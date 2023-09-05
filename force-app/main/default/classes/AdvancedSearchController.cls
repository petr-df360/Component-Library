public with sharing class AdvancedSearchController {

    public class InvoiceWrapper{
        @AuraEnabled
        public String account {get;set;}
        @AuraEnabled
        public list<Document__c> invoices {get;set;}
        @AuraEnabled
        public Decimal total_amount {get;set;}
        @AuraEnabled
        public Decimal notPaid_amount {get;set;}
        @AuraEnabled
        public Decimal paid_amount {get;set;}
         @AuraEnabled
        public Decimal onhold_amount {get;set;}
        @AuraEnabled
        public Decimal inPayment_amount {get;set;}
        @AuraEnabled
        public Boolean allPaid {get;set;}
        @AuraEnabled
        public String userCurrency {get {return UserInfo.getDefaultCurrency();} 

        }

        public InvoiceWrapper(String a, Document__c i) {
            this.account = a;
            this.invoices = new list<Document__c>();
            this.invoices.add(i);

            // Set to 0 by default
            this.total_amount = 0;
            this.notPaid_amount = 0;
            this.paid_amount = 0;
            this.onhold_amount = 0;
            this.inPayment_amount = 0;

            // Calculate totals
            if (i.Total__c == null){
                i.Total__c = 0;
            }
            this.total_amount = i.Total__c;

            this.allPaid = true;
            
            if(i.Paid__c == 'Paid') {
                this.paid_amount = i.Total__c;
            } else if(i.Paid__c == 'Not paid') {
                this.notPaid_amount = i.Total__c;
                this.allPaid = false;
            } else if(i.Paid__c == 'In payment') {
                this.inPayment_amount = i.Total__c;
                this.allPaid = false;
            } else if(i.Paid__c == 'Sent to accountant' || i.Paid__c == 'Do not pay') {
                this.onhold_amount = i.Total__c;
                this.allPaid = false;
            } else {
                this.allPaid = false;
            }
        }
        public void addInvoice(Document__c i) {
            if(i.Total__c == null){
                i.Total__c = 0;
            }
            this.invoices.add(i);
            // Calculate totals
            System.debug('## this.total_amount: '+this.total_amount);
            this.total_amount += i.Total__c;
            
            if(i.Paid__c == 'Paid') {
                this.paid_amount += i.Total__c;
            } else if(i.Paid__c == 'Not paid') {
                this.notPaid_amount += i.Total__c;
                this.allPaid = false;
            } else if(i.Paid__c == 'In payment') {
                this.inPayment_amount = i.Total__c;
                this.allPaid = false;
            } else if(i.Paid__c == 'Sent to accountant' || i.Paid__c == 'Do not pay') {
                this.onhold_amount += i.Total__c;
                this.allPaid = false;
            } else {
                this.allPaid = false;
            }
        }

        private void setTotals(Document__c i) {

        }
    }
    
    @AuraEnabled
    public static list<InvoiceWrapper> getInitInvoice() {
        
        List<Document__c> invoices = new List<Document__c>();
     
        invoices = [SELECT id, Paid__c, Approval_Status__c, Invoice_nb__c, Benefit_Invoice_Number__c, Variable_Symbol__c, Issue_Date__c, Payment_Due_Date__c, Name/*Subject__c*/, convertCurrency(Total__c), CurrencyIsoCode, Supplier__c, Supplier__r.Name, Constant_Symbol__c, Invoice_Type__c
        FROM Document__c 
        WHERE RecordType.DeveloperName = 'Invoice' AND (Paid__c  = 'Not paid') AND Formal_Check__c = true
        ORDER BY Supplier__r.Name ASC,Payment_Due_Date__c ASC];

        return wrapInvoices(invoices);
    }

    @AuraEnabled
    public static list<InvoiceWrapper> getInvoice(String searchInput) {
        /*
        Requirement:
        Users should be able to search through invoices based on keywords in the search bar – I believe it would be reasonable to look matches in:
        Invoice no. (sf autonumber ?) => OK
        Subject => OK
        and maybe variable symbol ? => OK

        String searchquery='FIND\'Edge*\'IN ALL FIELDS RETURNING Account(id,name),Contact, Lead';
        */

        //searchInput = searchInput+'*';

/*        if(String.isBlank(paid)) {
            // Push search but will ommit filters
            sosl = 'FIND :searchInput IN ALL FIELDS RETURNING Document__c(Id WHERE RecordType.DeveloperName = \'Invoice\' AND (Paid__c = \'Not paid\' OR Paid__c = \'Sent to accountant\' OR Paid__c = \'Do not pay\'))';
           // sosl = 'FIND :searchInput IN ALL FIELDS RETURNING Document__c(Id WHERE RecordType.DeveloperName = \'Invoice\' )';
        } else {
            // push from apply filter button
            sosl = 'FIND :searchInput IN ALL FIELDS RETURNING Document__c(Id WHERE RecordType.DeveloperName = \'Invoice\''+filters+')';    
        }*/

        String sosl = 'FIND {*'+searchInput+'*} IN ALL FIELDS RETURNING Document__c(Id WHERE RecordType.DeveloperName = \'Invoice\')';
        
        List<List<SObject>> results = search.query(sosl); //[FIND :searchInput IN ALL FIELDS RETURNING Document__c(Id WHERE RecordType.DeveloperName = 'Invoice')];
        List<Document__c> invoices = new List<Document__c>();

        if(!results.isEmpty()) {
            Set<id> ids = new Set<Id>();
            for(Document__c a : (List<Document__c>)results.get(0)) {
                ids.add(a.Id);
            }
            if(!ids.isEmpty()) {
                invoices = [SELECT id, Paid__c, Approval_Status__c, Invoice_nb__c, Benefit_Invoice_Number__c, Variable_Symbol__c, Issue_Date__c, Payment_Due_Date__c, Name/*Subject__c*/, convertCurrency(Total__c), CurrencyIsoCode, Supplier__c, Supplier__r.Name, Constant_Symbol__c, Invoice_Type__c
                           FROM Document__c 
                           WHERE Id =:ids AND Formal_Check__c = true ORDER BY Supplier__r.Name ASC, Payment_Due_Date__c ASC];
            }

            System.debug('## invoices size: '+invoices.size());


/*            List<InvoiceWrapper> invoicesWrapper = new List<InvoiceWrapper>();
            String accountTracker = null;
            for(Document__c i : invoices) {
                String accounName = (i.Supplier__c == null) ? 'Linked to no account':i.Supplier__r.Name;
                if(accountTracker != accounName) {
                    invoicesWrapper.add(new InvoiceWrapper(accounName, i));
                    accountTracker = accounName;
                } else {
                    InvoiceWrapper lastGroup = invoicesWrapper.get(invoicesWrapper.size() - 1);
                    lastGroup.addInvoice(i);
                }   

            }
            System.debug(invoicesWrapper);*/
        }
        return wrapInvoices(invoices);
    }

    @AuraEnabled
    public static List<String> getInvoiceStates() {
        List<String> states = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document__c.Paid__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : ple) {
            states.add(entry.getLabel());
        }
        return states;
    }
    
    
    @AuraEnabled
    public static Map<String, String> getAccontNames(String paid, String account, String type) {
        Map<String, String> names = new Map<String, String>();
        
        List<RecordType> accountRTs = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName IN ('Customer', 'Supplier')];
        Set<Id> ids = new Set<Id>();
        for(RecordType rt : accountRTs) {
            ids.add(rt.Id);
        }
       	List<Account> accounts = [SELECT Id, Name FROM Account WHERE RecordTypeId = :ids ORDER BY Name ASC];
        for(Account acc : accounts) {
            names.put(acc.Id, acc.Name);
        }
        return names;
    }
    
    @AuraEnabled
    public static List<String> getInvoiceTypes() {
        List<String> types = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document__c.Invoice_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : ple) {
            types.add(entry.getLabel());
        }
        
        return types;
    }

    @AuraEnabled
    public static List<String> getInvoiceCurrencies() {
        List<String> invoiceCurrencies = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document__c.CurrencyIsoCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : ple) {
            invoiceCurrencies.add(entry.getValue());
        }
        
        return invoiceCurrencies;
    }

    @AuraEnabled
    public static void payInvoice(list<String> invoiceIds, String paymentOption, String bankAccount) { 
        System.debug('paymentOption: ' +paymentOption);
        System.debug('bankAccount: ' +bankAccount);
        
        if(!invoiceIds.isEmpty()) {
            List<Document__c> invoicesToUpdate = [SELECT id, Paid__c, Invoice_nb__c, Payment_Method__c, Bank_Account__c FROM Document__c WHERE Id =:invoiceIds];
            List<Payment_method__mdt> payMethods = [SELECT PaymentId__c FROM Payment_method__mdt WHERE Label = :paymentOption];
            
            List<Document__c> invoicesToPay = new List<Document__c>();
            
            //check if invoice is already paid and omit already paid invoices
            for(Document__c doc : invoicesToUpdate) {
                if(doc.Paid__c != 'Paid') {
                    invoicesToPay.add(doc);
                }
            }
            
            //set status to 'In payment' and chosen payment method for invoices to pay
            for(Document__c doc: invoicesToPay) {
                doc.Paid__c = 'In payment';
                doc.Payment_Method__c = paymentOption; 
            }
                       
            update invoicesToPay;

            
            List<Id> invoicesToPayIds = new List<Id>();
            for(Document__c invoice : invoicesToPay) {
                invoicesToPayIds.add(invoice.Id);
            }
            
            // Call ERP here
            payInvoiceCallout(invoicesToPayIds,payMethods[0].PaymentId__c, bankAccount);

        }
   
    }
    
    @future(callout=true)
    private static void payInvoiceCallout(List<String> invoiceIds, String paymentMethod, String bankAccount) {
        BenefitServiceProvider.payInvoiceV2(invoiceIds, paymentMethod, bankAccount);
        //BenefitServiceProvider.payInvoice(invoiceIds, paymentMethod, bankAccount);
    }
    
    

    @AuraEnabled
    public static List<String> getAccountsWithInvoices(){

        List<String> accNames = new List<String>();

        for (Account a :[SELECT Name FROM Account WHERE Id IN (SELECT Supplier__c FROM Document__c WHERE Supplier__c <> null)]){
            accNames.add(a.Name);
        }

        return accNames;
    }

    @AuraEnabled
    public static List<InvoiceWrapper> getInvoicesFromFilterSearch(String paid, String account, String type, String invoiceCurrency){

      
        if(paid == Label.Invoice_Paid) {
            paid = 'Paid';
        }else if(paid == Label.Invoice_NotPaid) {
            paid = 'Not paid';
        }else if(paid == Label.Invoice_DoNotPay) {
            paid = 'Do not pay';
        }else if(paid == Label.Invoice_SentToAccountant) {
            paid = 'Sent do accountant';
        }else if(paid == Label.Invoice_InPayment) {
            paid = 'In payment';
        }

        if(type == Label.InvoiceType_Services) {
            type = 'Services';
        }else if(type == Label.InvoiceType_Goods) {
            type = 'Goods';
        }



        String filters = '';
        if(String.isNotBlank(paid) && paid != '_ALL_')
            filters += ' AND Paid__c=\''+paid+'\'';

        if(String.isNotBlank(account))
            filters += ' AND Supplier__r.Name=\''+account+'\'';

        if(String.isNotBlank(type) && type != '_ALL_')
            filters += ' AND Invoice_Type__c=\''+type+'\'';

        if(String.isNotBlank(invoiceCurrency) && invoiceCurrency != '_ALL_')
            filters += ' AND CurrencyIsoCode =\''+invoiceCurrency+'\'';

        System.debug('## paid:'+ paid);
        System.debug('## account:'+account);
        System.debug('## type:'+type);
        System.debug('## currency:'+invoiceCurrency);
        System.debug('## filters: '+filters);
        List<Document__c> invoices = Database.query('SELECT id, Paid__c, Approval_Status__c, Invoice_nb__c, Benefit_Invoice_Number__c,  Variable_Symbol__c, Issue_Date__c, Payment_Due_Date__c, Name, convertCurrency(Total__c), CurrencyIsoCode, Supplier__c, Supplier__r.Name, Constant_Symbol__c, Invoice_Type__c FROM Document__c WHERE RecordType.DeveloperName = \'Invoice\' AND Formal_Check__c = true ' + filters + 'ORDER BY Supplier__r.Name, Payment_Due_Date__c'  );
        System.debug('## invoices: '+invoices);
        return wrapInvoices(invoices);
    }

    private static List<InvoiceWrapper> wrapInvoices(List<Document__c> invoices){

        List<InvoiceWrapper> invoicesWrapper = new List<InvoiceWrapper>();
        String accountTracker = null;
        for(Document__c i : invoices) {
            String accounName = (i.Supplier__c == null) ? 'Linked to no account':i.Supplier__r.Name;
            if(accountTracker != accounName) {
                invoicesWrapper.add(new InvoiceWrapper(accounName, i));
                accountTracker = accounName;
            } else {
                InvoiceWrapper lastGroup = invoicesWrapper.get(invoicesWrapper.size() - 1);
                lastGroup.addInvoice(i);
            }
        }
        System.debug('##: '+invoicesWrapper);
        return invoicesWrapper;
    }
}