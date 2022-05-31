@RestResource(urlMapping='/v.1/NewsLetterOptout/*')
global with sharing class REST_NewsLetterOptoutController {
    
    @HttpPatch
    //global static List<String> doPatch(){
    global static Result doPatch(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = '';
        List<Contact> lContactsToUpdate = new List<Contact>();
        String returnResponse = '';
        String returnMessage = '';
        
        String MESSAGE_OK = Label.REST_NewsLetterOptoutController_Message_OK;
        String MESSAGE_ERROR = Label.REST_EmailOptoutController_Message_Error;
        String MESSAGE_NOTFOUND = Label.REST_EmailOptoutController_Message_NotFound;
        String MESSAGE_NOEMAIL = Label.REST_EmailOptoutController_Message_NoEmail;
        
        
        // grab the email address from the end of the URL
        String sMail = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(sMail == ''){
          returnResponse = 'optoutNOEMAIL';
            returnMessage = MESSAGE_NOEMAIL;
        }else{
          
          /*List<List<sObject>> searchList = [FIND :phone IN PHONE FIELDS
                             RETURNING Account(Id,Name), Contact(Id,FirstName,LastName,Account.Id), Lead(Id,Name)
                             LIMIT 1];
          Account[] searchAccounts = (Account[])searchList[0];
          Contact[] searchContacts = (Contact[])searchList[1];
          Lead[] searchLeads = (Lead[])searchList[2];*/
          
          List<Contact> foundContacts = [select Id, Email, Abonne_newsletter__c
                                          FROM Contact
                                          WHERE Email = :sMail  ];  
                                           
          if( foundContacts.size() > 0 ) {
              for (Contact con: foundContacts) {
                  
                  System.debug(logginglevel.WARN, 'EmailOptoutRestService.doPatch() | Found contact: ' + con.Id + ' with email : ' + sMail);
                  
                  if(con.Email== sMail){
                      con.Abonne_newsletter__c= False; 
                  }
                  
                  
                  lContactsToUpdate.add(con);
                  
              }
          }
          
          if(lContactsToUpdate.size() > 0){
              try {
                  update lContactsToUpdate;
                  
                  returnResponse = 'optoutOK';
                  returnMessage = MESSAGE_OK;
              } catch (DmlException e) {
                  System.debug('The following exception has occurred: ' + e.getMessage());
                  returnResponse = 'optoutNOK';
                  returnMessage = MESSAGE_ERROR;
              }
          }else{
              returnResponse = 'optoutNOTFOUND';
              returnMessage = MESSAGE_NOTFOUND;
          }
        }
        
        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage;

    // Log API request and response
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, req.params, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }
    
}