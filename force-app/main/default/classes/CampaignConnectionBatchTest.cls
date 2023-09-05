@isTest
public class CampaignConnectionBatchTest {
    
    @isTest
    public static void testConnectionBatch(){
        Test.setMock(HttpCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostInvoice_OK());
        
        List<Contact> contacts = new List<Contact>();
        List<ListEmail> listEmails = new List<ListEmail>();
        List<Task> tasks = new List<Task>();
        
        Campaign cmp = new Campaign(Name='Campaign',isActive=true);
        insert cmp;
        
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        insert account1;
        
        for(Integer i = 0;i<10;i++){
            Contact contact1 = new Contact();
            contact1.FirstName = 'Dummy'+i;
            contact1.LastName = 'Contact'+i;
            contact1.AccountId = account1.Id;
            contact1.Email = 'someaspire'+i+'@email.org';
            contacts.add(contact1);
            
            ListEmail le = new ListEmail(
                CampaignId=cmp.Id,
                Status='Draft',
                Name = 'ListEmail'+i,
                Subject = 'subject',
                HtmlBody = 'emailBody',
                FromAddress = UserInfo.getUserEmail()
            );
            listEmails.add(le);
        }
        
        insert contacts;
        insert listEmails;
        
        for(Integer i = 0;i<10;i++){
            Task t = new Task();
            t.OwnerId = UserInfo.getUserId();
            t.Subject = 'ListEmail '+i;
            t.Status = 'In Progress';
            t.Priority = 'Normal';
            t.Description = 'Desc';
            t.WhatId = listEmails[i].Id;
            t.WhoId = contacts[i].Id;
            tasks.add(t);
        }
        
        insert tasks;
        
        String batchQuery = 'SELECT Id,WhoId,WhatId,CreatedDate FROM Task WHERE what.type =: LIST_EMAIL';
        
        Test.startTest();
        CampaignConnectionSchedule dbls = new CampaignConnectionSchedule();
        dbls.batchQuery = batchQuery;
        dbls.execute(null);
        Test.stopTest();
        
        List<Campaign_Connection__c> newConnections = [SELECT Id from Campaign_Connection__c];
        System.assertEquals(10,newConnections.size());
        
    }
    
    
}