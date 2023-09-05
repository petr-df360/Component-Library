@isTest
public class AdvancedSearchControllerTest {


    private static Account createAccount(String name, String benefitId) {
        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.Benefit_Id__c = benefitId;

        insert newAccount;
        return newAccount;
    }

    private static Bank_Accounts__c createNewBankAccount(Id accountid, String currIsoCode, String accountNumber, String bankCode, String iban, String swift) {
        Bank_Accounts__c bankAccount = new Bank_Accounts__c();
        bankAccount.Account__c = accountid;
        bankAccount.CurrencyIsoCode = currIsoCode;
        bankAccount.Bank_Account__c = accountNumber;
        bankAccount.Bank_Code__c = bankCode;
        bankAccount.IBAN__c = iban;
        bankAccount.SWIFT__c = swift;

        insert bankAccount;
        return bankAccount;
    }


    @isTest
    public static void getInitInvoiceTest() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_OK());

        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Document__c' and  DeveloperName = 'Invoice'];

        Account supp = createAccount('supplier', '2');

        Bank_Accounts__c account = createNewBankAccount(supp.Id, 'CZK', '676487986', '300', null, null );

        List<Document__c> docs = new List<Document__c>();

        List<String> statuses= new List<String>{'Not paid','In payment' ,'Sent to accountant','Do not pay','Paid'};
        for(Integer i=0;i<5;i++){
            Document__c doc = new Document__c();
            doc.Name='testDoc'+i;
            doc.Supplier__c=supp.id;
            doc.RecordTypeId=rt[0].Id;
            doc.Paid__c=statuses[i];
            doc.Invoice_nb__c = String.valueOf(1000+i);
            doc.Issue_Date__c = Date.today();
            doc.Payment_Due_Date__c=Date.today().addDays(2);
            doc.Date_VAT__c = Date.today().addDays(-2);
            doc.Total__c = (500+i);
            doc.Invoice_Type__c='Goods';
            doc.Invoice_Type_of_Document__c = 'Invoice';
            doc.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
            doc.Account__c=supp.id;
            doc.Constant_Symbol__c='const';
            doc.CurrencyIsoCode='CZK';
            doc.Subject__c='testDoc';
            doc.Variable_Symbol__c='variable' +i;
            doc.Bank_Account__c = account.Id;
            doc.Approval_Status__c = 'Draft';
            doc.Formal_Check__c = false;
            doc.Final_Approver__c = UserInfo.getUserId();
            docs.add(doc);
        }



        //List<User> runUser = [SELECT Id FROM User WHERE isActive=true AND (Username LIKE 'igor.dolezal@aspire.eu.crm' OR Email = 'petr.vavruska@b-i.com')];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Správce systému'];
        
        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        
        
        List<User> runUser = [SELECT Id FROM User WHERE Email = 'userovich22444@testUser.com'];
        
        List<AdvancedSearchController.InvoiceWrapper> wrapper;

        Test.startTest();

        System.runAs(runUser[0]) {

                insert docs;

                for(Document__c invoice : docs) {
                    invoice.Formal_Check__c = true;
                }
                update docs;

                wrapper = AdvancedSearchController.getInitInvoice();
            }

        Test.stopTest();

        System.assertEquals(1, wrapper.size(), 'Only 1 new invoice with Paid__c == \'Not paid\' should exist!');
    }

    @isTest
    public static void getInvoiceTest() {
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_OK());

        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Document__c' and  DeveloperName = 'Invoice'];

        Account supplier = createAccount('supplier', '4');
        Account adidas = createAccount('Adidas', '2');
        Account nike = createAccount('Nike', '3');

        Bank_Accounts__c accountAdidas = createNewBankAccount(adidas.Id, 'CZK', '676487986', '300', null, null );
        Bank_Accounts__c accountNike = createNewBankAccount(nike.Id, 'CZK', '5498764', '100', null, null );

        List<Document__c> docs = new List<Document__c>();

        for(Integer i=1;i<6;i++){
            Document__c doc = new Document__c();
            doc.Name='testDoc'+i;
            doc.Supplier__c=((i < 4) ? adidas.Id : nike.Id);
            doc.RecordTypeId=rt[0].Id;
            doc.Paid__c='Not paid';
            doc.Invoice_nb__c = String.valueOf(1000+i);
            doc.Issue_Date__c = Date.today();
            doc.Payment_Due_Date__c=Date.today().addDays(2);
            doc.Date_VAT__c = Date.today().addDays(-2);
            doc.Total__c = (500+i);
            doc.Invoice_Type__c='Goods';
            doc.Invoice_Type_of_Document__c = 'Invoice';
            doc.Invoice_Category__c = '310 - Dodavatelé tuzemsko';
            doc.Account__c= supplier.Id;
            doc.Constant_Symbol__c='const';
            doc.CurrencyIsoCode='CZK';
            doc.Subject__c='testDoc';
            doc.Variable_Symbol__c='variable' +i;
            doc.Bank_Account__c = ((i < 4) ? accountAdidas.Id : accountNike.Id);
            doc.Approval_Status__c = 'Draft';
            doc.Formal_Check__c = false;
            doc.Final_Approver__c = UserInfo.getUserId();
            docs.add(doc);
            System.debug(doc);
        }


        List<AdvancedSearchController.InvoiceWrapper> searchInvoices;
        List<String> accountsWithInvoices;
        List<AdvancedSearchController.InvoiceWrapper> invoicesFromFilter;

        //List<User> runUser = [SELECT Id FROM User WHERE isActive=true AND (Username LIKE 'igor.dolezal@aspire.eu.crm' OR Email = 'petr.vavruska@b-i.com')];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Správce systému'];

        User usr = new User(Alias = 'testtik', Email='userovich22444@testUser.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='userovich22444@testUser.com');
        insert usr;
        

        List<User> runUser = [SELECT Id FROM User WHERE Email = 'userovich22444@testUser.com'];

        Test.startTest();

        System.runAs(runUser[0]) {

            insert docs;

            for(Document__c invoice : docs) {
                invoice.Formal_Check__c = true;
            }
            update docs;

            searchInvoices = AdvancedSearchController.getInvoice('1003');
            accountsWithInvoices = AdvancedSearchController.getAccountsWithInvoices();
            invoicesFromFilter = AdvancedSearchController.getInvoicesFromFilterSearch('Not paid', 'Adidas', 'Goods');

        }


        Test.stopTest();

        System.assertEquals(2, accountsWithInvoices.size(), 'There should be exactly two accounts with invoices!');
        System.assertEquals(1, invoicesFromFilter.size(), 'There should be exactly one invoice matching the search criteria1');

    }

    @isTest
    public static void initValuesTest() {

        RecordType customerRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' and  DeveloperName = 'Customer' LIMIT 1];
        Account adidas = new Account();
        adidas.RecordTypeId = customerRT.Id;
        adidas.Name = 'Adidas';
        adidas.Benefit_Id__c = '7';
        insert adidas;

        Account nike = new Account();
        nike.RecordTypeId = customerRT.Id;
        nike.Name = 'Adidas';
        nike.Benefit_Id__c = '9';
        insert nike;

        List<String> paidStatuses = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document__c.Paid__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : ple) {
            paidStatuses.add(entry.getLabel());
        }

        List<String> invoiceTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult2 = Document__c.Invoice_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for(Schema.PicklistEntry entry : ple2) {
            invoiceTypes.add(entry.getLabel());
        }

        Test.startTest();

            List<String> invoicesStates = AdvancedSearchController.getInvoiceStates();
            List<String> invoicesTypesResult = AdvancedSearchController.getInvoiceTypes();
            Map<String, String> accountNames = AdvancedSearchController.getAccontNames('something', 'something', 'something');

        Test.stopTest();

        System.assertEquals(paidStatuses, invoicesStates, 'Paid__c possible statuses are not as expected!');
        System.assertEquals(invoiceTypes, invoicesTypesResult, 'Invoice types are not as expected!');
        System.assertEquals(2, accountNames.size(), 'There should be exactly two accounts with invoices!');

    }

    /*
        The rest of classes in AdvancedSearchController class is tested in BenefitServiceProviderTest class
        together with other tests for posting and paying invoices.

     */

}