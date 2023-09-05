@isTest
public class BenefitCalloutMockProvider {
    
    public class BenefitTokenResponse_Ok implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
            res.setBody(body);
            res.setStatusCode(200);
            
            return res;
        }
    }
    
    public class BenefitTokenResponse_Fail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            String body = '{"error":"invalid_grant","error_description":"The user name or password is incorrect."}';
            res.setBody(body);
            res.setStatusCode(400);
            
            return res;
        }
    }
    
    
    public class BenefitPartnerRevenue_OK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if(req.getEndpoint().contains('getsecuretoken')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('partner/partner')) {
                String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('partner_statistics/revenue')) {
                String body = '{"is_valid":true,"error":null,"revenues":' +
                    '[{"ben_partid":"888","ben_padrid":1,"brand":"TREK","revenue_ytd":2500,"revenue_2ytd":2500,"revenue_b2b":2017.2,"unreleased_preorder":500.0},' + 
                    '{"ben_partid":"888","ben_padrid":2,"brand":"SCOTT","revenue_ytd":1000,"revenue_2ytd":0.0,"revenue_b2b":1059.82,"unreleased_preorder":0.0},' + 
                    '{"ben_partid":"888","ben_padrid":2,"brand":"TREK","revenue_ytd":20000,"revenue_2ytd":5000,"revenue_b2b":20816.5,"unreleased_preorder":0.0},' +
                    '{"ben_partid":"888","ben_padrid":1,"brand":"UVEX","revenue_ytd":1000,"revenue_2ytd":0.0,"revenue_b2b":908.98,"unreleased_preorder":0.0}]}';
                res.setBody(body);
                res.setStatusCode(200);
            }

            return res;
        } 
    }
    
    public class BenefitPartnerRevenue_Fail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            
            if(req.getEndpoint().contains('getsecuretoken')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }
            if(req.getEndpoint().contains('partner_statistics/revenue')) {
                String body = '{"is_valid" : false,"ben_partid" : "3333", "error" : "not found"}';
                res.setBody(body);
                res.setStatusCode(400);                
            }
            return res;
        }
        
    }
    
    
    public class BenefitPartnerBalance_OK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            
            if(req.getEndpoint().contains('getsecuretoken')) {
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200); 
            }
            if(req.getEndpoint().contains('partner/partner')) {
                String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
                res.setBody(body);
                res.setStatusCode(200); 
            }
            if(req.getEndpoint().contains('partner_statistics/balance')) {
                String body = '{"is_valid":true,"error":null,"balances":['+ 
                    '{"ben_partid":"1","balance":6836.0,"balance_after":6836.0},' +
                    '{"ben_partid":"2","balance":863325.0,"balance_after":56084.0},' +
                    '{"ben_partid":"3","balance":7221.0,"balance_after":7221.0},' +
                    '{"ben_partid":"4","balance":5963.0,"balance_after":5963.0},' +
                    '{"ben_partid":"5","balance":348280.0,"balance_after":0.0}' +
                    ']}';
                res.setBody(body);
                res.setStatusCode(200);
                
                }
                return res;
                 
            }
    }
    
    
    public class BenefitPartnerBalance_Fail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            
            if(req.getEndpoint().contains('getsecuretoken')) {
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200); 
            }
            if(req.getEndpoint().contains('partner/partner')) {
                String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
                res.setBody(body);
                res.setStatusCode(200); 
            }
            if(req.getEndpoint().contains('partner_statistics/balance')) {
                String body = '{"is_valid":true,"error":null,"balances":['+ 
                    '{"ben_partid":"1","balance":6836.0,"balance_after":6836.0},' +
                    '{"ben_partid":"2","balance":863325.0,"balance_after":56084.0},' +
                    '{"ben_partid":"3","balance":7221.0,"balance_after":7221.0},' +
                    '{"ben_partid":"4","balance":5963.0,"balance_after":5963.0},' +
                    '{"ben_partid":"5","balance":348280.0,"balance_after":0.0}' +
                    ']}';
                res.setBody(body);
                res.setStatusCode(400);
                
                }
                return res;
                 
            }
        
    }
    

    
    public class BenefitPartnerInvoices_OK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if(req.getEndpoint().contains('getsecuretoken')) {
               String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
               res.setBody(body);
               res.setStatusCode(200);
           }
            System.debug('endpoint req: ' + req.getEndpoint());
            if(req.getEndpoint().contains('invoices')) {
                String body = '{"is_valid":true,"error":null,"invoices":['+
                          '{"ben_partid":"1","number":201905214,"variable":"201905214 ","date_issue":"2019-03-14T13:20:07.723","date_vat":"2019-03-14T00:00:00","date_due":"2019-04-13T00:00:00","date_payed":null,"ammount":3103.0,"amount_payed":0.0,"payment": "PP","currency":"CZK","days_after":10},'+
                          '{"ben_partid":"1","number":201720150,"variable":"201720150 ","date_issue":"2017-12-14T08:18:03.417","date_vat":"2017-12-14T00:00:00","date_due":"2019-04-13T00:00:00","date_payed":"2019-04-13T00:00:00","ammount":72472.0,"amount_payed":200.0,"payment": "PP","currency":"CZK","days_after":10},'+
                          '{"ben_partid":"1","number":201905271,"variable":"201905271 ","date_issue":"2019-03-14T15:52:57.96","date_vat":"2019-03-14T00:00:00","date_due":"2019-04-13T00:00:00","date_payed":null,"ammount":16420.0,"amount_payed":0.0,"payment": "PP","currency":"CZK","days_after":20},'+
                          '{"ben_partid":"1","number":201905175,"variable":"201905175 ","date_issue":"2019-03-14T11:39:30.267","date_vat":"2019-03-14T00:00:00","date_due":"2019-04-13T00:00:00","date_payed":null,"ammount":455.71,"amount_payed":0.0,"payment": "PP","currency":"EUR","days_after":20},'+
                          '{"ben_partid":"1","number":201907193,"variable":"201907193 ","date_issue":"2019-04-06T09:41:57.18","date_vat":"2019-04-06T00:00:00","date_due":"2019-04-13T00:00:00","date_payed":null,"ammount":112.15,"amount_payed":0.0,"payment": "PP","currency":"EUR","days_after":30}]}';
            res.setBody(body);
            res.setStatusCode(200);
            }

            return res;
        }
        
    }


   public class BenefitPartnerInvoices_Fail implements HttpCalloutMock {

       public HTTPResponse respond(HTTPRequest req) {
           HTTPResponse res = new HTTPResponse();
           res.setHeader('Content-type', 'application/json');
           if(req.getEndpoint().contains('getsecuretoken')) {
               String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
               res.setBody(body);
               res.setStatusCode(200);
           }
           if(req.getEndpoint().contains('invoices?days_from')) {
               String body = '{"Message":"Authorization has been denied for this request."}';
               res.setBody(body);
               res.setStatusCode(400);
           }

           return res;
       }
   }
   

  public class BenefitBlockB2B_OK implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/blockB2B')) {
              String body = '{"is_valid" : true,"error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }

          return res;
      }
  }

  public class BenefitBlockB2B_Fail implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/blockB2B')) {
              String body = '{"Message":"Authorization has been denied for this request."}';
              res.setBody(body);
              res.setStatusCode(400);
          }

          return res;
      }
  }
    
    public class BenefitBlockB2B_NotValid implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/blockB2B')) {
              String body = '{"is_valid":false,"error":"not found"}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          
          return res;
      }
  }


  public class BenefitPayInvoice_OK implements HttpCalloutMock {
      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200); 
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('pay_invoice')) {
              String body = '{"is_valid":true,"error":null,"res_invoices":['+
                            '{"ben_invyear":"2019","ben_invnumber":321804104,"is_valid": true,"error": null},'+
                            '{"ben_invyear":"2019","ben_invnumber":201905214,"is_valid": false,"error": "not found"},' +
                            '{"ben_invyear":"2019","ben_invnumber":333804587,"is_valid": true,"error": null}]}';
              res.setBody(body);
              res.setStatusCode(200);
              
          }
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
          else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
              String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
              res.setBody(body);
              res.setStatusCode(200);
              res.setStatus('');
          }
          
          return res;
      }
  }

  public class BenefitPayInvoice_Fail implements HttpCalloutMock {
      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('pay_invoice')) {
              String body = '{"is_valid":true,"error":"Bad request!","res_invoices":['+
                      '{"ben_invyear":"2019","ben_invnumber":333804587,"is_valid": false,"error": "Bad request!"}]}';
              res.setBody(body);
              res.setStatusCode(400);

          }
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
          else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
              String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
              res.setBody(body);
              res.setStatusCode(200);
              res.setStatus('');
          }

          return res;
      }
  }
    
    
    public class BenefitPayInvoice_Fail_NotValid implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200); 
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "1003", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('pay_invoice')) {
              String body = '{"is_valid":false,"error": "internal database error","res_invoices":['+
                            '{"ben_invyear":"2019","ben_invnumber":321804104,"is_valid": false,"error":"internal database error"}]}';
              res.setBody(body);
              res.setStatusCode(200);

          }
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
            else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
                String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
                res.setBody(body);
                res.setStatusCode(200);
                res.setStatus('');
            }


          return res;
      }
        
    } 
    
    
    
 
  public class BenefitPostInvoice_OK implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
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
          else if(req.getEndpoint().endswith('ListItemAllFields/RoleAssignments')){
              String body = '{"value": [{"PrincipalId":"123"},{"PrincipalId":"879"}]}';
              res.setBody(body);
              res.setStatusCode(200);
              res.setStatus('');
          }

          else{
              String body = '{"is_valid":true,"error":null,"ben_invyear":2019,"ben_invnumber":321804104}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          
          return res;
      }

  }
    

  public class BenefitPostInvoice_Fail implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) { 
              String body = '{"is_valid" : true,"ben_partid" : "3333", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('new_invoice')){
              String body = '{"is_valid":false,"error":"Není zadán partner.","ben_invyear":null,"ben_invnumber":null}';
              res.setBody(body);
              res.setStatusCode(400);
          }

          return res;
      }

  }
    
    public class BenefitPostInvoice_isValid_false implements HttpCalloutMock {

      public HTTPResponse respond(HTTPRequest req) {
          HTTPResponse res = new HTTPResponse();
          res.setHeader('Content-type', 'application/json');
          
          if(req.getEndpoint().contains('getsecuretoken')) {
              String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('partner/partner')) {
              String body = '{"is_valid" : true,"ben_partid" : "3333", "error" : null}';
              res.setBody(body);
              res.setStatusCode(200);
          }
          if(req.getEndpoint().contains('new_invoice')){
              String body = '{"is_valid":false,"error":"Není zadán partner.","ben_invyear":null,"ben_invnumber":null}';
              res.setBody(body);
              res.setStatusCode(200);
          }

          return res;
      }

  }

 
    public class BenefitPostPartner_OK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            String body = '{"is_valid" : true,"ben_partid" : "3333", "error" : null}';
            res.setBody(body);
            res.setStatusCode(200);
            
            return res;
        }
    }
    
    public class BenefitPostPartner_Fail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            
            if(req.getEndpoint().contains('getsecuretoken')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }else{
                String body = '{"is_valid" : false,"ben_partid" : "3333", "error" : "not found"}';
                res.setBody(body);
                res.setStatusCode(400);                
            }
            
            return res;
        }
    }
    
    
    public class BenefitPostAddress_OK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            String body = '{"is_valid" : true ,"ben_partid" : "2222", "ben_padrid" : "3", "error" : null}';
            res.setBody(body);
            res.setStatusCode(200);
            
            return res;
        }
        
    }
    
    public class BenefitPostAddress_Fail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            
            if(req.getEndpoint().contains('getsecuretoken')){
                String body = '{"access_token":"testTokenString","token_type":"bearer","expires_in":86399}';
                res.setBody(body);
                res.setStatusCode(200);
            }else{
                String body = '{"is_valid" : false ,"ben_partid" : "6666", "ben_padrid" : "", "error" : "not found"}';
                res.setBody(body);
                res.setStatusCode(400);                
            }
                        
            return res;
        }
        
    }

}