public class Voxpay_CalloutMgr {
    
    // Call Voxpay API to get current user information
    public static userReferenceResponseBody callVoxpayUser(Voxpay_API_Settings__mdt pVxpAPI, string federationId) {
        
        String endpoint = '';
        userReferenceResponseBody oUserReferenceResponseBody;
        
        // if the user doesn't exist in Voxpay, no need to go further
        if( (federationId == null || federationId == '') ) return null;
        
        // Set the endpoint
        endpoint = String.format(pVxpAPI.User_Reference_Endpoint__c, new String[]{federationId});
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('Authorization', 'Bearer ' + pVxpAPI.API_Key__c);
        
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            String resBody = '{"data":[{"id":280,"created_at":"2020-02-17T15:47:15+00:00","email":"erwan.lecaer@butagaz.com","firstname":"Erwan","lastname":"LE CAER","phone":"33611959221","role":"admin","active":true,"reference":"TestFedId","pin_code":"6234", "number_decimal_separator":"", "number_thousand_separator":"", "locale":"", "date_format":"", "time_format":"", "timezone":"", "login":"","campaigns":[{"uuid":"71509899-76d9-59a3-81cc-b0371ee12661","name":"GAZARMOR RECETTE"},{"uuid":"73d2cbd2-e770-5157-886f-6f9385294278","name":"BUTAGAZ LOGIGAZ RECETTE Temporaire sur Granule (GEC)"},{"uuid":"4d1c1d8b-210d-59b4-873a-bb7674f77924","name":"BUTAGAZ ISOLATION RECETTE"},{"uuid":"47bba5c0-5119-5372-b3e9-a50d7641ddde","name":"Campagne par d\u00e9faut"},{"uuid":"ca2f898d-38ce-54ec-96f5-0facdd928222","name":"GRANULE RECETTE"}],"api_token":"NzWOrhNNOOSfWMCnAO5zYasTYJjbSpyg3V6p8kbSwTXGm6MJ0H7KT4XCXLlp"}],"links":{"first":"https://api.voxpay.ai/users?page=1","last":"https://api.voxpay.ai/users?page=1","prev":null,"next":null},"meta":{"current_page":1,"from":1,"last_page":1,"path":"https://api.voxpay.ai/users","per_page":15,"to":1,"total":1}}';
            res.setBody(resBody);
        }
        
        /*if(res.getStatusCode()==200){
            returnValue = res.getBody();
            System.debug(logginglevel.WARN,'### returnValue : ' + returnValue);
            
            userReferenceResponseBody oResponseBody = (userReferenceResponseBody)JSON.deserializeStrict(res.getBody(), userReferenceResponseBody.class);
            System.debug(logginglevel.WARN,'### oResponseBody : ' + oResponseBody);
            
            if(oResponseBody.id != '') {
                //logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Voxpay', null, req.getEndpoint(), '', res.getBodyAsBlob());
                //RestApiLogging.logRestApiCall(req.getHeader('contentType'), req.getMethod(), '', 'Voxpay', null, req.getEndpoint(), '', res.getBodyAsBlob().toString());
            }
            
        } else {
            //System.debug(logginglevel.WARN,'### res.getStatusCode() = ' + res.getStatusCode() + ' - ' + res.getStatus());
            //logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Voxpay', null, req.getEndpoint(), '', res.getBodyAsBlob());
        }*/
        
        if(res.getStatusCode()==200){
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Cast the values in the 'data' key as a list
            List<Object> lData = (List<Object>) results.get('data');
            
            System.debug('Received the following data:');
            
            for (Object oData: lData) {
                System.debug(oData);
                
                String dataJSONString = JSON.serialize(oData);
                System.debug(logginglevel.WARN,'### dataJSONString : ' + dataJSONString);
                oUserReferenceResponseBody = (userReferenceResponseBody)JSON.deserializeStrict(dataJSONString, userReferenceResponseBody.class);
                System.debug(logginglevel.WARN,'### oUserReferenceResponseBody : ' + oUserReferenceResponseBody);
                System.debug(logginglevel.WARN,'### oUserReferenceResponseBody.api_token : ' + oUserReferenceResponseBody.api_token);
            }
            
        }
        
        return oUserReferenceResponseBody;
    }
    
    // Call Voxpay API to send a payment request
    public static HttpResponse doCalloutPayment(Voxpay_API_Settings__mdt pVxpAPI, String pApiKey, paymentInfo oPaymentInfo) {
        
        String vxpEndpoint = '';
        
        Map<String, Object> psp_params = new Map<String, Object>{};
        if(oPaymentInfo.returnContext != null){
        	// Remove special characters from returnContext string. Not allowed. Keep only alphanumeric and blank spaces.
            psp_params.put('returnContext', oPaymentInfo.returnContext.replaceAll('[^a-zA-Z0-9 ]', ''));
        }
        if(oPaymentInfo.orderId != null){
            psp_params.put('orderId', oPaymentInfo.orderId);
        }
        
        if(!oPaymentInfo.subscription){
        	vxpEndpoint = pVxpAPI.Payment_Endpoint__c;
        }else{
        	vxpEndpoint = pVxpAPI.Subscription_Endpoint__c;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint(pVxpAPI.Payment_Endpoint__c);
        req.setEndpoint(vxpEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + pApiKey);
        // Set the body as a JSON object
        //request.setBody('{"cinematic_id": 4}');
        Map<String, Object> parameters = new Map<String, Object>{
            'campaign_id' => oPaymentInfo.campaign_id,
            'cinematic_id' => integer.valueOf(oPaymentInfo.cinematic_id),
            'amount' => oPaymentInfo.amount,
            'currency' => oPaymentInfo.currencyLabel,
            'customer_reference' => oPaymentInfo.customer_reference,
            'customer_title' => oPaymentInfo.customer_title,  // Voxpay salutations different from our list : how to manage this ? through a map from custom settings ?
            'customer_firstname' => oPaymentInfo.customer_firstname,
            'customer_lastname' => oPaymentInfo.customer_lastname,
            'customer_phone' => oPaymentInfo.customer_phone.replace('+', ''),
            'customer_email' => oPaymentInfo.customer_email,
            'short_description' => oPaymentInfo.short_description,
            'psp_params' => psp_params
        };
        // if we got a call uuid, this means we're posting a payment by phone and then we need to pass this uuid as a parameter to the payment API
        if(oPaymentInfo.call_uuid != null && oPaymentInfo.call_uuid != ''){
            parameters.put('call_uuid', oPaymentInfo.call_uuid);
        }
        if(oPaymentInfo.subscription){
        	parameters.put('interval_amount', oPaymentInfo.interval_amount);
        	parameters.put('interval_type', oPaymentInfo.interval_type);
        	parameters.put('interval_count', oPaymentInfo.interval_count);
        	parameters.put('gateway_operation', oPaymentInfo.gateway_operation);
        }
        System.debug(logginglevel.WARN,'### Endpoint = ' + pVxpAPI.Payment_Endpoint__c);
        System.debug(logginglevel.WARN,'### Bearer = ' + 'Bearer ' + pApiKey);
        System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        System.debug(logginglevel.WARN,'### JSON.serialize(parameters) = ' + JSON.serialize(parameters));
        req.setBody(JSON.serialize(parameters));
                
        System.debug(logginglevel.WARN,'### req = '+ req);
        
        //HTTPResponse res = h.send(req);
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            
            String resBody = '';
            if(oPaymentInfo.subscription){
            	res.setStatusCode(201);
	            res.setStatus('OK');
	            
	            resBody = '{"id":"019800fe-a7f6-433e-b6e3-85dc4415b0eb","interval_amount":2,"interval_currency":"EUR","interval_count":2,"interval_type":"month","created_at":"2020-06-26T09:18:25+00:00","updated_at":"2020-06-26T09:18:26+00:00","parent_payment":{"created_at":"2020-06-26T09:18:25+00:00","updated_at":"2020-06-26T09:18:26+00:00","started_at":"2020-06-26T09:18:25+00:00","authorized_at":null,"expires_at":"2020-07-26T09:18:25+00:00","scheduled_at":null,"error_code":null,"error_message":null,"laststep":"","steps":{"sms":{"is_valid":null,"delivered_at":null},"webpage":{"is_valid":null,"displayed_at":null,"user_agent":""},"pan":{"is_valid":null,"value":""},"date":{"is_valid":null,"value":""},"cvv":{"is_valid":null,"value":""},"transaction":{"is_valid":null,"status":""}},"requested_3ds":"no","result_3ds":null,"localized_result_3ds":null,"is_card_holder_required":false,"currency":"EUR","reference":"2006261","short_description":"short_desc","customer_reference":"CUSTREF","customer_email":"erwan.lecaer@butagaz.com","customer_phone":"33611959221","customer_title":"mister","customer_firstname":"Erwan","customer_lastname":"TestQLIDoublons","customer_language":null,"line_forward":null,"extra":{},"caller_sda":null,"link":"https://p.voxpay.io/a93yPsB","gateway_operation":"tokenization+authorization+capture","success_url":null,"failure_url":null,"can_send_receipt":false,"psp_reference":null,"card_brand":null,"card_expire_date":null,"card_masked":null,"webpage_display_user_agent":"","webpage_displayed_at":"","mail_displayed_at":"","pan":"","pan_valid":null,"date":"","date_valid":null,"cvv":"","cvv_valid":"","embedded_url":"https://admin.voxpay.io/payment/d7bee813-21e6-4b56-be53-3c82f8155d7b/embedded?signature=407a6d6e5b328c2624a6aa06813241a4f1dcebf35da7ca69cb15e973f6c1ea07","is_test":true,"amount":1,"amount_debit":0,"id":"d7bee813-21e6-4b56-be53-3c82f8155d7b","campaign":{"id":"874b903e-5ce3-5251-b7a3-d69706601733","name":"Campagne par defaut","is_active":true,"is_default":null,"auto_email_receipt":false,"payment_reference_prefix":null,"customer_language":null,"customer_timezone":"Europe/Paris","additional_form_fields":[],"customizations":[{"id":"c142039c-b07d-4f9d-b8d3-92c0f4884681","name":"Par defaut","type":"WEB_PAYMENT_PAGE","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"template":"default","name":"default","primary_color":"#16b1ff","secondary_color":"#71cdfe","logo_url":"c2dfd6a8-d8a6-4ffc-b117-1404f80088d0","background_image_url":null,"cgv_url":null},"content":{"fr":{"cgv_url":null,"logo_url":"c2dfd6a8-d8a6-4ffc-b117-1404f80088d0","background_image_url":null}},"status":"available"},{"id":"07060437-81c9-47e6-9202-f382c44b41b4","name":"Par defaut","type":"REQUEST_PAYMENT_SMS","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"sender":"Voxpay","content":"Rappel de reglement {{account_name}} pour un montant de {{amount}} {{currency}}. Pour regler: {{link}}"},"content":{"fr":{"sender":"Voxpay","content":"Rappel de reglement {{account_name}} pour un montant de {{amount}} {{currency}}. Pour regler: {{link}}"}},"status":"available"},{"id":"bbc0d736-3c3e-40c9-ac79-f9afdc656912","name":"WhatsApp FR #2","type":"REQUEST_PAYMENT_WHATSAPP","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"sinch_bot_id":"voxpay","template_language":"fr","template_name":"ask_payment_simple","content":"{{customer_firstname}} {{customer_lastname}}, vous avez reçu une demande de paiement de la part de {{account_name}} dun montant de {{amount}} {{currency}}. Pour regler, veuillez suivre ce lien {{link}}. La proc\u00e9dure dachat est totalement s\u00e9curis\u00e9e.","params_ordered":"{{customer_firstname}} {{customer_lastname}}#{{account_name}}#{{amount}} {{currency}}#{{link}}"},"content":[],"status":"available"},{"id":"37015a83-2e99-4f60-9461-a7ae7e34db35","name":"Par d\u00e9faut","type":"REQUEST_PAYMENT_EMAIL","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"color":null,"theme":"default","title":null,"footer":null,"subject":"Lien de paiement","template":"default","logo_footer":null,"logo_header":null,"top_content":"","bottom_content":"","is_basket_visible":false,"is_info_table_visible":true},"content":{"fr":{"title":null,"footer":null,"subject":"Lien de paiement","logo_footer":null,"logo_header":null,"top_content":"","bottom_content":""}},"status":"available"},{"id":"0c9ca04b-312e-4745-8bac-5366a8646d68","name":"Par d\u00e9faut","type":"RECEIPT_PAYMENT_EMAIL","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"theme":"default","title":"Re\u00e7u de paiement","footer":null,"subject":"Re\u00e7u de paiement","template":"default","logo_footer":null,"logo_header":null,"top_content":"","bottom_content":"","is_basket_visible":false,"is_info_table_visible":true},"content":{"fr":{"title":"Re\u00e7u de paiement","footer":null,"subject":"Re\u00e7u de paiement","logo_footer":null,"logo_header":null,"top_content":"","bottom_content":""}},"status":"available"},{"id":"1eb88e5e-1149-41ca-9d79-6f4dd3285620","name":"Par d\u00e9faut","type":"REQUEST_PAYMENT_BY_CODE_SMS","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"sender":"Voxpay","content":"Rappel de reglement {{account_name}} pour un montant de {{amount}} {{currency}}. Veuillez composer le {{payment_sda}} avec le code {{payment_code}}"},"content":{"fr":{"sender":"Voxpay","content":"Rappel de reglement {{account_name}} pour un montant de {{amount}} {{currency}}. Veuillez composer le {{payment_sda}} avec le code {{payment_code}}"}},"status":"available"},{"id":"b57f65df-d05b-4197-9049-bea7a9113d14","name":"Par defaut","type":"REQUEST_PAYMENT_BY_CODE_EMAIL","created_at":"2020-01-30T16:00:00+00:00","updated_at":"2020-01-30T16:00:00+00:00","data":{"template":"default","subject":"Code de paiement","title":null,"content":null,"footer":null},"content":{"fr":{"title":null,"footer":null,"content":null,"subject":"Code de paiement"}},"status":"available"},{"id":"f6ededd4-e91e-406b-aff3-605152d83ce8","name":"Par defaut","type":"RECEIPT_PAYMENT_SMS","created_at":"2020-02-13T12:22:17+00:00","updated_at":"2020-02-13T12:22:17+00:00","data":{"sender":"Voxpay","content":"Paiement de {{amount}} {{currency}} pour le compte de {{account_name}} confirme. Merci pour votre commande."},"content":{"fr":{"sender":"Voxpay","content":"Paiement de {{amount}} {{currency}} pour le compte de {{account_name}} confirme. Merci pour votre commande."}},"status":"available"}],"generate_reference_if_empty":true,"invoice":{"name":null,"address":null,"city":null,"zipcode":null,"country":null,"vat_number":null,"siret":null}},"gateway":{"id":102,"gateway_type":{"name":"Sandbox","psp":"sandbox"},"name":"Gateway Sandbox (test)","params":[],"is_test":true,"tokenization_field":null,"ask_3ds":"no"},"user":{"id":250,"created_at":"2020-06-02T16:42:22+00:00","email":"Erwan.LeCaer@Butagaz.com","firstname":"Erwan","lastname":"Le Caer","phone":"","role":"admin","active":true,"reference":"erwan.lecaer@butagaz.fr.logigaz","pin_code":"7409","api_token":"27RsmY9BrhFvtbEGw2ckbfNq7GcXBVGGM683wxEMC9fL263FBc9oBIYnuS29"},"call":null,"cinematic":{"id":4,"name":"SmsToWeb","description":"Push paiement web par SMS","locale_name":"SMS"},"status":{"id":20,"name":"initialized","locale_name":"Initialise"},"qrcode_url":"https://admin.voxpay.io/payment/d7bee813-21e6-4b56-be53-3c82f8155d7b/qr-code","psp_params":{"returnContext":"ReturnContextBtz","orderId":"orderIdBtz"}}}';
            }else{
	            res.setStatusCode(200);
	            res.setStatus('OK');
	            
	            resBody = '{"created_at":"2020-05-11T10:26:15+00:00","updated_at":"2020-05-11T10:26:15+00:00","started_at":"2020-05-11T10:26:15+00:00","authorized_at":null,"expires_at":"2020-06-16T10:26:15+00:00","error_code":null,"error_message":null,"laststep":"","steps":{"sms":{"is_valid":null,"delivered_at":null},"webpage":{"is_valid":null,"displayed_at":null,"user_agent":""},"pan":{"is_valid":null,"value":""},"date":{"is_valid":null,"value":""},"cvv":{"is_valid":null,"value":""},"transaction":{"is_valid":null,"status":""}},"requested_3ds":"no","result_3ds":null,"localized_result_3ds":null,"is_card_holder_required":false,"currency":"EUR","reference":"12345","short_description":"short_desc","customer_reference":null,"customer_email":"erwan.lecaer@butagaz.com","customer_phone":"33611959221","customer_title":"","customer_firstname":"Erwan","customer_lastname":"LNameMainOwner","customer_language":"fr","line_forward":null,"extra":{},"caller_sda":null,"link":"https://tpe.cx/aNdF271","gateway_operation":"authorization+capture","success_url":null,"failure_url":null,"can_send_receipt":false,"psp_reference":null,"card_brand":null,"card_expire_date":null,"card_masked":null,"webpage_display_user_agent":"","webpage_displayed_at":"","mail_displayed_at":"","pan":"","pan_valid":null,"date":"","date_valid":null,"cvv":"","cvv_valid":"","embedded_url":"https://admin.voxpay.ai/payment/ab51fca8-0f6c-49fc-86f3-8ebc4066098d/embedded?signature=072755ebb830bd47a06c58cfa49de3bea647953a7e627efdafd94d03a5e0b4c9","is_test":true,"amount":10,"amount_debit":0,"id":"ab51fca8-0f6c-49fc-86f3-8ebc4066098d","campaign":{"id":"1","name":"GRANULE RECETTE","is_active":true,"is_default":null,"auto_email_receipt":true,"payment_reference_prefix":"GRA","customer_language":"fr","customer_timezone":"Europe/Paris","additional_form_fields":{"customer_title":"Civilite","customer_lastname":"Nom","customer_firstname":"Prenom","customer_phone":"Téléphone Mobile","customer_email":"Email","customer_reference":{"type":"text","label":"Reference Client(Client)","tooltip":"","info":"","placeholder":"DG00109629"},"psp_params[orderId]":{"type":"text","label":"No de Commande","tooltip":"","info":"","placeholder":"GDB1961453"},"psp_params[returnContext]":{"type":"text","label":"References Complementaires","tooltip":"Texte Libre","info":"Texte Libre","placeholder":""},"description":"Commentaire","short_description":{"type":"hidden","label":"short description"},"reference":{"type":"hidden","label":"reference"}},"customizations":[{"id":"1","name":"Granules","type":"RECEIPT_PAYMENT_EMAIL","created_at":"2020-02-13T21:35:24+00:00","updated_at":"2020-04-23T15:09:48+00:00","data":{"theme":"default","subject":"Votre paiement a bien ete enregistre","title":"Confirmation de reglement aupres de Butagaz","top_content":"Bonjour","is_info_table_visible":"1","bottom_content":null,"footer":"","logo_header":"1","logo_footer":null},"status":"available"},{"id":"1","name":"Par d\u00e9faut","type":"REQUEST_PAYMENT_SMS","created_at":"2020-01-27T14:31:21+00:00","updated_at":"2020-01-27T14:31:21+00:00","data":{"content":"Rappel","sender":"Voxpay"},"status":"available"},{"id":"1","name":"Par d\u00e9faut","type":"REQUEST_PAYMENT_BY_CODE_SMS","created_at":"2020-01-27T14:31:21+00:00","updated_at":"2020-01-27T14:31:21+00:00","data":{"content":"Rappel","sender":"Voxpay"},"status":"available"},{"id":"1","name":"Par","type":"REQUEST_PAYMENT_BY_CODE_EMAIL","created_at":"2020-01-27T14:31:21+00:00","updated_at":"2020-01-27T14:31:21+00:00","data":{"content":null,"footer":null,"subject":"Code de paiement","template":"default","title":null},"status":"available"},{"id":"1","name":"WhatsApp FR #2","type":"REQUEST_PAYMENT_WHATSAPP","created_at":"2020-01-27T14:31:21+00:00","updated_at":"2020-01-27T14:31:21+00:00","data":{"content":"TTT","params_ordered":"","sinch_bot_id":"voxpay","template_language":"fr","template_name":"ask_payment_simple"},"status":"available"},{"id":"1","name":"Par d\u00e9faut","type":"RECEIPT_PAYMENT_SMS","created_at":"2020-02-06T10:08:57+00:00","updated_at":"2020-02-06T10:08:57+00:00","data":{"sender":"Voxpay","content":"Paiement"},"status":"available"},{"id":"1","name":"Granul\u00e9s","type":"REQUEST_PAYMENT_EMAIL","created_at":"2020-02-13T21:32:29+00:00","updated_at":"2020-04-23T15:09:36+00:00","data":{"theme":"default","subject":"Votre commande","title":"Votre demande de paiement","top_content":"","is_info_table_visible":"1","bottom_content":null,"footer":"","color":null,"logo_header":"","logo_footer":null},"status":"available"},{"id":"1","name":"Granules","type":"WEB_PAYMENT_PAGE","created_at":"2020-02-13T21:34:29+00:00","updated_at":"2020-03-24T13:35:57+00:00","data":{"name":"butagaz","primary_color":null,"secondary_color":null,"logo_url":"","background_image_url":null,"cgv_url":""},"status":"available"}],"generate_reference_if_empty":true},"gateway":{"id":144,"gateway_type":{"name":"Mercanet","psp":"mercanet"},"name":"GRANULE RECETTE","params":{"env":"test","key_version":"6","merchant_id":"211040032210001"},"is_test":true,"tokenization_field":null,"ask_3ds":"no"},"user":{"id":280,"created_at":"2020-02-17T15:47:15+00:00","email":"erwan.lecaer@butagaz.com","firstname":"Erwan","lastname":"LE CAER","phone":"33611959221","role":"admin","active":true,"reference":"1234","pin_code":"6234","api_token":"1"},"call":null,"cinematic":{"id":4,"name":"SmsToWeb","description":"Push paiement Web par SMS","locale_name":"SMS"},"status":{"id":20,"name":"initialized","locale_name":"Initialise"},"qrcode_url":"","psp_params":{"returnContext":"returnContextBtz","orderId":"orderIdBtz"}}';
            }
            res.setBody(resBody);
            
        }
        
        logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'VoxpayPayment', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        //return h.send(req);
        return res;
    }
    
    // Call Voxpay API to book a phone number
    public static ddiBookResponseBody callVoxpayDdiBook(Voxpay_API_Settings__mdt pVxpAPI, String pApiKey, String pUserReference) {
        
        String endpoint = '';
        ddiBookResponseBody oDdiBookResponseBody;
        
        
        if( (pUserReference == null || pUserReference == '') ) return null;
        
        // Perform the callout
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(pVxpAPI.Ddi_Book_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + pApiKey);
        //req.setHeader('Content-Length', '0');
        // Set the body as a JSON object
        Map<String, Object> parameters = new Map<String, Object>{
            'user_reference' => pUserReference
        };
        System.debug(logginglevel.WARN,'### Endpoint = ' + pVxpAPI.Ddi_Book_Endpoint__c);
        System.debug(logginglevel.WARN,'### Bearer = ' + 'Bearer ' + pApiKey);
        System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        System.debug(logginglevel.WARN,'### JSON.serialize(parameters) = ' + JSON.serialize(parameters));
        req.setBody(JSON.serialize(parameters));
        System.debug(logginglevel.WARN,'### req = ' + req);
        
        //HTTPResponse res = h.send(req);
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            String resBody = '{"sda":"33188882230","date_end_booking":"2020-05-11T22:30:07+00:00"}';
            res.setBody(resBody);
        }
        
        if(res.getStatusCode()==200){
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());
            
            oDdiBookResponseBody = (ddiBookResponseBody)JSON.deserializeStrict(res.getBody(), ddiBookResponseBody.class);
            System.debug(logginglevel.WARN,'### oDdiBookResponseBody : ' + oDdiBookResponseBody);
            
            if(oDdiBookResponseBody == null || oDdiBookResponseBody.sda == '') {
                oDdiBookResponseBody = null;
            }else{
                //logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'Voxpay', null, req.getEndpoint(), '', res.getBodyAsBlob());
            }
            
        } else {
            oDdiBookResponseBody = null;
        }
        
        logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'VoxpayDdiBook', req.getBodyAsBlob(), req.getEndpoint(), '', res.getBodyAsBlob());
        
        return oDdiBookResponseBody;
    }
    
    // Call Voxpay API to check the call has been transferred to Voxpay
    public static callsResponseBody callVoxpayCalls(Voxpay_API_Settings__mdt pVxpAPI, String pApiKey, String pUserReference) {
        
        // Set the endpoint
        String endpoint = String.format(pVxpAPI.Get_Calls_Endpoint__c, new String[]{pUserReference});
        //string endpoint = 'https://api.voxpay.ai/calls?online=1&user_reference={0}';
        //endpoint = String.format(vxpGetCallsEndpoint, new String[]{pUserReference});
        
        //string vxpGetCallsEndpoint = 'https://api.voxpay.ai/calls?online=1&user_reference=12345';
        
        callsResponseBody oCallsResponseBody;
        
        if( (pUserReference == null || pUserReference == '') ) return null;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint(pVxpAPI.Get_Calls_Endpoint__c);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + pApiKey);
        //req.setHeader('Content-Length', '0');
        // Set the body as a JSON object
        //Map<String, Object> parameters = new Map<String, Object>{
        //    'online' => 1,
        //    'user_reference' => pUserReference
        //};
        System.debug(logginglevel.WARN,'### Endpoint = ' + pVxpAPI.Get_Calls_Endpoint__c);
        System.debug(logginglevel.WARN,'### Bearer = ' + 'Bearer ' + pApiKey);
        //System.debug(logginglevel.WARN,'### parameters = ' + parameters);
        //System.debug(logginglevel.WARN,'### JSON.serialize(parameters) = ' + JSON.serialize(parameters));
        //req.setBody(JSON.serialize(parameters));
        System.debug(logginglevel.WARN,'### req = ' + req);
        
        //HTTPResponse res = h.send(req);
        HTTPResponse res = new HttpResponse();
        if(! Test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            
            res.setStatusCode(200);
            res.setStatus('OK');
            
            String resBody = '{"data": [{"id": "1de66f5d-cfe3-5895-8f2a-471194106cad","phone_from": "33182881377","phone_from_formatted": "+33 1 82 88 13 77","phone_to": "33800123891","phone_to_formatted": "+33 800 12 38 91","start_call": "2020-04-29T19:10:35+00:00","end_call": null,"duration": null,"reason_end_call": null,"fee": null,"fee_currency": null,"destination_type": null,"destination_country_iso2": null,"reference": null,"contact": null,"user": {"id": 280,"reference": "12345","email": "erwan.lecaer@butagaz.com"},"new_payment_url": {"1": "https://admin.voxpay.ai/call/1de66f5d-cfe3-5895-8f2a-471194106cad/new-payment/1","4": "https://admin.voxpay.ai/call/1de66f5d-cfe3-5895-8f2a-471194106cad/new-payment/4","6": "https://admin.voxpay.ai/call/1de66f5d-cfe3-5895-8f2a-471194106cad/new-payment/6"},"embedded_url": "https://api.voxpay.ai"}],"links": {"first": "https://api.voxpay.ai/calls?page=1","last": "https://api.voxpay.ai/calls?page=1","prev": null,"next": null},"meta": {"current_page": 1,"from": 1,"last_page": 1,"path": "https://api.voxpay.ai/calls","per_page": 15,"to": 1,"total": 1}}';
            res.setBody(resBody);
        }
        
        
        if (res.getStatusCode() == 200) {
            // Replace keys that have numbers as names because they are illegal as attribute names
            System.debug(logginglevel.WARN,'### res.getBody() : ' + res.getBody());
            String responseBody = res.getBody();
            responseBody = responseBody.replaceAll('\"1\":', '\"npu1\":');
            responseBody = responseBody.replaceAll('\"4\":', '\"npu4\":');
            responseBody = responseBody.replaceAll('\"6\":', '\"npu6\":');
            System.debug(logginglevel.WARN,'### responseBody : ' + responseBody);
            
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            // Cast the values in the 'data' key as a list
            List<Object> lData = (List<Object>) results.get('data');
            
            System.debug('Received the following data:');
            // We'll be receiving only one record in the collection
            for (Object oData: lData) {
                System.debug(oData);
                
                String dataJSONString = JSON.serialize(oData);
                System.debug(logginglevel.WARN,'### dataJSONString : ' + dataJSONString);
                oCallsResponseBody = (callsResponseBody)JSON.deserializeStrict(dataJSONString, callsResponseBody.class);
                System.debug(logginglevel.WARN,'### oCallsResponseBody : ' + oCallsResponseBody);
                System.debug(logginglevel.WARN,'### oCallsResponseBody.phone_from : ' + oCallsResponseBody.phone_from);
            }
            
            logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'VoxpayCalls', null, req.getEndpoint(), '', res.getBodyAsBlob());
        }else{
            System.debug(logginglevel.WARN,'### The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            logRestApiCallout(req.getHeader('contentType'), req.getMethod(), '', 'VoxpayCalls', null, req.getEndpoint(), '', res.getBodyAsBlob());
            return null;
        }
        
        return oCallsResponseBody;
    }
    
    
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
    
    
    public class paymentInfo {
        public String campaign_id { get; set; }
        public Integer cinematic_id { get; set; }
        public String call_uuid { get; set; }
        public Decimal amount { get; set; }
        public String currencyLabel { get; set; }
        public String customer_reference { get; set; }
        public String customer_title { get; set; }
        public String customer_firstname { get; set; }
        public String customer_lastname { get; set; }
        public String customer_phone { get; set; }
        public String customer_email { get; set; }
        public String returnContext { get; set; }
        public String orderId { get; set; }
        public String short_description { get; set; }
        public Boolean subscription { get; set; }
        public Decimal interval_amount { get; set; }
        public String interval_type { get; set; }
        public Integer interval_count { get; set; }
        public String gateway_operation { get; set; }
        
        /*public paymentInfo(){
            
        }*/
    }
    
    public class userReferenceResponseBody {
        public String id;
        public String created_at;
        public String email;
        public String firstname;
        public String lastname;
        public String phone;
        public String role;
        public Boolean active;
        public String reference;
        public String pin_code;
        public List<userReferenceResponseBodyCampaign> campaigns;
        public String api_token;
        public String number_decimal_separator;
        public String number_thousand_separator;
        public String locale;
        public String date_format;
        public String time_format;
        public String timezone;
        public String login;
        public userReferenceResponseBodyCampaign default_campaign;
    }
    
    public class userReferenceResponseBodyCampaign {
        public String uuid;
        public String name;
    }
    
    public class ddiBookResponseBody {
        public String sda;
        public String date_end_booking;
    }
    
    public class callsResponseBody {
        public String id;
        public String reference;
        public String contact;
        public String phone_from;
        public String phone_from_formatted;
        public String phone_to;
        public String phone_to_formatted;
        public String start_call;
        public String end_call;
        public String duration;
        public String reason_end_call;
        public String fee;
        public String fee_currency;
        public String destination_type;
        public String destination_country_iso2;
        public String embedded_url;
        public String audio_url;
        public callsResponseBodyUser user;
        public callsResponseBodyNewPaymentURL new_payment_url;
    }
    
    public class callsResponseBodyUser {
        public Integer id;
        public String reference;
        public String email;
    }
    
    public class callsResponseBodyNewPaymentURL {
        public String npu1;
        public String npu4;
        public String npu6;
    }
    
}