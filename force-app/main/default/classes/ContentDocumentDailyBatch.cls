global class ContentDocumentDailyBatch  implements Database.Batchable<sObject>{    
    global ContentDocumentDailyBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
       String query = 'SELECT Id, Description FROM ContentDocument WHERE Description = \'TO-DELETE-OUTLOOK\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ContentDocument> scope){       
        try{
            delete scope;}
        catch(Exception e){
            System.debug('Failed to delete attachment '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}