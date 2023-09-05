global class BenefitScheduledJobs implements Schedulable {
    
    global void execute(SchedulableContext ctx) {        
        Database.executeBatch(new AccountDailyBatch(), 200); 
    }
    
}