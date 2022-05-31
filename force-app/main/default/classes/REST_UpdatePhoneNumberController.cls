@RestResource(urlMapping='/v.1/updatePhoneNumber/*')
global with sharing class REST_UpdatePhoneNumberController {
    
    @HttpPatch
    global static Result doPatch(String ptlNumber, String phoneNumber){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;


        String recordFound = '';
        List<PTL__c> lPTLsToUpdate = new List<PTL__c>();
        List<Account> lAccountsToUpdate = new List<Account>();
        String returnResponse = '';
        String returnMessage = '';
        Boolean actdomOutOfBound = false;
        
        
        // Check phone number not empty and 10 characters long
        if( String.isBlank(phoneNumber) || phoneNumber.length() != 10 ){
            returnResponse = 'badPhone';
            returnMessage = 'Phone empty or in wrong format.';
        }else{
            
            List<PTL__c> foundPTLs = [SELECT Id, 
                                                Phone__c,
                                                Mobile_Phone_Number__c, 
                                                Activity_Domain__r.ExternalID__c,
                                                Account_DO__c
                                           FROM PTL__c 
                                           WHERE Name = :ptlNumber
                                           LIMIT 1 ];
            
            
            if( foundPTLs.size() > 0 ) {
                for (PTL__c ptl : foundPTLs) {
                    
                    System.debug(logginglevel.WARN, 'REST_UpdatePhoneNumberController.doPatch() | Found ptl : ' + ptl.Id);
                    
                    // For activity domain GEB : Update both the PTL and its parent account
                    if(ptl.Activity_Domain__r.ExternalID__c == 41){
                        
                        Account relatedAccount = new Account(Id=ptl.Account_DO__c);
                        
                        if( phoneNumber.startsWith('06') || phoneNumber.startsWith('07') ){
                            ptl.Mobile_Phone_Number__c = phoneNumber;
                            relatedAccount.Mobile_Phone_Number__c = phoneNumber;
                        }else{
                            ptl.Phone__c = phoneNumber;
                            relatedAccount.Phone = phoneNumber;
                        }
                        lAccountsToUpdate.add(relatedAccount);
                        
                    // For activity domain GEC : Update the PTL only
                    }else if(ptl.Activity_Domain__r.ExternalID__c == 42){
                        if( phoneNumber.startsWith('06') || phoneNumber.startsWith('07') ){
                            ptl.Mobile_Phone_Number__c = phoneNumber;
                        }else{
                            ptl.Phone__c = phoneNumber;
                        }
                    }else{
                        // Activity domain out of bound
                        actdomOutOfBound = true;
                    }
                    
                    if(!actdomOutOfBound){
                        lPTLsToUpdate.add(ptl);
                    }
                    
                }
            }
            
            if(lPTLsToUpdate.size() > 0){
                try {
                    update lPTLsToUpdate;
                    update lAccountsToUpdate;
                    returnResponse = 'OK';
                    returnMessage = 'Data saved.';
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    returnResponse = 'NOK';
                    returnMessage = 'Error : ' + e.getMessage();
                }
            }else if(actdomOutOfBound){
                returnResponse = 'actdomOutOfBound';
                returnMessage = 'Activity domain out of bound.';
            }else{
                returnResponse = 'NotFound';
                returnMessage = 'PTL not found.';
            }
        }
        
        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage;
        
        // Log API request and response
        Map<String, String> mParams = new Map<String, String>();
        mParams.put('ptlNumber', ptlNumber);
        mParams.put('phoneNumber', phoneNumber);
        
        //string sResponse = 'response:' + resultToReturn.response + ', message:' + resultToReturn.message;
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, mParams /*req.params*/, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }
    
}