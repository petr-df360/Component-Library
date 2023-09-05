@RestResource(urlMapping='/addressService')
global with sharing class REST_BenefitToSalesforceAddress {
    
    @HttpPost
    global static ResponseObject ProcessPost()
    {
        RestRequest req = RestContext.request;
        ResponseObject res = new ResponseObject();
        String method = req.requestURI.substring( req.requestURI.lastIndexOf('/') + 1 ).toLowerCase();
        String body = req.requestBody.toString();//String.valueOf(req.requestBody);
        
        Id storeRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'Store' OR Name LIKE 'Prodejna'][0].Id;
        Id customerRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'Customer' OR Name LIKE 'Zákazník'][0].Id;
        Id supplierRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'Supplier' OR Name = 'Dodavatel'][0].Id;
        
        AddressWrapper store = parse(body);
        System.debug('partner '+store);
        
        res.is_valid=false;
        
        /*Contact c = new Contact();
        if(store.contact != null && store.contact.length() > 0){
            if(store.contact.indexOf(' ') != -1){
                c.FirstName = store.contact.Substring(0,store.contact.indexOf(' '));
                c.LastName = store.contact.Substring(store.contact.indexOf(' '),store.contact.length());}    
            else{
                c.LastName = store.contact;    
            } 
            c.Phone = store.phone;
            c.Email = store.email;
        }*/
        
        if(store.billing){
            //get main account and update address
            List<Account> customers = [SELECT Id, Main_Contact__c FROM Account WHERE Benefit_Id__c =: store.ben_partid]; // AND RecordTypeId =:customerRecordType   
            if(customers != null && customers.size() >0){
                //edit billingAddress and update, if not existing? save address only?
                //customer.Active__c = (customer.active != null && customer.active == true) ? 'Yes' : 'No';
                Account customer = customers[0];
                customer.Benefit_Store_Id__c = store.ben_padrid;                
                customer.BillingCountryCode=store.state;
                customer.BillingCity=store.city;
                customer.BillingStreet=store.street;
                customer.BillingPostalCode=store.postcode;
                
                if(store.email != null && store.email.length() > 0 && validateEmail(store.email))
                    customer.Email__c = store.email;
                
                customer.Phone = store.phone;
                
                if(store.contact != null && store.contact.length() > 0){
                    customer.Contact__c = store.contact;}
                
                //Id contactId = customer.Main_Contact__c != null ? customer.Main_Contact__c : null;
                try{
                    update customer;
                    //handleContact(c,customer.Id,contactId);
                    res.is_valid=true;
                }
                catch(Exception e){
                    res.errorCode=e.getTypeName();
                    res.message=e.getMessage();
                    res.is_valid=false;
                }
            }else{
                res.errorCode='NO EXISTING PARTNER';
                res.is_valid=false;
                res.message='No existing partners were found.';
            }
            return res;
        }
        //else - create new store account
        List<Account> existing = [SELECT Id,Benefit_Main_Account_Id__c, Benefit_Store_Id__c,Main_Contact__c FROM Account
                                  WHERE RecordTypeId =:storeRecordType AND Benefit_Main_Account_Id__c=:store.ben_partid AND Benefit_Store_Id__c =:store.ben_padrid];
        Account acc;
        Boolean exists = (existing!= null && existing.size()>0);
        if(exists){
            acc = existing[0];
        }else{
            acc = new Account();
        }
        
        acc.Name = store.name1;// +' '+ store.name2;
        if(store.name2 != null && store.name2.length() >0)
            acc.Name2__c = store.name2;
        acc.RecordTypeId = storeRecordType;
        acc.Benefit_Store_Id__c = store.ben_padrid;
        acc.Benefit_Main_Account_Id__c = store.ben_partid;
        acc.Active__c = (store.active != null && store.active == true) ? 'Yes' : 'No';
        
        acc.BillingCountryCode = store.state;
        acc.BillingCity = store.city;
        acc.BillingPostalCode = store.postcode;
        acc.BillingStreet = store.street;
        
        if(store.email != null && store.email.length() > 0 && validateEmail(store.email))
            acc.Email__c = store.email;
        acc.Phone = store.phone;
        
        if(store.contact != null && store.contact.length() > 0){
            acc.Contact__c = store.contact;}
        
        List<Account> mainAcc= [SELECT Id FROM Account WHERE Benefit_Id__c =:store.ben_partid];
        if(mainAcc!= null && mainAcc.size()>0){
            acc.Account__c = mainAcc[0].Id;
        }
        
        if(exists){
            try{
                //Id contactId = acc.Main_Contact__c != null ? acc.Main_Contact__c : null;
                upsert acc;
                //handleContact(c,acc.Id, contactId);
                res.is_valid=true;
                
            }catch(Exception e){
                res.errorCode=e.getTypeName();
                res.message=e.getMessage();
                return res;
            }
        }else{
            try{
                insert acc;
                //handleContact(c,acc.Id, null);
                res.is_valid=true;
                
            }catch(Exception e){
                res.errorCode=e.getTypeName();
                res.message=e.getMessage();
                return res;
            } 
        }
        
        
        
        return res;
        
    }
    
    /*
    public static void handleContact(Contact c, Id acc, Id contactId){
        List<Account> accs = [SELECT Id,Main_Contact__c FROM Account WHERE Id=:acc];
        
        if(c == null || (c.Name == null && c.Email == null && c.Phone == null)){
            accs[0].Main_Contact__c = null;
            update accs[0];
            return;
        }
        
        if(c!=null && c.Email != null){
            List<Contact> existing = [SELECT Id,FirstName, LastName,Email,Phone FROM Contact WHERE Email = :c.Email];
            if(existing != null && existing.size()>0){
                Contact con = existing[0];
                if(c.FirstName != null)
                    con.FirstName = c.FirstName;
                if(c.LastName != null)
                    con.LastName = c.LastName;
                if(c.Phone != null)
                    con.Phone = c.Phone;
                con.AccountId = accs[0].Id;
                
                if(con.LastName != null && con.LastName.length()>0){
                    update con;
                    
                    accs[0].Main_Contact__c = con.Id;
                    update accs[0];}
            }else{
                c.AccountId = accs[0].Id;
                if(c.LastName != null && c.LastName.length()>0){
                    insert c;
                    accs[0].Main_Contact__c = c.Id;
                    update accs[0];}
            }
        }
    }    */
    
    public static AddressWrapper parse(String json) {
        return (AddressWrapper) System.JSON.deserialize(json, AddressWrapper.class);
    }
    
    public static Boolean validateEmail(String email) {
    Boolean res = true;
        
    
    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
    Pattern MyPattern = Pattern.compile(emailRegex);
    Matcher MyMatcher = MyPattern.matcher(email);

    if (!MyMatcher.matches()) 
        res = false;
    return res; 
    }
    
    global class ResponseObject{
        public Boolean is_valid;
        public string errorCode;
        public string message;
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
        public Boolean active;
        public String ben_partid;
        public String ben_padrid;
        public Boolean billing;
    }
    
    
    
}