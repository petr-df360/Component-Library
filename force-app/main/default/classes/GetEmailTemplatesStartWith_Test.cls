@isTest
public class GetEmailTemplatesStartWith_Test {

    @isTest
    static void testGetEmailTemplates() {
        // Initialize the inputs
        GetEmailTemplatesStartWith.FlowInputs fInputs = new GetEmailTemplatesStartWith.FlowInputs();
        fInputs.inputPrefixes = new List<String>{'Test', 'Sample'};

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
                // assert that the template name starts with expected prefixes
                System.assert(tmp.Name.startsWith('Test') || tmp.Name.startsWith('Sample'), 'Template name does not start with the expected prefix');
            }
        }
    }
}