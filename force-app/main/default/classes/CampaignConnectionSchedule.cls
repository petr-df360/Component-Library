global class CampaignConnectionSchedule implements Schedulable {
    public String batchQuery;
    
    global void execute(SchedulableContext sc) {
        CampaignConnectionBatch campaignJob;
        
        if(this.batchQuery != null){
            campaignJob = new CampaignConnectionBatch(batchQuery);
        }else{
            campaignJob = new CampaignConnectionBatch(null);    
        }
        
        database.executeBatch(campaignJob, 200);
    }
    
}