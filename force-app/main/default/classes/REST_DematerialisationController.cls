@RestResource(urlMapping='/v.1/Dematerialisation/*')
global with sharing class REST_DematerialisationController {
    
   //// @HttpPatch
    //global static List<String> doPatch(){
   // global static Result doPatch(){
  ////  global static Result doPatch(String sMail1, String sMail2){
  
   @HttpPost
    //global static List<String> doPatch(){
    global static Result doPost(String sMail1, String sMail2, Boolean bModeDemat){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recordFound = '';
        List<Account> lAccountsToUpdate = new List<Account>();
          List<Account> foundAccounts  = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        String Passe = '';
        String AccMail= '';
        String MESSAGE_OK = '' ;
        
        
        if (bModeDemat==true)
        {
        MESSAGE_OK = Label.REST_DematerialisationController_Message_OK;
        }
        else
        {
        MESSAGE_OK = Label.REST_DematerialisationControllerOptin_Message_OK;
        }
     
        
       // String MESSAGE_OK = Label.REST_DematerialisationController_Message_OK;
        String MESSAGE_ERROR = Label.REST_EmailOptoutController_Message_Error;
        String MESSAGE_NOTFOUND = Label.REST_EmailOptoutController_Message_NotFound;
        String MESSAGE_NOEMAIL = Label.REST_EmailOptoutController_Message_NoEmail;
        
        String sMailAll= ''; 
        String sMail = '';
       
       if ( sMail1 != '' &&  sMail2 ==''  )  
       {
           sMail = sMail1 ;       
       }
            
   
        
        if (  sMail1 != '' &&  sMail2 !='' )  
        {
             sMail = '' ;
             sMail1 = sMail1 ;
             sMail2 = sMail2 ;
        }    
       
    
       
        if (sMail1 == '' &&  sMail2 ==''){
            returnResponse = 'optoutNOEMAIL';
            returnMessage = MESSAGE_NOEMAIL;
        }
        
        else 
        {
           
              
              if (sMail != '' )
              {
              
                 foundAccounts =  [select Id, Email__c, Demat1_chorus__c, Email_2__c, Demat2_chorus__c 
                                          FROM Account 
                                          WHERE Email__c = :sMail OR Email_2__c = :sMail ];  
              
              }
              
        
              else  
              {
              
         
              
                  foundAccounts = [select Id, Email__c, Demat1_chorus__c, Email_2__c, Demat2_chorus__c 
                                              FROM Account 
                                              WHERE Email__c = :sMail1 AND Email_2__c = :sMail2 ];  
              
              }
                            
                                           
          if( foundAccounts.size() > 0 ) {
              for (Account acc : foundAccounts) {
                  
                  System.debug(logginglevel.WARN, 'DematerialisationRestService.doPatch() | Found account : ' + acc.Id + ' with email : ' + sMail);
                  System.debug(logginglevel.WARN, 'DematerialisationRestService.doPatch() | Found account : ' + acc.Id + ' with email2 : ' + sMail2);
                  
              
             
            
                
                if(sMail != '')
                {
                   if (acc.Email__c==sMail)
                  {
                      acc.Demat1_chorus__c = bModeDemat; //True; 
                      Passe = 'mail1';
                      AccMail = acc.Email_2__c;
                  }
                  
                  if (acc.Email_2__c==sMail)
                
                  {
                      acc.Demat2_chorus__c = bModeDemat; // True; 
                      Passe = 'mail2';
                      AccMail = acc.Email_2__c;
                  }
                
                }
                
                
               //  if ( sMail1 != '' &&  sMail2 !=''  )  
                if(sMail == '' )
               {
                   if ( acc.Email__c == sMail1 && acc.Email_2__c== sMail2)
                   {
                      acc.Demat1_chorus__c = bModeDemat; //True; 
                      acc.Demat2_chorus__c = bModeDemat; //True; 
                       AccMail = acc.Email_2__c;
                  }
                }
                
                  
                  lAccountsToUpdate.add(acc);
                 
              }
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
              returnMessage = MESSAGE_NOTFOUND    ;
          }
        }
        
        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse ;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage ;

 // Log API request and response
        Map<String, String> mParams = new Map<String, String>();
        mParams.put('sMail1', sMail1);
        mParams.put('sMail2', sMail2);

    // Log API request and response
    //    RestApiLogging.logRestApiCall(req.headers, req.httpMethod, req.params, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));
 RestApiLogging.logRestApiCall(req.headers, req.httpMethod, mParams /*req.params*/, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));
        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }
    
}