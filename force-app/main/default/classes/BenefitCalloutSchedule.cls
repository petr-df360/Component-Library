global class BenefitCalloutSchedule implements Schedulable{
    
    global void execute(SchedulableContext ctx){
        
      AccountDailyBatch batch = new AccountDailyBatch();
      Database.executebatch(batch, 200);
        
    }

}