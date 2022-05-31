public class VFC_Quotelineitem_01{
    
    Quote current;
    
    Map<String, Boolean> pricingQuoteVisibility = new Map<String, Boolean>();
    public Boolean pricingQuoteVisibilityCommercialRebate {get; set;}
    public Boolean pricingQuoteVisibilityConsignationGrptoneshot {get; set;}
    public Boolean pricingQuoteVisibilityCyclicalRebate {get; set;}
    public Boolean pricingQuoteVisibilityGroupCommercialRebate {get; set;}
    public Boolean pricingQuoteVisibilityGroupCyclicalRebate {get; set;}
    public Boolean pricingQuoteVisibilityGroupementRebate {get; set;}
    public Boolean pricingQuoteVisibilityGroupementRebateOnProduct {get; set;}
    public Boolean pricingQuoteVisibilityRCERebate {get; set;}
    public Boolean pricingQuoteVisibilityRCERebateOnProduct {get; set;}
    public Boolean pricingQuoteVisibilityRemiseExceptionalforTankCNAB {get; set;}
    public Boolean pricingQuoteVisibilityRemiseGrptoneshot {get; set;}
    public Boolean pricingQuoteVisibilityDiscount {get; set;}
    public Boolean pricingQuoteVisibilityOfferedMonths {get; set;}
    public Boolean pricingQuoteVisibilityPaymentSpreadAmount {get; set;}
    
    
    public Boolean CEM {get; set;}     
    public Boolean COT {get; set;} 
    public Boolean VAPO {get; set;} 
    public decimal NewPriceHT {get; set;}
    public decimal NewPriceTTC {get; set;} /*MLC 20171102 STORY 419*/
    public decimal NewRedevancePriceHT {get; set;}
    public decimal NewRedevancePriceTTC {get; set;}
    public decimal groupCycRebLengthMonths {get; set;}
    public decimal TICPEAmountHT {get; set;}
    public decimal TICPEAmountTTC {get; set;}
    public decimal PaymentSpreadAmountHT {get; set;}
    public decimal PaymentSpreadAmountTTC {get; set;}
    public decimal RemisePostOffreHT {get; set;}
    public decimal RemisePostOffreTTC {get; set;}
    public decimal NormalProductScaleFromSAP {get; set;}
    public Boolean DisplayRunningFeesSentence {get; set;}
    public String scaleGEB {get; set;}
    public String vatCode {get; set;}
    public String priceTTCIdeoRemise {get; set;}
    public boolean hasTankAlreadyOnSite {get; set;}
    public String BioProduct {get; set;}
    public decimal BioOptionAmountHT {get; set;}
    public decimal BioOptionAmountTTC {get; set;}
    public decimal NewPriceECOTTC {get; set;} /*FLA 20210215 CASE 37*/
    public Boolean fraisResil {get; set;} /*FLA 20210315 CASE 265*/
    public String fraisResilBareme {get; set;} /*FLA 20210315 CASE 265*/
    public String CGVContratRef {get; set;} /*FLA 20210315 CASE 265*/
    public Boolean bActionComFixedPrice = false;
    public Boolean bModifStockage = false;
    public decimal FixedPriceHT {get; set;}
    public decimal OfferedMonths;
    public decimal RebateRconj;
    public decimal PriceListTTC;
    public Boolean CommercialRebateMessage = false;
    
    private Map<Integer, String> mSortDocs {get;set;}  // Map used to sort Scale Docs to render on VFP
    
    public static String isSE{get; set;} // Is the quote being electronically signed ?
    
     /**Debut  DPA - 30-03-2021 - Attributs: GEC PRO calcul des montant cumulé de RCE par PTL  */
     public  List<QuoteLineItem> listQuoteLI;
    public  map<String,Decimal> mapQPTLNameTotalRCEHTAmount;
    public decimal cumulRCEAmount ;
     /**Fin  DPA - 30-03-2021 - Attributs: GEC PRO calcul des montant cumulé de RCE par PTL  */
    
    ApexPages.StandardController stdController;
    
    
    public VFC_Quotelineitem_01(ApexPages.StandardController controller) {  
        if(!test.isrunningtest()){
            controller.addFields(new String[]{
                'Opportunity.Project_Type__c',
                    'Derogation_calcul_consommation__c',
                    'Opportunity.Project_Type__c',
                    'F_Activity_Domain_ExternalID__c',
                    'DO_Groupement__r.Scale_GEB__c',
                    'Opportunity.Account.Scale_GEB__c',
                    'Action_Commerciale__r.Offered_Months__c',
                    'VAT_code__c',
                    'Rollup_Total_Exceptional_Rebate_TTC__c',
                    'Opportunity.T_Pack__c',
                    'Opportunity.Project_market_subtype__c'
                    /*,
'Action_Commerciale__r.Locked_Price_1_Year__c',
'Action_Commerciale__r.Offered_Months__c'*/
                    });        
        }
        
        this.stdController = controller;
        current = (Quote) stdController.getRecord();
        
        System.debug(logginglevel.WARN,'### isSE =' + isSE);
        isSE = ApexPages.CurrentPage().getParameters().get('isSE');
        if(isSE == null){isSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        System.debug(logginglevel.WARN,'### isSE =' + isSE);
        
        this.calculatePricingQuoteVisibility();
        this.calculateCEM();
        this.calculateCOT();
        this.calculateVAPO();
        this.calculateNewPrice();
        this.calculateRedevanceNewPrice();
        //this.calculateNewPriceHT();
        //this.calculateNewPriceTTC();/*MLC 20171102 STORY 419*/
        /*this.calculateRunningFeesSentence();*/
        if(current.F_Activity_Domain_ExternalID__c == '41') {this.calculateScaleGEB();}
        //this.calculatePriceTTCIdeoRemise();
        this.calculateHasTankAlreadyOnSite();
        this.calculateFraisResil();
        
    }
    //FLA DEMANDE 265
    public void calculateFraisResil(){
        //VERIFIE SI ACTION COMMERCIALE PRIX FIXE
        if(current.Action_Commerciale__c != null)
        {
            if((current.Action_Commerciale__r.Fixed_Price__c == true)||(current.Action_Commerciale__r.Locked_Price_1_Year__c == true)||(current.Action_Commerciale__r.Locked_Price_2_Years__c == true)||(current.Action_Commerciale__r.Locked_Price_3_Years__c == true))
                this.bActionComFixedPrice = true;
        }
        //VERIFIE SI MODIFICATION DE STOCKAGE SUR OPP  
        if(current.OpportunityId != null)
        {
            if((current.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers enfoui')||
               (current.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers apparent')||
               (current.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers enfoui ECOCFT')||
               (current.Opportunity.Opportunity_Reason__c == 'Modif de stockage – enfoui vers apparent')||
               (current.Opportunity.Opportunity_Reason__c == 'Modif de stockage – enfoui vers enfoui'))
                this.bModifStockage = true;
        }
        
        if(((this.bModifStockage == true)||(this.bActionComFixedPrice == true)) && (current.Opportunity.Project_Type__c == 'FIDE'))
        {
            this.fraisResil = true;
            
            if(current.Market_type__c == 'DOM')
            {
                if((current.opportunity.T_Pack__c == 'IDEO')||(current.opportunity.T_Pack__c == 'SOLO')||(current.opportunity.T_Pack__c == 'OPTIMO'))
                    this.fraisResilBareme = 'SERVICES+ (IDEO/OPTIMO/SOLO)';
                if(current.opportunity.T_Pack__c == 'ECOCFT')
                    this.fraisResilBareme = 'SERVICES+ (ECOCONFORTIQUE)';
                if(current.opportunity.T_Pack__c == 'V1DOM PACK')
                    this.fraisResilBareme = 'V2P';
                this.CGVContratRef = '61200';
            }            
            if(current.Market_type__c == 'PRO')   
            {
                this.fraisResil = true; 
                this.fraisResilBareme = 'V2F';
                
                List<String> l61113 = new List<String>(); 
                l61113.add('Commerce/Service');
                l61113.add('Domestique');
                l61113.add('Collectivité/Administration');
                
                List<String> l61513 = new List<String>(); 
                l61513.add('Agriculture');
                l61513.add('Hôtel/Restauration');
                l61513.add('Industrie');
                l61513.add('Camping');
                
                if(l61113.contains(current.opportunity.Project_market_subtype__c))
                {
                    this.CGVContratRef = '61113';
                }
                if(l61513.contains(current.opportunity.Project_market_subtype__c))
                {
                    this.CGVContratRef = '61513';
                }
            }            
        } 
    }
    
    public string getPrettyDate() {
        Date today = Date.today();
        return today.format();
    } 
    
    public string getPrettyExpirationDate() {
        Date expirationDate = current.ExpirationDate;
        
        String result = '';
        if(expirationDate != null){ result = expirationDate.format(); }
        
        return result;
    }
    
    public string getPrettyCotationDate() {
        Date dateCotation = current.Date_de_cotation__c;
        
        String result= '';
        if(dateCotation != null){ result = dateCotation.format(); }
        
        return result;
    }
    
    public string getPrettyInstallationDate() {
        Date dateInstal = current.Opportunity.Installation_date__c;
        
        String result= '';
        if(dateInstal != null){ result = dateInstal.format(); }
        
        return result;
    }
    
    /* Condtioning used to render Pricing Tables to show or not show cells, and columns*/
    
    private void calculatePricingQuoteVisibility() {
        this.pricingQuoteVisibilityCommercialRebate = false;
        this.pricingQuoteVisibilityConsignationGrptoneshot = false;
        this.pricingQuoteVisibilityCyclicalRebate = false;
        this.pricingQuoteVisibilityGroupCommercialRebate = false;
        this.pricingQuoteVisibilityGroupCyclicalRebate = false;
        this.pricingQuoteVisibilityGroupementRebate = false;
        this.pricingQuoteVisibilityGroupementRebateOnProduct = false;
        this.pricingQuoteVisibilityRCERebate = false;
        this.pricingQuoteVisibilityRCERebateOnProduct = false;
        this.pricingQuoteVisibilityRemiseExceptionalforTankCNAB = false;
        this.pricingQuoteVisibilityRemiseGrptoneshot = false;
        this.pricingQuoteVisibilityDiscount = false;
        this.pricingQuoteVisibilityOfferedMonths = false;
        this.pricingQuoteVisibilityPaymentSpreadAmount = false;
      
        
        
        List<QuoteLineItem> quoteLineItems = this.getPricing();
        
        
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            
            if (quoteLineItem.Commercial_Rebate_TTC__c > 0  ) { this.pricingQuoteVisibilityCommercialRebate = true; }
            if (quoteLineItem.Consignation_Grpt_one_shot_HT__c > 0) { this.pricingQuoteVisibilityConsignationGrptoneshot = true; }
            if (quoteLineItem.Cyclical_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityCyclicalRebate = true; }
            if (quoteLineItem.Group_Commercial_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityGroupCommercialRebate = true; }
            if (quoteLineItem.Group_Cyclical_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityGroupCyclicalRebate = true; }
            if (quoteLineItem.Group_RCE_Rebate_HT__c > 0) { this.pricingQuoteVisibilityGroupementRebate = true; }
            if ( quoteLineItem.Product_Family__c == 'Produit' && quoteLineItem.Group_RCE_Rebate_HT__c > 0 ) { this.pricingQuoteVisibilityGroupementRebateOnProduct = true; }
            if (quoteLineItem.RCE_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityRCERebate = true; }
            if ( quoteLineItem.Product_Family__c == 'Produit' && quoteLineItem.RCE_Rebate_HT__c > 0 ) { this.pricingQuoteVisibilityRCERebateOnProduct = true; }
            if (quoteLineItem.Remise_Exceptional_for_Tank_CN_AB__c > 0) { this.pricingQuoteVisibilityRemiseExceptionalforTankCNAB = true; }
            if (quoteLineItem.Remise_Grpt_one_shot_HT__c > 0) { this.pricingQuoteVisibilityRemiseGrptoneshot = true; }
            if (quoteLineItem.Discount > 0) { this.pricingQuoteVisibilityDiscount = true; }
            if (quotelineItem.Offered_Months__c > 0){ this.pricingQuoteVisibilityOfferedMonths = true; }
            if (quotelineItem.Payment_Spread_Amount_TTC__c > 0){ this.pricingQuoteVisibilityPaymentSpreadAmount = true; }
          
        }
        
        
        List<QuoteLineItem> quoteLineItems2 = this.getPricing2();
        
        
        for (QuoteLineItem quoteLineItem2 : quoteLineItems2) {
            
            if (quoteLineItem2.Commercial_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityCommercialRebate = true; }
            if (quoteLineItem2.Consignation_Grpt_one_shot_HT__c > 0) { this.pricingQuoteVisibilityConsignationGrptoneshot = true; }
            if (quoteLineItem2.Cyclical_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityCyclicalRebate = true; }
            if (quoteLineItem2.Group_Commercial_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityGroupCommercialRebate = true; }
            if (quoteLineItem2.Group_Cyclical_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityGroupCyclicalRebate = true; }
            if (quoteLineItem2.Group_RCE_Rebate_HT__c > 0) { this.pricingQuoteVisibilityGroupementRebate = true; }
            if ( quoteLineItem2.Product_Family__c == 'Produit' && quoteLineItem2.Group_RCE_Rebate_HT__c > 0 ) { this.pricingQuoteVisibilityGroupementRebateOnProduct = true; }
            if (quoteLineItem2.RCE_Rebate_TTC__c > 0) { this.pricingQuoteVisibilityRCERebate = true; }
            if ( quoteLineItem2.Product_Family__c == 'Produit' && quoteLineItem2.RCE_Rebate_HT__c > 0 ) { this.pricingQuoteVisibilityRCERebateOnProduct = true; }
            if (quoteLineItem2.Remise_Exceptional_for_Tank_CN_AB__c > 0) { this.pricingQuoteVisibilityRemiseExceptionalforTankCNAB = true; }
            if (quoteLineItem2.Remise_Grpt_one_shot_HT__c > 0) { this.pricingQuoteVisibilityRemiseGrptoneshot = true; }
            if (quoteLineItem2.Discount > 0) { this.pricingQuoteVisibilityDiscount = true; }
            if (quotelineItem2.Offered_Months__c > 0){ this.pricingQuoteVisibilityOfferedMonths = true; }
            if (quotelineItem2.Payment_Spread_Amount_TTC__c > 0){ this.pricingQuoteVisibilityPaymentSpreadAmount = true; }
           
            
        }
        
        
        
        
    }
    
    /* used to show text based on the CEM  checkbox on Product, when in the QLI this is chosen the text renders on this condition, */
    
    private void calculateCEM() {
        this.CEM= false;
        List<QuoteLineItem> quoteLineItems = this.getService();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.PricebookEntry.Product2.CEM__c) { this.CEM = true; }
        }
    }
     
    /* Condition to show extra column for Customer owned tank  ( user sets this in editing the QLI for Tanks)*/
    
    private void calculateCOT() {
        this.COT= false;
        List<QuoteLineItem> quoteLineItems = this.getQuoteLineItems();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.Mis_Disposition__c=='Customer Owned Tank') { this.COT = true; }
        }
    }
    
    /* Condition set on Product to show some text for Gros vrac  : if the product is a Vapo then text in the vfp shows*/
    
    private void calculateVAPO() {
        this.VAPO= false;
        
        List<QuoteLineItem> quoteLineItems = this.getPricing();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.PricebookEntry.Product2.VAPO__c) { this.VAPO = true; }
        }
    }
    
    private void calculateRedevanceNewPrice() {
        this.NewRedevancePriceHT = 0;
        this.NewRedevancePriceTTC = 0;
        
        List<QuoteLineItem> quoteLineItems = this.getRedevence();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            // Make sure this applies only to redevance linked to Energy access
            if(quoteLineItem.PricebookEntry.Product2.ProductCode == 'SPPABO0010' || quoteLineItem.PricebookEntry.Product2.ProductCode == 'SPPABO0008'){
                this.NewRedevancePriceHT = quoteLineItem.New_Price_HT__c != null ? quoteLineItem.New_Price_HT__c : 0;
                this.NewRedevancePriceTTC = quoteLineItem.New_Price_TTC__c != null ? quoteLineItem.New_Price_TTC__c : 0;
                break;
            }
        }
    }
    /*
* Return the list of All Equipment__c related to the current Opportunity's Existing_PTL__c
*/
    public List<Equipement__c> getPTLEQUIPEMENTS() {
        
        List<Equipement__c> equipementsFromExistingPTLOnOpty = new List<Equipement__c>();
        
        if(current.opportunity.Existing_PTL__c != null){
            equipementsFromExistingPTLOnOpty = [select Article__r.Name,Tank_Type__c,Capacity_Tank__c,Name,PTL__c,ExternalID__c,Designation__c from Equipement__C where PTL__c = :current.opportunity.Existing_PTL__c];
        }
        
        return equipementsFromExistingPTLOnOpty;
    }
    /*
* Return the Quote_PTL__c related to the current Opportunity's Existing_PTL__c
*/
    public Quote_PTL__c getQuotePTLFromOptyExistingPTL() {
        
        Quote_PTL__c quotePTLFromOptyExistingPTL = null;
        
        if(current.opportunity.Existing_PTL__c != null){
            list<Quote_PTL__c> lQPTL = [select Id, RPTL_Purposes__c from Quote_PTL__c where Opportunity_PTL__r.PTL__c = :current.opportunity.Existing_PTL__c and Quote__c = :current.Id];
            if (lQPTL.size() > 0) {
                quotePTLFromOptyExistingPTL=lQPTL.get(0) ;               
            }               
        }
        return quotePTLFromOptyExistingPTL;
    }
     
    public String getDateAddMonth(){
        date myDate = Date.today();
        date newDate = mydate.addMonths(2); 
        return newDate.format(); 
    }
    
    /*private void calculatePriceTTCIdeoRemise() {
this.priceTTCIdeoRemise='';
List<QuoteLineItem> quoteLineItems = this.getProduits();
for (QuoteLineItem quoteLineItem : quoteLineItems) {
//if (quoteLineItem.PricebookEntry.Product2.CEM__c) { this.priceTTCIdeoRemise = ''; }
this.priceTTCIdeoRemise = String.valueOf(quotelineitem.New_Price_TTC__c);
}
}*/
    /* there is two sets of lists built for all Tables now:  one for QLI that are NOT used for GER usager to show in tables that need to show all non usager QLI*/ 
    
    
    /* ----------SET ONE-------FOR NON USAGER QLI-----------*/
    
    public List<QuoteLineItem> getQuoteLineItems() {
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [
            SELECT 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
            Linenumber,
            pricebookentry.Name,
            CreatedDate,
            New_Price_HT__c,
            CreatedById,
            Tank_Placing_Type__c,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            QuoteId,
            PricebookEntryId,
            Quantity,
            UnitPrice,
            F_Product_Code__c,
            Discount,
            Description,
            ServiceDate,
            SortOrder,
            ListPrice,
            New_Price_TTC__c,
            Got_From_SAP__c,
            F_Quantity_Unit__c,
            Subtotal,
            TotalPrice, 
            Price_List_HT__c,
            Price_List_TTC__c,
            Group_Commercial_Rebate_HT__c,
            Group_Commercial_Rebate_TTC__c,
            Commercial_Rebate_HT__c,
            Commercial_Rebate_TTC__c,
            Group_Cyclical_Rebate_HT__c,
            Group_Cyclical_Rebate_TTC__c,
            
            Cyclical_Rebate_HT__c,
            Cyclical_Rebate_TTC__c,
            RCE_Rebate_HT__c,
            RCE_Rebate_TTC__c,
            Transport_Increase_HT__c,
            Transport_Increase_TTC__c,
            Tank_Capacity__c,
            T_TANK_CAPACITY_NUMBER__c,
            Linked_PTL__c,
            T_PTL_InFormation__c,
            Mis_Disposition__c,
            
            Remise_Grpt_one_shot_HT__c,
            Consignation_Grpt_one_shot_HT__c,
            Cyclical_Rebate_Months__c,
            
            Usage__c,
            Tax__c,
            Product_Description__c,
            From_Date__c,
            To_Date__c,
            Remise_Exceptional_for_Tank_CN_AB__c,
            Product_Family__c, 
            Quantity_Unit__c,
            Amount_Unit__c,
            Pricing_Unit__c,
            Start_Date_remise_Exc_Subscription__c,
            End_Date_remise_Exc_Subscription__c,
            Quote_PTL__r.Opportunity_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
            
            Quote_PTL__r.Opportunity_PTL__r.CreatedById,
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
            Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
            Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
            Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c, Quote_PTL__r.Consumption_From_Excel__c, 
            Quote_PTL__r.Consumptioncurveprofile__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c, Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c, Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c, Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c, Quote_PTL__r.RPTL_Purposes__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c, Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c, Quote_PTL__r.Consumption_fixed_apr__c, Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name, Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
            Quote_PTL__r.Consumption_fixed_feb__c, Quote_PTL__r.Consumption_fixed_jan__c, Quote_PTL__r.Consumption_fixed_jul__c, Quote_PTL__r.Consumption_fixed_jun__c, Quote_PTL__r.Consumption_fixed_mar__c, 
            Quote_PTL__r.Consumption_fixed_may__c, Quote_PTL__r.Consumption_fixed_nov__c, Quote_PTL__r.Consumption_fixed_oct__c, Quote_PTL__r.Consumption_fixed_sep__c,  
            Quote_PTL__r.Consumption_variable_apr__c, Quote_PTL__r.Consumption_variable_aug__c, Quote_PTL__r.Consumption_variable_dec__c, Quote_PTL__r.Consumption_variable_feb__c, 
            Quote_PTL__r.Consumption_variable_jan__c, Quote_PTL__r.Consumption_variable_jul__c, Quote_PTL__r.Consumption_variable_jun__c, Quote_PTL__r.Consumption_variable_mar__c, 
            Quote_PTL__r.Consumption_variable_may__c, Quote_PTL__r.Consumption_variable_nov__c, Quote_PTL__r.Consumption_variable_oct__c, Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
            Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
            Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
            Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
            Customer_Owned_Tank_Name__c,
            Customer_Owned_Tank_ReApprBefore_Date__c,
            Customer_Owned_Tank_Serial_Number__c,
            Customer_Owned_Tank_Appr_Date__c,
            Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
            Cles_en_Main__c,
            Concrete__c,
            Connected_Tank__c,
            Concrete_Tile_Flooring__c,
            Detente_3_Bar__c,
            Drain__c,
            Earliest_Tank_moving_Date__c,
            Enhance_Jauge__c,
            Evacuation_of_Dirt_Rubble__c,
            Flooring_for_Burried_ballast_Tank__c,
            Insdustrial_Outflow__c,
            Intervention__c,
            Land_spreading_10_m__c,
            Latest_Tank_moving_Date_MEP__c,
            Mechanic_type__c,
            MEP_Tank_Placing_Type_Details__c,
            Modification_of_the_Installation_Needed__c,
            Mouvement_a_la_meme_adresse_pour_Butagaz__c,
            Percentage_Jauge_Competitor_Tank__c,
            Precheck_Tank_Connection__c,
            Preparation_trench__c,
            Pre_Visit__c,
            Supplementary_Filling__c,
            System_Cut_off_point_at_liquid_Channel__c,
            Simultaneous_MEP__c,
            TeleJauge__c,
            Three_point_attachement__c,
            MEP_Comments__c,
            Tank_Placing_Options__c,
            Sub_Type__c,
            
            Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
            /* Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c,
            Offered_Months__c,
            F_MonthlyPriceDisplay__c,
            
            // Erwan 20181217
            TICPE_Amount_HT__c,
            TICPE_Amount_TTC__c,
            Remise_Post_Offre_HT__c,
            Remise_Post_Offre_TTC__c,
            Normal_Product_Scale_From_SAP__c,
            
            // Erwan 20190430
            Payment_Spread_Amount_HT__c,
            Payment_Spread_Amount_TTC__c,
            
            // Erwan 20191203
            Bio_Product__c,
            Bio_Option_Amount_HT__c,
            Bio_Option_Amount_TTC__c,
            F_Rollup_BioPercentage__c,  
            
            // MLC 20210527
            Fixed_Price_HT__c,
            
            //MLC 20211209
            F_Payment_Type__c
            
            FROM quotelineitem where QuoteId = :current.Id and Sub_type__c = 'Citerne' and Tank_placing_options__c != 'RDS' and Deconsignation__c=false and PricebookEntry.Product2.UseConsumerTarget__c=false ];
        
        return quotelineitemList;
        
        
        
        
        
        
    }
    
    public List<QuoteLineItem> getExistingCiterne() {
        
        
        
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [
            SELECT 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
            Linenumber,
            pricebookentry.Name,
            CreatedDate,
            New_Price_HT__c,
            CreatedById,
            Tank_Placing_Type__c,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            New_Price_TTC__c,
            QuoteId,
            PricebookEntryId,
            Quantity,
            UnitPrice,
            F_Product_Code__c,
            Discount,
            Description,
            ServiceDate,
            SortOrder,
            ListPrice,
            Got_From_SAP__c,
            F_Quantity_Unit__c,
            Subtotal,
            TotalPrice, 
            Price_List_HT__c,
            Price_List_TTC__c,
            Group_Commercial_Rebate_HT__c,
            Group_Commercial_Rebate_TTC__c,
            Commercial_Rebate_HT__c,
            Commercial_Rebate_TTC__c,
            Group_Cyclical_Rebate_HT__c,
            Group_Cyclical_Rebate_TTC__c,
            
            Cyclical_Rebate_HT__c,
            Cyclical_Rebate_TTC__c,
            RCE_Rebate_HT__c,
            RCE_Rebate_TTC__c,
            Transport_Increase_HT__c,
            Transport_Increase_TTC__c,
            Tank_Capacity__c,
            T_TANK_CAPACITY_NUMBER__c,
            Linked_PTL__c,
            T_PTL_InFormation__c,
            Mis_Disposition__c,
            
            Remise_Grpt_one_shot_HT__c,
            Consignation_Grpt_one_shot_HT__c,
            Cyclical_Rebate_Months__c,
            
            Usage__c,
            Tax__c,
            Product_Description__c,
            From_Date__c,
            To_Date__c,
            Remise_Exceptional_for_Tank_CN_AB__c,
            Product_Family__c, 
            Quantity_Unit__c,
            Amount_Unit__c,
            Pricing_Unit__c,
            Start_Date_remise_Exc_Subscription__c,
            End_Date_remise_Exc_Subscription__c,
            Quote_PTL__r.Opportunity_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
            
            Quote_PTL__r.Opportunity_PTL__r.CreatedById,
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
            Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
            Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
            Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c,  Quote_PTL__r.Consumption_From_Excel__c, 
            Quote_PTL__r.Consumptioncurveprofile__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c,  Quote_PTL__r.RPTL_Purposes__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c,  Quote_PTL__r.Consumption_fixed_apr__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name,  Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
            Quote_PTL__r.Consumption_fixed_feb__c,  Quote_PTL__r.Consumption_fixed_jan__c,  Quote_PTL__r.Consumption_fixed_jul__c,  Quote_PTL__r.Consumption_fixed_jun__c,  Quote_PTL__r.Consumption_fixed_mar__c, 
            Quote_PTL__r.Consumption_fixed_may__c,  Quote_PTL__r.Consumption_fixed_nov__c,  Quote_PTL__r.Consumption_fixed_oct__c,  Quote_PTL__r.Consumption_fixed_sep__c,  
            Quote_PTL__r.Consumption_variable_apr__c,  Quote_PTL__r.Consumption_variable_aug__c,  Quote_PTL__r.Consumption_variable_dec__c,  Quote_PTL__r.Consumption_variable_feb__c, 
            Quote_PTL__r.Consumption_variable_jan__c,  Quote_PTL__r.Consumption_variable_jul__c,  Quote_PTL__r.Consumption_variable_jun__c,  Quote_PTL__r.Consumption_variable_mar__c, 
            Quote_PTL__r.Consumption_variable_may__c,  Quote_PTL__r.Consumption_variable_nov__c,  Quote_PTL__r.Consumption_variable_oct__c,  Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
            Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
            Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
            Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
            Customer_Owned_Tank_Name__c,
            Customer_Owned_Tank_ReApprBefore_Date__c,
            Customer_Owned_Tank_Serial_Number__c,
            Customer_Owned_Tank_Appr_Date__c,
            Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
            Cles_en_Main__c,
            Concrete__c,
            Connected_Tank__c,
            Concrete_Tile_Flooring__c,
            Detente_3_Bar__c,
            Drain__c,
            Earliest_Tank_moving_Date__c,
            Enhance_Jauge__c,
            Evacuation_of_Dirt_Rubble__c,
            Flooring_for_Burried_ballast_Tank__c,
            Insdustrial_Outflow__c,
            Intervention__c,
            Land_spreading_10_m__c,
            Latest_Tank_moving_Date_MEP__c,
            Mechanic_type__c,
            MEP_Tank_Placing_Type_Details__c,
            Modification_of_the_Installation_Needed__c,
            Mouvement_a_la_meme_adresse_pour_Butagaz__c,
            Percentage_Jauge_Competitor_Tank__c,
            Precheck_Tank_Connection__c,
            Preparation_trench__c,
            Pre_Visit__c,
            Supplementary_Filling__c,
            System_Cut_off_point_at_liquid_Channel__c,
            Simultaneous_MEP__c,
            TeleJauge__c,
            Three_point_attachement__c,
            MEP_Comments__c,
            Tank_Placing_Options__c,
            
            
            Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c, 
            Offered_Months__c,
            F_MonthlyPriceDisplay__c,
            
            // Erwan 20181217
            TICPE_Amount_HT__c,
            TICPE_Amount_TTC__c,
            Remise_Post_Offre_HT__c,
            Remise_Post_Offre_TTC__c,
            Normal_Product_Scale_From_SAP__c,
            
            // Erwan 20190430
            Payment_Spread_Amount_HT__c,
            Payment_Spread_Amount_TTC__c,
            
            // Erwan 20191203
            Bio_Product__c,
            Bio_Option_Amount_HT__c,
            Bio_Option_Amount_TTC__c,
            F_Rollup_BioPercentage__c,
            
            //MLC 20211209
            F_Payment_Type__c
            
            FROM quotelineitem where QuoteId = :current.Id and Sub_type__c = 'Citerne' and Got_from_SAP__c=true  and PricebookEntry.Product2.UseConsumerTarget__c=false ];
        
        return quotelineitemList;
        
    } 
    
    public List<QuoteLineItem> getService() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select 
                             Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             New_Price_HT__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,
                             Group_Cyclical_Rebate_TTC__c,
                             Quote_PTL__r.PTL_Name__c,
                             F_Quantity_Unit__c,
                             Mis_Disposition__c,
                             New_Price_TTC__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             PricebookEntry.Product2.CEM__c ,
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,Group_Cyclical_Rebate_lenght_in_months__c,
                             F_Product_Code__c,Quote_PTL__r.PTL_Label__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and (Product_Family__c ='Accessoire' OR Product_Family__c ='Service')and Deconsignation__c=false and PricebookEntry.Product2.UseConsumerTarget__c=false   ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c];      
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getRedevence() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select 
                             Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             New_Price_HT__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,         
                             Group_Cyclical_Rebate_TTC__c,
                             F_Quantity_Unit__c,
                             New_Price_TTC__c,
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             PricebookEntry.Product2.ProductCode,
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,Group_Cyclical_Rebate_lenght_in_months__c,
                             F_Product_Code__c,Quote_PTL__r.PTL_Label__c ,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Redevance' and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c];      
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getOtherEquipment() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select 
                             Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             New_Price_HT__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,         
                             Group_Cyclical_Rebate_TTC__c,
                             F_Quantity_Unit__c,
                             New_Price_TTC__c,
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,Group_Cyclical_Rebate_lenght_in_months__c,
                             F_Product_Code__c,Quote_PTL__r.PTL_Label__c ,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Equipement' and Sub_type__c != 'Citerne' and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c];      
        return quotelineitemList;
        
        
    }       
    
    public List<QuoteLineItem> getPricing() {
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             PricebookEntry.Product2.VAPO__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             New_Price_HT__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_RCE_Rebate_HT__c,
                             Group_RCE_Rebate_TTC__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,
                             F_Quantity_Unit__c,
                             Group_Cyclical_Rebate_TTC__c,
                             New_Price_TTC__c,
                             
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,
                             To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             Group_Cyclical_Rebate_lenght_in_months__c, 
                             
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,F_Product_Code__c,Quote_PTL__r.PTL_Label__c,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20190924
                             /*Tank_Placing_Options__c,
Tank_Pumping_Required__c,*/
                             PricebookEntry.Product2.Standardized_Form__c,
                             Only_for_Standardized_Form__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,  
            
                            // MLC 20210527
                            Fixed_Price_HT__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id  and Tank_placing_options__c != 'RDS' and Deconsignation__c=false and PricebookEntry.Product2.UseConsumerTarget__c=false and Only_for_Standardized_Form__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getTarificationLinesForGerProprietaire() {
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             PricebookEntry.Product2.VAPO__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             New_Price_HT__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_RCE_Rebate_HT__c,
                             Group_RCE_Rebate_TTC__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,
                             F_Quantity_Unit__c,
                             Group_Cyclical_Rebate_TTC__c,
                             New_Price_TTC__c,
                             
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,
                             To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             Group_Cyclical_Rebate_lenght_in_months__c, 
                             
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,F_Product_Code__c,Quote_PTL__r.PTL_Label__c,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id   and Deconsignation__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getProduits() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Start_Date_remise_Exc_Subscription__c, End_Date_remise_Exc_Subscription__c, Quantity_Unit__c,Pricing_Unit__c,Amount_Unit__c,Product_Family__c, Commercial_Rebate_TTC__c,
                             Consignation_Grpt_one_shot_HT__c,Cyclical_Rebate_Months__c,Cyclical_Rebate_HT__c,Cyclical_Rebate_TTC__c,From_Date__c,Group_Commercial_Rebate_HT__c,Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,Group_Cyclical_Rebate_TTC__c,Group_RCE_Rebate_HT__c,Group_RCE_Rebate_TTC__c,Mis_Disposition__c,Ger_consumption__c,
                             Price_List_HT__c,Price_List_TTC__c,Product_Description__c,RCE_Rebate_HT__c,RCE_Rebate_TTC__c,Commercial_Rebate_HT__c,Remise_Exceptional_for_Tank_CN_AB__c,Remise_Grpt_one_shot_HT__c,T_TANK_CAPACITY_NUMBER__c,Tank_Capacity__c,
                             Tax__c,To_Date__c,Transport_Increase_HT__c,Transport_Increase_TTC__c,Usage__c,ListPrice, Quantity, pricebookentry.Name, Quote_PTL__r.Opportunity_PTL__r.PTL__c, Discount, Description, totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_number__c,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,F_Quantity_Unit__c,New_Price_TTC__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,Quote_PTL__r.PTL_Name__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,Tank_Placing_Type__c,New_Price_HT__c,
                             Quote_PTL__r.RPTL_Purposes__c,Group_Cyclical_Rebate_lenght_in_months__c,F_Product_Code__c,Quote_PTL__r.PTL_Label__c , Offered_Months__c,F_MonthlyPriceDisplay__c,
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,  
            
                            // MLC 20210527
                            Fixed_Price_HT__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Produit' and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getProduitsRedevanceType() {
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Id, New_Price_TTC__c, F_Product_Code__c 
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Redevance' and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=false ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
    } 
      
    public List<Quote_PTL__c> getQUOTEPTLS() {
        
        
        List<Quote_PTL__c> Baslist;
        
        Baslist = [select Name, Opportunity_PTL__r.PTL__r.Name, PTL_Name__c ,PTL_Label__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__c,
                   Opportunity_PTL__r.PTL__r.Account_Groupement__c,
                   Opportunity_PTL__r.PTL__r.Activity_Domain__c,
                   Opportunity_PTL__r.PTL__r.Address__c,
                   Opportunity_PTL__r.PTL__r.ADV_deletion_flag__c,
                   Opportunity_PTL__r.PTL__r.Anniversary_date__c,
                   Opportunity_PTL__r.PTL__r.Blocking_Commands_ADV__c,
                   Opportunity_PTL__r.PTL__r.Blocking_Commands_General__c,
                   Opportunity_PTL__r.PTL__r.Blocking_Delivery_ADV__c,
                   Opportunity_PTL__r.PTL__r.Blocking_Delivery_General__c,
                   Opportunity_PTL__r.PTL__r.Call_client_before_delivery__c,
                   Opportunity_PTL__r.PTL__r.City__c,
                   Opportunity_PTL__r.PTL__r.City_code__c,
                   Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
                   /*Opportunity_PTL__r.PTL__r.Code_AC_administrator__c,
Opportunity_PTL__r.PTL__r.Code_AC_administrator_value__c,*/
                   Opportunity_PTL__r.PTL__r.Code_AC_administrator_New__c,
                   Opportunity_PTL__r.PTL__r.Code_branche__c,
                   Opportunity_PTL__r.PTL__r.Code_branche_value__c,
                   Opportunity_PTL__r.PTL__r.Code_division__c,
                   Opportunity_PTL__r.PTL__r.Code_division_value__c,
                   Opportunity_PTL__r.PTL__r.Code_NACE__c,
                   /*Opportunity_PTL__r.PTL__r.Code_NACE_value__c,*/
                   Opportunity_PTL__r.PTL__r.Code_NAF__c,
                   Opportunity_PTL__r.PTL__r.Country__c,
                   Opportunity_PTL__r.PTL__r.Customer_presence__c,
                   Opportunity_PTL__r.PTL__r.Date_at_the_End_of_Dispensation__c,
                   Opportunity_PTL__r.PTL__r.Date_Connecting__c,
                   Opportunity_PTL__r.PTL__r.Seasonal_Date_of_Period_End__c,
                   Opportunity_PTL__r.PTL__r.Seasonal_Date_of_Period_Start__c,
                   Opportunity_PTL__r.PTL__r.Days_no_Delivery_possible__c,
                   Opportunity_PTL__r.PTL__r.Delivery_possible_in_absence_of_client__c,
                   Opportunity_PTL__r.PTL__r.Department__c,
                   Opportunity_PTL__r.PTL__r.E_mail__c,
                   Opportunity_PTL__r.PTL__r.Estimated_or_Real_Capacity__c,
                   Opportunity_PTL__r.PTL__r.Etimated_or_Real_Consumption__c,
                   Opportunity_PTL__r.PTL__r.ExternalID__c,
                   Opportunity_PTL__r.PTL__r.Fax_Number__c,
                   Opportunity_PTL__r.PTL__r.First_and_Last_Name__c,
                   Opportunity_PTL__r.PTL__r.Fiscal_class_PTL__c,
                   Opportunity_PTL__r.PTL__r.Gal_deletion_flag__c,
                   Opportunity_PTL__r.PTL__r.Gasdeliverymode__c,
                   Opportunity_PTL__r.PTL__r.Label__c,
                   Opportunity_PTL__r.PTL_City__c ,
                   Opportunity_PTL__r.PTL_Postal_code__c ,
                   Opportunity_PTL__r.PTL__r.Limitation_of_Tonnage__c,
                   Opportunity_PTL__r.PTL__r.Limitation_of_Vehicle__c,
                   Opportunity_PTL__r.PTL__r.Mandataire__c,
                   Opportunity_PTL__r.PTL__r.Mandataire_Name__c,
                   Opportunity_PTL__r.PTL__r.Market_Sub_Type__c,
                   Opportunity_PTL__r.PTL__r.Market_type__c,
                   Opportunity_PTL__r.PTL__r.Mobile_Phone_Number__c,
                   Opportunity_PTL__r.PTL__r.Network__c,
                   Opportunity_PTL__r.PTL__r.Number_extention__c,
                   Opportunity_PTL__r.PTL__r.Opportunity_Number__c,
                   Opportunity_PTL__r.PTL__r.Payment_Delay__c,
                   Opportunity_PTL__r.PTL__r.PDV_Number__c,
                   Opportunity_PTL__r.PTL__r.Period_Frequency__c,
                   Opportunity_PTL__r.PTL__r.Periodic_delivery__c,
                   Opportunity_PTL__r.PTL__r.Permanent_dispensation__c,
                   Opportunity_PTL__r.PTL__r.Phone__c,
                   Opportunity_PTL__r.PTL__r.Place_Called__c,
                   Opportunity_PTL__r.PTL__r.Postal_Box__c,
                   Opportunity_PTL__r.PTL__r.Postal_code__c,
                   Opportunity_PTL__r.PTL__r.Precheck_Truck_needed__c,
                   Opportunity_PTL__r.PTL__r.Purposes__c,
                   Opportunity_PTL__r.PTL__r.Restriction_of_the_vehicule__c,
                   Opportunity_PTL__r.PTL__r.SAP_City_Code__c,
                   Opportunity_PTL__r.PTL__r.SAP_City_Name__c,
                   Opportunity_PTL__r.PTL__r.SAP_Postal_Code__c,
                   Opportunity_PTL__r.PTL__r.Scale__c,
                   Opportunity_PTL__r.PTL__r.Scale_Code__c,
                   Opportunity_PTL__r.PTL__r.Shipping_Condition__c,
                   Opportunity_PTL__r.PTL__r.Status__c,
                   Opportunity_PTL__r.PTL__r.Street_name__c,
                   Opportunity_PTL__r.PTL__r.Street_number__c,
                   Opportunity_PTL__r.PTL__r.Street_type__c,
                   Opportunity_PTL__r.PTL__r.Temporary_dispensation__c,
                   Opportunity_PTL__r.PTL__r.Title__c,
                   Opportunity_PTL__r.PTL__r.Truck_delivery_condition_details__c,
                   Opportunity_PTL__r.PTL__r.Value_added_tax_within_the_Community__c,
                   Opportunity_PTL__r.PTL__r.Value_of_tonnage_limitation__c,
                   Opportunity_PTL__r.PTL__r.VAT_code__c,
                   Opportunity_PTL__r.PTL__r.VAT_code_sap__c,
                   Opportunity_PTL__r.PTL__r.Work_Phone_Number__c,
                   Opportunity_PTL__r.PTL__r.PDF_Hours_of_delivery_not_possible__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Name,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Street_Name__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Street_n__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.City_postal_code__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Postal_code__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.City__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.City_Postal_Code__r.Name,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.PersonOtherPhone,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.AccountNumber,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Street_type__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Country__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.PersonEmail,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.PersonHomePhone,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.PersonMobilePhone,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Phone,
                   Opportunity_PTL__r.PTL_VAT_code__c,
                   
                   Opportunity_PTL__r.PTL_Street_name__c,  
                   Opportunity_PTL__r.PTL_Street_number__c,    
                   Opportunity_PTL__r.PTL_Number_extention__c,
                   Opportunity_PTL__r.PTL_Street_type__c,
                   Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                   Opportunity_PTL__r.PTL_Name__c,
                   Opportunity_PTL__r.PTL_Label__c,
                   Opportunity_PTL__r.PTL__r.Account_DO__r.Phone_Restriction__c,
                   RPTL_Purposes__c,
                   Opportunity_PTL__r.PTL_First_and_Last_Name__c,
                   Opportunity_PTL__r.PTL_E_mail__c,
                   Opportunity_PTL__r.PTL_Work_Phone_Number__c,
                   Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,
                   Opportunity_PTL__r.PTL_Phone__c,
                   Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,
                   Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,
                   Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,
                   Opportunity_PTL__r.PTL_PDF_Hours_of_delivery_not_possible__c,
                   Opportunity_PTL__r.PTL_Days_no_Delivery_possible__c,
                   Opportunity_PTL__r.PTL_Precheck_Truck_needed__c, 
                   Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,
                   Opportunity_PTL__r.PTL_Shipping_Condition__c,
                   Opportunity_PTL__r.PTL_Gasdeliverymode__c,
                   Opportunity_PTL__r.PTL_Clayground__c,
                   Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
                   Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
                   Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
                   Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,
                   Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
                   Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
                   Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,
                   Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
                   Opportunity_PTL__r.PTL_Septic_Tank__c,
                   Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
                   Opportunity_PTL__r.PTL_Size_3m__c,
                   Opportunity_PTL__r.PTL_With_wall__c,
                   Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
                   Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c 
                   
                   
                   
                   from QUOTE_PTL__C where Quote__c = :current.Id];
        
        return Baslist;
        
        
        
        
    }
    
    /* END OF SET ONE----------------------------*/

    /* SET TWO this set of lists are used solely for GER USAGER QLI to show for the precigaz contracts*/

    public List<QuoteLineItem> getQuoteLineItems2() {
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [
            SELECT 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
            Linenumber,
            pricebookentry.Name,
            CreatedDate,
            New_Price_HT__c,
            CreatedById,
            Tank_Placing_Type__c,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            QuoteId,
            PricebookEntryId,
            Quantity,
            UnitPrice,
            F_Product_Code__c,
            Discount,
            Description,
            ServiceDate,
            SortOrder,
            ListPrice,
            New_Price_TTC__c,
            Got_From_SAP__c,
            F_Quantity_Unit__c,
            Subtotal,
            TotalPrice, 
            Price_List_HT__c,
            Price_List_TTC__c,
            Group_Commercial_Rebate_HT__c,
            Group_Commercial_Rebate_TTC__c,
            Commercial_Rebate_HT__c,
            Commercial_Rebate_TTC__c,
            Group_Cyclical_Rebate_HT__c,
            Group_Cyclical_Rebate_TTC__c,
            
            Cyclical_Rebate_HT__c,
            Cyclical_Rebate_TTC__c,
            RCE_Rebate_HT__c,
            RCE_Rebate_TTC__c,
            Transport_Increase_HT__c,
            Transport_Increase_TTC__c,
            Tank_Capacity__c,
            T_TANK_CAPACITY_NUMBER__c,
            Linked_PTL__c,
            T_PTL_InFormation__c,
            Mis_Disposition__c,
            
            Remise_Grpt_one_shot_HT__c,
            Consignation_Grpt_one_shot_HT__c,
            Cyclical_Rebate_Months__c,
            
            Usage__c,
            Tax__c,
            Product_Description__c,
            From_Date__c,
            To_Date__c,
            Remise_Exceptional_for_Tank_CN_AB__c,
            Product_Family__c, 
            Quantity_Unit__c,
            Amount_Unit__c,
            Pricing_Unit__c,
            Start_Date_remise_Exc_Subscription__c,
            End_Date_remise_Exc_Subscription__c,
            Quote_PTL__r.Opportunity_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
            
            Quote_PTL__r.Opportunity_PTL__r.CreatedById,
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
            Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
            Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
            Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c,  Quote_PTL__r.Consumption_From_Excel__c, 
            Quote_PTL__r.Consumptioncurveprofile__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c,  Quote_PTL__r.RPTL_Purposes__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c,  Quote_PTL__r.Consumption_fixed_apr__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name,  Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
            Quote_PTL__r.Consumption_fixed_feb__c,  Quote_PTL__r.Consumption_fixed_jan__c,  Quote_PTL__r.Consumption_fixed_jul__c,  Quote_PTL__r.Consumption_fixed_jun__c,  Quote_PTL__r.Consumption_fixed_mar__c, 
            Quote_PTL__r.Consumption_fixed_may__c,  Quote_PTL__r.Consumption_fixed_nov__c,  Quote_PTL__r.Consumption_fixed_oct__c,  Quote_PTL__r.Consumption_fixed_sep__c,  
            Quote_PTL__r.Consumption_variable_apr__c,  Quote_PTL__r.Consumption_variable_aug__c,  Quote_PTL__r.Consumption_variable_dec__c,  Quote_PTL__r.Consumption_variable_feb__c, 
            Quote_PTL__r.Consumption_variable_jan__c,  Quote_PTL__r.Consumption_variable_jul__c,  Quote_PTL__r.Consumption_variable_jun__c,  Quote_PTL__r.Consumption_variable_mar__c, 
            Quote_PTL__r.Consumption_variable_may__c,  Quote_PTL__r.Consumption_variable_nov__c,  Quote_PTL__r.Consumption_variable_oct__c,  Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
            Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
            Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
            Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
            Customer_Owned_Tank_Name__c,
            Customer_Owned_Tank_ReApprBefore_Date__c,
            Customer_Owned_Tank_Serial_Number__c,
            Customer_Owned_Tank_Appr_Date__c,
            Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
            Cles_en_Main__c,
            Concrete__c,
            Connected_Tank__c,
            Concrete_Tile_Flooring__c,
            Detente_3_Bar__c,
            Drain__c,
            Earliest_Tank_moving_Date__c,
            Enhance_Jauge__c,
            Evacuation_of_Dirt_Rubble__c,
            Flooring_for_Burried_ballast_Tank__c,
            Insdustrial_Outflow__c,
            Intervention__c,
            Land_spreading_10_m__c,
            Latest_Tank_moving_Date_MEP__c,
            Mechanic_type__c,
            MEP_Tank_Placing_Type_Details__c,
            Modification_of_the_Installation_Needed__c,
            Mouvement_a_la_meme_adresse_pour_Butagaz__c,
            Percentage_Jauge_Competitor_Tank__c,
            Precheck_Tank_Connection__c,
            Preparation_trench__c,
            Pre_Visit__c,
            Supplementary_Filling__c,
            System_Cut_off_point_at_liquid_Channel__c,
            Simultaneous_MEP__c,
            TeleJauge__c,
            Three_point_attachement__c,
            MEP_Comments__c,
            Tank_Placing_Options__c,
            
            
            Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
            /* Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c,
            
            // Erwan 20181217
            TICPE_Amount_HT__c,
            TICPE_Amount_TTC__c,
            Remise_Post_Offre_HT__c,
            Remise_Post_Offre_TTC__c,
            Normal_Product_Scale_From_SAP__c,
            
            // Erwan 20190430
            Payment_Spread_Amount_HT__c,
            Payment_Spread_Amount_TTC__c,
            
            // Erwan 20191203
            Bio_Product__c,
            Bio_Option_Amount_HT__c,
            Bio_Option_Amount_TTC__c,
            F_Rollup_BioPercentage__c,
            
            //MLC 20211209
            F_Payment_Type__c
            
            FROM quotelineitem where QuoteId = :current.Id and Sub_type__c = 'Citerne' and PricebookEntry.Product2.UseConsumerTarget__c=true ];
        
        return quotelineitemList;
        
        
        
        
        
        
    }
    
    public List<QuoteLineItem> getExistingCiterne2() {
        
        
        
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [
            SELECT 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
            Linenumber,
            pricebookentry.Name,
            CreatedDate,
            New_Price_HT__c,
            CreatedById,
            Tank_Placing_Type__c,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            New_Price_TTC__c,
            QuoteId,
            PricebookEntryId,
            Quantity,
            UnitPrice,
            F_Product_Code__c,
            Discount,
            Description,
            ServiceDate,
            SortOrder,
            ListPrice,
            Got_From_SAP__c,
            F_Quantity_Unit__c,
            Subtotal,
            TotalPrice, 
            Price_List_HT__c,
            Price_List_TTC__c,
            Group_Commercial_Rebate_HT__c,
            Group_Commercial_Rebate_TTC__c,
            Commercial_Rebate_HT__c,
            Commercial_Rebate_TTC__c,
            Group_Cyclical_Rebate_HT__c,
            Group_Cyclical_Rebate_TTC__c,
            
            Cyclical_Rebate_HT__c,
            Cyclical_Rebate_TTC__c,
            RCE_Rebate_HT__c,
            RCE_Rebate_TTC__c,
            Transport_Increase_HT__c,
            Transport_Increase_TTC__c,
            Tank_Capacity__c,
            T_TANK_CAPACITY_NUMBER__c,
            Linked_PTL__c,
            T_PTL_InFormation__c,
            Mis_Disposition__c,
            
            Remise_Grpt_one_shot_HT__c,
            Consignation_Grpt_one_shot_HT__c,
            Cyclical_Rebate_Months__c,
            
            Usage__c,
            Tax__c,
            Product_Description__c,
            From_Date__c,
            To_Date__c,
            Remise_Exceptional_for_Tank_CN_AB__c,
            Product_Family__c, 
            Quantity_Unit__c,
            Amount_Unit__c,
            Pricing_Unit__c,
            Start_Date_remise_Exc_Subscription__c,
            End_Date_remise_Exc_Subscription__c,
            Quote_PTL__r.Opportunity_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
            
            Quote_PTL__r.Opportunity_PTL__r.CreatedById,
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
            Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
            Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
            Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
            Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
            Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c,  Quote_PTL__r.Consumption_From_Excel__c, 
            Quote_PTL__r.Consumptioncurveprofile__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c,  Quote_PTL__r.RPTL_Purposes__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
            Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c,  Quote_PTL__r.Consumption_fixed_apr__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name,  Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
            Quote_PTL__r.Consumption_fixed_feb__c,  Quote_PTL__r.Consumption_fixed_jan__c,  Quote_PTL__r.Consumption_fixed_jul__c,  Quote_PTL__r.Consumption_fixed_jun__c,  Quote_PTL__r.Consumption_fixed_mar__c, 
            Quote_PTL__r.Consumption_fixed_may__c,  Quote_PTL__r.Consumption_fixed_nov__c,  Quote_PTL__r.Consumption_fixed_oct__c,  Quote_PTL__r.Consumption_fixed_sep__c,  
            Quote_PTL__r.Consumption_variable_apr__c,  Quote_PTL__r.Consumption_variable_aug__c,  Quote_PTL__r.Consumption_variable_dec__c,  Quote_PTL__r.Consumption_variable_feb__c, 
            Quote_PTL__r.Consumption_variable_jan__c,  Quote_PTL__r.Consumption_variable_jul__c,  Quote_PTL__r.Consumption_variable_jun__c,  Quote_PTL__r.Consumption_variable_mar__c, 
            Quote_PTL__r.Consumption_variable_may__c,  Quote_PTL__r.Consumption_variable_nov__c,  Quote_PTL__r.Consumption_variable_oct__c,  Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
            Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
            Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
            Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
            Customer_Owned_Tank_Name__c,
            Customer_Owned_Tank_ReApprBefore_Date__c,
            Customer_Owned_Tank_Serial_Number__c,
            Customer_Owned_Tank_Appr_Date__c,
            Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
            Cles_en_Main__c,
            Concrete__c,
            Connected_Tank__c,
            Concrete_Tile_Flooring__c,
            Detente_3_Bar__c,
            Drain__c,
            Earliest_Tank_moving_Date__c,
            Enhance_Jauge__c,
            Evacuation_of_Dirt_Rubble__c,
            Flooring_for_Burried_ballast_Tank__c,
            Insdustrial_Outflow__c,
            Intervention__c,
            Land_spreading_10_m__c,
            Latest_Tank_moving_Date_MEP__c,
            Mechanic_type__c,
            MEP_Tank_Placing_Type_Details__c,
            Modification_of_the_Installation_Needed__c,
            Mouvement_a_la_meme_adresse_pour_Butagaz__c,
            Percentage_Jauge_Competitor_Tank__c,
            Precheck_Tank_Connection__c,
            Preparation_trench__c,
            Pre_Visit__c,
            Supplementary_Filling__c,
            System_Cut_off_point_at_liquid_Channel__c,
            Simultaneous_MEP__c,
            TeleJauge__c,
            Three_point_attachement__c,
            MEP_Comments__c,
            Tank_Placing_Options__c,
            
            
            Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
            /*Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,*/
            Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
            Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c, Offered_Months__c,
            F_MonthlyPriceDisplay__c,
            
            // Erwan 20181217
            TICPE_Amount_HT__c,
            TICPE_Amount_TTC__c,
            Remise_Post_Offre_HT__c,
            Remise_Post_Offre_TTC__c,
            Normal_Product_Scale_From_SAP__c,
            
            // Erwan 20190430
            Payment_Spread_Amount_HT__c,
            Payment_Spread_Amount_TTC__c,
            
            // Erwan 20191203
            Bio_Product__c,
            Bio_Option_Amount_HT__c,
            Bio_Option_Amount_TTC__c,
            F_Rollup_BioPercentage__c,  
            
            // MLC 20210527
            Fixed_Price_HT__c,
            
            //MLC 20211209
            F_Payment_Type__c
            
            FROM quotelineitem where QuoteId = :current.Id and Sub_type__c = 'Citerne' and Got_from_SAP__c =true and PricebookEntry.Product2.UseConsumerTarget__c=true ];
        
        return quotelineitemList;
        
    } 

    public List<QuoteLineItem> getService2() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select 
                             Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             New_Price_HT__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,
                             Group_Cyclical_Rebate_TTC__c,
                             Quote_PTL__r.PTL_Name__c,
                             F_Quantity_Unit__c,
                             Mis_Disposition__c,
                             New_Price_TTC__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             PricebookEntry.Product2.CEM__c ,
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,Group_Cyclical_Rebate_lenght_in_months__c,
                             F_Product_Code__c,Quote_PTL__r.PTL_Label__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and (Product_Family__c ='Accessoire' OR Product_Family__c ='Service')and PricebookEntry.Product2.UseConsumerTarget__c=true   ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c];      
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getRedevence2() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select 
                             Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             New_Price_HT__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,         
                             Group_Cyclical_Rebate_TTC__c,
                             F_Quantity_Unit__c,
                             New_Price_TTC__c,
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,Group_Cyclical_Rebate_lenght_in_months__c,
                             F_Product_Code__c,Quote_PTL__r.PTL_Label__c ,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Redevance'  and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=true ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c];      
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getPricing2() {
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Start_Date_remise_Exc_Subscription__c,
                             End_Date_remise_Exc_Subscription__c,
                             Quantity_Unit__c,
                             Pricing_Unit__c,
                             PricebookEntry.Product2.VAPO__c,
                             Amount_Unit__c,
                             Ger_consumption__c,
                             Product_Family__c,
                             Commercial_Rebate_TTC__c,
                             Commercial_Rebate_HT__c,
                             Consignation_Grpt_one_shot_HT__c,
                             Cyclical_Rebate_Months__c,
                             New_Price_HT__c,
                             Cyclical_Rebate_HT__c,
                             Cyclical_Rebate_TTC__c,
                             From_Date__c,
                             Group_Commercial_Rebate_HT__c,
                             Group_RCE_Rebate_HT__c,
                             Group_RCE_Rebate_TTC__c,
                             Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,
                             F_Quantity_Unit__c,
                             Group_Cyclical_Rebate_TTC__c,
                             New_Price_TTC__c,
                             
                             Mis_Disposition__c,
                             Price_List_HT__c,
                             Price_List_TTC__c,
                             Product_Description__c,
                             RCE_Rebate_HT__c,
                             RCE_Rebate_TTC__c,
                             Remise_Exceptional_for_Tank_CN_AB__c,
                             Remise_Grpt_one_shot_HT__c,
                             T_TANK_CAPACITY_NUMBER__c,
                             Tank_Capacity__c,
                             Tax__c,
                             To_Date__c,
                             Transport_Increase_HT__c,
                             Transport_Increase_TTC__c,
                             Usage__c,
                             ListPrice,
                             Quantity,
                             pricebookentry.Name,
                             Group_Cyclical_Rebate_lenght_in_months__c, 
                             
                             Discount,
                             Description,
                             totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,    
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,
                             Quote_PTL__r.RPTL_Purposes__c,
                             Tank_Placing_Type__c,F_Product_Code__c,Quote_PTL__r.PTL_Label__c,Quote_PTL__r.PTL_Name__c, Offered_Months__c,
                             F_MonthlyPriceDisplay__c,
                             
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,  
            
                            // MLC 20210527
                            Fixed_Price_HT__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id   and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=true ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
        
        
    }
    
    public List<QuoteLineItem> getProduits2() {
        
        
        List<QuoteLineItem> quotelineitemList;
        
        quotelineitemList = [select Start_Date_remise_Exc_Subscription__c, End_Date_remise_Exc_Subscription__c, Quantity_Unit__c,Pricing_Unit__c,Amount_Unit__c,Product_Family__c, Commercial_Rebate_TTC__c,
                             Consignation_Grpt_one_shot_HT__c,Cyclical_Rebate_Months__c,Cyclical_Rebate_HT__c,Cyclical_Rebate_TTC__c,From_Date__c,Group_Commercial_Rebate_HT__c,Group_Commercial_Rebate_TTC__c,
                             Group_Cyclical_Rebate_HT__c,Group_Cyclical_Rebate_TTC__c,Mis_Disposition__c,Ger_consumption__c,
                             Price_List_HT__c,Price_List_TTC__c,Product_Description__c,RCE_Rebate_HT__c,RCE_Rebate_TTC__c,Commercial_Rebate_HT__c,Remise_Exceptional_for_Tank_CN_AB__c,Remise_Grpt_one_shot_HT__c,T_TANK_CAPACITY_NUMBER__c,Tank_Capacity__c,
                             Tax__c,To_Date__c,Transport_Increase_HT__c,Transport_Increase_TTC__c,Usage__c,ListPrice, Quantity, pricebookentry.Name, Quote_PTL__r.Opportunity_PTL__r.PTL__c, Discount, Description, totalPrice,
                             Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Scale__c,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_number__c,Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,F_Quantity_Unit__c,New_Price_TTC__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c,Quote_PTL__r.PTL_Name__c,
                             Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c,Tank_Placing_Type__c,New_Price_HT__c,
                             Quote_PTL__r.RPTL_Purposes__c,Group_Cyclical_Rebate_lenght_in_months__c,F_Product_Code__c,Quote_PTL__r.PTL_Label__c , Offered_Months__c,
                             // Erwan 20181217
                             TICPE_Amount_HT__c,
                             TICPE_Amount_TTC__c,
                             Remise_Post_Offre_HT__c,
                             Remise_Post_Offre_TTC__c,
                             Normal_Product_Scale_From_SAP__c,
                             // Erwan 20190430
                             Payment_Spread_Amount_HT__c,
                             Payment_Spread_Amount_TTC__c,
                             // Erwan 20191203
                             Bio_Product__c,
                             Bio_Option_Amount_HT__c,
                             Bio_Option_Amount_TTC__c,
                             F_Rollup_BioPercentage__c,  
            
                            // MLC 20210527
                            Fixed_Price_HT__c,
            
                            //MLC 20211209
                            F_Payment_Type__c
                             
                             from quotelineitem where QuoteId = :current.Id and Product_Family__c ='Produit' and Deconsignation__c=false  and PricebookEntry.Product2.UseConsumerTarget__c=true ORDER BY Quote_PTL__r.Opportunity_PTL__r.PTL__c ];
        return quotelineitemList;
        
        
    }
    
    public Decimal getTotalPriceProductsBaremeHT() {
        
        AggregateResult aggrTotalPrice;
        
        // Recover Prix Bareme HT from QLI of type Product
        List <AggregateResult> tempAggrTotalPrice  = [Select QuoteId GroupField, SUM(Price_List_HT__c) SumPriceHT
                                                      From QuoteLineItem Where QuoteId = :current.Id and Product_Family__c ='Produit' and Deconsignation__c=false and PricebookEntry.Product2.UseConsumerTarget__c=false Group By QuoteId];
        if (tempAggrTotalPrice.size() > 0) {
            aggrTotalPrice = tempAggrTotalPrice.get(0);
            return (Decimal)aggrTotalPrice.get('SumPriceHT');
        }
        else {
            return 0.00;
        }
        
        
    }
    
    public string getDateDebutOffre() {
        if(current.Date_debut_offre__c != null){
            return current.Date_debut_offre__c.format();
        } 
        else {
            return '';
        }
    }
    
    public string getDateFinOffre() {
        if(current.Date_fin_offre__c != null){
            return current.Date_fin_offre__c.format();
        } 
        else {
            return '';
        }
    }
    
    /* ELC 20180103 regrouping methods calculateNewPriceHT and calculateNewPriceTTC to consume one less query */
    /* ELC 20160105 used to display HT Price for groupement PROFT on VFP_ContractPDF_GECPRO */
    private void calculateNewPrice() {
        this.NewPriceHT = 0;
        this.priceTTCIdeoRemise='';
        this.NewPriceTTC = 0;
        this.TICPEAmountHT = 0;
        this.TICPEAmountTTC = 0;
        this.PaymentSpreadAmountHT = 0;
        this.PaymentSpreadAmountTTC = 0;
        this.RemisePostOffreHT = 0;
        this.RemisePostOffreTTC = 0;
        this.NormalProductScaleFromSAP = 0;
        this.BioOptionAmountHT = 0;
        this.BioOptionAmountTTC = 0;
        this.FixedPriceHT =0;
        List<QuoteLineItem> quoteLineItems = this.getProduits();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.Product_Family__c == 'Produit'){
                this.NewPriceHT = quoteLineItem.New_Price_HT__c != null ? quoteLineItem.New_Price_HT__c : 0;
                this.NewPriceTTC = quoteLineItem.New_Price_TTC__c != null ? quoteLineItem.New_Price_TTC__c : 0;
                this.TICPEAmountHT = quoteLineItem.TICPE_Amount_HT__c != null ? quoteLineItem.TICPE_Amount_HT__c : 0;
                this.TICPEAmountTTC = quoteLineItem.TICPE_Amount_TTC__c != null ? quoteLineItem.TICPE_Amount_TTC__c : 0;
                this.PaymentSpreadAmountHT = quoteLineItem.Payment_Spread_Amount_HT__c != null ? quoteLineItem.Payment_Spread_Amount_HT__c : 0;
                this.PaymentSpreadAmountTTC = quoteLineItem.Payment_Spread_Amount_TTC__c != null ? quoteLineItem.Payment_Spread_Amount_TTC__c : 0;
                this.priceTTCIdeoRemise = String.valueOf(quotelineitem.New_Price_TTC__c);
                this.groupCycRebLengthMonths = quoteLineItem.Group_Cyclical_Rebate_lenght_in_months__c;
                this.RemisePostOffreHT = quoteLineItem.Remise_Post_Offre_HT__c != null ? quoteLineItem.Remise_Post_Offre_HT__c : 0;
                this.RemisePostOffreTTC = quoteLineItem.Remise_Post_Offre_TTC__c != null ? quoteLineItem.Remise_Post_Offre_TTC__c : 0;
                this.NormalProductScaleFromSAP = quoteLineItem.Normal_Product_Scale_From_SAP__c != null ? quoteLineItem.Normal_Product_Scale_From_SAP__c : 0;
                this.BioOptionAmountHT = quoteLineItem.Bio_Option_Amount_HT__c != null ? quoteLineItem.Bio_Option_Amount_HT__c : 0;
                this.BioOptionAmountTTC = quoteLineItem.Bio_Option_Amount_TTC__c != null ? quoteLineItem.Bio_Option_Amount_TTC__c : 0;
                this.FixedPriceHT = quoteLineItem.Fixed_Price_HT__c  != null ? quoteLineItem.Fixed_Price_HT__c : 0;
                break;
            }
        }
        List<QuoteLineItem> listQuoteLineItemsRedevance = this.getProduitsRedevanceType();
        for (QuoteLineItem quoteLineItemRedevance : listQuoteLineItemsRedevance) 
        {
            if (quoteLineItemRedevance.F_Product_Code__c == 'SPPABO0017'){ //FLA 20210215 CASE 37
                this.NewPriceECOTTC = quoteLineItemRedevance.New_Price_TTC__c != null ? quoteLineItemRedevance.New_Price_TTC__c : 0;
            }
            //system.debug('quoteLineItem.F_Product_Code__c:'+quoteLineItem.F_Product_Code__c);
            
        }
    }
    
    
    /* ELC 20160105 used to display HT Price for groupement PROFT on VFP_ContractPDF_GECPRO */
    /*private void calculateNewPriceHT() {
this.NewPriceHT = 0;
List<QuoteLineItem> quoteLineItems = this.getProduits();
for (QuoteLineItem quoteLineItem : quoteLineItems) {
if (quoteLineItem.Product_Family__c=='Produit'){
this.NewPriceHT = quoteLineItem.New_Price_HT__c;
break;
}
}
}*/
    
    
    /* MLC 20171102 afficher le prix TTC du produit  */
    /*private void calculateNewPriceTTC() {
this.NewPriceTTC = 0;
List<QuoteLineItem> quoteLineItems = this.getProduits();
for (QuoteLineItem quoteLineItem : quoteLineItems) {
if (quoteLineItem.Product_Family__c=='Produit'){
this.NewPriceTTC = quoteLineItem.New_Price_TTC__c;
break;
}
}
}*/
    
    /* ELC 20160105 used to display HT Price for groupement PROFT on VFP_ContractPDF_GECPRO */
    private void calculateHasTankAlreadyOnSite(){
        this.hasTankAlreadyOnSite = false;
        List<QuoteLineItem> quoteLineItems = this.getQuoteLineItems();
        for(QuoteLineItem quoteLineItem : quoteLineItems){
            if(quoteLineItem.Sub_type__c=='Citerne' && quoteLineItem.Tank_placing_options__c=='CDP'){
                this.hasTankAlreadyOnSite = true;
                break;
            }
        }
    }
    
    /*public List<QuoteLineItem> getQuoteLineItemsFees() {

List<QuoteLineItem> quotelineitemfeesList;

quotelineitemfeesList = [
SELECT Product_Code__c
FROM quotelineitem where QuoteId = :current.Id ]; //and Sub_type__c = 'Frais'

return quotelineitemfeesList;

}*/
    
    /* ELC 20170306 used to display a sentence on a VFP */
    /*private void calculateRunningFeesSentence() {
this.DisplayRunningFeesSentence= false;
List<QuoteLineItem> quoteLineItems = this.getQuoteLineItemsFees();
for (QuoteLineItem quoteLineItem : quoteLineItems) {
if (quoteLineItem.Product_Code__c=='S000000006' || quoteLineItem.Product_Code__c=='S000000007' || quoteLineItem.Product_Code__c=='S000000042' || 
quoteLineItem.Product_Code__c=='S000000109' || quoteLineItem.Product_Code__c=='S000000118' || quoteLineItem.Product_Code__c=='S000000165' || 
quoteLineItem.Product_Code__c=='S000000169') { this.DisplayRunningFeesSentence = true; }
}
}*/
    
    private void calculateScaleGEB() {
        this.scaleGEB = '';
        /*List<Quote> quoteScaleGEB;

quoteScaleGEB = [SELECT Opportunity.Account.Scale_GEB__c, DO_Groupement__r.Scale_GEB__c
FROM Quote where Id = :current.Id ];

for (Quote qScaleGEB : quoteScaleGEB) {
if (qScaleGEB.DO_Groupement__c != null && qScaleGEB.DO_Groupement__r.Scale_GEB__c != null ) { 
this.scaleGEB = qScaleGEB.DO_Groupement__r.Scale_GEB__c;
}else{
this.scaleGEB = qScaleGEB.Opportunity.Account.Scale_GEB__c;
}
}*/
        
        if (current.DO_Groupement__c != null && current.DO_Groupement__r.Scale_GEB__c != null ) { 
            this.scaleGEB = current.DO_Groupement__r.Scale_GEB__c;
        }else{
            this.scaleGEB = current.Opportunity.Account.Scale_GEB__c;
        }
        if(current.VAT_code__c != null) {
            this.vatCode = current.VAT_code__c; 
        }
        
    }
    
    /* ELC 20170405 used to display GEB Scale document on a VFP */
    public List<Document> getScalesGEBDoc() {
        
        List<Document> scaleGEBList = new List<Document>();
        List<Document> sortedScaleGEBList = new List<Document>();
        
        List<String> tmpScaleGEBList = new List<String>();
        
        Integer i = 1;
        mSortDocs = new Map<Integer, String>();
        
        //if (mSortDocs != null) mSortDocs.clear();
        
        // Get GEB scales
        if(this.scaleGEB != null && this.vatCode != null){
            tmpScaleGEBList = getDocumentsIdsValue(this.scaleGEB + '_' + this.vatCode).split(';');
            for(String str : tmpScaleGEBList){
                mSortDocs.put(i, str);
                i++;
            }
        }
        
        // Retrieve documents from db
        if(mSortDocs != null && !mSortDocs.isEmpty()){
            scaleGEBList = [select Id from Document where Id=:mSortDocs.values()];
            // Manual sorting of the list to maintain docs order
            for(String sortDoc : mSortDocs.values()){
                for (Document doc : scaleGEBList){
                    if(sortDoc == doc.Id) sortedScaleGEBList.add(doc); 
                }
            }
        }
        
        return sortedScaleGEBList;
        
    }
    
    /** Getting Custom Settings methods **/
    public static String getDocumentsIdsValue(String name){
        try{
            String res = DocumentsIds__c.getInstance(name).DocumentId__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
                // BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
                //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'No value specified for Custom Setting DocumentsIds__c : (' + name +').'});
                return '';
            }            
        }catch(System.NullPointerException e){
            // BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
            //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the DocumentsIds__c named (' + name +'). [ '+ e.getMessage() + ' ]'});
            return '';
        }
    }
    
    /**Debut  DPA - 30-03-2021 - Methodes: GEC PRO calcul des montant cumulé de RCE par PTL  */
    public map<String,Decimal> getMapQPTLNameTotalRCEHTAmount(){
        map<String,Decimal> myMap = new  map<String,Decimal>();
        if( this.listQuoteLI==null || this.listQuoteLI.isEmpty() ){
            this.listQuoteLI = getPricing();
        }
        this.cumulRCEAmount=0;
        for ( QuoteLineItem qli : this.listQuoteLI ){
            // Erwan - 20210921 : Added restriction Product_Family__c == 'Produit'
            if ( qli.Product_Family__c == 'Produit' && qli.RCE_Rebate_HT__c>0 ){
                system.debug(' nom du ptl : '+qli.Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c);
                system.debug(' nom du ptl 1 : '+qli.Quote_PTL__r.PTL_Label__c);
                system.debug(' nom du ptl 2 : '+qli.Quote_PTL__r.PTL_Name__c);
                if( !myMap.containsKey(qli.Quote_PTL__r.PTL_Label__c) ){
                    myMap.put(qli.Quote_PTL__r.PTL_Label__c,0);
                }
                Decimal amount= myMap.get(qli.Quote_PTL__r.PTL_Label__c)+qli.RCE_Rebate_HT__c;
                myMap.put(qli.Quote_PTL__r.PTL_Label__c,amount);
                cumulRCEAmount=cumulRCEAmount+qli.RCE_Rebate_HT__c;
                
            //   this.cumulRCEAmount=this.cumulRCEAmount+qli.RCE_Rebate_HT__c;
            }
        }
        
        this.mapQPTLNameTotalRCEHTAmount=myMap;
        return myMap;
    }
 
    public Decimal getCumulRCEAmount(){
        if( this.cumulRCEAmount<=0){
          this.cumulRCEAmount=0;
        for ( Decimal value :mapQPTLNameTotalRCEHTAmount.values() )
        {
            this.cumulRCEAmount=this.cumulRCEAmount+value;
        }
        }
        
        return this.cumulRCEAmount;
    }
     /**Fin  DPA - 30-03-2021 - Methodes : GEC PRO calcul des montant cumulé de RCE par PTL  */
    
   // MLC 20210630 INC2952433
    public Decimal getOfferedMonths() {
        this.OfferedMonths= 0;
        
        List<QuoteLineItem> quoteLineItems = this.getPricing();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quotelineItem.Cyclical_Rebate_Months__c   > 0){ this.OfferedMonths = quotelineItem.Cyclical_Rebate_Months__c  ; }
              system.debug(' OfferedMonths : '+quotelineItem.Cyclical_Rebate_Months__c  );
        }
         return this.OfferedMonths;
    }      
    
         public Decimal getRebateRconj() {
         this.RebateRconj= 0;
         decimal  PriceRebate; 
         PriceRebate=0;
        List<QuoteLineItem> quoteLineItems = this.getPricing();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quotelineItem.Cyclical_Rebate_TTC__c   > 0){ 
                PriceRebate = quotelineItem.Price_List_TTC__c-quotelineItem.New_Price_TTC__c;
                this.RebateRconj = PriceRebate  ; 
                system.debug(' RebateRconj 1: '+quotelineItem.New_Price_TTC__c  );
                system.debug(' RebateRconj 2: '+quotelineItem.Price_List_TTC__c  );
                system.debug(' RebateRconj 3: '+PriceRebate  );
            }
              
        }
         return this.RebateRconj;
    }
    
    public Decimal getPriceListTTC() {
         this.PriceListTTC= 0;
         decimal  PriceListTTC; 
         PriceListTTC=0;
            List<QuoteLineItem> quoteLineItems = this.getPricing();
           // List<QuoteLineItem> quoteLineItems = this.getProduits();
            for (QuoteLineItem quoteLineItem : quoteLineItems) {
               // if (quotelineItem.Price_List_TTC__c   > 0){ 
                 if (quoteLineItem.Product_Family__c == 'Produit'){
                    PriceListTTC = quotelineItem.Price_List_TTC__c;  
                    this.PriceListTTC = PriceListTTC;
                     system.debug(' PriceListTTC: '+quotelineItem.Price_List_TTC__c  );
                   }
                   
              
        }
         return this.PriceListTTC;
    }
    
    
    // MLC 20211209 INC3198388
    public Boolean getCommercialRebateMessage() {
        this.CommercialRebateMessage= false;
        
        List<QuoteLineItem> quoteLineItems = this.getPricing();
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.F_Payment_Type__c != 'Consignation' && quoteLineItem.Commercial_Rebate_TTC__c > 0) {
                  this.CommercialRebateMessage = true ; 
                  system.debug(' F_Payment_Type__c : '+quotelineItem.F_Payment_Type__c  );
                  system.debug(' CommercialRebateMessage : '+this.CommercialRebateMessage  );
                
             }
        }
         return this.CommercialRebateMessage;
    }     

    
}