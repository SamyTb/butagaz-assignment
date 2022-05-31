public class Comparator_CalloutMgr {
    
    Static Custom_Settings__c Comparator_Endpoint = Custom_Settings__c.getValues('Comparator_Endpoint');
    public static Map<String, Comparator_Status_Mapping__c> comparatorStatusCodeMap = Comparator_Status_Mapping__c.getAll();
    
    @future (callout = true)
    public static void callComparatorWS(Id sourceId, string sourceExtId, string sourceStatus) {
        
        String endpoint = '';
        String status = '';
        String returnValue = '';
        
        //String sourceExtId = 'cmp-001169';
        //String sourceStatus = 'New';
        
        // If we arrive from the Opty, we need to query the Lead_ExternalID__c field from the account
        if( (sourceExtId == null || sourceExtId == '') && sourceId.getSObjectType() == Opportunity.sObjectType ){
            List<Opportunity> lOpty = [SELECT Id, Account.Lead_ExternalID__c FROM Opportunity WHERE id = :sourceId LIMIT 1];
            for(Opportunity oOpty : lOpty){
                if(oOpty.Account != null && oOpty.Account.Lead_ExternalID__c != null){
                    sourceExtId = oOpty.Account.Lead_ExternalID__c;
                }
            }
        }
        System.debug(logginglevel.WARN,'### sourceExtId : ' + sourceExtId);
        if( (sourceExtId == null || sourceExtId == '') ) return;
        
        
        // Construct a status matrix to match SFDC and Comparator status
        status = getStatusCode(sourceStatus);
        System.debug(logginglevel.WARN,'### status: ' + status);
        if(status == '') {
            // log an error if status not found in Custom Settings ?
            //logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Comparateur', null, req.getEndpoint(), '', res.getBodyAsBlob());
        }else {
            
            // Set the endpoint
            endpoint = String.format(Comparator_Endpoint.value__c, new String[]{sourceExtId, status});
            
            // Perform the callout
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint(endpoint);
            req.setHeader('contentType', 'application/json');
            req.setHeader('Content-Length', '0');
            req.setMethod('POST');
            HTTPResponse res = h.send(req); 
            
            if(res.getStatusCode()==200){
                returnValue = res.getBody();
                
                responseBody oResponseBody = (responseBody)JSON.deserializeStrict(res.getBody(), responseBody.class);
                
                if(oResponseBody.status != '200') {
                    logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Comparateur', null, req.getEndpoint(), '', res.getBodyAsBlob());
                }
                
            } else {
                //System.debug(logginglevel.WARN,'### res.getStatusCode() = ' + res.getStatusCode() + ' - ' + res.getStatus());
                logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Comparateur', null, req.getEndpoint(), '', res.getBodyAsBlob());
            }
            
        }
        
    }
    
    //public static Map<String, String> getStatusCode() {
        /*
         * Extranet Comparateur
         * Devis en cours : 2 
         * Gagnée : 8
         * Perdu : 9 
         */
    /*    return new Map<String,String> {
            // Lead Status
            'Abandoned' => '9',
            'Postponed' => '9',
            // Opty Stage
            'Prospecting' => '2',
            //'Needs analysis' => '2',
            //'Negotiation/Review' => '2',
            'Closed Won' => '8',
            'Closed Lost' => '9'
        };
    }*/
    
    public static String getStatusCode(String statusName){
        if(comparatorStatusCodeMap !=null && comparatorStatusCodeMap.containsKey(statusName)) {
            return comparatorStatusCodeMap.get(statusName).value__c;
        }else { 
            return '';
        }
    }
    
    public static void logRestApiCallout(string header, string httpMethod, string params, string remoteAddress, Blob requestBody, string requestURI, string resourcePath, Blob response){
        //System.debug(logginglevel.WARN,'### logRestApiCall');

        String sLogCall = AP_PricingUtilities.getCustomSettingValue('TrackRestAPICalls');

        if(sLogCall == 'true'){
            Rest_API_Log__c oRestAPILog = new Rest_API_Log__c(
                Request_Header__c = header,
                Request_HttpMethod__c = httpMethod,
                Request_Params__c = params,
                Request_Remote_Address__c = remoteAddress,
                Request_Body__c = requestBody == null ? '' : requestBody.toString(),
                Request_URI__c = requestURI,
                Request_Resource_Path__c = resourcePath,
                Response__c = response == null ? '' : response.toString()
            );
            insert oRestAPILog;
        }
    }
    
    public class responseBody {
        public String status;
        public String detail;
    }

    
}