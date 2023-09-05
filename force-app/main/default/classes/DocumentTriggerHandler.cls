public class DocumentTriggerHandler {


    public static void fillSupplierTextName(List<Document__c> invoices) {
        Set<Id> suppliersIds = new Set<Id>();
        for(Document__c invoice : invoices) {
            suppliersIds.add(invoice.Supplier__c);
        }

        Map<Id, Account> suppliers = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id = : suppliersIds]);

        for (Document__c invoice : invoices) {
            try{
                String supplierTextName = suppliers.get(invoice.Supplier__c).Name;
                if(!String.isBlank(supplierTextName)) {
                    invoice.Supplier_Text_Name__c = supplierTextName;
                }else{
                    invoice.Supplier_Text_Name__c = '';
                }
            }catch (NullPointerException e) {
                invoice.Supplier_Text_Name__c = '';
            }
           
        }

    }
    
    public static void updateDocumentSharing(List<Id> docIds, Id shareId) {
        System.debug('sharingUpdate '+docIds);
        List<Document__c> documents = [SELECT Id,DocumentEditRights__c,DocumentReadRights__c FROM Document__c WHERE Id IN : docIds];
       
        if(docIds == null || docIds.size()==0)
            return;
        
        Map<Id, List<Document__Share>> docToShareMap = new Map<Id, List<Document__Share>>();
        //all sharing - UserOrGroupId - it could be user or group
        List<Document__Share> shares = [SELECT Id, AccessLevel, UserOrGroupId, ParentId FROM Document__Share WHERE ParentId = :docIds];
        for(Document__Share share : shares) {
            if(docToShareMap.get(share.ParentId) == null) {
                docToShareMap.put(share.ParentId, new List<Document__Share>{share});
            }else{
                docToShareMap.get(share.ParentId).add(share);
            }
        }

        System.debug('all shares: ' +shares);
        
		//all existing groups - used to distinguish UserId or GroupIp in UserOrGroupId
        Map<Id,Group> groupsMap = new Map<Id, Group>([SELECT Id FROM Group]);
        
        Set<Id> userOrGroupIds = new Set<Id>();
        for(Document__Share share : shares) {
            userOrGroupIds.add(share.UserOrGroupId);
        }
        
        
        List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = : userOrGroupIds];
        //groups and members(Users) in it - used to add user in a group to sharing
        Map<Id, List<Id>> groupToMembers = new Map<Id, List<Id>>();
        for(GroupMember member : members) {
            if(groupToMembers.get(member.GroupId) == null) {
                groupToMembers.put(member.GroupId, new List<Id>{member.UserOrGroupId});
            }else{
                groupToMembers.get(member.GroupId).add(member.UserOrGroupId);
            }
        }
        
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Sharing_Id__c FROM User]);
        
        //for each document
        //get sharing setting
        //determine if it is use or group
        //add all users and all users in group
         
        for(Document__c doc : documents) {
            Set<Id> editAccess = new Set<Id>();
            Set<Id> readAccess = new Set<Id>();
            
            List<Document__Share> docShares = docToShareMap.get(doc.Id);
            
            List<Id> groupIds = new List<Id>();
            for(Document__Share docShare : docShares) {
                if(groupsMap.containsKey(docShare.UserOrGroupId)) {//it is Group Id
                    if('Read' == docShare.AccessLevel) {
                        readAccess.addAll(groupToMembers.get(docShare.UserOrGroupId));
                    }
                    if('Edit' == docShare.AccessLevel || 'All' == docShare.AccessLevel) {
                        editAccess.addAll(groupToMembers.get(docShare.UserOrGroupId));
                    }
                }else{//it is User Id
                    if('Read' == docShare.AccessLevel) {
                        readAccess.add(docShare.UserOrGroupId);
                    }
                    if('Edit' == docShare.AccessLevel || 'All' == docShare.AccessLevel) {
                        editAccess.add(docShare.UserOrGroupId);
                    }
                }
            }
            
            System.debug('readAccess '+readAccess);
            System.debug('editAcces '+editAccess);
            
            //update write rights list
            String write = '';
            for(Id userId : editAccess) {
                write += usersMap.get(userId).Sharing_Id__c + ',';
            }
            write = write.removeEnd(',');
            //add error when longer than 255 characters!
            doc.DocumentEditRights__c = write;
            
            //update read rights list
            String read = '';
            for(Id userId : readAccess) {
                read += usersMap.get(userId).Sharing_Id__c + ',';
            }
            read = read.removeEnd(',');
            //add error when longer than 255 characters!
            doc.DocumentReadRights__c = read;
            
        }
        
    update documents;
    }
    
    
    //------------------------- for POST INVOICE V1 ----------------------------------------
    /*public static void handleInvoiceInsert(List<Document__c> invoices) {
        
        List<Id> supplierIds = new List<Id>();
        for(Document__c invoice : invoices) {
            supplierIds.add(invoice.Supplier__c);
        }
        
        List<Account> suppliers = [SELECT Id, Benefit_Id__c FROM Account WHERE Id =:supplierIds];
        
        Map<Id, String> suplierToBenId = new Map<Id, String>();
        for(Account a : suppliers) {
            if(suplierToBenId.get(a.Id) == null) {
                suplierToBenId.put(a.Id, a.Benefit_Id__c);
            }
        }
        
        for(Document__c invoice : invoices) {
            BenefitTypes.PostInvoiceJSON invoiceJSON = createInvoiceJson(invoice, suplierToBenId.get(invoice.Supplier__c));
            String body = JSON.serialize(invoiceJSON, true);
            //System.debug('invoice body: ' + body);
            invoiceCallout(body, invoice.Id);        }
        
    }*/
    
	//-------------------------------------POST INVOICE V2-----------------------------------
    public static void handleInvoiceInsert_V2(List<Document__c> invoices) {
        
        List<InvoiceWrapper> validInvoices = checkInvoices(invoices);
        
        //send to Benefit
        for(InvoiceWrapper wrapper : validInvoices) {
            BenefitTypes.PostInvoiceJSON_V2 invoiceJSON = createInvoiceJson_V2(wrapper);
            String body = JSON.serialize(invoiceJSON, true);
            System.debug('invoice body V2: ' + body);
            invoiceCallout_V2(body, wrapper.invoice.Id);
        }

    }

    //----------for POST INVOICE V1 - not used------------------------------------------------------------
    /*private static BenefitTypes.PostInvoiceJSON createInvoiceJson(Document__c invoice, String benefitId) {
        BenefitTypes.PostInvoiceJSON invoiceJson = new BenefitTypes.PostInvoiceJSON();
        invoiceJson.ben_partid = benefitId;
        invoiceJson.supplier_number = invoice.Invoice_nb__c;
        invoiceJson.variable = invoice.Variable_Symbol__c;
        invoiceJson.ammount = invoice.Total__c;
        invoiceJson.curr = invoice.CurrencyIsoCode;
        if(invoice.Payment_Due_Date__c != null) {
            invoiceJson.date_due = String.valueOf(invoice.Payment_Due_Date__c);
        }
        invoiceJson.payment = invoice.Payment_Method__c;
        invoiceJson.comment = invoice.Comment__c;
       
        return invoiceJson;
        
    }*/
    
    //------------------------POST INVOICES V2-------------------------------------------------
    public class InvoiceWrapper {
        public Document__c invoice {get; set;}
        public String benefitId {get; set;}
        public String accountNumber {get; set;}
        public String bankCode {get; set;}
        public String iban {get; set;}
        public String swift {get; set;}
    }


    private static List<InvoiceWrapper> checkInvoices(List<Document__c> invoicesToCheck) {
        
        List<InvoiceWrapper> validInvoices = new List<InvoiceWrapper>();
        
        List<Id> supplierIds = new List<Id>();
        List<Id> bankAccountIds = new List<Id>();
        for(Document__c invoice : invoicesToCheck) {
            supplierIds.add(invoice.Supplier__c);
            bankAccountIds.add(invoice.Bank_Account__c);
        }
        
        //get suppliers for invoices
        List<Account> suppliers = [SELECT Id, Benefit_Id__c FROM Account WHERE Id =:supplierIds];
        
        Map<Id, String> suplierToBenId = new Map<Id, String>();
        for(Account a : suppliers) {
            if(suplierToBenId.get(a.Id) == null) {
                suplierToBenId.put(a.Id, a.Benefit_Id__c);
            }
        }
        
        //get bank accounts for invoices
        List<Bank_Accounts__c> bankAccounts = [SELECT Bank_Account__c, Bank_Code__c, IBAN__c, SWIFT__c FROM Bank_Accounts__c WHERE Id = :bankAccountIds];
        
        Map<Id, String> bankAccountToIban = new Map<Id, String>();
        Map<Id, String> bankAccountToSwift = new Map<Id, String>();
        Map<Id, String> bankAccountToNumber = new Map<Id, String>();
        Map<Id, String> bakAccountToBankCode = new Map<Id, String>();
        for (Bank_Accounts__c bankAccount : bankAccounts) {
            bankAccountToIban.put(bankAccount.Id, bankAccount.IBAN__c);
            bankAccountToSwift.put(bankAccount.Id, bankAccount.SWIFT__c);
            bankAccountToNumber.put(bankAccount.Id, bankAccount.Bank_Account__c);
            bakAccountToBankCode.put(bankAccount.Id, bankAccount.Bank_Code__c);   
        }
        
        for(Document__c invoice : invoicesToCheck) {
            String benefitId = suplierToBenId.get(invoice.Supplier__c);
            if(String.isBlank(benefitId)) {
                invoice.Supplier__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : BenefitId is blank for AccountId: ' +invoice.Supplier__c + ' is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            
            if(String.isBlank(invoice.Invoice_Type_of_Document__c)) {
                invoice.Invoice_Type_of_Document__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Invoice_Type_of_Document__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(invoice.Invoice_Category__c)) {
                invoice.Invoice_Category__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Invoice_Category__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(invoice.Invoice_nb__c)) { 
                invoice.Invoice_nb__c.addError('Invoice number is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(invoice.Variable_Symbol__c)) {
                invoice.Variable_Symbol__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Variable_Symbol__c is blank! Unable to sent invoice to Benefit!');
                continue;                                                  
            }
            if(String.isBlank(String.valueOf(invoice.Total__c))) { 
                invoice.Total__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Total__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(invoice.CurrencyIsoCode)) { 
                invoice.CurrencyIsoCode.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : CurrencyIsoCode is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(String.valueOf(invoice.Issue_Date__c))) { 
                invoice.Issue_Date__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Issue_Date__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(String.valueOf(invoice.Payment_Due_Date__c))) { 
                invoice.Payment_Due_Date__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Payment_Due_Date__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(String.valueOf(invoice.Date_VAT__c))) { 
                invoice.Date_VAT__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Date_VAT__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }
            if(String.isBlank(invoice.Payment_Method__c)) { 
                invoice.Payment_Method__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Payment_Method__c is blank! Unable to sent invoice to Benefit!');
                continue;
            }

            String bankNumber = bankAccountToNumber.get(invoice.Bank_Account__c);
            String bankCode = bakAccountToBankCode.get(invoice.Bank_Account__c);
            String iban = bankAccountToIban.get(invoice.Bank_Account__c);
            String swift = bankAccountToSwift.get(invoice.Bank_Account__c);
            //payments within Czech need only (number + code); abroad payments need only (iban+swift)
            if(invoice.CurrencyIsoCode == 'CZK') {
                if(String.isBlank(bankNumber)) {
                    invoice.Bank_Account__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Bank_Account__c number is blank! Unable to sent invoice to Benefit!');
                    continue;
                }
                if(String.isBlank(bankCode)) {
                    invoice.Bank_Account__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : Bank_Account__c bank code is blank! Unable to sent invoice to Benefit!');
                    continue;
                }
            }else {
                if(String.isBlank(iban)) { 
                    invoice.Bank_Account__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : IBAN is blank! Unable to sent invoice to Benefit!');
                    continue;
                }
                
                if(String.isBlank(swift)) { 
                    invoice.Bank_Account__c.addError('Invoice number: ' +invoice.Invoice_nb__c+ ' : SWIFT is blank! Unable to sent invoice to Benefit!');
                    continue;
                }
            }

            InvoiceWrapper wrapper = new InvoiceWrapper();
            wrapper.invoice = invoice;
            wrapper.benefitId = benefitId;
            if(invoice.CurrencyIsoCode == 'CZK') {
                wrapper.accountNumber = bankNumber;
            	wrapper.bankCode = bankCode;
            }else{
                wrapper.iban = iban;
            	wrapper.swift = swift;
            }
			System.debug('wrapper: ' + wrapper);
            validInvoices.add(wrapper);
        }

        return validInvoices; 
    }
    
    
    
    private static BenefitTypes.PostInvoiceJSON_V2 createInvoiceJson_V2(InvoiceWrapper wrapper) {
        Document__c invoice = wrapper.invoice;
    	String benefitId = wrapper.benefitId;
    	String bankAccount = wrapper.accountNumber;
		String bankCode = wrapper.bankCode;
        String iban = wrapper.iban;
        String swift = wrapper.swift;
        
        BenefitTypes.PostInvoiceJSON_V2 invoiceJson = new BenefitTypes.PostInvoiceJSON_V2();
        invoiceJson.ben_partid = benefitId;
        invoiceJson.supplier_number = invoice.Invoice_nb__c;
        invoiceJson.variable = invoice.Variable_Symbol__c;
        invoiceJson.ammount = invoice.Total__c;
        invoiceJson.curr = invoice.CurrencyIsoCode;
        if(bankAccount != null && bankCode != null) {
            invoiceJson.account_number = bankAccount+'/'+bankCode;
        }   
        if(invoice.Payment_Due_Date__c != null) {
            invoiceJson.date_due = String.valueOf(invoice.Payment_Due_Date__c);
        }
        if(invoice.Date_VAT__c != null) {
            invoiceJson.date_vat = String.valueOf(invoice.Date_VAT__c);
        }
        if(invoice.Issue_Date__c != null) {
            invoiceJson.date_issue = String.valueOf(invoice.Issue_Date__c);
        }
        if(invoice.Date_VAT_Year__c != null) {
            invoiceJson.year = Integer.valueOf(invoice.Date_VAT_Year__c);
        }
        if(invoice.Date_VAT_Month__c != null) {
            invoiceJson.month = Integer.valueOf(invoice.Date_VAT_Month__c);
        }
        if(iban != null) {
            invoiceJson.iban = iban;
        }
        if(swift != null) {
            invoiceJson.swift = swift;
        }
        invoiceJson.payment = invoice.Payment_Method__c;
        invoiceJson.comment = invoice.Comment__c;
        invoiceJson.type = invoice.Invoice_Type_of_Document__c;
        String typeId = invoice.Invoice_Category__c;
        if(typeId != null) {
            invoiceJson.ben_typeid = typeId.substring(0, 3);
        }else{
            invoiceJson.ben_typeid = '';
        }

        return invoiceJson; 
    }
    
    @future(callout=true)
    public static void createSharepointFolder(String docId){
        SharepointController.createFolder(docId);
    }
    
    @future(callout=true)
    public static void ownerChangePermissionSetting(Id oldOwner, Id newOwner, Id documentId){
        //SharepointController.addRoleAssignment(documentId, oldOwner, 'remove');
        SharepointController.addRoleAssignment(documentId, newOwner, 'Edit',true);
    }

    //-------------for POST INVOICE V1 - old now used method--------------------------------
    /*@future(callout=true)
    private static void invoiceCallout(String invoice, Id invoiceId){
        BenefitServiceProvider.postInvoice(invoice, invoiceId);
    }*/
    
    //--------------------POST INVOICES V2---------------------------------------------------
    @future(callout=true)
    private static void invoiceCallout_V2(String invoiceBody, Id invoiceId) {
        BenefitServiceProvider.postInvoiceV2(invoiceBody, invoiceId);
    }

}