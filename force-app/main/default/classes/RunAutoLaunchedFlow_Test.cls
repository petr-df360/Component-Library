@isTest
public class RunAutoLaunchedFlow_Test {
    static testMethod void testRunAutoLaunchedFlow() {
        //Given
        Test.StartTest();

        //When
        RunAutoLaunchedFlow action = new RunAutoLaunchedFlow();
        String sch = '0 00 * * * ?';
        system.schedule('Test RunAutoLaunchedFlow', sch, action);
        
        //Then
        Test.StopTest();
    }
}