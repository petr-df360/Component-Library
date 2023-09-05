public class PaymentOptionsController {
    @AuraEnabled
    public static List<Payment_method__mdt> fetchPaymentOptions(){
        
        return [SELECT Label FROM Payment_method__mdt];
        
    }
    
    @AuraEnabled
    public static List<Aspire_Bank_Account__mdt> fetchBankAccounts(){
        
        return [SELECT Label FROM Aspire_Bank_Account__mdt];
        
    }

}