public class SharePointUploadController {
    /*
    private static String orgUrl = 'https://wepscrm.sharepoint.com';
        
    
    @AuraEnabled
    public static String getToken(){
        Map<String,String> token =  Auth.AuthToken.getAccessTokenMap('0SO9E00000000iF', 'Microsoft Access Control Service');
        
        System.debug(token);
        
        string data2 = 'grant_type=client_credentials&username=petr%40wepscrm.onmicrosoft.com&password=poiPOI1234&client_id=6eff4ef6-1612-4274-a7e7-a2fd0d1dec58%4092ca3734-f9c6-41b3-ab40-bbdbdeb07cf9&client_secret=mUT18uXc0NxRv%2FYVYkkrzfRIpQMv4%2BBKcIbkd1qz%2Fog%3D&resource=00000003-0000-0ff1-ce00-000000000000%2Fwepscrm.sharepoint.com%40wepscrm.onmicrosoft.com';
        
        Http http = new Http();
        HttpResponse response;
        
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://accounts.accesscontrol.windows.net/wepscrm.onmicrosoft.com/tokens/OAuth/2?resource=00000003-0000-0ff1-ce00-000000000000/wepscrm.sharepoint.com@wepscrm.onmicrosoft.com');
        request.setMethod('POST');
        request.setHeader('content-type', 'application/x-www-form-urlencoded');
        request.setBody(data2);
        request.setTimeout(60000);
        
        response = http.send(request);
        responseJSON res = parse(response.getBody());
        System.debug('tkn:'+res.access_token);
        return res.access_token;        
    }
    

    
    @AuraEnabled
    public static string simpleUploadOutlook(String name,Blob b,String recordId){
        
        String originalName = name;
        name = EncodingUtil.urlEncode(name, 'UTF-8').replaceAll('\\+','%20');
        
        uploadResponse res = new uploadResponse();        
        
        
        System.debug('fileName '+name);
        
        //Shared%20Documents
        string token = getToken();
        String endpoint = 'https://wepscrm.sharepoint.com/sites/SF_Aspire/_api/web/GetFolderByServerRelativeUrl%28%27CloudHDdeveloperSF%27%29/files/add%28overwrite=true,url=%27'+name+'%27%29';       
        //EncodingUtil.urlEncode(targetString,'UTF-8');
        
        Http http = new Http();
        HttpRequest httpReq = new  HttpRequest();
        
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod( 'POST' );
        httpReq.setBodyAsBlob(b);
        httpReq.setHeader( 'Accept', 'application/json' );
        httpReq.setHeader( 'Authorization', 'Bearer ' + token);
        
        HttpResponse response = http.send( httpReq );
        
        if(response.getStatusCode() == 200) {
            res = parseUpload(response.getBody());
            System.debug(res);
            
            attachFile(recordId, res.ServerRelativeUrl, originalName);
            
            return res.ServerRelativeUrl;
        }else{
            return 'not done';
        }
        
    }
    
    
    @AuraEnabled
    public static string simpleUpload(String name,String content,String recordId, boolean isChunk){
        content = EncodingUtil.urlDecode(content, 'UTF-8');
        String originalName = name;
        name = EncodingUtil.urlEncode(name, 'UTF-8').replaceAll('\\+','%20');
        
        uploadResponse res = new uploadResponse();        
        
        String folderName;
        List<Document__c> doc =[SELECT Id,Document_ID__c FROM Document__c WHERE Id=:recordId]; 
        if(doc!=null && doc.size()>0){
            folderName = EncodingUtil.urlEncode(doc[0].Document_ID__c, 'UTF-8').replaceAll('\\+','%20');
        }
        
        System.debug('fileName '+name);
        
        //Shared%20Documents
        string token = getToken();
        String endpoint = 'https://wepscrm.sharepoint.com/sites/SF_Aspire/_api/web/GetFolderByServerRelativeUrl%28%27CloudHDdeveloperSF%27%29/files/add%28overwrite=true,url=%27'+name+'%27%29';       
        //EncodingUtil.urlEncode(targetString,'UTF-8');
        
        Http http = new Http();
        HttpRequest httpReq = new  HttpRequest();
        
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod( 'POST' );
        if(content!= null && content.length()>0){
            Blob b = EncodingUtil.base64Decode(content);
            httpReq.setBodyAsBlob(b);}
        
        httpReq.setHeader( 'Accept', 'application/json' );
        httpReq.setHeader( 'Authorization', 'Bearer ' + token);
        
        HttpResponse response = http.send( httpReq );
        
        if(response.getStatusCode() == 200) {
            res = parseUpload(response.getBody());
            System.debug(res);
            if(recordId !=null && !isChunk)
                attachFile(recordId, res.ServerRelativeUrl, originalName);
            
            return res.ServerRelativeUrl;
        }else{
            return 'not done';
        }
        
    }
    
    public static void attachFile(String recordId, String url, String fileName){
        // edit link: +'?Web=1';
        List<Document__c> os = [SELECT Id FROM Document__c WHERE Id=:recordId];
        if(os.size() > 0){
            Document__c o = os[0];
            o.File_Storage_Location__c = 'https://wepscrm.sharepoint.com'+url;
            o.File_Name__c = fileName;
            update o;
        }
    }
    
    
    //JSON response - token auth
    
    public static responseJSON parse(String json) {
        return (responseJSON) System.JSON.deserialize(json, responseJSON.class);
    }
    
    public static uploadResponse parseUpload(String json) {
        return (uploadResponse) System.JSON.deserialize(json, uploadResponse.class);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        
        return oAttachment.Id;
    }
   
    public class responseJSON {
        
        public String token_type;
        public String expires_in;
        public String not_before;
        public String expires_on;
        public String resource;
        public String access_token;
    }
    
    public class uploadResponse {
        
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public String CheckInComment {get;set;} 
        public Integer CheckOutType {get;set;} 
        public String ContentTag {get;set;} 
        public Integer CustomizedPageStatus {get;set;} 
        public String ETag {get;set;} 
        public Boolean Exists {get;set;} 
        public Boolean IrmEnabled {get;set;} 
        public String Length {get;set;} 
        public Integer Level {get;set;} 
       // public Object LinkingUri {get;set;} 
        public String LinkingUrl {get;set;} 
        public Integer MajorVersion {get;set;} 
        public Integer MinorVersion {get;set;} 
        public String Name {get;set;} 
        public String ServerRelativeUrl {get;set;} 
        public String TimeCreated {get;set;} 
        public String TimeLastModified {get;set;} 
        //public Object Title {get;set;} 
        public Integer UIVersion {get;set;} 
        public String UIVersionLabel {get;set;} 
        public String UniqueId {get;set;} 
    }
    */
}