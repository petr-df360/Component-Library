public class ContentDocumentTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public ContentDocumentTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    @future(callout=true)
    private static void call(String name,Blob content, String id,Boolean isAttachment, String fileId){
        SharepointController.simpleUploadOutlook(name,content,id,isAttachment,fileId);
    }
    
    public void OnAfterInsert(ContentDocumentLink[] links){
        
        Map<Id,ContentDocument> attachments = new Map<Id,ContentDocument>();
        Map<Id,ContentVersion> versions = new Map<Id,ContentVersion>();
        
        List<Id> ids = new List<Id>();
        List<Id> emailIds = new List<Id>();
        List<Id> versionIds = new List<Id>();
        List<Id> documentIds = new List<Id>();
        System.debug('afterHandler, size: '+links.size());
        if(links != null && links.size() > 0){
            for(ContentDocumentLink att: links){
                if(att!=null && att.ContentDocumentId != null && att.LinkedEntityId != null){
                    ids.add(att.ContentDocumentId);
                    emailIds.add(att.LinkedEntityId);}
            }
        }
        
        attachments = new Map<Id,ContentDocument>([SELECT Id, LatestPublishedVersionId FROM ContentDocument
                                                   WHERE Id in: ids]);
        if(attachments.keySet() != null && attachments.keySet().size()>0)
            for(ContentDocument att: attachments.values()){
                versionIds.add(att.LatestPublishedVersionId);
            }
        
        versions = new Map<Id,ContentVersion>([SELECT Id,Title,FileExtension,ContentDocumentId,VersionData FROM  ContentVersion WHERE Id IN: versionIds]);
        
        
        List<EmailMessage> emails = [SELECT Id,RelatedToId,ContentDocumentIds FROM EmailMessage WHERE Id IN: emailIds];
        if(emails != null && emails.size()>0)
            for(EmailMessage e: emails){
                documentIds.add(e.RelatedToId);
            }
        
        Map<Id,Document__c> docs;
        docs =new Map<Id,Document__c>([SELECT Id, File_Storage_Location__c FROM Document__c WHERE Id IN:documentIds]);
        
        for(EmailMessage e:emails){
            if(e!=null && e.ContentDocumentIds != null){
                
                List<ContentDocument> docs2 = new List<ContentDocument>();
                docs2 = [SELECT Id, Description FROM ContentDocument WHERE Id In:e.ContentDocumentIds];
                
                Integer counter = 0;
                for(Id link:e.ContentDocumentIds){
                    Document__c doc = docs.get(e.RelatedToId);
                    
                    //more complex error handling might be good - all attachments are deleted in batch
                    if(doc == null){
                        if(e!= null && e.ContentDocumentIds != null && e.ContentDocumentIds.size()>0){
                            if(docs2!=null && !docs2.isEmpty()){
                                
                                for(ContentDocument cd:docs2){
                                    cd.Description = 'TO-DELETE-OUTLOOK';    
                                }
                                //e.set('ContentDocumentIds',null);
                                
                                update docs2;
                            }
                        }
                        Id batchJobId = Database.executeBatch(new ContentDocumentDailyBatch(), 200);
                        return;
                    }
                    
                    
                    ContentDocument cd = attachments.get(link);
                    
                    if(cd!= null){
                        ContentVersion version = versions.get(cd.LatestPublishedVersionId);
                        //PNO 2021-12-07 - fix issue: outlook files missing extension
                        //String name = version.Title; 
                        String name = version.Title + '.'+ version.FileExtension;
                        String fileId;
                        
                        Boolean isDocumentAttachment = false;
                        
                        /*If document exists - create file__c 
                        * @depracatedIf document with file existis, create doc copy.*/
                        if(counter>0||(doc.File_Storage_Location__c != null && doc.File_Storage_Location__c.length()>0)){
                            isDocumentAttachment = true;
                            String fileName = name;
                            fileName = fileName;
                            String originalName;
                            
                            if(name.length()>255){
                                originalName= name.substring(0, 250)+'...';
                            }else{
                                originalName = name;
                            }
                            fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
                            fileName = fileName.replaceAll('\'','');
                            originalName = fileName.replaceAll('\'','');
                            
                            File__c f = new File__c(Document__c = doc.id,SP_File_Name__c=fileName,File_Name__c=originalName);
                            insert f;
                            fileId = f.Id;                            
                        }else{
                            doc.File_Storage_Location__c ='notnull';
                        }

                        call(name,version.VersionData, doc.Id, isDocumentAttachment,fileId);
                        
                        cd.Description = 'TO-DELETE-OUTLOOK';
                        update cd;
                    }
                    counter++;
                }
            }
        }
        Id batchJobId = Database.executeBatch(new ContentDocumentDailyBatch(), 200);
    }

}