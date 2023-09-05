trigger BrandToStoreAssignmentTrigger on BrandToStoreAssignment__c (before insert, after insert, before update, after update) {
    
    
    if(Trigger.isInsert && Trigger.isBefore) {
        /*List<BrandToStoreAssignment__c> brandAssignments = new List<BrandToStoreAssignment__c>();
        for(BrandToStoreAssignment__c assignment : Trigger.New) {
            brandAssignments.add(assignment);
        }
       BrandToStoreAssignmentTriggerHelper.checkExistingBrandAssignments(brandAssignments);
       BrandToStoreAssignmentTriggerHelper.fillParentAccount(brandAssignments);
       BrandToStoreAssignmentTriggerHelper.setRevenueToZeroIfNull(brandAssignments);*/
        //BrandToStoreAssignmentTriggerHelper.checkExistingBrandAssignments(Trigger.New);
        //BrandToStoreAssignmentTriggerHelper.fillParentAccount(Trigger.New);
        //BrandToStoreAssignmentTriggerHelper.setRevenueToZeroIfNull(Trigger.New);        
    }
    
    
    if(Trigger.isInsert && Trigger.isAfter) {
        /*List<BrandToStoreAssignment__c> assignments = new List<BrandToStoreAssignment__c>();
        for(BrandToStoreAssignment__c assignment : Trigger.New) {
            assignments.add(assignment);
        }
        BrandToStoreAssignmentTriggerHelper.addRevenueToCustomerAssignment(assignments);*/
        BrandToStoreAssignmentTriggerHelper.addRevenueToCustomerAssignment(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
        /*List<BrandToStoreAssignment__c> assignments = new List<BrandToStoreAssignment__c>();
        for(BrandToStoreAssignment__c assignment : Trigger.New) {
            assignments.add(assignment);
        }
        BrandToStoreAssignmentTriggerHelper.setRevenueToZeroIfNull(assignments);*/
        //BrandToStoreAssignmentTriggerHelper.setRevenueToZeroIfNull(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        System.debug('afterUpdate');
       	/*Map<BrandToStoreAssignment__c, BrandToStoreAssignment__c> assignmentsMap = new Map<BrandToStoreAssignment__c, BrandToStoreAssignment__c>();
        for(BrandToStoreAssignment__c assignment : Trigger.New) {
            assignmentsMap.put(assignment, Trigger.oldMap.get(assignment.Id));
        }*/
        //BrandToStoreAssignmentTriggerHelper.addRevenueToCustomerAssignment(Trigger.New);
    }
    
    
}