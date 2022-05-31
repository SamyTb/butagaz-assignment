@RestResource(urlMapping='/v.1/getRecordByAccountNumber/*')
global with sharing class REST_RecordByAccountNumberController {
	
    @HttpGet
    global static Result doGet(){
    	
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = ''; 
        
        Result resultToReturn = new Result();
        
        // grab the account number from the end of the URL
        String accNum = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        List<Account> foundAccounts = [SELECT Id, AccountNumber, ExternalID__c, Salutation, FirstName, LastName, Email__c, Phone, Mobile_Phone_Number__c, Activity_Domain__r.ExternalID__c
                                                   FROM Account 
                                                   WHERE AccountNumber = :accNum
                                                   LIMIT 1];
				                           
        if( foundAccounts.size() > 0 ) {
            for (Account acc : foundAccounts) {
                
                System.debug(logginglevel.WARN, 'REST_RecordByAccountNumberController.doGet() | Found account : ' + acc.Id);
                System.debug(logginglevel.WARN, acc.Id + ', ' + acc.Salutation + ', ' + acc.FirstName + ', ' + acc.LastName + ', ' + acc.Email__c + ', ' + acc.Phone + ', ' + acc.Mobile_Phone_Number__c + ', ' + acc.AccountNumber + ', ' + acc.Activity_Domain__r.ExternalID__c);
	            
	            resultToReturn = setResult('FoundAccount', acc.Id, acc.Salutation, acc.FirstName, acc.LastName,  acc.Email__c,  acc.Phone,  acc.Mobile_Phone_Number__c, acc.AccountNumber, String.valueOf(acc.Activity_Domain__r.ExternalID__c));
                
            }
        }else{
        	resultToReturn = setResult('NotFound', '', '', '', '',  '', '', '', '', '');
        }
        

        // Log API request and response if Custom Setting set to 'true'
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, req.params, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));
		
		
        return resultToReturn;
    }
    
    private static Result setResult(string response, string ID, string Salutation, string FirstName, string LastName, string EmailAddress, string Phone, string MobilePhone, string AccountNumber, string ActivityDomainExtId){
    	
    	Result r = new Result();
    	
    	r.response = response;
    	r.URL = ID == null || ID == '' ? '' : URL.getSalesforceBaseUrl().toExternalForm() + '/' + ID;
    	r.ID = ID == null ? '' : ID;
    	r.Salutation = Salutation == null ? '' : Salutation;
    	r.FirstName = FirstName == null ? '' : FirstName.replace('.', '');
    	r.LastName = LastName == null ? '' : LastName.replace('.', '');
    	r.EmailAddress = EmailAddress == null ? '' : EmailAddress;
    	r.Phone = Phone == null ? '' : Phone;
    	r.MobilePhone = MobilePhone == null ? '' : MobilePhone;
    	r.AccountNumber = AccountNumber == null ? '' : AccountNumber;
        r.ActivityDomainExtId = ActivityDomainExtId == null ? '' : ActivityDomainExtId;

    	return r;
    }
    
    global class Result {
    	global String response{get;set;}
        global String URL{get;set;}
        global String ID{get;set;}
        global String Salutation{get;set;}
        global String FirstName{get;set;}
        global String LastName{get;set;}
        global String EmailAddress{get;set;}
        global String Phone{get;set;}
        global String MobilePhone{get;set;}
        global String AccountNumber{get;set;}
        global String ActivityDomainExtId{get;set;}
    }
    
}