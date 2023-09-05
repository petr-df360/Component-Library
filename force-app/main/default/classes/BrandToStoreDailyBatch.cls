global class BrandToStoreDailyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    global BrandToStoreDailyBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM BrandToStoreAssignment__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<BrandToStoreAssignment__c> scope){
        Delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {       
        BenefitServiceProvider.getPartnerRevenue();
    }
}