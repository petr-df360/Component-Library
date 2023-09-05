/**
 * Methods related to Digital Experience
 *
 * @author  Stepan Ruzicka stepan@mooza.io
 * @date    2022-02-25
 */
public with sharing class CommunityUserService {
    private static final String DEFAULT_LANGUAGE_LOCALE_KEY = 'cs';
    private static final String DEFAULT_LANGUAGE_SID_KEY = 'cs_CZ';
    private static final String DEFAULT_COUNTRY = 'Czech Republic';
    private static final String DEFAULT_TIMEZONE_SID_KEY = 'Europe/Prague';
    private static final String DEFAULT_ENCODING = 'UTF-8';
    private static final String CLIENT_PORTAL_PROFILE = 'Customer Community Plus Login User';
    @TestVisible
    private static final Set<String> DEFAULT_PERMISSION_SETS = new Set<String>{'Client_Portal'};
    private static final Boolean SEND_EMAIL = true;
    private String userNameSuffix = '';

    private Id defaultProfileId{
        get{
            if(defaultProfileId == null){
                try{
                    defaultProfileId = [SELECT Id FROM Profile WHERE Name = :CLIENT_PORTAL_PROFILE].Id;
                }catch(QueryException ex){
                    // TODO: label
                    throw new ClientPortalUserException(CLIENT_PORTAL_PROFILE + ' profile is not available in the current org.');
                }
            }
            return defaultProfileId;
        }
        set;
    }

    private Set<Id> defaultPermissionSetIds{
        get{
            if(defaultPermissionSetIds == null){
                defaultPermissionSetIds = (new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name in :DEFAULT_PERMISSION_SETS])).keySet();
            }
            return defaultPermissionSetIds;
        }
        set;
    }
    
    /**
     * The method creates community users for contacts
     *
     * @param contactIds Contacts to be enabled as customers
     *
     * @return - list of created users
     */
    public List<User> createCrestylClientPortalUsers(Set<Id> contactIds){
        Id clientPortalProfileId;
        List<Contact> contactList;
        List<User> users = new List<User>();

        // get contact details
        contactList = getContactDetails(contactIds);

        return createClientPortalUsers(contactList, defaultProfileId, defaultPermissionSetIds);
    }
    
    /**
     * The method creates community users for contacts and assings profile and permission sets
     *
     * @param contacts Contacts to be enabled as customers
     * @param profileId Profile to be assigned
     * @param permissionSetIds Permission sets to be assigned
     *
     * @return - list of created users
     */
    @TestVisible
    private List<User> createClientPortalUsers(List<Contact> contacts, Id profileId, Set<Id> permissionSetIds){
        List<User> userList = new List<User>();
        
        for(Contact contact: contacts){
            userList.add(createClientPortalUser(contact, profileId, permissionSetIds));
        }

        if(permissionSetIds != null){
            assignPermissionSets(userList, permissionSetIds);
        }
        
        return userList;
    }
    
    /**
     * The method creates community user for given contact and assings profile and permission sets
     *
     * @param contact Contact to be enabled as customer
     * @param profileId Profile to be assigned
     * @param permissionSetIds Permission sets to be assigned
     *
     * @return - list of created users
     */
    @TestVisible
    private User createClientPortalUser(Contact contact, Id profileId, Set<Id> permissionSetIds){
	String suffix;

        if(contact?.FirstName == null || contact?.LastName == null || contact?.Email == null){
            // TODO: label
            throw new ClientPortalUserException('FirstName, LastName and Email must be populated on Contact record.');
        }

        User clientPortalUser = new User(
                ProfileId = profileId,
                ContactId = contact.Id,
                Alias = getAlias(contact.FirstName, contact.LastName).left(8),
                Email = contact.Email,
                EmailEncodingKey = DEFAULT_ENCODING,
                FirstName = contact.FirstName,
                LastName = contact.LastName,
                LanguageLocaleKey = DEFAULT_LANGUAGE_LOCALE_KEY,
                LocaleSidKey = DEFAULT_LANGUAGE_SID_KEY,
                Country = DEFAULT_COUNTRY,
                TimeZoneSidKey = DEFAULT_TIMEZONE_SID_KEY,
                IsActive = true
        );
	suffix = getUsernameSuffix();
	if(suffix != null && suffix.length() > 0){
	   clientPortalUser.Username = contact.Email + '.' + suffix;
	}else{
           clientPortalUser.Username = contact.Email;
	}

        setSendInvitaionEmail(clientPortalUser);

        insert clientPortalUser;

        return clientPortalUser;
    }
    
    /**
     * Queries contact details for given contact Ids
     *
     * @param contactIds Contacts to be retrieved
     *
     * @return - list of contacts
     */
    @TestVisible
    private List<Contact> getContactDetails(Set<Id> contactIds){
        return [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id in :contactIds];
    }
    
    /**
     * Get alias based on firstname and lastname
     *
     * @param firstName
     * @param lastName
     *
     * @return - alias
     */
    @TestVisible
    private String getAlias(String firstName, String lastName) {
        String alias = '';

        if(firstname != null) {
            alias += firstname.substring(0, 1);
        }

        if(lastName != null) {
            alias += lastName;
        }

        return alias;
    }

    /**
     * Gets username's suffix based on the type of organisation
     *
     * @return - suffix
     */
    @TestVisible
    private String getUsernameSuffix(){
        String usernameSuffix;
        Organization org = [SELECT Name FROM Organization];
        String sandboxName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.');

        usernameSuffix = org.Name.toLowerCase();

        if(Utils.isProd()){
            return '';
        }else if(Utils.isSandbox()){
            return org.Name.toLowerCase() + '.' + sandboxName;
        }else if(Utils.isScratchOrg()){
            return org.Name.toLowerCase() + '.' + String.valueof(DateTime.now().getTime());
        }

        return usernameSuffix;
    }

    /**
     * Sets DML Options for give user in order to send invitation email
     *
     * @return - DMLOptions
     */
    @TestVisible
    private Database.DMLOptions setSendInvitaionEmail(User user){
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.emailHeader.triggerUserEmail = true;
        dmlOptions.emailHeader.triggerAutoResponseEmail = true;
        user.setOptions(dmlOptions);
        return dmlOptions;
    }

    /**
     * Assigns permission sets to given users
     * 
     * @param userList List of users
     * @param permissionSetIds Permission sets to be assigned
     *
     * @return - List of permission set assignments
     */
    @TestVisible
    private List<PermissionSetAssignment> assignPermissionSets(List<User> userList, Set<Id> permissionSetIds){
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();

        for(User user: userList){
            for(Id permissionSetId: permissionSetIds){
                permissionSetAssignments.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionSetId));
            }
        }

        if(permissionSetAssignments.size() > 0 && !Test.isRunningTest()){
            insert permissionSetAssignments;
        }

        return permissionSetAssignments;
    }
    
    public class ClientPortalUserException extends Exception{}
}