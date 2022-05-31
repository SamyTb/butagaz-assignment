public class Dolead_CalloutMgr {

    public Dolead_CalloutMgr() {

    }

    @future (callout = true)
    public static void callDoleadCustomerConversionsWS(Id sourceId, string sourceExtId, string sourceStatus) {
        
        String endpoint = '';
        String status = '';
        String returnValue = '';
        String objectType = '';
        String reasonForClosedLost = '';
        Dolead_API_Settings__mdt cDoleadAPI;

        
        cDoleadAPI = getDoleadAPISettings();

        // If we arrive from the Opty, we need to query the Lead_ExternalID__c field from the account
        if( (sourceExtId == null || sourceExtId == '') && sourceId.getSObjectType() == Opportunity.sObjectType ){
            List<Opportunity> lOpty = [SELECT Id, Account.Lead_ExternalID__c, StageName, Reason_for_Closed_Lost__c FROM Opportunity WHERE id = :sourceId LIMIT 1];
            for(Opportunity oOpty : lOpty){
                if(oOpty.Account != null && oOpty.Account.Lead_ExternalID__c != null){
                    sourceExtId = oOpty.Account.Lead_ExternalID__c;
                    reasonForClosedLost = oOpty.Reason_for_Closed_Lost__c;
                }
            }
        }
        System.debug(logginglevel.WARN,'### sourceExtId : ' + sourceExtId);
        if( (sourceExtId == null || sourceExtId == '') ) return;
        
        // Get object type to build the request accordingly
        if( sourceId.getSObjectType() == Lead.sObjectType ){
            objectType = 'Lead'; 
        } else if( sourceId.getSObjectType() == Opportunity.sObjectType ){
            objectType = 'Opportunity'; 
        }
        
        
        // Set the endpoint
        endpoint = cDoleadAPI.Dolead_API_Conversion_Endpoint__c;
        
        //String leadInfo = '[[{"lead_id": "form_59771b74c938b1.46776754"}, {"customer_contacted": true, "customer_sale_fail_reason": "unreachable", "customer_sql": true, "customer_sale": false}]]';
        //leadInfo += '';

        //String leadInfo = '[[{"lead_id": "form_59771b74c938b1.46776754"}, {"customer_contacted": true, "customer_sale_fail_reason": "unreachable", "customer_sql": true, "customer_sale": false}]]';
        
        String leadInfo = getRequestConversions(objectType, sourceExtId, sourceStatus, reasonForClosedLost);
        
        // Set the payload
        String payLoad = 'grant_type=password' 
            + '&login=' + EncodingUtil.urlEncode(cDoleadAPI.Dolead_API_Conversion_User__c,'UTF-8') 
            + '&password=' + EncodingUtil.urlEncode(cDoleadAPI.Dolead_API_Conversion_Password__c, 'UTF-8') 
            + '&conversions=' + EncodingUtil.urlEncode(leadInfo, 'UTF-8');
        
        /*
            conversions='[
            [
                {
                    "lead_id": "form_59771b74c938b1.46776754"
                },
                {
                    "customer_contacted": true,
                    "customer_sale_fail_reason": "unreachable",
                    "customer_sql": true,
                    "customer_sale": false
                }
            ],
            [
                {
                    "lead_id": "form_5977198b037614.02218067"
                },
                {
                    "customer_contacted": true,
                    "customer_sale": true,
                    "customer_turnover": 59.14
                }
            ]
        ]'
        */
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(payload);
        req.setMethod('POST');
        HTTPResponse res = h.send(req); 
        
        if(res.getStatusCode()==200){
            returnValue = res.getBody();
            System.debug('### returnValue = ' + returnValue);
            
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            if(results.get('result') == 'success'){
                System.debug(logginglevel.WARN,'### Result successfull : ' + res.getBody());
            }else{
                System.debug(logginglevel.WARN,'### Result unsuccessfull : ' + res.getBody());
            }

            logRestApiCallout(req.getHeader('Content-Type'), req.getMethod(), '', 'DoleadCustomerConversions', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());


            /*responseBody oResponseBody = (responseBody)JSON.deserializeStrict(res.getBody(), responseBody.class);
            System.debug('### oResponseBody = ' + oResponseBody);
            
            if(oResponseBody.result != 'success') {
                logRestApiCallout(req.getHeader('Content-Type'), req.getMethod(), '', 'DoleadCustomerConversions', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
            }else{
                logRestApiCallout(req.getHeader('Content-Type'), req.getMethod(), '', 'DoleadCustomerConversions', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
            }*/
            
            
        } else {
            //System.debug(logginglevel.WARN,'### res.getStatusCode() = ' + res.getStatusCode() + ' - ' + res.getStatus());
            logRestApiCallout(req.getHeader('Content-Type'), req.getMethod(), '', 'DoleadCustomerConversions', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        }
        
    }
    
    //public static Map<String, String> getFailReason() {
        /*
         * Dolead
         * invalid_number
         * invalid_email
         * unreachable
         * no_project
         * project_already_done
         * wrong_category
         * accepted_another_offer
         * refused_of 
         * 
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
    
    
    public static void logRestApiCallout(string header, string httpMethod, string params, string remoteAddress, Blob requestBody, string requestURI, string resourcePath, Blob response){

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
    
    /*public class responseBody {
        public String result;
        public Details details;
    }

    public class Details {
        public List<Success> success;
        public List<Success> failure;
    }

    public class Success {
    }

    public class Failure {
    }*/

    // Get Dolead API settings
    public static Dolead_API_Settings__mdt getDoleadAPISettings() {
        
        List<Dolead_API_Settings__mdt> lDoleadAPI = [ select Dolead_API_Conversion_Endpoint__c, Dolead_API_Conversion_User__c, Dolead_API_Conversion_Password__c
                                            from Dolead_API_Settings__mdt
                                            limit 1
                                            ];
        
        if(lDoleadAPI.size() == 0){
            System.debug('### No Dolead API settings defined');
            return null;
        }
        
        System.debug('### lDoleadAPI[0] = ' + lDoleadAPI[0]);
        return lDoleadAPI[0];
    }

    // Build request conversions
    public static String getRequestConversions(String ObjectType, string sourceExtId, string sourceStatus, String reasonForClosedLost) {
        
        String requestConversions = '';
        /*
        conversions='[
                [
                    {
                        "lead_id": "form_59771b74c938b1.46776754"
                    },
                    {
                        "customer_contacted": true,
                        "customer_sale_fail_reason": "unreachable",
                        "customer_sql": true,
                        "customer_sale": false
                    }
                ],
                [
                    {
                        "lead_id": "form_5977198b037614.02218067"
                    },
                    {
                        "customer_contacted": true,
                        "customer_sale": true,
                        "customer_turnover": 59.14
                    }
                ]
            ]'
        */
        
        requestConversions = '[[{"lead_id": "' + sourceExtId + '"},{';

        if(ObjectType == 'Lead'){
            
            for(Lead oLead: [ select ID, Status, isConverted, (select ID, CreatedDate from ActivityHistories order by CreatedDate asc limit 1) 
                from Lead 
                where ExternalID__c =:sourceExtId ])
            {
                
                // Check if lead has been contacted
                if(oLead.ActivityHistories.size() > 0){
                    requestConversions += '"customer_contacted": true, "customer_contacted_at": "' + oLead.ActivityHistories[0].CreatedDate + '",';
                } else {
                    requestConversions += '"customer_contacted": false,';
                }
                
                // Check if lead has been abandoned
                if(oLead.Status == 'Abandoned'){
                    requestConversions += '"customer_sale_fail_reason": "other", "sub_status": "' + oLead.Status + '", "customer_sql": false,';
                } else {
                    //requestConversions += '"customer_sql": false, ';
                }

                // Check if lead has been converted
                if(oLead.isConverted){
                    requestConversions += '"customer_sql": true, "customer_contacted": true,';
                } else {
                    //requestConversions += '"customer_sql": false, ';
                }

                System.debug('### requestConversions1 = ' + requestConversions);
                requestConversions = requestConversions.removeEnd(',');
                System.debug('### requestConversions2 = ' + requestConversions);
            }
        
        } else if(ObjectType == 'Opportunity'){
            // Check if the opportunity has been won or lost
            if(sourceStatus == 'Closed Won'){
                requestConversions += '"customer_sale": true, "customer_contacted": true ';
            }else if(sourceStatus == 'Closed Lost'){
                requestConversions += '"customer_sale": false, "customer_sale_fail_reason": "other", "sub_status": "' + reasonForClosedLost + '", "customer_contacted": true ';
            }
        }

        
        requestConversions += '}]]';

        System.debug('### requestConversions = ' + requestConversions);


        /*
        Lead contacté :
        "customer_contacted": true
        "customer_contacted_at": "2011-03-21T00:18:56Z"


        Lead abandonné avant contact :
        "customer_contacted": false
        "customer_sale_fail_reason": "unreachable"
        "customer_sql": false


        Lead abandonné après contact :
        "customer_contacted": true
        "customer_contacted_at": "2011-03-21T00:18:56Z"
        "customer_sale_fail_reason": "refused_offer"
        "customer_sql": false


        Lead converti :
        "customer_contacted": true
        "customer_contacted_at": "2011-03-21T00:18:56Z"
        "customer_sql": true


        Opportunité gagnée :
        "customer_contacted": true
        "customer_contacted_at": "2011-03-21T00:18:56Z"
        "customer_sql": true
        "customer_sale": true


        Opportunité perdue :
        "customer_contacted": true
        "customer_contacted_at": "2011-03-21T00:18:56Z"
        "customer_sql": true
        "customer_sale": false
        "customer_sale_fail_reason": "accepted_another_offer"
        */

        /* 20211110 : Set customer_sale_fail_reason to "other" and set the fail reason in new field sub_status
            "customer_sale_fail_reason": "other", 
            "sub_status": "Abandoned"
        */

        return requestConversions;
    }

}