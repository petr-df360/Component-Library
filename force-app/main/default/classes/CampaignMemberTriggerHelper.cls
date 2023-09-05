public with sharing class CampaignMemberTriggerHelper {


    public static void runDeleteCampaignMemberFlow(List<CampaignMember> members) {
          for(CampaignMember member : members) {
              Map<String, Object> flowMap = new Map<String, Object>();
              flowMap.put('CampaignMember', member);

              Flow.Interview.Delete_Brand_to_Contact_based_on_Campaign_memeber_deletion myFlow = new Flow.Interview.Delete_Brand_to_Contact_based_on_Campaign_memeber_deletion(flowMap);
              myFlow.start();
          }
    }

}