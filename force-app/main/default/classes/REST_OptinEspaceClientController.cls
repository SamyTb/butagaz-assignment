@RestResource(urlMapping='/v.1/OptinEspaceClient/*')
global with sharing class REST_OptinEspaceClientController {
    
 
    @HttpGet
    global static Account doGet() {
       
   //   global static String doGet() {  
        boolean bOptin1 = false;
        boolean bOptin2 = false;
        boolean bOptin3 = false;

        RestRequest req = RestContext.request;

        RestResponse res = RestContext.response;

        String AccountNumber= req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String ResultEC  ='' ;

        Account result = [SELECT Id, ExternalID__c ,Optin_1__c, Optin_2__c,Optin_Partenaires__c
                          FROM Account 
                          WHERE ExternalID__c = :AccountNumber];
                          
                          
                          if(result.Optin_1__c==false)
                          {
                              result.Optin_1__c = true;
                          }else
                          {
                              result.Optin_1__c = false;
                          }
                          
                          if(result.Optin_2__c==false)
                          {
                              result.Optin_2__c = true;
                          }else
                          {
                              result.Optin_2__c = false;
                          }
                          
                          if(result.Optin_Partenaires__c==false)
                          {
                              result.Optin_Partenaires__c = true;
                          }else
                          {
                              result.Optin_Partenaires__c = false;
                          }
         
        //ResultEC ='{"Id":"'+result.id+'","ExternalID__c":"'+result.ExternalID__c +'","Optin_1__c":'+bOptin1+' //,"Optin_2__c":'+bOptin2+',"Optin_Partenaires__c":'+bOptin3+' }';
        //return ResultEC ;
        return result ;
        
        }
        
        
    
    @HttpPost
    global static Result doPost( String AccountNumber, boolean Optin1, boolean Optin2, boolean Optin3, String Email1, String Email2){
   
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;


        String recordFound = '';
        List<Account> lAccountsToUpdate = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        Boolean cnxTypeOutOfBound = false;
        boolean bOptin1 = false;
        boolean bOptin2 = false;
        boolean bOptin3 = false;
        
        if (Optin1==false)
        {
        bOptin1 = true;
        }else
        {
        bOptin1 = false;
        }  

        if (Optin2==false)
        {
        bOptin2 = true;
        }else
        {
        bOptin2 = false;
        }  


        if (Optin3==false)
        {
        bOptin3 = true;
        }else
        {
        bOptin3 = false;
        }       
        
        List<Account> foundAccounts = [SELECT Id, 
                                            Optin_1__c, 
                                            Optin_2__c, 
                                            Optin_Partenaires__c, Email__c, Email_2__c,No_E_mail__c
                                       FROM Account 
                                       WHERE ExternalID__c = :AccountNumber
                                       LIMIT 1 ];  
                                         
        if( foundAccounts.size() > 0 ) {
            for (Account acc : foundAccounts) {
  
                acc.Optin_1__c=bOptin1;
                acc.Optin_2__c=bOptin2; 
                acc.Optin_Partenaires__c=bOptin3;
                acc.Email__c = Email1;
                acc.Email_2__c = Email2;
                
                if((Email1!='' && Email1!=null)||(Email2!='' && Email2!=null))
                	acc.No_E_mail__c= false; 
                lAccountsToUpdate.add(acc);
                
            }
            
             
        }
        
        if(lAccountsToUpdate.size() > 0){
            try {
                update lAccountsToUpdate;
                returnResponse = 'OK';
                returnMessage = 'Data saved.';
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                returnResponse = 'NOK';
                returnMessage = 'Error : ' + e.getMessage();
            }
        
        }else{
            returnResponse = 'NotFound';
            returnMessage = 'Customer not found.' + foundAccounts.size();
        }
        
        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage;

        // Log API request and response
        Map<String, String> mParams = new Map<String, String>();
        mParams.put('AccountNumber', AccountNumber);

       //         RestApiLogging.logRestApiCall(req.headers, req.httpMethod, mParams , req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }
    
}