public class BenefitServiceProvider {
    
    
    private static final Benefit_Setting__mdt BENEFIT_SETTING = [select Password__c, URL__c, Username__c from Benefit_Setting__mdt LIMIT 1];
    
    public static String getBenefitToken() {
        
        String token = '';
        String endpoint = BENEFIT_SETTING.URL__c +'/api/sf/v1/auth/getsecuretoken';
        
        String body = 'grant_type=password'
            + '&username='+ EncodingUtil.urlEncode(BENEFIT_SETTING.Username__c,'UTF-8')
            + '&password=' + EncodingUtil.urlEncode(BENEFIT_SETTING.Password__c, 'UTF-8');
       
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        request.setTimeout(60000);
        
        
        Http http = new Http();
        HTTPResponse response = http.send(request); 
        
        Integer statusCode = response.getStatusCode();
        if(200 == statusCode) {
            BenefitTypes.tokenJSON res = parse(response.getBody());
            token = res.access_token;
        }else{
            String errorMessage = response.getBody();
            System.debug(System.LoggingLevel.ERROR, String.format('BenefitServiceProvider.getBenefitToken(): {0}. {1}', new string[]{response.getStatus(), response.getBody()}));
            logBenefitErrorMessage('BenefitServiceProvider.getBenefitToken()', endpoint, statusCode, errorMessage);
        }
        
        return token;
    }
    
    private static HttpRequest getRequest(String method, String endpoint){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Authorization', 'Bearer '+getBenefitToken());
        request.setTimeout(120000);
        System.debug(System.LoggingLevel.DEBUG, request);
        return request;
    }
    
    public static void getPartnerRevenue(){
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner_statistics/revenue';
        HttpRequest request = getRequest('GET', endpoint);
       
        Http http = new Http();
        HTTPResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        
        if(statusCode == 200){
            System.debug(System.LoggingLevel.INFO, 'Received partner_statistics/revenue with size: ' + response.getBodyAsBlob().size());
            AccountRevenueQueable queueable = new AccountRevenueQueable(response.getBody());
            System.enqueueJob(queueable);
        }else{
            String errorMessage = response.getBody();
            System.debug(System.LoggingLevel.ERROR, errorMessage);
            logBenefitErrorMessage('BenefitServiceProvider.getPartnerRevenue()', endpoint, statusCode, errorMessage);
        }
    }

    
    //@future(callout=true)
    public static void getPartnerBalance() {
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner_statistics/balance';
        HttpRequest request = getRequest('GET', endpoint);
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        
        
        if(statusCode == 200){
            BenefitTypes.PartnerBalanceJSON res = parseBalance(response.getBody());
            AccountBalanceController.updateBalances(res.balances);
            
        }else{
            String errorMessage = response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.getPartnerBalance()', endpoint, statusCode, errorMessage);
        }
    }
    
	//@future(callout=true)
    public static void getPartnerInvoices(Integer daysFrom, Integer daysTo) {

        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner_statistics/invoices?days_from='+daysFrom+'&days_to='+daysTo;
        HttpRequest request = getRequest('GET', endpoint);
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        
        if(statusCode == 200){
            String res = response.getBody();
            //Modify reserved keywords
            res = res.replace('number', 'num');
            res = res.replace('currency', 'curr');
            
            BenefitTypes.PartnerInvoicesJSON invoicesJSON = parseInvoices(res);
            InvoicingController.updatePartnerInvoices(invoicesJSON.invoices);
               
        }else{
            String errorMessage = response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.getPartnerInvoices('+daysFrom+','+ daysTo+')', endpoint, statusCode, errorMessage);
        }
    }
   
   public static void blockB2B(String benefitId){
       String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner/blockB2B';
       HttpRequest request = getRequest('POST', endpoint);
		
       BenefitTypes.blockB2bJSON blockB2B = new BenefitTypes.blockB2bJSON();
       blockB2B.ben_partid = benefitId;

       String body = JSON.serialize(blockB2B, true);
       request.setHeader('Content-Type', 'application/json');
       request.setBody(body);

       Http http = new Http();
       HTTPResponse response = http.send(request);
       Integer statusCode = response.getStatusCode();
       if(statusCode == 200){//200 response
           BenefitTypes.blockB2bResponse blockB2BResponse = parseBlockB2BResponse(response.getBody());
           if(blockB2BResponse.is_valid) {
               //200 response and is_valid
               List<Account> blockedAccounts = [SELECT Id, OwnerId FROM Account WHERE Benefit_Id__c = : benefitId LIMIT 1];
               blockedAccounts[0].Turn_Off_B2B__c = false;
               update blockedAccounts[0];

               try{
                   Map<String, Object> flowMap = new Map<String, Object>();
                   flowMap.put('Account', blockedAccounts[0]);

                   Flow.Interview.BlockB2B_OK myFlow = new Flow.Interview.BlockB2B_OK(flowMap);
                   myFlow.start();

               }catch (Exception e) {
                   logBenefitErrorMessage('BlockB2B_OK','partner/blockB2B', statusCode, 'Problems with running flow BlockB2B_OK.');
               }

               
           }else{//200 response and NOT valid
               String errorMessage = blockB2BResponse.error;
               logBenefitErrorMessage('BenefitServiceProvider.blockB2B('+benefitId+')', endpoint, statusCode, errorMessage);
               List<Account> blockedAccounts = [SELECT Id, OwnerId FROM Account WHERE Benefit_Id__c = : benefitId LIMIT 1];
               blockedAccounts[0].Turn_Off_B2B__c = false;
               update blockedAccounts[0];

               try{
                   Map<String, Object> flowMap = new Map<String, Object>();
                   flowMap.put('Account', blockedAccounts[0]);

                   Flow.Interview.BlockB2B_Fail myFlow = new Flow.Interview.BlockB2B_Fail(flowMap);
                   myFlow.start();

               }catch(Exception e) {
                   logBenefitErrorMessage('BlockB2B_Fail','partner/blockB2B', statusCode, 'Problems with running flow BlockB2B_Fail.');
               }
              
           }
           
       }else{//other than 200 response
           String errorMessage = response.getBody();
           logBenefitErrorMessage('BenefitServiceProvider.blockB2B('+benefitId+')', endpoint, statusCode, errorMessage);
           List<Account> blockedAccounts = [SELECT Id, OwnerId FROM Account WHERE Benefit_Id__c = : benefitId LIMIT 1];
           blockedAccounts[0].Turn_Off_B2B__c = false;
           update blockedAccounts[0];

           try{
               Map<String, Object> flowMap = new Map<String, Object>();
               flowMap.put('Account', blockedAccounts[0]);

               Flow.Interview.BlockB2B_Fail myFlow = new Flow.Interview.BlockB2B_Fail(flowMap);
               myFlow.start();
           }catch (Exception e) {
               logBenefitErrorMessage('BlockB2B_Fail','partner/blockB2B', statusCode, 'Problems with running flow BlockB2B_Fail.');
           }
           
       }
   }
    //---------------------------- PAY INVOICE V2------------------------------------------------------
    
    public static void payInvoiceV2(List<Id> invoiceIds, String paymentMethod, String bankAccount){
        Map<String,Integer> account = new Map<String,Integer>();
        
        
        List<Aspire_Bank_Account__mdt> accounts = [SELECT Ben_accountid__c,Label FROM Aspire_Bank_Account__mdt WHERE Label = :bankAccount];
        if(!accounts.isEmpty()) {
            account.put(accounts[0].Label,Integer.valueOf(accounts[0].Ben_accountid__c));
        }
        
        List<Document__c> invoices = [SELECT Id, Benefit_Invoice_Number__c,CurrencyIsoCode, Benefit_Invoice_Year__c, Paid__c,Total__c FROM Document__c WHERE Id = :invoiceIds];
        
        List<BenefitTypes.InvoicePayJSON_V2> invoicesJSON = new List<BenefitTypes.InvoicePayJSON_V2>();
        
        for(Document__c invoiceToPay : invoices) {
            BenefitTypes.InvoicePayJSON_V2 singleInvoice = new BenefitTypes.InvoicePayJSON_V2();
            singleInvoice.ben_accountid = account.get(bankAccount);
            singleInvoice.payment = paymentMethod;
            singleInvoice.ben_invyear = invoiceToPay.Benefit_Invoice_Year__c;
            singleInvoice.ben_invnumber = invoiceToPay.Benefit_Invoice_Number__c;

            invoicesJSON.add(singleInvoice);
        }

        BenefitTypes.PostInvoicePayJSON_V2 invoicesToPayJSON = new BenefitTypes.PostInvoicePayJSON_V2();
        invoicesToPayJSON.invoices = invoicesJSON;
        String body = JSON.serialize(invoicesToPayJSON, true);
        
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/invoices/pay_invoice';
        HttpRequest request = getRequest('POST', endpoint);
        Http http = new Http();
        
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        
        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('response: ' + response);
        if(200 == statusCode) {//200 response
            
            BenefitTypes.PostInvoicePayResponseJSON invoicesToPayResponse = parsePostInvoicePayResponse(response.getBody());
            System.debug('invoicesToPayResponse: ' + invoicesToPayResponse);
            
            if(invoicesToPayResponse.is_valid) {//200 response and is_valid -> all paied
                
                List<BenefitTypes.InvoicePayResponseJSON> invoiceResponse = invoicesToPayResponse.res_invoices;
                
                List<String> benIdentificator_paidInvoices = new List<String>();
        		List<String> benIdentificator_failedInvoices = new List<String>();
                
                for(BenefitTypes.InvoicePayResponseJSON singleInvoice : invoiceResponse) {
                    if(singleInvoice.is_valid) {
                        System.debug('singleInvoiceOK: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_paidInvoices.add(benInvYear+benInvNumber);
                    // this should never happen - just to be absolutely sure! -> if response is 200 and isValid it means all paied!   
                    }else{//single invoice response is not valid
                        System.debug('singleInvoiceFail: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_failedInvoices.add(benInvYear+benInvNumber);
                    }
    
                }
                
                if(paymentMethod.equals('Cash') || paymentMethod.equals('HOT')){
                        InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices,'HOTOVOST','--');
                }else{
                    InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices,accounts[0].Label,String.valueOf(account.get(accounts[0].Label)));
                }
                
                InvoicingController.handleFailedInvoices(benIdentificator_failedInvoices);
                
            }else{//200 response and NOT valid -> something paid AND something NOT paid
                //invoicesToPayResponse: PostInvoicePayResponseJSON:[error=Při zpracování některých záznamů došlo k chybě. Počet nezpracovaných záznamů: 1., is_valid=false, res_invoices=(InvoicePayResponseJSON:[ben_invnumber=321804135, ben_invyear=2018, error=Neplatné číslo banky - 4006., is_valid=false])]
                
                List<BenefitTypes.InvoicePayResponseJSON> invoiceResponse = invoicesToPayResponse.res_invoices;
                
                List<String> benIdentificator_paidInvoices = new List<String>();
        		List<String> benIdentificator_failedInvoices = new List<String>();
                
                for(BenefitTypes.InvoicePayResponseJSON singleInvoice : invoiceResponse) {
                    if(singleInvoice.is_valid) {//single response is valid
                        //System.debug('singleInvoiceOK: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_paidInvoices.add(benInvYear+benInvNumber);
                        
                    }else{//single invoice response is NOT valid
                        //System.debug('singleInvoiceFail: ' +singleInvoice);
                        String errorMessage = singleInvoice.error;
                        logBenefitErrorMessage('BenefitServiceProvider.payInvoice()', endpoint, statusCode, errorMessage);

                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_failedInvoices.add(benInvYear+benInvNumber);
                    }

                }
                if(paymentMethod.equals('Cash') || paymentMethod.equals('HOT')){
                        InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices,'HOTOVOST','--');
                }else{
                    InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices,accounts[0].Label,String.valueOf(account.get(accounts[0].Label)));
                }

                InvoicingController.handleFailedInvoices(benIdentificator_failedInvoices);
            }
            
        }else{//other than 200 response -> NOTHING paid
            String errorMessage = response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.payInvoice()', endpoint, statusCode, errorMessage);

            List<Document__c> invToUpdate = new List<Document__c>();
            for(Document__c invoice : invoices) {
                invoice.Paid__c = 'Not paid';
                invToUpdate.add(invoice);
            }
            update invToUpdate;
        }
    }
    
    
    //-----------------PAY INVOICE V1 - old not used version---------------------------------------
    /*public static void payInvoice(List<Id> invoiceIds, String paymentMethod, String bankAccount){
        System.debug('invoiceIDS: ' + invoiceIds);
        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('bankAccount: ' + bankAccount);
        
        Integer account;
        
        List<Aspire_Bank_Account__mdt> accounts = [SELECT Ben_accountid__c FROM Aspire_Bank_Account__mdt WHERE Label = :bankAccount];
        if(!accounts.isEmpty()) {
            account = Integer.valueOf(accounts[0].Ben_accountid__c);
        }
        
        List<Document__c> invoices = [SELECT Id, Benefit_Invoice_Number__c, Benefit_Invoice_Year__c, Paid__c FROM Document__c WHERE Id = :invoiceIds];
        
        List<BenefitTypes.InvoicePayJSON> invoicesJSON = new List<BenefitTypes.InvoicePayJSON>();
        
        for(Document__c invoiceToPay : invoices) {
            BenefitTypes.InvoicePayJSON singleInvoice = new BenefitTypes.InvoicePayJSON();
            singleInvoice.ben_accountid = account;
            //payment method not available in V1
            //singleInvoice.paymentMethod = paymentMethod;
            singleInvoice.ben_invyear = invoiceToPay.Benefit_Invoice_Year__c;
            singleInvoice.ben_invnumber = invoiceToPay.Benefit_Invoice_Number__c;
            
            invoicesJSON.add(singleInvoice);
        }

        BenefitTypes.PostInvoicePayJSON invoicesToPayJSON = new BenefitTypes.PostInvoicePayJSON();
        invoicesToPayJSON.invoices = invoicesJSON;
        String body = JSON.serialize(invoicesToPayJSON, true);
        System.debug('body: ' + body);
        
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v1/invoices/pay_invoice';
        HttpRequest request = getRequest('POST', endpoint);
        Http http = new Http();
        
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        
        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('response: ' + response);
        if(200 == statusCode) {//200 response
            
            BenefitTypes.PostInvoicePayResponseJSON invoicesToPayResponse = parsePostInvoicePayResponse(response.getBody());
            System.debug('invoicesToPayResponse: ' + invoicesToPayResponse);
            
            if(invoicesToPayResponse.is_valid) {//200 response and is_valid -> all paied
                
                List<BenefitTypes.InvoicePayResponseJSON> invoiceResponse = invoicesToPayResponse.res_invoices;
                
                List<String> benIdentificator_paidInvoices = new List<String>();
        		List<String> benIdentificator_failedInvoices = new List<String>();
                
                for(BenefitTypes.InvoicePayResponseJSON singleInvoice : invoiceResponse) {
                    if(singleInvoice.is_valid) {
                        System.debug('singleInvoiceOK: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_paidInvoices.add(benInvYear+benInvNumber);
                    // this should never happen - just to be absolutely sure! -> if response is 200 it means all paied!   
                    }else{//single invoice response is not valid
                        System.debug('singleInvoiceFail: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_failedInvoices.add(benInvYear+benInvNumber);
                    }
    
                }
                //System.debug('benIdentificator_paidInvoices: ' + benIdentificator_paidInvoices);
                //System.debug('benIdentificator_failedInvoices: ' + benIdentificator_failedInvoices);
                InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices);
                InvoicingController.handleFailedInvoices(benIdentificator_failedInvoices);
                
            }else{//200 response and NOT valid -> something paid AND something NOT paid
                //invoicesToPayResponse: PostInvoicePayResponseJSON:[error=Při zpracování některých záznamů došlo k chybě. Počet nezpracovaných záznamů: 1., is_valid=false, res_invoices=(InvoicePayResponseJSON:[ben_invnumber=321804135, ben_invyear=2018, error=Neplatné číslo banky - 4006., is_valid=false])]
                
                List<BenefitTypes.InvoicePayResponseJSON> invoiceResponse = invoicesToPayResponse.res_invoices;
                
                List<String> benIdentificator_paidInvoices = new List<String>();
        		List<String> benIdentificator_failedInvoices = new List<String>();
                
                for(BenefitTypes.InvoicePayResponseJSON singleInvoice : invoiceResponse) {
                    if(singleInvoice.is_valid) {//single response is valid
                        //System.debug('singleInvoiceOK: ' +singleInvoice);
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_paidInvoices.add(benInvYear+benInvNumber);
                        
                    }else{//single invoice response is NOT valid
                        //System.debug('singleInvoiceFail: ' +singleInvoice);
                        String errorMessage = singleInvoice.error;
                        logBenefitErrorMessage('BenefitServiceProvider.payInvoice()', endpoint, statusCode, errorMessage);//zmenit na list erroru
                        
                        String benInvNumber = singleInvoice.ben_invnumber;
                        String benInvYear = singleInvoice.ben_invyear;
                        benIdentificator_failedInvoices.add(benInvYear+benInvNumber);
                    }
                    
                    InvoicingController.handlePaidInvoices(benIdentificator_paidInvoices);
                	InvoicingController.handleFailedInvoices(benIdentificator_failedInvoices);
    
                }
            }
            
        }else{//other than 200 response -> NOTHING paied 
            String errorMessage = response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.payInvoice()', endpoint, statusCode, errorMessage); 
            List<Document__c> invToUpdate = new List<Document__c>();
            for(Document__c invoice : invoices) {
                invoice.Paid__c = 'Not paid';
                invToUpdate.add(invoice);
            }
            update invToUpdate;
        }
    
    }*/

	//------------------------------POST INVOICE V2-------------------------------------
    public static void postInvoiceV2(String body, Id invoiceId) {
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/invoices/new_invoice';
        HttpRequest request = getRequest('POST', endpoint);
        Http http = new Http();
        request.setHeader('Content-Type', 'application/json');
        //need to replace because currency is reserved word in apex
        String bodyReplace = body.replace('curr', 'currency');
        request.setBody(bodyReplace);

        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('invoiceV2 response: ' +response);
        System.debug('invoiceV2 response body: ' +response.getBody());

        if(200 == statusCode) {
            BenefitTypes.PostInvoiceResponseJSON res = parsePostInvoiceResponse(response.getBody());
            List<Document__c> invoices = [SELECT Id, Benefit_Invoice_Year__c, Benefit_Invoice_Number__c FROM Document__c WHERE Id = :invoiceId LIMIT 1];
            if(res.is_valid == true) {//200 and is_valid response - save the response to record
                if(!invoices.isEmpty()) {
                    invoices[0].Benefit_Invoice_Year__c = res.ben_invyear;
                    invoices[0].Benefit_Invoice_Number__c = res.ben_invnumber;
                    update invoices[0];

                }
            }else{//200 and NOT is_valid response
                update invoices[0];
                String errorMessage = 'Invoice ID: ' + invoiceId + ' - ' + response.getBody();
                logBenefitErrorMessage('BenefitServiceProvider.postInvoice()', endpoint, statusCode, errorMessage);
            }

        }else{//other than 200 response
            String errorMessage = 'Invoice ID: ' + invoiceId + ' - ' + response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.postInvoice()', endpoint, statusCode, errorMessage);
        }

    }

    
    //-----------POST INVOICE V1 - old not used method---------------------------------------------
    /*public static void postInvoice(String body, Id invoiceId){
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v1/invoices/new_invoice';
        HttpRequest request = getRequest('POST', endpoint);
        Http http = new Http();
        //need to replace beceause currecny is reserved word in apex
        String bodyReplace = body.replace('curr', 'currency');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(bodyReplace);
        System.debug('request body: ' + bodyReplace);
        
        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('invoice response: ' +response);
        System.debug('invoice response body: ' +response.getBody());
        
        if(200 == statusCode) {
            BenefitTypes.PostInvoiceResponseJSON res = parsePostInvoiceResponse(response.getBody());
            
            if(res.is_valid == true) {
                //set the response fields
                List<Document__c> invoices = [SELECT Id, Benefit_Invoice_Year__c, Benefit_Invoice_Number__c FROM Document__c WHERE Id = :invoiceId LIMIT 1];
                if(!invoices.isEmpty()) {
                    invoices[0].Benefit_Invoice_Year__c = res.ben_invyear;
                    invoices[0].Benefit_Invoice_Number__c = res.ben_invnumber;
                    update invoices[0];
                }
                
            }else{
                //Benefit responded as NOT VALID
                String errorMessage = 'Invoice ID: ' + invoiceId + ' - ' + response.getBody();
                logBenefitErrorMessage('BenefitServiceProvider.postInvoice()', endpoint, statusCode, errorMessage); 
            }
            
        }else{
            //got other response code than 200
            String errorMessage = 'Invoice ID: ' + invoiceId + ' - ' + response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.postInvoice()', endpoint, statusCode, errorMessage);
        }
    }*/

     
    //Partner integration 
    public static String postPartner(String body, Id accountId, Boolean isInsert){
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner/partner';
        HttpRequest request = getRequest('POST', endpoint);
        //is request null - token callout failed -- add error handling
        Http http = new Http();
        
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        
        HTTPResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        
        System.debug('BENEFIT (partner): '+statusCode+' '+response.getBody());
        
        if(200 == statusCode) {
            BenefitTypes.PartnerPostJSON res = parsePartner(response.getBody());
            
            if(res.is_valid == true){
                
                    Account acc = [SELECT Id,Name, Name2__c,Active__c, Email__c, Phone, Contact__c, Benefit_Store_Id__c, Development_Status__c, Benefit_Id__c, BillingStreet, BillingCity, BillingCountryCode, BillingPostalCode FROM Account WHERE Id =:accountId];
                    if(acc!= null){
                        System.debug('Updating benefitId: '+acc+' '+res.ben_partid);
                        acc.Benefit_Id__c = res.ben_partid;
                        
                        BenefitTypes.AddressJSON add = getAddress(acc);
                        String bodyAdd = JSON.serialize(add, true);
                        if(acc.BillingCountryCode != null)
                            acc = postAddress(bodyAdd, acc.Id, false);
                        acc.Benefit_Id__c = res.ben_partid;
                        if(isInsert)
                            update acc;
                    }  
            }
            
        }else{
            
            String errorMessage = response.getBody();
            logBenefitErrorMessage('BenefitServiceProvider.postPartner() for Account: ' + accountId + 'IsInsert: ' + isInsert, endpoint, statusCode, errorMessage);
        }
        
        return '';
    }
    
    public static Account postAddress(String body, Id accountId, Boolean isInsert){
        String endpoint = BENEFIT_SETTING.URL__c+'/api/sf/v2/partner/partner_address';
        HttpRequest request = getRequest('POST', endpoint);
        Http http = new Http();
        request.setHeader('Content-Type','application/json');
        request.setBody(body);
        
        HTTPResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('BENEFIT (address): '+statusCode+' '+response.getBody());
        
        if(200 == statusCode) {
            BenefitTypes.AddressPostJSON res = parseAddress(response.getBody());
            
            if(res.is_valid == true){
                Account acc = [SELECT Id,Active__c, Email__c, Phone, Contact__c, Benefit_Id__c, BillingStreet, BillingCity, BillingCountryCode, BillingPostalCode, Main_Contact__c FROM Account WHERE Id =:accountId ];
                if(acc!= null){
                    if(isInsert){
                        acc.Benefit_Store_Id__c = res.ben_padrid;
                        acc.Benefit_Main_Account_Id__c = res.ben_partid; 
                        update acc;
                        return null;
                    }
                    acc.Benefit_Store_Id__c = res.ben_padrid;
                    acc.Benefit_Main_Account_Id__c = res.ben_partid;
                    return acc;
                }
    
            }
            
        }else{
            String errorMessage = response.getBody();
        	logBenefitErrorMessage('BenefitServiceProvider.postAddress() for Account: ' + accountId + 'IsInsert: ' + isInsert, endpoint, statusCode, errorMessage);
        }

        return null;
    }
    
    private static void logBenefitErrorMessage(String method, String endpoint, Integer statusCode, String errorMessage) {
        BenefitLogger__c logger = new BenefitLogger__c();
        logger.Method__c = method;
        logger.Endpoint__c = endpoint;
        if(errorMessage.length() > 190) {
            errorMessage = errorMessage.substring(0, 190);
        }
        logger.Message__c = 'Status code: ' + statusCode +' - remote call failed: ' + errorMessage;
        insert logger;
        
    } 
    
    public static BenefitTypes.tokenJSON parse(String json) {
        return (BenefitTypes.tokenJSON) System.JSON.deserialize(json, BenefitTypes.tokenJSON.class);
    }
    
    public static BenefitTypes.PartnerPostJSON parsePartner(String json) {
        return (BenefitTypes.PartnerPostJSON) System.JSON.deserialize(json, BenefitTypes.PartnerPostJSON.class);
    }
    
    public static BenefitTypes.AddressPostJSON parseAddress(String json) {
        return (BenefitTypes.AddressPostJSON) System.JSON.deserialize(json, BenefitTypes.AddressPostJSON.class);
    }
    
    public static BenefitTypes.PartnerRevenueJSON parseRevenue(String json) {
        return (BenefitTypes.PartnerRevenueJSON) System.JSON.deserialize(json, BenefitTypes.PartnerRevenueJSON.class);
    }
    
    public static BenefitTypes.PartnerBalanceJSON parseBalance(String json) {
        return (BenefitTypes.PartnerBalanceJSON) System.JSON.deserialize(json, BenefitTypes.PartnerBalanceJSON.class);
    }
    
    public static BenefitTypes.PartnerInvoicesJSON parseInvoices(String json) {
        return (BenefitTypes.PartnerInvoicesJSON) System.JSON.deserialize(json, BenefitTypes.PartnerInvoicesJSON.class);
    }
    
    public static BenefitTypes.PostInvoiceResponseJSON parsePostInvoiceResponse(String json) {
        return (BenefitTypes.PostInvoiceResponseJSON) System.JSON.deserialize(json, BenefitTypes.PostInvoiceResponseJSON.class);
    }
    
    public static BenefitTypes.PostInvoicePayResponseJSON parsePostInvoicePayResponse(String json) {
        return (BenefitTypes.PostInvoicePayResponseJSON) System.JSON.deserialize(json, BenefitTypes.PostInvoicePayResponseJSON.class);
    }
   
    public static BenefitTypes.blockB2bResponse parseBlockB2BResponse(String json) {
        return (BenefitTypes.blockB2bResponse)System.JSON.deserialize(json, BenefitTypes.blockB2bResponse.class);
    }
 
    
    private static BenefitTypes.AddressJSON getAddress(Account acc){
        BenefitTypes.AddressJSON address = new BenefitTypes.AddressJSON();
        String n1 = '';
        String n2 = '';
        if(acc.Name.length() > 50){
            n1 = acc.Name.substring(0,50);
            n2 = acc.Name.substring(50);
        }else{
            n1 = acc.Name;
            n2 = '';
        }
        
        address.name1 = n1;
        address.name2 = n2;
        address.street = acc.BillingStreet;
        address.city = acc.BillingCity;
        address.postcode = acc.BillingPostalCode;
        address.state = acc.BillingCountryCode;
        address.ben_partid = acc.Benefit_Id__c;
        
        if(acc.Benefit_Store_Id__c != null){
            address.ben_padrid = Integer.valueOf(acc.Benefit_Store_Id__c);
        }
        
        address.billing = true;
        
        address.contact = acc.Contact__c;
        address.phone = acc.Phone;
        address.email = acc.Email__c;
        
        /* NEED TO ADD FUNCTIONALITY FOR BILLING ADDRESS HERE*/
        
        if(acc.Active__c != null) {
            address.active = acc.Active__c == 'Yes' ? true : false;
        }
        
        if(acc.Benefit_Store_Id__c != null){
            address.ben_padrid = Integer.valueOf(acc.Benefit_Store_Id__c);
        }
        
        return address;
    }

}