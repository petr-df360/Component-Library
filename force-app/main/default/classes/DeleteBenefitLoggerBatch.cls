global class DeleteBenefitLoggerBatch implements Database.Batchable<sObject> {
    
    Date today = Date.today();
    
    Date daysAgo14 = today.addDays(-14);
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(!Test.isRunningTest()) {
            query = 'SELECT Id FROM BenefitLogger__c WHERE CreatedDate < N_DAYS_AGO:14';
        }else{
            query = 'SELECT Id FROM BenefitLogger__c';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<BenefitLogger__c> logList) {
        List<BenefitLogger__c> logsToDelete = new List<BenefitLogger__c>();
        
        for(BenefitLogger__c singleLog : logList) {
            logsToDelete.add(singleLog);
        }
        
        delete logsToDelete;
        
    }
    
    global void finish(Database.BatchableContext info) {
        //nothing here
    }
    
    

}