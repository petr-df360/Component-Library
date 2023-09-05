@isTest
public class SharepointControllersTest {
    
     @isTest
    public static void tokenFail(){
        try{
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointTokenFail());
            SharepointController.getToken();}
        catch(Exception e){
            System.assert(e.getTypeName() =='System.CalloutException');
        }
    }
    
     @isTest
    public static void uploadTestFail(){
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockFail());
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom Standard User' OR Name='Standardní Uživatel' OR Name='aspire Custom Standard User'];

        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        
        Brand__c b = new Brand__c(Name='testBrand');
        insert b;
        
        Group g = new Group();        
       	g.DeveloperName='group1';
        g.Name = 'group1';
        insert g;
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        insert doc;
        
        Test.startTest();
        
        SharepointController.lightningResponse res = SharepointController.startUpload('testFile', '1', 'docId');
        SharepointController.lightningResponse res2 = SharepointController.continueUpload(res.offset, 'testFile', '2', 'docId', res.guid);
        SharepointController.finishUpload(res2.offset, 'testFile', '2', 'testId', res2.guid,true);
        
        
        SharepointController.addRoleAssignment(doc.Id, g.Id, 'Read',false);
        
        Test.stopTest();
        Document__c returnedDoc = SharepointController.getDocument(doc.id);
        SharepointController.attachFile('url', returnedDoc.Id, 'fileName','fileName',null);
        SharepointController.removeFileLink(returnedDoc.Id);
        
        SharepointController.removeToast(doc.Id);
        
        
        doc.OwnerId =usr.Id;
        update doc;
        
    }
    
    @isTest
    public static void uploadTest(){
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom Standard User' OR Name='Standardní Uživatel' OR Name='aspire Custom Standard User'];

        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        
        Brand__c b = new Brand__c(Name='testBrand');
        insert b;        
        
        Group g = new Group();        
       	g.DeveloperName='group1';
        g.Name = 'group1';
        insert g;
        
        Test.startTest();
        
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id);
        insert doc;
        Test.stopTest();
        
        Document__c returnedDoc = SharepointController.getDocument(doc.id);
        /*SharepointController.removeToast(doc.Id);
        SharepointController.attachFile('url', returnedDoc.Id, 'fileName','fileName',null);
        SharepointController.removeFileLink(returnedDoc.Id);
        
        SharepointController.lightningResponse res = SharepointController.startUpload('testFile', '1', doc.Id);
        SharepointController.lightningResponse res2 = SharepointController.continueUpload(res.offset, 'testFile', '2',doc.Id, res.guid);
        SharepointController.finishUpload(res2.offset, 'testFile', '2', 'testId', res2.guid,true);*/
        
        SharepointController.simpleUploadOutlook('fileName',Blob.valueOf('2'),doc.Id,true,null);
        
        //SharepointController.addRoleAssignment(doc.Id, g.Id, 'Read',true);
        doc.OwnerId =usr.Id;
        update doc;
        
    }
    
    @isTest
    public static void uploadOutlook(){
        Test.setMock(HTTPCalloutMock.class, new SharepointCalloutMockProvider.SharepointMockSuccess());
        //SharepointController.simpleUpload('testFile', '1', 'docId');
        
        Brand__c b = new Brand__c(Name='testBrand');
        insert b;
        Document__c doc = new Document__c(Name='TestDoc',Brand__c = b.Id,File_Storage_Location__c='url');
        insert doc;
        
        
        EmailMessage em = new EmailMessage();
        Blob bx = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = doc.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = bx;
        insert(attachment);
        
        em.RelatedToId=doc.Id;
        insert em;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Penguins2',
            PathOnClient = 'Penguins2.jpg',
            VersionData = Blob.valueOf('Test Content2'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = em.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        Test.startTest();
        insert cdl;
        Test.stopTest();
    }
    
    
}