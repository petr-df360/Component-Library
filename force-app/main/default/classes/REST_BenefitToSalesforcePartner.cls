@RestResource(urlMapping='/partnerService')
global with sharing class REST_BenefitToSalesforcePartner {
    
    @HttpPost
    global static ResponseObject ProcessPost()
    {
        RestRequest req = RestContext.request;
        ResponseObject res = new ResponseObject();
        
        List<RecordType> customerRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'Customer' OR Name = 'Zákazník'];
        List<RecordType> supplierRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'Supplier' OR Name = 'Dodavatel'];
        
        String method = req.requestURI.substring( req.requestURI.lastIndexOf('/') + 1 ).toLowerCase();
        String body = req.requestBody.toString();
        
        PartnerWrapper partner = parse(body);
        
        Account acc = new Account();
        acc.Name = partner.name;
        
        //IS supplier
        if(partner.supplier != null && partner.supplier == true){
            acc.RecordTypeId = supplierRecordType[0].Id;
        }
        else{
            acc.RecordTypeId = customerRecordType[0].Id;}
        
        acc.Benefit_Id__c = partner.ben_partid;
        acc.Active__c = partner.active ? 'Yes' : 'No';
        acc.Description = partner.comment;
        acc.TaxId__c = partner.org_id;
        acc.Payment_Type__c = partner.payment;
        acc.Credit_Limit__c = partner.creditLimit;
        acc.Insurance__c = partner.insurance;
        acc.Development_Status__c = partner.development_status;
        
        if(partner.region_cycle != null){
            acc.region_cycle__c = partner.region_cycle;
        }
        
        if(partner.maturity != null)
            acc.Payment_Due_Days__c = Decimal.valueOf(partner.maturity);
        
        
        res.is_valid=false;
        
        List<Account> existing = [SELECT Id,Benefit_Id__c FROM Account WHERE Benefit_Id__c =:partner.ben_partid];
        
        if(existing != null && existing.size()>0){
            try{
                upsert acc Account.Benefit_Id__c;
                res.is_valid=true;
                
            }catch(Exception e){
                res.errorCode=e.getTypeName();
                res.message=e.getMessage();
            }
        }
        else{
            try{
                insert acc;
                res.is_valid=true;
                
            }catch(Exception e){
                res.errorCode=e.getTypeName();
                res.message=e.getMessage();
            }
        }
        return res;
    }
    
    public static PartnerWrapper parse(String json) {
        return (PartnerWrapper) System.JSON.deserialize(json, PartnerWrapper.class);
    }
    
    global class ResponseObject{
        public Boolean is_valid;
        public string errorCode;
        public string message;
    }
    
    public class PartnerWrapper {
        
        public String name;
        public String org_id;
        public String maturity;
        public String payment;
        public String comment;
        public Boolean active;
        public String ben_partid;
        public Decimal creditlimit;
        public Boolean insurance;
        public Boolean supplier;
        public String region_cycle;
        public String development_status;
    }
    
    public class AddressWrapper {
        public String name1;
        public String name2;
        public String street;
        public String city;
        public String postcode;
        public String state;
        public String contact;
        public String email;
        public String phone;
        public boolean active;
        public boolean billing;
        public String ben_partid;
        public String ben_padrid;
    }
    
    
    
}