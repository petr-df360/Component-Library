global class BrandToBrandDailyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    global BrandToBrandDailyBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM BrandToBrandAssignment__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<BrandToBrandAssignment__c> scope){
        Delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
       Database.executeBatch(new BrandToStoreDailyBatch(), 200);
    }
}