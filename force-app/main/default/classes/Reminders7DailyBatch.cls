public class Reminders7DailyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Invoice_Reminder__c LIMIT 100';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Invoice_Reminder__C> scope) {
        //nothing to do here
    }
    
    public static void finish(Database.BatchableContext BC) {
        BenefitServiceProvider.getPartnerInvoices(10, 10);
        Database.executeBatch(new Reminders14DailyBatch());
    }

}