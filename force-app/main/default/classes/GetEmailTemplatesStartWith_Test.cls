@isTest
public with sharing class GetEmailTemplatesStartWith_Test {
 
    @isTest(SeeAllData=true)
    static void testGetEmailTemplates() {
        // Get EmailFolder
        EmailTemplate et = [SELECT FolderId FROM EmailTemplate LIMIT 1];

        // Create EmailTemplates
        List<EmailTemplate> templatesToInsert = new List<EmailTemplate>{
            new EmailTemplate(Name='QTestTemplate1', DeveloperName='TestTemplate1', TemplateType='text', IsActive=true, FolderId=et.FolderId),
            new EmailTemplate(Name='QSampleTemplate1', DeveloperName='SampleTemplate1', TemplateType='text', IsActive=true, FolderId=et.FolderId)
        };


        insert templatesToInsert;
        
        // Initialize the inputs
        GetEmailTemplatesStartWith.FlowInputs fInputs = new GetEmailTemplatesStartWith.FlowInputs();
        fInputs.inputPrefixes = new List<String>{'QTest', 'QSample'};

        // Test the invocable method
        Test.startTest();
        List<List<EmailTemplate>> templates = GetEmailTemplatesStartWith.getEmailTemplates(new List<GetEmailTemplatesStartWith.FlowInputs>{fInputs});
        Test.stopTest();

        // Asserts
        System.assertNotEquals(0, templates.size(), 'No templates fetched');

        for (List<EmailTemplate> tempList : templates) {
            // assert that each list is not empty
            System.assertNotEquals(0, tempList.size(), 'No templates fetched for specific prefix');
            
            for (EmailTemplate tmp : tempList) {
                System.debug(tmp.Name);
                // assert that the template name starts with expected prefixes
                System.assert(tmp.Name.startsWith('QTest') || tmp.Name.startsWith('QSample'), tmp.Name+' Template name does not start with the expected prefix');
            }
        }
    }
}