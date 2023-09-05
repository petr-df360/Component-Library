global class AccountDailyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    global AccountDailyBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
       String query = 'SELECT Balance_After_Due__c, Balance_Total__c FROM Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        for(Account acc:scope){
            acc.Balance_After_Due__c = 0;
            acc.Balance_Total__c = 0;
        }
        update scope;        
    }
    
    global static void finish(Database.BatchableContext BC) {
       	BenefitServiceProvider.getPartnerBalance();
        
        Database.executeBatch(new BrandToBrandDailyBatch(), 200);
    }
    
}