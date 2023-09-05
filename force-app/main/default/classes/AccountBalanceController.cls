public class AccountBalanceController {

    public static void updateBalances(List<BenefitTypes.BalanceJSON> balances) {
        Map<String, Account> customers = new Map<String, Account>();
        Map<String,Double> currencyMap = new Map<String,Double>();
        List<Account> accsToUpdate = new List<Account>();
        
        customers = getAccountsByIds(balances);
        currencyMap = getCurrencyMap();
        
        for(BenefitTypes.BalanceJSON balance:balances) {
            if(customers.containsKey(balance.ben_partid)) {
                Account c = customers.get(balance.ben_partid);
                Double conversionRate = currencyMap.get(c.CurrencyIsoCode);
                
                c.Balance_After_Due__c = balance.balance_after*conversionRate;
                c.Balance_Total__c = balance.balance*conversionRate;
                accsToUpdate.add(c);
            }
        }
        
        update accsToUpdate;
    }

    private static Map<String,Double> getCurrencyMap() {
        Map<String,Double> currencyMap = new Map<String,Double>();
        
        // Currency ISO code to conversion rate
        for(currencytype c :[SELECT ConversionRate, IsCorporate, IsoCode FROM currencytype]) {
            currencyMap.put(c.IsoCode, c.ConversionRate);
        }

        return currencyMap;
    }

    private static Map<String, Account> getAccountsByIds(List<BenefitTypes.BalanceJSON> balances) {
        List<String> accIds = new List<String>();
        
        // TODO: Move to selectors class
        for(BenefitTypes.BalanceJSON balance:balances) {
            // Found accountIds for SOQL query
            accIds.add(balance.ben_partid);            
        }

        Map<String, Account> accounts = new Map<String, Account>();
        // Account externalId (Benefit) to record map
        for(Account acc : [SELECT Id, Benefit_Id__c,Balance_After_Due__c,Balance_Total__c,CurrencyIsoCode FROM Account WHERE Benefit_Id__c IN :accIds FOR UPDATE]) {
            accounts.put(acc.Benefit_Id__c, acc);
        }

        return accounts;
    }
}