public class InvoicingController {
    PRIVATE STATIC FINAL List<String> EMAILS = new List<String>{'alena.malachova@aspire.eu'};//alena.malachova@aspire.eu
        PRIVATE STATIC FINAL List<String> CCs = new List<String>{'igor.dolezal@aspire.eu'};//igor.dolezal@aspire.eu
    
    public static void updatePartnerInvoices(List<BenefitTypes.InvoiceJSON> invoices){

        List<Invoice_Reminder__c> remindersToCreate = new List<Invoice_Reminder__c>();

        Map<String, String> methodToBenefitId = new Map<String, String>();

        //all possible payment methods; PaymentId__c is used in Benefit, Label in Salesforce
        List<Payment_method__mdt> payments =[SELECT Label, PaymentId__c FROM Payment_method__mdt];

        for(Payment_method__mdt payment : payments) {
            methodToBenefitId.put(payment.PaymentId__c, payment.Label);
        }
        
        for(BenefitTypes.InvoiceJSON invoice : invoices) {

            Invoice_Reminder__c reminder = new Invoice_Reminder__c();
            reminder.Benefit_id__c = invoice.ben_partid;
            reminder.CurrencyIsoCode = invoice.curr;
            reminder.Invoice_Number__c = invoice.num;
            reminder.Variable_Symbol__c = invoice.variable;
            if(invoice.date_issue != null) {
                reminder.Invoice_Issue_Date__c = Date.valueOf(invoice.date_issue);
            }
            if(invoice.date_vat != null) {
                reminder.Date_VAT__c = Date.valueOf(invoice.date_vat);
            }
            if(invoice.date_due != null) {
                reminder.Payment_Due_Date__c = Date.valueOf(invoice.date_due);
            }
            if(invoice.date_payed != null) {
                reminder.Payment_Date__c = Date.valueOf(invoice.date_payed);
            }
            reminder.Paid_Amount__c = invoice.amount_payed;
            reminder.Invoice_Amount__c = invoice.ammount;
            reminder.Days_Overdue__c = invoice.days_after;
            reminder.Payment__c = methodToBenefitId.get(invoice.payment);

            remindersToCreate.add(reminder);
        }

        
        System.debug('total batch size: ' +remindersToCreate.size());
        BatchWorkerController projectWorker = new BatchWorkerController();
        List<Invoice_Reminder__c> toBatch = new List<Invoice_Reminder__c>();
        
        for(Invoice_Reminder__c inv : remindersToCreate){
            if(toBatch.size() < 30){
                toBatch.add(inv);
            }else{
                System.debug('toBatch list size: ' +toBatch.size());
                projectWorker.addWork(new BatchWorkerController.upsertInvoiceReminders(toBatch));
                toBatch = new List<Invoice_Reminder__c>();
                toBatch.add(inv);
            }
     
        }
        
        if(toBatch != null && toBatch.size() > 0) {
            System.debug('toBatch list size: ' +toBatch.size());
            projectWorker.addWork(new BatchWorkerController.upsertInvoiceReminders(toBatch));
        }
        
        Id jobId = projectWorker.run().BatchJobId;
        toBatch = new List<Invoice_Reminder__c>();

    }
    
    
    public static void handlePaidInvoices(List<String> invoiceIdentificators,String accName, String accNum) {
        System.debug('invoiceIdentificators paid: ' +invoiceIdentificators);
        if(!invoiceIdentificators.isEmpty()) {
            List<Document__c> invoicesToUpdate = new List<Document__c>();
            
            List<Document__c> invoices= [SELECT Id,Paid__c,Benefit_Invoice_Number__c,CurrencyIsoCode, Benefit_Invoice_Year__c,Total__c FROM Document__c
                                         WHERE Benefit_Invoice_Identificator__c =:invoiceIdentificators
                                        AND Paid__c != 'Canceled'];
            for(Document__c invoice : invoices) {
                invoice.Paid__c = 'Paid';
                invoicesToUpdate.add(invoice);
            }
            
            update invoicesToUpdate;
            try{
                sendEmailSentToPayment(invoicesToUpdate,accName, accNum);}
            catch(Exception e){
                logErrorMessage('Send emailsent to payment', accName, e.getMessage());
            }
            /*
             * 
             * DONT SEND THIS EMAIL - SEND DETAILED INFORMATION INSTEAD
            try{
                Map<String, Object> flowMap = new Map<String, Object>();
                flowMap.put('Document', invoices[0]);

                Flow.Interview.InvoicesSentForPayment myFlow = new Flow.Interview.InvoicesSentForPayment(flowMap);
                myFlow.start();

            }catch(Exception e) {
                logErrorMessage('InvoicesSentForPayment', 'payInvoice()', e.getMessage());
            }*/
            

        }
    }
    
    public static void handleFailedInvoices(List<String> invoiceIdentificators) {
        System.debug('invoiceIdentificators failed: ' +invoiceIdentificators);
        if(!invoiceIdentificators.isEmpty()) {
            List<Document__c> invoicesToUpdate = new List<Document__c>();
            
            List<Document__c> invoices = [SELECT Id,Invoice_nb__c,Paid__c FROM Document__c
                                          WHERE Benefit_Invoice_Identificator__c =:invoiceIdentificators
                                         AND Paid__c != 'Canceled'];
            for(Document__c invoice : invoices) {
                invoice.Paid__c = 'Not paid';
                invoicesToUpdate.add(invoice);
                sendEmail(invoice);
            }
            
            update invoicesToUpdate;
        }
    }
    

    @TestVisible
    private static void logErrorMessage(String flowName, String endpoint, String errorMessage) {
        BenefitLogger__c logger = new BenefitLogger__c();
        logger.Method__c = flowName;
        logger.Endpoint__c = endpoint;
        if(errorMessage.length() > 190) {
            errorMessage = errorMessage.substring(0, 190);
        }
        logger.Message__c =  'Problems with running Flow: ' + flowName + ' -';
        insert logger;
    }
    
    public static void sendEmail(Document__c invoice){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+invoice.Id;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { UserInfo.getUserEmail()};
            message.setSenderDisplayName('Správa Faktur');
        message.subject = 'Placení Faktury Selhalo';
        message.htmlbody = '<p>Placení faktury '+invoice.Invoice_nb__c +' selhalo.</p> <p> Detail faktury naleznete <a href="'+recordUrl+'"> zde</a>.</p>';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    public static void sendEmailSentToPayment(List<Document__c> invoices,String accName, String accNum){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = EMAILS;
        message.ccaddresses = CCs;
        message.setSenderDisplayName('Správa Faktur');
        message.subject = 'Zaslány faktury k zaplaceni';
        
        
        String body = '<p>Dobrý den,<br>informujeme Vás, že do Benefitu právě byla zaslána dávka faktur k zaplacení z bankovního účtu: ';//<p>Tyto  faktury '+invoice.Invoice_nb__c +' selhalo.</p> <p> Detail faktury naleznete <a href="'+recordUrl+'"> zde</a>.</p>';
        body += '<b>'+accName+'</b> ('+accNum+')</p>';
        body += '<div> <h3> Odeslané faktury </h3> <table> <tr> <th style="width:100px;">Číslo faktury</th>  <th style="width:100px;">Měna</th> <th style="width:100px;">Částka</th> </tr>';
        
        String recordUrl;
        Decimal sum = 0;
        for(Document__c i:invoices){
            System.debug('inoice to send '+i);
            recordUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+i.Id;
            body += '<tr>';
            body +='<th style="width:100px;"><a href="'+recordUrl+'">'+i.Benefit_Invoice_Number__c+'</a></th>';
            body +='<th style="width:100px;">'+i.CurrencyIsoCode+'</th>';//+i.CurrencyIsoCode+
            body +='<th style="width:100px; text-align:right;">'+i.Total__c+'</th>';
            body += '</tr>';
            sum+= i.Total__c;
        }
        
        //total
        body += '<tr style="border-top;">';
            body +='<th style="width:100px; border-top: solid;">Celkem</th>';
            body +='<th style="width:100px; border-top: solid;">'+invoices[0].CurrencyIsoCode+'</th>';
            body +='<th style="width:100px; border-top: solid;  text-align:right;">'+sum+'</th>';
            body += '</tr>';
        //end of total
        body+='</table>';
        body+='</div>';
        body+='<p> S pozdravem, <br> Salesforce CRM </p>';
        message.htmlbody=body;
        
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    
}