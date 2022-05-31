@RestResource(urlMapping='/v.1/paymentSpreadAmendment/*')
global with sharing class REST_PaymentSpreadAmendmentController {

    //static final String CONN_TYPE_REGISTRATION = '0';
    //static final String CONN_TYPE_CONNECTION = '1';

    // WS Parameters :
    // campMember : CampaignMember.Id from SalesForce
    // paymentSpread : 3 or 10 for owners, 3 for renters
    // mobilePhoneNumber : Mobile Phone Number (can be '' if not filled on the landing page)
    // savePhone : Y or N depending on the radiobutton selected by the client on the landing page
    
    @HttpPost
    //global static List<String> doPatch(){
    global static Result doPost(String campMember, String paymentSpread, String mobilePhoneNumber, String savePhone){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;


        //String recordFound = '';
        List<CampaignMember> lCampMembersToUpdate = new List<CampaignMember>();
        String returnResponse = '';
        String returnMessage = '';
        Boolean paymentSpreadOutOfBound = false;
        String resSignea = '';
        String accountIdToUpdate = '';
        List<Account> lAccountsToUpdate = new List<Account>();
        //String mobilePhone = '';
        
        /*String ConnectionType = req.params.get('ConnectionType');
        String AccountNumber = req.params.get('AccountNumber');
        System.debug(logginglevel.WARN, 'REST_LogsEspaceClientController.doPatch() | ConnectionType : ' + ConnectionType);
        System.debug(logginglevel.WARN, 'REST_LogsEspaceClientController.doPatch() | AccountNumber : ' + AccountNumber);*/
        
        
        List<CampaignMember> foundCampMember = [SELECT Id, Contact.AccountId, Contact.Account.Mobile_Phone_Number__c
                                                   FROM CampaignMember 
                                                   WHERE Id = :campMember
                                                   LIMIT 1 ];
        
        // Update phone number on account if provided and if savePhone = Y
        if( foundCampMember.size() > 0 && mobilePhoneNumber != '' && savePhone == 'Y') {
            for (CampaignMember cm : foundCampMember) {
                //if(mobilePhoneNumber != ''){
                    accountIdToUpdate = cm.Contact.AccountId;
                //}
            }

            List<Account> foundAccount = [SELECT Id, Mobile_Phone_Number__c
                                                   FROM Account 
                                                   WHERE Id = :accountIdToUpdate
                                                   LIMIT 1 ];
            if( foundAccount.size() > 0 ) {
                for (Account acc : foundAccount) {
                    acc.Mobile_Phone_Number__c = mobilePhoneNumber;
                    lAccountsToUpdate.add(acc);
                }

                try {
                    update lAccountsToUpdate;
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
        
        if( foundCampMember.size() > 0 ) {
            for (CampaignMember cm : foundCampMember) {
                
                System.debug(logginglevel.WARN, 'REST_PaymentSpreadAmendmentController.doPost() | Found CampaignMember : ' + cm.Id);
                
                if(paymentSpread == '3' || paymentSpread == '10'){
                    // Update CampaignMember status     /!\ Keep there or move to ProcessDataForSigneaFromCampaign method ?
                    cm.Status = 'Responded';
                    lCampMembersToUpdate.add(cm);
                    // Call method to start the Signea process
                    //if (savePhone == 'Y') mobilePhone = ''; else mobilePhone = mobilePhoneNumber;
                    resSignea = VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign(cm.Id, paymentSpread);
                    if(resSignea.startsWith('000')){
                        //ok
                        accountIdToUpdate = cm.Contact.AccountId;
                    }else if(resSignea.startsWith('ENC')){
                        //Circuit déjà en cours
                        System.debug('The following exception has occurred: ' + resSignea);
                        returnResponse = 'ENC';
                        returnMessage = resSignea.substring(6);
                    }else{
                        //nok
                        System.debug('The following exception has occurred: ' + resSignea);
                        returnResponse = 'NOK';
                        returnMessage = 'Error : ' + resSignea;
                    }
                }else{
                    // If paymentSpread value is different than the values expected, this is an issue
                    paymentSpreadOutOfBound = true;
                    returnResponse = 'paymentSpreadOutOfBound';
                    returnMessage = 'Payment spread out of bound.';
                }
                
            }
        }else{
            returnResponse = 'NotFound';
            returnMessage = 'Campaign member not found.';
        }
        
        if(lCampMembersToUpdate.size() > 0 && returnResponse == ''){
            try {
                update lCampMembersToUpdate;
                returnResponse = 'OK';
                returnMessage = 'Processing circuit.';
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                returnResponse = 'NOK';
                returnMessage = 'Error : ' + e.getMessage();
            }
        }
        
        

        Result resultToReturn = new Result();
        resultToReturn.response = returnResponse == '' ? '' : returnResponse;
        resultToReturn.message = returnMessage == '' ? '' : returnMessage;

        // Log API request and response
        Map<String, String> mParams = new Map<String, String>();
        mParams.put('campMember', campMember);
        mParams.put('paymentSpread', paymentSpread);
        mParams.put('mobilePhoneNumber', mobilePhoneNumber);
        mParams.put('savePhone', savePhone);

        //string sResponse = 'response:' + resultToReturn.response + ', message:' + resultToReturn.message;
        RestApiLogging.logRestApiCall(req.headers, req.httpMethod, mParams /*req.params*/, req.remoteAddress, req.requestBody, req.requestURI, req.resourcePath, JSON.serializePretty(resultToReturn));

        return resultToReturn;
    }
    
    global class Result {
        global String response{get;set;}
        global String message{get;set;}
    }

}