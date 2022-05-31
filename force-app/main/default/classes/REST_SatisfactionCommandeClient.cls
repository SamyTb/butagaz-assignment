@RestResource(urlMapping='/v.1/SatisfactionCommandeClient/*')
global with sharing class REST_SatisfactionCommandeClient {
    
   @HttpPost
     global static Result doPost(String sAccountNumber, Integer iSatisfactionCdeNote, String sSatisfactionCdeOrigine,String sSatisfactionCdeValeurAC){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = '';
        List<Account> lAccountsToUpdate = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        
       
       
        if ( sSatisfactionCdeValeurAC=='RFC call bot' )  
       {
           sSatisfactionCdeOrigine=Label.REST_SatisfactionCdeOrigine;   
               
       }else
       {
           
           if ( sSatisfactionCdeOrigine == 'null')
           {
               sSatisfactionCdeOrigine = 'Autre';
               
           }else
           {
               sSatisfactionCdeOrigine = sSatisfactionCdeOrigine ;
           
           }
           
       }
             
        if(iSatisfactionCdeNote == null ){
          returnResponse = 'optoutNOEMAIL';
            returnMessage = 'pas de note';
        }else{
                                  
          List<Account> foundAccounts = [select Id, AccountNumber, SatisfactionCdeNote__c, SatisfactionCdeOrigine__c,Activity_Domain_Simple__c, SatisfactionCdeDate__c
                                          FROM Account 
                                          WHERE AccountNumber = :sAccountNumber  ];       
            
                                           
          if( foundAccounts.size() > 0 ) {
              for (Account acc : foundAccounts) {
                  
                  System.debug(logginglevel.WARN, 'EmailOptoutRestService.doPatch() | Found account : ' + acc.Id + ' with note : ' + iSatisfactionCdeNote);
                  
                  if(acc.AccountNumber == sAccountNumber){
                      acc.SatisfactionCdeNote__c = iSatisfactionCdeNote; 
                      acc.SatisfactionCdeOrigine__c=sSatisfactionCdeOrigine;
                      acc.SatisfactionCdeDate__c = date.today();//date.today().format();
                  }
                 
                  
                  lAccountsToUpdate.add(acc);
                  
              }
          }
          
                    
          if(lAccountsToUpdate.size() > 0){
              try {
                  update lAccountsToUpdate;
                  
                  returnResponse = 'optoutOK';
                  returnMessage = 'Note ok';
              } catch (DmlException e) {
                  System.debug('The following exception has occurred: ' + e.getMessage());
                  returnResponse = 'optoutNOK';
                  returnMessage = 'note ko';
              }
          }else{
              returnResponse = 'optoutNOTFOUND';
              returnMessage = 'MESSAGE_NOTFOUND';
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