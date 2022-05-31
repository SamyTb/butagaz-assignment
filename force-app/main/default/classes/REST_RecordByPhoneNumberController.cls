@RestResource(urlMapping='/v.1/getRecordByPhoneNumber/*')
global with sharing class REST_RecordByPhoneNumberController {
    
    @HttpGet
    //global static List<String> doGet(){
    global static Result doGet(){
    //global static string doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = ''; 
        
        Result resultToReturn = new Result();
        //String resultToReturn = '';
        
        // grab the phone number from the end of the URL
        String phone = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //string phone = s1.startsWith('+') ? '{' +s1 + ' OR ' + '0' + s1.substring(3) + '}' : '{' + s1 + ' OR ' + '+33' + s1.substring(1) + '}';
        //string phone = s1.startsWith('+') ? s1 + ' OR ' + '0' + s1.substring(3) : s1 + ' OR ' + '+33' + s1.substring(1);
        phone = phone.startsWith('+') ? '0' + phone.substring(3) : phone;
        
        List<List<sObject>> searchList = [FIND :phone IN PHONE FIELDS
                                           RETURNING Account(Id,Salutation,FirstName,LastName,Email__c,Phone,Mobile_Phone_Number__c,ExternalID__c,Activity_Domain__r.ExternalID__c), 
                                                     PTL__c(Account_DO__r.Id, Account_DO__r.Salutation, Account_DO__r.FirstName, Account_DO__r.LastName, Account_DO__r.Email__c, Account_DO__r.Phone, Account_DO__r.Mobile_Phone_Number__c, Account_DO__r.ExternalID__c, Account_DO__r.Activity_Domain__r.ExternalID__c),
                                                     Project__c(Customer_Account__r.Id, Customer_Account__r.Salutation, Customer_Account__r.FirstName, Customer_Account__r.LastName, Customer_Account__r.Email__c, Customer_Account__r.Phone, Customer_Account__r.Mobile_Phone_Number__c, Customer_Account__r.ExternalID__c, Customer_Account__r.Activity_Domain__r.ExternalID__c),
                                                     Contact(Id,FirstName,LastName,Account.Id,Account.Salutation,Account.FirstName,Account.LastName,Account.Email__c,Account.Phone,Account.Mobile_Phone_Number__c,Account.ExternalID__c,Account.Activity_Domain__r.ExternalID__c), 
                                                     Lead(Id,Salutation,FirstName,LastName,Email,Phone,MobilePhone,Activity_Domain__r.ExternalID__c)
                                           LIMIT 2000];
        
        Account[] searchAccounts = (Account[])searchList[0];
        PTL__c[] searchPTLs = (PTL__c[])searchList[1];
        Project__c[] searchProjects = (Project__c[])searchList[2];
        Contact[] searchContacts = (Contact[])searchList[3];
        Lead[] searchLeads = (Lead[])searchList[4];
        
        System.debug('Found the following ' + searchAccounts.size() + ' accounts.');
        for (Account a : searchAccounts) {
            System.debug(logginglevel.WARN, a.Id + ', ' + a.Salutation + ', ' + a.FirstName + ', ' + a.LastName + ', ' + a.Email__c + ', ' + a.Phone + ', ' + a.Mobile_Phone_Number__c + ', ' + a.ExternalID__c + ', ' + a.Activity_Domain__r.ExternalID__c + ', ' + searchAccounts.size());
            recordFound = a.Id;
            resultToReturn = setResult('FoundAccount', a.Id, a.Salutation, a.FirstName, a.LastName, a.Email__c, a.Phone, a.Mobile_Phone_Number__c, a.ExternalID__c, String.valueOf(a.Activity_Domain__r.ExternalID__c), String.valueOf(searchAccounts.size()));
            break;
        }
        
        if(recordFound == ''){
            System.debug('Found the following ' + searchPTLs.size() + ' PTLs.');
            for (PTL__c p : searchPTLs) {
                // We need to check if there is an account linked to the PTL
                if(p.Account_DO__c != null){
                    System.debug(logginglevel.WARN, p.Account_DO__r.Id + ', ' + p.Account_DO__r.Salutation + ', ' + p.Account_DO__r.FirstName + ', ' + p.Account_DO__r.LastName + ', ' + p.Account_DO__r.Email__c + ', ' + p.Account_DO__r.Phone + ', ' + p.Account_DO__r.Mobile_Phone_Number__c + ', ' + p.Account_DO__r.ExternalID__c + ', ' + p.Account_DO__r.Activity_Domain__r.ExternalID__c + ', ' + searchPTLs.size());
                    recordFound = p.Account_DO__r.Id;
                    resultToReturn = setResult('FoundAccount', p.Account_DO__r.Id, p.Account_DO__r.Salutation, p.Account_DO__r.FirstName, p.Account_DO__r.LastName,  p.Account_DO__r.Email__c,  p.Account_DO__r.Phone,  p.Account_DO__r.Mobile_Phone_Number__c, p.Account_DO__r.ExternalID__c, String.valueOf(p.Account_DO__r.Activity_Domain__r.ExternalID__c), String.valueOf(searchPTLs.size()));
                    break;
                }
            }
        }
        
        if(recordFound == ''){
            System.debug('Found the following ' + searchProjects.size() + ' Projects.');
            for (Project__c p : searchProjects) {
                // We need to check if there is an account linked to the Project
                if(p.Customer_Account__c != null){
                    System.debug(logginglevel.WARN, p.Customer_Account__r.Id + ', ' + p.Customer_Account__r.Salutation + ', ' + p.Customer_Account__r.FirstName + ', ' + p.Customer_Account__r.LastName + ', ' + p.Customer_Account__r.Email__c + ', ' + p.Customer_Account__r.Phone + ', ' + p.Customer_Account__r.Mobile_Phone_Number__c + ', ' + p.Customer_Account__r.ExternalID__c + ', ' + p.Customer_Account__r.Activity_Domain__r.ExternalID__c + ', ' + searchProjects.size());
                    recordFound = p.Customer_Account__r.Id;
                    resultToReturn = setResult('FoundAccount', p.Customer_Account__r.Id, p.Customer_Account__r.Salutation, p.Customer_Account__r.FirstName, p.Customer_Account__r.LastName,  p.Customer_Account__r.Email__c,  p.Customer_Account__r.Phone,  p.Customer_Account__r.Mobile_Phone_Number__c, p.Customer_Account__r.ExternalID__c, String.valueOf(p.Customer_Account__r.Activity_Domain__r.ExternalID__c), String.valueOf(searchProjects.size()));
                    break;
                }
            }
        }
        
        if(recordFound == ''){
            System.debug('Found the following ' + searchContacts.size() + ' contacts.');
            for (Contact c : searchContacts) {
                System.debug(logginglevel.WARN, c.Id + ', ' + c.LastName + ', ' + c.FirstName + ', ' + c.Account.Id + ', ' + c.Account.Salutation + ', ' + c.Account.FirstName + ', ' + c.Account.LastName + ', ' + c.Account.Email__c + ', ' + c.Account.Phone + ', ' + c.Account.Mobile_Phone_Number__c + ', ' + c.Account.ExternalID__c + ', ' + c.Account.Activity_Domain__r.ExternalID__c + ', ' + searchContacts.size());
                recordFound = c.Account.Id;
                resultToReturn = setResult('FoundContact', c.Account.Id, c.Account.Salutation, c.Account.FirstName, c.Account.LastName, c.Account.Email__c, c.Account.Phone, c.Account.Mobile_Phone_Number__c, c.Account.ExternalID__c, String.valueOf(c.Account.Activity_Domain__r.ExternalID__c), String.valueOf(searchContacts.size()));
                break;
            }
        }
        
        if(recordFound == ''){
            System.debug('Found the following ' + searchLeads.size() + ' leads.');
            for (Lead l : searchLeads) {
                System.debug(logginglevel.WARN, l.Id + ', ' + l.Salutation + ', ' + l.FirstName + ', ' + l.LastName + ', ' + l.Email + ', ' + l.Phone + ', ' + l.MobilePhone + ', ' + l.Activity_Domain__r.ExternalID__c + ', ' + searchLeads.size());
                recordFound = l.Id;
                resultToReturn = setResult('FoundLead', l.Id, l.Salutation, l.FirstName, l.LastName, l.Email, l.Phone, l.MobilePhone, '', String.valueOf(l.Activity_Domain__r.ExternalID__c), String.valueOf(searchLeads.size()));
                break;
            }
        }
        
        
        //r.response = recordFound == '' ? '' : URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordFound;
        if (recordFound == ''){
            resultToReturn = setResult('NotFound', '', '', '', '',  '', '', '', '', '', '');
        }

        // Log API request and response if Custom Setting set to 'true'
        //string sResponse = 'response:' + resultToReturn.response + ', URL:' + resultToReturn.URL + ', ID:' + resultToReturn.ID + ', Salutation:' + resultToReturn.Salutation + ', FirstName:' + resultToReturn.FirstName + ', LastName:' + resultToReturn.LastName + ', EmailAddress:' + resultToReturn.EmailAddress + ', Phone:' + resultToReturn.Phone + ', MobilePhone:' + resultToReturn.MobilePhone;
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, req.params, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        /*String s = JSON.serialize(resultToReturn);
        System.debug(logginglevel.WARN,'### s = ' + s);*/

        return resultToReturn;
    }
    
    private static Result setResult(string response, string ID, string Salutation, string FirstName, string LastName, string EmailAddress, string Phone, string MobilePhone, string AccountNumber, string ActivityDomainExtId, string RecordCount){
        
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
        r.RecordCount = RecordCount == null ? '' : RecordCount;

        return r;
    }
    
    /*private static string setResult(string response, string ID, string Salutation, string FirstName, string LastName, string EmailAddress){
        
        List<Result> resultList = new List<Result>();
        Result r1 = new Result();
        r1.response = response;
        r1.URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ID;
        r1.ID = ID;
        r1.Salutation = Salutation;
        r1.FirstName = FirstName;
        r1.LastName = LastName;
        r1.EmailAddress = EmailAddress;
        resultList.add(r1);
        
        // Serialise the list
        String jsonData = JSON.serializePretty(resultList);
        
        return jsonData;
        
    }*/
    
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
        global String RecordCount{get;set;} /* 20190730 : Added RecordCount key in response so Zaion transfers the call if several records were found with the same phone number */
    }
    
}