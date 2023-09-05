global class CampaignConnectionBatch implements Database.Batchable<sObject>{    
    STATIC FINAL STRING LIST_EMAIL = 'ListEmail';
    
    public String query;
    
    public CampaignConnectionBatch(String query){
        this.query = query;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        //Get all tasks with ListEmail created the previous day
        Date yesterday = Date.today().addDays(-1);
        
        String taskQuery = this.query != null ? this.query : 'SELECT Id, WhoId, WhatId,CreatedDate FROM Task WHERE CreatedDate =: yesterday AND what.type =: LIST_EMAIL AND WhoId != null ';
        
        return Database.getQueryLocator(taskQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Task> scope){
        Set<Id> emailIds = new Set<Id>();
        
        List<Campaign_Connection__c> newConnections = new List<Campaign_Connection__c>();
        
        for(Task t:scope){
            if(!emailIds.contains(t.WhatId)){
                emailIds.add(t.WhatId);
            }
        }
        
        Map<Id,ListEmail> idToEmails = new Map<Id,ListEmail>([SELECT CampaignId, Subject, HtmlBody,Status,CreatedDate FROM ListEmail where Id IN: emailIds]);
        
        for(Task t:scope){
            Campaign_Connection__c newConnection;
            
            if(idToEmails.containsKey(t.WhatId) && idToEmails.get(t.WhatId).CampaignId != null){
                
                ListEmail mailList = idToEmails.get(t.WhatId);
                
                newConnection = new Campaign_Connection__c(
                    Campaign__c = mailList.CampaignId,
                    Contact__c = t.WhoId,
                    Status__c = mailList.Status,
                    TaskId__c = t.Id,
                    Sent_Date__c = mailList.CreatedDate
                );
                
                if(mailList.Subject != null){
                    newConnection.Subject__c = mailList.Subject;
                }
                
                if(mailList.HtmlBody != null){
                    newConnection.Body__c = mailList.HtmlBody;
                }
                
                newConnections.add(newConnection);
            }
        }
        
        System.debug('Creating: '+newConnections.size()+' new campaign connections');
        insert newConnections;
        
    }
    
    global static void finish(Database.BatchableContext BC) {
    }    
}