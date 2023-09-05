public class BrandToStoreAssignmentTriggerHelper {

    private static List<BrandToBrandAssignment__c> getExistingAssignmentsByParentId(List<BrandToStoreAssignment__c> newAssignments){
        Set<Id> customerIds = new Set<Id>();
        
        for(BrandToStoreAssignment__c  assignment: newAssignments){
            customerIds.add(assignment.ParentAccount__c);
        }
        
        List<BrandToBrandAssignment__c> assignments = [SELECT Id, Account__c,Revenue_Last_Year__c, Account__r.Name, Brand__c, Revenue__c, Revenue_YTD_2_Years__c, RevenueB2B__c, Unreleased_PO__c
        FROM BrandToBrandAssignment__c
        WHERE Account__c IN :customerIds FOR UPDATE];
        return assignments;
    }
    
    public static void addRevenueToCustomerAssignment(List<BrandToStoreAssignment__c> newStoreAssignments) {
        Map<String,BrandToBrandAssignment__c> toUpsert = new Map<String,BrandToBrandAssignment__c>();
        
        List<BrandToBrandAssignment__c> assignments = getExistingAssignmentsByParentId(newStoreAssignments);
        
        // Go over new Brand2Store assignments and update/create new brand2brand assignments
        for(BrandToStoreAssignment__c  storeAssignment: newStoreAssignments){
            if(storeAssignment.ParentAccount__c == null){
                System.debug('Parent not found, skipping assignment: '+storeAssignment);
                continue;
            }
            
            Boolean foundAndUpdated = findAndUpdateBrandAssignment(assignments, storeAssignment, toUpsert);
            
            // Existing brandAssignment not found, create new
            if(!foundAndUpdated){
                BrandToBrandAssignment__c brandAssignment = createNewBrandToBrandAssignment(storeAssignment);
                toUpsert.put((brandAssignment.Account__c+'_'+brandAssignment.Brand__c), brandAssignment);
                assignments.add(brandAssignment);
            }
        }

        System.debug('BrandToStoreAssignmentTriggerHelper:Creating Brand2Brand assignements: '+toUpsert.values().size());
        upsert toUpsert.values();
    }

    private static Boolean findAndUpdateBrandAssignment(List<BrandToBrandAssignment__c> assignments, BrandToStoreAssignment__c  storeAssignment, Map<String,BrandToBrandAssignment__c> toUpsert){
        for(BrandToBrandAssignment__c brandAssignment : assignments) {
            // Look for main account and brand match
            if(storeAssignment.ParentAccount__c == brandAssignment.Account__c && storeAssignment.Brand__c == brandAssignment.Brand__c) {
                String composedKey = brandAssignment.Account__c+'_'+brandAssignment.Brand__c;
                
                // We already have this pair for upset, fetch and increment
                if(toUpsert.containsKey((composedKey))) {
                    brandAssignment = toUpsert.get(composedKey);
                }

                brandAssignment = updateExistingAssignment(storeAssignment, brandAssignment);
                toUpsert.put(composedKey, brandAssignment);
                return true;
            }
        }
        return false;
    }

    private static BrandToBrandAssignment__c updateExistingAssignment(BrandToStoreAssignment__c storeAssignment, BrandToBrandAssignment__c brandAssignment) {
        brandAssignment.Revenue__c += storeAssignment.Revenue__c != null ? storeAssignment.Revenue__c : 0;
        brandAssignment.RevenueB2B__c += storeAssignment.RevenueB2B__c != null ? storeAssignment.RevenueB2B__c : 0;
        brandAssignment.Revenue_YTD_2_Years__c += storeAssignment.Revenue_2_Years__c != null ? storeAssignment.Revenue_2_Years__c : 0;
        brandAssignment.Unreleased_PO__c += storeAssignment.Unreleased_PO__c != null ? storeAssignment.Unreleased_PO__c : 0;
        brandAssignment.Revenue_Last_Year__c = brandAssignment.Revenue_Last_Year__c != null ? brandAssignment.Revenue_Last_Year__c : 0;
        brandAssignment.Revenue_Last_Year__c += storeAssignment.Revenue_Last_Year__c != null ? storeAssignment.Revenue_Last_Year__c : 0;
        
        return brandAssignment;
    }
    
    private static BrandToBrandAssignment__c createNewBrandToBrandAssignment(BrandToStoreAssignment__c storeAssignment) {
        BrandToBrandAssignment__c brandAssignment = new BrandToBrandAssignment__c(
            Brand__c = storeAssignment.Brand__c,
            Account__c = storeAssignment.ParentAccount__c
        );
        
        brandAssignment.Revenue__c = (storeAssignment.Revenue__c == null)  ? 0 : storeAssignment.Revenue__c;
        brandAssignment.Revenue_YTD_2_Years__c = (storeAssignment.Revenue_2_Years__c) == null  ? 0 : storeAssignment.Revenue_2_Years__c;
        brandAssignment.RevenueB2B__c = (storeAssignment.RevenueB2B__c == null)  ? 0 : storeAssignment.RevenueB2B__c;
        brandAssignment.Unreleased_PO__c = (storeAssignment.Unreleased_PO__c == null)  ? 0 : storeAssignment.Unreleased_PO__c;
        brandAssignment.Revenue_Last_Year__c = (storeAssignment.Revenue_Last_Year__c == null)  ? 0 : storeAssignment.Revenue_Last_Year__c;

        return brandAssignment;
    }

}