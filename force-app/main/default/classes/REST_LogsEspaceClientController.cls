@RestResource(urlMapping='/v.1/logsEspaceClient/*')
global with sharing class REST_LogsEspaceClientController {
    
    static final String CONN_TYPE_REGISTRATION = '0';
    static final String CONN_TYPE_CONNECTION = '1';
    
    @HttpPatch
    //global static List<String> doPatch(){
    global static Result doPatch(String ConnectionType, String AccountNumber){
    //global static Result doPatch(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;


        String recordFound = '';
        List<Account> lAccountsToUpdate = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        Boolean cnxTypeOutOfBound = false;
        
        /*String ConnectionType = req.params.get('ConnectionType');
        String AccountNumber = req.params.get('AccountNumber');
        System.debug(logginglevel.WARN, 'REST_LogsEspaceClientController.doPatch() | ConnectionType : ' + ConnectionType);
        System.debug(logginglevel.WARN, 'REST_LogsEspaceClientController.doPatch() | AccountNumber : ' + AccountNumber);*/
        
        
        List<Account> foundAccounts = [SELECT Id, 
                                            Espace_Client_Registration_Date__c, 
                                            Espace_Client_Last_Login_Date__c, 
                                            Espace_Client_Login_Count__c
                                       FROM Account 
                                       WHERE ExternalID__c = :AccountNumber
                                       LIMIT 1 ];  
                                         
        if( foundAccounts.size() > 0 ) {
            for (Account acc : foundAccounts) {
                
                System.debug(logginglevel.WARN, 'REST_LogsEspaceClientController.doPatch() | Found account : ' + acc.Id);
                
                if(ConnectionType == CONN_TYPE_REGISTRATION){
                    acc.Espace_Client_Registration_Date__c = system.now();
                }else if(ConnectionType == CONN_TYPE_CONNECTION){
                    acc.Espace_Client_Last_Login_Date__c = system.now();
                    // If Registration Date has never been set, we set it because a connection means the customer has already registered
                    if(acc.Espace_Client_Registration_Date__c == null){
                        acc.Espace_Client_Registration_Date__c = system.now();
                    }
                }else{
                    // Connection type out of bound
                    cnxTypeOutOfBound = true;
                }
                
                if(!cnxTypeOutOfBound){
                    acc.Espace_Client_Login_Count__c = acc.Espace_Client_Login_Count__c == null ? 1 : acc.Espace_Client_Login_Count__c + 1;
                    lAccountsToUpdate.add(acc);
                }
                
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
        }else if(cnxTypeOutOfBound){
            returnResponse = 'cnxTypeOutOfBound';
            returnMessage = 'Connection type out of bound.';
        }else{
            returnResponse = 'NotFound';
            returnMessage = 'Customer not found.';
        }
        
        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage;

        // Log API request and response
        Map<String, String> mParams = new Map<String, String>();
        mParams.put('ConnectionType', ConnectionType);
        mParams.put('AccountNumber', AccountNumber);

        //string sResponse = 'response:' + resultToReturn.response + ', message:' + resultToReturn.message;
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, mParams /*req.params*/, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }
    
}