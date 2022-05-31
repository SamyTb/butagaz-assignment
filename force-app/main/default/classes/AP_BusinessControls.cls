//This class will check the mandatory fields on the Quote, Quote_PTL before perfoming callout BAPI Pricing
public class AP_BusinessControls{
    
    public List<String> listErrors;
    
    //Quote & QuotePTLs
    private Quote currentQuote;
    private List<Quote_PTL__c> currentQuotePTLList;
    
    //Mandatory Common parameters
    public String IM_SOLD_TO;
    public String IM_SPART; //activity Domain
    public String IM_DO_FEES_SALESDISTRICT;
    public String IM_GER_CONSUMPTION;
    public String IM_CUSTOMER_GROUP;
    public String BAREME_PRODUIT;
    public String TAX_CLASSIFICATION;
    public String SHIPPING_CONDITION;
    
    //Case of GER
    public Boolean isGEROwner;
    public Boolean isGERConsumer;
    //Case of GEB
    public Boolean isGEB;
    //Case of GEC DOM SOLO / IDEO / ECOCFT
    public Boolean isGECDOMIDEO;
    public Boolean isGECDOMSOLO;
    public Boolean isGECDOMECOCFT;
    public Boolean isGECDOMLOCIDEOSOLO;
    
    
    public AP_BusinessControls(Quote currentQuote, List<Quote_PTL__c> currentQuotePTLList){
        system.debug('## RecordTypeId : '+this.currentQuote.RecordTypeId+' (GEB CONS : '+getQuoteRecordTypeValue('GEB CONS')+')');
        this.currentQuote = currentQuote;
        this.currentQuotePTLList = currentQuotePTLList;
        this.isGEROwner = (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GER Proprietaire'));
        this.isGERConsumer = (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GER Usager')); 
        this.isGEB = ((this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEB CONS')) || (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEB RE')));
        this.isGECDOMIDEO = (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEC DOM IDEO'));
        this.isGECDOMSOLO = (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEC DOM SOLO'));
        this.isGECDOMECOCFT = (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEC DOM ECOCFT'));
        this.isGECDOMLOCIDEOSOLO= (this.currentQuote.RecordTypeId == getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'));
        this.listErrors = new List<String>();
        
        
        this.IM_SOLD_TO = this.currentQuote.Opportunity.DO_AccountNumber__c; 
        this.IM_SPART = (this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c != null) ? 
                        String.valueOf(this.currentQuote.Opportunity.Account.Activity_Domain__r.ExternalID__c) :
                        null;
        this.IM_DO_FEES_SALESDISTRICT = this.currentQuote.Scale__c;
        if(this.isGEB){
            this.IM_GER_CONSUMPTION = this.currentQuote.Product_Scale__c;
        }
        else{
            this.IM_GER_CONSUMPTION = this.currentQuote.Ger_Consumption__c;
        }
        this.IM_CUSTOMER_GROUP = this.currentQuote.Opportunity.Account.Channel__c;
        this.BAREME_PRODUIT = this.currentQuote.Product_Scale__c;
        this.TAX_CLASSIFICATION = this.currentQuote.VAT_code__c;
        this.SHIPPING_CONDITION = this.currentQuote.Shipping_Condition__c;         
    }
    
    //Check common parameters of Pricing (accessible from the Quote)
    public void checkMandatoryOfInputCommonParameters(String BAPIMode){
        System.debug('### Quote:'+this.currentQuote + ' Oppty:' + this.currentQuote.Opportunity.Project_Type__c);
        if(this.IM_SOLD_TO == null){
            if(BAPIMode.equals('1')){
                //In case of CREA/SUCC we will set a fake Number temporary to perform SAP callout, otherwise it's an error (missing of the DO Number)
                if(this.currentQuote.Opportunity.Project_Type__c.equals('CREA') || 
                   this.currentQuote.Opportunity.Project_Type__c.equals('SUCC')){
                    if(this.isGEROwner){
                        this.currentQuote.Opportunity.DO_AccountNumber__c = 'PRNEWCUST';
                    }else if(this.isGERConsumer){
                        this.currentQuote.Opportunity.DO_AccountNumber__c = 'UNEWCUST';
                    }else{
                        this.currentQuote.Opportunity.DO_AccountNumber__c = 'NEWCUST';
                    }
                }else{
                    listErrors.add(System.Label.crm_message+ ' : ' + System.Label.accountNumber_mandatory);
                    //listErrors.add(System.Label.crm_message+ ' : ' + 'The DO (Number) of the Opportunity ( in DO Information section) is mandatory on FIDE/EXT/SUCC  (on CREA, a fake number will be set temporary)');
                }
            }else{
                if(this.currentQuote.Opportunity.Project_Type__c.equals('SUCC') &&
                    this.currentQuote.Opportunity.Predecessor__r.AccountNumber == null){
                    listErrors.add(System.Label.crm_message+ ' : ' + System.Label.predecessor_mandatory_on_succ);
                }
                if((this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') ||
                    this.currentQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO')) &&
                    this.currentQuote.Opportunity.Account_Owner__r.AccountNumber == null){
                    listErrors.add(System.Label.crm_message+ ' : ' + System.Label.owner_mandatory_on_succ);  
                }
                if(this.currentQuote.Opportunity.Project_Type__c.equals('FIDE') || this.currentQuote.Opportunity.Project_Type__c.equals('EXTE')){
                    listErrors.add(System.Label.crm_message+ ' : ' + System.Label.accountNumber_mandatory);
                }
            }            
        }else{
            if(this.isGEROwner && !this.IM_SOLD_TO.toUpperCase().startsWith('PR')){
                listErrors.add(System.Label.crm_message+ ' : ' + System.Label.accountNumberWithPR_mandatory);
                //listErrors.add(System.Label.crm_message+ ' : ' + 'In GER Owner, the DO (Number) of the Opportunity ( in DO Information section) must start with PRxxx (even in CREA project)');
            }
            if(this.isGERConsumer && !this.IM_SOLD_TO.toUpperCase().startsWith('U')){
                listErrors.add(System.Label.crm_message+ ' : ' + System.Label.accountNumberWithU_mandatory);
                //listErrors.add(System.Label.crm_message+ ' : ' + 'In GER Consumer, the DO (Number) of the Opportunity ( in DO Information section) must start with Uxxx (even in CREA project)');
            }
        }
        if(this.IM_SPART == null){
            listErrors.add(System.Label.crm_message+ ' : ' + System.Label.activityDomain_mandatory);
            //listErrors.add(System.Label.crm_message+ ' : ' + 'The Activity Domain of the Opportunity is mandatory');
        }else{
            if(this.IM_DO_FEES_SALESDISTRICT == null){
                if(this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || (this.isGEROwner)){
                    listErrors.add(System.Label.crm_message+ ' : ' + System.Label.scale_mandatory);
                    //listErrors.add(System.Label.crm_message+ ' : ' + 'The Scale of the Quote is mandatory for 42, 43, 45 owner');
                }
            }
            if(this.IM_GER_CONSUMPTION == null){
                if((this.isGERConsumer)){
                    listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.groupConsumption_mandatory);
                    //listErrors.add(System.Label.crm_message+ ' : ' + 'The Ger consumption (pricing group) of the Quote is mandatory for 41, 45 consumer');
                }
            }
            if(this.IM_CUSTOMER_GROUP == null){
                if(this.IM_SPART.equals('41')){
                    listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.customerGroup_mandatory);
                    //listErrors.add(System.Label.crm_message+ ' : ' + 'The Customer group of the Opportunity is mandatory for 41');
                }
            }
            if(this.BAREME_PRODUIT == null){
                if(this.IM_SPART.equals('41') || this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || this.IM_SPART.equals('45')){
                    listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.productScaleQuote_mandatory);
                }
            }                
            if(this.TAX_CLASSIFICATION == null){
                if(this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || this.IM_SPART.equals('45') || this.IM_SPART.equals('41')){
                    listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.taxClassificationQuote_mandatory);
                }
            }
            if(this.SHIPPING_CONDITION == null){
                    if(this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || (this.isGEROwner)){
                        listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.shippingConditions_mandatory);
                        //listErrors.add(System.Label.crm_message+ ' : ' + 'The shipping condition on the Opty PTL '+cPTL.Opportunity_PTL__r.Name+' is mandatory for 42,43, 45 Owner');
                    }
            }
        }

    }        
    
    //Check parameters of all delivery point of Pricing
    public void checkMandatoryFieldsOfInputDeliveryPointParameters(){

        for(Quote_PTL__c cPTL : currentQuotePTLList){
        
            Decimal CAPACITY = cPTL.Estimated_Capacity__c;
            Decimal CONSUMPTION = cPTL.Estimated_Consumption__c;
            
            //See the case which the code is required 
            /**if(CODE == null){
                throw new AP_CRMException('The code of the PTL on the Quote PTL is mandatory');
            }**/
            if(this.IM_SPART != null){
                String name = (cPTL.PTL_Name__c != null) ? cPTL.PTL_Name__c : cPTL.PTL_Label__c;
                //This capacity will be updated before calling sap according to the products chooses by sales rep (calculated dynamically)
                /**if(CAPACITY == null || CAPACITY == 0){
                    if(this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || (this.isGEROwner)){
                        listErrors.add(System.Label.crm_message+ ' : ' + 'La capacité du PTL_Devis n°: '+cPTL.Name+' est obligatoire dans GEC, GPLC, GER Propriétaire (valeur non nulle)');
                        //listErrors.add(System.Label.crm_message+ ' : ' + 'The capacity on the Quote PTL '+cPTL.Name+' is mandatory for 42, 43, 45 Owner');
                    }    
                }**/
                if(CONSUMPTION == null || CONSUMPTION == 0){
                    if(this.IM_SPART.equals('42') || this.IM_SPART.equals('43') || (this.isGEROwner)){
                        listErrors.add(System.Label.crm_message+ ' : ' +  System.Label.consumptionPTL_mandatory + ' ('+System.Label.quotePTL+ ' n°: '+cPTL.Name+' '+System.Label.linkedTo+' '+name+')');
                        //listErrors.add(System.Label.crm_message+ ' : ' + 'The consumption on the Quote PTL '+cPTL.Name+' is mandatory for 42, 43, 45 Owner');
                    }    
                }
                
            }    
        }
        
    }
    
    public void checkListErrors(){
        if(!listErrors.isEmpty()){
            throw new AP_CRMException(listErrors);
        }
    }
    
    public static String getQuoteRecordTypeValue(String name){
        try{
            return RecordTypes_OpportunityToQuote__c.getInstance(name).QuoteRecordType__c;
        }catch(System.NullPointerException e){
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the RecordTypes_OpportunityToQuote named (' + name +'). [ '+ e.getMessage() + ' ]'});
        }
    }
    
    public static String getCustomSettingValue(String name){
        try{
            return Custom_Settings__c.getInstance(name).value__c;
        }catch(System.NullPointerException e){
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the Custom Setting of named (' + name +'). [ '+ e.getMessage() + ' ]'});
        }
    }
    
    public static String convertDecimalToString(Decimal d){
        if(d != null){
            return String.valueOf(d);
        }
        return null;
    }
    
    //Rules about rebates that we have to disable
    public Boolean toDisable(String rebateType, String familyName, string subType, String sPack){
        system.debug('AP_BusinessControls.toDisable('+rebateType+','+familyName+','+subType+') (GEB : '+this.isGEB+')');
        
      
            if(familyName.toLowerCase().equals('equipement') || familyName.toLowerCase().equals('accessoire') ){
                        
                    if(AP_PricingUtilities.isRCE(rebateType) && ( (subType != 'Butabox') || (subType == 'Butabox' && sPack != null && (sPack.equals('ECOCFT'))) ) ){
                        return true;
                    }
                    
                    if(AP_PricingUtilities.isRCOM(rebateType) ){
                        return true;
                    }
                    
                    if(AP_PricingUtilities.isRCONJ(rebateType)){
                        return true;
                    }
                    
                }
            
            
            if(familyName.toLowerCase().equals('produit')  && subType != 'Butabox' ){
                if(AP_PricingUtilities.isRCE(rebateType) && this.isGEROwner){
                    return true;
                }
                 if(AP_PricingUtilities.isRCE(rebateType) && this.isGEB){
                     
                    return true;
                }
                if(AP_PricingUtilities.isRCOM(rebateType) && this.isGERConsumer){
                    return true;
                }
                if(AP_PricingUtilities.isRCONJ(rebateType) && (this.isGERConsumer || this.IM_SPART.equals('43'))){
                    return true;
                }
                
                if(AP_PricingUtilities.isRCOM(rebateType) && ( this.isGECDOMIDEO || this.isGECDOMSOLO || this.isGECDOMECOCFT || this.isGECDOMLOCIDEOSOLO) ){
                    return true;
                }
                if(AP_PricingUtilities.isRCONJ(rebateType) && (   this.isGECDOMECOCFT ) ){   /// mlc 20200727 this.isGECDOMIDEO || this.isGECDOMSOLO ||
                    return true;
                }
            }
            if(familyName.toLowerCase().equals('service') ){
                if(AP_PricingUtilities.isRCE(rebateType) && (this.isGEROwner || this.isGERConsumer || this.isGEB || this.IM_SPART.equals('43') || (sPack != null && (sPack.equals('IDEO') || sPack.equals('SOLO'))) || (sPack != null && (sPack.equals('ECOCFT'))) )){
                    return true;
                }
                if(AP_PricingUtilities.isRCOM(rebateType) && !this.isGEROwner){
                    return true;
                }
                if(AP_PricingUtilities.isRCONJ(rebateType)){
                    return true;
                }
            }
            if(familyName.toLowerCase().equals('redevance') ){
                if(AP_PricingUtilities.isRCE(rebateType) && ( subType != 'Butabox' || (sPack != null && (sPack.equals('ECOCFT'))) ) ){
                    return true;
                }
                String projectMarketType = this.currentQuote.Opportunity.Project_market_type__c;
                
                if(AP_PricingUtilities.isRCOM(rebateType) && (this.isGERConsumer || (this.IM_SPART.equals('42') && projectMarketType != null && projectMarketType.equals('DOM')))){
                    return true;
                }
                if(AP_PricingUtilities.isRCONJ(rebateType) && !(isGEROwner || isGEB)){
                    return true;
                }
            }
            
            
        
        
        
          
          
        return false;
    }
    
    
    /*public Boolean toDisable(String rebateType, String familyName){
        system.debug('AP_BusinessControls.toDisable('+rebateType+','+familyName+') (GEB : '+this.isGEB+')');
        if(familyName.toLowerCase().equals('equipement') || familyName.toLowerCase().equals('accessoire')){
            return true;
        }
        if(familyName.toLowerCase().equals('produit')){
            if(AP_PricingUtilities.isRCE(rebateType) && this.isGEROwner){
                return true;
            }
             if(AP_PricingUtilities.isRCE(rebateType) && this.isGEB){
                 
                return true;
            }
            if(AP_PricingUtilities.isRCOM(rebateType) && this.isGERConsumer){
                return true;
            }
            if(AP_PricingUtilities.isRCONJ(rebateType) && (this.isGERConsumer || this.IM_SPART.equals('43'))){
                return true;
            }
        }
        if(familyName.toLowerCase().equals('service')){
            if(AP_PricingUtilities.isRCE(rebateType) && (this.isGEROwner || this.isGERConsumer || this.isGEB || this.IM_SPART.equals('43'))){
                return true;
            }
            if(AP_PricingUtilities.isRCOM(rebateType) && !this.isGEROwner){
                return true;
            }
            if(AP_PricingUtilities.isRCONJ(rebateType)){
                return true;
            }
        }
        if(familyName.toLowerCase().equals('redevance')){
            if(AP_PricingUtilities.isRCE(rebateType)){
                return true;
            }
            String projectMarketType = this.currentQuote.Opportunity.Project_market_type__c;
            
            if(AP_PricingUtilities.isRCOM(rebateType) && (this.isGERConsumer || (this.IM_SPART.equals('42') && projectMarketType != null && projectMarketType.equals('DOM')))){
                return true;
            }
            if(AP_PricingUtilities.isRCONJ(rebateType) && !(isGEROwner || isGEB)){
                return true;
            }
        }
        return false;
    }*/

}