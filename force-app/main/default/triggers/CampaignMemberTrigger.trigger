trigger CampaignMemberTrigger on CampaignMember (before delete) {

    if(Trigger.isBefore ) {

        if(Trigger.isDelete) {

            /*Set<Id> ids = Trigger.oldMap.keySet();
            List<CampaignMember> members = [SELECT Id, Delete__c FROM CampaignMember WHERE Id = :ids];

            List<CampaignMember> membersToUpdate = new List<CampaignMember>();
            for(CampaignMember member : members) {
                member.Delete__c = true;
                membersToUpdate.add(member);
            }
            System.debug('campaign members to update: '+membersToUpdate);
            update membersToUpdate;*/

            
            CampaignMemberTriggerHelper.runDeleteCampaignMemberFlow(Trigger.old);
        }


    }

}