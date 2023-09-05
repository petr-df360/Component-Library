@isTest
public class REST_BenefitTest {
    
    @isTest
    public static void testPartner(){
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostPartner_OK());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/partnerService'; 
        
        String body = '{"name" : "partner2","org_id" : "12344567",	"maturity" : "23","payment" : "dobirka","comment" : "comment text","active" : true,"ben_partid" : "1","creditLimit":"35000","insurance":true,"supplier":false}';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        //req.requestBody = EncodingUtil.base64Decode(body);
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
        REST_BenefitToSalesforcePartner.ResponseObject response = REST_BenefitToSalesforcePartner.ProcessPost();
        
        String body2 = '{"name" : "","org_id" : "",	"maturity" : "22","payment" : "dobirka","comment" : "comment text","active" : true,"ben_partid" : "1","creditLimit":"35000","insurance":true,"supplier":true}';
        req.requestBody = Blob.valueOf(body2);
        REST_BenefitToSalesforcePartner.ResponseObject response2 = REST_BenefitToSalesforcePartner.ProcessPost();
        
        
        String body3 = '{"name" : "","org_id" : "",	"maturity" : "22","payment" : "dobirka","comment" : "comment text","active" : true,"ben_partid" : "1","creditLimit":"35000","insurance":true,"supplier":true}';
        req.requestBody = Blob.valueOf(body3);
        REST_BenefitToSalesforcePartner.ResponseObject response3 = REST_BenefitToSalesforcePartner.ProcessPost();
        
        
        
        Test.stopTest();  
    }
    
    @isTest
    public static void testAddress(){
        Test.setMock(HTTPCalloutMock.class, new BenefitCalloutMockProvider.BenefitPostAddress_OK());
        Test.startTest();
        
        Account acc = new Account();
        acc.Active__c = 'Yes';
        acc.Name = 'testAcc';
        acc.Benefit_Id__c='1';
        insert acc;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/addressService'; 
        String body = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":false,"ben_partid":"1","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com","ben_padrid":"24"}';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);
        
        REST_BenefitToSalesforceAddress.ResponseObject response = REST_BenefitToSalesforceAddress.ProcessPost();
        
        String body2 = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":false,"ben_partid":"","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com","ben_padrid":"24"}';
        req.requestBody = Blob.valueOf(body2);
        REST_BenefitToSalesforceAddress.ResponseObject response2 = REST_BenefitToSalesforceAddress.ProcessPost();
        
         String body3 = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":true,"ben_partid":"1","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com","ben_padrid":"24"}';
        req.requestBody = Blob.valueOf(body3);
        REST_BenefitToSalesforceAddress.ResponseObject response3 = REST_BenefitToSalesforceAddress.ProcessPost();
        
         String body4 = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":false,"ben_partid":"1","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com","ben_padrid":"25"}';
        req.requestBody = Blob.valueOf(body4);
        REST_BenefitToSalesforceAddress.ResponseObject response4 = REST_BenefitToSalesforceAddress.ProcessPost();
        
        String body5 = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":false,"ben_partid":"1","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com @#","ben_padrid":"25"}';
        req.requestBody = Blob.valueOf(body5);
        REST_BenefitToSalesforceAddress.ResponseObject response5 = REST_BenefitToSalesforceAddress.ProcessPost();
        
        String body6 = '{"name1":"Prodejna Zabrdovice","street":"Dornych 24","postcode":"60200","city":"Brno","state":"CZ","billing":false,"ben_partid":"1","contact":"Josef Vav2","email":"novakjoseph@jospehnovak.com","ben_padrid":""}';
        req.requestBody = Blob.valueOf(body6);
        REST_BenefitToSalesforceAddress.ResponseObject response6 = REST_BenefitToSalesforceAddress.ProcessPost();
        
        Test.stopTest();  
    }
}