@isTest
public class FavoritesControllerTest {
    
    
    private static User createUser(String firstName, String lastName) {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User u = new user();
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = firstName+'.'+lastName+'@test.com';
        u.Alias = 'pvyskoc';
        u.Username = 'test1234444@aspire.cz';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        
        insert u;
        return u;
    }    
    
    
    @isTest
    public static void addToFavoritesTest() {
Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        Brand__c b = new Brand__c();
        b.Name = 'TREK';
        insert b;
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        
        
        User testUser = createUser('Pepa', 'Vyskoc');
        
        Test.startTest();
        insert doc;
        System.runAs(testUser) {
            FavoritesController.addToFavorites(doc.Id);
        }
        
        Test.stopTest();
        
        Document__c testDoc = [SELECT Id, Favorites_User_List__c FROM Document__c WHERE Id = :doc.Id LIMIT 1];
        User u = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :testUser.Id LIMIT 1];
        
        System.assertEquals(true, testDoc.Favorites_User_List__c.contains(u.Sharing_Id__c), 'Document was not added into favorites!');
        
    }
    
    @isTest
    public static void addToFavoritesTest_Fail() {
Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        Brand__c b = new Brand__c();
        b.Name = 'TREK';
        insert b;
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        
        
        User testUser = createUser('Pepa', 'Vyskoc');
        testUser.Sharing_Id__c = '';
        update testUser;
        
        Test.startTest();
        insert doc;
        System.runAs(testUser) {
            FavoritesController.addToFavorites(doc.Id);
        }
        
        Test.stopTest();
        
        Document__c testDoc = [SELECT Id, Favorites_User_List__c FROM Document__c WHERE Id = :doc.Id LIMIT 1];
        User u = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :testUser.Id LIMIT 1];
        
        System.assertEquals(true, testDoc.Favorites_User_List__c == null, 'Document was added into favorites even if Sharing_Id__c for user is blank!');
        
    }
    
    /*@isTest
    public static void removFromFavoritesTest() {
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        Brand__c b = new Brand__c();
        b.Name = 'TREK';
        insert b;
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        
        
        User testUser = createUser('Pepa', 'Vyskoc');
        
        Document__c testDoc1;
        
        Test.startTest();
        insert doc;
        System.runAs(testUser) {
            FavoritesController.addToFavorites(doc.Id);
            FavoritesController.removeFromFavorites(doc.Id);
        }
        
        Test.stopTest();
        
        Document__c testDoc = [SELECT Id, Favorites_User_List__c FROM Document__c WHERE Id = :doc.Id LIMIT 1];
        User u = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :testUser.Id LIMIT 1];
        
        System.assertEquals(true, testDoc.Favorites_User_List__c == null, 'Document was not removed from favorites!');
        
        
    }*/
    
    @isTest
    public static void removFromFavoritesTest_Fail() {
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        Brand__c b = new Brand__c();
        b.Name = 'TREK';
        insert b;
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        
        
        User testUser = createUser('Pepa', 'Vyskoc');
        
        Document__c testDoc1;
        
        Test.startTest();
        insert doc;
        System.runAs(testUser) {
            FavoritesController.addToFavorites(doc.Id);
            
            testUser.Sharing_Id__c = '';
            update testUser;
            
            FavoritesController.removeFromFavorites(doc.Id);
        }
        
        Test.stopTest();
        
        Document__c testDoc = [SELECT Id, Favorites_User_List__c FROM Document__c WHERE Id = :doc.Id LIMIT 1];
        User u = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :testUser.Id LIMIT 1];
        
        System.assertEquals(false, testDoc.Favorites_User_List__c == null, 'Document was removed from favorites even Sharing_Id__c for user is blank!');
        
        
    }

}