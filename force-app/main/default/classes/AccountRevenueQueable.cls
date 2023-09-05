public class AccountRevenueQueable implements System.Queueable {
    
    String revenueJson;
    
    public AccountRevenueQueable(String revenueJson) {
        this.revenueJson = revenueJson;
    }

    public void execute(QueueableContext context) {

        JSONParser parser = JSON.createParser(revenueJson);
        List<BenefitTypes.RevenueJSON> revenuesBulk = new List<BenefitTypes.RevenueJSON>();
        System.debug('Processing partner_statistics HeapSize: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        
        while (parser.nextToken() != null) {
        // Start at the array of revenues
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire revenue object
                        BenefitTypes.RevenueJSON partnerRevenue = (BenefitTypes.RevenueJSON) parser.readValueAs(BenefitTypes.RevenueJSON.class);
                        revenuesBulk.add(partnerRevenue);
                        parser.skipChildren();
                    }
                }
            }
        }

        revenueJson = null; // clear out heap

        if(!revenuesBulk.isEmpty()){
            System.debug('Parsed partner_statistics HeapSize: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
            System.debug(System.LoggingLevel.INFO, 'Processing partner_statistics/revenue records ' + revenuesBulk.size());
            AccountRevenueController.updateRevenues(revenuesBulk);
        }
  }
}