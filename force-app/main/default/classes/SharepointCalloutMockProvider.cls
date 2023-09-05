@isTest
public class SharepointCalloutMockProvider {
    
    public class SharepointMockSuccess implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if(req.getEndpoint().contains('tokens/OAuth')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('folders/add')){
                String body = '{"ServerRelativeUrl": "testFolderUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('files/add')) {
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().contains('StartUpload')){
                String body = '{"value": 5}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().contains('continueupload')){
                String body = '{"value": 10}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().contains('finishUpload')){
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('breakroleinheritance')){
                String body = '';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('SiteUsers')){
                String body = '{"Id": "123"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('getbyprincipalid')){
                res.setBody('');
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('sitegroups')){
                String body = '{"Id": "456"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('addroleassignment')){
                res.setBody('');
                res.setStatusCode(200);
            }
            /*else if(req.getEndpoint().containsIgnoreCase('')){
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }*/
            else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
                String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            /*else if(rqe.getEndpoint().contains('partner/partner'){
                
            }*/
            return res;
        } 
    }
    
    public class SharepointMockFail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if(req.getEndpoint().contains('tokens/OAuth')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            
            if(req.getEndpoint().contains('folders/add')){
                String body = '{"ServerRelativeUrl": "testFolderUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('files/add')) {
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().contains('StartUpload')){
                String body = '{"value": 5}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().contains('continueupload')){
                String body = '{"value": 10}';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }
            else if(req.getEndpoint().contains('finishUpload')){
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('breakroleinheritance')){
                String body = '';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }
            else if(req.getEndpoint().containsIgnoreCase('SiteUsers')){
                String body = '{"Id": "123"}';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }
            else if(req.getEndpoint().containsIgnoreCase('getbyprincipalid')){
                res.setBody('');
                res.setStatusCode(200);
                res.setStatus('');
            }
            else if(req.getEndpoint().containsIgnoreCase('sitegroups')){
                String body = '{"Id": "456"}';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }
            else if(req.getEndpoint().containsIgnoreCase('addroleassignment')){
                res.setBody('');
                res.setStatusCode(200);
                res.setStatus('');
            }
            /*else if(req.getEndpoint().containsIgnoreCase('')){
                String body = '{"ServerRelativeUrl": "testFileUrl"}';
                res.setBody(body);
                res.setStatusCode(200);
            }*/
            else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
                String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }
            /*else if(rqe.getEndpoint().contains('partner/partner'){
                
            }*/
            return res;
        } 
    }
    
    public class SharepointTokenFail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if(req.getEndpoint().contains('tokens/OAuth')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(400);
                res.setStatus('Could not get token');
            }
            return res;
        }
    }
    
    
    
}