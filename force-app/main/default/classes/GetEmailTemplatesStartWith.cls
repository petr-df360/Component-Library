public class GetEmailTemplatesStartWith {
  
    public class FlowInputs {
        @InvocableVariable(label='Input Prefixes' required=true)
        public List<String> inputPrefixes;
    }

    @InvocableMethod(label='Get Email Templates Start With' description='Fetch email templates with names starting with the given prefix' iconName='slds:standard:template')
    public static List<List<EmailTemplate>> getEmailTemplates(List<FlowInputs> inputsCollection) {
        List<List<EmailTemplate>> allTemplates = new List<List<EmailTemplate>>();
        
        // For each set of inputs
        for (FlowInputs inputs : inputsCollection) {
            List<String> conditions = new List<String>();
            
            // Create conditions for all the prefixes in the set
            for (String prefix : inputs.inputPrefixes) {
                conditions.add('Name LIKE \'' + String.escapeSingleQuotes(prefix) + '%\'');
            }
            
            String condition = String.join(conditions, ' OR ');
            String soql = 'SELECT Id, Name, IsActive, FolderId FROM EmailTemplate WHERE ' + condition;
          
            List<EmailTemplate> templates = Database.query(soql);
            allTemplates.add(templates);
        }
        
        return allTemplates;
    }
}