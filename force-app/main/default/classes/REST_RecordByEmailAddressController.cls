@RestResource(urlMapping='/v.1/getRecordByEmailAddress/*')
global with sharing class REST_RecordByEmailAddressController {
    
    @HttpGet
    global static Result doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = ''; 

        Result resultToReturn = new Result();
        
        
        // grab the phone number from the end of the URL
        String email = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        
        List<List<sObject>> searchList = [FIND :email IN EMAIL FIELDS
                                           RETURNING Account(Id,Salutation,FirstName,LastName,Email__c,Phone,Mobile_Phone_Number__c,ExternalID__c,Activity_Domain__r.ExternalID__c), 
                                                     Contact(Id,FirstName,LastName,Account.Id,Account.Salutation,Account.FirstName,Account.LastName,Account.Email__c,Account.Phone,Account.Mobile_Phone_Number__c,Account.ExternalID__c,Account.Activity_Domain__r.ExternalID__c), 
                                                     Lead(Id,Salutation,FirstName,LastName,Email,Phone,MobilePhone,Activity_Domain__r.ExternalID__c)
                                           LIMIT 3];
                                           
        Account[] searchAccounts = (Account[])searchList[0];
        Contact[] searchContacts = (Contact[])searchList[1];
        Lead[] searchLeads = (Lead[])searchList[2];
        
        System.debug('Found the following accounts.');
        for (Account a : searchAccounts) {
            System.debug(logginglevel.WARN, a.Id + ', ' + a.Salutation + ', ' + a.FirstName + ', ' + a.LastName + ', ' + a.Email__c + ', ' + a.Phone + ', ' + a.Mobile_Phone_Number__c + ', ' + a.ExternalID__c + ', ' + a.Activity_Domain__r.ExternalID__c);
            recordFound = a.Id;
            resultToReturn = setResult('FoundAccount', a.Id, a.Salutation, a.FirstName, a.LastName,  a.Email__c,  a.Phone,  a.Mobile_Phone_Number__c, a.ExternalID__c, String.valueOf(a.Activity_Domain__r.ExternalID__c));
        }
        
        if(recordFound == ''){
            System.debug('Found the following contacts.');
            for (Contact c : searchContacts) {
                System.debug(logginglevel.WARN, c.Id + ', ' + c.LastName + ', ' + c.FirstName + ', ' + c.Account.Id + ', ' + c.Account.Salutation + ', ' + c.Account.FirstName + ', ' + c.Account.LastName + ', ' + c.Account.Email__c + ', ' + c.Account.Phone + ', ' + c.Account.Mobile_Phone_Number__c + ', ' + c.Account.ExternalID__c + ', ' + c.Account.Activity_Domain__r.ExternalID__c);
                recordFound = c.Account.Id;
                resultToReturn = setResult('FoundContact', c.Account.Id, c.Account.Salutation, c.Account.FirstName, c.Account.LastName,  c.Account.Email__c,  c.Account.Phone,  c.Account.Mobile_Phone_Number__c, c.Account.ExternalID__c, String.valueOf(c.Account.Activity_Domain__r.ExternalID__c));
            }
        }
        
        if(recordFound == ''){
            System.debug('Found the following leads.');
            for (Lead l : searchLeads) {
                System.debug(logginglevel.WARN, l.Id + ', ' + l.Salutation + ', ' + l.FirstName + ', ' + l.LastName + ', ' + l.Email + ', ' + l.Phone + ', ' + l.MobilePhone + ', ' + l.Activity_Domain__r.ExternalID__c);
                recordFound = l.Id;
                resultToReturn = setResult('FoundLead', l.Id, l.Salutation, l.FirstName, l.LastName,  l.Email,  l.Phone,  l.MobilePhone, '', String.valueOf(l.Activity_Domain__r.ExternalID__c));
            }
        }
        
        
        //r.response = recordFound == '' ? '' : URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordFound;
        if(recordFound == ''){
            resultToReturn = setResult('NotFound', '', '', '', '',  '', '', '', '', '');
        }

        // Log API request and response if Custom Setting set to 'true'
        //string sResponse = 'response:' + resultToReturn.response + ', URL:' + resultToReturn.URL + ', ID:' + resultToReturn.ID + ', Salutation:' + resultToReturn.Salutation + ', FirstName:' + resultToReturn.FirstName + ', LastName:' + resultToReturn.LastName + ', EmailAddress:' + resultToReturn.EmailAddress + ', Phone:' + resultToReturn.Phone + ', MobilePhone:' + resultToReturn.MobilePhone;
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