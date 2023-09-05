public class AccountTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public AccountTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void onAfterInsert(Account[] accs, Set<Id> customerIds){
        Map<Id, Account> mainAccounts = new Map<Id, Account>([SELECT Id, Benefit_Id__c FROM Account WHERE Id IN :customerIds]);
        
        for(Account acc :accs){
            if(acc.RecordType_Name__c =='Store')
            {
                BenefitTypes.AddressJSON address = getAddress(acc, mainAccounts);
                Boolean doUpdate = acc.Benefit_Store_Id__c == null;
                addressCallout(JSON.serialize(address, true), acc.Id, doUpdate);
            }
            else{
                BenefitTypes.PartnerJSON partner = getPartner(acc);
                Boolean doUpdate = acc.Benefit_Id__c == null;
                partnerCallout(JSON.serialize(partner, true), acc.Id, doUpdate);   
            }
        }
        
        
    }
    
    public void onAfterUpdate(Account[] accs, Set<Id> customerIds){
        Map<Id, Account> mainAccounts = new Map<Id, Account>([SELECT Id, Benefit_Id__c FROM Account WHERE Id IN :customerIds]);
        
        for(Account acc :accs){
            if(acc.RecordType_Name__c =='Store')
            {
                BenefitTypes.AddressJSON address = getAddress(acc, mainAccounts);
                Boolean doUpdate = acc.Benefit_Store_Id__c == null;
                if(!System.isFuture()){
                    addressCallout(JSON.serialize(address, true), acc.Id, doUpdate);
                }
            }
            else{
                BenefitTypes.PartnerJSON partner = getPartner(acc);
                //BenefitTypes.AddressJSON address = getAddress(acc, mainAccounts);
                //String addressBody = JSON.serialize(address, true);
                Boolean doUpdate = acc.Benefit_Id__c == null;
                if(!System.isFuture()){
                    partnerCallout(JSON.serialize(partner, true), acc.Id, doUpdate);
                    //addressCallout(addressBody, acc.Id, doUpdate);
                }
                
            }
        }   
    }

    public void blockB2BAccounts(List<Account> accountsToBlock) {
        for (Account a : accountsToBlock) {
            blockB2BCallout(a.Benefit_Id__c);
        }
    }

    @future(callout=true)
    public static void blockB2BCallout(String accountToBlockBenId) {
        BenefitServiceProvider.blockB2B(accountToBlockBenId);
    }
    
    @future(callout=true)
    private static void partnerCallout(String partner, Id accId, Boolean isInsert){
        BenefitServiceProvider.postPartner(partner,accId, isInsert);
    }
    
    @future(callout=true)
    private static void addressCallout(String address, Id accId, Boolean isInsert){
        BenefitServiceProvider.postAddress(address,accId, isInsert);
    }
    
    
    private BenefitTypes.PartnerJSON getPartner(Account acc){
        BenefitTypes.PartnerJSON partner = new BenefitTypes.PartnerJSON();
        partner.name =	(acc.Name.length() > 30) ? acc.Name.substring(0,30) : acc.Name;
        partner.org_id = acc.TaxId__c;
        partner.maturity = acc.Payment_Due_Days__c;
        partner.payment = acc.Payment_Type__c;
        partner.comment = acc.Description;
        partner.creditlimit = acc.Credit_Limit__c;
        partner.ben_partid = acc.Benefit_Id__c;
        partner.development_status = acc.Development_Status__c;
        partner.supplier = (acc.RecordType_Name__c =='Supplier' || acc.RecordType_Name__c =='Media' ||acc.RecordType_Name__c =='Brand');
        
        if(acc.region_cycle__c != null){
            partner.region_cycle = acc.region_cycle__c;
        }else{
            partner.region_cycle = null;
        }
        
        if(acc.Insurance__c!=null){
            partner.insurance = acc.Insurance__c;
        }
        
        if(acc.Active__c!=null){
            partner.active = acc.Active__c == 'Yes' ? true : false;
        }
            
        return partner;
    }
    
    private BenefitTypes.AddressJSON getAddress(Account acc,Map<Id,Account> mainAccounts){//, Map<Id, Contact> mainContacts
        BenefitTypes.AddressJSON address = new BenefitTypes.AddressJSON();
        address.name1 = acc.Name;
        if(acc.Name2__c != null){
            address.name2 = acc.Name2__c;
        }
        address.street = acc.BillingStreet;
        address.city = acc.BillingCity;
        address.postcode = acc.BillingPostalCode;
        address.state = acc.BillingCountryCode;
        
        address.email = acc.Email__c;
        address.phone = acc.Phone;
        address.contact = acc.Contact__c;
        
        if(acc.RecordType_Name__c == 'Store'){
            address.billing = false;
        }else{
            address.billing = true;
            if(acc.Benefit_Id__c != null) {
                address.ben_partid = acc.Benefit_Id__c;
            }
            if(acc.Benefit_Store_Id__c != null) {
                address.ben_padrid = Integer.valueOf(acc.Benefit_Store_Id__c);
            }
        }
        
        
        if(acc.Benefit_Main_Account_Id__c != null && acc.Benefit_Main_Account_Id__c.length() > 0){
            address.ben_partid = acc.Benefit_Main_Account_Id__c;}
        else{
            if(mainAccounts.containsKey(acc.Account__c)){
                address.ben_partid = mainAccounts.get(acc.Account__c).Benefit_Id__c;
            }
        }
        
        /* NEED TO ADD FUNCTIONALITY FOR BILLING ADDRESS HERE*/
        if(acc.Active__c!=null) {
            address.active = acc.Active__c == 'Yes' ? true : false;
        }
            
        
        if(acc.Benefit_Store_Id__c!=null){
            address.ben_padrid = Integer.valueOf(acc.Benefit_Store_Id__c);
        }
        return address;
    }
    
    public static Boolean syncedFieldsChanged(Account a, Account old){
        List<String> syncedFields = new List<String>{'Name','Phone','Contact__c','Email__c', 'Development_Status__c', 'TaxId__c','Name2__c','Payment_Type__c','Payment_Due_Days__c','BillingStreet','BillingCity','BillingPostalCode','BillingCountryCode','Description','Credit_Limit__c','Insurance__c','Active__c','Territory__c'};//,'Territory__c','region_cycle__c'
            
        for(String field:syncedFields) {
            if(old.get(field) != a.get(field)) {
                return true;
            }
        }
        
        
        //If recordtype changed to or from supplier
        if((isSupplier(old) && !isSupplier(a)) || (!isSupplier(old) && isSupplier(a))){
            System.debug('Record type change ! - new Type '+a.RecordType_Name__c);
            return true;
        }
        
        return false;
    }
    
    public static void fillTerritoryLookup(Account[] accs){
        Map<String,String> regionToTerritoryMap = new Map<String,String>();
        Map<String,String> codeToIdMap = new Map<String,String>();
        for(Account acc:accs){
            regionToTerritoryMap.put(acc.Id,acc.region_cycle__c);
        }
        
        List<Territory__c> ts = [SELECT Id,Region_Code__c FROM Territory__c WHERE Region_Code__c IN: regionToTerritoryMap.values()];
        for(Territory__c t:ts){
            codeToIdMap.put(t.Region_Code__c,t.Id);
        }
        
        for(Account acc:accs){
            acc.Territory__c = codeToIdMap.get(acc.region_cycle__c);
        }
        
    }
    
    public static void fillRegion(Account[] accs){
        Map<String,String> territoryToRegionMap = new Map<String,String>();
        
        Map<String,String> IdToCodeMap = new Map<String,String>();
        for(Account acc:accs){
            territoryToRegionMap.put(acc.Id,acc.Territory__c);
        }
        
        List<Territory__c> ts = [SELECT Id,Region_Code__c FROM Territory__c WHERE Id IN: territoryToRegionMap.values()];
        for(Territory__c t:ts){
            IdToCodeMap.put(t.Id,t.Region_Code__c);
        }
        
        for(Account acc:accs){
            acc.region_cycle__c = IdToCodeMap.get(acc.Territory__c);
        }
    }
    
    private static boolean isSupplier(Account acc){
        return (acc.RecordType_Name__c == 'Supplier' || acc.RecordType_Name__c == 'Media' || acc.RecordType_Name__c == 'Brand');
    }

    public static boolean isIntegrationUser(String profileName){
        if(
        (UserInfo.getFirstName() == 'Integration' && UserInfo.getLastName() =='Benefit') ||
        (UserInfo.getFirstName() == 'User' && UserInfo.getLastName() =='Integration') ||
        (profileName.toLowerCase().contains('integration'))
        ) {
            return true;
        }
        return false;
    }
    
}