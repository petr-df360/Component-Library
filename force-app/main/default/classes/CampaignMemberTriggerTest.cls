@isTest
public class CampaignMemberTriggerTest {

    @isTest
    public static void deleteCampaingMemberTest() {

        Campaign campaign = new Campaign();
        campaign.Name = 'TestCampaign';
        insert campaign;

        Lead l = new Lead(LastName='Smith', Company='Test company');
        insert l;
        
        CampaignMember member = new CampaignMember (CampaignId= campaign.id, LeadId=l.id);
        insert member;


        Test.startTest();

            delete  member;

        Test.stopTest();

    }
}