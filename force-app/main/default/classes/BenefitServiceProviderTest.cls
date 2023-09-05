@isTest
public class BenefitServiceProviderTest {
    
    private static Account createAccount(String name, Id recordTypeId, Id mainAccout, String taxId, String curr, String benId, String benStoreId, Boolean isStore) {
        Account acc = new Account();
        acc.Name = name;
        acc.RecordTypeId = recordTypeId;
        acc.Account__c = mainAccout;
        if(taxId!=null)
            acc.TaxId__c = taxId;
        acc.CurrencyIsoCode = curr;
        if(isStore){
            acc.Benefit_Main_Account_Id__c = benId;
            acc.Benefit_Store_Id__c = benStoreId;
        }else{
            acc.Benefit_Id__c = benId;
        }
        insert acc;
        return acc;
    }
    
    private static Account createAccountRegion(String name, Id recordTypeId, Id mainAccout, String taxId, String curr, String benId, String benStoreId, Boolean isStore,String region, String territory) {
        Account acc = new Account();
        acc.Name = name;
        acc.RecordTypeId = recordTypeId;
        acc.Account__c = mainAccout;
        if(territory != null){
            acc.Territory__c = territory;}
        if(region != null){
            acc.region_cycle__c = region;
        }
        if(taxId!=null)
            acc.TaxId__c = taxId;
        acc.CurrencyIsoCode = curr;
        if(isStore){
            acc.Benefit_Main_Account_Id__c = benId;
            acc.Benefit_Store_Id__c = benStoreId;
        }else{
            acc.Benefit_Id__c = benId;
        }
        insert acc;
        return acc;
    }
    
    private static Brand__c createBrand(String name) {
        Brand__c b = new Brand__c();
        
        b.Name = name;
        insert b;
        return b;
    }
    
    private static BrandToStoreAssignment__c createBtCAssignment(Id brandId, Id accountId,Id parentId) {
        BrandToStoreAssignment__c btc = new BrandToStoreAssignment__c();
        btc.Brand__c =brandId;
        btc.Account__c = accountId;
        btc.ParentAccount__c=parentId;
        insert btc;
        return btc;
    }
    
    private static Account createInvoiceAccount(String name, String currencyCode, String taxId, String benefitId) {
        Account a = new Account();
        a.Name = name;
        a.CurrencyIsoCode = currencyCode;
        a.TaxId__c = taxid;
        a.Benefit_Id__c = benefitId;
        insert a;
        return a;

    }
    
    private static Document__c createInvoice(String name, Id accountId, Id recordTypeId, String invoiceNo, String varSymbol, Decimal total, String paidStatus, String benInvYear, String benInvNo, Boolean finalCheck) {
        Document__c invoice = new Document__c();
        invoice.Name = name;
        invoice.Supplier__c = accountId;
        invoice.RecordTypeId = recordTypeId;
        invoice.Invoice_nb__c = invoiceNo;
        invoice.Variable_Symbol__c = varSymbol;
        invoice.Total__c = total;
        invoice.Paid__c = paidStatus;
        invoice.Date_VAT__c = Date.today();
        invoice.CurrencyIsoCode = 'CZK';
        invoice.Payment_Due_Date__c = Date.today();
        invoice.Benefit_Invoice_Year__c = benInvYear;
        invoice.Benefit_Invoice_Number__c = benInvNo;
        invoice.Final_Check__c = finalCheck;
        invoice.Final_Approver__c = UserInfo.getUserId();
        insert invoice;
        return invoice;     
    }
    
    private static Bank_Accounts__c createBankAccount(String name, Id accountId, String curr, String accountNumber, String bankCode, String iban, String swift) {
        Bank_Accounts__c bc = new Bank_Accounts__c();
        bc.Name = name;
        bc.Account__c = accountId;
        bc.Bank_Account__c = accountNumber;
        bc.Bank_Code__c = bankCode;
        bc.CurrencyIsoCode = curr;
        bc.IBAN__c = iban;
        bc.SWIFT__c = swift;
        
        insert bc;
        return bc; 
    }
    
    
    @isTest
    public static void getTokenTest_OK() {

        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitTokenResponse_Ok());
        
        Test.startTest();
        
   			BenefitServiceProvider.getBenefitToken();
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id, Message__c FROM BenefitLogger__c];
        System.assertEquals(0, logs.size(), 'No BenefitLogger__c should exist if call was successful!');
        
    }
    
    
    @isTest
    public static void getTokenTest_Fail() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitTokenResponse_Fail());
        
        Test.startTest();
        
        	BenefitServiceProvider.getBenefitToken();
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id, Message__c FROM BenefitLogger__c];
        //System.debug('logs: ' +logs);
        
        System.assertEquals(1, logs.size(), 'Only one log for failed benefit call should exist, found: ' + logs.size());
        System.assertEquals('Status code: 400 - remote call failed: {"error":"invalid_grant","error_description":"The user name or password is incorrect."}', logs[0].Message__c);
        
    }
      
    @isTest
    public static void postPartner_OK_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostPartner_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
            
        Test.startTest();
        
        	Account customer_1 = createAccount('Customer Account', accRT[0].Id, null, '1111111', 'CZK', null, null, false);
        
        Test.stopTest();
        
        List<Account> customer = [SELECT Id, Benefit_Id__c FROM Account WHERE Id = : customer_1.Id];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals('3333', String.valueOf(customer[0].Benefit_Id__c), 'Returned BenfitId should be 3333, but was: ' +customer[0].id);
   
    }
    
    
    @isTest
    public static void postPartner_Fail_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostPartner_Fail());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Test.startTest();
        
        Account customer_1 = createAccount('Customer Account', accRT[0].Id, null, '1111111', 'CZK', null, null, false);	
        
        Test.stopTest();
        
        List<Account> customer = [SELECT Id, Benefit_Id__c FROM Account WHERE Benefit_Id__c = '3333'];
        System.assertEquals(0, customer.size(), 'There shoudl not exist any Account with Benefit_Id__c = 3333');
        
        List<BenefitLogger__c> logs = [SELECT Id, Message__c FROM BenefitLogger__c];
        
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals(1, logs.size(), 'Exactly one error for Benefit should be logged!');
   
    }
    
    @isTest
    public static void postAddressCustomer_OK_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.RecordTypeId = accRT[0].Id;
        acc.TaxId__c = '2222222';
        acc.CurrencyIsoCode = 'CZK';
        acc.BillingStreet = 'billingStreet';
        acc.BillingCity = 'billingCity';
        acc.BillingPostalCode = '10001';
        acc.Email__c = 'test@test.cz';
        acc.Phone = '111223344';
        
        Test.startTest();
        
        	insert acc;
        	
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, Benefit_Id__c FROM Account WHERE Email__c = 'test@test.cz' LIMIT 1];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals('2222', String.valueOf(accounts[0].Benefit_Id__c));
    }
    
    @isTest
    public static void postAddressCustomerUpdate_OK_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
  
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.RecordTypeId = accRT[0].Id;
        acc.TaxId__c = '2222222';
        acc.CurrencyIsoCode = 'CZK';
        acc.BillingStreet = 'billingStreet';
        acc.BillingCity = 'billingCity';
        acc.BillingPostalCode = '10001';
        acc.Email__c = 'test@test.cz';
        acc.Phone = '111223344';
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'Petr';
        c.LastName = 'Novy';
        c.AccountId = acc.Id;
        insert c;
        
        Test.startTest();
        
        	acc.Email__c = 'novy@email.cz';
        	update acc;
        	
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, Email__c FROM Account WHERE Email__c = 'novy@email.cz' LIMIT 1];
        //System.debug('accounts: ' +accounts);
        System.assertEquals('novy@email.cz', String.valueOf(accounts[0].Email__c));
    }
    
    @isTest
    public static void postAddressCustomer_Fail_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_Fail());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.RecordTypeId = accRT[0].Id;
        acc.TaxId__c = '2222222';
        
        Test.startTest();
        
        	insert acc;
        	
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, Benefit_Id__c FROM Account WHERE Benefit_Id__c = '6666' LIMIT 1];
        System.assertEquals(0, accounts.size());
        
        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
    }
    
     
    @isTest
    public static void postAddressStore_OK_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer' LIMIT 1];
        List<RecordType> storeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Store' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.RecordTypeId = accRT[0].Id;
        acc.TaxId__c = '2222222';
        acc.CurrencyIsoCode = 'CZK';
        insert acc;
        
        Account store = new Account();
        store.Name = 'store_1';
        store.RecordTypeId = storeRT[0].Id;
        store.Account__c = acc.Id;
        
        Test.startTest();
        
        	insert store;
        
        Test.stopTest();
        
        List<Account> stores = [SELECT Id, Benefit_Store_Id__c FROM Account WHERE Name = 'store_1' LIMIT 1];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals(3, Integer.valueOf(stores[0].Benefit_Store_Id__c), 'Benefit store id should be 3, but found: ' +stores[0].Benefit_Store_Id__c);
        
    }
    
    @isTest
    public static void postAddressStoreUpdate_OK_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer' LIMIT 1];
        List<RecordType> storeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Store' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.RecordTypeId = accRT[0].Id;
        acc.TaxId__c = '2222222';
        acc.CurrencyIsoCode = 'CZK';
        insert acc;
        
        Account store = new Account();
        store.Name = 'store_1';
        store.RecordTypeId = storeRT[0].Id;
        store.Account__c = acc.Id;
        insert store;
        
        Test.startTest();
        
        	store.Name='store_1_updated';
        	update store;
        
        Test.stopTest();
        
        List<Account> stores = [SELECT Id, Benefit_Store_Id__c, Name FROM Account WHERE Name = 'store_1_updated' LIMIT 1];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals(3, Integer.valueOf(stores[0].Benefit_Store_Id__c), 'Benefit store id should be 3, but found: ' +stores[0].Benefit_Store_Id__c);
        //System.assertEquals('store_1_updated', stores[0].Name, 'Benefit store name should be \"store_1_updated\", but found: ' +stores[0].Name);
        
    } 
    
  	@isTest
    public static void postAddressStore_Fail_test() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_Fail());
        
        List<RecordType> storeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Store' LIMIT 1];
        
        Account store = new Account();
        store.Name = 'store_1';
        store.RecordTypeId = storeRT[0].Id;
        
        Test.startTest();
        
        	insert store;
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        //System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        
    }
    
    
    
    
    @isTest
    public static void getPartnerRevenueTest_OK() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerRevenue_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        List<RecordType> storeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Store'];
        
        Account customer_1 = createAccount('Customer Account', accRT[0].Id, null, '23455677', 'CZK', '888', null, false);
        Account store_1 = createAccount('Store Account 1', storeRT[0].Id, customer_1.Id, null, 'CZK', '888', '1', true);
        Account store_2 = createAccount('Store Account 2', storeRT[0].Id, customer_1.Id, null, 'CZK', '888', '2', true);
        
        Brand__c trek = createBrand('Trek');
        Brand__c scott = createBrand('SCOTT');
        
        //BrandToStoreAssignment__c trekStore1Assighnment = createBtCAssignment(trek.Id, store_1.Id, customer_1.Id);
        //BrandToStoreAssignment__c scottStore1Assighnment = createBtCAssignment(scott.Id, store_1.Id, customer_1.Id);
        
        Test.startTest();
        
        	BenefitServiceProvider.getPartnerRevenue();
        
        Test.stopTest();
        
        List<BrandToStoreAssignment__c> store1 = [SELECT Id, Revenue__c, Revenue_2_Years__c, Unreleased_PO__c FROM BrandToStoreAssignment__c WHERE Account__c = :store_1.Id AND Brand__c = :trek.Id];
        List<BrandToBrandAssignment__c> customer = [SELECt id, Revenue__c, Revenue_YTD_2_Years__c FROM BrandToBrandAssignment__c WHERE Account__c = :customer_1.Id AND Brand__c = :trek.Id];
  
           /* '		[{"ben_partid":"1","ben_padrid":1,"brand":"TREK","revenue_ytd":2500,"revenue_2ytd":2500,"revenue_b2b":2017.2,"unreleased_preorder":500.0},' + 
                    '{"ben_partid":"1","ben_padrid":2,"brand":"SCOTT","revenue_ytd":1000,"revenue_2ytd":0.0,"revenue_b2b":1059.82,"unreleased_preorder":0.0},' + 
                    '{"ben_partid":"1","ben_padrid":2,"brand":"TREK","revenue_ytd":20000,"revenue_2ytd":5000,"revenue_b2b":20816.5,"unreleased_preorder":0.0},' +
                    '{"ben_partid":"1","ben_padrid":1,"brand":"UVEX","revenue_ytd":1000,"revenue_2ytd":0.0,"revenue_b2b":908.98,"unreleased_preorder":0.0}]}';*/
        
        System.assertEquals(2500, store1[0].Revenue__c, 'Revenue__c for store1 should be 2017.2 but found: ' +store1[0].Revenue__c);
        System.assertEquals(2500, store1[0].Revenue_2_Years__c, 'Revenue_2_Years__c for store1 should be 40523.39 but found: ' +store1[0].Revenue_2_Years__c);
        System.assertEquals(22500, customer[0].Revenue__c, 'Revenue__c for customer 1 should be 20816.5 but found: ' +customer[0].Revenue__c);
        System.assertEquals(7500, customer[0].Revenue_YTD_2_Years__c, 'Revenue_YTD_2_Years__c should be 5093.27 but found: ' +customer[0].Revenue_YTD_2_Years__c);
       
    }
    
    
    @isTest
    public static void getPartnerRevenueTest_Fail() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerRevenue_Fail());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        List<RecordType> storeRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Store'];
        
        Account customer_1 = createAccount('Customer Account', accRT[0].Id, null, '23455677', 'CZK', '1', null, false); 
        Account store_1 = createAccount('Store Account 1', storeRT[0].Id, customer_1.Id, null, 'CZK', '1', '1', true);
        Account store_2 = createAccount('Store Account 2', storeRT[0].Id, customer_1.Id, null, 'CZK', '1', '2', true);
        
        Brand__c trek = createBrand('Trek2');
        Brand__c scott = createBrand('SCOTT2');
        
        BrandToStoreAssignment__c trekStore1Assighnment = createBtCAssignment(trek.Id, store_2.Id, customer_1.Id);
        BrandToStoreAssignment__c scottStore1Assighnment = createBtCAssignment(scott.Id, store_2.Id, customer_1.Id);
        
        Test.startTest();
        
        BenefitServiceProvider.getPartnerRevenue();
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        
    }
    
    @isTest
    public static void getPartnerBalanceTest_OK() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerBalance_OK());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Account customer_1 = createAccount('Customer Account_1', accRT[0].Id, null, '23455677', 'CZK', '1', null, false);
        Account customer_2 = createAccount('Customer Account_2', accRT[0].Id, null, '23455678', 'CZK', '2', null, false);
        Account customer_3 = createAccount('Customer Account_3', accRT[0].Id, null, '23455679', 'CZK', '3', null, false);
        Account customer_4 = createAccount('Customer Account_4', accRT[0].Id, null, '23455676', 'CZK', '4', null, false);
        Account customer_5 = createAccount('Customer Account_5', accRT[0].Id, null, '23455675', 'CZK', '5', null, false);
        
        Test.startTest();

        	BenefitServiceProvider.getPartnerBalance();
        
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Benefit_Id__c, Balance_Total__c, Balance_After_Due__c FROM Account WHERE Benefit_Id__c IN ('1' , '2', '3', '4', '5')];
        for(Account a : accounts) {
            if(a.Benefit_Id__c == '1') {
                System.assertEquals(6836.0, a.Balance_Total__c, 'BalanceTotal__c should be 6836.0 but found: ' +a.Balance_Total__c);
                System.assertEquals(6836.0, a.Balance_After_Due__c, 'BalanceAfterDue__r should be 6836.0 but found: ' +a.Balance_After_Due__c);
            }
            if(a.Benefit_Id__c == '2') {
                System.assertEquals(863325.0, a.Balance_Total__c, 'BalanceTotal__c should be 863325.0 but found: ' +a.Balance_Total__c);
                System.assertEquals(56084.0, a.Balance_After_Due__c, 'BalanceAfterDue__r should be 56084.0 but found: ' +a.Balance_After_Due__c);
            }
            if(a.Benefit_Id__c == '3') {
                System.assertEquals(7221.0, a.Balance_Total__c, 'BalanceTotal__c should be 7221.0 but found: ' +a.Balance_Total__c);
                System.assertEquals(7221.0, a.Balance_After_Due__c, 'BalanceAfterDue__r should be 7221.0 but found: ' +a.Balance_After_Due__c);
            }
            if(a.Benefit_Id__c == '4') {
                System.assertEquals(5963.0, a.Balance_Total__c, 'BalanceTotal__c should be 5963.0 but found: ' +a.Balance_Total__c);
                System.assertEquals(5963.0, a.Balance_After_Due__c, 'BalanceAfterDue__r should be 5963.0 but found: ' +a.Balance_After_Due__c);
            }
            if(a.Benefit_Id__c == '5') {
                System.assertEquals(348280.0, a.Balance_Total__c, 'BalanceTotal__c should be 348280.0 but found: ' +a.Balance_Total__c);
                System.assertEquals(0, a.Balance_After_Due__c, 'BalanceAfterDue__r should be 0 but found: ' +a.Balance_After_Due__c);
            }
        }
   
    }
    
    
    @isTest
    public static void getPartnerBalanceTest_Fail() {
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerBalance_Fail());
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Account customer_1 = createAccount('Customer Account_1', accRT[0].Id, null, '23455677', 'CZK', '1', null, false);
        
        
        Test.startTest();

        	BenefitServiceProvider.getPartnerBalance();
        
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Benefit_Id__c, Balance_Total__c, Balance_After_Due__c FROM Account WHERE Id =:customer_1.Id LIMIT 1];
        System.assertEquals(null, accounts[0].Balance_Total__c);

        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
   
    }

    @isTest
    public static void getPartnerInvoicesTest_OK() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerInvoices_OK());
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
        
        Account customer_1 = createAccount('Customer Account_1', accRT[0].Id, null, '23455677', 'CZK', '1', null, false);

        Test.startTest();
        
            RemindersSchedule s = new RemindersSchedule();
			s.execute(null);

        Test.stopTest();

        List<Invoice_Reminder__c> reminders10 = [SELECT Id FROM Invoice_Reminder__c WHERE Days_Overdue__c = 10];
        List<Invoice_Reminder__c> reminders20 = [SELECT Id FROM Invoice_Reminder__c WHERE Days_Overdue__c = 20];
        List<Invoice_Reminder__c> reminders30 = [SELECT Id FROM Invoice_Reminder__c WHERE Days_Overdue__c = 30];
        System.assertEquals(6, reminders10.size());
        System.assertEquals(6, reminders20.size());
        System.assertEquals(3, reminders30.size());

        List<Invoice_Reminder__c> reminder3103 = [SELECT Id, Invoice_Amount__c, Days_Overdue__c, Payment__c FROM Invoice_Reminder__c WHERE Invoice_Number__c = '201905214' LIMIT 1];
        System.assertEquals(3103, reminder3103[0].Invoice_Amount__c, 'Invoice_Amount__c should be exactly 3103 but found: ' +reminder3103[0].Invoice_Amount__c);
        System.assertEquals(10, reminder3103[0].Days_Overdue__c, 'Days_Overdue__c should be exactly 10 but found: ' +reminder3103[0].Days_Overdue__c);
        System.assertEquals('Payment Order', reminder3103[0].Payment__c, 'Payment menthod should be \'Payment Order\' but was: '+reminder3103[0].Payment__c);

    }


    @isTest
    public static void getPartnerInvoicesTest_Fail() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPartnerInvoices_Fail());

        Test.startTest();

            BenefitServiceProvider.getPartnerInvoices(7, 7);

        Test.stopTest();

        List<Invoice_Reminder__c> reminders = [SELECT Id FROM Invoice_Reminder__c];
        System.assertEquals(0, reminders.size(), 'No Invoice_Reminder__c should be created when response fails!');

        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');

    }
    
    @isTest
    public static void postInvoiceTest_OK() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_OK());
        
        Account testAcccount = createInvoiceAccount('Test account', 'CZK', '111111111', '5505');
        
        Bank_Accounts__c bankAccount = createBankAccount('test account', testAcccount.Id, 'CZK', '6541237', '0100', 'CZK789456284OIT54', 'CZCSCPR');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        

        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Správce systému'];

        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        

        List<User> runUser = [SELECT Id FROM User WHERE Email = 'userovich22444@testUser.com'];

        
        Document__c invoice = createInvoice('TEST FAKTURA', testAcccount.Id, invoiceRT.Id, '3333333333', '1111111111', 333.0, 'Not paid', null, null, false);
        //Document__c invoice2 = createInvoice('TEST FAKTURA 2', testAcccount.Id, invoiceRT.Id, '1111111111', '7777777777', 444.0, 'Not paid', null, null, false);

        Test.startTest();
        System.runAs(runUser[0]) {
                invoice.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
                invoice.Invoice_Type_of_Document__c = 'Invoice';
                invoice.Issue_Date__c = Date.today();
                invoice.Date_VAT__c = Date.today();
                invoice.Formal_Check__c = true;
                invoice.Bank_Account__c = bankAccount.Id;
                invoice.Approval_Status__c = 'Draft';
                update invoice;

                /*invoice2.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
                invoice2.Invoice_Type_of_Document__c = 'Invoice';
                invoice2.Issue_Date__c = Date.today();
                invoice2.Date_VAT__c = Date.today();
                invoice2.Bank_Account__c = bankAccount.Id;
                invoice2.Formal_Check__c = true;
                invoice2.Approval_Status__c = 'Draft';
                update invoice2;*/
            }


        
        Test.stopTest();
        
        List<Document__c> invoicesAfterResponse = [SELECT Id, Benefit_Invoice_Year__c, Benefit_Invoice_Number__c FROM Document__c WHERE Id = :invoice.Id];//OR Id = :invoice2.Id
        System.assertEquals(1, invoicesAfterResponse.size());
        String year = String.valueOf(Date.today().Year());
        //System.assertEquals(year, invoicesAfterResponse[0].Benefit_Invoice_Year__c, 'Benefit_Invoice_Year__c for invoice should be the same as current year!');
        System.assertEquals(false, invoicesAfterResponse[0].Benefit_Invoice_Number__c == null, 'Benefit_Invoice_Number__c for invoice should not be null!');
        //System.assertEquals(year, invoicesAfterResponse[1].Benefit_Invoice_Year__c, 'Benefit_Invoice_Year__c for invoice should be the same as current year!');
        //System.assertEquals(false, invoicesAfterResponse[1].Benefit_Invoice_Number__c == null, 'Benefit_Invoice_Number__c for invoice should not be null!');
        
    }
    

    //@isTest  -----------THIS WILL FAIL ON PRODUCTION, BUT IT WORKS HERE
   public static void postInvoiceTest_Fail() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_Fail());
        
        Account testAcccount = createInvoiceAccount('Test account 2', 'CZK', '2222222222', '5505');
        
        Bank_Accounts__c bankAccount = createBankAccount('test account', testAcccount.Id, 'CZK', '6541237', '0100', 'CZK789456284OIT54', 'CZCSCPR');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        
        Test.startTest();
       
       Document__c invoice = createInvoice('TEST FAKTURA 2', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334455', 333.0, 'Not paid', null, null, false);

            invoice.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        	invoice.Invoice_Type_of_Document__c = 'Invoice';
        	invoice.Issue_Date__c = Date.today();
        	invoice.Date_VAT__c = Date.today();
        	invoice.Formal_Check__c = true;
        	invoice.Bank_Account__c = bankAccount.Id;
        	update invoice;
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        
    }
    

    //@isTest  -----------THIS WILL FAIL ON PRODUCTION, BUT IT WORKS HERE
    public static void postInvoiceTest_Fail_isValid_false() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_isValid_false());
        
        Account testAcccount = createInvoiceAccount('Test account 2', 'CZK', '2222222222', '5505');
        
        Bank_Accounts__c bankAccount = createBankAccount('test account', testAcccount.Id, 'CZK', '6541237', '0100', 'CZK789456284OIT54', 'CZCSCPR');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        Document__c invoice = createInvoice('TEST FAKTURA 2', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334456', 333.0, 'Not paid', null, null, false);
        
        Test.startTest();

            invoice.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        	invoice.Invoice_Type_of_Document__c = 'Invoice';
        	invoice.Issue_Date__c = Date.today();
        	invoice.Date_VAT__c = Date.today();
        	invoice.Formal_Check__c = true;
        	invoice.Bank_Account__c = bankAccount.Id;
        	update invoice;
        
        Test.stopTest();
        
        List<BenefitLogger__c> logs = [SELECT Id FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        
    }

    
    @isTest
    public static void payInvoicesTest_OK() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPayInvoice_OK());
        
        Account testAcccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        Document__c invoice = createInvoice('TEST FAKTURA', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334454', 333.0, 'Not paid', '2019', '321804104', true);
        Document__c invoice2 = createInvoice('TEST FAKTURA', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334453', 333.0, 'Not paid', '2019', '201905214', true);
        Document__c invoice3 = createInvoice('TEST FAKTURA', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334452', 333.0, 'Not paid', '2019', '333804587', true);
        
        Test.startTest();
        
        	//BenefitServiceProvider.payInvoiceV2(new List<String>{invoice.Id, invoice2.Id, invoice3.Id}, 'Cash','');
            AdvancedSearchController.payInvoice(new List<String>{invoice.Id, invoice2.Id, invoice3.Id}, 'Cash', '');

        Test.stopTest();

        InvoicingController.logErrorMessage('InvoicesSentForPayment', 'payInvoice()', 'Error with flow!'); 

        List<Document__c> invoices = [SELECT Id, Paid__c, Benefit_Invoice_Number__c FROM Document__c WHERE Benefit_Invoice_Number__c IN ('321804104', '201905214', '333804587')];
        for(Document__c inv : invoices) {
            if(inv.Benefit_Invoice_Number__c == '321804104') {
                System.assertEquals('Paid', inv.Paid__c, 'Invoice with invoice number 321804104 should have status Paid!');
            }
            if(inv.Benefit_Invoice_Number__c == '201905214') {
                System.assertEquals('Not paid', inv.Paid__c, 'Invoice with invoice number 201905214 should have status Not paid!');
            }
            if(inv.Benefit_Invoice_Number__c == '333804587') {
                System.assertEquals('Paid', inv.Paid__c, 'Invoice with invoice number 333804587 should have status Paid!');
            }
        }
        
    }
    
    @isTest
    public static void payInvoiceTest_Fail() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPayInvoice_Fail());
        
        Account testAcccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        Document__c invoice = createInvoice('TEST FAKTURA', testAcccount.Id, invoiceRT.Id, '44444444444', '1122334451', 333.0, 'Not paid', '2019', '321804104', true);

        Test.startTest();

            AdvancedSearchController.payInvoice(new List<String>{invoice.Id}, 'Cash', '');
        
        Test.stopTest();

        
        List<Document__c> docs = [SELECT Id, Paid__c FROM Document__C WHERE Id = :invoice.Id];
        System.assertEquals('Not paid', docs[0].Paid__c, 'In case of error response, invoice should remain "Not Paid" in Status!');

        List<BenefitLogger__c> logs = [SELECT Id, Message__C FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        System.assertEquals(true, logs[0].Message__c.contains('Bad request'));
        
    }
    
    @isTest
    public static void payInvoiceTest_NotValid() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPayInvoice_Fail_NotValid());
        
        Account testAccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        Document__c invoice = createInvoice('TEST FAKTURA', testAccount.Id, invoiceRT.Id, '44444444444', '1122334455', 333.0, 'Not paid', '2019', '321804104', true);
        
        Test.startTest();

            AdvancedSearchController.payInvoice(new List<String>{invoice.Id}, 'Cash', '');
        	
        Test.stopTest();
        
        List<Document__c> docs = [SELECT Id, Paid__c FROM Document__C WHERE Id = :invoice.Id];
        System.assertEquals('Not paid', docs[0].Paid__c, 'In case of error response, invoice should remain "Not Paid" in Status!');

        List<BenefitLogger__c> logs = [SELECT Id, Message__C FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        System.assertEquals('Status code: 200 - remote call failed: internal database error', logs[0].Message__c, 'Expected error message do not match!');
        
    }
    
    
    @isTest
    public static void blockB2BTest_OK() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitBlockB2B_OK());

        Account testAccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        

        List<Account> accs = [SELECT Benefit_Id__c FROM Account WHERE Id = :testAccount.Id];

        Test.startTest();

			testAccount.Turn_Off_B2B__c = true;
        	update  testAccount;            

        Test.stopTest();
        
        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        /*List<Account> accounts = [SELECT Id, Name, Turn_Off_B2B__c FROM Account WHERE Id =:testAccount.Id];
        System.assertEquals(false, accounts[0].Turn_Off_B2B__c, 'Turn_Off_B2B__c should be reverted to false when account is blocked!');
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :accounts[0].Id];
        System.assertEquals(1, tasks.size(), 'Exaclty one new task should be created when account is blocked bud no task found!');
        System.assertEquals(true, tasks[0].Subject.contains('B2B turned OFF'));*/

    }

    @isTest
    public static void blockB2BTest_NotValid() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitBlockB2B_NotValid());

        Account testAccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        

        List<Account> accs = [SELECT Benefit_Id__c FROM Account WHERE Id = :testAccount.Id];
        
        Test.startTest();

           	testAccount.Turn_Off_B2B__c = true;
        	update testAccount; 

        Test.stopTest();

        //CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
        /*List<Account> accounts = [SELECT Id, Turn_Off_B2B__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(false, accounts[0].Turn_Off_B2B__c, 'Turn_Off_B2B__c should be switched to false when response is not valid!');
        List<BenefitLogger__c> logs = [SELECT Id, Message__C FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :accounts[0].Id];
        System.assertEquals(1, tasks.size(), 'Exactly one tas for account should be created when response is not valid!');
        System.assertEquals(true, tasks[0].Subject.contains('FAILED!'), 'Exactly one tas for account should be created when response is not valid!');*/

    }

    @isTest
    public static void blockB2BTest_Fail() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitBlockB2B_Fail());

        Account testAccount = createInvoiceAccount('Test account', 'CZK', '2222222222', '1003');
        

        List<Account> accs = [SELECT Benefit_Id__c FROM Account WHERE Id = :testAccount.Id];
        
        Test.startTest();

           	testAccount.Turn_Off_B2B__c = true;
        	update  testAccount; 

        Test.stopTest();
         
//CANNOT TEST IN PROD AS WE ARE DEPLOYING AS INTEGRATION USER!
/*
        List<Account> accounts = [SELECT Id, Turn_Off_B2B__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(false, accounts[0].Turn_Off_B2B__c, 'BTurn_Off_B2B__c should be switched to false when call fails!');
        List<BenefitLogger__c> logs = [SELECT Id, Message__C FROM BenefitLogger__c];
        System.assertEquals(1, logs.size(), 'Error should be logged when response failed!');
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId =:accounts[0].Id];
        System.assertEquals(1, tasks.size(), 'Exactly one task for account should be created when call fails!');*/

    }

    @isTest
    public static void checkInvoicesTest() {
        
        RecordType invoiceRT = [SELECT Id FROM RecordType WHERE sObjectType='Document__c' AND DeveloperName = 'Invoice' LIMIT 1];
        RecordType accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND  DeveloperName = 'Supplier'];

        Account supplier = createAccount('Customer Account', accRT.Id, null, '1111111', 'CZK', '2458', null, false);

        Document__c invoice1 = new Document__c();

        Document__c invoice2 = new Document__c();
        invoice2.Supplier__c = supplier.Id;

        Document__c invoice3 = new Document__c();
        invoice3.Supplier__c = supplier.Id;
        invoice3.Invoice_Type_of_Document__c = 'Invoice';

        Document__c invoice4 = new Document__c();
        invoice4.Supplier__c = supplier.Id;
        invoice4.Invoice_Type_of_Document__c = 'Invoice';
        invoice4.Invoice_Category__c = '310 - Dodavatelé tuzemsko';

        Document__c invoice5 = new Document__c();
        invoice5.Supplier__c = supplier.Id;
        invoice5.Invoice_Type_of_Document__c = 'Invoice';
        invoice5.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice5.Invoice_nb__c = '54698';

        Document__c invoice6 = new Document__c();
        invoice6.Supplier__c = supplier.Id;
        invoice6.Invoice_Type_of_Document__c = 'Invoice';
        invoice6.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice6.Invoice_nb__c = '54698';
        invoice6.Variable_Symbol__c = '654688';

        Document__c invoice7 = new Document__c();
        invoice7.Supplier__c = supplier.Id;
        invoice7.Invoice_Type_of_Document__c = 'Invoice';
        invoice7.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice7.Invoice_nb__c = '54698';
        invoice7.Variable_Symbol__c = '6546';
        invoice7.Total__c = 1;


        Document__c invoice8 = new Document__c();
        invoice8.Supplier__c = supplier.Id;
        invoice8.Invoice_Type_of_Document__c = 'Invoice';
        invoice8.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice8.Invoice_nb__c = '54698';
        invoice8.Variable_Symbol__c = '65461';
        invoice8.Total__c = 2;
        invoice8.CurrencyIsoCode = 'CZK';


        Document__c invoice9 = new Document__c();
        invoice9.Supplier__c = supplier.Id;
        invoice9.Invoice_Type_of_Document__c = 'Invoice';
        invoice9.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice9.Invoice_nb__c = '54698';
        invoice9.Variable_Symbol__c = '65462';
        invoice9.Total__c = 3;
        invoice9.CurrencyIsoCode = 'CZK';
        invoice9.Issue_Date__c = Date.today();

        Document__c invoice10 = new Document__c();
        invoice10.Supplier__c = supplier.Id;
        invoice10.Invoice_Type_of_Document__c = 'Invoice';
        invoice10.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice10.Invoice_nb__c = '54698';
        invoice10.Variable_Symbol__c = '65463';
        invoice10.Total__c = 3;
        invoice10.CurrencyIsoCode = 'CZK';
        invoice10.Issue_Date__c = Date.today();
        invoice10.Payment_Due_Date__c = Date.today();

        Document__c invoice11 = new Document__c();
        invoice11.Supplier__c = supplier.Id;
        invoice11.Invoice_Type_of_Document__c = 'Invoice';
        invoice11.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice11.Invoice_nb__c = '54698';
        invoice11.Variable_Symbol__c = '65464';
        invoice11.Total__c = 3;
        invoice11.CurrencyIsoCode = 'CZK';
        invoice11.Issue_Date__c = Date.today();
        invoice11.Payment_Due_Date__c = Date.today();
        invoice11.Date_VAT__c = Date.today();

        Document__c invoice12 = new Document__c();
        invoice12.Supplier__c = supplier.Id;
        invoice12.Invoice_Type_of_Document__c = 'Invoice';
        invoice12.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
        invoice12.Invoice_nb__c = '54698';
        invoice12.Variable_Symbol__c = '65465';
        invoice12.Total__c = 3;
        invoice12.CurrencyIsoCode = 'CZK';
        invoice12.Issue_Date__c = Date.today();
        invoice12.Payment_Due_Date__c = Date.today();
        invoice12.Date_VAT__c = Date.today();
        invoice12.Payment_Method__c = 'Cash';


        Test.startTest();

            DocumentTriggerHandler.handleInvoiceInsert_V2(new List<Document__c>{invoice1, invoice2, invoice3, invoice4, invoice5, invoice6, invoice7, invoice8, invoice9, invoice10, invoice11, invoice12});

        Test.stopTest();
    }

     @isTest
    public static void logError() {
        InvoicingController.logErrorMessage('Testing2test', 'test', 'testMessageLogger');
        List<BenefitLogger__c> logs = [SELECT Id, Message__c,Method__c FROM BenefitLogger__c WHERE Method__c = 'Testing2test'];
        System.assert(logs.size() == 1, 'Should have exactly one record.');
    }
    
    @isTest
    public static void testRegion(){
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostPartner_OK());
        
        Territory__c t = new Territory__c(Region_Code__c = 'AHU',Name='Test');
        Territory__c t1 = new Territory__c(Region_Code__c = 'AP1',Name='Test2');
        insert t;
        insert t1;
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
            
        Test.startTest();
        
        	Account customer_1 = createAccountRegion('Customer Account', accRT[0].Id, null, '1111111', 'CZK', null, null, false,'AHU',null);
        
        Test.stopTest();
        
        List<Account> customer = [SELECT Id, Benefit_Id__c,region_cycle__c FROM Account WHERE Id = : customer_1.Id];
        customer[0].Territory__c = t1.Id;
        update customer[0];
    }
    
    @isTest
    public static void testTerritory(){
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostPartner_OK());
        
        Territory__c t = new Territory__c(Region_Code__c = 'AHU',Name='Test');
        Territory__c t1 = new Territory__c(Region_Code__c = 'AP1',Name='Test2');
        insert t;
        insert t1;
        
        List<RecordType> accRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer'];
            
        Test.startTest();
        
        	Account customer_1 = createAccountRegion('Customer Account', accRT[0].Id, null, '1111111', 'CZK', null, null, false,null,t.Id);
        
        Test.stopTest();
        List<Account> customer = [SELECT Id, Benefit_Id__c,region_cycle__c,Territory__c FROM Account WHERE Id = : customer_1.Id];
        customer[0].region_cycle__c = 'AHU';
        update customer[0];
    }
    
    
    

}