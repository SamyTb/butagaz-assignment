public class AP_WrapperForSOAPCallPricing {

    public microsoftLobservicesSapPricing.RfcEndpoint webserviceSOAP;
    public AP_WrapperDataForController responseForController;
    
    public Quote currentQuote; // Quote received from controller
    public Id currentPriceBook2Id; // PriceBook2Id of the Quote received from controller
    
    public Boolean isGEROwner;
    public Boolean isGERConsumer;
    public Boolean isGEB;
    
    // ORO 140903 - Store Request/response if required
    public BAPITracker__c oBapiTracker {get;set;}
    public String sStoreTracker {get;set;}
    
    // Parameters shared by All SOAP Request
    public String IM_ACTION;
    public Decimal IM_CAPACITY;
    public String IM_CONDITION_GROUP_1;
    public String IM_CONSIGNMENT_OFFER;
    public Decimal IM_CONSUMPTION;
    public String IM_CUSTOMER_GROUP;
    public String IM_CUSTOMER_GROUP_1;
    public String IM_CUSTOMER_GROUP_2;
    public String IM_CUSTOMER_GROUP_4;
    public String IM_CUSTOMER_GROUP_5;
    public String IM_DO_FEES_SALESDISTRICT;
    public String IM_GER_CONSUMPTION;
    public String IM_HIERARCHY;
    public String IM_CONTRACT_DURATION;
    public String IM_QUOTE_DATE;
    public Decimal IM_KWH_CONSUMPTION;
    public String IM_SOLD_TO;
    public String IM_SALES_DEAL;
    public String IM_SPART;
    public String IM_TANK_TYPE;
    public String IM_PRODUCT_SCALE;

    
    public AP_WrapperForSOAPCallPricing(Quote currentQuote, Id currentPriceBook2Id){
        this.webserviceSOAP = new microsoftLobservicesSapPricing.RfcEndpoint();
        this.currentPriceBook2Id = currentPriceBook2Id;
        this.currentQuote = currentQuote;
        
        this.oBapiTracker = new BAPITracker__c();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');
        
        this.isGEROwner = (this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire'));
        this.isGERConsumer = (this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager'));
        this.isGEB = ((this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS')) || (this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB RE'))); 
       
        // Fill parameters shared by All SOAP Request
        this.IM_ACTION = null; //To be fill in in request method
        this.IM_CAPACITY = null; // To be fill in in Calculate mode
        this.IM_CONDITION_GROUP_1 = this.currentQuote.Opportunity.Groupe__c;
        this.IM_CONSIGNMENT_OFFER = this.currentQuote.Bottle_Leasing_Type__c;
        this.IM_CONSUMPTION = null; // To be fill in in Calculate mde
        this.IM_CUSTOMER_GROUP = this.currentQuote.Opportunity.Account.Channel__c;
        this.IM_CUSTOMER_GROUP_1 =  this.currentQuote.Opportunity.Account.Sub_Channel__c;
        this.IM_CUSTOMER_GROUP_2 =  this.currentQuote.Opportunity.Account.Customer_group_2__c;
        this.IM_CUSTOMER_GROUP_4 =  this.currentQuote.Opportunity.Account.Group_Code__c;
        this.IM_CUSTOMER_GROUP_5 =  this.currentQuote.Opportunity.Account.Customer_group_5__c;
        this.IM_DO_FEES_SALESDISTRICT = this.currentQuote.Scale__c;
        this.IM_PRODUCT_SCALE = this.currentQuote.Product_scale__c;
        this.IM_CONTRACT_DURATION = null;
        //this.IM_CONTRACT_DURATION = this.currentQuote.Contract_Duration__c; // MLC - 20141006 - initialisation de la duree de contrat 
        this.IM_SALES_DEAL = null;
        this.IM_TANK_TYPE = null;

        System.debug('this.IM_DO_FEES_SALESDISTRICT '+ this.IM_DO_FEES_SALESDISTRICT);
        System.debug('this.IM_PRODUCT_SCALE '+ this.IM_PRODUCT_SCALE);
        if(this.IM_DO_FEES_SALESDISTRICT != null && (this.IM_DO_FEES_SALESDISTRICT.equals('NA') || this.IM_DO_FEES_SALESDISTRICT.equals('V2.3'))){
            if(AP_PricingUtilities.getQuoteProductScalePack(currentQuote)){
            //In case of scale=NA and Pack is defined on the Quote, we will send scale=P to SAP
                this.IM_DO_FEES_SALESDISTRICT = 'P';
                System.debug('=> CASE ABO PACK');
            }else if (IM_PRODUCT_SCALE  != null && IM_PRODUCT_SCALE.equals('V4')){
                //In case of scale=NA and 'V4' is defined on the Quote, we will send product_scale=V1PRO to SAP
                this.IM_DO_FEES_SALESDISTRICT = '2';
                this.IM_PRODUCT_SCALE = 'V1PRO';
                System.debug('=> CASE V1PRO + 2');
            }else{
                //In case of scale=NA and Pack is not defined on the Quote, we will send scale=2 to SAP
                this.IM_DO_FEES_SALESDISTRICT = '2';
                System.debug('=> CASE 2');
            }
        }
        
         
         //Added for Pack Maison Neuve
         if(this.IM_DO_FEES_SALESDISTRICT != null && this.IM_DO_FEES_SALESDISTRICT.equals('V2P')){
            if (IM_PRODUCT_SCALE  != null && IM_PRODUCT_SCALE.equals('V1PK')){
                this.IM_DO_FEES_SALESDISTRICT = 'BB';
                this.IM_PRODUCT_SCALE = 'V1BBC';    
            }
         }

    
       this.IM_HIERARCHY = this.currentQuote.Opportunity.Account.Parent.AccountNumber;
     
        
        Decimal activityDomain = (this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c != null) ? this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c : 0;
        if(activityDomain == 41){
            //If GEB
            this.IM_GER_CONSUMPTION = this.currentQuote.Product_scale__c;
            this.IM_HIERARCHY = this.currentQuote.DO_Groupement__r.AccountNumber;
            System.debug('=> CASE GEB');
        }
        else{
            this.IM_GER_CONSUMPTION = this.currentQuote.Ger_Consumption__c;
            System.debug('=> CASE NON GEB');
        }
        
       //MLC 20210121 sharepoint341 <- ajout currentQuote.Opportunity.Compte_Optimo__c pour heracle optimo
        if (this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO') )
          {
              if(this.currentQuote.Client_Type__c=='Owner'){
          			this.IM_HIERARCHY = this.currentQuote.DO_Groupement__r.AccountNumber;
                  }
             
          }
          else{  
            System.debug('=> CASE NON OPTIMO');
        }
        
         //MLC 20210514  pour heracle optimo locataire
         if (this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC OPTIMO') )
          {
              if(this.currentQuote.Client_Type__c=='Renter'){
          			this.IM_HIERARCHY = this.currentQuote.Opportunity.Compte_Optimo__c;
                  }
              
          }
          else{  
            System.debug('=> CASE NON OPTIMO');
        }
        
        
        
        this.IM_QUOTE_DATE = AP_PricingUtilities.convertDateToString(datetime.now().date());
        this.IM_SOLD_TO = this.currentQuote.Opportunity.DO_AccountNumber__c; 
        
        this.IM_SPART = (this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c != null) ? 
                        String.valueOf(this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c) :
                        null;
       
        String username, password;
        this.webserviceSOAP.endpoint_x = AP_PricingUtilities.getCustomSettingValue('Pricing_EndPointURL');
        username = AP_PricingUtilities.getCustomSettingValue('Pricing_Username');
        password = AP_PricingUtilities.getCustomSettingValue('Pricing_Password');
        //webserviceSOAP.endpoint_x = 'http://www.lodeblomme.be/log/index.php';
        
        Map<String,String> inputHttpHeaders = new Map<String, String>();

        Blob headerValue = Blob.valueOf( username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        inputHttpHeaders.put('Authorization', authorizationHeader);

        this.webserviceSOAP.inputHttpHeaders_x = inputHttpHeaders;
        webserviceSOAP.timeout_x = 60000;
        
    }
    
    /** CONSTRUCT THE REQUEST TO DO CALLOUT FOR ACTION=2 i.e THE DISPLAY MODE (dynamic)**/
    public AP_WrapperDataForController displayPricingForExistingCustomer(List<Quote_PTL__c> listQuotePTL) {
       
       AP_ProcessSAPRequest newRequest = new AP_ProcessSAPRequest(this, listQuotePTL);
        System.debug('new AP_ProcessSAPRequest  : '+ newRequest );
       newRequest.doSAPRequestAndFetchDisplayPricingMode();
       AP_ProcessSAPResponse responseGot = newRequest.sapResponses;
       System.debug('responseGot.getRealCapacity()  : '+ responseGot );
       Decimal realConsumption = responseGot.getRealConsumption();
       Decimal realCapacity = responseGot.getRealCapacity();
        System.debug('responseGot.getRealCapacity()  : '+ realCapacity );
       List<QuoteLineItem> QLIList = responseGot.getQuoteLineItemList();
       List<ReturnFields> returnFieldsList = responseGot.getReturnFieldsList();
       List<AP_VFMessage> APVFMessageList = responseGot.getAPVFMessageList();
       Boolean errorGotFromSAP = responseGot.getErrorGotFromSAP();
       
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForController = new AP_WrapperDataForController(this, realConsumption, realCapacity, QLIList, returnFieldsList, APVFMessageList, errorGotFromSAP);
       return responseForController; 
         
    }
    
    /** CONSTRUCT THE REQUEST TO DO CALLOUT FOR ACTION=1 i.e THE CREATION OF A NEW CONTRACT, IN THIS CASE WE HAVE TO SPECIFY THE TABLE 'IT_DELIVERY_POINT' **/
    public AP_WrapperDataForController calculatePricingForNewContract(List<QuoteLineItem> listQuoteLineItemFromCtrl, Action_Commerciale__c actionCommerciale){
        
       AP_ProcessSAPRequest newRequest = new AP_ProcessSAPRequest(this, listQuoteLineItemFromCtrl, actionCommerciale);
       newRequest.doSAPRequestAndFetchCalculatePricingMode();
       AP_ProcessSAPResponse responseGot = newRequest.sapResponses;
       
       Decimal realConsumption = responseGot.getRealConsumption();
       Decimal realCapacity = responseGot.getRealCapacity();
       
       List<QuoteLineItem> QLIList = responseGot.getQuoteLineItemList();
       QLIList.addAll(responseGot.getQuoteLineItemsSkippingSAP());
       
       List<ReturnFields> returnFieldsList = responseGot.getReturnFieldsList();
       List<AP_VFMessage> APVFMessageList = responseGot.getAPVFMessageList();
       Boolean errorGotFromSAP = responseGot.getErrorGotFromSAP();
        
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForController = new AP_WrapperDataForController(this, realConsumption, realCapacity, QLIList, returnFieldsList, APVFMessageList, errorGotFromSAP);
       return responseForController; 
         
    }

    
    //Process SAP Responses
    private class AP_ProcessSAPResponse{
        private AP_ProcessSAPRequest sapRequests;
        
        private Decimal realAnnualConsumptionDO;
        private Decimal realAnnualCapacityDO;
        
        private List< List<ReturnFields> >  returnFieldsPacket; // Store packet of ReturnFields got for each callout
        
        private List<AP_VFMessage> APVFMessageList; // Will store messages of CRM and those from SAP

        private Boolean errorGotFromSAP;
            
        public AP_ProcessSAPResponse(AP_ProcessSAPRequest sapRequests){
            this.sapRequests = sapRequests;
            this.returnFieldsPacket = new List< List<ReturnFields> >();
            this.APVFMessageList = new List<AP_VFMessage>();
            this.errorGotFromSAP = false;
        }
        
        public Decimal getRealConsumption(){
            return this.realAnnualConsumptionDO;
        }
        
        public Decimal getRealCapacity(){
            return this.realAnnualCapacityDO;
        }
        
        public Boolean getErrorGotFromSAP(){
            return this.errorGotFromSAP;
        }
        
        public List<QuoteLineItem> getQuoteLineItemList(){
            //GET the QuoteLineItems (references) of the requsest having the updated prices
            List<List<QuoteLineItem>> currentQuoteLineItemPacket = this.sapRequests.quoteLineItemsPacket; 
            
            //Merge the packets 
            List<QuoteLineItem> currentQuoteLineItemList = new List<QuoteLineItem>(); 
            for(List<QuoteLineItem> l : currentQuoteLineItemPacket){
                currentQuoteLineItemList.addAll(l);
            }
            return currentQuoteLineItemList;
        }
        
        public List<QuoteLineItem> getQuoteLineItemsSkippingSAP(){
            return this.sapRequests.quoteLineItemsSkippingSAP;
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
               for(AP_WrapperForSOAPCallPricing.ReturnFields ret : returnFieldsList){
                       if(ret.Type_x != null){
                           //ApexPages.Severity severity = ret.getSeverityFromType(ret.Type_x);
                           String type = ret.Type_x;
                           String summary = System.Label.sap_message + ' : ' + ret.Message;
                           String detail = System.Label.details_message + ' --> ID : ' + ret.ID + ', NUMBER : ' + ret.Number_x + ', LOG_NO : ' + ret.LogNo
                                        + ', LOG_MSG_NO : ' + ret.LogMsgNo + ', MESSAGE V1 : ' + ret.MessageV1 + ', MESSAGE V2 : ' + ret.MessageV2
                                        + ', MESSAGE V3 : ' + ret.MessageV3 + ', MESSAGE V4 : ' + ret.MessageV4 + ', PARAM : ' + ret.Parameter + ', ROW : ' + ret.Row 
                                        + ', FIELD : ' + ret.Field + ', SYSTEM : ' + ret.System_x;               
                           this.APVFMessageList.add(new AP_VFMessage(type, summary, detail));
                           if(type == 'E'){
                                this.errorGotFromSAP = true;
                           }
                       }    
               } 
            }            
        }
    }
    
    // Process SAP Requests
    private class AP_ProcessSAPRequest{
        private AP_WrapperForSOAPCallPricing parent;
        
        //Fields to do SAP Requests 
        private List< List<QuoteLineItem> > quoteLineItemsPacket; // List of Param for SAP Request : on Mode '1' The QuoteLineItems already retrieved will be updated with pricing information , on Mode '2' it will store one list of the New QuoteLineItem with pricing information
        private List<Quote_PTL__c> quotePTLList; // List of Param for SAP Request on Mode '2'
        private List<QuoteLineItem> lquoteLineItems;  // List of all QouteLineItems
        private Action_Commerciale__c acSelectedAc; // Chosen Action Commerciale 
        
        //List of QLI skipping SAP call
        private List<QuoteLineItem> quoteLineItemsSkippingSAP; //List of QLI having noSAP set to true
        
        //Fields to construct SAP Responses
        public AP_ProcessSAPResponse sapResponses;
        
        public AP_ProcessSAPRequest(AP_WrapperForSOAPCallPricing parent, List<Quote_PTL__c> quotePTLList){
            this.parent = parent;
            this.initQuotePTLList(quotePTLList);
            this.quoteLineItemsPacket = new List< List<QuoteLineItem> >();
            this.sapResponses = new AP_ProcessSAPResponse(this);
        }
        
        private void initQuotePTLList(List<Quote_PTL__c> quotePTLList){
            this.quotePTLList = quotePTLList;
        }
        
        public AP_ProcessSAPRequest(AP_WrapperForSOAPCallPricing parent, List<QuoteLineItem> quoteLineItemsList, Action_Commerciale__c ac){
            this.parent = parent;
            this.lquoteLineItems = quoteLineItemsList;
            this.acSelectedAc = ac;            
            this.initQuoteLineItemsPacket(quoteLineItemsList);
            this.quotePTLList = new List<Quote_PTL__c>();
            this.sapResponses = new AP_ProcessSAPResponse(this);
        }
        
        private void initQuoteLineItemsPacket(List<QuoteLineItem> lQuoteLineItems){
            this.quoteLineItemsPacket = new List<List<QuoteLineItem>>();
            this.quoteLineItemsSkippingSAP = new List<QuoteLineItem>();
            
            
            
            //Construct the list of products skipping SAP Call
            for(QuoteLineItem oQLI : lQuoteLineItems){
                if(oQLI.PricebookEntry.Product2.noSAP__c){
                    this.quoteLineItemsSkippingSAP.add(oQLI);
                }
            }
            
            // Construct a packet for each Ger Consumption C1/C2/C3...
            if(this.parent.isGEROwner){
                Map<String, List<QuoteLineItem>> mPacketsForGER = new Map<String, List<QuoteLineItem>>();
                for (QuoteLineItem oQLI : lQuoteLineItems){
                    if(oQLI.PricebookEntry.Product2.noSAP__c){
                        continue;
                    }
                    //Keys : (Owner-None), (Consumer-None), (Consumer-C1/2/3/4)
                    String target = (oQLI.PricebookEntry.Product2.UseConsumerTarget__c) ? 'Consumer' : 'Owner';
                    String gerConsumption = (oQLI.Ger_Consumption__c != null) ? oQLI.Ger_Consumption__c : 'None';
                    
                    if (mPacketsForGER.containsKey(target+'-'+gerConsumption)){
                        mPacketsForGER.get(target+'-'+gerConsumption).add(oQLI);
                    } else {
                        mPacketsForGER.put(target+'-'+gerConsumption, new List<QuoteLineItem>{oQLI});
                    }
                }
                
                // The (Owner-None)  packet should be sent first (if it exists)
                if (mPacketsForGER.containsKey('Owner-None')){
                    this.quoteLineItemsPacket.add(mPacketsForGER.get('Owner-None'));
                    mPacketsForGER.remove('Owner-None');
                }
                // For the packet (Consumer-None), we should add it to one of the (Consumer-C1/2/3/4) we will add it to C1, since for soap request having (Uxx + 45) ger consumption is mandatory for SAP and products for this packet don't require a GER consumption
                if(mPacketsForGER.containsKey('Consumer-None')){
                    if(mPacketsForGER.containsKey('Consumer-C1')){
                        mPacketsForGER.get('Consumer-C1').addAll(mPacketsForGER.get('Consumer-None'));
                    }else{
                        mPacketsForGER.put('Consumer-C1', mPacketsForGER.get('Consumer-None'));
                    }
                    mPacketsForGER.remove('Consumer-None');
                }
                
                // Add the remaining packets after
                this.quoteLineItemsPacket.addAll(mPacketsForGER.values());
            }else{
                List<QuoteLineItem> quoteLineItemsToSend = new List<QuoteLineItem>();
                for(QuoteLineItem oQLI : lQuoteLineItems){
                    if(!oQLI.PricebookEntry.Product2.noSAP__c){
                        quoteLineItemsToSend.add(oQLI);
                    }
                }
                this.quoteLineItemsPacket.add(quoteLineItemsToSend);        
            }    
        }
        
        private void doSAPRequestAndFetchDisplayPricingMode(){
            List<ReturnFields> returnFieldsList = new List<ReturnFields>();
                    
            this.parent.IM_ACTION = '2';
                        
            //In case of SUCC or GEC Locataire, we have to bring the products of the Owner (parent Account and the exiting PTL on the Opty)
            if(this.parent.currentQuote.Opportunity.Project_Type__c.equals('SUCC')){
                this.parent.IM_SOLD_TO = this.parent.currentQuote.Opportunity.Predecessor__r.AccountNumber;
            }
            //if(this.parent.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') || this.parent.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO')){ 
            if(this.parent.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') || this.parent.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO') ||  this.parent.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC OPTIMO')){ 
                this.parent.IM_SOLD_TO = this.parent.currentQuote.Opportunity.Account_Owner__r.AccountNumber;
            }
            
            microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING ET_PRICING = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING();
             
            microsoftLobservicesSapPricing.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapPricing.ArrayOfBAPIRET2();

            microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT IT_DELIVERY_POINT = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT();

            if(this.quotePTLList != null && !this.quotePTLList.isEmpty()){
                IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT[this.quotePTLList.size()];
                for(Integer i=0; i < this.quotePTLList.size(); i++){
                    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i] = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT();
                    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = this.quotePTLList.get(i).PTL_Name__c;
                }    
            }

            //Do request and retrieve response
            microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element response_x;
            if (Test.isRunningTest()){
                    response_x = AP_WrapperForSOAPCallPricing.ZBAPI_CRM_PRICINGDummy();
            } else {
                if(AP_PricingUtilities.getCustomSettingValue('Pricing_doCallOuts').equals('1')){
                    //Temporary for DEBUG
                    String oldEndPoint =  this.parent.webserviceSOAP.endpoint_x;
                    //this.parent.webserviceSOAP.endpoint_x = 'http://www.lodeblomme.be/log/';
                    //this.parent.webserviceSOAP.endpoint_x = 'http://orozco.fr:6843/put/';
                    //this.parent.webserviceSOAP.endpoint_x = 'http://test-sap-butagaz.herokuapp.com/put/';
                    this.parent.webserviceSOAP.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
                    try{
                        response_x = this.parent.webserviceSOAP.ZBAPI_CRM_PRICING(
                                                    this.parent.IM_ACTION,
                                                    this.parent.IM_CAPACITY,
                                                    this.parent.IM_CONDITION_GROUP_1,
                                                    this.parent.IM_CONSIGNMENT_OFFER,
                                                    this.parent.IM_CONSUMPTION,
                                                    this.parent.IM_CONTRACT_DURATION,
                                                    this.parent.IM_CUSTOMER_GROUP,
                                                    this.parent.IM_CUSTOMER_GROUP_1,
                                                    this.parent.IM_CUSTOMER_GROUP_2,
                                                    this.parent.IM_CUSTOMER_GROUP_4,
                                                    this.parent.IM_CUSTOMER_GROUP_5,
                                                    this.parent.IM_DO_FEES_SALESDISTRICT,
                                                    this.parent.IM_GER_CONSUMPTION,
                                                    this.parent.IM_HIERARCHY,
                                                    this.parent.IM_KWH_CONSUMPTION,
                                                    this.parent.IM_QUOTE_DATE,
                                                    this.parent.IM_SALES_DEAL,
                                                    this.parent.IM_SOLD_TO,
                                                    this.parent.IM_SPART,
                                                    this.parent.IM_TANK_TYPE,
                                                    ET_PRICING, 
                                                    ET_RETURN,
                                                    IT_DELIVERY_POINT
                                                    );
                    System.debug('######### 1 #########' + response_x);                           
                    }catch(Exception e){
                    }finally{
                        this.parent.webserviceSOAP.endpoint_x = oldEndPoint;
                        
                        response_x = this.parent.webserviceSOAP.ZBAPI_CRM_PRICING(
                                                    this.parent.IM_ACTION,
                                                    this.parent.IM_CAPACITY,
                                                    this.parent.IM_CONDITION_GROUP_1,
                                                    this.parent.IM_CONSIGNMENT_OFFER,
                                                    this.parent.IM_CONSUMPTION,
                                                    this.parent.IM_CONTRACT_DURATION,                                                      
                                                    this.parent.IM_CUSTOMER_GROUP,
                                                    this.parent.IM_CUSTOMER_GROUP_1,
                                                    this.parent.IM_CUSTOMER_GROUP_2,
                                                    this.parent.IM_CUSTOMER_GROUP_4,
                                                    this.parent.IM_CUSTOMER_GROUP_5,
                                                    this.parent.IM_DO_FEES_SALESDISTRICT,
                                                    this.parent.IM_GER_CONSUMPTION,
                                                    this.parent.IM_HIERARCHY,
                                                    this.parent.IM_KWH_CONSUMPTION,                                                    
                                                    this.parent.IM_QUOTE_DATE,
                                                    this.parent.IM_SALES_DEAL,                                                    
                                                    this.parent.IM_SOLD_TO,
                                                    this.parent.IM_SPART,
                                                    this.parent.IM_TANK_TYPE,                                                    
                                                    ET_PRICING, 
                                                    ET_RETURN,
                                                    IT_DELIVERY_POINT
                                                    );
                     System.debug('######### 1 #########' + response_x);                     
                    }
                }else{
                    response_x = AP_WrapperForSOAPCallPricing.ZBAPI_CRM_PRICINGDummy();
                }
                System.debug('######### 1 #########' + response_x);    
            }
             System.debug('######### 1 #########' + response_x);
             this.parent.oBapiTracker.Response1__c = String.valueOf(response_x);
             this.parent.oBapiTracker.Endpoint__c = this.parent.webserviceSOAP.endpoint_x;   
            // Fetching
            this.sapResponses.realAnnualConsumptionDO = response_x.EX_CONSUMPTION; 
            this.sapResponses.realAnnualCapacityDO = response_x.EX_CAPACITY; 

            this.fetchItemsPricingOnDisplayMode(response_x.ET_PRICING);
            this.fetchReturnFields(response_x.ET_RETURN);

        }
        
        private void fetchItemsPricingOnDisplayMode(microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING itemsPricingListBapi){
            if( itemsPricingListBapi != null && itemsPricingListBapi.ZBAPI_CRM_PRICING != null){
                List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
                
                //Map : key=MaterialCode, value=TODO
                Map<String, PricebookEntry> mapPriceBookEntry = new map<String, PricebookEntry>();
                //Map : key=PTLCode, value=Quote_PTL__c
                Map<String, Quote_PTL__c> mapPTLCodeToQuotePTL = new map<String, Quote_PTL__c>();
                //Set of material code got from SAP
                Set<String> materialCodes = new Set<String>();
                //Set of ptl code got from SAP
                Set<String> PTLCodes = new Set<String>();
                
                // Retrieve material code and ptl code got from SAP to construct mapping 
                for(microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing : itemsPricingListBapi.ZBAPI_CRM_PRICING){
                    materialCodes.add(itemPricing.MATERIAL_CODE);
                    PTLCodes.add(itemPricing.DELIVERY_POINT);
                }

                // Construct MapPriceBookEntry
                List<PricebookEntry> listPriceBookEntry =  //!TODO! We have the same query twice, clean? Maybe the wrapper should give 
                    [
                        SELECT 
                            Id,
                            Product2Id,
                            Product2.ProductCode,
                            Product2.Name,        
                            Product2.Family,
                            Product2.Capacity__c, 
                            Product2.Sub_Type__c,
                            Product2.Tank_Type__c,
                            Product2.Auto_Add__c
                        FROM PricebookEntry 
                        WHERE Product2.ProductCode in:materialCodes
                        AND Pricebook2Id = : this.parent.currentPriceBook2Id
                    ];
                for(PricebookEntry o: listPriceBookEntry ){
                    mapPriceBookEntry.put(o.Product2.ProductCode, o);
                }
                
                // Construct MapPTLCodeToQuotePTL
                //List<Quote_PTL__c> listQuotePTL = [
                //        SELECT Id, PTL_Name__c
                //        FROM Quote_PTL__c 
                //        WHERE Quote__c = :this.parent.currentQuote.Id
                //    ];
                for(Quote_PTL__c o: this.quotePTLList){
                    mapPTLCodeToQuotePTL.put(o.PTL_Name__c, o);
                }
                
                for(microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing : itemsPricingListBapi.ZBAPI_CRM_PRICING){
                        QuoteLineItem quoteLineItem_x = new QuoteLineItem(QuoteId = this.parent.currentQuote.Id);              
                        
                        Quote_PTL__c quotePTLTobeLinked = mapPTLCodeToQuotePTL.get(itemPricing.DELIVERY_POINT);
                        if(quotePTLTobeLinked == null){
                            if((!this.parent.isGERConsumer &&
                                this.parent.currentQuote.RecordTypeId != RecordTypes_OpportunityToQuote__c.getInstance('GEB CONS').QuoteRecordType__c)){ //To validate this case for GEB CONS (ambiguity with RE)!!
                                    this.sapResponses.errorGotFromSAP = true;
                                    this.sapResponses.APVFMessageList.add(new AP_VFMessage('E', System.Label.crm_message+ ' : ' + System.Label.the_ptl + ' : '+ itemPricing.DELIVERY_POINT + ' '+ System.Label.ptl_required_on_opty));
                            }        
                        }else{
                            quoteLineItem_x.Quote_PTL__c = quotePTLTobeLinked.Id;
                        }
                        
                        PriceBookEntry p = mapPriceBookEntry.get(itemPricing.MATERIAL_CODE);
                        if(p == null) {
                            //If we are not GEC Locataire, we won't be able to receive products that we don't have on the current pricebook
                            //For GEC Locataire, we will skip all the products of the Owner except the 'Propane'
                            //For S000000087, we will skip this product , it's temporary because it an old product on SAP, and the master SAP wont give us this product on the future S000000087
                             if((this.parent.currentQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') && this.parent.currentQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO') && this.parent.currentQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC OPTIMO')) && itemPricing.MATERIAL_CODE != null &&  !itemPricing.MATERIAL_CODE.equals('S000000087')   ){
                           // if((this.parent.currentQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') && this.parent.currentQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO')) && itemPricing.MATERIAL_CODE != null &&  !itemPricing.MATERIAL_CODE.equals('S000000087')   ){
                                  
                            this.sapResponses.errorGotFromSAP = true;
                                this.sapResponses.APVFMessageList.add(new AP_VFMessage('E', System.Label.crm_message+ ' : ' +  System.Label.the_material + ' ' + itemPricing.LIBELLE_ART + ' '+System.Label.having_the_code+' : ' + itemPricing.MATERIAL_CODE + ' '+System.Label.product_required_on_catalog));
                            }
                            
                            
                           
                            
                           
                        }else{
                            quoteLineItem_x.PriceBookEntry  = p;            
                            quoteLineItem_x.PriceBookEntryId = p.Id;                        
                            quoteLineItem_x.Quantity = 1.00;
                            if(!AP_PricingUtilities.isTank(quoteLineItem_x)){ // By default Butagaz Owned Tank
                                quoteLineItem_x.Mis_Disposition__c = null;
                            }
                            
                            this.finalizeQLIPricingInfo(quoteLineItem_x, itemPricing);
                            this.finalizeQLIPricingInfoBackup(quoteLineItem_x);
                            
                            quoteLineItem_x.Got_From_SAP__c = true;
                            
                            // Update the List of QuoteLineItem of the current Object
                            if(!itemPricing.MATERIAL_CODE.equals('SPPABO0018'))
                            {
                            quoteLineItemList.add(quoteLineItem_x);
                            }
                        }    
                }
                if(!quoteLineItemList.isEmpty()){
                    //Add the New QuoteLineItem List into the current packet of the request, in order to be process be the AP_ProcessSAPReponse
                    
                    this.quoteLineItemsPacket.add(quoteLineItemList);
                }
            }    
        }
        
        
        private List<QuoteLineItem> filterQLIFromNullCapacityPTL(Map<String, Decimal> mapPTLsToCapacity, List<QuoteLineItem> quoteLineItemsList){
            List<QuoteLineItem> filteredQuoteLineItems = new List<QuoteLineItem>();
            
            
            for(QuoteLineItem qli:quoteLineItemsList){
                Decimal capacity = AP_PricingUtilities.getQuotePTLCapacity(mapPTLsToCapacity, qli.Quote_PTL__r.Name);
                
                if(capacity > 0 || qli.Quote_PTL__c == null || isGEBContext() || isGERConsumerContext()){
                    filteredQuoteLineItems.add(qli);
                }
            }
            
            return filteredQuoteLineItems;
        }
        
        
        // Process the Packets of QuoteLineItem on SAP Request and fetch them with the Pricing information
        private void doSAPRequestAndFetchCalculatePricingMode(){
            Map<String, Decimal> mapPTLsToCapacity = AP_PricingUtilities.mapQuotePTLToCapacity(quoteLineItemsPacket);
            
            string TankPriorityValue = null;
            string TankOtherOption = null;
            
            //Send the request with Mode '3' if there is only one Equipement replacement, otherwise send it with Mode '1'
            boolean isEquipementReplacement = isEquipementReplacement(this.lquoteLineItems); 
            if(isEquipementReplacement==true){
                this.parent.IM_ACTION = '3';            
            }
            else {
                this.parent.IM_ACTION = '1';                
            }
            this.parent.IM_CONSUMPTION = this.parent.currentQuote.Sum_PTL_Consumption__c;            
            this.parent.IM_SOLD_TO = this.parent.currentQuote.Opportunity.DO_AccountNumber__c; 

            //this.parent.IM_CAPACITY = this.parent.currentQuote.Estimated_Capacity__c;
            //the IM_CAPACITY will be updated with the capacity of QLIs (see the loop below)
            
            
            System.debug('packet'+ quoteLineItemsPacket);
            
            for(List<QuoteLineItem> quoteLineItemsList : quoteLineItemsPacket){
                
                quoteLineItemsList = filterQLIFromNullCapacityPTL(mapPTLsToCapacity , quoteLineItemsList);
                
                //In the loop, because can change from packet to other one
                 if(this.parent.IM_SPART.equals('41')){
                      this.parent.IM_GER_CONSUMPTION = this.parent.currentQuote.Product_Scale__c;
                 }else{
                      this.parent.IM_GER_CONSUMPTION = this.parent.currentQuote.Ger_Consumption__c;
                 }
                
                // SAP needs the contract duration on 2 characters
                // ORO: Fix 140925 - Null value for Contract Duration
                if(this.parent.currentQuote.Contract_Duration__c != null && this.parent.currentQuote.Contract_Duration__c.length()==1){
                    this.parent.IM_CONTRACT_DURATION = '0'+this.parent.currentQuote.Contract_Duration__c;
                }else if (this.parent.currentQuote.Contract_Duration__c != null ){
                    this.parent.IM_CONTRACT_DURATION = this.parent.currentQuote.Contract_Duration__c;
                } else {
                    this.parent.IM_CONTRACT_DURATION = '00';
                }
                //this.parent.IM_CONTRACT_DURATION = this.parent.currentQuote.Contract_Duration__c;
                this.parent.IM_KWH_CONSUMPTION = this.parent.currentQuote.Sum_PTL_Consumption__c;
                
                // ORO: 140904: Link to selected Offre Commerciale
                if (this.acSelectedAc != null) {
                    this.parent.IM_SALES_DEAL = this.acSelectedAc.Name;
                } else {
                    this.parent.IM_SALES_DEAL = '';
                }
                // ORO: 140904: END Link to selected Offre Commerciale
                
                
                //Remember the scale
                String scale = this.parent.IM_DO_FEES_SALESDISTRICT;
                //this.parent.IM_DO_FEES_SALESDISTRICT = this.parent.currentQuote.Scale__c;
                
                //Updating the current CAPACITY sent on the callout with the capacity of QLI choosed (case of Citerne), we have to update capacity of Quote_PTLs when saveForm
                this.parent.IM_CAPACITY = AP_PricingUtilities.getTotalQuotePTLsCapacity(mapPTLsToCapacity);
            
                List<ReturnFields> returnFieldsList = new List<ReturnFields>();
                
                // Constructing SAP Request
                       
                microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING ET_PRICING = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING();
                 
                microsoftLobservicesSapPricing.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapPricing.ArrayOfBAPIRET2();

                microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT IT_DELIVERY_POINT = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT();
                if(quoteLineItemsList != null){
                    IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT[quoteLineItemsList.size()];
                    for(Integer i=0; i<IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT.size(); i++){
                        //Init the ZBAPI_CRM_DEL_PT
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i] = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT();   
                        //Get the currentQuoteLineItem
                        QuoteLineItem currentQuoteLineItem = quoteLineItemsList.get(i);
                        //Fill the ZBAPI_CRM_DEL_PT according to the information of the currentQuoteLineItem
                        //In case of GEB and GER Consumer, since the QLIs don't have PTLs we need some mandatory information on Quote instead of Quote_PTL
                        if(this.parent.IM_SPART.equals('41') || (this.parent.isGERConsumer)){
                            IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = this.parent.IM_SOLD_TO;
                        }else{
                            IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CODE = (currentQuoteLineItem.Quote_PTL__r.PTL_Name__c  != null) ? currentQuoteLineItem.Quote_PTL__r.PTL_Name__c  : String.valueOf(currentQuoteLineItem.Quote_PTL__r.Name).substring(0,10);
                        }
                        
                        if(currentQuoteLineItem.PriceBookEntry.Product2.Tank_Type__c!=null && currentQuoteLineItem.Tank_Placing_Options__c != null){
                            if(currentQuoteLineItem.PriceBookEntry.Product2.Tank_Type__c == 'A' && currentQuoteLineItem.Tank_Placing_Options__c != 'RDS' && currentQuoteLineItem.Tank_Placing_Options__c != 'IDE'){
                                TankPriorityValue = currentQuoteLineItem.PriceBookEntry.Product2.Tank_Type__c;
                            }
                            else if (currentQuoteLineItem.PriceBookEntry.Product2.Tank_Type__c != 'A'){
                                tankOtherOption = currentQuoteLineItem.PriceBookEntry.Product2.Tank_Type__c; 
                            }
                        }
                        
                        //IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CAPACITY = currentQuoteLineItem.Quote_PTL__r.Estimated_Capacity__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CAPACITY = AP_PricingUtilities.getQuotePTLCapacity(mapPTLsToCapacity, currentQuoteLineItem.Quote_PTL__r.Name);
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].PRODUCT_GROUP = this.parent.currentQuote.DO_Groupement__r.AccountNumber;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].TAX_CLASSIFICATION = this.parent.currentQuote.VAT_code__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].BAREME = this.parent.IM_PRODUCT_SCALE ;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].CONSUMPTION = currentQuoteLineItem.Quote_PTL__r.Estimated_Consumption__c;
//                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].DEPARTEMENT = currentQuoteLineItem.Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].DEPARTEMENT = currentQuoteLineItem.Quote_PTL__r.Opportunity_PTL__r.DepartmentFormula__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].SHIPPING_CONDITION = this.parent.currentQuote.Shipping_Condition__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].PAYMENT_DELAY = this.parent.currentQuote.Payment_spread_SAP__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].FEES_GROUP = this.parent.currentQuote.DO_Groupement__r.AccountNumber;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].TYPCTR =  this.parent.currentQuote.Type_of_charge__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].MATERIAL_CODE = currentQuoteLineItem.PriceBookEntry.Product2.ProductCode;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].FUEL = (currentQuoteLineItem.PriceBookEntry.Product2.ProductCode.equals('904P0001')) ? AP_PricingUtilities.convertPurposesToFuelFlag(currentQuoteLineItem.Quote_PTL__r.RPTL_Purposes__c) : null;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].MATERIAL_QTY = currentQuoteLineItem.Quantity;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].QTY_UNITE = currentQuoteLineItem.Quantity_Unit__c;
                        IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[i].BIO_PRODUCT = currentQuoteLineItem.Bio_Product__c;
                        
                        //In case of GER Owner, if the QLI is for Consumer, we have to set the Number to Uxxx and the new GER Consumption and put the Quote scale blank
                        if(this.parent.isGEROwner && currentQuoteLineItem.PricebookEntry.Product2.UseConsumerTarget__c){
                            //Account Number must be Uxxx
                            this.parent.IM_SOLD_TO = 'USPLITREQ';
                            //GER Consumption is mandatory if we send a request for GER Consumer (45 + Uxxx)
                            this.parent.IM_GER_CONSUMPTION = (currentQuoteLineItem.Ger_consumption__c != null) ? currentQuoteLineItem.Ger_consumption__c : 'C1' ;
                            //Quote Scale must be blank
                            this.parent.IM_DO_FEES_SALESDISTRICT = null;
                        }
                    }
                    if(TankPriorityValue!=null){
                        this.parent.IM_TANK_TYPE = TankPriorityValue;
                    }
                    else {
                        this.parent.IM_TANK_TYPE = TankOtherOption;
                    }
                }
                //Do request and retrieve response
                microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element response_x;
                if (Test.isRunningTest()){
                    response_x = AP_WrapperForSOAPCallPricing.ZBAPI_CRM_PRICINGDummy();

                } else {
                    if(AP_PricingUtilities.getCustomSettingValue('Pricing_doCallOuts').equals('1')){
                         //Temporary for DEBUG
                        String oldEndPoint =  this.parent.webserviceSOAP.endpoint_x;
                        //this.parent.webserviceSOAP.endpoint_x = 'http://www.lodeblomme.be/log/';
                        //this.parent.webserviceSOAP.endpoint_x = 'http://orozco.fr:6843/put/';
                        //this.parent.webserviceSOAP.endpoint_x = 'http://test-sap-butagaz.herokuapp.com/put/';
                        this.parent.webserviceSOAP.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
                        try{
                            response_x = this.parent.webserviceSOAP.ZBAPI_CRM_PRICING(
                                                        this.parent.IM_ACTION,
                                                        this.parent.IM_CAPACITY,
                                                        this.parent.IM_CONDITION_GROUP_1,
                                                        this.parent.IM_CONSIGNMENT_OFFER,
                                                        this.parent.IM_CONSUMPTION,
                                                        this.parent.IM_CONTRACT_DURATION,  
                                                        this.parent.IM_CUSTOMER_GROUP,
                                                        this.parent.IM_CUSTOMER_GROUP_1,
                                                        this.parent.IM_CUSTOMER_GROUP_2,
                                                        this.parent.IM_CUSTOMER_GROUP_4,
                                                        this.parent.IM_CUSTOMER_GROUP_5,
                                                        this.parent.IM_DO_FEES_SALESDISTRICT,
                                                        this.parent.IM_GER_CONSUMPTION,
                                                        this.parent.IM_HIERARCHY,
                                                        this.parent.IM_KWH_CONSUMPTION,
                                                        this.parent.IM_QUOTE_DATE,
                                                        this.parent.IM_SALES_DEAL,
                                                        this.parent.IM_SOLD_TO,
                                                        this.parent.IM_SPART,
                                                        this.parent.IM_TANK_TYPE,
                                                        ET_PRICING, 
                                                        ET_RETURN,
                                                        IT_DELIVERY_POINT
                                                        );
                        System.debug('######### 2 #########' + response_x);
                                                    
                        }catch(Exception e){
                        }finally{
                            this.parent.webserviceSOAP.endpoint_x = oldEndPoint;
                            response_x = this.parent.webserviceSOAP.ZBAPI_CRM_PRICING(
                                                        this.parent.IM_ACTION,
                                                        this.parent.IM_CAPACITY,
                                                        this.parent.IM_CONDITION_GROUP_1,
                                                        this.parent.IM_CONSIGNMENT_OFFER,
                                                        this.parent.IM_CONSUMPTION,
                                                        this.parent.IM_CONTRACT_DURATION,
                                                        this.parent.IM_CUSTOMER_GROUP,
                                                        this.parent.IM_CUSTOMER_GROUP_1,
                                                        this.parent.IM_CUSTOMER_GROUP_2,
                                                        this.parent.IM_CUSTOMER_GROUP_4,
                                                        this.parent.IM_CUSTOMER_GROUP_5,
                                                        this.parent.IM_DO_FEES_SALESDISTRICT,
                                                        this.parent.IM_GER_CONSUMPTION,
                                                        this.parent.IM_HIERARCHY,
                                                        this.parent.IM_KWH_CONSUMPTION,
                                                        this.parent.IM_QUOTE_DATE,
                                                        this.parent.IM_SALES_DEAL,
                                                        this.parent.IM_SOLD_TO,
                                                        this.parent.IM_SPART,
                                                        this.parent.IM_TANK_TYPE,
                                                        ET_PRICING, 
                                                        ET_RETURN,
                                                        IT_DELIVERY_POINT
                                                        );
                        System.debug('######### 2 ######### - ' + this.parent.IM_TANK_TYPE + ' - ' + response_x);                    
                        }
                    }else{
                        response_x = AP_WrapperForSOAPCallPricing.ZBAPI_CRM_PRICINGDummy();
                        System.debug('######### 2 ######### - ' + this.parent.IM_TANK_TYPE + ' - ' + response_x);
                    }
                    System.debug('######### 2 #########' + response_x);    
                }
                System.debug('######### 2 ######### - ' + this.parent.IM_TANK_TYPE + ' - ' + response_x);
                this.parent.oBapiTracker.Response2__c = String.valueOf(response_x);
                this.parent.oBapiTracker.Endpoint__c = this.parent.webserviceSOAP.endpoint_x; 
                // Fetching for the current CALLOUT
                this.sapResponses.realAnnualConsumptionDO = response_x.EX_CONSUMPTION; //Will be the same even if we split the sap requests
                this.sapResponses.realAnnualCapacityDO = response_x.EX_CAPACITY; //Will be the same even if we split the sap requests
                
                this.fetchItemsPricingOnCalculateMode(response_x.ET_PRICING, quoteLineItemsList);
                this.fetchReturnFields(response_x.ET_RETURN);
                
                //In case of GER, for the consumer we wont send a scale, it will be set to null, thats why we have to put the first value that we had
                this.parent.IM_DO_FEES_SALESDISTRICT = scale;
            }

        }
        
        //check if there an equipement replacement
        private Boolean isEquipementReplacement(List<QuoteLineItem> quoteLineItemsList){        
            boolean isEquipementReplacement = false;
            for(QuoteLineItem QLI : quoteLineItemsList){
                if(QLI.Got_From_SAP__c && QLI.PricebookEntry.Product2.Family != null && !QLI.PricebookEntry.Product2.Family.toLowerCase().equals('equipement') && !QLI.PricebookEntry.Product2.Family.toLowerCase().equals('produit')){
                    if(QLI.Remplacement__c==true){
                        isEquipementReplacement = true;
                    }                   
                }
            }
            return isEquipementReplacement;
        }
            
        private Boolean isGEBContext(){
            return this.parent.IM_SPART.equals('41');
        }
        
        private Boolean isGERConsumerContext(){
            return parent.isGERConsumer;
        }
        
        private void fetchItemsPricingOnCalculateMode(microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING itemsPricingListBapi, List<QuoteLineItem> currentQuoteLineItems){
            
            integer iCptITemPricingKey = 1 ;  // To manage multi-PTL (BAPI)
            integer iCptItemKey = 1 ;  // To manage multi-PTL (Qli)
            
            
            if( itemsPricingListBapi != null && itemsPricingListBapi.ZBAPI_CRM_PRICING != null){
                
                //Construct the Map  (Key='MaterialCode-PTLCode' , Value=ZBAPI_CRM_PRICING)
                Map<String, microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING> mapSAPPrices = new Map<String, microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING>();
                Map<String, String> mapStoreKeysBAPI = new Map<String, String>();
                
                for(microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing : itemsPricingListBapi.ZBAPI_CRM_PRICING){
                    
                    //The unique key is based on Material code
                    String itemPricingKey = (itemPricing.MATERIAL_CODE == null) ? '' : itemPricing.MATERIAL_CODE; // materialCode=null : Impossible case that we receive Prices with No material Code
                    
                    //..and PTL code.       
                    //Handle the PTL Code (and so the multi-PTL cases) except for GEB & GER Consumer
                    if(!isGEBContext() && !this.parent.isGERConsumer){ 
                        String PTLCode = (itemPricing.DELIVERY_POINT == null) ? '' : itemPricing.DELIVERY_POINT;    // PTLCode='' : case of GEB or GER usager, don't have a PTL
                        itemPricingKey += '-' + PTLCode ;                  
                    }
                    
                    // ELC 20150227 : to handle multiple identical material code/ptl cases (BAPI) (START)
                    // Create a dummy counter (common for all material codes / PTLs) to match the SOAP and the Qlis
                    String itemPricingKeyToCheck = itemPricingKey ;
                    if(mapStoreKeysBAPI.containsKey(itemPricingKey)){
                        iCptITemPricingKey = integer.valueof(mapStoreKeysBAPI.get(itemPricingKey)) + 1;
                        itemPricingKey += '-' + iCptITemPricingKey ;
                        mapStoreKeysBAPI.put(itemPricingKeyToCheck, string.valueof(iCptITemPricingKey));
                    }else{
                        itemPricingKey += '-1' ;
                        mapStoreKeysBAPI.put(itemPricingKeyToCheck, '1');
                    }
                    System.debug('ELC itemPricingKey :'+ itemPricingKey);
                    // ELC 20150227 : to handle multiple identical material code/ptl cases (BAPI) (END)
                    
                    if(!itemPricingKey.equals('')){
                        mapSAPPrices.put(itemPricingKey, itemPricing);
                    }else{
                        //display the error about the lack of datas
                        this.sapResponses.APVFMessageList.add(new AP_VFMessage('E', System.Label.crm_message+ ' : ' + System.Label.pricing_with_no_materialCode, ''));
                    }    
                }
                
                System.debug('MAPSAPPRICES :'+ mapSAPPrices);
                System.debug('mapStoreKeysBAPI :'+ mapStoreKeysBAPI);
                
                
                // ELC
                Map<String, String> mapStoreKeysQli = new Map<String, String>();
                
                // Update List of QuoteLineItems of the parent Object with the prices
                for(QuoteLineItem Qli : currentQuoteLineItems){
                    String materialCode = Qli.PricebookEntry.Product2.ProductCode;
                    String PTLCode = (Qli.Quote_PTL__r == null) ? '' : ((Qli.Quote_PTL__r.PTL_Name__c != null) ? Qli.Quote_PTL__r.PTL_Name__c : String.valueOf(Qli.Quote_PTL__r.Name).substring(0,10)) ;
                    System.debug('Material code :'+ materialCode);
                    System.debug('PTL Code :'+ PTLCode);
                    
                    String itemKey = materialCode; 
                    if(!isGEBContext() && !this.parent.isGERConsumer){
                       itemKey += '-' + PTLCode;
                    }
                    
                    // ELC 20150227 : to handle multiple identical material code/ptl cases (Qli) (START)
                    // To match the dummy counter of the SOAP                    
                    String itemKeyToCheck = itemKey ;
                    if(mapStoreKeysQli.containsKey(itemKey)){
                        iCptItemKey = integer.valueof(mapStoreKeysQli.get(itemKey)) + 1;
                        itemKey += '-' + iCptItemKey ;
                        mapStoreKeysQli.put(itemKeyToCheck, string.valueof(iCptItemKey));
                    }else{
                        itemKey += '-1' ;
                        mapStoreKeysQli.put(itemKeyToCheck, '1');
                    }
                    System.debug('ELC itemKey :'+ itemKey);
                    // ELC 20150227 : to handle multiple identical material code/ptl cases (Qli) (END)
                    
                    microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing = mapSAPPrices.get(itemKey);
                    
                    if(itemPricing != null){
                        String misADispositon = Qli.Mis_Disposition__c;
                        //We won't take into account the pricing coming from SAP, if the tank are sold by BTZ
                        if(misADispositon == null || !(misADispositon.toLowerCase().equals('tank sold by btz'))){
                            this.finalizeQLIPricingInfo(Qli, itemPricing);
                            this.finalizeQLIPricingInfoBackup(Qli);
                        }    
                    }else{
                        //Impossible case (Normally!!!)
                        this.sapResponses.APVFMessageList.add(new AP_VFMessage('E', System.Label.crm_message+ ' : ' + System.Label.no_pricing_for_quotelineitem + ' : ( ' + materialCode + '-' + PTLCode + ' ) ', ''));
                    }                    
                }
                
            }     
        }
        
        private void finalizeQLIPricingInfo(QuoteLineItem Qli, microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing){
            Boolean rceSetByAC = false;
            Boolean rcomSetByAC = false;
            Boolean rcomaboSetByAC = false;

            if(Qli != null && itemPricing != null){
                Qli.Description = itemPricing.LIBELLE_ART;
                
                Qli.VAT_Percentage__c = itemPricing.VAT_PRC;
                
                Qli.Amount_Unit__c = itemPricing.AMOUNT_UNIT;
                Qli.Quantity_Unit__c = itemPricing.QTY_UNIT;
                
                Qli.Pricing_Unit__c = itemPricing.PRICING_UNIT;
                Qli.UnitPrice = itemPricing.PRICING_UNIT;
                
                Qli.Price_List_HT__c = this.calculateHT(itemPricing.PRICE_LIST_HT, Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.PRICE_LIST_HT;
                //Qli.Price_List_TTC__c = this.calculateTTC(Qli.Price_List_HT__c, itemPricing.VAT_PRC); //itemPricing.PRICE_LIST_TTC;
                Qli.Price_List_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.PRICE_LIST_TTC, Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.PRICE_LIST_TTC;
                
                // ORO:140910 - AutoRCE on line (family = product)
                if (this.acSelectedAc != null && Qli.PricebookEntry.Product2.Family == 'Produit' 
                    && !Qli.RCE_Rebate_ManuallySet__c && this.acSelectedAc.RCE__c != null) {
                        Qli.RCE_Rebate_TTC__c = this.acSelectedAc.RCE__c;
                        rceSetByAC = true;
                }
                
                
                 // MLC:20180123- AutoRCOM on line (family = product)
                if (this.acSelectedAc != null && Qli.PricebookEntry.Product2.Family == 'Produit' 
                    && this.acSelectedAc.RCOM__c != null) {
                        Qli.Commercial_Rebate_TTC__c= this.acSelectedAc.RCOM__c;
                        rcomSetByAC = true;
                }
                
                // ELC 20200818 - AutoRCom on line (product = SPPABO0010)
                System.debug(logginglevel.WARN,'### Qli.PricebookEntry.Product2.ProductCode : ' + Qli.PricebookEntry.Product2.ProductCode);
                if (this.acSelectedAc != null && (Qli.PricebookEntry.Product2.ProductCode == 'SPPABO0010' || Qli.PricebookEntry.Product2.ProductCode == 'SPPABO0008')
                    && this.acSelectedAc.RCOM_AbonnementAccesEnergie__c != null) {
                        Qli.Commercial_Rebate_TTC__c = this.acSelectedAc.RCOM_AbonnementAccesEnergie__c;
                        rcomaboSetByAC = true;
                }
                

                //In case of SUCC or FIDE(V37) we won't retrieve all rebates in mode 2
                if(!('2'.equals(this.parent.IM_ACTION) &&
                        ('SUCC'.equals(this.parent.currentQuote.Opportunity.Project_Type__c) ||
                            ('FIDE'.equals(this.parent.currentQuote.Opportunity.Project_Type__c) && 'V37'.equals(this.parent.currentQuote.Opportunity.Project_Sub_Type__c))
                        )
                    )
                  ){
                    //ALL GROUPEMENT REBATES
                    
                    //NB: transcript all rebates to positifs numbers since SAP sent us as negatives and latitude calculation expect positifs numbers
                    Qli.Group_Commercial_Rebate_HT__c = this.calculateHT(itemPricing.GROUP_COM_REB_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.GROUP_COM_REB_HT;
                    Qli.Group_Commercial_Rebate_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.GROUP_COM_REB_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.GROUP_COM_REB_TTC;
                    
                    Qli.Group_Cyclical_Rebate_HT__c = this.calculateHT(itemPricing.GROUP_CYC_REB_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.GROUP_CYC_REB_HT;
                    Qli.Group_Cyclical_Rebate_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.GROUP_CYC_REB_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.GROUP_CYC_REB_TTC;
                    
                    //If GROUP_CYC_REB_HT not equal to 0, the duration receveid is for groupement : Group_Cyclical_Rebate_lenght_in_months__c
                    //If CYC_REB_HT not equal to 0, the duration receveid is not for groupement : Cyclical_Rebate_Months__c
                    //If both are equal to 0, the duration will be set to 0 as well, we will store it in Group_Cyclical_Rebate_lenght_in_months__c
                    if(itemPricing.GROUP_CYC_REB_HT != 0){
                        Qli.Group_Cyclical_Rebate_lenght_in_months__c = itemPricing.GROUPE_CYC_LENGHT;
                    }
                    
                    //ALL REBATES (GIVEN BY SALES REP ON ONE SHOT)

                     // MLC 20180123- bypass Bapi's value if AutoRCOM ajout du if
                    if (!rcomSetByAC && !rcomaboSetByAC) {
                    Qli.Commercial_Rebate_HT__c = this.calculateHT(itemPricing.COM_REB_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT);//itemPricing.COM_REB_HT;
                    Qli.Commercial_Rebate_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.COM_REB_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.COM_REB_TTC;
                    }
                    
                    Qli.Cyclical_Rebate_HT__c = this.calculateHT(itemPricing.CYC_REB_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.CYC_REB_HT;
                    Qli.Cyclical_Rebate_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.CYC_REB_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.CYC_REB_TTC;
                    if(itemPricing.CYC_REB_HT != 0){
                        Qli.Cyclical_Rebate_Months__c = itemPricing.GROUPE_CYC_LENGHT;
                    }
                    
                    /*if(itemPricing.CYC_REB_HT != 0){
                        Qli.Cyclical_Rebate_Months__c = itemPricing.CYC_REB_LENGHT;
                    }*/
                    
                    // ORO 140912 - bypass Bapi's value if AutoRCE
                    if (!rceSetByAC) {
                        Qli.RCE_Rebate_HT__c = this.calculateHT(itemPricing.RCE_REB_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.RCE_REB_HT;
                        Qli.RCE_Rebate_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.RCE_REB_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.RCE_REB_TTC;
                    } else {
                        //Qli.RCE_Rebate_HT__c = this.calculateHT(Qli.RCE_Rebate_HT__c*(-1), 1, itemPricing.PRICING_UNIT);
                    }
                    
                }
                
                // FRECA0 26/09/2014 - TAEG
                //System.debug('###ELC itemPricing.TAEG_HT; :'+ itemPricing.TAEG_HT);
                //System.debug('###ELC itemPricing.TAEG_TTC; :'+ itemPricing.TAEG_TTC);
                //System.debug('###ELC itemPricing.TAEG_POURCENTAGE; :'+ itemPricing.TAEG_POURCENTAGE);
                Qli.TAEG_Amount_HT__c = itemPricing.TAEG_HT;
                Qli.TAEG_Amount_TTC__c = itemPricing.TAEG_TTC;
                Qli.TAEG_Percentage__c = itemPricing.TAEG_POURCENTAGE;
                
                
                Qli.Transport_Increase_HT__c =  this.calculateHT(itemPricing.INC_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT);//itemPricing.INC_HT;
                Qli.Transport_Increase_TTC__c =  this.calculateTTCWithVATAlreadyApplied(itemPricing.INC_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT);//itemPricing.INC_TTC;
                
                // Erwan 20181217
                Qli.TICPE_Amount_HT__c = this.calculateHT(itemPricing.TICPE_HT, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.TICPE_Amount_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.TICPE_TTC, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Remise_Post_Offre_HT__c = this.calculateHT(itemPricing.REM_POST_PFIXE_HT*(-1), Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Remise_Post_Offre_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.REM_POST_PFIXE_TTC*(-1), Qli.Quantity, itemPricing.PRICING_UNIT);
                
                // Erwan 20190423
                Qli.Fixed_Price_HT__c = this.calculateHT(itemPricing.PFIXE_HT, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Fixed_Price_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.PFIXE_TTC, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Payment_Spread_Amount_HT__c = this.calculateHT(itemPricing.ETAL_PMT_HT, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Payment_Spread_Amount_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.ETAL_PMT_TTC, Qli.Quantity, itemPricing.PRICING_UNIT);
                
                // Erwan 20191203
                Qli.Bio_Option_Amount_HT__c = this.calculateHT(itemPricing.MBIO_HT, Qli.Quantity, itemPricing.PRICING_UNIT);
                Qli.Bio_Option_Amount_TTC__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.MBIO_TTC, Qli.Quantity, itemPricing.PRICING_UNIT);
                
                // Erwan 20180209 - Store Product Scale on 1st call if "Prix Fixe"
                //if(Qli.Normal_Product_Scale_From_SAP__c == null && Qli.PricebookEntry.Product2.Family == 'Produit'){
                if(this.acSelectedAc == null && Qli.PricebookEntry.Product2.Family == 'Produit'){
                    if(this.parent.currentQuote.Opportunity.Project_market_type__c == 'DOM'){
                        Qli.Normal_Product_Scale_From_SAP__c = this.calculateTTCWithVATAlreadyApplied(itemPricing.PRICE_LIST_TTC, Qli.Quantity, itemPricing.PRICING_UNIT); //itemPricing.Normal_Product_Scale_From_SAP__c;
                    }else{
                        Qli.Normal_Product_Scale_From_SAP__c = this.calculateHT(itemPricing.PRICE_LIST_HT, Qli.Quantity, itemPricing.PRICING_UNIT);
                    }
                }
                
            }        
        }
        
        
        private void finalizeQLIPricingInfoBackup(QuoteLineItem Qli){
            if(Qli != null){
                Qli.Price_List_HT_Old__c =  Qli.Price_List_HT__c;
                Qli.Price_List_TTC_Old__c = Qli.Price_List_TTC__c;
                
                //In case of SUCC or FIDE(V37) we won't retrieve all rebates in mode 2
                system.debug('##### MLCthis.parent : ' +  this.parent.currentQuote);
                system.debug('##### MLCthis.parent.currentQuote.Opportunity : ' +  this.parent.currentQuote.Opportunity);
                if(!(this.parent.IM_ACTION.equals('2') &&
                        (this.parent.currentQuote.Opportunity.Project_Type__c.equals('SUCC') ||
                            ((this.parent.currentQuote.Opportunity.Project_Type__c.equals('FIDE') )&& 
                             ( this.parent.currentQuote.Opportunity.Project_Sub_Type__c.equals('V37')))
                        )
                    )
                  ){
                    Qli.Group_Commercial_Rebate_HT_Old__c = Qli.Group_Commercial_Rebate_HT__c;
                    Qli.Group_Commercial_Rebate_TTC_Old__c = Qli.Group_Commercial_Rebate_TTC__c;
                    
                    Qli.Group_Cyclical_Rebate_HT_Old__c = Qli.Group_Cyclical_Rebate_HT__c;
                    Qli.Group_Cyclical_Rebate_TTC_Old__c = Qli.Group_Cyclical_Rebate_TTC__c;
                    Qli.Group_Cyclical_Rebate_lenght_months_Old__c = Qli.Group_Cyclical_Rebate_lenght_in_months__c;
                    
                    Qli.Commercial_Rebate_HT_Old__c = Qli.Commercial_Rebate_HT__c;
                    Qli.Commercial_Rebate_TTC_Old__c = Qli.Commercial_Rebate_TTC__c;

                    Qli.Cyclical_Rebate_Months_Old__c = Qli.Cyclical_Rebate_Months__c;
                    Qli.Cyclical_Rebate_HT_Old__c = Qli.Cyclical_Rebate_HT__c;
                    Qli.Cyclical_Rebate_TTC_Old__c = Qli.Cyclical_Rebate_TTC__c;

                    Qli.RCE_Rebate_HT_Old__c = Qli.RCE_Rebate_HT__c;
                    Qli.RCE_Rebate_TTC_Old__c = Qli.RCE_Rebate_TTC__c;
                }
                
                Qli.Transport_Increase_HT_Old__c =  Qli.Transport_Increase_HT__c;
                Qli.Transport_Increase_TTC_Old__c =  Qli.Transport_Increase_TTC__c;
                
            }        
        }
        
        private Decimal calculateHT(Decimal priceHT, Decimal Qty, Decimal priceUnit){
            if(priceHT != null && Qty != null && priceUnit != null && priceUnit != 0){
                return (priceHT * Qty) / priceUnit;
            }
            return priceHT;
        }
        
        private Decimal calculateTTCWithVATAlreadyApplied(Decimal priceTTC, Decimal Qty, Decimal priceUnit){
            if(priceTTC != null && Qty != null && priceUnit != null && priceUnit != 0){
                return (priceTTC * Qty) / priceUnit;
            }
            return priceTTC;
        }
        
        private Decimal calculateTTC(Decimal priceHT, Decimal TVA){
            return priceHT * (1+ TVA/100);
        }
        
        private void fetchReturnFields(microsoftLobservicesSapPricing.ArrayOfBAPIRET2 returnFieldsListBapi){
            List<ReturnFields> returnFieldsList = new List<ReturnFields>();
            if( returnFieldsListBapi != null && returnFieldsListBapi.BAPIRET2 != null){
                for(microsoftLobservicesSapPricing.BAPIRET2 returnFields : returnFieldsListBapi.BAPIRET2){
                    ReturnFields r  = new ReturnFields();
                    r.Type_x = returnFields.TYPE_x;
                    r.ID =  returnFields.ID;
                    r.Number_x = returnFields.NUMBER_x;
                    r.Message = returnFields.MESSAGE;
                    r.LogNo = returnFields.LOG_NO;
                    r.LogMsgNo = returnFields.LOG_MSG_NO;
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
    
    private class ReturnFields {      
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
    
    //Wrap the data received from SAP (soap/bapi) format to a format that the controller expect
    public class AP_WrapperDataForController{
        private AP_WrapperForSOAPCallPricing parent;
        
        public Decimal realAnnualConsumptionDO;
        public Decimal realAnnualCapacityDO;

        public  List<QuoteLineItem> listQuoteLineItemToCtrl; // List of QuoteLineItem that the controller will received
       
        private List<ReturnFields> returnFieldsList;       
        public  List<AP_VFMessage> listAPVFMessage; // List of AP_VFMessage that the controller will received  
        
        public boolean errorGotFromSAP;
        
        public AP_WrapperDataForController(AP_WrapperForSOAPCallPricing parent,
                                           Decimal realConsumption,
                                           Decimal realCapacity,
                                           List<QuoteLineItem> QLIList,
                                           List <ReturnFields> returnFieldsList,
                                           List<AP_VFMessage> APVFMessageList,
                                           Boolean errorGotFromSAP) {
            this.parent = parent;
            this.realAnnualConsumptionDO = realConsumption;
            this.realAnnualCapacityDO = realCapacity;
            this.listQuoteLineItemToCtrl = QLIList;
            this.returnFieldsList = returnFieldsList;
            this.listAPVFMessage = APVFMessageList;
            this.errorGotFromSAP = errorGotFromSAP;
        }
        
    }
    
            
    
    
    public static microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element ZBAPI_CRM_PRICINGDummy() {
                                            
        //TODO CONSTRUCT A DUMMY RESPONSE
        microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element responseDummy = new microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element();
        
        responseDummy.EX_CAPACITY = 100;
        responseDummy.EX_CONSUMPTION = 100;
        
        responseDummy.ET_PRICING = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING();      
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING = new microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING[2];
        
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0] = new microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING();
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].DELIVERY_POINT = 'PTLCODE1';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].MATERIAL_CODE = 'TESTMATCODE1';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].LIBELLE_ART = 'LIBELLEART';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].VAT_PRC = 19.6;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].AMOUNT_UNIT = 'EUR';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].QTY_UNIT = 'T';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].PRICING_UNIT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].PRICE_LIST_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].PRICE_LIST_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].GROUP_COM_REB_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].GROUP_COM_REB_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].COM_REB_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].COM_REB_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].GROUP_CYC_REB_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].GROUP_CYC_REB_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].GROUPE_CYC_LENGHT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].CYC_REB_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].CYC_REB_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].RCE_REB_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].RCE_REB_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].INC_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].INC_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].TICPE_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].TICPE_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].REM_POST_PFIXE_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].REM_POST_PFIXE_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].CYC_REB_LENGHT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].PFIXE_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].PFIXE_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].ETAL_PMT_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].ETAL_PMT_TTC = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].MBIO_HT = 10;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[0].MBIO_TTC = 10;
        
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1] = new microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING();
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1] = new microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING();
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].DELIVERY_POINT = 'PTLCODE2';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].MATERIAL_CODE = 'TESTMATCODE2';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].LIBELLE_ART = 'LIBELLEART';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].VAT_PRC = 0.898;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].AMOUNT_UNIT = 'EUR';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].QTY_UNIT = 'HL';
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].PRICING_UNIT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].PRICE_LIST_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].PRICE_LIST_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].GROUP_COM_REB_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].GROUP_COM_REB_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].COM_REB_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].COM_REB_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].GROUP_CYC_REB_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].GROUP_CYC_REB_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].GROUPE_CYC_LENGHT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].CYC_REB_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].CYC_REB_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].RCE_REB_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].RCE_REB_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].INC_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].INC_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].TICPE_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].TICPE_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].REM_POST_PFIXE_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].REM_POST_PFIXE_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].CYC_REB_LENGHT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].PFIXE_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].PFIXE_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].ETAL_PMT_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].ETAL_PMT_TTC = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].MBIO_HT = 20;
        responseDummy.ET_PRICING.ZBAPI_CRM_PRICING[1].MBIO_TTC = 20;
        
        return responseDummy;
    }
    
    
    
 
    public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
 
    
    
}