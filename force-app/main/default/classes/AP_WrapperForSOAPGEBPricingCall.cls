public with sharing class AP_WrapperForSOAPGEBPricingCall {
    
     //EndPoint of SAP WebService
     private microsoftLobservicesSapPricing.RfcEndpoint SAPEndPoint = new microsoftLobservicesSapPricing.RfcEndpoint();
     
     
    public Decimal calculateSautDeTrancheFromBAPI(Quote quote, List<Quote_PTL__c> quotePTLs){
        
        //Init the connection
        initBAPIWebServiceConnection();
        
        //Collect all the mandatory inputs for the BAPI Call
        String articlePivot = getArticlePivotFromQptl(quotePTLs);
        InputBAPI inputs = collectBAPIInputsForGEBMode2(quote, quotePTLs, articlePivot);
        
        //Launch the request and get the BAPI response
        OutputBAPI output = launchSAPRequest(inputs);
        
        //Log the result on System.debug
        if(output != null && output.BAPIResponse != null) logResult(output.BAPIResponse.ET_PRICING);
        
        //Extract the only data we are interested in
        Decimal cyclicalRebate = extractCyclicalRebateFromOutputBAPI(output);
        
        //Calcul saut de tranche
        Decimal sautDeTranche = calculSautDeTrancheFromCyclicalRebate(cyclicalRebate, articlePivot);
        
        return sautDeTranche;
    }
    
    
    private Decimal calculSautDeTrancheFromCyclicalRebate(Decimal cyclicalRebate, String articlePivot){

        List<PricingGap> allSautDeTrancheGaps = fetchSautDeTrancheGapsByProduct(articlePivot);
     
        //no cyclical rebate means no saut de tranche
        if(cyclicalRebate > 0){
        
            for(PricingGap gap:allSautDeTrancheGaps){
                //iterate on ASC Ordered (!) Gaps List
                
                if(cyclicalRebate <= gap.gap){
                    //once we meet a gap right above the cyclical rebate, 
                    //it returns the related saut de tranche.
                    return gap.sautDeTranche;
                }
            }
            
        }
        
        return 0 ;
    }
    
    
    private InputBAPI collectBAPIInputsForGEBMode2(Quote quote, List<Quote_PTL__c> quotePTLs, String articlePivot){   
       
        Opportunity opty = quote.Opportunity;
        Account account = opty.Account;
        
        InputBAPI inputs = new InputBAPI();
        
        inputs.IM_ACTION            = '1';
        inputs.IM_CAPACITY          = null;
        inputs.IM_CONDITION_GROUP_1 = opty.Groupe__c;
        inputs.IM_CONSIGNMENT_OFFER = quote.Bottle_Leasing_Type__c;
        inputs.IM_CONSUMPTION       = quote.Sum_PTL_Consumption__c;  
        inputs.IM_CUSTOMER_GROUP    = account.Channel__c;
        inputs.IM_CUSTOMER_GROUP_1  = account.Sub_Channel__c;
        inputs.IM_CUSTOMER_GROUP_2  = account.Customer_group_2__c;
        inputs.IM_CUSTOMER_GROUP_4  = account.Group_Code__c;
        inputs.IM_CUSTOMER_GROUP_5  = account.Customer_group_5__c;
        inputs.IM_PRODUCT_SCALE     = quote.Product_scale__c;
        inputs.IM_DO_FEES_SALESDISTRICT = quote.Scale__c;        
        
        if('NA'.equals(quote.Scale__c) || 'V2.3'.equals(quote.Scale__c)){
            
            if(AP_PricingUtilities.getQuoteProductScalePack(quote)){
                //In case of scale=NA and Pack is defined on the Quote, we will send scale=P to SAP
                inputs.IM_DO_FEES_SALESDISTRICT = 'P';
                System.debug('=> CASE ABO PACK');
            }else if ('V4'.equals(inputs.IM_PRODUCT_SCALE)){
                //In case of scale=NA and 'V4' is defined on the Quote, we will send product_scale=V1PRO to SAP
                inputs.IM_DO_FEES_SALESDISTRICT = '2';
                inputs.IM_PRODUCT_SCALE = 'V1PRO';
                System.debug('=> CASE V1PRO + 2');
            }else{
                //In case of scale=NA and Pack is not defined on the Quote, we will send scale=2 to SAP
                inputs.IM_DO_FEES_SALESDISTRICT = '2';
                System.debug('=> CASE 2');
            }
        }
        
        Decimal activityDomainId = account.Activity_Domain__r.ExternalID__c;
        
        if(activityDomainId  != null && activityDomainId == 41){
            inputs.IM_GER_CONSUMPTION = quote.Product_scale__c;
             System.debug('=> CASE GEB');
        }
        else{
            inputs.IM_GER_CONSUMPTION = quote.Ger_Consumption__c;
             System.debug('=> CASE NON GEB');
        }
        
        inputs.IM_HIERARCHY = account.Parent.AccountNumber;
        inputs.IM_QUOTE_DATE = AP_PricingUtilities.convertDateToString(datetime.now().date());
        inputs.IM_SOLD_TO = opty.DO_AccountNumber__c; 
        
       
        
        if(activityDomainId != null)
            inputs.IM_SPART =  String.valueOf(activityDomainId);
        
        
        //In case of SUCC or GEC Locataire, we have to bring the products of the Owner (parent Account and the exiting PTL on the Opty)
        if('SUCC'.equals(opty.Project_Type__c)){
            inputs.IM_SOLD_TO = opty.Predecessor__r.AccountNumber;
        }
        
        
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT[1];           
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[0] = new microsoftLobservicesSapPricing.ZBAPI_CRM_DEL_PT();
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[0].CODE = opty.DO_AccountNumber__c;
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[0].MATERIAL_CODE = articlePivot; 
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[0].BAREME = quote.Product_scale__c;
        inputs.IT_DELIVERY_POINT.ZBAPI_CRM_DEL_PT[0].TAX_CLASSIFICATION = quote.VAT_code__c;
        
        return inputs;
    }
    
    
    
    private String getArticlePivotFromQptl(List<Quote_PTL__c> quotePTLs){
    
         if(quotePTLs == null || quotePTLs.isEmpty()){
            throw new CRMException('Une opportunité PTL avec un article pivot doit être enregistrée sur l\'opportunité');
         }
         
         Quote_PTL__c quotePTL = quotePTLs.get(0);
         quotePTL = [SELECT Opportunity_PTL__r.Emballage_Pivot__c FROM Quote_PTL__c WHERE Id = :quotePTL.Id];
         
         if(quotePTL.Opportunity_PTL__r == null || quotePTL.Opportunity_PTL__r.Emballage_Pivot__c == null){
            throw new CRMException('Une opportunité PTL avec un article pivot doit être enregistrée sur l\'opportunité');
         }
         
         return quotePTL.Opportunity_PTL__r.Emballage_Pivot__c;
    }
    
    
    /*
      * Extract the Cyclical Rebate (Remise conjoncturelle) from the BAPI output
      */
    private Decimal extractCyclicalRebateFromOutputBAPI(OutputBAPI output){
        
        microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING firstPricingItem = getFirstPricingItemFromOutput(output);
        
        if(firstPricingItem == null) return null;
        
        Decimal remiseConjoncturelle = firstPricingItem.CYC_REB_HT;
        
        if(firstPricingItem.PRICING_UNIT != null 
            && firstPricingItem.PRICING_UNIT > 0){
            remiseConjoncturelle /= firstPricingItem.PRICING_UNIT;
        }
        
        //PRICING_UNIT
        return remiseConjoncturelle;
  
    }
    
    /*
     * Extract the first item of ZBAPI_CRM_PRICING from the BAPI Webservice output
     */
    private microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING getFirstPricingItemFromOutput(OutputBAPI output){

        if(output != null && 
                output.BAPIResponse != null &&
                output.BAPIResponse.ET_PRICING != null && 
                output.BAPIResponse.ET_PRICING.ZBAPI_CRM_PRICING != null &&
                output.BAPIResponse.ET_PRICING.ZBAPI_CRM_PRICING.size() > 0){
                
                return output.BAPIResponse.ET_PRICING.ZBAPI_CRM_PRICING[0];
        }
        
        return null;
    }
    
    
    private Boolean isGEB(Quote quote){
        return ((quote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS')) || 
                (quote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB RE'))); 
    }
    
    
     private OutputBAPI launchSAPRequest(InputBAPI inputs){
        
        //Initialise the response
        microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element BAPIResponse;
        
        //SAPEndPoint.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
        
        try{
            //Launch the request
            BAPIResponse = SAPEndPoint.ZBAPI_CRM_PRICING(
                                        inputs.IM_ACTION,
                                        inputs.IM_CAPACITY,
                                        inputs.IM_CONDITION_GROUP_1,
                                        inputs.IM_CONSIGNMENT_OFFER,
                                        inputs.IM_CONSUMPTION,
                                        inputs.IM_CONTRACT_DURATION,  
                                        inputs.IM_CUSTOMER_GROUP,
                                        inputs.IM_CUSTOMER_GROUP_1,
                                        inputs.IM_CUSTOMER_GROUP_2,
                                        inputs.IM_CUSTOMER_GROUP_4,
                                        inputs.IM_CUSTOMER_GROUP_5,
                                        inputs.IM_DO_FEES_SALESDISTRICT,
                                        inputs.IM_GER_CONSUMPTION,
                                        inputs.IM_HIERARCHY,
                                        inputs.IM_KWH_CONSUMPTION,
                                        inputs.IM_QUOTE_DATE,
                                        inputs.IM_SALES_DEAL,
                                        inputs.IM_SOLD_TO,
                                        inputs.IM_SPART,
                                        inputs.IM_TANK_TYPE, 
                                        inputs.ET_PRICING, 
                                        inputs.ET_RETURN,
                                        inputs.IT_DELIVERY_POINT
                                        );
        }catch(Exception e){
            system.debug(e.getMessage());
            throw e;
        }
        
        OutputBAPI outputs = new OutputBAPI();
        outputs.BAPIResponse = BAPIResponse;
        
        return outputs;         
    }

    /*
     * Initialize the endpoint, login, password to SAP WebService
     */
    private void initBAPIWebServiceConnection(){
         this.SAPEndPoint.endpoint_x = AP_PricingUtilities.getCustomSettingValue('Pricing_EndPointURL');
         this.SAPEndPoint.timeout_x = 50000;  
        String username = AP_PricingUtilities.getCustomSettingValue('Pricing_Username');
        String password = AP_PricingUtilities.getCustomSettingValue('Pricing_Password');
        
        Blob headerValue = Blob.valueOf( username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        Map<String,String> inputHttpHeaders = new Map<String, String>();
        inputHttpHeaders.put('Authorization', authorizationHeader);

        this.SAPEndPoint.inputHttpHeaders_x = inputHttpHeaders;
    }
    
    /*
     * Fetch all the data of GEB_SautdeTranche_Pricing_Gap__c customSettings
     */
     public List<PricingGap> fetchSautDeTrancheGapsByProduct(String sautDeTranche){  
            
            List<GEB_SautdeTranche_Pricing_Gap__c> allSautDeTrancheGaps = [ SELECT gap__c, Saut_de_tranche__c 
                                                                            FROM GEB_SautdeTranche_Pricing_Gap__c 
                                                                            WHERE Article__c = :sautDeTranche]; 
            
            List<PricingGap> sortedSautDeTrancheGaps = new List<PricingGap>();
            for(GEB_SautdeTranche_Pricing_Gap__c gap:allSautDeTrancheGaps){
                sortedSautDeTrancheGaps.add(new PricingGap(gap.gap__c, gap.Saut_de_tranche__c));
            }
            
            sortedSautDeTrancheGaps.sort();
            
            return sortedSautDeTrancheGaps;      
    }
    
     /*
      * Technical method to log (system.debug) the BAPI result
      */
     private void logResult(microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING itemsPricingListBapi){
        system.debug('log result');
        if( itemsPricingListBapi != null && itemsPricingListBapi.ZBAPI_CRM_PRICING != null){
            system.debug('log result ZBAPI_CRM_PRICING ');
            for(microsoftLobservicesSapPricing.ZBAPI_CRM_PRICING itemPricing : itemsPricingListBapi.ZBAPI_CRM_PRICING){
                system.debug('DELIVERY_POINT : '+itemPricing.DELIVERY_POINT);
                system.debug('MATERIAL_CODE : '+itemPricing.MATERIAL_CODE);
                system.debug('LIBELLE_ART : '+itemPricing.LIBELLE_ART);
                system.debug('VAT_PRC : '+itemPricing.VAT_PRC);
                system.debug('AMOUNT_UNIT : '+itemPricing.AMOUNT_UNIT);
                system.debug('QTY_UNIT : '+itemPricing.QTY_UNIT);
                system.debug('PRICING_UNIT : '+itemPricing.PRICING_UNIT);
                system.debug('PRICE_LIST_HT : '+itemPricing.PRICE_LIST_HT);
                system.debug('PRICE_LIST_TTC : '+itemPricing.PRICE_LIST_TTC);
                system.debug('GROUP_COM_REB_HT : '+itemPricing.GROUP_COM_REB_HT);
                system.debug('GROUP_COM_REB_TTC : '+itemPricing.GROUP_COM_REB_TTC);
                system.debug('COM_REB_HT : '+itemPricing.COM_REB_HT);
                system.debug('COM_REB_TTC : '+itemPricing.COM_REB_TTC);
                system.debug('GROUP_CYC_REB_HT : '+itemPricing.GROUP_CYC_REB_HT);
                system.debug('GROUP_CYC_REB_TTC : '+itemPricing.GROUP_CYC_REB_TTC);
                system.debug('GROUPE_CYC_LENGHT : '+itemPricing.GROUPE_CYC_LENGHT);
                system.debug('CYC_REB_HT : '+itemPricing.CYC_REB_HT);
                system.debug('CYC_REB_TTC : '+itemPricing.CYC_REB_TTC);
                system.debug('RCE_REB_HT : '+itemPricing.RCE_REB_HT);
                system.debug('RCE_REB_TTC : '+itemPricing.RCE_REB_TTC);
                system.debug('INC_HT : '+itemPricing.INC_HT);
                system.debug('INC_TTC : '+itemPricing.INC_TTC);
            }
        }
    }
    
    
    /**
     * Handle all inputs for the BAPI WebService Call 
     */
     private class InputBAPI {      
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
        public String IM_QUOTE_DATE;
        public String IM_PRODUCT_SCALE;
        public String IM_SOLD_TO;
        public String IM_SPART;
        public String IM_CONTRACT_DURATION;
        public Decimal IM_KWH_CONSUMPTION;
        public String IM_SALES_DEAL;
        public String IM_TANK_TYPE;
        public microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING ET_PRICING = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_PRICING();
        public microsoftLobservicesSapPricing.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapPricing.ArrayOfBAPIRET2();
        public microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT IT_DELIVERY_POINT = new microsoftLobservicesSapPricing.ArrayOfZBAPI_CRM_DEL_PT();
    }
    
    /**
     * Handle all Output from the BAPI WebService Call 
     */
     private class OutputBAPI {      
        microsoftLobservicesSapPricing.ZBAPI_CRM_PRICINGResponse_element BAPIResponse;
    }
    
    private class PricingGap implements Comparable{
        Decimal gap { Get; Set;}
        Decimal sautDeTranche { Get; Set;}
        
        public PricingGap(Decimal gap, Decimal sautDeTranche){
            this.gap = gap;
            this.sautDeTranche = sautDeTranche;
        }
        
        public Integer compareTo(Object otherObject){
            
            PricingGap otherGap = (PricingGap) otherObject;
            
            Integer score = 0;
            
            if(this.gap == null) score -=1;
            if(otherGap.gap == null) score += 1;
            
            if(this.gap != null && otherGap.gap != null){
                if(this.gap > otherGap.gap) score = 1;
                else if(this.gap < otherGap.gap) score =-1;
            }
            
            return score;
        }
    }
}