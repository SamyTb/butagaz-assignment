@RestResource(urlMapping='/v.1/Concentement/*')
global with sharing class REST_ConcentementController {
    
   @HttpPost
     global static Result doPost(String sMail, Boolean bOptinBTZ, Boolean bOptinGroupe){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = '';
        List<Lead> lLeadsToUpdate = new List<Lead>();
        List<Account> lAccountsToUpdate = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        
        String MESSAGE_OK = Label.REST_ConsentementController_Message_OK;
        String MESSAGE_ERROR = Label.REST_EmailOptoutController_Message_Error;
        String MESSAGE_NOTFOUND = Label.REST_EmailOptoutController_Message_NotFound;
        String MESSAGE_NOEMAIL = Label.REST_EmailOptoutController_Message_NoEmail;
        
        
        // grab the email address from the end of the URL
       // String sMail = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(sMail == ''){
          returnResponse = 'optoutNOEMAIL';
            returnMessage = MESSAGE_NOEMAIL;
        }else{
          
          
          List<Lead> foundLeads = [select Id, Email, Optin_1__c,OptinGroupeBtz__c
                                          FROM Lead 
                                          WHERE Email = :sMail ];  
                                          
          List<Account> foundAccounts = [select Id, Email__c, Optin_1__c,Optin_Partenaires__c
                                          FROM Account 
                                          WHERE Email__c = :sMail  ];       





         if( foundLeads.size() > 0 ) {
                      for (Lead ld : foundLeads) {
                          
                          System.debug(logginglevel.WARN, 'EmailOptoutRestService.doPatch() | Found lead : ' + ld.Id + ' with email : ' + sMail);
                          
                          if(ld.Email == sMail){
                              ld.Optin_1__c = bOptinBTZ; 
                              ld.OptinGroupeBtz__c =bOptinGroupe;
                          }
                          
                          lLeadsToUpdate.add(ld);
                          
                      }
                  }

                                          
                                           
          if( foundAccounts.size() > 0 ) {
              for (Account acc : foundAccounts) {
                  
                  System.debug(logginglevel.WARN, 'EmailOptoutRestService.doPatch() | Found account : ' + acc.Id + ' with email : ' + sMail);
                  
                  if(acc.Email__c == sMail){
                      acc.Optin_1__c = bOptinBTZ; 
                      acc.Optin_Partenaires__c=bOptinGroupe;
                  }
                 
                  
                  lAccountsToUpdate.add(acc);
                  
              }
          }
          
          if(lLeadsToUpdate.size() > 0){
              try {
                  update lLeadsToUpdate;
                  
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
          
          
          if(lAccountsToUpdate.size() > 0){
              try {
                  update lAccountsToUpdate;
                  
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