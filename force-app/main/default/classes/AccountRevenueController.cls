public class AccountRevenueController {
    static final String WITHOUT_BRAND = 'BEZ ZNAČKY';
    static final Integer BATCH_SIZE = 2000;
    
    public static void updateRevenues(List<BenefitTypes.RevenueJSON> revenues) {
        Map<Id, List<BrandToStoreAssignment__c>> newAssignments = new Map<Id, List<BrandToStoreAssignment__c>>();
        Map<String, Account> stores = new Map<String, Account>();
        Map<String, Brand__c> brandsUpperCase = new Map<String, Brand__c>();
        Set<String> brandNamesUpperCase = new Set<String>{WITHOUT_BRAND};
        Map<String,Set<String>> partnerAddressMap = new Map<String,Set<String>>();
        Map<String, Set<String>> accountMap = new Map<String, Set<String>> {'partners' => new Set<String>(), 'addresses' => new Set<String>() };

        System.debug('Processing '+revenues.size()+' account revenues.');

        // Go over revenues
        for(BenefitTypes.RevenueJSON rev:revenues) {
            // Gather brand names
            if(!brandNamesUpperCase.contains(rev.brand.toUpperCase())) {
                brandNamesUpperCase.add(rev.brand.toUpperCase());
            }
                
            // Gather partner Ids
            if(!accountMap.get('partners').contains(rev.ben_partid)) {
                accountMap.get('partners').add(rev.ben_partid);
            }
            
            // Gather partner address Ids
            if(!accountMap.get('addresses').contains(rev.ben_padrid)) {
                accountMap.get('addresses').add(rev.ben_padrid);
            }
            
            // Map of partner stores -> PartnerId to AddressId
            if(partnerAddressMap.containsKey(rev.ben_partid)){
                partnerAddressMap.get(rev.ben_partid).add(rev.ben_padrid);
            }else{
                partnerAddressMap.put(rev.ben_partid, new Set<String>{rev.ben_padrid});
            }
        }
        
        stores = getStoreMap(accountMap, partnerAddressMap);
        brandsUpperCase = getBrands(brandNamesUpperCase);
        
        partnerAddressMap.clear();
        accountMap.clear();
        brandNamesUpperCase.clear();
        
        //For each received partner revenue
        Integer missingStore = 0;
        for(BenefitTypes.RevenueJSON rev:revenues) {
            BrandToStoreAssignment__c newAssignment;
            // Get store by combination of partner&address ID, go to next revenue if store not found
            String storeKey = String.valueOf(rev.ben_partid) +'_'+ String.valueOf(rev.ben_padrid);
            Account store = stores.get(storeKey);
            if(store == null) {
                missingStore++;
                // System.debug('Store not found for '+storeKey); - ADD benefit error logger?
                // TODO: create benfit error logger record
                continue;
            }

            // main account Id - set to store.Id if acount is the main one
            Id mainAccountId = (store.Account__c == null) ? store.Id : store.Account__c;
            String brand = (rev.brand == null) ? WITHOUT_BRAND : rev.brand.toUpperCase();
            
            newAssignment = new BrandToStoreAssignment__c(
                Brand__c = brandsUpperCase.get(brand).Id,
                Account__c = store.Id,
                ParentAccount__c = mainAccountId,
                Revenue__c = rev.revenue_ytd,
                RevenueB2B__c = rev.revenue_b2b,
                Revenue_2_Years__c = rev.revenue_2ytd,
                Unreleased_PO__c = rev.unreleased_preorder,
                Revenue_Last_Year__c = rev.revenue_ly,
                Brand_Name_String__c = brand
            );
            //System.debug('Creating new for ' + brand +' and '+store.Id + ' with revenue: ' + newAssignment.Revenue__c);
            
            // Add to list for upsert
            if(newAssignments.containsKey(newAssignment.ParentAccount__c)){
                newAssignments.get(newAssignment.ParentAccount__c).add(newAssignment);
                
            }else{
                newAssignments.put(newAssignment.ParentAccount__c, new List<BrandToStoreAssignment__c>{newAssignment});
            }
        }

        System.debug('Store not found for records: ' +missingStore);
        revenues.clear();
        updateRevenuesInbatch(newAssignments.values());
        
    }
    
    private static void updateRevenuesInbatch(List<List<BrandToStoreAssignment__c>> brandStoreRevenues){
        // Project worker has all the batches - instance is too big
        // TODO: Rework so worker has only it's 2k records and only starts next job when done
        BatchWorkerController projectWorker = new BatchWorkerController();
        List<BrandToStoreAssignment__c> toBatch = new List<BrandToStoreAssignment__c>();
        
        Integer reordCounter = 0;

        for(List<BrandToStoreAssignment__c> bts : brandStoreRevenues){
            // If there are <2K revenues, add records from another account
            if(toBatch.size() < AccountRevenueController.BATCH_SIZE){
                toBatch.addAll(bts);
            }else{
                toBatch.addAll(bts);
                System.debug('BatchWorkerController adding workload of size: '+toBatch.size());
                projectWorker.addWork( new BatchWorkerController.updateRevenueWork(toBatch));
                toBatch = new List<BrandToStoreAssignment__c>();
            }
            reordCounter+=bts.size();
        }

        System.debug('BatchWorkerControlle Total Records: ' + reordCounter + ' records.');
        if(toBatch != null && !toBatch.isEmpty()) {
            System.debug('BatchWorkerController.addWork FINAL ROUND: '+toBatch.size());
            projectWorker.addWork( new BatchWorkerController.updateRevenueWork(toBatch));
            Id jobId = projectWorker.run().BatchJobId;
            toBatch = new List<BrandToStoreAssignment__c>();
        }
        
    }

    private static Map<String, Account> getStoreMap(Map<String, Set<String>> accountMap, Map<String,Set<String>> partnerAddressMap) {
        Map<String,Account> storesMap = new Map<String,Account>();
        for(Account acc : [SELECT Id,Benefit_Main_Account_Id__c,Benefit_Id__c,RecordType_Name__c,Account__c, Benefit_Store_Id__c
        FROM Account
        WHERE Benefit_Store_Id__c IN :accountMap.get('addresses') AND
        (Benefit_Main_Account_Id__c IN :accountMap.get('partners') OR Benefit_Id__c IN :accountMap.get('partners'))
        FOR UPDATE]) {
            String composedKey;

            // Parent account - composeKey is benefitId + storeId
            if(acc.Benefit_Main_Account_Id__c == null) {
                composedKey =  String.valueOf(acc.Benefit_Id__c) + '_' + String.valueOf(acc.Benefit_Store_Id__c);

                // If storesMap contains account & its storeId
                if(partnerAddressMap.containsKey(acc.Benefit_Id__c) && partnerAddressMap.get(acc.Benefit_Id__c).contains(acc.Benefit_Store_Id__c)) {
                    storesMap.put(composedKey, acc);
                }
            } else {
                // Child account - composeKey is parent account benefitId + storeId
                composedKey =  String.valueOf(acc.Benefit_Main_Account_Id__c) + '_' + String.valueOf(acc.Benefit_Store_Id__c);

                // If storesMap contains main account & current storeId
                if(partnerAddressMap.containsKey(acc.Benefit_Main_Account_Id__c) && partnerAddressMap.get(acc.Benefit_Main_Account_Id__c).contains(acc.Benefit_Store_Id__c)) {
                    storesMap.put(composedKey, acc);
                }
            }
        }

        return storesMap;
    }

    private static Map<String, Brand__c> getBrands(Set<String> brandNames) {
        Map<String, Brand__c> brands = new Map<String, Brand__c>();
         
        // Get all brands & create missing
         for(Brand__c b : [SELECT Id, Name FROM Brand__c WHERE (Name IN :brandNames AND Is_Sales_Plan_Brand__c = false AND Marketing_Communication__c = false) FOR UPDATE]) {
            brands.put(b.Name.toUpperCase(), b);
        }

        List<Brand__c> newBrands = new List<Brand__c>();
        for(String b : brandNames){
            if(!brands.containsKey(b)){
                Brand__c newBrand = new Brand__c(Name = b);
                newBrands.add(newBrand);
                brands.put(newBrand.Name, newBrand);
            }
        }
        insert newBrands;
        return brands;
    }
     
}