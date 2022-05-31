public class AP_WrapperForSOAPCallRebate {
    
    public microsoftLobservicesSapRebate.RfcEndpoint webserviceSOAP;
    public AP_WrapperDataForController responseForController;
    
    public Quote currentQuote; // Quote received from controller
    
    public String IM_CANAL;
    public String IM_DONNEUR_ORDRE;
    public String IM_MODE;
    public String IM_ORGA_COM;
    public String IM_SECTEUR;
    //public String reason;
    
    public BAPITracker__c oBapiTracker {get;set;}
    public String sStoreTracker {get;set;}
    
    public string rebateTypes {get;set;}    // Build a string to concatenate the rebate types to rename the opportunity and quote
    
    
    
    public AP_WrapperForSOAPCallRebate(Quote currentQuote){
        
        System.debug(logginglevel.WARN,'### currentQuote : ' + currentQuote );
        
        this.webserviceSOAP = new microsoftLobservicesSapRebate.RfcEndpoint();
        this.currentQuote = currentQuote;
        
        this.oBapiTracker = new BAPITracker__c();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');
        
        this.IM_CANAL = '02';
        this.IM_DONNEUR_ORDRE = this.currentQuote.Opportunity.Account.AccountNumber;
        this.IM_MODE = '1';
        this.IM_ORGA_COM = this.currentQuote.Opportunity.Account.Mandataire__r.ExternalID__c;
        this.IM_SECTEUR = this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c.toPlainString();
        //this.reason = this.currentQuote.Opportunity.Reason__c;
        
        System.debug(logginglevel.WARN,'### this.IM_DONNEUR_ORDRE : ' + this.IM_DONNEUR_ORDRE );
        System.debug(logginglevel.WARN,'### this.IM_ORGA_COM : ' + this.IM_ORGA_COM );
        System.debug(logginglevel.WARN,'### this.IM_SECTEUR : ' + this.IM_SECTEUR );
        
        
        String username, password;
        this.webserviceSOAP.endpoint_x = AP_PricingUtilities.getCustomSettingValue('Rebate_EndPointURL');
        username = AP_PricingUtilities.getCustomSettingValue('Rebate_Username');
        password = AP_PricingUtilities.getCustomSettingValue('Rebate_Password');
        
        Map<String,String> inputHttpHeaders = new Map<String, String>();

        Blob headerValue = Blob.valueOf( username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        inputHttpHeaders.put('Authorization', authorizationHeader);

        this.webserviceSOAP.inputHttpHeaders_x = inputHttpHeaders;
        webserviceSOAP.timeout_x = 60000;
        
        System.debug(logginglevel.WARN,'### webserviceSOAP.timeout_x : ' + webserviceSOAP.timeout_x );
    }
    
    
    /** CONSTRUCT THE REQUEST TO DO CALLOUT, WE HAVE TO SPECIFY THE TABLE 'IT_PTL' **/
    public AP_WrapperDataForController postRebatesToSAP(List<QuoteLineItem> listQuoteLineItemFromCtrl){
       
       System.debug(logginglevel.WARN,'### listQuoteLineItemFromCtrl : ' + listQuoteLineItemFromCtrl );
       AP_ProcessSAPRequest newRequest = new AP_ProcessSAPRequest(this, listQuoteLineItemFromCtrl);
       newRequest.doSAPRequest();
       AP_ProcessSAPResponse responseGot = newRequest.sapResponses;
       
       System.debug(logginglevel.WARN,'### responseGot : ' + responseGot );
       
       String exControl = responseGot.getExControl();
       
       List<QuoteLineItem> QLIList = responseGot.getQuoteLineItemList();
       
       List<ReturnFields> returnFieldsList = responseGot.getReturnFieldsList();
       List<AP_VFMessage> APVFMessageList = responseGot.getAPVFMessageList();
       Boolean errorGotFromSAP = responseGot.getErrorGotFromSAP();
       Boolean atLeastOneRebateCreatedInSAP = responseGot.getAtLeastOneRebateCreatedInSAP();
       
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForController = new AP_WrapperDataForController(this, exControl, QLIList, returnFieldsList, APVFMessageList, errorGotFromSAP, atLeastOneRebateCreatedInSAP);
       return responseForController; 
       
    }
    
    
    // Process SAP Requests
    private class AP_ProcessSAPRequest{
        private AP_WrapperForSOAPCallRebate parent;
        
        //Fields to do SAP Requests 
        private List< List<QuoteLineItem> > quoteLineItemsPacket; // List of Param for SAP Request
        private List<QuoteLineItem> lquoteLineItems;  // List of all QuoteLineItems
        
        //Fields to construct SAP Responses
        public AP_ProcessSAPResponse sapResponses;
        
        public AP_ProcessSAPRequest(AP_WrapperForSOAPCallRebate parent, List<Quote_PTL__c> quotePTLList){
            this.parent = parent;
            this.quoteLineItemsPacket = new List< List<QuoteLineItem> >();
            this.sapResponses = new AP_ProcessSAPResponse(this);
        }
        
        public AP_ProcessSAPRequest(AP_WrapperForSOAPCallRebate parent, List<QuoteLineItem> quoteLineItemsList){
            this.parent = parent;
            this.lquoteLineItems = quoteLineItemsList;
            this.initQuoteLineItemsPacket(quoteLineItemsList);
            this.sapResponses = new AP_ProcessSAPResponse(this);
        }
        
        private void initQuoteLineItemsPacket(List<QuoteLineItem> lQuoteLineItems){
            this.quoteLineItemsPacket = new List<List<QuoteLineItem>>();
            
            System.debug(logginglevel.WARN,'### lQuoteLineItems : ' + lQuoteLineItems );

            List<QuoteLineItem> quoteLineItemsToSend = new List<QuoteLineItem>();
            for(QuoteLineItem oQLI : lQuoteLineItems){
                System.debug(logginglevel.WARN,'### this.parent.currentQuote.Client_Reenlistment__c : ' + this.parent.currentQuote.Client_Reenlistment__c );
                if(this.parent.currentQuote.Client_Reenlistment__c == 'Commercial offer' && this.parent.currentQuote.Type_de_remuneration__c != 'Avoir'){
                    if(oQLI.PricebookEntry.Product2.Family == 'Produit'){
                        quoteLineItemsToSend.add(oQLI);
                    }
                }else{
                    System.debug(logginglevel.WARN,'### Add QLI TTT : ' + oQLI );
                    quoteLineItemsToSend.add(oQLI);
                }
            }
            this.quoteLineItemsPacket.add(quoteLineItemsToSend);
            
        }
        
        
        // Process the Packets of QuoteLineItem on SAP Request
        private void doSAPRequest(){
            
            this.parent.IM_MODE = '1';
            this.parent.rebateTypes = '';
            
            integer cptRebatesToBAPI = 0;
            string ptlCode = '';
            integer iLockedPriceDurationInYears = 0;
            
            // We need to count the rebates to post to determine the array size
            integer cptRebatesToPost = 0;
            for(QuoteLineItem qli : lquoteLineItems){
                // RCE
                if( this.parent.currentQuote.Client_Reenlistment__c == 'Contract' && qli.RCE_Rebate_TTC__c != null && qli.RCE_Rebate_TTC__c != 0 ){
                    qli.Reason_For_Order__c = '000';
                }
                if( qli.RCE_Rebate_TTC__c != null && qli.RCE_Rebate_TTC__c != 0 && String.isNotBlank(qli.Reason_For_Order__c) ) cptRebatesToPost++;
                
                // RConj
                if( qli.Cyclical_Rebate_TTC__c != null && qli.Cyclical_Rebate_TTC__c != 0 ) cptRebatesToPost++;
                
                // RComm
                if( qli.Commercial_Rebate_TTC__c != null && qli.Commercial_Rebate_TTC__c != 0 && (this.parent.currentQuote.Client_Reenlistment__c == 'Contract') ) cptRebatesToPost++;
                
                // Credit
                if( qli.Credit_Unit_Price_HT__c != null && qli.Credit_Unit_Price_HT__c != 0 && this.parent.currentQuote.Credit_Price_Date__c != null && String.isNotBlank(this.parent.currentQuote.Opportunity.Reason__c) ) cptRebatesToPost++;
                
                // Remise post prix fixe
                if( qli.Remise_Post_Offre_TTC__c != null && qli.Remise_Post_Offre_TTC__c != 0 ) cptRebatesToPost++;
                
                // Action Co
                // In case of Contract with an Action Co LockedPrice we need to post another rebate to SAP
                if( qli.PricebookEntry.Product2.Family == 'Produit' && this.parent.currentQuote.Client_Reenlistment__c == 'Contract' && this.parent.currentQuote.Action_Commerciale__c != null && 
                        ( this.parent.currentQuote.Action_Commerciale__r.Fixed_Price__c || this.parent.currentQuote.Action_Commerciale__r.Locked_Price__c || this.parent.currentQuote.Action_Commerciale__r.Locked_Price_1_Year__c ||
                        this.parent.currentQuote.Action_Commerciale__r.Locked_Price_2_Years__c || this.parent.currentQuote.Action_Commerciale__r.Locked_Price_3_Years__c ) ){
                    cptRebatesToPost++;
                }
            }
            
            System.debug(logginglevel.WARN,'### cptRebatesToPost : ' + cptRebatesToPost );
            
            // Calculate fixed or locked price duration
            if( this.parent.currentQuote.Action_Commerciale__r.Fixed_Price__c || this.parent.currentQuote.Action_Commerciale__r.Locked_Price__c ) iLockedPriceDurationInYears = (this.parent.currentQuote.Contract_Duration__c == null) ? 0 : integer.valueOf(this.parent.currentQuote.Contract_Duration__c);
            if( this.parent.currentQuote.Action_Commerciale__r.Locked_Price_1_Year__c ) iLockedPriceDurationInYears = 1;
            if( this.parent.currentQuote.Action_Commerciale__r.Locked_Price_2_Years__c ) iLockedPriceDurationInYears = 2;
            if( this.parent.currentQuote.Action_Commerciale__r.Locked_Price_3_Years__c ) iLockedPriceDurationInYears = 3;
            
            
            for(List<QuoteLineItem> quoteLineItemsList : quoteLineItemsPacket){
            
                List<ReturnFields> returnFieldsList = new List<ReturnFields>();
                
                // Constructing SAP Request
                microsoftLobservicesSapRebate.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapRebate.ArrayOfBAPIRET2();
                microsoftLobservicesSapRebate.ArrayOfZBAPI_CRM_REMISE IT_PTL = new microsoftLobservicesSapRebate.ArrayOfZBAPI_CRM_REMISE();
                
                if(quoteLineItemsList != null){
                    
                    //IT_PTL.ZBAPI_CRM_REMISE = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE[quoteLineItemsList.size()];
                    IT_PTL.ZBAPI_CRM_REMISE = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE[cptRebatesToPost];
                    System.debug(logginglevel.WARN,'### IT_PTL.ZBAPI_CRM_REMISE.size() : ' + IT_PTL.ZBAPI_CRM_REMISE.size() );
                    
                    //for(Integer i=0; i<IT_PTL.ZBAPI_CRM_REMISE.size(); i++){
                    for(Integer i=0; i<quoteLineItemsList.size(); i++){
                        
                        // Get the currentQuoteLineItem
                        QuoteLineItem currentQuoteLineItem = quoteLineItemsList.get(i);
                        System.debug(logginglevel.WARN,'### this.parent.currentQuote.Client_Reenlistment__c : ' + this.parent.currentQuote.Client_Reenlistment__c );
                        System.debug(logginglevel.WARN,'### currentQuoteLineItem : ' + currentQuoteLineItem );
                        System.debug(logginglevel.WARN,'### currentQuoteLineItem.RCE_Rebate_TTC__c : ' + currentQuoteLineItem.RCE_Rebate_TTC__c );
                        System.debug(logginglevel.WARN,'### currentQuoteLineItem.Reason_For_Order__c : ' + currentQuoteLineItem.Reason_For_Order__c );
                        System.debug(logginglevel.WARN,'### currentQuoteLineItem.Credit_Unit_Price_HT__c : ' + currentQuoteLineItem.Credit_Unit_Price_HT__c );
                        System.debug(logginglevel.WARN,'### currentQuoteLineItem.Credit_Quantity__c : ' + currentQuoteLineItem.Credit_Quantity__c );
                        System.debug(logginglevel.WARN,'### this.parent.currentQuote.Credit_Price_Date__c : ' + this.parent.currentQuote.Credit_Price_Date__c );
                        System.debug(logginglevel.WARN,'### this.parent.currentQuote.Credit_Comment_For_Customer__c : ' + this.parent.currentQuote.Credit_Comment_For_Customer__c );
                        
                        if( this.parent.currentQuote.Client_Reenlistment__c == 'Contract' ){
                            ptlCode = (currentQuoteLineItem.Quote_PTL__r.Opportunity_PTL__r.PTLSynchroSAP__c != null) ? currentQuoteLineItem.Quote_PTL__r.Opportunity_PTL__r.PTLSynchroSAP__c : String.valueOf(currentQuoteLineItem.Quote_PTL__r.Name).substring(0,10);
                        }else{
                            ptlCode = (currentQuoteLineItem.Quote_PTL__r.PTL_Name__c != null) ? currentQuoteLineItem.Quote_PTL__r.PTL_Name__c : String.valueOf(currentQuoteLineItem.Quote_PTL__r.Name).substring(0,10);
                        }
                        
                        // RebateType == REBATE : FLA ajout Contract
                        if( (this.parent.currentQuote.Client_Reenlistment__c == 'Commercial offer' && this.parent.currentQuote.Type_de_remuneration__c != 'Avoir') || (this.parent.currentQuote.Client_Reenlistment__c == 'Contract') ){
                            // We may have several rebates filled on the same QuoteLineItem. If so, we need to send them separately
                            // RCE
                            if( currentQuoteLineItem.RCE_Rebate_TTC__c != null && currentQuoteLineItem.RCE_Rebate_TTC__c != 0 && String.isNotBlank(currentQuoteLineItem.Reason_For_Order__c) ){
                                // Init the ZBAPI_CRM_DEL_PT
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                //In case of GEB and GER Consumer, since the QLIs don't have PTLs we need some mandatory information on Quote instead of Quote_PTL
                                //if(this.parent.IM_SPART.equals('41') || (this.parent.isGERConsumer)){
                                //    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = this.parent.IM_SOLD_TO;
                                //}else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                //}
                                System.debug(logginglevel.WARN,'### IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE : ' + IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE );
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                if( currentQuoteLineItem.PricebookEntry.Product2.Family == 'Produit' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = (currentQuoteLineItem.Reason_For_Order__c == '000') ? 'RCE_DED' : 'RCE_REMB';   // To determine outside of code ?
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'RCC_DED';
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.RCE_Rebate_HT__c;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                if( this.parent.currentQuote.Client_Reenlistment__c == 'Contract' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c : null;
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (currentQuoteLineItem.Rebate_Starting_Date__c != null) ? currentQuoteLineItem.Rebate_Starting_Date__c : null;
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = DateTime.valueOf('9999-12-31 09:00:00');   // ( currentQuoteLineItem.Rebate_Starting_Date__c != null && currentQuoteLineItem.Cyclical_Rebate_Months__c != null ) ? currentQuoteLineItem.Rebate_Starting_Date__c.addMonths(currentQuoteLineItem.Cyclical_Rebate_Months__c.intValue()) : DateTime.valueOf('9999-12-31 09:00:00');
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = (currentQuoteLineItem.Reason_For_Order__c == '000') ? '' : currentQuoteLineItem.Reason_For_Order__c.left(3);   // Value '000' is a fictional value for the RCE type that doesn't expect a Reason for order so we replace it with an empty value
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = 0;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = '';

                                cptRebatesToBAPI++;
                                if( !this.parent.rebateTypes.contains('RCE') ) this.parent.rebateTypes += ' RCE';
                            }
                            
                            // RConj
                            if( currentQuoteLineItem.Cyclical_Rebate_TTC__c != null && currentQuoteLineItem.Cyclical_Rebate_TTC__c != 0 ){
                                // Init the ZBAPI_CRM_DEL_PT
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                //In case of GEB and GER Consumer, since the QLIs don't have PTLs we need some mandatory information on Quote instead of Quote_PTL
                                //if(this.parent.IM_SPART.equals('41') || (this.parent.isGERConsumer)){
                                //    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = this.parent.IM_SOLD_TO;
                                //}else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                //}
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'RCONJ';   // To determine outside of code ?
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Cyclical_Rebate_HT__c;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                if( this.parent.currentQuote.Client_Reenlistment__c == 'Contract' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c : null;
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = ( this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null && currentQuoteLineItem.Cyclical_Rebate_Months__c != null ) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c.addMonths(currentQuoteLineItem.Cyclical_Rebate_Months__c.intValue()).addDays(-1) : DateTime.valueOf('9999-12-31 09:00:00');
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (currentQuoteLineItem.Rebate_Starting_Date__c != null) ? currentQuoteLineItem.Rebate_Starting_Date__c : null;
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = ( currentQuoteLineItem.Rebate_Starting_Date__c != null && currentQuoteLineItem.Cyclical_Rebate_Months__c != null ) ? currentQuoteLineItem.Rebate_Starting_Date__c.addMonths(currentQuoteLineItem.Cyclical_Rebate_Months__c.intValue()).addDays(-1) : DateTime.valueOf('9999-12-31 09:00:00');
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = '';   // Value is empty for RConj
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = 0;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = '';

                                cptRebatesToBAPI++;
                                if( !this.parent.rebateTypes.contains('RCONJ') ) this.parent.rebateTypes += ' RCONJ';
                            }

                            // RComm
                            if( currentQuoteLineItem.Commercial_Rebate_TTC__c != null && currentQuoteLineItem.Commercial_Rebate_TTC__c != 0 && (this.parent.currentQuote.Client_Reenlistment__c == 'Contract') ){
                                // Init the ZBAPI_CRM_DEL_PT
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                if( currentQuoteLineItem.PricebookEntry.Product2.Family == 'Produit' || currentQuoteLineItem.PricebookEntry.Product2.Payment_type__c == 'Abonnement' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'VCT_DED';
                                }else if( currentQuoteLineItem.PricebookEntry.Product2.Payment_type__c == 'Consignation' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'RCG_DED';
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;

                                // RComm rebate on products SPPABO0010 and SPPABO0008 are stored as monthly value on Actions Co but need to be sent as annual value (*12) to SAP
                                if( currentQuoteLineItem.PricebookEntry.Product2.ProductCode == 'SPPABO0010' || currentQuoteLineItem.PricebookEntry.Product2.ProductCode == 'SPPABO0008' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Commercial_Rebate_HT__c * 12;
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Commercial_Rebate_HT__c;
                                }

                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c : null;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = DateTime.valueOf('9999-12-31 09:00:00');
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                // If product family == Product : UNIT_QTE = TO, otherwise UNIT_QTE = PCE
                                if( currentQuoteLineItem.PricebookEntry.Product2.Family == 'Produit' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'PCE';
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = '';   // Value is empty for RComm
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = 0;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = '';

                                cptRebatesToBAPI++;
                                if( !this.parent.rebateTypes.contains('RCOM') ) this.parent.rebateTypes += ' RCOM';
                            }

                            // Action Co
                            if( currentQuoteLineItem.PricebookEntry.Product2.Family == 'Produit' && this.parent.currentQuote.Action_Commerciale__c != null && 
                                    ( this.parent.currentQuote.Action_Commerciale__r.Fixed_Price__c || 
                                    this.parent.currentQuote.Action_Commerciale__r.Locked_Price__c || 
                                    this.parent.currentQuote.Action_Commerciale__r.Locked_Price_1_Year__c ||
                                    this.parent.currentQuote.Action_Commerciale__r.Locked_Price_2_Years__c || 
                                    this.parent.currentQuote.Action_Commerciale__r.Locked_Price_3_Years__c ) ){
                                // Init the ZBAPI_CRM_DEL_PT
                                System.debug(logginglevel.WARN,'### ActionCo : ' + this.parent.currentQuote.Action_Commerciale__r.Name );
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                if( this.parent.currentQuote.Product_Scale__c == 'CART1' || this.parent.currentQuote.Product_Scale__c == 'CART2' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'PV3_PRIX';
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'PV5_PRIX';
                                }
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;

                                /*if( this.parent.currentQuote.Market_type__c == 'DOM' ){
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.New_Price_HT__c;  // In this case we need to send the price returned by the SAP Pricing BAPI
                                }else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Fixed_Price_HT__c;  // In this case we need to send the price returned by the SAP Pricing BAPI without the TICPE amount
                                }*/
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Fixed_Price_HT__c;  // For ZPV3 and ZPV5 we need to send the price returned by the SAP Pricing BAPI without the TICPE amount
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c : null;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = this.parent.currentQuote.Opportunity.Contract_Start_Date__c.addYears(iLockedPriceDurationInYears);
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = this.parent.currentQuote.Action_Commerciale__r.Name;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = '';   // Value is empty for Action Co
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = 0;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = '';

                                cptRebatesToBAPI++;
                            }

                            // Remise post prix fixe
                            if( currentQuoteLineItem.PricebookEntry.Product2.Family == 'Produit' && currentQuoteLineItem.Remise_Post_Offre_TTC__c != 0 ){
                                // Init the ZBAPI_CRM_DEL_PT
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'VCT_DED';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Remise_Post_Offre_HT__c;  // In this case we need to send the price returned by the SAP Pricing BAPI
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = (this.parent.currentQuote.Opportunity.Contract_Start_Date__c != null) ? this.parent.currentQuote.Opportunity.Contract_Start_Date__c : null;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = DateTime.valueOf('9999-12-31 09:00:00');
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = this.parent.currentQuote.Action_Commerciale__r.Name;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = '';   // Value is empty for Action Co
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = 0;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = '';

                                cptRebatesToBAPI++;
                            }
                    
                        // RebateType == CREDIT
                        }else if( this.parent.currentQuote.Client_Reenlistment__c == 'Credit' || (this.parent.currentQuote.Client_Reenlistment__c == 'Commercial offer' && this.parent.currentQuote.Type_de_remuneration__c == 'Avoir')){

                            if( currentQuoteLineItem.Credit_Unit_Price_HT__c != null && currentQuoteLineItem.Credit_Unit_Price_HT__c != 0 && this.parent.currentQuote.Credit_Price_Date__c != null /*&& String.isNotBlank(this.parent.currentQuote.Credit_Comment_For_Customer__c)*/ ){
                                // Init the ZBAPI_CRM_DEL_PT
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI] = new microsoftLobservicesSapRebate.ZBAPI_CRM_REMISE();
                                
                                //In case of GEB and GER Consumer, since the QLIs don't have PTLs we need some mandatory information on Quote instead of Quote_PTL
                                //if(this.parent.IM_SPART.equals('41') || (this.parent.isGERConsumer)){
                                //    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = this.parent.IM_SOLD_TO;
                                //}else{
                                    IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE = ptlCode;
                                //}
                                System.debug(logginglevel.WARN,'### IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE : ' + IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].POINT_LIVRE );
                                
                                // Fill the ZBAPI_CRM_REMISE according to the information of the currentQuoteLineItem
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].TYPE_GEST_CO = 'AVOIR';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ARTICLE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].MONTANT = currentQuoteLineItem.Credit_Unit_Price_HT__c;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DEVISE = 'EUR';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_DEB = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DATE_FIN = DateTime.valueOf('9999-12-31 09:00:00');   // A date is expected but SAP won't use it in case of Credit rebate type
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_PRIX = 1;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].UNITE_QTE = 'TO';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].FLAG_SUPP = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ACTION_COM = '';
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].RAISON_GEST = this.parent.currentQuote.Opportunity.Reason__c;
                                // New fields for credits
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].DT_PRIX = this.parent.currentQuote.Credit_Price_Date__c;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].QUANTITE = currentQuoteLineItem.Credit_Quantity__c;
                                IT_PTL.ZBAPI_CRM_REMISE[cptRebatesToBAPI].ZTEXT_TXT = this.parent.currentQuote.Credit_Comment_For_Customer__c;

                                cptRebatesToBAPI++;
                                if( !this.parent.rebateTypes.contains('Avoir') ) this.parent.rebateTypes += ' Avoir';
                            }
                        }
                        
                    }
                }
                //Do request and retrieve response
                microsoftLobservicesSapRebate.ZBAPI_CRM_REMISEResponse_element response_x;
                if (Test.isRunningTest()){
                    response_x = AP_WrapperForSOAPCallRebate.ZBAPI_CRM_REMISEDummy();

                } else {
                    if(AP_PricingUtilities.getCustomSettingValue('Rebate_doCallOuts').equals('1')){
                         //Temporary for DEBUG
                        String oldEndPoint =  this.parent.webserviceSOAP.endpoint_x;
                        this.parent.webserviceSOAP.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
                        try{
                            System.debug(logginglevel.WARN,'### this.parent.webserviceSOAP.endpoint_x : ' + this.parent.webserviceSOAP.endpoint_x );
                            response_x = this.parent.webserviceSOAP.ZBAPI_CRM_REMISE(
                                                        this.parent.IM_CANAL,
                                                        this.parent.IM_DONNEUR_ORDRE,
                                                        this.parent.IM_MODE,
                                                        this.parent.IM_ORGA_COM,
                                                        this.parent.IM_SECTEUR,
                                                        ET_RETURN,
                                                        IT_PTL
                                                        );
                        System.debug('######### 2 #########' + response_x);
                                                    
                        }catch(Exception e){
                        }finally{
                            this.parent.webserviceSOAP.endpoint_x = oldEndPoint;
                            System.debug(logginglevel.WARN,'### this.parent.webserviceSOAP.endpoint_x : ' + this.parent.webserviceSOAP.endpoint_x );
                            response_x = this.parent.webserviceSOAP.ZBAPI_CRM_REMISE(
                                                        this.parent.IM_CANAL,
                                                        this.parent.IM_DONNEUR_ORDRE,
                                                        this.parent.IM_MODE,
                                                        this.parent.IM_ORGA_COM,
                                                        this.parent.IM_SECTEUR,
                                                        ET_RETURN,
                                                        IT_PTL
                                                        );
                                       
                        }
                    }else{
                        response_x = AP_WrapperForSOAPCallRebate.ZBAPI_CRM_REMISEDummy();
                    }
                }
                System.debug(logginglevel.WARN,'### String.valueOf(response_x) : ' + String.valueOf(response_x) );
                this.parent.oBapiTracker.Response2__c = String.valueOf(response_x);
                this.parent.oBapiTracker.Endpoint__c = this.parent.webserviceSOAP.endpoint_x; 
                
                // Fetching for the current CALLOUT
                this.sapResponses.exControl = response_x.EX_CONTROL;
                System.debug(logginglevel.WARN,'### this.sapResponses.exControl : ' + this.sapResponses.exControl );
                
                this.fetchReturnFields(response_x.ET_RETURN);
                System.debug(logginglevel.WARN,'### response_x.ET_RETURN : ' + response_x.ET_RETURN );
                
            }

        }
        
        
        private void fetchReturnFields(microsoftLobservicesSapRebate.ArrayOfBAPIRET2 returnFieldsListBapi){
            List<ReturnFields> returnFieldsList = new List<ReturnFields>();
            if( returnFieldsListBapi != null && returnFieldsListBapi.BAPIRET2 != null){
                for(microsoftLobservicesSapRebate.BAPIRET2 returnFields : returnFieldsListBapi.BAPIRET2){
                    ReturnFields r  = new ReturnFields();
                    r.Type_x = returnFields.TYPE_x;
                    r.ID =  returnFields.ID;
                    r.Number_x = returnFields.NUMBER_x.format();
                    r.Message = returnFields.MESSAGE;
                    r.LogNo = returnFields.LOG_NO;
                    r.LogMsgNo = returnFields.LOG_MSG_NO.format();
                    r.MessageV1 = returnFields.MESSAGE_V1;
                    r.MessageV2 = returnFields.MESSAGE_V2;
                    r.MessageV3 = returnFields.MESSAGE_V3;
                    r.MessageV4 = returnFields.MESSAGE_V4;
                    r.Parameter = returnFields.PARAMETER;
                    r.Row = returnFields.ROW;
                    r.Field = returnFields.FIELD;
                    r.System_x = returnFields.SYSTEM_x;
                    returnFieldsList.add(r);
                }
            }
            if(!returnFieldsList.isEmpty()){
                this.sapResponses.returnFieldsPacket.add(returnFieldsList);
            }
        }
        
    }
    
    
    //Process SAP Responses
    private class AP_ProcessSAPResponse{
        private AP_ProcessSAPRequest sapRequests;
        
        private String exControl;
        
        //private String rebateTypes;  // Build a string to concatenate the rebate types to rename the opportunity and quote
        
        private List< List<ReturnFields> >  returnFieldsPacket; // Store packet of ReturnFields got for each callout
        
        private List<AP_VFMessage> APVFMessageList; // Will store messages of CRM and those from SAP

        private Boolean errorGotFromSAP;
        private Boolean atLeastOneRebateCreatedInSAP;
            
        public AP_ProcessSAPResponse(AP_ProcessSAPRequest sapRequests){
            this.sapRequests = sapRequests;
            this.returnFieldsPacket = new List< List<ReturnFields> >();
            this.APVFMessageList = new List<AP_VFMessage>();
            this.errorGotFromSAP = false;
            this.atLeastOneRebateCreatedInSAP = false;
        }
        
        public Boolean getErrorGotFromSAP(){
            return this.errorGotFromSAP;
        }
        
        public Boolean getAtLeastOneRebateCreatedInSAP(){
            return this.atLeastOneRebateCreatedInSAP;
        }
        
        public String getExControl(){
            return this.exControl;
        }
        
        public List<QuoteLineItem> getQuoteLineItemList(){
            //GET the QuoteLineItems (references) of the request having the updated prices
            List<List<QuoteLineItem>> currentQuoteLineItemPacket = this.sapRequests.quoteLineItemsPacket; 
            
            //Merge the packets 
            List<QuoteLineItem> currentQuoteLineItemList = new List<QuoteLineItem>(); 
            for(List<QuoteLineItem> l : currentQuoteLineItemPacket){
                currentQuoteLineItemList.addAll(l);
            }
            return currentQuoteLineItemList;
        }
        
        public List<ReturnFields> getReturnFieldsList(){                
            //Merge the packets 
            List<ReturnFields> currentReturnFieldsList = new List<ReturnFields>(); 
            for(List<ReturnFields> l : this.returnFieldsPacket){
                currentReturnFieldsList.addAll(l);
            }
            return currentReturnFieldsList;
        }
        
        public List<AP_VFMessage> getAPVFMessageList(){ 
            // Adding to all CRM messages if existed, those from SAP
            this.fetchAPVFMessageList();
            return this.APVFMessageList;
        }
        
        private void fetchAPVFMessageList(){
           List<ReturnFields> returnFieldsList =  this.getReturnFieldsList(); // ReturnFields after the merge
           
           if(returnFieldsList != null){
               for(AP_WrapperForSOAPCallRebate.ReturnFields ret : returnFieldsList){
                       if(ret.Type_x != null){
                           //ApexPages.Severity severity = ret.getSeverityFromType(ret.Type_x);
                           String type = ret.Type_x;
                           String summary = System.Label.sap_message + ' : ' + ' PTL ' + ret.Field + ' | ' + ret.Message;
                           String detail = System.Label.details_message + ' --> ID : ' + ret.ID + ', NUMBER : ' + ret.Number_x + ', LOG_NO : ' + ret.LogNo
                                        + ', LOG_MSG_NO : ' + ret.LogMsgNo + ', MESSAGE V1 : ' + ret.MessageV1 + ', MESSAGE V2 : ' + ret.MessageV2
                                        + ', MESSAGE V3 : ' + ret.MessageV3 + ', MESSAGE V4 : ' + ret.MessageV4 + ', PARAM : ' + ret.Parameter + ', ROW : ' + ret.Row 
                                        + ', FIELD : ' + ret.Field + ', SYSTEM : ' + ret.System_x;               
                           this.APVFMessageList.add(new AP_VFMessage(type, summary, detail));
                           if(type == 'E'){
                                this.errorGotFromSAP = true;
                           }else if(type == 'S'){
                                this.atLeastOneRebateCreatedInSAP = true;
                           }
                       }    
               } 
            }            
        }
    }
    
    
    public class ReturnFields {      
        public String Type_x;
        public String ID;
        public String Number_x;
        public String Message;
        public String LogNo;
        public String LogMsgNo;
        public String MessageV1;
        public String MessageV2;
        public String MessageV3;
        public String MessageV4;
        public String Parameter;
        public Integer Row;
        public String Field;
        public String System_x;
    }
    
    //Wrap the data received from SAP (soap/bapi) format to a format that the controller expects
    public class AP_WrapperDataForController{
        private AP_WrapperForSOAPCallRebate parent;
        
        public String exControl; 

        public  List<QuoteLineItem> listQuoteLineItemToCtrl; // List of QuoteLineItem that the controller will receive
       
        public List<ReturnFields> returnFieldsList;       
        public  List<AP_VFMessage> listAPVFMessage; // List of AP_VFMessage that the controller will receive
        
        public boolean errorGotFromSAP;
        public boolean atLeastOneRebateCreatedInSAP;  // Set to True if at least one rebate has successfully been created in SAP so we prevent users to send this quote again
        
        public AP_WrapperDataForController(AP_WrapperForSOAPCallRebate parent,
                                           String exControl,
                                           List<QuoteLineItem> QLIList,
                                           List <ReturnFields> returnFieldsList,
                                           List<AP_VFMessage> APVFMessageList,
                                           Boolean errorGotFromSAP,
                                           Boolean atLeastOneRebateCreatedInSAP) {
            this.parent = parent;
            this.exControl = exControl;
            this.listQuoteLineItemToCtrl = QLIList;
            this.returnFieldsList = returnFieldsList;
            this.listAPVFMessage = APVFMessageList;
            this.errorGotFromSAP = errorGotFromSAP;
            this.atLeastOneRebateCreatedInSAP = atLeastOneRebateCreatedInSAP;
        }
        
    }
    
    
    public static microsoftLobservicesSapRebate.ZBAPI_CRM_RemiseResponse_element ZBAPI_CRM_RemiseDummy() {
                                            
        //TODO CONSTRUCT A DUMMY RESPONSE
        microsoftLobservicesSapRebate.ZBAPI_CRM_RemiseResponse_element responseDummy = new microsoftLobservicesSapRebate.ZBAPI_CRM_RemiseResponse_element();
        
        responseDummy.EX_CONTROL = 'OK';
        
        
        responseDummy.ET_RETURN = new microsoftLobservicesSapRebate.ArrayOfBAPIRET2();      
        responseDummy.ET_RETURN.BAPIRET2 = new microsoftLobservicesSapRebate.BAPIRET2[2];
        
        responseDummy.ET_RETURN.BAPIRET2[0] = new microsoftLobservicesSapRebate.BAPIRET2();
        responseDummy.ET_RETURN.BAPIRET2[0].TYPE_x = 'S';
        responseDummy.ET_RETURN.BAPIRET2[0].ID = 'PTLCODE1 RCE_REMB';
        responseDummy.ET_RETURN.BAPIRET2[0].NUMBER_x = 0;
        responseDummy.ET_RETURN.BAPIRET2[0].MESSAGE = 'Return message from SAP';
        responseDummy.ET_RETURN.BAPIRET2[0].LOG_NO = '';
        responseDummy.ET_RETURN.BAPIRET2[0].LOG_MSG_NO = 0;
        responseDummy.ET_RETURN.BAPIRET2[0].MESSAGE_V1 = '';
        responseDummy.ET_RETURN.BAPIRET2[0].MESSAGE_V2 = '';
        responseDummy.ET_RETURN.BAPIRET2[0].MESSAGE_V3 = '';
        responseDummy.ET_RETURN.BAPIRET2[0].MESSAGE_V4 = '';
        responseDummy.ET_RETURN.BAPIRET2[0].PARAMETER = '';
        responseDummy.ET_RETURN.BAPIRET2[0].ROW = 0;
        responseDummy.ET_RETURN.BAPIRET2[0].FIELD = 'PTLCODE1';
        responseDummy.ET_RETURN.BAPIRET2[0].SYSTEM_x = '';
        
        
        responseDummy.ET_RETURN.BAPIRET2[1] = new microsoftLobservicesSapRebate.BAPIRET2();
        responseDummy.ET_RETURN.BAPIRET2[1].TYPE_x = 'S';
        responseDummy.ET_RETURN.BAPIRET2[1].ID = 'PTLCODE2 RCE_REMB';
        responseDummy.ET_RETURN.BAPIRET2[1].NUMBER_x = 0;
        responseDummy.ET_RETURN.BAPIRET2[1].MESSAGE = 'Return message from SAP';
        responseDummy.ET_RETURN.BAPIRET2[1].LOG_NO = '';
        responseDummy.ET_RETURN.BAPIRET2[1].LOG_MSG_NO = 0;
        responseDummy.ET_RETURN.BAPIRET2[1].MESSAGE_V1 = '';
        responseDummy.ET_RETURN.BAPIRET2[1].MESSAGE_V2 = '';
        responseDummy.ET_RETURN.BAPIRET2[1].MESSAGE_V3 = '';
        responseDummy.ET_RETURN.BAPIRET2[1].MESSAGE_V4 = '';
        responseDummy.ET_RETURN.BAPIRET2[1].PARAMETER = '';
        responseDummy.ET_RETURN.BAPIRET2[1].ROW = 0;
        responseDummy.ET_RETURN.BAPIRET2[1].FIELD = 'PTLCODE2';
        responseDummy.ET_RETURN.BAPIRET2[1].SYSTEM_x = '';
        
        
        return responseDummy;
    }
    
}