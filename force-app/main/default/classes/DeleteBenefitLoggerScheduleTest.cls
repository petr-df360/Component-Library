@isTest
public class DeleteBenefitLoggerScheduleTest {
    
    private static BenefitLogger__c createLog() {
        String statusCode = '400';
        String errorMessage = 'bad request';
        BenefitLogger__c logger = new BenefitLogger__c();
        logger.Method__c = 'BenefitServiceProvider.getBenefitToken()';
        logger.Endpoint__c = 'test endpoint';
        logger.Message__c = 'Status code: ' + statusCode +' - remote call failed: ' + errorMessage;
        return logger;
    }
    
    @testSetup
    public static void setup() {
        List<BenefitLogger__c> logs = new List<BenefitLogger__c>();
        for(integer i = 0; i < 100 ; i++) {
            BenefitLogger__c log = createLog();
            logs.add(log);
        }
        insert logs;
    }
    
    @isTest
    public static void deleteLogsTest() {
        List<BenefitLogger__c> allLogs;
        
        System.Test.startTest();
        	allLogs = [SELECT Id FROM BenefitLogger__c];
        	DeleteBenefitLoggerSchedule dbls = new DeleteBenefitLoggerSchedule();
        	dbls.execute(null);
        
        System.Test.stopTest();
        
        List<BenefitLogger__c> logsAfterDelete = [SELECT Id FROM BenefitLogger__c];
        
        System.assertEquals(100, allLogs.size(), 'There should be exactly 100 BenefitLogger__c objects before delete job!');
        System.assertEquals(0, logsAfterDelete.size(), 'No BenefitLogger__c should exist after delete job!');
        
    }

}