@isTest
public with sharing class FileTriggerTest {
    
    
    @isTest
    public static void insertSingleFileTest() {
        
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        
        
        Brand__c b = new Brand__c(Name='testBrand');
        insert b;
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        insert doc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom Standard User' OR Name='Standardní Uživatel' OR Name='aspire Custom Standard User'];
        
        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        
        Group g = new Group();
        g.DeveloperName='group1';
        g.Name = 'group1';
        insert g;
        
        Document__c returnedDoc = SharepointController.getDocument(doc.id);
        
        
        List<File__c> files = new List<File__c>();
        
        for(integer i = 1; i < 12; i++) {
            File__c file = new File__c();
            file.Document__c = returnedDoc.Id;
            file.File_Name__c = 'Test file ' +i;
            file.SP_File_Name__c = 'Test file '+i;
            files.add(file);
        }
        
        
        
        Test.startTest();
        
        insert files;
        
        Test.stopTest();
        
        Document__c testDocument = [SELECT Id, File1__c, File3__c, File5__c, File10__c, Open_File1__c, Open_File3__c, Open_File5__c, Open_File10__c FROM Document__c WHERE Id = :doc.Id];
        System.debug('testDoc '+testDocument);
        System.assertEquals('Test file 1', testDocument.File1__c, 'Field File1__c is missing correct file name!');
        System.assertEquals(true, testDocument.Open_File1__c.contains('Test file 1'), 'Field Open_File1__c is missing correct link name!');
        System.assertEquals('Test file 3', testDocument.File3__c, 'Field File3__c is missing correct file name!');
        System.assertEquals(true, testDocument.Open_File3__c.contains('Test file 3'), 'Field Open_File3__c is missing correct link name!');
        System.assertEquals('Test file 5', testDocument.File5__c, 'Field File5__c is missing correct file name!');
        System.assertEquals(true, testDocument.Open_File5__c.contains('Test file 5'), 'Field Open_File5__c is missing correct link name!');
        System.assertEquals('Test file 10', testDocument.File10__c, 'Field File10__c is missing correct file name!');
        System.assertEquals(true, testDocument.Open_File10__c.contains('Test file 10'), 'Field Open_File10__c is missing correct link name!');
        
    }
    
    
    @isTest
    public static void deleteFileTest() {
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        
        
        Brand__c b = new Brand__c(Name='testBrand');
        insert b;
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom Standard User' OR Name='Standardní Uživatel' OR Name='aspire Custom Standard User'];
        
        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        
        Group g = new Group();
        g.DeveloperName='group1';
        g.Name = 'group1';
        insert g;
        
        
        
        List<File__c> files = new List<File__c>();
        
        
        
        
        Document__c testDocument1;
        Document__c testDocument2;
        Document__c testDocument3;
        Document__c testDocument4;
        Document__c testDocument5;
        Document__c testDocument6;
        Document__c testDocument7;
        Document__c testDocument8;
        Document__c testDocument9;
        Document__c testDocument10;
        Document__c testDocument11;
        
        Test.startTest();
        insert doc;
        
        Document__c returnedDoc = SharepointController.getDocument(doc.id);
        for(integer i = 1; i < 12; i++) {
            File__c file = new File__c();
            file.Document__c = returnedDoc.Id;
            file.File_Name__c = 'Test file ' +i;
            file.SP_File_Name__c = 'Test file ' +i;
            files.add(file);
        }
        
        insert files;
        
        delete files[9];
        testDocument1 = [SELECT Id, File10__c, Open_File10__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[8];
        testDocument2 = [SELECT Id, File9__c,  Open_File9__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[7];
        testDocument3 = [SELECT Id,  File8__c,  Open_File8__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[6];
        testDocument4 = [SELECT Id,  File7__c,  Open_File7__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[5];
        testDocument5 = [SELECT Id,  File6__c,  Open_File6__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[4];
        testDocument6 = [SELECT Id,  File5__c,  Open_File5__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[3];
        testDocument7 = [SELECT Id,  File4__c,  Open_File4__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[2];
        testDocument8 = [SELECT Id,  File3__c,  Open_File2__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[1];
        testDocument9 = [SELECT Id, File2__c, Open_File2__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[0];
        testDocument10 = [SELECT Id, File1__c, Open_File1__c FROM Document__c WHERE Id = :doc.Id];
        
        delete files[10];
        testDocument11 = [SELECT Id, File1__c, Open_File1__c FROM Document__c WHERE Id = :doc.Id];
        
        
        Test.stopTest();
        
        System.assertEquals(true, testDocument1.File10__c.contains(files[10].File_Name__c), 'File11 should go to 10th position when 10th file was deleted!');
        System.assertEquals(true, testDocument2.File9__c.contains(files[10].File_Name__c), 'File11 should go to 9th position when 10th and 9th files were deleted!');
        System.assertEquals(true, testDocument3.File8__c.contains(files[10].File_Name__c), 'File11 should go to 8th position when 10th and 9th and 8th files were deleted!');
        System.assertEquals(true, testDocument4.File7__c.contains(files[10].File_Name__c), 'File11 should go to 7th position when 10th - 7th files were deleted!');
        System.assertEquals(true, testDocument5.File6__c.contains(files[10].File_Name__c), 'File11 should go to 6th position when 10th - 6th files were deleted!');
        System.assertEquals(true, testDocument6.File5__c.contains(files[10].File_Name__c), 'File11 should go to 5th position when 10th - 5th files were deleted!');
        System.assertEquals(true, testDocument7.File4__c.contains(files[10].File_Name__c), 'File11 should go to 4th position when 10th - 4th files were deleted!');
        System.assertEquals(true, testDocument8.File3__c.contains(files[10].File_Name__c), 'File11 should go to 3th position when 10th - 3th files were deleted!');
        System.assertEquals(true, testDocument9.File2__c.contains(files[10].File_Name__c), 'File11 should go to 2th position when 10th - 2th files were deleted!');
        System.assertEquals(true, testDocument10.File1__c.contains(files[10].File_Name__c), 'File11 should go to 1th position when 10th - 1th files were deleted!');
        
    }
    
}