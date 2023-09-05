@isTest
public with sharing class CreateClientPortalUserInvocableTest{
    @TestSetup
    static void testSetup(){
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Crestyl Administrator') AND IsActive = true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account account = new Account(Name = 'Test Account');
            insert account;

            Contact contact1 = new Contact(FirstName = 'Test1', LastName = 'Test', 
                    Email = Datetime.now().getTime()+'test1@test.cz', AccountId = account.Id, Mobile_Custom__c = '+420999999999');
            insert contact1;
        }
    }

    @isTest
    static void should_createClientPortalUser(){
        Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'Test1'];
        List<User> userList;

        Test.startTest();
        userList = CreateClientPortalUserInvocable.createClientPortalUser(new List<String>{contact.Id});
        Test.stopTest();

        System.assert(userList.size() > 0, 'One user is supposed to be created');
    }
}