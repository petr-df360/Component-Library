@isTest
public class BrandToStoreAssignmentTriggerTest {
    
    @testSetup
    public static void setup() {
        
        
    }
    
    @isTest
    public static void checkExistingBrandAssignmentsTest() {
        Account parentAccount = createAccount('Parent Account', null, 'TaxId1');
        Account childAccount = createAccount('Child Account', parentAccount.Id, 'TaxId2');
        String meridaName = 'Merida';
        Brand__c meridaBrand = createBrand(meridaName);
        Brand__c trekBrand = createBrand('Trek');
        BrandToStoreAssignment__c meridaAssignment = createNewBrandToStoreAssignmnet(childAccount, meridaBrand, 1000, 3000, 2000);
        BrandToStoreAssignment__c trekAssignment = createNewBrandToStoreAssignmnet(childAccount, trekBrand, null, null, null);
        
        
        List<BrandToStoreAssignment__c> allAssignments;
        List<BrandToStoreAssignment__c> meridas;
        BrandToStoreAssignment__c secondMeridaAssignment;
        String exceptionMessage;
            
        System.Test.startTest();
        	allAssignments = [SELECT Id FROM BrandToStoreAssignment__c WHERE Account__c = :childAccount.Id];
        	meridas = [SELECT Id, Revenue__c, Revenue_2_Years__c, RevenueB2B__c FROM BrandToStoreAssignment__c WHERE Account__c = :childAccount.Id AND Brand__c = :meridaBrand.Id];
        	try{
                secondMeridaAssignment = createNewBrandToStoreAssignmnet(childAccount, meridaBrand, 500, 1000, 500);
            }catch(System.DmlException ex) {
                exceptionMessage = ex.getMessage();
            }
        	
        System.Test.stopTest();
        
        //System.assertEquals(true, exceptionMessage.contains(meridaName), 'Error message should contain name of the duplicate: Merida!');
        
        System.assertEquals(2, allAssignments.size(), 'Two store assignments should exist for child account now!');
        System.assertEquals(1, meridas.size(), 'One Merida BrandToStoreAssignment__c should exist!');
        
        List<BrandToBrandAssignment__c> brandAssignments = [SELECT Id FROM BrandToBrandAssignment__c WHERE Account__c = :parentAccount.Id];
        System.assertEquals(2, brandAssignments.size(), 'BrandToBrandAssignmnet__c should be automatically created whne new BrandToStoreAssignment__c is created!');
        
        
    }
    
    @isTest
    public static void updateBrandToStoreAssignmentTest() {
       	Account parentAccount = createAccount('Parent Account', null, 'TaxId1');
        Account childAccount = createAccount('Child Account', parentAccount.Id, 'TaxId2');
        Account childAccount2 = createAccount('Child Account2', parentAccount.Id, 'TaxId3');
        Account childAccount3 = createAccount('Child Account4', parentAccount.Id, 'TaxId4');
        String meridaName = 'Merida';
        Brand__c meridaBrand = createBrand(meridaName);
        Brand__c trekBrand = createBrand('Trek');
        BrandToStoreAssignment__c meridaAssignment = createNewBrandToStoreAssignmnet(childAccount, meridaBrand, 1000, 3000, 2000);
        BrandToStoreAssignment__c meridaAssignment2 = createNewBrandToStoreAssignmnet(childAccount2, meridaBrand, 333, 666,  555);
        BrandToStoreAssignment__c trekAssignment = createNewBrandToStoreAssignmnet(childAccount, trekBrand, 2000, 6000, 4000);
        
        List<BrandToBrandAssignment__c> brandAssignments = [SELECT Id, Revenue__c, Revenue_YTD_2_Years__c, RevenueB2B__c FROM BrandToBrandAssignment__c WHERE Account__c = :parentAccount.Id AND Brand__c = :meridaBrand.Id];
        System.assertEquals(1333, brandAssignments[0].Revenue__c);
        System.assertEquals(2555, brandAssignments[0].RevenueB2B__c);
        System.assertEquals(3666, brandAssignments[0].Revenue_YTD_2_Years__c);

        
        System.Test.startTest();
        
        BrandToStoreAssignment__c meridaAssignment3 = createNewBrandToStoreAssignmnet(childAccount3, meridaBrand, 100, 300, 200);
        upsert meridaAssignment3;
        
        System.Test.stopTest();
                
        List<BrandToBrandAssignment__c> updated = [SELECT Id, Revenue__c, Revenue_YTD_2_Years__c, RevenueB2B__c FROM BrandToBrandAssignment__c WHERE Account__c = :parentAccount.Id AND Brand__c = :meridaBrand.Id];
        System.assertEquals(1433, updated[0].Revenue__c);
        System.assertEquals(2755, updated[0].RevenueB2B__c);
        System.assertEquals(3966, updated[0].Revenue_YTD_2_Years__c);
    }
    
    @isTest
    public static void deleteBrandToBrandAssignmentTest() {
        Account parentAccount = createAccount('Parent Account', null, 'TaxId1');
        Account childAccount = createAccount('Child Account', parentAccount.Id, 'TaxId2');
        Brand__c meridaBrand = createBrand('Merida');
        Brand__c trekBrand = createBrand('Trek');
        BrandToStoreAssignment__c meridaAssignment = createNewBrandToStoreAssignmnet(childAccount, meridaBrand, 1000, 3000, 2000);
        BrandToStoreAssignment__c trekAssignment = createNewBrandToStoreAssignmnet(childAccount, trekBrand, 100, 300, 200);
        
       
        
        System.Test.startTest();
        
			delete trekAssignment;          
        
        System.Test.stopTest();
        
        List<BrandToBrandAssignment__c> brandAssignments = [SELECT Id, Revenue__c, Revenue_YTD_2_Years__c, RevenueB2B__c,Unreleased_PO__c FROM BrandToBrandAssignment__c WHERE Account__c = :parentAccount.Id AND Brand__c = :meridaBrand.Id];
        System.assertEquals(1000, brandAssignments[0].Revenue__c, 'Revenue__c should be exactly 1000 on BarandToBrandAssighnment after deleting StoreToBrandAssighnment!');
        System.assertEquals(2000, brandAssignments[0].RevenueB2B__c, 'RevenueB2B__c should be exactly 2000 on BarandToBrandAssighnment after deleting StoreToBrandAssighnment!');
        System.assertEquals(3000, brandAssignments[0].Revenue_YTD_2_Years__c, 'Revenue_YTD_2_Years__c should be exactly 3000 on BarandToBrandAssighnment after deleting StoreToBrandAssighnment!');
    }
    
    
    
    
    private static Account createAccount(String name, Id mainAccount, String taxId) {
       	Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.CurrencyIsoCode = 'EUR';
        newAccount.TaxId__c = taxId;
        newAccount.Account__c = mainAccount;
        newAccount.SynchronizeToBenefit__c = false;
            
      	insert newAccount;
        return newAccount;
    }
    
    private static Brand__c createBrand(String name) { 
      	Brand__c newBrand = new Brand__c();
      	newBrand.Name = name;
        
        insert newBrand;
        return newBrand;
    }
    
    private static BrandToStoreAssignment__c createNewBrandToStoreAssignmnet(Account account, Brand__c brand, Decimal revenue, Decimal revenue2Y, Decimal revenueB2B) {
        BrandToStoreAssignment__c assignment = new BrandToStoreAssignment__c();
        assignment.Account__c = account.Id;
        assignment.ParentAccount__c = account.Account__c;
        assignment.Brand__c = brand.Id;
        assignment.Revenue__c = revenue;
        assignment.Revenue_2_Years__c = revenue2Y;
        assignment.RevenueB2B__c = revenueB2B;
        assignment.Unreleased_PO__c = 0;
        
        insert assignment;
        return assignment;
        
    }

}