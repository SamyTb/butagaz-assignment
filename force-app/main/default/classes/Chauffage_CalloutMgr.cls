public class Chauffage_CalloutMgr {
    
    
    public Chauffage_CalloutMgr() {

    }

    // Call API to get session token
    public static apiResponse callGetToken(Chauffage_API_Settings__mdt pChauffageAPI) {
        
        String endpoint = '';
        String response = '';
        String resBody = '';
        tokenResponseBodyGARANKA oTokenResponseBodyGARANKA;
        tokenResponseBodyMENERGIES oTokenResponseBodyMENERGIES;

        apiResponse responseToReturn = new apiResponse();
        
        
        if( pChauffageAPI == null ) return null;
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(pChauffageAPI.Get_Token_Endpoint__c);
        req.setMethod('POST');
        
        Map<String, Object> parameters;
        String payLoad = '';
        if(pChauffageAPI.DeveloperName == 'GARANKA'){
            // Parameters need to be url-encoded for GARANKA
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            payLoad = 'grant_type=client_credentials' 
                            + '&client_id=' + EncodingUtil.urlEncode(pChauffageAPI.ClientId__c,'UTF-8') 
                            + '&client_secret=' + EncodingUtil.urlEncode(pChauffageAPI.ClientSecret__c, 'UTF-8');
            
            req.setBody(payLoad);
        }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
            // Parameters are not url-encoded for MENERGIES
            req.setHeader('Content-Type', 'application/json');

            parameters = new Map<String, Object>{
                'username' => pChauffageAPI.UserName__c,
                'password' => pChauffageAPI.Password__c
            };

            req.setBody(JSON.serialize(parameters));
        }
        System.debug(logginglevel.WARN,'### payLoad = ' + payLoad);
        System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        
        System.debug(logginglevel.WARN,'### req = ' + req);
        
        //HTTPResponse res = h.send(req);
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            try {
                res = h.send(req);
            } catch(System.CalloutException e) {
                responseToReturn.hasError = true;
                //responseToReturn.successMessage = '';
                responseToReturn.errorMessage = e.getMessage();
                return responseToReturn;
            }
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                resBody = '{"access_token": "XXXXX","expires_in": 3600,"token_type": "Bearer","scope": "basic"}';
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                resBody = '{"token": "XXXXX"}';
            }
            res.setBody(resBody);
        }
        
        if(res.getStatusCode() == 200){
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                oTokenResponseBodyGARANKA = (tokenResponseBodyGARANKA)JSON.deserializeStrict(res.getBody(), tokenResponseBodyGARANKA.class);
                if(oTokenResponseBodyGARANKA == null || oTokenResponseBodyGARANKA.access_token == '') {
                    responseToReturn.hasError = true;
                    responseToReturn.errorMessage = 'No Token found.';
                }else{
                    //response = oTokenResponseBodyGARANKA.access_token;
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = oTokenResponseBodyGARANKA.access_token;
                }
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                oTokenResponseBodyMENERGIES = (tokenResponseBodyMENERGIES)JSON.deserializeStrict(res.getBody(), tokenResponseBodyMENERGIES.class);
                if(oTokenResponseBodyMENERGIES == null || oTokenResponseBodyMENERGIES.token == '') {
                    responseToReturn.hasError = true;
                    responseToReturn.errorMessage = 'No Token found.';
                }else{
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = oTokenResponseBodyMENERGIES.token;
                }
            }
            System.debug(logginglevel.WARN,'### responseToReturn : ' + responseToReturn);
            
        } else {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('error') + ' - ' + results.get('error_description');
            }else{
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('code') + ' - ' + results.get('message');
            }
        }
        
        logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', pChauffageAPI.DeveloperName + ' - getToken', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        return responseToReturn;
    }

    // Call API to get customer eligibility from department and product (product needed only for GARANKA)
    public static apiResponse callGetEligibility(Chauffage_API_Settings__mdt pChauffageAPI, String pApiToken, String pPostalCode, String pProductCode) {
        
        String endpoint = '';
        String resBody = '';
        eligibilityResponseBodyGARANKA oEligibilityResponseBodyGARANKA;

        apiResponse responseToReturn = new apiResponse();
        
        if(pChauffageAPI.DeveloperName == 'GARANKA'){
            endpoint = String.format(pChauffageAPI.Get_Eligibility_Endpoint__c, new String[]{pPostalCode, pProductCode});
        }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
            endpoint = String.format(pChauffageAPI.Get_Eligibility_Endpoint__c, new String[]{pPostalCode});
        }
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + pApiToken);
        if(pChauffageAPI.DeveloperName == 'MENERGIES') req.setHeader('Accept', 'application/json');
        
        System.debug(logginglevel.WARN,'### endpoint = ' + endpoint);
        //System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        //System.debug(logginglevel.WARN,'### JSON.serialize(parameters) = ' + JSON.serialize(parameters));
        System.debug(logginglevel.WARN,'### req = ' + req);
        System.debug(logginglevel.WARN,'### req.getBody() = ' + req.getBody());
        System.debug(logginglevel.WARN,'### req.getHeader(Content-Type) = ' + req.getHeader('Content-Type'));
        System.debug(logginglevel.WARN,'### req.getHeader(Authorization) = ' + req.getHeader('Authorization'));
        
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            try {
                res = h.send(req);
            } catch(System.CalloutException e) {
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = e.getMessage();
                return responseToReturn;
            }
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                resBody = '{"response": true}';
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                resBody = '["oui"]';
            }
            res.setBody(resBody);
        }
        
        if(res.getStatusCode() == 200){
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                oEligibilityResponseBodyGARANKA = (eligibilityResponseBodyGARANKA)JSON.deserializeStrict(res.getBody(), eligibilityResponseBodyGARANKA.class);
                if(oEligibilityResponseBodyGARANKA == null || oEligibilityResponseBodyGARANKA.response == null) {
                    responseToReturn.hasError = true;
                    responseToReturn.errorMessage = 'Erreur lors de la vérification de l\'éligibilité auprès du partenaire GARANKA';
                }else{
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = (oEligibilityResponseBodyGARANKA.response == true ? 'true' : 'false');
                }
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){

                if(res.getBody() == null || res.getBody() == ''){
                    responseToReturn.hasError = true;
                    responseToReturn.errorMessage = 'Erreur lors de la vérification de l\'éligibilité auprès du partenaire MENERGIES';
                }else{
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = (res.getBody() == '["oui"]' ? 'true' : 'false');
                }
            }
            System.debug(logginglevel.WARN,'### responseToReturn : ' + responseToReturn);
            
        } else {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('code') + ' - ' + results.get('message');
            }else{
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('code') + ' - ' + results.get('message');
            }
        }
        
        logRestApiCallout(req.getHeader('Content-Type') + '-' + req.getHeader('Authorization'), req.getMethod(), '', pChauffageAPI.DeveloperName + ' - getEligibility', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        return responseToReturn;
    }

    // Call API to get booking time slots
    public static Map<String, Object> callGetBookingTimeSlots(Chauffage_API_Settings__mdt pChauffageAPI, String pApiToken, String pPostalCode) {
        
        String endpoint = '';
        Map<String, Object> response;
        

        endpoint = String.format(pChauffageAPI.Get_Booking_Time_Slots_Endpoint__c, new String[]{pPostalCode});

        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + pApiToken);
        System.debug(logginglevel.WARN,'### req = ' + req);
        
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            try {
                res = h.send(req);
            } catch(System.CalloutException e) {
                /*responseToReturn.hasError = true;
                responseToReturn.errorMessage = e.getMessage();*/
                return null;
            }
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            String resBody = '{"01-12-2020": ["8h-12h","14h-18h"],"03-12-2020": ["8h-12h","14h-18h"]}';
            res.setBody(resBody);
        }
        
        if(res.getStatusCode() == 200){
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());

            // Check used to manage no timesolts returned. In that case, the response returned by GARANKA is an empty collection with no key : []
            if(res.getBody().length() <= 2) return null;

            Map<String, Object> mapResult = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            response = mapResult;
        } else {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                /*responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('code') + ' - ' + results.get('message');*/
                System.debug(logginglevel.WARN,'### callGetBookingTimeSlots error : ' + results.get('code') + ' - ' + results.get('message'));
                return null;
            }else{
                //response = res.getStatusCode() + ' - ' + res.getStatus();
            }
        }
        
        logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', pChauffageAPI.DeveloperName + ' - getBookingTimeSlots', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        return response;
    }

    // Call API to post data to partner company
    public static apiResponse callPostData(Chauffage_API_Settings__mdt pChauffageAPI, String pApiToken, projectData pProjectData) {

        String endpoint = '';
        String response = '';
        String resBody = '';
        //postDataResponseBodyGARANKA oPostDataResponseBodyGARANKA;
        //tokenResponseBodyMENERGIES oTokenResponseBodyMENERGIES;
        
        apiResponse responseToReturn = new apiResponse();
        
        if( pChauffageAPI == null ) return null;
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(pChauffageAPI.Post_Data_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        if(pChauffageAPI.DeveloperName == 'MENERGIES') req.setHeader('Accept', 'application/json');
        //if(pChauffageAPI.DeveloperName == 'GARANKA'){
            req.setHeader('Authorization', 'Bearer ' + pApiToken);
        //}

        Map<String, Object> parameters;
        String payLoad = '';
        
        if(pChauffageAPI.DeveloperName == 'GARANKA'){
            parameters = new Map<String, Object>{
                'id_lead_source' => pProjectData.id_lead_source,
                'affilieur' => pProjectData.affilieur,
                'id_prod' => pProjectData.id_prod,
                'id_contrat' => pProjectData.id_contrat,
                //'code_postal' => pProjectData.code_postal,  //'54710', 
                'statut' => pProjectData.statut,
                'batiment' => pProjectData.batiment,
                'age' => pProjectData.age,
                'app' => pProjectData.app,
                'techno' => pProjectData.techno,
                'marque' => pProjectData.marque,
                'age_appareil' => pProjectData.age_appareil,
                'code_prix' => pProjectData.code_prix,
                'promo' => pProjectData.promo,
                'date_visite' => pProjectData.date_visite,
                'creneau_visite' => pProjectData.creneau_visite,
                'clt_situation' => pProjectData.clt_situation,
                'clt_position' => pProjectData.clt_position,
                'clt_civ' => pProjectData.clt_civ,
                'clt_nom' => pProjectData.clt_nom,
                'clt_prenom' => pProjectData.clt_prenom,
                'clt_email' => pProjectData.clt_email,
                'clt_telephone' => pProjectData.clt_telephone,
                'clt_adresse' => pProjectData.clt_adresse,
                'clt_adresse_cpl' => pProjectData.clt_adresse_cpl,
                'clt_adresse_cpl2' => pProjectData.clt_adresse_cpl2,
                'clt_cp' => pProjectData.clt_cp,
                'clt_ville' => pProjectData.clt_ville,
                'fct_civ' => pProjectData.fct_civ,
                'fct_nom' => pProjectData.fct_nom,
                'fct_prenom' => pProjectData.fct_prenom,
                'fct_email' => pProjectData.fct_email,
                'fct_telephone' => pProjectData.fct_telephone,
                'fct_adresse' => pProjectData.fct_adresse,
                'fct_adresse_cpl' => pProjectData.fct_adresse_cpl,
                'fct_adresse_cpl2' => pProjectData.fct_adresse_cpl2,
                'fct_cp' => pProjectData.fct_cp,
                'fct_ville' => pProjectData.fct_ville
            };
        }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
            parameters = new Map<String, Object>{
                'idLeadSource' => pProjectData.id_lead_source,
                'affilieur' => pProjectData.affilieur,
                'idProd' => ( pProjectData.id_prod == null ? null : integer.valueof(pProjectData.id_prod)),
                'idContrat' => pProjectData.id_contrat,
                'codePostal' => ( pProjectData.code_postal == null ? null : integer.valueof(pProjectData.code_postal)),
                'statut' => pProjectData.statut,
                'batiment' => pProjectData.batiment,
                'age' => pProjectData.age,
                'app' => pProjectData.app,
                'techno' => pProjectData.techno,
                'marque' => ( pProjectData.marque == null ? null : integer.valueof(pProjectData.marque)),
                'ageApp' => pProjectData.age_appareil,
                'prixTtc' => null,  //pProjectData.code_prix,
                'promo' => pProjectData.promo,
                'dateVisite' => pProjectData.date_visite,
                //'creneau_visite' => pProjectData.creneau_visite,
                'cltSituation' => pProjectData.clt_situation,
                'cltPosition' => pProjectData.clt_position,
                'cltCiv' => pProjectData.clt_civ,
                'cltNom' => pProjectData.clt_nom,
                'cltPrenom' => pProjectData.clt_prenom,
                'cltEmail' => pProjectData.clt_email,
                'cltTelephone' => pProjectData.clt_telephone,
                'cltAdresse' => pProjectData.clt_adresse,
                'cltAdresseCpl' => pProjectData.clt_adresse_cpl,
                'cltAdresseCpl2' => pProjectData.clt_adresse_cpl2,
                'cltCp' => ( pProjectData.clt_cp == null ? null : integer.valueof(pProjectData.clt_cp) ),
                'cltVille' => pProjectData.clt_ville,
                'fctCiv' => pProjectData.fct_civ,
                'fctNom' => pProjectData.fct_nom,
                'fctPrenom' => pProjectData.fct_prenom,
                'fctEmail' => pProjectData.fct_email,
                'fctTelephone' => pProjectData.fct_telephone,
                'fctAdresse' => pProjectData.fct_adresse,
                'fctAdresseCpl' => pProjectData.fct_adresse_cpl,
                'fctAdresseCpl2' => pProjectData.fct_adresse_cpl2,
                'fctCp' => ( pProjectData.fct_cp == null ? null : integer.valueof(pProjectData.fct_cp) ),
                'fctVille' => pProjectData.fct_ville
            };
        }

        req.setBody(JSON.serialize(parameters));

        System.debug(logginglevel.WARN,'### payLoad = ' + payLoad);
        System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        
        System.debug(logginglevel.WARN,'### req = ' + req);
        
        //HTTPResponse res = h.send(req);
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            try {
                res = h.send(req);
            } catch(System.CalloutException e) {
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = e.getMessage();
                return responseToReturn;
            }
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                resBody = '{"response": true}';
                //resBody = '{"response":false,"error":{"id_lead_source":"Parametre id_lead_source requis","batiment":"Parametre batiment requis"}}';
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                resBody = '{"id": 0}';
            }
            res.setBody(resBody);
        }
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());
            
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                //oPostDataResponseBodyGARANKA = (postDataResponseBodyGARANKA)JSON.deserializeStrict(res.getBody(), postDataResponseBodyGARANKA.class);
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                if(results.get('response') == true){
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = 'Données correctement envoyées au partenaire GARANKA.';
                }else{
                    responseToReturn.hasError = true;

                    Map<String, Object> errorsMap = (Map<String, Object>) results.get('error');
                    System.debug(logginglevel.WARN,'### errorsMap : ' + errorsMap);
                    
                    responseToReturn.errorMessage = 'Un problème est survenu dans l\' envoi des données au partenaire GARANKA : ' + errorsMap;
                }
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                if(results.get('id') != null){
                    responseToReturn.hasError = false;
                    responseToReturn.successMessage = 'Données correctement envoyées au partenaire MENERGIES.';
                }else{
                    responseToReturn.hasError = true;

                    Map<String, Object> errorsMap = (Map<String, Object>) results.get('message');
                    System.debug(logginglevel.WARN,'### errorsMap : ' + errorsMap);
                    
                    responseToReturn.errorMessage = 'Un problème est survenu dans l\' envoi des données au partenaire MENERGIES : ' + errorsMap;
                }
            }
            System.debug(logginglevel.WARN,'### responseToReturn : ' + responseToReturn);
            
        } else {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(pChauffageAPI.DeveloperName == 'GARANKA'){
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('code') + ' - ' + results.get('message');
            }else if(pChauffageAPI.DeveloperName == 'MENERGIES'){
                responseToReturn.hasError = true;
                responseToReturn.errorMessage = results.get('title') + ' - ' + results.get('detail');
            }
        }
        
        logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', pChauffageAPI.DeveloperName + ' - postData', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        return responseToReturn;
    }


    public static void logRestApiCallout(String header, String httpMethod, String params, String remoteAddress, Blob requestBody, String requestURI, String resourcePath, Blob response){

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
    
    
    // Response format to return to main controller (Code = OK or KO)
    public class apiResponse {
        public Boolean hasError { get; set; }
        public String successMessage { get; set; }
        public String errorMessage { get; set; }
    }

    public class tokenResponseBodyGARANKA {
        public String access_token;
        public String expires_in;
        public String token_type;
        public String scope;
    }

    public class tokenResponseBodyMENERGIES {
        public String token;
    }

    public class eligibilityResponseBodyGARANKA {
        public Boolean response;
    }
    
    public class projectData {
        public String id_lead_source { get; set; }
        public String affilieur { get; set; }
        public Integer id_prod { get; set; }
        public Integer id_contrat { get; set; }
        public String code_postal { get; set; }  // key removed by Garanka and needs to be sent as integer to MEnergies
        public String statut { get; set; }
        public String batiment { get; set; }
        public String age { get; set; }
        public Integer app { get; set; }
        public String techno { get; set; }
        public String marque { get; set; }  // needs to be sent as integer to MEnergies
        public Integer age_appareil { get; set; }
        public String code_prix { get; set; }  // needs to be sent as integer to MEnergies
        public String promo { get; set; }
        public String date_visite { get; set; }
        public String creneau_visite { get; set; }
        public String clt_situation { get; set; }
        public String clt_position { get; set; }
        public String clt_civ { get; set; }
        public String clt_nom { get; set; }
        public String clt_prenom { get; set; }
        public String clt_email { get; set; }
        public String clt_telephone { get; set; }
        public String clt_adresse { get; set; }
        public String clt_adresse_cpl { get; set; }
        public String clt_adresse_cpl2 { get; set; }
        public String clt_cp { get; set; }  // needs to be sent as integer to MEnergies
        public String clt_ville { get; set; }
        public String fct_civ { get; set; }
        public String fct_nom { get; set; }
        public String fct_prenom { get; set; }
        public String fct_email { get; set; }
        public String fct_telephone { get; set; }
        public String fct_adresse { get; set; }
        public String fct_adresse_cpl { get; set; }
        public String fct_adresse_cpl2 { get; set; }
        public String fct_cp { get; set; }  // needs to be sent as integer to MEnergies
        public String fct_ville { get; set; }
    }
    
}