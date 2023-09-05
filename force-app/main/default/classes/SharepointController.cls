public class SharepointController {

    // TODO: query by a flag (like active/org type), not by dev name
    private static final Sharepoint_Settings__mdt SP_SETTINGS = [select DeveloperName,Sharepoint_URL__c,Sharepoint_Site__c,Sharepoint_Folder__c, Username__c,
                                                                 Password__c, Client_ID__c, Client_Secret__c
                                                                 from Sharepoint_Settings__mdt WHERE DeveloperName ='aspiresportseu' LIMIT 1]; //name must be perserved on PROD
    
    private static String getSP(){
        return SP_SETTINGS.Sharepoint_URL__c+'/';
    }
    
    private static String getSPForUrl(){
        return SP_SETTINGS.Sharepoint_URL__c;
    }
    
    private static String getSiteName(){
        return SP_SETTINGS.Sharepoint_Site__c;
    }
    
    // Returns base sharepoint site url
    private static String getSite(){
        return getSP()+'sites/'+getSiteName()+'/_api/web';
    }
    
    // Returns base folder used for SF files storage
    private static String getDefaultFolder(){
        return SP_SETTINGS.Sharepoint_Folder__c; 
    }
    
    // Returns new guid
    private static String getGuid(){
        return GuidUtil.NewGuid();
    }
    
    /*Create folder for each file -> allows duplicate file names without overriding e.g. -> ProductCatalog2017.pdf for several brands*/
    @AuraEnabled
    public static boolean createFolder(String newFolder){
        newFolder = EncodingUtil.urlEncode(newFolder, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        String url = getSite()+'/folders/add(%27'+getDefaultFolder()+'/'+newFolder+'%27)';
        String method = 'POST';
        
        Http http = new Http();
        HttpRequest request = getRequest(method,url);
        request.setHeader( 'Accept', 'application/json' );
        request.setBody('');
        HttpResponse response = http.send(request);
        
        //handle success/error I guess - url is not needed as folderName format is reliable (salesforce documentId - this may change tho)
        if (response.getStatusCode() == 200) {
            breakInheritance(newFolder);
            return true;
        }else{
            logError('CreateFolder', url,  response.getStatusCode(), response.getStatus());
            return false;//it's focked mate
        }
    }
    
    @AuraEnabled
    public static String simpleUpload(String fileName, String content, String documentId){
        Boolean folderCreated = createFolder(documentId);
        fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        //create new folder based on documentId and then just upload it! - this method is used for small files and first step of large file upload --->
        //	before startUpload is used, file must exist -> empty file is created with an empty body, url is returned and the rest is done with start/continue/finish upload
        String fileUrl;
        String url = getSite()+'/GetFolderByServerRelativeUrl%28%27'+getDefaultFolder()+'/'+documentId+'%27%29/files/add%28overwrite=true,url=%27'+fileName+'%27%29';
        String method = 'POST';
        
        Http http = new Http();
        HttpRequest request = getRequest(method,url);
        request.setHeader( 'Accept', 'application/json' );
        request.setBody(content);
        HttpResponse response = http.send(request);
        
        //handle success/error I guess - url is not needed as folderName format is reliable (salesforce documentId - this may change tho)
        if (response.getStatusCode() == 200) {
            SharepointResponses.simpleUploadResponse res = parseSimple(response.getBody());
            fileUrl = res.ServerRelativeUrl;
        }else{
            logError('SimpleUpload', url,  response.getStatusCode(), response.getStatus());
            fileUrl = 'FAILED';
        }
        return fileUrl; //returned by sharepoint
    }
    
    @AuraEnabled
    public static lightningResponse startUpload(String fileName, String content, String documentId){
        fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        content = EncodingUtil.urlDecode(content, 'UTF-8');
        lightningResponse lr = new lightningResponse();
        String fileUrl = simpleUpload(fileName,'',documentId);
        lr.relativeUrl = fileUrl;        
        
        String guid = getGuid();
        lr.guid = guid;
        
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/getFileByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+getDefaultFolder()+'/'+documentId+'/'+fileName+'%27%29/StartUpload%28%27'+guid+'%27%29'; 
        
        Integer offset;
        //uploading large file 
        //1. create folder
        //upload empty
        //upload first and return offset - returned by SP
        
        String method = 'POST';
        
        Http http = new Http();
        HttpRequest request = getRequest(method,url);
        request.setHeader( 'Accept', 'application/json' );
        if(content!= null && content.length()>0){
            Blob b = EncodingUtil.base64Decode(content);
            request.setBodyAsBlob(b);}
        HttpResponse response = http.send(request);
        
        
        
        //handle success/error I guess - url is not needed as folderName format is reliable (salesforce documentId - this may change tho)
        if (response.getStatusCode() == 200) {
            SharepointResponses.chunkUploadResponse res = parseChunk(response.getBody());
            if(res != null && res.value!= null){
                lr.offset = Integer.valueOf(res.value);
                lr.valid = true;}
            else{
                lr.valid = false;
            }
        }else{
            logError('StartUpload', url,  response.getStatusCode(), response.getStatus());
            lr.valid = false;
        }
        
        return lr;
    }
    
    @AuraEnabled
    public static lightningResponse continueUpload(Integer offset, String fileName, String content, String documentId, String guid){
        fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        content = EncodingUtil.urlDecode(content, 'UTF-8');
        lightningResponse lr = new lightningResponse();
        lr.guid = guid;
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/getFileByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+'/'+getDefaultFolder()+'/'+documentId+'/'+fileName+'%27%29/continueupload%28uploadId=guid%27'+guid+'%27,fileOffset=%27'+offset+'%27%29'; 
        
        
        String method = 'POST';
        
        Http http = new Http();
        HttpRequest request = getRequest(method,url);
        request.setHeader( 'Accept', 'application/json' );
        if(content!= null && content.length()>0){
            Blob b = EncodingUtil.base64Decode(content);
            request.setBodyAsBlob(b);}
        HttpResponse response = http.send(request);
        
        //handle success/error I guess - url is not needed as folderName format is reliable (salesforce documentId - this may change tho)
        if (response.getStatusCode() == 200) {
            SharepointResponses.chunkUploadResponse res = parseChunk(response.getBody());
            if(res != null && res.value!= null){
                lr.offset = Integer.valueOf(res.value);
                lr.valid = true;}
            else{
                lr.valid = false;
            }
        }else{
            logError('ContinueUpload', url,  response.getStatusCode(), response.getStatus());
            lr.valid = false;
        }
        
        return lr;
    }
    
    @AuraEnabled
    public static String finishUpload(Integer offset, String fileName, String content, String documentId, String guid,Boolean isDocument){
        String originalName = fileName;
        fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        content = EncodingUtil.urlDecode(content, 'UTF-8');
        String url=getSP()+'sites/'+getSiteName()+'/_api/Web/getFileByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+'/'+getDefaultFolder()+'/'+documentId+'/'+fileName+'%27%29/finishUpload(uploadId=guid%27'+guid+'%27,fileOffset=%27'+offset+'%27%29'; 
        
        String result='';
        String method = 'POST';
        
        Http http = new Http();
        HttpRequest request = getRequest(method,url);
        request.setHeader( 'Accept', 'application/json' );
        if(content!= null && content.length()>0){
            Blob b = EncodingUtil.base64Decode(content);
            request.setBodyAsBlob(b);}
        else{
            request.setBody('');
        }
        HttpResponse response = http.send(request);
        
        //handle success/error I guess - url is not needed as folderName format is reliable (salesforce documentId - this may change tho)
        if (response.getStatusCode() == 200) {
            SharepointResponses.finishUploadResponse res = parseFinish(response.getBody());
            result = res.ServerRelativeUrl;
            if(isDocument){
                attachDocument(result, documentId,originalName);}
            else{
                attachFile(result, documentId,fileName,originalName,null);
            }
        }else{
            logError('FinishUpload', url,  response.getStatusCode(), response.getStatus());
            result='FAIL';
        }
    
        return result;
    }
    
    
    @AuraEnabled
    public static string simpleUploadOutlook(String fileName,Blob b,String documentId,Boolean isAttachment,String fileId){
        
        String originalName = fileName;
        fileName = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20').replaceAll('%27','');
        
        String url = getSite()+'/GetFolderByServerRelativeUrl%28%27'+getDefaultFolder()+'/'+documentId+'%27%29/files/add%28overwrite=true,url=%27'+fileName+'%27%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('POST',url);
        request.setHeader( 'Accept', 'application/json' );
        request.setBodyAsBlob(b);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            SharepointResponses.simpleUploadResponse res = parseSimple(response.getBody());
            
            if(isAttachment){
                attachFile(res.ServerRelativeUrl,documentId, fileName,originalName, fileId);}
            else{
                attachDocument(res.ServerRelativeUrl,documentId, originalName);
            }
            return res.ServerRelativeUrl;
        }else{
            logError('simpleUploadOutlook', url,  response.getStatusCode(), response.getStatus());
            return 'not done';
        }        
    }
    
    @AuraEnabled
    public static void removeAttachment(String recordId){
        List<File__c> fs = [SELECT Id FROM File__c
                                WHERE Id=: recordId];
        if(fs != null && fs.size() >0){
            delete fs;
        }
    }
    
    @AuraEnabled
    public static void removeFileLink(String recordId){
        List<Document__c> ds = [SELECT Id,File_Name__c,File_Storage_Location__c
                                FROM Document__c
                                WHERE Id=: recordId
                                AND File_Name__c != null
                                AND File_Storage_Location__c != null];
        if(ds != null && ds.size() >0){
            Document__c d = ds[0];
            d.File_Name__c = null;
            d.File_Storage_Location__c = null;
            update d;
        }
        
        
    }
    
    @AuraEnabled
    public static void removeToast(String recordId){
        List<Document__c> ds = [SELECT Id, Show_Sharing_Toast__c
                                FROM Document__c
                                WHERE Id=: recordId];
        if(ds != null && ds.size() >0){
            ds[0].Show_Sharing_Toast__c = false;
            update ds;
        }
    }
    
    
        
    @AuraEnabled
    public static void attachDocument(String url, String recordId, String fileName){
        fileName = fileName.replaceAll('\'','');
        List<Document__c> os = [SELECT Id FROM Document__c WHERE Id=:recordId];
        
        String folderLocation = getSPForUrl()+url;
        folderLocation = folderLocation.substring(0,folderLocation.lastIndexOf('/')+1);
        
        if(os.size() > 0){
            Document__c o = os[0];
            o.File_Storage_Location__c = getSPForUrl()+url;
            o.File_Name__c = fileName;
            o.Folder_Storage_Location__c = folderLocation;
            update o;
        }
    }
    
    
    @AuraEnabled
    public static void attachFile(String url, String recordId,String spName, String fileName, String fileId){
        fileName = fileName.replaceAll('\'','');
        
        if(fileName.length()>255){
           fileName= fileName.substring(0, 250)+'...';
        }
        
        if(fileId == null){
            File__c f = new File__c(
                File_Location__c = getSPForUrl()+url,
                File_Name__c = fileName,
                SP_File_Name__c=spName,
                Document__c = recordId
            );
            insert f;
        }else{
            List<File__c> fs = [SELECT Id,File_Location__c,SP_File_Name__c,File_Name__c,Document__c FROM File__c WHERE Id = :fileId];
            if(fs!=null && fs.size()>0){
                fs[0].File_Location__c = getSPForUrl()+url;
                fs[0].File_Name__c=fileName;
                update fs[0];
            }
        }
    }
    
    
    
    /*SHAREPOINT PERMISSIONS*/    
    public static void breakInheritance(String documentId){
        
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/GetFolderByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+
            '/'+getDefaultFolder()+'/'+documentId+'%27%29/ListItemAllFields/breakroleinheritance%28true%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('POST',url);
        request.setHeader( 'Accept', 'application/json' );
        request.setBody('');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Integer userId = getSPUserId();
            if(userId !=-1){
                getAndDeleteDefaultRoleAssignments(documentId,userId);}//, fileName, userId);}
            else{
                logError('breakInheritance', url,  response.getStatusCode(), 'Could not get userId');
                System.debug('failed to set permissions - unable to get userId');
            }
        }else{
            logError('breakInheritance', url,  response.getStatusCode(), response.getStatus());
            System.debug('failed to set permissions - break inheritance');
        }  
        
        //BY DEFAULT - Group all should be able to read the document
        Document__c doc = getDocument(documentId);
        /*if(doc.Is_Sharepoint_Insert__c == true){
            List<Group> gs = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName='All' LIMIT 1];
            if(gs!= null && gs.size()>0){
                addRoleAssignment(documentId,fileName,gs[0].Id,'Edit', false);
                doc.Is_Sharepoint_Insert__c = false;
                update doc;
            }
        }*/
        
        List<Document__share> sharings = [SELECT AccessLevel,Id,ParentId,UserOrGroupId FROM Document__Share WHERE ParentId =:documentId];
        if(sharings!= null && sharings.size()>0){
            for(Document__share share:sharings){
                String level;
                if(share.AccessLevel =='All'){
                    level = 'Edit';
                }
                if(share.AccessLevel =='Read'){
                    level = 'Read';
                }
                if(share.AccessLevel =='Edit'){
                    level = 'Edit';
                }
                addRoleAssignment(documentId, share.UserOrGroupId, level, false);
            }
        }
    }
    
    public static Integer getSPUserIdFromEmail(String userMail){
        Integer userId = -1;
        String url = getSP()+'sites/'+getSiteName()+'/_api/Web/SiteUsers%28%27i%3A0%23.f%7Cmembership%7C'+EncodingUtil.urlDecode(userMail, 'UTF-8')+'%27%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('GET',url);
        request.setHeader( 'Accept', 'application/json' );
        
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            SharepointResponses.SharepointUser res = parseSharepointUser(response.getBody());
            if(res!=null && res.Id != null){
                userId = res.Id;}
        }else{
            logError('GetSPUserIdFromEmail', url,  response.getStatusCode(), response.getStatus());
            System.debug('Failed to set permissions - unable to get userId from email.');
        }
        return userId;
    }
    
    public static Integer getSPUserId(){
        Integer userId = -1;
        String userMail='';
        
        userMail = userinfo.getUserEmail();
        
        
        String url = getSP()+'sites/'+getSiteName()+'/_api/Web/SiteUsers%28%27i%3A0%23.f%7Cmembership%7C'+EncodingUtil.urlDecode(userMail, 'UTF-8')+'%27%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('GET',url);
        request.setHeader( 'Accept', 'application/json' );
        
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            SharepointResponses.SharepointUser res = parseSharepointUser(response.getBody());
            if(res!=null && res.Id != null){
                userId = res.Id;}
        }else{
            logError('getSPUserId', url,  response.getStatusCode(), response.getStatus());
            System.debug('Failed to set permissions - unable to get userId');
        }
        return userId;
    }
    
    public static void getAndDeleteDefaultRoleAssignments(String documentId, Integer userId){         
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/GetFolderByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+
            '/'+getDefaultFolder()+'/'+documentId+'%27%29/ListItemAllFields/RoleAssignments';
        
        Http http = new Http();
        HttpRequest request = getRequest('GET',url);
        request.setHeader( 'Accept', 'application/json' );
        
        Set<Integer> systemAssignments = new Set<Integer>{3,6,64,userId}; // HARD-CODED SHAREPOINT GROUPS
            
            List<Integer> assignmentsDelete = new List<Integer>();
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            SharepointResponses.RoleAssignments res = parseRoleAssignments(response.getBody());
            if(res != null && res.value != null){
                System.debug('We have assignments '+res.value.size());
                for(SharepointResponses.RoleAssignment rass : res.value){
                    if(!systemAssignments.contains(rass.PrincipalId)){
                        // remove all except system and record owner
                        System.debug('Remove role assignment: '+rass.PrincipalId);
                        removePermission(documentId, rass.PrincipalId);
                    }
                }
            }
        }else{
            System.debug('Failed to load role assignments.');
            logError('getAndDeleteDefaultRoleAssignments', url,  response.getStatusCode(), response.getStatus());
        }
    }
    
    public static void removePermission(String documentId, Integer principalId){//, String fileName, Integer principalId){
      
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/GetFolderByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+
            '/'+getDefaultFolder()+'/'+documentId+'%27%29/ListItemAllFields/RoleAssignments/getbyprincipalid%28'+principalId+'%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('DELETE',url);
        request.setHeader( 'Accept', 'application/json' );
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            System.debug('Permission removed');
        }else{
            System.debug('Unable to remove: '+url);
            //logError('removePermission', url,  response.getStatusCode(), response.getStatus());
        }
    }
    
    
    
    
    public static Integer getSPGroupId(String groupName){
        Integer userId = -1;
        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/sitegroups/getbyname%28%27'+groupName+'%27%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('GET',url);
        request.setHeader( 'Accept', 'application/json' );
        
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            SharepointResponses.SharepointGroup res = parseSharepointGroup(response.getBody());
            if(res!=null && res.Id != null){
                return res.Id;
            }
        }else{
            logError('getSPGroupId', url,  response.getStatusCode(), response.getStatus());
        }
        return userId;
    }
    
    public static String getRoleDefinitionId(String accessLevel){
        if(accessLevel == 'Edit')
        {
            return '1073741827'; // Contribute
        }
        else if(accessLevel == 'Read'){
            return '1073741826'; // Read
        }
        else if(accessLevel == 'remove'){
            return 'remove';
        }
        return 'none';
    }
    
    public static void addRoleAssignment(Id documentId, String userOrGroupId, String accessLevel, Boolean ownerChange){//(Id documentId, String fileName, String userOrGroupId, String accessLevel, Boolean ownerChange){
        Boolean isAdmin = false;
        System.debug('user/group '+userOrGroupId);
        List<Group> groups = [SELECT DeveloperName, Id FROM Group WHERE id = :userOrGroupId];
        List<User> users = [SELECT Email,ProfileId, Id FROM User WHERE id = :userOrGroupId];
        
        String principalId='';
        Document__c doc;
        
        //Add permissions for a group?
        if(groups!= null && groups.size()>0){
            principalId = String.valueOf(getSPGroupId(groups[0].DeveloperName));
        }
        
        //Add permissions for an user?
        if(users != null && users.size()>0){
            String profileName = [select Name from profile where id = :users[0].profileId][0].Name;
            if(profileName!= null){
                if(profileName == 'System Administrator'|| profileName =='Správce systému'){
                    isAdmin = true;
                }
                principalId = String.valueOf(getSPUserIdFromEmail(users[0].Email));
                
            }
        }
        
        if(principalId == null || principalId.length() == 0){
            System.debug('Unable to set permission - no principal id.');
            return;
        }
        
        if(accessLevel =='remove'){
            if(isAdmin){
                return;  // Don't remove admin permissions
            }
            removePermission(documentId, Integer.valueOf(principalId));
            return;
        }

        String url =getSP()+'sites/'+getSiteName()+'/_api/Web/GetFolderByServerRelativeUrl%28%27/'+'sites/'+getSiteName()+
            '/'+getDefaultFolder()+'/'+documentId+'%27%29/ListItemAllFields/RoleAssignments/addroleassignment%28principalid='+principalId+',roledefid='+getRoleDefinitionId(accessLevel)+'%29';
        
        Http http = new Http();
        HttpRequest request = getRequest('POST',url);
        request.setHeader( 'Accept', 'application/json' );
        request.setBody('');
        
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            System.debug('Permission added');
            if(ownerChange){
                getAndDeleteDefaultRoleAssignments(String.valueOf(documentId), Integer.valueOf(principalId));//String.valueOf(documentId), fileName, Integer.valueOf(principalId));
            }
        }else{
            logError('addRoleAssignment', url,  response.getStatusCode(), response.getStatus());
            System.debug('Unable to add permissions');
        }
        
    }
    
    
    
    private static HttpRequest getRequest(String method, String endpoint){
        HttpRequest httpReq = new  HttpRequest();
        String token = getToken();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod(method);
        httpReq.setHeader( 'Accept', 'application/json' );
        httpReq.setHeader( 'Authorization', 'Bearer ' + token);
        return httpReq;
    }
    
    
    public static string getToken(){
        
        
        
        //HARDCODED CREDENTIALS - REMOVE
        string username = SP_SETTINGS.Username__c;
        string password = SP_SETTINGS.Password__c;
        string clientId = SP_SETTINGS.Client_Id__c;
        string secret = SP_SETTINGS.Client_Secret__c;
        string spName = SP_SETTINGS.DeveloperName;
        string data2 = 'grant_type=client_credentials&username='+username+'&'+password+'=&client_id='+clientId+'&client_secret='+secret+'&resource=00000003-0000-0ff1-ce00-000000000000%2F'+spName+'.sharepoint.com%40'+spName+'.onmicrosoft.com';
        string url = '';
        Http http = new Http();
        HttpResponse response;
        
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://accounts.accesscontrol.windows.net/'+spName+'.onmicrosoft.com/tokens/OAuth/2?resource=00000003-0000-0ff1-ce00-000000000000/'+spName+'.sharepoint.com@'+spName+'.onmicrosoft.com');
        request.setMethod('POST');
        request.setHeader('content-type', 'application/x-www-form-urlencoded'	);
        request.setHeader('accept', 'application/json');
        request.setBody(data2);
        request.setTimeout(60000);
        
        //add error handling
        response = http.send(request);
        if(response.getStatusCode() == 200){
            tokenJSON res = parse(response.getBody());
            return res.access_token;}
        else{
            logError('GetToken', url,  response.getStatusCode(), response.getStatus());
            throw new CalloutException('Sharepoint integration is not working properly. We were unable to get your security token. Sorry about this dear Aspire.');
        }
    }
    
    @AuraEnabled
    public static Document__c getDocument(String recordId){
        List<Document__c> ds = [SELECT Id,File_Name__c,File_Storage_Location__c,Show_Sharing_Toast__c,(SELECT Id,File_Name__c,Name,File_Location__c FROM Files__r ORDER BY CreatedDate)
                                FROM Document__c
                                WHERE Id=: recordId];
        if(ds == null || ds.size() ==0)
            return null;
        
        return ds[0];
    }
    
    @AuraEnabled
    public static Boolean isReadOnly(String documentId){
        UserRecordAccess access =  [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :documentId LIMIT 1];
        return !access.HasEditAccess;
    }
    
    
    
    public static void returnError(){
        
    }
    
    public static tokenJSON parse(String json) {
        return (tokenJSON) System.JSON.deserialize(json, tokenJSON.class);
    }
    
    public static SharepointResponses.simpleUploadResponse parseSimple(String json) {
        return (SharepointResponses.simpleUploadResponse) System.JSON.deserialize(json, SharepointResponses.simpleUploadResponse.class);
    }
    
    public static SharepointResponses.chunkUploadResponse parseChunk(String json) {
        return (SharepointResponses.chunkUploadResponse) System.JSON.deserialize(json, SharepointResponses.chunkUploadResponse.class);
    }
    
    public static SharepointResponses.finishUploadResponse parseFinish(String json) {
        return (SharepointResponses.finishUploadResponse) System.JSON.deserialize(json, SharepointResponses.finishUploadResponse.class);
    }
    
    public static SharepointResponses.RoleAssignments parseRoleAssignments(String json) {
        return (SharepointResponses.RoleAssignments) System.JSON.deserialize(json, SharepointResponses.RoleAssignments.class);
    }
    
    public static SharepointResponses.SharepointUser parseSharepointUser(String json) {
        return (SharepointResponses.SharepointUser) System.JSON.deserialize(json, SharepointResponses.SharepointUser.class);
    }
    
    public static SharepointResponses.SharepointGroup parseSharepointGroup(String json) {
        return (SharepointResponses.SharepointGroup) System.JSON.deserialize(json, SharepointResponses.SharepointGroup.class);
    }
    
    private static void logError(String method, String endpoint, Integer statusCode, String errorMessage) {
        if(errorMessage == null){
            errorMessage = 'NULL';
        }
        if(statusCode == null) {
            statusCode = 0;
        }
        if(method.length()> 250){
            method = method.substring(0, 250);
        }
        
        if(endpoint.length()> 250){
            endpoint = endpoint.substring(0, 250);
        }
        
        BenefitLogger__c logger = new BenefitLogger__c();
        logger.Method__c = method;
        logger.Endpoint__c = endpoint;
        if(errorMessage.length() > 190) {
            errorMessage = errorMessage.substring(0, 190);
        }
        logger.Message__c = 'SHAREPOINT CALLOUD: Status code: ' + statusCode +'. Error: ' + errorMessage;
        insert logger;
        
    }
    
    
    
    public class tokenJSON {
        public String token_type;
        public String expires_in;
        public String not_before;
        public String expires_on;
        public String resource;
        public String access_token;
    }
    
    public class lightningResponse{
        @AuraEnabled
        public String guid;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String relativeUrl;
        @AuraEnabled
        public Integer offset;
        @AuraEnabled
        public boolean valid;
    }
    
    
}