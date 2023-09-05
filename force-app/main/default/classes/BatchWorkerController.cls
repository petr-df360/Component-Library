public class BatchWorkerController extends BatchWorker {
    
    public BatchWorkerController updateRevenue(List<BrandToStoreAssignment__c> bts)
    {
        return (BatchWorkerController) super.addWork(new UpdateRevenueWork(bts));
    }
    
    public BatchWorkerController upsertInvoiceReminders(List<Invoice_Reminder__c> reminders)
    {
        return (BatchWorkerController) super.addWork(new UpsertInvoiceReminders(reminders));
    }
    
    
    
    public override void doWork(Object work)
    {   
        if(work instanceof UpdateRevenueWork)
        {
            UpdateRevenueWork setupProject = (UpdateRevenueWork) work;
            setupProject.upsertRevenues();
        } else if(work instanceof UpsertInvoiceReminders) {
            UpsertInvoiceReminders upserThem = (UpsertInvoiceReminders) work;
            upserThem.upsertReminders();
        }
    }
    
    
    public class UpdateRevenueWork{
        private List<BrandToStoreAssignment__c> btss;
        
        public UpdateRevenueWork(List<BrandToStoreAssignment__c> btss){
            this.btss = btss;
        }
        
        private void upsertRevenues() {
            Database.UpsertResult[] lsr = Database.upsert(btss, BrandToStoreAssignment__c.Id, true);
            List<BenefitLogger__c> loggers = new List<BenefitLogger__c>();
            
            for(Database.UpsertResult result : lsr) {
                if(!result.isSuccess()){
                    BenefitLogger__c logger = new BenefitLogger__c();
                    logger.Message__c = 'Error creating B2Store assignment '+result.getId()+' '+result.getErrors()[0].getMessage();
                    loggers.add(logger);
                }
            }
            
            if(!loggers.isEmpty()) {
                insert loggers;
            }
            
        }
        
    }
    
    public class UpsertInvoiceReminders{
        private List<Invoice_Reminder__c> reminders;
        
        public upsertInvoiceReminders(List<Invoice_Reminder__c> reminders) {
            this.reminders = reminders;
        }
        
        private void upsertReminders() {
            upsert this.reminders;
        }
    }
    
}