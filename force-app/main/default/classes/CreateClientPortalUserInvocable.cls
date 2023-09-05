public with sharing class CreateClientPortalUserInvocable {
    @InvocableMethod(Label='Create Client Portal User')
    public static List<User> createClientPortalUser(List<String> contactIdList){
        Set<Id> contactIdSet = new Set<Id>();
        for(Id contactId: contactIdList){
            contactIdSet.add(contactId);
        }
        List<User> userList = (new CommunityUserService()).createCrestylClientPortalUsers(new Set<Id>(contactIdSet));
        return userList;
    }
}