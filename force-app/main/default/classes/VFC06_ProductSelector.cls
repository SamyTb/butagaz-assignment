public without sharing class VFC06_ProductSelector {
    // **********************
    // ATTRIBUTES 
    // **********************

    /** The Wrapper For SOAP Pricing Call**/
    public AP_WrapperForSOAPCallPricing wrapperForSOAPCall;
    /** The object which store data for controller, especially QuoteLineItems etc. **/
    public AP_WrapperForSOAPCallPricing.AP_WrapperDataForController dataForController;
    
    /* The quote we're working with */
    public  Quote      oQuote {get;set;} 
    private Pricebook2 pricebook;
    private Id pricebookId;
    
    
    private AP_BusinessControls businessControls;
    
    /* Lists of Products */
    public list<AvailableProduct> lAvailableProducts {get;set;} // Page 1: Products that can be added
    public list<SelectedProduct>  lSelectedProducts  {get;set;} // Page 1: Products that have been selected
    public List<QuoteLineItem>    lPendingLineItems  {get;set;} // Page 2: Quote Line Items to be saved
    public List<QuoteLineItemView> lPendingLineItemsView {get; set;} // Page 2: Quote Line Items View to be saved, represent the QLI and it's view
    
    /* Auto Product Map */
    Map<String, PricebookEntry> autoProductsMap {get;set;}
    Map<String, PricebookEntry> autoProductsStandardizedFormMap {get;set;}
    Map<String, PricebookEntry> autoProductsStorageModificationMap {get;set;}
   
    public List<Quote_PTL__c> lQuotePTLs {get;set;} // The Quote PTLs for the Quote.
    protected Map<Id, Quote_PTL__c> mQuotePTLs {get;set;}

    /* Page State */
    public List<AP_VFMessage> listAPVFMessage {get; set;} // List of Message to add on makeStatusMessages
    
    /* Search and display the objects */
    private final integer PRODUCTS_PER_PAGE = 20; //sets the page size or number of rows
    
    public List<SelectOption> connectionTypeOptions {get; set;}
    public List<SelectOption> gerConsumptionOptions {get; set;}
    public List<SelectOption> familySelectorOptions {get; set;}
    public List<SelectOption> subTypeSelectorOptions {get; set;}
    public List<SelectOption> tankTypeSelectorOptions {get; set;}
    public List<SelectOption> tankProtectionSelectorOptions {get; set;}
    public List<SelectOption> tankPlacingSelectorOptions {get; set;}
    public List<SelectOption> misADispositionSelectorOptions {get; set;}
    public List<SelectOption> misADispositionGEBSelectorOptions {get; set;}
    public List<SelectOption> tankPumpingRequiredSelectorOptions {get; set;}
    public List<SelectOption> bioProductOptions {get; set;}
    

    
    public SearchClause searchClause {get; set;}
    
    private AP_Pagination_01.Paginator paginator;
    private AP_Query_01.QuerySet       currentQuery;

    public  integer productListSize; //used to show user the total size of the list
    private Integer pageIndex;

    public Boolean showForm {get; set;}
    public Boolean onlyShowMode {get; set;}
    public Boolean showContractNumber {get; set;}
    
    public Integer cptIsButabox = 0;
    
    /* "Actions commerciales" */
    public List<Action_Commerciale__c> lActionsCommerciales {get;set;}
    public Action_Commerciale__c selectedAC {get;set;}
    public String AcMIdChosen {get; set;}
    public String AcMId2Chosen {get; set;}
    public boolean hasAvailableAcMs {get; set;}
    public String sOfferedMonths {get; set;}
    
    private string sTank_Property = '';
    private string sTank_Type = '';
    public String tankPlacing = '';
    private Quote_PTL__c ptlDefault {get; set;}
    public List<SelectedProduct> lProductToDelete = new List<SelectedProduct>();
    public List<QuoteLineItem> lQLIToRemove {get; set;}
    
    public String sOfferedRedevance {get; set;}
    private string sNumberOfMonthsRemainingOnContract = '';
    private Set<String> sArticlesOfferedRedevance = new Set<String>();
    protected Map<Integer, Boolean> mTrueFalse {get;set;}
    
  //  public decimal TVA = 19.6;
  // public decimal TVA = 20.0;
    
    private integer cptTank;
    private string selectedBioOption = '';

    // **********************
    // CONSTRUCTOR
    // **********************
    public VFC06_ProductSelector(ApexPages.standardcontroller stdController) {
        System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Constructing.');           
        try{            
            // Initialize constants
            this.lSelectedProducts = new list<SelectedProduct>();
            this.lAvailableProducts = new List<AvailableProduct>();
            this.lActionsCommerciales = new List<Action_Commerciale__c>();
            this.listAPVFMessage = new List<AP_VFMessage>();
            this.lQLIToRemove = new List<QuoteLineItem>();
            this.oQuote = [
                SELECT Id, Name, T_LAT_Approved__c, T_LAT_Rejected__c, T_LAT_ApprovalRequested__c, CreatedBy.Id, RecordTypeId, Opportunity.Project_Type__c, Opportunity.Project_Sub_Type__c, Opportunity.Project_market_type__c, Opportunity.RecordTypeId, 
                       OpportunityId, Pricebook2Id, Opportunity.Contrat__c, Opportunity.Account.Customer_Group__c, Opportunity.Account.Customer_group_1__c,
                       Opportunity.Account.Channel__c, Opportunity.Account.Sub_Channel__c, Opportunity.Account.Group_Code__c,
                       Opportunity.Account.Customer_group_2__c, Opportunity.Account.Customer_group_4__c, Opportunity.Account.Customer_group_5__c, Opportunity.DO_AccountNumber__c,
                       Opportunity.Account.Activity_Domain__r.ExternalID__c, Action_Commerciale__r.Name, Contract_Duration__c, Opportunity.Contrat__r.PTL__r.Name, Scale__c, Opportunity.Account.Parent.AccountNumber, Ger_Consumption__c,
                       Bottle_Leasing_Type__c, Opportunity.Groupe__c, Type_of_charge__c, Payment_spread_SAP__c, DO_Groupement__r.AccountNumber, Estimated_Capacity__c, Sum_PTL_Consumption__c,
                       Product_scale__c, VAT_code__c, Tax_model__c, Shipping_Condition__c, Opportunity.Account_Owner__r.AccountNumber, Opportunity.Predecessor__r.AccountNumber, Opportunity.Client_Type__c, Client_Reenlistment__c, Client_Type__c, IsButabox__c, 
                       Action_Commerciale__c, Opportunity.Opportunity_Reason__c, Opportunity.Energy_Source__c, Opportunity.DPE__c, Opportunity.Account.Prescriber_Client_GEC_DOM__c, Opportunity.Account.Collaborator__c, Action_Commerciale__r.Offered_Months__c,
                       Opportunity.T_Pack__c, Opportunity.Contrat__r.StartDate, Opportunity.Contrat__r.ContractTerm, T_Anciennete_Contrat__c, T_LAT_GEC_ALL_EtaitPackIDEOSOLOECOCFT__c, Opportunity.Prescriber_Account__r.Prescriber_Activity__c,
                       Application_fee_exemption__c, Opportunity.Account_Owner_Market_subtype__c, Action_Commerciale__r.Fixed_Price__c, Action_Commerciale__r.Locked_Price_1_Year__c, Action_Commerciale__r.Locked_Price_2_Years__c, Action_Commerciale__r.Locked_Price_3_Years__c,
                       Opportunity.Project_market_subtype__c,QuantiteRestante__c,Opportunity.Compte_Optimo__c
                FROM Quote
                WHERE Id=:stdController.getRecord().Id
            ];
            
            this.autoProductsMap = new Map<String, PricebookEntry>();
            this.autoProductsStandardizedFormMap = new Map<String, PricebookEntry>();
            this.autoProductsStorageModificationMap = new Map<String, PricebookEntry>();
            
            this.searchClause = new SearchClause(this);
            this.connectionTypeOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Connection_Type__c'); 
            this.gerConsumptionOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Ger_consumption__c'); 
            this.familySelectorOptions = this.getPickListValuesAsSelectorOptions(Product2.getSObjectType(), 'Family');
            this.subTypeSelectorOptions = this.getPickListValuesAsSelectorOptions(Product2.getSObjectType(), 'Sub_Type__c');
            this.tankTypeSelectorOptions = this.getPickListValuesAsSelectorOptions(Product2.getSObjectType(), 'Tank_Type__c');
            this.tankProtectionSelectorOptions = this.getPickListValuesAsSelectorOptions(Product2.getSObjectType(), 'Tank_protection__c');
            this.misADispositionSelectorOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Mis_Disposition__c');
            this.tankPlacingSelectorOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Tank_Placing_Options__c');
            this.misADispositionGEBSelectorOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Mise_a_Disposition_GEB__c');
            this.tankPumpingRequiredSelectorOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Tank_Pumping_Required__c');
            this.bioProductOptions = this.getPickListValuesAsSelectorOptions(QuoteLineItem.getSObjectType(), 'Bio_Product__c');
            
            
            if (this.oQuote.pricebook2Id != null){
                this.pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Id=:this.oQuote.pricebook2Id];
                this.pricebookId = this.pricebook.Id;
            } else {
                this.pricebook = null;
                this.pricebookId = null;
            }
            
                        
            if ((this.AcMIdChosen == null || this.AcMIdChosen == '') && this.oQuote.Action_Commerciale__c != null) {
                this.AcMIdChosen = oQuote.Action_Commerciale__r.id;
                this.AcMId2Chosen = oQuote.Action_Commerciale__r.id;
                System.debug(logginglevel.WARN,'### Constructor: AcMIdChosen (1&2) set to ' + oQuote.Action_Commerciale__r.id);
            } else {
                this.AcMIdChosen = '';
            }

            System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Quote synced and constants loaded');

            // Retrieve Quote PTLs that the Quote Line Items may be added to

            this.mQuotePTLs = new Map<Id, Quote_PTL__c>([
                SELECT 
                    Id,
                    Name,
                    PTL_Name__c, 
                    PTL_Label__c,
                    Opportunity_PTL__r.Name,
//                    Opportunity_PTL__r.PTL_Department__c, 
                    Opportunity_PTL__r.DepartmentFormula__c, 
                    RPTL_Purposes__c, 
                    Estimated_Capacity__c, 
                    Estimated_Consumption__c
                FROM Quote_PTL__c 
                WHERE Quote__c = :this.oQuote.Id
            ]);
            this.lQuotePTLs = this.mQuotePTLs.values(); // !TODO! Replace with a getter method. (Fix in Visualforce page).
            
            //Check the approval process of Latitute, if it's done it will be impossible to change a locket Quote
            if(this.oQuote.T_LAT_ApprovalRequested__c && AP_PricingUtilities.isQuoteOwner(this.oQuote.CreatedBy.Id)) {
                throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + System.Label.quote_locked});
            }
            
            //Check Business rules for required fields needed to do callout Pricing
            this.businessControls = new AP_BusinessControls(this.oQuote, this.lQuotePTLs);
            this.businessControls.checkMandatoryOfInputCommonParameters('1'); 
            this.businessControls.checkMandatoryFieldsOfInputDeliveryPointParameters();
            this.businessControls.checkListErrors();//can throw AP_CRMException 
            
            System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] PTLs Queried: [' + this.lQuotePTLs + ']');
            
            // Initialize the wrapper
            this.wrapperForSOAPCall = new AP_WrapperForSOAPCallPricing(this.oQuote, this.pricebookId);
            
            List<QuoteLineItem> currentQuoteLineItems = this.selectQuoteLineItemsQuery();
            
            System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Current QLIs Queried: [' + currentQuoteLineItems + ']');

            System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Converting QLIs to SelectedProducts');

            for(QuoteLineItem oQLI: currentQuoteLineItems) {
                System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Converting [' + oQLI + ']');
                this.lSelectedProducts.add(new SelectedProduct(oQLI, this));
            }

            this.paginator = new AP_Pagination_01.Paginator(0, this.PRODUCTS_PER_PAGE);
            this.pageIndex = 0;

            System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Adding status messages.');

            if(oQuote != null && (!oQuote.T_LAT_ApprovalRequested__c && !oQuote.T_LAT_Approved__c)) {
                this.makeStatusMessages();
            }
            
            this.showForm = true;
            
            this.onlyShowMode = false;
            if(ApexPages.currentPage().getParameters().containsKey('onlyShowMode')) {
                this.onlyShowMode = true;
                this.showContractNumber = false;
            }
            
            this.selectedAC = null;
            this.hasAvailableAcMs = false;
            this.sOfferedMonths = '';
            this.sOfferedRedevance = '';
            this.ptlDefault = null;
            
        } catch(AP_CRMException e){
            this.showForm = false;
            this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
            AP_PricingUtilities.showApexErrors(e);
        }
        
        System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.Constructor] Done Constructing.');
    }
        
    public List<SelectOption> getPickListValuesAsSelectorOptions(Schema.sObjectType ObjectType, String pickListName){
        List<SelectOption> l = new List<selectOption>(); //new list for holding all of the picklist options

        l.add(new SelectOption('', ' --'+System.Label.none_label_male+'-- '));
        //Schema.sObjectType ObjectType = Product2.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe = ObjectType.getDescribe(); //describe the sobject

        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(pickListName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        Map<String, Pack_Bio_Options__c> packToBioOptionsMap = Pack_Bio_Options__c.getAll();  // Erwan 20191220 : Fetch which Bio Options are available for each Pack
        for (Schema.PicklistEntry a : pickListValues) { //for all values in the picklist list
            
            // Erwan 20191220 : Filter Bio Options picklist against Pack_Bio_Options__c custom settings
            if ( !pickListName.equals('Bio_Product__c') || 
                ( pickListName.equals('Bio_Product__c') && packToBioOptionsMap.containsKey(this.oQuote.Opportunity.T_Pack__c) && packToBioOptionsMap.get(this.oQuote.Opportunity.T_Pack__c).value__c.contains(a.getValue()) ) ) {
                
                String value = a.getValue();
                String label = (a.getLabel() != null) ? a.getLabel() : value; // Put the value on the label, if no label set
                l.add(new selectOption(value, label)); //add the value and label to our final list
                
                //Update the default value (if the PicklistEntry is the default value)
                if(a.isDefaultValue()){
                    if(picklistName.equals('Family') && this.searchClause.familyName == null) {
                        this.searchClause.familyName = value;
                    }else if(pickListName.equals('Sub_Type__c') && this.searchClause.subTypeName == null){
                        this.searchClause.subTypeName = value;
                    }else if(pickListName.equals('Tank_Placing_Options__c') && this.searchClause.tankPlacing == null){
                        this.searchClause.tankPlacing = value;
                    }else if(pickListName.equals('Tank_protection__c') && this.searchClause.tankProtection == null){
                        this.searchClause.tankProtection = value;
                    }
                }
            }
            
        }
        return l;
    }
    
    
    public PageReference initializePage(){
        if(oQuote != null && !onlyShowMode && (oQuote.T_LAT_ApprovalRequested__c || oQuote.T_LAT_Approved__c)){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, 'Une approbation latitude a été demandée et vous ne pouvez plus modifier le devis');
            ApexPages.addMessage(message);
            this.showForm = false;
            return null;
        }
        return choosingPriceBook();
    }
    
    //The redirection to SelectPriceBook Page
    public PageReference choosingPriceBook(){
        if(this.pricebookId == null){
            PageReference selectPriceBook = Page.VFP06_SelectPriceBook;
            selectPriceBook.getParameters().put('id', this.oQuote.Id);
            selectPriceBook.getParameters().put('parentPageURL', ApexPages.currentPage().getUrl());
            return selectPriceBook;
        }
        return null;
    }
    
    /** Query to get current QuoteLineItems of the quote **/
    public List<QuoteLineItem> selectQuoteLineItemsQuery(){
        List<QuoteLineItem> listQuoteLineItems = [
            SELECT  
                // Common fields
                Id,
                UnitPrice, 
                Quote_PTL__c, 
                QuoteId, 
                Quantity,
                Quantity_Unit__c,
                N_Lot__c,
                // Pricebook fields (Page 1)
                PricebookEntryId,
                PricebookEntry.Product2Id,
                PricebookEntry.Product2.IsActive,
                PriceBookEntry.Product2.ProductCode,
                PricebookEntry.Product2.Name,
                PricebookEntry.Product2.Family,
                PricebookEntry.Product2.Capacity__c,
                PricebookEntry.Product2.Sub_Type__c,
                PricebookEntry.Product2.Tank_Type__c,
                PricebookEntry.Product2.Payment_type__c,
                PricebookEntry.Product2.UseGerConsumption__c,
                PricebookEntry.Product2.UseConnectionType__c,
                PricebookEntry.Product2.UseConsumerTarget__c,
                PricebookEntry.Product2.noSAP__c,
                PricebookEntry.Product2.MonthlyPriceDisplay__c,
                PricebookEntry.Product2.Standardized_Form__c,
                PricebookEntry.UnitPrice,
                // Customizable fields (Page 2)
                Remise_Grpt_one_shot_HT__c, 
                Consignation_Grpt_one_shot_HT__c, 

                Group_Commercial_Rebate_HT__c, 
                Group_Commercial_Rebate_TTC__c, 

                Group_Cyclical_Rebate_HT__c, 
                Group_Cyclical_Rebate_TTC__c, 
                //Group_Cyclical_Rebate_lenght_in_Days__c,
                Group_Cyclical_Rebate_lenght_in_months__c,
                Group_RCE_Rebate_HT__c,
                Group_RCE_Rebate_TTC__c,
                
                Commercial_Rebate_TTC__c, 
                Commercial_Rebate_HT__c,

                Cyclical_Rebate_TTC__c, 
                Cyclical_Rebate_HT__c, 
                Cyclical_Rebate_Months__c, 

                RCE_Rebate_TTC__c, 
                RCE_Rebate_HT__c, 

                Transport_Increase_TTC__c,
                Transport_Increase_HT__c,

                VAT_Percentage__c,

                Price_List_HT__c,
                Price_List_TTC__c,
                Pricing_Unit__c,
                Amount_Unit__c,
                
                Ger_consumption__c,
                Connection_Type__c,
                
                //Tank_Sold__c,
                Tank_Placing_Options__c,
                Mis_Disposition__c,
                Mise_a_Disposition_GEB__c,
                IsTank__c,
                Got_From_SAP__c,
                Deconsignation__c,
                Remplacement__c,
                
                // Identifiant_Contrat__c, -- Champ pour l'automatisation -- MLC 28/07/2014
                // T_Is_Identifiant_Contrat__c, -- Champ pour l'automatisation -- MLC 28/07/20014
                
                F_Product_Code__c,
                PricebookEntry.Product2.Auto_Add__c,
                Offered_Months__c,
                RCE_Rebate_ManuallySet__c,
                PricebookEntry.Product2.Invisible_New_Pack__c,
                TAEG_Amount_TTC__c,
                TAEG_Percentage__c,
                Offered_Redevance_Nb_Months__c,
                
                // ELC 20141118 Customer Owned Tank
                Customer_Owned_Tank_Appr_Date__c,
                Brand__c,
                Customer_Owned_Tank_Capacity__c,
                Customer_Owned_Tank_Name__c,
                Customer_Owned_Tank_ReApprBefore_Date__c,
                Customer_Owned_Tank_Serial_Number__c,
                
                Tank_Pumping_Required__c,
                Only_for_Standardized_Form__c,
                Bio_Product__c
                
            FROM QuoteLineItem 
            WHERE QuoteId=:this.oQuote.Id
        ];
        return listQuoteLineItems;
    }

    /* METHODS FOR CONTROLLING DISPLAY ELEMENTS */
    
    /** The Quantity (inputText) won't be disabled for GEB_PRO and GER_Usager, otherwise it will be set to 1 for others **/
    public boolean getUsesQuantity(){
        if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager')){
            return true;
        }
        return false;
    }
    
    public boolean getUsesPTLs() {
        if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS')){
            return false;
        }
        if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager')){
            return false;
        }
        return true;
    }
    
    //For GER PRO, we need to be able to choose the consumption of each products (especially the SRES000001)
    public boolean getUsesGerConsumption(){
        if(this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire')){
            return true;
        }
        return false;
    }
    
    
    public boolean getUsesConnectionType(){
        if(this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire')){
            return true;
        }
        return false;
    }
    
    //Domain having the ability to do sap call out (calculate new pricing mode 1)
    /**public boolean getUsesCalculatePricingButton(){
        if(this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE')){
            return false;
        }
        return true;
    }**/
    
    public Boolean getPTLsOK(){
        // Returns whether the PTL conditions are OK
        // == PTLs not used - OR - PTLSize > 0.
        return (!this.getUsesPTLs()) || this.getPTLSize() > 0;
    }

    public List<selectOption> getPtls() {
        List<selectOption> options = new List<selectOption>();
        String PTLName, labelName;
        for (Quote_PTL__c oQuotePTL : this.lQuotePTLs) {            
            
            //ELC 21/04/2015  QPTL truncated in ProductSelector Step1 picklist
            //PTLName = (oQuotePTL.PTL_Name__c != null) ? oQuotePTL.PTL_Name__c : String.valueOf(oQuotePTL.Name).substring(0,10);
            PTLName = (oQuotePTL.PTL_Name__c != null) ? oQuotePTL.PTL_Name__c : oQuotePTL.Name;
            labelName = (oQuotePTL.PTL_Label__c !=null) ? oQuotePTL.PTL_Label__c : '-';
            
            options.add(new selectOption(oQuotePTL.Id, PTLName + ', ' + labelName)); 
        }
        return options; 
    }

    public Integer getPTLSize(){
        return this.lQuotePTLs.size();
    }
    
    public String getQuoteAC(){
        // Returns the id of the "Action Commerciale" if already defined at the quote level or null
        return this.oQuote.Action_Commerciale__c;
    }
    
    
     // MLC 22062016 - premmet de recuperer le HT de la remise conjoncturelle
    public Decimal calculateHT(Decimal priceTTC, Decimal TVAqli){
        decimal coefconv = 0;
        decimal priceHT = 0;
        coefconv = 100+TVAqli; 
      
        
            if(priceTTC != 0 || priceTTC != null){
                
                priceHT = (100 / coefconv) * priceTTC;
                
               // priceHT = priceHT.round(roundingMode.DOWN);
                priceHT = priceHT.setscale(2);
                return priceHT;
            }
           return priceTTC;
        }  
        

    /* ACTION METHODS */

    public PageReference saveForm(){
        //List<QuoteLineItem> QLIFromSAP = new List<QuoteLineItem>();
        //List<QuoteLineItem> QLINotFromSAP = new List<QuoteLineItem>();
        
        // Don't allow to save if there's a rebate on a fixed price (on GPL product)
        if( this.AcMIdChosen != null && this.AcMIdChosen != '' && (selectedAC.Fixed_Price__c || selectedAC.Locked_Price_1_Year__c || selectedAC.Locked_Price_2_Years__c || selectedAC.Locked_Price_3_Years__c) ){
            for(QuoteLineItem qli : lPendingLineItems){
                /* Erwan : 20210924 : RCE Rebate now allowed on Fixed/Locked price
                if(oQUote.Opportunity.Project_market_type__c == 'DOM' && qli.PricebookEntry.Product2.Family == 'Produit' && qli.RCE_Rebate_TTC__c != null && qli.RCE_Rebate_TTC__c > 0 ) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.No_Rebate_On_Fixed_Price_Message));
                    return null;
                }
                else */
                if(oQUote.Opportunity.Project_market_type__c == 'PRO' && qli.PricebookEntry.Product2.Family == 'Produit' && qli.RCE_Rebate_HT__c != null && qli.RCE_Rebate_HT__c > 0 ) {
                   // Id quoteGrocVracRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Gros_Vrac').getRecordTypeId();
                    if(!FeatureManagement.checkPermission('EditRCE')){
                 //   if(true){
                        qli.RCE_Rebate_HT__c = 0;
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.No_Rebate_On_Fixed_Price_Message));
                        return null;
                    }
                }  
            }
        }
        
        // Don't allow to save if Bio option selected on PRO Quote and : not V1GR && not groupement AP000000 && not fixed price action co
        // 20201026 : Bio options now allowed on PRO without fixed price as well
        /*if( oQUote.Opportunity.Project_market_type__c == 'PRO' ){
            for(QuoteLineItem qli : lPendingLineItems){
                if( qli.PricebookEntry.Product2.Family == 'Produit' && qli.Bio_Product__c != null ) {
                    if( oQuote.Product_Scale__c != 'V1GR' || oQuote.DO_Groupement__c == null || (oQuote.DO_Groupement__c != null && oQuote.DO_Groupement__r.AccountNumber != 'AP000000') || selectedAC == null || (selectedAC != null && ( !selectedAC.Fixed_Price__c && !selectedAC.Locked_Price_1_Year__c && !selectedAC.Locked_Price_2_Years__c && !selectedAC.Locked_Price_3_Years__c)) ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.PRO_Bio_Option_On_Fixed_Price_Only));
                        return null;
                    }
                }
            }
        }*/

        // Don't allow to save if Bio option selected on DOM Quote and : fixed price action co
        // 20210920 : Bio options now allowed on PRO without fixed price as well
        /*if( oQUote.Opportunity.Project_market_type__c == 'DOM' ){
            for(QuoteLineItem qli : lPendingLineItems){
                if( qli.PricebookEntry.Product2.Family == 'Produit' && qli.Bio_Product__c != null ) {
                    if( selectedAC != null && ( selectedAC.Fixed_Price__c || selectedAC.Locked_Price_1_Year__c || selectedAC.Locked_Price_2_Years__c || selectedAC.Locked_Price_3_Years__c) ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.DOM_Bio_Option_Not_On_Fixed_Price));
                        return null;
                    }
                }
            }
        }*/
        
        try{
            
            //Updating Quote_PTL of QLIs (Estimated_Capacity__c field)
            Map<String, Decimal> mapPTLsToCapacity = AP_PricingUtilities.mapQuotePTLToCapacity(new List<List<QuoteLineItem>>{lPendingLineItems});
            for(QuoteLineItem qli : lPendingLineItems){
                if(qli.Quote_PTL__r != null){
                    qli.Quote_PTL__r.Estimated_capacity__c = AP_PricingUtilities.getQuotePTLCapacity(mapPTLsToCapacity, qli.Quote_PTL__r.Name);
                    System.debug(logginglevel.WARN,'### '+ qli.Quote_PTL__r.Name + ' CAPA -> ' + qli.Quote_PTL__r.Estimated_capacity__c );
                } 
                // ORO: 140910 - Update Qli.RCE_Rebate_ManuallySet__c
                if (qli.PricebookEntry.Product2.Family == 'Produit' && this.AcMIdChosen != null && this.AcMIdChosen != ''
                    && qli.RCE_Rebate_TTC__c != selectedAC.RCE__c)
                        qli.RCE_Rebate_ManuallySet__c = true;
                        
                        
                // MLC 22062016 - Updating QLI -  Cyclical_Rebate_HT__c
               if (qli.PricebookEntry.Product2.Family == 'Produit' && qli.Got_From_SAP__c == true && oQUote.Opportunity.Project_market_type__c=='DOM'  )
               {
                 
                 System.debug(logginglevel.WARN,'### '+ qli.Cyclical_Rebate_HT__c + '' + qli.Cyclical_Rebate_TTC__c + '' + qli.VAT_Percentage__c +' HTavantMAJ -> ' );
                // qli.Cyclical_Rebate_HT__c = calculateHT(qli.Cyclical_Rebate_TTC__c , this.TVA);
                if ( qli.Cyclical_Rebate_TTC__c != null)
                 {
                 qli.Cyclical_Rebate_HT__c = calculateHT(qli.Cyclical_Rebate_TTC__c , qli.VAT_Percentage__c);
                 }
                 System.debug(logginglevel.WARN,'### '+ qli.Cyclical_Rebate_HT__c + ' HTapresMAJ -> ' );
                
               }
                
            }
            update lQuotePTLs;
            
            
            //Updating QLIs
            upsert lPendingLineItems;
                
            // Remove outdated lineItems
            if (lQLIToRemove.size() > 0) delete lQLIToRemove;
            
            //On QLI we have the flag Got_From_SAP__c that specify QLI got from the second mode, and we have VRs that will be skipped for those products (it's important on the second mode)
            //But in this first mode, we have to apply VRs for all QLI having Got_From_SAP = true or false
            //Trick : unflag those products, upsert all products (to be able to trigger VRs for all), flag products and upsert
            /**
            for(QuoteLineItem qli : lPendingLineItems){
                if(qli.Got_From_SAP__c){
                    //unflag the product temporary
                    qli.Got_From_SAP__c = false;
                    QLIFromSAP.add(qli);
                }else{
                    QLINotFromSAP.add(qli);
                }
            }
            //Merge the two list to have ONE upsert
            List<QuoteLineItem> mergedList = new List<QuoteLineItem>();
            mergedList.addAll(QLIFromSAP);
            mergedList.addAll(QLINotFromSAP);
            upsert mergedList;
            
            //QLIFromSAP;
            //upsert QLINotFromSAP;
            
            for(QuoteLineItem qli : QLIFromSAP){
                qli.Got_From_SAP__c = true;
            }   
            update mergedList;
            **/
            
            //FRECA0 02/04/2014  Update Flag if IsButabox
            //For IsButabox to be True, the Quote needs to have at least 1 QLI
            //with Product Code AC01000012 and one with SPPABO0007
            /*cptIsButabox = 0;
            for(QuoteLineItem qli : lPendingLineItems){
                // Rule change : 08/04/2016
                //if((qli.F_Product_Code__c == 'AC01000012') || (qli.F_Product_Code__c == 'SPPABO0007')){
                if(qli.F_Product_Code__c == 'AC01000012'){
                    cptIsButabox ++ ;
                    System.debug(logginglevel.WARN,'### Product Code = '+ qli.F_Product_Code__c + ' , cptIsButabox = ' + cptIsButabox );
                }
            }*/
            cptIsButabox = 0;
            for (SelectedProduct oSelected : this.lSelectedProducts){
                if (oSelected.oEntry.Product2.ProductCode == 'AC01000012'){
                    System.debug(logginglevel.WARN,'### 1 Found AC01000012');
                    cptIsButabox ++ ;
                }
            }
            
            //if we found both products in the loop above
            // Rule change : 08/04/2016
            //if (cptIsButabox == 2){
            if (cptIsButabox == 1){
                oQuote.IsButabox__c = True;
            }
            //Fin FRECA0 02/04/2014  Update Flag if IsButabox
            
            
            System.debug(logginglevel.WARN,'### AcMIdChosen while saving:' + this.AcMIdChosen);
            if (this.AcMIdChosen != null && this.AcMIdChosen != '') {
                oQuote.Action_Commerciale__c  = this.AcMIdChosen;
                oQuote.Locked_Price__c = selectedAC.Locked_Price__c;
            } else if (this.AcMIdChosen == '') {
                oQuote.Action_Commerciale__c  = null;
                oQuote.Locked_Price__c = false;
            }
            
            update oQuote;
            
            //System.debug('List QLI FROM SAP' + QLIFromSAP);
            //System.debug('List QLI NOT FROM SAP' + QLINotFromSAP);
            return new pageReference('/'+oquote.Id);
        }
        catch(DmlException ex){
            /**for(QuoteLineItem qli : QLIFromSAP){
                qli.Got_From_SAP__c = true;
            } **/
            ApexPages.addMessages(ex);
            return null;
        }
    }

    public String getClientType(){
        String MarketType  = this.oquote.Opportunity.Project_market_type__c;
        String ProjectType = this.oquote.Opportunity.Project_Type__c;

        String str='';
        if(this.oQuote.Opportunity.Project_Type__c=='FIDE')
            str+='FIDE';
        if(oQUote.Opportunity.Project_market_type__c=='DOM')
            str+='DOM';
        else if(oQUote.Opportunity.Project_market_type__c=='PRO')
            str+='PRO';

        System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.getClientType] Opportunity Market Type: [' + MarketType +']');
        System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.getClientType] Opportunity Project Type: [' + ProjectType +']');
        System.debug(logginglevel.WARN,'### [VFC06_ProductSelector.getClientType] Output: [' + str + ']');

        return str;
    }   
    
    private void makeStatusMessages(){
        // Display Pricebook information
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.crm_message + ' : '+ System.Label.the_pricebook + ' ' + this.pricebook.name + ' '+  System.Label.will_be_used_for_the_quote));
        
        // Do we have products?
        if (this.lSelectedProducts.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.crm_message + ' : '+  System.Label.no_products_choosed));
        }

        // Are all the products OK?
        Boolean allProductsOK = true;
        for (SelectedProduct oSelected : this.lSelectedProducts){
            if (!oSelected.getIsValid()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : '+  System.Label.products_not_valid));
                allProductsOK = false;
                break;
            }
        }
        if (allProductsOK){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.crm_message + ' : '+System.Label.products_valid));
        }
        
        // Add listAPVFMessage 
        for(AP_VFMessage m : this.listAPVFMessage){
                ApexPages.addMessage(new ApexPages.Message(m.getSeverityFromType(), m.summary, m.details));
        }
    }
    
    public PageReference clearFilters(){
        if(searchClause != null){
            searchClause.setProductName(null);
            searchClause.setProductCode(null);
            searchClause.familyName = null;
            searchClause.subTypeName = null;
            searchClause.capacity = null;
        }    
        return this.refresh();
    }
    
    public PageReference search(){
        List<String> queryFields = new List<String>{
            'Id',                   'Product2.Id',
            'Product2.Name',        'Product2.Family',
            'Product2.Capacity__c', 'Product2.Sub_Type__c', 'Product2.Payment_type__c',
            'Product2.ProductCode', 'Product2.UseGerConsumption__c', 'Product2.UseConnectionType__c',
            'Product2.UseConsumerTarget__c', 'Product2.is_crea__c', 'Product2.is_not_pack__c',
            'Product2.Tank_Type__c', 'Product2.Tank_protection__c',
            'Product2.IsActive', 'Product2.noSAP__c', 'Product2.MonthlyPriceDisplay__c',
            'UnitPrice', 'Product2.Auto_Add__c','Product2.Invisible_New_Pack__c','Product2.Standardized_Form__c'
        };
        List<AP_Query_01.QuerySetClause> queryFilters = new List<AP_Query_01.QuerySetClause>();

        if (!(searchClause.getProductCode() == '' || searchClause.getProductCode() == null)){
            queryFilters.add(new AP_Query_01.QuerySetLikeClause('Product2.ProductCode', searchClause.getProductCode()));
        }
        
        if (!(searchClause.getProductName() == '' || searchClause.getProductName() == null)){
            queryFilters.add(new AP_Query_01.QuerySetLikeClause('Product2.Name', searchClause.getProductName()));
        }

        if (searchClause.familyName != null){
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Family', searchClause.familyName));
        }
        
        if(searchClause.subTypeName != null){
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Sub_Type__c', searchClause.subTypeName));
        }
        
        //We have to take into account the capacity only if the familyName is different to Produit and Accessoire
        if(searchClause.familyName == null || (!searchClause.familyName.toLowerCase().equals('produit') && !searchClause.familyName.toLowerCase().equals('accessoire'))){ 
            if(!(searchClause.capacity == 0 || searchClause.capacity == null)){
                queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Capacity__c', searchClause.capacity));
            }
        }
        
        //Business ask to remove those filters!
        /**if(searchClause.tankType != null){
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Tank_Type__c', searchClause.tankType));
        }
        
        if(searchClause.tankProtection != null){
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Tank_protection__c', searchClause.tankProtection));
        }**/
        
        if (this.pricebook != null){ 
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Pricebook2Id', this.pricebook.Id));
        }
        
        //We have to take into account the New BTZ product filter only if the familyName is Equipement
        if(searchClause.familyName != null && searchClause.familyName.toLowerCase().equals('equipement')){ 
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.is_crea__c', searchClause.isCrea));
        }
        
        //We have to take into account the No Pack filter only if the familyName is Redevance
        if(searchClause.familyName != null && searchClause.familyName.toLowerCase().equals('redevance')){ 
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.is_not_pack__c', searchClause.isNotPack));
        }
        
        queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.IsActive', true));
        
        
                
        // ORO 140910 - removing auto-products from the list
        // ORO 141006 - Or condition - List of "hybrid" products, available through the search and flagged as "Auto add".
        //              List located in Custom setting AutoAdd_Allowed 
        List<String> sTmpExtId = AP_PricingUtilities.getCustomSettingValue('AutoAdd_Allowed').split(';');
        List<AP_Query_01.QuerySetClause> lTmpClause = new List<AP_Query_01.QuerySetClause>();
        lTmpClause.add(new AP_Query_01.QuerySetInClause('Product2.external_ID__c',sTmpExtId));
        lTmpClause.add(new AP_Query_01.QuerySetEqualsClause('Product2.Auto_Add__c', false));
        queryFilters.add(new AP_Query_01.QuerySetOrClause(lTmpClause));
        
        // MLC - 17092014
         if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            ) {
            queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Product2.Invisible_New_Pack__c', false));
        }

        
        this.currentQuery = new AP_Query_01.QuerySet('PricebookEntry', queryFields, queryFilters);
        this.paginator    = new AP_Pagination_01.Paginator(this.currentQuery.getCount(), this.PRODUCTS_PER_PAGE);

        // Reinitialize and return to first page
        this.productListSize = this.currentQuery.getCount();
        return this.navigateToPage(0);
    }

    public PageReference refresh(){
        /* Refresh the product list that is displayed */
        this.makeStatusMessages();
        //if (this.AcMIdChosen != null) ApexPages.currentPage().getParameters().put('AcMid', this.AcMIdChosen);
        return null;
    }

    private PageReference refreshProductList(){
        this.lAvailableProducts = new List<AvailableProduct>();
        PricebookEntry loopEntry; // Loop variable
        for (Sobject oEntry : this.currentQuery.getRecords(this.PRODUCTS_PER_PAGE, this.paginator.getPageStartIndex(this.pageIndex))){
            loopEntry = (PricebookEntry) oEntry;
            this.lAvailableProducts.add(new AvailableProduct(loopEntry, this, null, false));   // Modif ELC 20140611
        }
        return this.refresh();
    }

    /* Classes Used to represent fieldsets */
    
    public class SearchClause{
        private VFC06_ProductSelector parent;
        private String productCode;
        private String productName;
        public String familyName {get; set;} //Picklist
        public String subTypeName {get; set;}  //Related Picklist
        private String tankPlacing {get; set;}  // Picklist
        
        public Decimal capacity {get; set;}
        public String tankProtection {get; set;} //Picklist
        public Boolean isCrea {get; set;} // Bring only new products of BTZ in case of CREA/SUCC/EXT
        public Boolean isNotPack {get; set;} // Bring only pack products in case of Pack defined on the Quote
        
        // Others custom fields for clause...
        
        public SearchClause(VFC06_ProductSelector parent){
            this.parent = parent;
            //if(!this.parent.oQuote.Opportunity.Project_Type__c.equals('FIDE')){
            this.isCrea = true;
            //}
            this.isNotPack = AP_PricingUtilities.getQuoteIsNotPack(parent.oQuote);
        }
 
        public void setProductName(String productName){
            if(productName != null){
                this.productName = String.escapeSingleQuotes(productName);
            }else{
                this.productName = null;
            }            
        }

        public String getProductName(){
            return this.productName;
        }
        
        public void setProductCode(String productCode){
            if(productCode != null){
                this.productCode = String.escapeSingleQuotes(productCode);
            }else{
                this.productCode = null;
            }
        }
        
        public String getProductCode(){
            return this.productCode;
        }
    }
    
    public class AvailableProduct {
        public PricebookEntry oEntry {get;set;}
        VFC06_ProductSelector parentObject {get;set;}
        private Decimal dOfferedMonths {get;set;}
        //private Decimal dOfferedRedevanceNbMonths {get;set;}
        private Boolean onlyforStandardizedForm {get;set;}
        
        public AvailableProduct(PricebookEntry oEntry, VFC06_ProductSelector parentObject, Decimal dOfferedMonths, Boolean onlyforStandardizedForm){ 
            this.oEntry = oEntry;
            this.parentObject = parentObject;
            this.dOfferedMonths = dOfferedMonths;
            this.onlyforStandardizedForm = onlyforStandardizedForm;
        }
        /*
        public AvailableProduct(PricebookEntry oEntry, VFC06_ProductSelector parentObject, Decimal dOfferedRedevanceNbMonths){ 
            this.oEntry = oEntry;
            this.parentObject = parentObject;
            this.dOfferedRedevanceNbMonths = dOfferedRedevanceNbMonths;
        }
        
        public AvailableProduct(PricebookEntry oEntry, VFC06_ProductSelector parentObject, Decimal dOfferedMonths, Decimal dOfferedRedevanceNbMonths){ 
            this.oEntry = oEntry;
            this.parentObject = parentObject;
            this.dOfferedMonths = dOfferedMonths;
            this.dOfferedRedevanceNbMonths = dOfferedRedevanceNbMonths;
        }
        */
        public PageReference add(){
            parentObject.lSelectedProducts.add(new SelectedProduct(this));
            return parentObject.refresh();
        }
        
    } 

    public class SelectedProduct {
        public  PricebookEntry          oEntry {get;set;}
        private VFC06_ProductSelector   parentObject {get;set;}
        public  Id                      quotePTLID {get;set;}
        public  Long                    selectedUID {get; set;} // This is an unique number identifying this Selected object.
        private QuoteLineItem           lineItem; // The underlying Quote Line Item for this selected product.
        private Decimal                 dOfferedMonths {get;set;}
        //private Decimal                   dOfferedRedevanceNbMonths {get;set;}
        private Boolean                 onlyforStandardizedForm {get;set;}
        
        private String                  sQuantity; // Only to interface with the page
        private Decimal                 quantity;
        
        private Boolean                 syncedWithSAP;
        public  List<String>            lErrors {get; set;}

        public String gerConsumption;
        public String misADisposition; // If the Tank is sold by BTZ, we have to skip this product in sap callout
        public String tankPlacing;
        public String connectionType {get; set;}
        public String tankPumpingRequired;  // Property to be set by the users on tank lines to determine if a pumping article is needed
        public String bioProduct;  // Property to be set by the users on propane product lines to determine a Bio option
        
        
        public void initializeUID(){
            // Initialize the Selected Product's UID to a random number.
            // The likelihood of getting twice the same number in a single session is sufficiently close to 0.
            this.selectedUID = Crypto.getRandomLong();
        }

        public SelectedProduct(PricebookEntry oEntry, VFC06_ProductSelector parentObject){
            // instantiate a selectedProduct without setting the price
            this.initializeUID();
            this.lErrors = new List<String>();
            this.oEntry = oEntry;
            this.parentObject = parentObject;
            //In case of SRES00001 since we got price for 100 KWH we will put 100 in the Quantity
            if(this.oEntry.Product2.ProductCode.equals('SRES000001')){
                this.quantity = 100.00;
            }else{
                this.quantity = 1.00; // By default the quantity is set to 1
            }
            if(oEntry.Product2.Family.toLowerCase().equals('equipement') && 
                oEntry.Product2.Sub_Type__c.toLowerCase().equals('citerne')){
                this.misADisposition = 'Butagaz Owned Tank';
            }else{
                this.misADisposition = null;
            }
            // Load defaults.
            if (parentObject.lQuotePTLs != null) {
                if (parentObject.lQuotePTLs.size() == 1) {
                    this.quotePTLID = parentObject.lQuotePTLs[0].Id;
                }
            }
        }

        public SelectedProduct(AvailableProduct available){
            this(available.oEntry, available.parentObject);
            if(available.oEntry.Product2.noSAP__c) {
                this.syncedWithSAP = true; 
            } else {
                this.syncedWithSAP = false;// Created from List.
            }
            if (available.dOfferedMonths != null) {
                this.dOfferedMonths = available.dOfferedMonths;
            }
            /*if (available.dOfferedRedevanceNbMonths != null) {
                this.dOfferedRedevanceNbMonths = available.dOfferedRedevanceNbMonths;
            }*/
            if (available.onlyforStandardizedForm != null) {
                this.onlyforStandardizedForm = available.onlyforStandardizedForm;
            }
        }

        public SelectedProduct(QuoteLineItem oQLI, VFC06_ProductSelector parentObject){
            this(oQLI.PricebookEntry, parentObject);
            this.lineItem   = oQLI;
            this.quotePTLID = oQLI.Quote_PTL__c;
            this.quantity   = oQLI.Quantity;
            this.misADisposition = oQLI.Mis_Disposition__c;
            this.tankPlacing = oQLI.Tank_Placing_Options__c;
            this.tankPumpingRequired = oQLI.Tank_Pumping_Required__c;
            this.bioProduct = oQLI.Bio_Product__c;
            
            this.syncedWithSAP = true; // Created from SAP // !TODO! Make sure this is the case...
            if(this.oEntry.Product2.UseGerConsumption__c){
                this.gerConsumption = oQLI.Ger_consumption__c;
            }    
            if(this.oEntry.Product2.UseConnectionType__c){
                this.connectionType = oQLI.Connection_Type__c;
            }
            this.dOfferedMonths = oQLI.Offered_Months__c;
            //this.dOfferedRedevanceNbMonths = oQLI.Offered_Redevance_Nb_Months__c;
            this.onlyforStandardizedForm = oQLI.Only_for_Standardized_Form__c;
        }
        
        public void setGerConsumption(String value){
            if (this.gerConsumption != value){
                this.syncedWithSAP = false;
            }
            this.gerConsumption = value;
        }
        
        public String getGerConsumption(){
            return this.gerConsumption;
        }
        
        public void setMisADisposition(String value){
            if (this.misADisposition != value){
                this.syncedWithSAP = false;
            }
            this.misADisposition = value;
        }
        
        public String getMisADisposition(){
            return this.misADisposition;
        }
        
        public void setTankPlacing(String value){
            this.tankPlacing = value;
        }
        
        public String getTankPlacing(){
            return this.tankPlacing;
        }
        
        public void setSQuantity (String value){ 
            this.sQuantity = value;

            value = value.replace(',', '.'); // Normalize.
            Decimal oldQuantity = this.quantity;

            try {
                this.quantity = Decimal.valueOf(value); 
            } catch (System.TypeException e){
                this.quantity = null;
            } finally {
                if (this.quantity != oldQuantity){
                    this.syncedWithSAP = false;
                }
            }
        }
        
        public String getSQuantity (){ 
            if (this.quantity != null){
                return String.valueOf(this.quantity); 
            } else {
                return this.sQuantity;
            }
        }
        
        public void setTankPumpingRequired(String value){
            if (this.tankPumpingRequired != value){
                this.syncedWithSAP = false;
            }
            this.tankPumpingRequired = value;
        }
        
        public String getTankPumpingRequired(){
            return this.tankPumpingRequired;
        }
        
        public void setBioProduct(String value){
            if (this.bioProduct != value){
                this.syncedWithSAP = false;
            }
            this.bioProduct = value;
        }
        
        public String getBioProduct(){
            return this.bioProduct;
        }
        
        
        //Valid Product = SyncSAPOk + Valid quantity
        public Boolean getIsValid(){
            this.lErrors = new List<String>();

            if (this.quantity == null){
                this.lErrors.add(System.Label.the_quantity +' '+this.sQuantity + System.Label.isInvalid);
            }
            
            // Modified FRECA0 19/11/2015 : if(this.lineItem.IsTank__c && this.tankPlacing == null && (this.parentObject.oQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager')) && (this.parentObject.oQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GEC energigaz')) && (this.parentObject.oQuote.RecordTypeId != AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire')) ){
            if(this.lineItem.IsTank__c && this.tankPlacing == null && !this.parentObject.onlyShowMode){
                this.lErrors.add('Le type de placement citerne est requis!');
                return false;
            }
            
            // FRECA0 30/12/2014 : In case of ECOCMI scale on Quote, tanks must be of type "Enterrée"
            if(this.lineItem.IsTank__c && this.parentObject.oQuote.Product_Scale__c == 'ECOCMI' && this.oEntry.Product2.Tank_Type__c != 'E' ){
                this.lErrors.add('Vous devez sélectionner des citernes enterrées avec le barème ECOCMI!');
                return false;
            }
            
            if (this.syncedWithSAP == null || !this.syncedWithSAP){
                this.lErrors.add(System.Label.product_not_synced);
            }
            //In case of Product of Type Tank, we have to choose the mis a disposition
            if(this.lineItem.IsTank__c && this.misADisposition == null){
                this.lErrors.add('La mise à dispositon est requise!');
                return false;
            }
            
            //In case of GER PRO, the ger consumption of the product using it is mandatory
            if(this.parentObject.getUsesGerConsumption()){
                if(this.oEntry.Product2.UseGerConsumption__c && this.gerConsumption == null){
                    this.lErrors.add(System.Label.product_use_gerConsumption);
                    return false;
                }
            }
            
            //In case of GER PRO, the connection type of the product using it is mandatory
            if(this.parentObject.getUsesConnectionType()){
                if(this.oEntry.Product2.UseConnectionType__c && this.connectionType == null){
                    this.lErrors.add('The connection type is required!');
                    return false;
                }
            }
            
            return this.lErrors.isEmpty();
        }

        //Product Ready for SAP = Valid quantity
        public Boolean getReadyForSap(){
            //In case of GER PRO, fill the ger consumption of the product using it
            if(this.parentObject.getUsesGerConsumption()){
                if(this.oEntry.Product2.UseGerConsumption__c && this.gerConsumption == null)
                    return false;
            }
            
            //In case of Product of Type Tank, we have to choose the mis a disposition
            if(this.lineItem.IsTank__c && this.misADisposition == null){
                return false;
            }
            
            return (this.quantity != null);
        }
        
        public PageReference remove(){
            List<SelectedProduct> lProductTemp = new List<SelectedProduct>();
            
            for(SelectedProduct existingSelectedProduct :parentObject.lSelectedProducts){
                if(!(this.equals(existingSelectedProduct))){     
                    lProductTemp.add(existingSelectedProduct);
                }else{
                    // The SelectedProduct that we want to remove have already a QuoteLineItem behind and thus linked to the Quote (we cannot remove it from this controller)
                    if(this.lineItem != null && this.lineItem.Id != null && !this.lineItem.PricebookEntry.Product2.Auto_Add__c && !this.lineItem.PricebookEntry.Product2.Standardized_Form__c){
                        lProductTemp.add(this);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : '+System.Label.cannot_remove_QLI)); 
                    } else if (this.lineItem != null && this.lineItem.Id != null){
                        parentObject.lQLIToRemove.add(this.lineItem);
                    }
                }
                
            }
            parentObject.lSelectedProducts = lProductTemp;
            return parentObject.refresh();
        }
        
        /*public void removeAutoAddedProducts(){
            //List<SelectedProduct> lProductTemp = new List<SelectedProduct>();
            
            for(SelectedProduct existingSelectedProduct :parentObject.lSelectedProducts){
                System.debug('#ELC# this.lineItem.Id : ' + this.lineItem.Id);
                if(this.lineItem != null && this.lineItem.Id != null){
                    // if QLI already in db
                    // and Auto_Add__c == true
                    System.debug('#ELC# existingSelectedProduct.Auto_Add__c : ' + existingSelectedProduct.Auto_Add__c);
                    if(existingSelectedProduct.Auto_Add__c){
                        System.debug('#ELC# TTT');
                        //lProductToDelete.add(this);
                    }
                }else{
                    // if QLI not already in db
                    System.debug('#ELC# TTT2');
                }
                
            }
            //parentObject.lSelectedProducts = lProductTemp;
            //return parentObject.refresh();
        }*/
        
        
        public QuoteLineItem getLineItem(){
            // Used to retrieve the underlying Line Item for this SelectedProduct.
            // If no LineItem is currently available, one will be created on the fly
            // WARNING: This object CAN NOT be inserrted as-is, this will be handled in the next Step.
            if (this.lineItem == null){
                // Those fields are NOT controlled IN the selector, but only at creation.
                this.lineItem = new QuoteLineItem(
                    QuoteId          = this.parentObject.oQuote.Id,
                    PricebookEntryId = this.oEntry.Id,
                    PricebookEntry   = this.oEntry
                );
            }
            // Those fields are controlled IN the Selector, update them as they might have been updated!
            this.lineItem.Quantity     = this.quantity;
            this.lineItem.Amount_Unit__c = 'EUR';
            this.lineItem.Pricing_Unit__c = 1;
            this.lineItem.Quote_PTL__c = this.quotePTLID;
            this.lineItem.Quote_PTL__r = this.parentObject.mQuotePTLs.get(this.quotePTLID);
            this.lineItem.IsTank__c = AP_PricingUtilities.isTank(this.lineItem);
            this.lineItem.Mis_Disposition__c = this.misADisposition;
            System.debug(logginglevel.WARN,'### SET ::: ' + this.tankPlacing);
            this.lineItem.Tank_Placing_Options__c = this.tankPlacing;
            this.lineItem.Tank_Pumping_Required__c = this.tankPumpingRequired;
            this.lineItem.Bio_Product__c = this.bioProduct;
            
            this.lineItem.Offered_Months__c = this.dOfferedMonths;
            //this.lineItem.Offered_Redevance_Nb_Months__c = this.dOfferedRedevanceNbMonths;
            this.lineItem.Only_for_Standardized_Form__c = this.onlyforStandardizedForm;
            //In GER Owner, update the gerConsumption of QuoteLineItem ... 
            if(this.oEntry.Product2.UseGerConsumption__c){
                this.lineItem.Ger_consumption__c = this.gerConsumption;
            }
            if(this.oEntry.Product2.UseConnectionType__c){
                this.lineItem.Connection_Type__c = this.connectionType;
            }
            //In case of products skipping SAP CAll, we have to get the price set on PricebookEntry 
            if(this.oEntry.Product2.noSAP__c){
                // For noSAP product, TVA equals to 0%
                // 20161017 Erwan : Now products with sub type "Accessoires GER" need to have a VAT added
                this.lineItem.UnitPrice = this.oEntry.UnitPrice;
                this.lineItem.Price_List_HT__c = this.oEntry.UnitPrice * this.quantity;
                if(this.oEntry.Product2.Sub_Type__c == 'Accessoires GER' && this.parentObject.oQuote.VAT_code__c == '1'){   // Métropole
                    this.lineItem.Price_List_TTC__c = this.lineItem.Price_List_HT__c * (1 + Decimal.valueOf(AP_PricingUtilities.getCustomSettingValue('GER_Accessories_Metropole_VAT')) / 100);
                }else if (this.oEntry.Product2.Sub_Type__c == 'Accessoires GER' && this.parentObject.oQuote.VAT_code__c == '2'){   // Corsica
                    this.lineItem.Price_List_TTC__c = this.lineItem.Price_List_HT__c * (1 + Decimal.valueOf(AP_PricingUtilities.getCustomSettingValue('GER_Accessories_Corsica_VAT')) / 100);
                }else{
                    this.lineItem.Price_List_TTC__c = this.oEntry.UnitPrice * this.quantity;
                }
            }
            if((this.lineItem.Mis_Disposition__c == 'Tank sold by BTZ')){
                // For tank sold by BTZ, we will apply a custom TVA
                this.lineItem.UnitPrice = this.oEntry.UnitPrice;
                this.lineItem.Price_List_HT__c = (this.oEntry.UnitPrice * this.quantity);
                this.lineItem.Price_List_TTC__c =  this.lineItem.Price_List_HT__c * (1+ Decimal.valueOf(AP_PricingUtilities.getCustomSettingValue('Tank_TVA_Sold_By_BTZ'))/100);
            }
            
            return lineItem;
        }

        public Boolean equals(Object obj){
            if (obj == null){ return false; }
            try {
                SelectedProduct other = (SelectedProduct) obj;
                return this.selectedUID == other.selectedUID;
            } catch (System.TypeException e) {
                return false;
            }
        }
    }   

    /* Navigation methods */

    private PageReference navigateToPage(Integer newPage){ this.pageIndex = newPage; return this.refreshProductList(); }

    public PageReference firstPage()    {return this.navigateToPage(0);}
    public PageReference previousPage() {return this.navigateToPage(this.pageIndex - 1);}
    public PageReference nextPage()     {return this.navigateToPage(this.pageIndex + 1);}
    public PageReference lastPage()     {return this.navigateToPage(this.paginator.getNumPages() - 1);}

    public Boolean getHasPrevious() { return this.paginator.pageExists(this.pageIndex - 1); }
    public Boolean getHasNext(){ return this.paginator.pageExists(this.pageIndex + 1); }

    public Integer getDisplayPageIndex(){ return this.pageIndex + 1; }
    public Integer getDisplayPageNumber(){ return this.paginator.getNumPages(); }

    public Boolean getHasSelectedProducts() { return !this.lSelectedProducts.isEmpty(); }
    public Boolean getHasAvailableProducts(){ return !this.lAvailableProducts.isEmpty();}
    public Boolean getHasPendingLineItems() { return !this.lPendingLineItems.isEmpty(); }
    
    //Check that all products can pass to the next step (Valid products = syncSAPOk + valid Quantity)
    public Boolean getAllSelectedProductsValid(){
        for (SelectedProduct oSelected : this.lSelectedProducts){
            if (!oSelected.getIsValid()){ return false; }            
        }
        return true;
    }
    
    //Check that all products can be sent to SAP (validQuantity)
    public Boolean getAllSelectedProductsReadyForSap(){
        for (SelectedProduct oSelected : this.lSelectedProducts){
            if (!oSelected.getReadyForSap()){ return false; }            
        }
        return true;
    }
    
    public Boolean getAbleToSave(){ //!TODO! Rename!
        if (this.dataForController != null && this.dataForController.errorGotFromSAP){ return false; } // We had a SAP error.
        return this.getAllSelectedProductsValid(); // What about the articles?
    }
    
    // FRECA0 : To check tanks specifications are not mixed up on the same quote
    public Boolean getTankInfoOK(){
        string sTankTypeToCheck = '';
        string sMisDispositionToCheck = '';
        integer iCptErrorTank = 0;
        
        for (SelectedProduct oSelected : this.lSelectedProducts){
            if (oSelected.lineitem.IsTank__c && oSelected.lineitem.Tank_Placing_Options__c != 'RDS' && oSelected.lineitem.Tank_Placing_Options__c != 'IDE'){
                if (sTankTypeToCheck != '' && oSelected.oEntry.Product2.Tank_Type__c != sTankTypeToCheck){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.tank_type_not_ok));
                    iCptErrorTank++;
                }
                if (sMisDispositionToCheck != '' && oSelected.lineitem.Mis_Disposition__c != sMisDispositionToCheck){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : ' + System.Label.tank_mis_disposition_not_ok));
                    iCptErrorTank++;
                }
                sTankTypeToCheck = oSelected.oEntry.Product2.Tank_Type__c;
                sMisDispositionToCheck = oSelected.lineitem.Mis_Disposition__c;
            }
        }
        
        if(iCptErrorTank > 0){
            return false;
        }else{
            return true;
        }

    }
    
    // FRECA0 20150114 : To check the consistency between the product scale and the tanks specifications
    public Boolean getScaleAndTanksOK(){
        string sTankTypeToCheck = '';
        string sMisDispositionToCheck = '';
        boolean bScaleAndTankOK = true;
        
        
        for (SelectedProduct oSelected : this.lSelectedProducts){
            if (oSelected.lineitem.IsTank__c && oSelected.lineitem.Tank_Placing_Options__c != 'RDS' && oSelected.lineitem.Tank_Placing_Options__c != 'IDE'){
                sTankTypeToCheck = oSelected.oEntry.Product2.Tank_Type__c ;
                sMisDispositionToCheck = oSelected.lineitem.Mis_Disposition__c ;
                break;
            }
        }
        
        if (this.oQuote.Product_Scale__c == 'ECOCMI'){
            if (this.oQuote.Contract_Duration__c != '5'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : La durée de contrat doit être de 5 ans pour bénéficier du barême ECOCMI.'));
                bScaleAndTankOK = false;
            }
            if (this.oQuote.Opportunity.Prescriber_Account__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : Un prescripteur doit être renseigné sur l\'opportunité pour bénéficier du barême ECOCMI.'));
                bScaleAndTankOK = false;
            }
            if (sTankTypeToCheck != 'E'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : Vous ne pouvez sélectionner que des citernes enterrées pour bénéficier du barême ECOCMI.'));
                bScaleAndTankOK = false;
            }
            if (sMisDispositionToCheck != 'Butagaz Owned Tank'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : Vous ne pouvez sélectionner que des citernes appartenant à Butagaz pour bénéficier du barême ECOCMI.'));
                bScaleAndTankOK = false;
            }
        /*}else if (this.oQuote.Product_Scale__c == 'ECOCFT'){
            if ( this.oQuote.Contract_Duration__c == '5' && this.oQuote.Opportunity.Prescriber_Account__c != null && sTankTypeToCheck == 'E' && sMisDispositionToCheck == 'Butagaz Owned Tank' ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : D\'après les informations que vous avez renseignées, vous devez sélectionner le barême ECOCMI sur votre devis.'));
                bScaleAndTankOK = false;
            }*/
        }else{
            
        }
        
        return bScaleAndTankOK;

    }
    
    // FRECA0 20171211 : To prevent more than 1 tank on each PTL in ECOCFT
    public Boolean getMultipleTanksOnSamePTLonECOCFTOK(){
        boolean bMultipleTanksOnSamePTLOK = true;
        
        Set<String> ptlNumberSet = new Set<String>();
        
        if (this.oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            for (SelectedProduct oSelected : this.lSelectedProducts){
                if (oSelected.lineitem.IsTank__c && oSelected.lineitem.Tank_Placing_Options__c != 'RDS' && oSelected.lineitem.Tank_Placing_Options__c != 'IDE'){
                    // Put PTLs in a Set (PTL number). If the Set already contains the value, we got multiple tanks on a same PTL
                    if(!ptlNumberSet.contains(oSelected.lineitem.Quote_PTL__c)){ 
                        ptlNumberSet.add(oSelected.lineitem.Quote_PTL__c);
                    }else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.crm_message + ' : En écoConfortique, multiciternes et citernes jumelées interdit.'));
                        bMultipleTanksOnSamePTLOK = false;
                        break;
                    }
                }
            }
        }else{
            
        }
        
        return bMultipleTanksOnSamePTLOK;
    }

    /* Actions on the page */
   
    public PageReference Calculate(){
        // Call SAP with Action=1, to calculate pricing for the selected products
        try{
            if(this.getAllSelectedProductsReadyForSap()){
              
              // Erwan 20180209 : Make a 1st call without the selected AcM if Quote on "Prix Fixe" so we can get the normal product scale
              //if(oQuote.Action_Commerciale__r.Fixed_Price__c || oQuote.Action_Commerciale__r.Locked_Price_1_Year__c || oQuote.Action_Commerciale__r.Locked_Price_2_Years__c || oQuote.Action_Commerciale__r.Locked_Price_3_Years__c){
              if( selectedAC != null && (selectedAC.Fixed_Price__c || selectedAC.Locked_Price_1_Year__c || selectedAC.Locked_Price_2_Years__c || selectedAC.Locked_Price_3_Years__c) ){
                this.dataForController = this.wrapperForSOAPCall.calculatePricingForNewContract(this.makeListPendingLineItems(), null);
              }
              
                this.dataForController = this.wrapperForSOAPCall.calculatePricingForNewContract(this.makeListPendingLineItems(), selectedAC);
                //Update the QuoteLineItems And SelectedProducts with data got from SAP
                if (!this.dataForController.errorGotFromSAP){
                    this.lPendingLineItems = this.dataForController.listQuoteLineItemToCtrl;
                    this.lSelectedProducts = this.makeListSelectedProducts();
                    // TODO Where store this.dataForController.realAnnualConsumptionDO ??
                    // TODO Where store this.dataForController.realAnnualCapacityDO ??
                }
                this.listAPVFMessage.clear();
                this.listAPVFMessage.addAll(this.dataForController.listAPVFMessage);
            }    
        }catch(AP_CRMException e){
            for(String s : e.getMessages()){
                this.listAPVFMessage.add(new AP_VFMessage('E', s, ''));
            }
            this.wrapperForSOAPCall.oBapiTracker.Message__c = String.valueOf(this.listAPVFMessage);   
        }catch(System.CalloutException e){
            this.listAPVFMessage.add(new AP_VFMessage('E', System.Label.network_connectivity_slow + '(' + e.getMessage() + ')'));
            this.wrapperForSOAPCall.oBapiTracker.Message__c = String.valueOf(this.listAPVFMessage); 
        }
        // Log BAPI Calls
        this.wrapperForSOAPCall.oBapiTracker.Request__c = String.valueOf(this.wrapperForSOAPCall.webserviceSOAP.sRequest);
        this.wrapperForSOAPCall.oBapiTracker.Response3__c = String.valueOf(this.wrapperForSOAPCall.webserviceSOAP.sResponse);
        this.wrapperForSOAPCall.oBapiTracker.User__c = UserInfo.getUserId() ;
        if (this.wrapperForSOAPCall.sStoreTracker.toLowercase() == 'true') upsert this.wrapperForSOAPCall.oBapiTracker;
        
        return this.refresh();
    }

    public List<QuoteLineItem> makeListPendingLineItems(){
        List<QuoteLineItem> lQuoteLineItems = new List<QuoteLineItem>();
        for (SelectedProduct oSelected : this.lSelectedProducts){
            lQuoteLineItems.add(oSelected.getLineItem());
        }
        return lQuoteLineItems;
    }
    
    public List<QuoteLineItemView> makeListPendingLineItemsView(){
        List<QuoteLineItemView> lQuoteLineItemsView = new List<QuoteLineItemView>();
        for (QuoteLineItem oQLI : this.lPendingLineItems){
            lQuoteLineItemsView.add(new QuoteLineItemView(oQLI, this));
        }
        return lQuoteLineItemsView;
    }
    
    public Boolean getRenderTabTank(){
        for(QuoteLineItem QLI : this.lPendingLineItems){
            if(QLI.IsTank__c){
                return true;
            }
        }
        return false;
    }
    
    // ELC 20141118 Customer Owned Tank
    public Boolean getRenderTabTankClient(){
        for(QuoteLineItem QLI : this.lPendingLineItems){
            if(QLI.IsTank__c && QLI.Mis_Disposition__c=='Customer Owned Tank'){
                return true;
            }
        }
        return false;
    }
    
    public Boolean getRenderTabGotFromSAP(){
        Boolean showTab = false;
        for(QuoteLineItem QLI : this.lPendingLineItems){
            if(QLI.Got_From_SAP__c && QLI.PricebookEntry.Product2.Family != null && !QLI.PricebookEntry.Product2.Family.toLowerCase().equals('equipement') && !QLI.PricebookEntry.Product2.Family.toLowerCase().equals('produit')){
                showTab = true;
            }
            /**if(QLI.PricebookEntry.Product2.Family != null && 
                QLI.PricebookEntry.Product2.Family.toLowerCase().equals('redevance') &&
                QLI.PricebookEntry.Product2.Payment_type__c != null &&
                QLI.PricebookEntry.Product2.Payment_type__c.toLowerCase().equals('consignation')){
                return true;
            }**/
        }
        return showTab;
    }
    
    
    public List<QuoteLineItem> getlPendingTankLineItems(){
        List<QuoteLineItem> lTankLineItems = new List<QuoteLineItem>();
        for (QuoteLineItem QLI : this.lPendingLineItems){
            if(QLI.IsTank__c){
                lTankLineItems.add(QLI);
            }    
        }
        return lTankLineItems;
    }
    
    public List<QuoteLineItem> getlPendingGotFromSAPExceptEquipementLineItems(){
        List<QuoteLineItem> lGotFromSAPExceptEquipementLineItems = new List<QuoteLineItem>();
        for (QuoteLineItem QLI : this.lPendingLineItems){
            if(QLI.Got_From_SAP__c && !isProductFamily('equipement', QLI) && (!isProductFamily('produit',QLI) || isProductPropane(QLI))){
                lGotFromSAPExceptEquipementLineItems.add(QLI);
            }            
            /**if(QLI.PricebookEntry.Product2.Family != null && 
                QLI.PricebookEntry.Product2.Family.toLowerCase().equals('redevance') &&
                QLI.PricebookEntry.Product2.Payment_type__c != null &&
                QLI.PricebookEntry.Product2.Payment_type__c.toLowerCase().equals('consignation')){
                lConsignationLineItems.add(QLI);
            }**/    
        }
        return lGotFromSAPExceptEquipementLineItems;
    }
    
    private Boolean isProductFamily(String family, QuoteLineItem qli){
       return qli.PricebookEntry.Product2.Family != null && 
           qli.PricebookEntry.Product2.Family.toLowerCase().equals(family);
    }
    
    private Boolean isProductPropane(QuoteLineItem qli){
        return false;
    }
    public List<SelectedProduct> makeListSelectedProducts(){
        List<SelectedProduct> lSelectedProducts = new List<SelectedProduct>();
        for (QuoteLineItem oQLI : this.lPendingLineItems){
            lSelectedProducts.add(new SelectedProduct(oQLI, this));
        }
        return lSelectedProducts;
    }
    
    public PageReference navigateToStep1(){
        // Return to Selected Products!
        this.lSelectedProducts = this.makeListSelectedProducts();
        this.makeStatusMessages();
        return Page.VFP06_ProductSelector_Step1;
    }
    
    public PageReference navigateBackToStep1(){
        // Return to Selected Products!
        //this.lSelectedProducts = this.makeListSelectedProducts();
        PageReference backToStep1 = Page.VFP06_ProductSelector_Step1;
        if(onlyShowMode)
            backToStep1.getParameters().put('onlyShowMode', '1');
        this.makeStatusMessages();
        return backToStep1;
    }
    
    public PageReference navigateToStep1Bis(){
        // Return to Selected Products!
        this.lPendingLineItems = this.makeListPendingLineItems();
        if( this.oQUote.Opportunity.Account.Activity_Domain__r.ExternalID__c == 42 &&
            this.oQUote.Opportunity.Project_market_type__c == 'DOM' &&
            (this.oQuote.Opportunity.T_Pack__c == 'IDEO' ||
            this.oQuote.Opportunity.T_Pack__c == 'SOLO' ||
            this.oQuote.Opportunity.T_Pack__c == 'ECOCFT') &&
            !getTankInfoOK() ){
            //this.lPendingLineItems = this.makeListPendingLineItems();
            return this.refresh();
        }else if ( this.oQuote.Opportunity.Opportunity_Reason__c == 'Construction neuve' && !getScaleAndTanksOK() ){
            //this.lPendingLineItems = this.makeListPendingLineItems();
            return this.refresh();
        }else if( !getMultipleTanksOnSamePTLonECOCFTOK() ){
            return this.refresh();
        }else{
            this.lPendingLineItems = this.makeListPendingLineItems();
            //this.lSelectedProducts = this.makeListSelectedProducts();
            //this.lPendingLineItemsView = this.makeListPendingLineItemsView();
            PageReference goToStep1Bis = Page.VFP06_ProductSelector_Step1Bis;
            if(onlyShowMode)
                goToStep1Bis.getParameters().put('onlyShowMode', '1');
            this.makeStatusMessages();
            return goToStep1Bis;
        }
    }
    
    public PageReference navigateToStep2(){
        // Turn the selected products into actual Line Items now.
        if (!this.getAbleToSave()){ // Validate the input we just received (Quantity...)
            return this.refresh();
        }else{ 
            // All fine, proceed
            this.lPendingLineItems = this.makeListPendingLineItems();
           // PutIdentifiantContrat();  MLC - Automatisation  28/07/2014
            this.lPendingLineItemsView = this.makeListPendingLineItemsView();
            this.makeStatusMessages();
            return Page.VFP06_ProductSelector_Step2;
        }    
    }
    
    private class QuoteLineItemView{
        public VFC06_ProductSelector parentObject {get; set;}
        public QuoteLineItem QLI {get; set;}
        
        public QuoteLineItemView(QuoteLineItem QLI, VFC06_ProductSelector parentObject){
            this.parentObject = parentObject;
            this.QLI = QLI;
        }
        
         public Boolean getRCEToDisable(){
            System.debug(logginglevel.WARN,'###ELC T_Pack__c = ' + this.parentObject.oQuote.Opportunity.T_Pack__c);
           return this.parentObject.businessControls.toDisable('RCE_Rebate', this.QLI.PricebookEntry.Product2.Family, this.QLI.PricebookEntry.Product2.Sub_Type__c, (this.parentObject.oQuote.Opportunity.T_Pack__c !=null) ? this.parentObject.oQuote.Opportunity.T_Pack__c : ' ');
        }
        
        public Boolean getRCOMToDisable(){
           return this.parentObject.businessControls.toDisable('Commercial_Rebate', this.QLI.PricebookEntry.Product2.Family, this.QLI.PricebookEntry.Product2.Sub_Type__c, (this.parentObject.oQuote.Opportunity.T_Pack__c !=null) ? this.parentObject.oQuote.Opportunity.T_Pack__c : ' ');
        }
        
        public Boolean getRCONJToDisable(){
           return this.parentObject.businessControls.toDisable('Cyclical_Rebate', this.QLI.PricebookEntry.Product2.Family, this.QLI.PricebookEntry.Product2.Sub_Type__c, (this.parentObject.oQuote.Opportunity.T_Pack__c !=null) ? this.parentObject.oQuote.Opportunity.T_Pack__c : ' ');
        }
        
        public Boolean getHasFamilyOfTypeProduct(){
            return this.QLI.PricebookEntry.Product2.Family.toLowerCase().equals('produit');
        }
    }
    
    public Boolean GetisGEBCONS(){
        
         if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS')){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGEC(){      
         if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GrosVrac'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO COLL'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC OPTIMO'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    
    public Boolean GetisGrosVrac(){
        
         if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GrosVrac')){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGPLc(){
        
         if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GPLc')){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGEB(){
        
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEB RE'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGERProprietaire(){
        
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC energigaz'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGERUsager(){
        
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGECProprietaire(){
        
        if (
            GetisGEC() && this.oQuote.Client_Type__c == 'Owner'){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGECLocataire(){
        
        if (
            GetisGEC() && this.oQuote.Client_Type__c == 'Renter'){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGECPack(){      
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'))
           // || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    public Boolean GetisGECECOCFT(){      
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    
       public Boolean GetisGECOPTIMO(){      
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO'))
            ||(this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC OPTIMO'))
            ){
            return true;
        }
        else {
            return false;
        }
    }
   
    public Boolean GetisGECDOM(){
        if (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM')){
            return true;
        }
        else {
            return false;
        }
    }
    
    
    
     public Boolean GetisGECPackSansOptimo(){      
        if (
              (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'))
           
            ){
            return true;
        }
        else {
            return false;
        }
    }
    
    public String GetOptyProjectType(){
        if (this.oQuote.Opportunity.Project_Type__c != null){
            return this.oQuote.Opportunity.Project_Type__c;
        }
        else {
            return '';
        }
    }
    
    public Boolean GetShowAddStandardizedFormProductsBtn(){      
        if (
            (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO'))
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'))
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO COLL'))
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO') && this.oQuote.Opportunity.Project_market_subtype__c=='Commerce/Service')
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE') && this.oQuote.Product_Scale__c=='V1LIB')
           || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO'))
           ){
           return true;
       }
       else {
           return false;
       }
   }
    
    
     // Debut MLC Mis en commentaire le 28/07/2014 --- Automatisation  
   /* 
    public void PutIdentifiantContrat(){
        
        if (GetisGECProprietaire() || GetisGrosVrac() || GetisGPLc() || GetisGERProprietaire())
        {
            PutIsIdentifiantContratGECProprietaire();
        }
        else if (GetisGERUsager())
        {
            showContractNumber = false ;
            PutIsIdentifiantContratGERUsager();
        }
        else if (GetisGEB() || GetisGECLocataire()){
            showContractNumber = false ;
            PutIsIdentifiantContratGEBGECLOC();
        }
    }
    
    public void PutIsIdentifiantContratGECProprietaire(){
        decimal index = 0 ;
        map<Id,list<QuoteLineItem>> mQptlIDToNumofCiternes = new map<Id,list<QuoteLineItem>> ();
        
        for (QuoteLineItem oQLI : this.lPendingLineItems)
        {
            if (oqli.PricebookEntry.Product2.Sub_Type__c == 'Citerne')
            {
                index ++ ;
                oqli.Identifiant_Contrat__c = index ;
                oqli.T_Is_Identifiant_Contrat__c = 1 ;
                if(!mQptlIDToNumofCiternes.containsKey(oqli.Quote_PTL__c))
                {
                    mQptlIDToNumofCiternes.put(oqli.Quote_PTL__c,new list<QuoteLineItem>{oqli});
                }
                else
                {
                    showContractNumber = true ;
                    mQptlIDToNumofCiternes.get(oqli.Quote_PTL__c).add(oqli);
                    //mQptlIDToNumofCiternes.put(oqli.Quote_PTL__c,mQptlIDToNumofCiternes.get(oqli.Quote_PTL__c));
                }
            }
            else 
                oqli.T_Is_Identifiant_Contrat__c = 0 ;
        }
        
        for (Id iQPTLId: mQptlIDToNumofCiternes.keyset()) 
        {
            if(mQptlIDToNumofCiternes.get(iQPTLId).size()==1)
            {
                for (QuoteLineItem oQLI : this.lPendingLineItems)
                {
                    if(oQLI.Quote_PTL__c==iQPTLId)
                    {
                        oQLI.Identifiant_Contrat__c = mQptlIDToNumofCiternes.get(iQPTLId).get(0).Identifiant_Contrat__c  ;
                    }                   
                }               
            }

        }
        
    }
    
    public void PutIsIdentifiantContratGERUsager(){
        for (QuoteLineItem oQLI : this.lPendingLineItems){
            if (oqli.PricebookEntry.Product2.Sub_Type__c == 'Compteur'){
                oqli.T_Is_Identifiant_Contrat__c = 1 ;
            }
            else{
                oqli.T_Is_Identifiant_Contrat__c = 0 ;
            }
            
            oqli.Identifiant_Contrat__c = 1 ;
        }
    }
    
    public void PutIsIdentifiantContratGEBGECLOC()
    {
        decimal index = 0 ;
        
        for (QuoteLineItem oQLI : this.lPendingLineItems)
        {
            if (oqli.PricebookEntry.Product2.Sub_Type__c != 'Citerne')
            {
                if (index == 0)
                {
                    index ++ ;
                    oqli.T_Is_Identifiant_Contrat__c = 1 ;
                }
                else
                {
                    oqli.T_Is_Identifiant_Contrat__c = 0 ;
                }
                
                oqli.Identifiant_Contrat__c = 1 ;
            }
        }
    }
    
    */
   // Fin MLC Mis en commentaire le 28/07/2014 --- Automatisation  
    
    /*public boolean GetIsIdentifiantContrat(QuoteLineItem oQLI){
        
        if (oqli.Quote.Opportunity.DO_Activity_Domain__r.ExternalID__c == 42){
            if (oqli.PricebookEntry.Product2.Sub_Type__c == 'Citerne'){
                return true;
            }
            else
                return false;
        }
        else
            return false;
    }*/
    
    
    
    //Manages commercial offers
    
    
    // fired when the search button is clicked
    /*public PageReference searchAcM() {
        if (searchResults == null) {
            searchResults = new List<Action_Commerciale__c>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
        
        getTankInfo();
        
        // use some dynamic soql to find the list of Commercial Offers available for the criteria
        String qry = 'SELECT Id, Name, Libelle__c, Project_Type__c, Contract_Duration__c, Tank_Property__c, Tank_Type__c, Locked_Price__c FROM Action_Commerciale__c a Where Project_Type__c = \'' + q.Project_Type__c + '\' AND Contract_Duration__c = \'' + q.Contract_Duration__c + '\' AND Tank_Property__c = \'' + this.oQLI.Mis_Disposition__c + '\' AND Tank_Type__c = \'' + this.oQLI.PricebookEntry.Product2.Tank_Type__c + '\' Order By a.Name';
        System.debug('#### qry = ' + qry);
        searchResults = Database.query(qry);
        return null;
    }*/
    
    // loop on the QLIs to check
    private void getTankInfo() {
        
        List<SelectedProduct> tankProductList = new List<SelectedProduct>();
        selectedBioOption = '';
        
        // Loop through selected products to find tank related products
        for(SelectedProduct sp: lSelectedProducts) {
            if(sp.oEntry.Product2.Sub_Type__c != null && sp.oEntry.Product2.Sub_Type__c.toLowerCase().equals('citerne')) tankProductList.add(sp);
            
            // Get Bio Option selected to use in ActionCo eligibility query
            if( sp.lineitem.Bio_Product__c != null ){
                selectedBioOption = sp.lineitem.Bio_Product__c;
            }
            if( String.isBlank(selectedBioOption) ) selectedBioOption = 'NOT_BIO';  // Default value if no Bio option selected on QLIs
        }
        
        if (tankProductList.size() >= 1) {
            sTank_Property = tankProductList[0].misADisposition;
            //ELC 20141106 sTank_Type = tankProductList[0].oEntry.Product2.Tank_Type__c;
            ptlDefault = mQuotePTLs.get(tankProductList[0].quotePTLID);
        } 
        if (tankProductList.size() >= 1) {
            for (Integer i=0; i < tankProductList.size(); i++) {
                if (tankProductList[i].oEntry.Product2.Tank_Type__c == 'A' && tankProductList[i].tankPlacing != null && tankProductList[i].tankPlacing != 'RDS' && tankProductList[i].tankPlacing != 'IDE') {
                    sTank_Type = 'A';
                    ptlDefault = mQuotePTLs.get(tankProductList[0].quotePTLID);
                //ELC 20141106
                } else if (tankProductList[i].oEntry.Product2.Tank_Type__c == 'E' && sTank_Type != 'A' && tankProductList[i].tankPlacing != null && tankProductList[i].tankPlacing != 'RDS' && tankProductList[i].tankPlacing != 'IDE') {
                    sTank_Type = 'E';
                    ptlDefault = mQuotePTLs.get(tankProductList[0].quotePTLID);
                }
                if (tankProductList[i].misADisposition == 'Butagaz Owned Tank') sTank_Property = 'Butagaz Owned Tank';
            }
        }
        System.debug(logginglevel.WARN,'### ptlDefault Property: ' + ptlDefault);
        //System.debug('### sTank_Property: ' + sTank_Property);
        //System.debug('### sTank_Type: ' + sTank_Type);
    }
    
    // fired when the add button is clicked
    /*public PageReference addCommOffer() {
        
        System.debug('AcMIdChosen = '+ AcMIdChosen );
        this.q.Action_Commerciale__c = AcMIdChosen;
        System.debug('this.q.Action_Commerciale__c = '+ this.q.Action_Commerciale__c );
        
        update q;
        
        return null;
    }*/
    
    // Manages Radio Buttons
    Public List<Action_Commerciale__c> getAllAcMs()
    {
        getTankInfo();
        
        mTrueFalse = new Map<Integer,Boolean>{0 => False, 1 => True};
        
        // We don't want any offer to be displayed if Client_Reenlistment__c != 'Contract'
        //if (this.oQuote.Client_Reenlistment__c == 'Contract'){
        
            // We don't want any offer to be displayed for renters
            // 20170721 : Update : except if Account_Owner_Market_subtype__c != null
            if ( !this.oQuote.Opportunity.Client_Type__c.toLowerCase().equals('renter') || (this.oQuote.Opportunity.Client_Type__c.toLowerCase().equals('renter') && this.oQuote.Opportunity.Account_Owner_Market_subtype__c!=null) ){
                
                String acQuery = 'SELECT Id, Name, Libelle__c, Project_Type__c, Contract_Duration__c, Tank_Property__c, ' +
                    'Tank_Type__c, Locked_Price__c, Articles__c ' +
                    'FROM Action_Commerciale__c a WHERE ' +
                        'Project_Type__c = \'' + this.oQuote.Opportunity.Project_Type__c + '\' ' +
                        'AND ( Client_Type__c = \'' + this.oQuote.Opportunity.Client_Type__c + '\' OR Client_Type_Not_Needed__c = TRUE ) ' +
                        'AND ( Cible__c INCLUDES (\'' + this.oQuote.Opportunity.Energy_Source__c + '\') OR Cible_Not_Needed__c = TRUE ) ' +
                        'AND ( DPE__c INCLUDES (\'' + this.oQuote.Opportunity.DPE__c + '\') OR DPE_Not_Needed__c = TRUE ) ' +
                        'AND ( Opportunity_Reason__c INCLUDES (\'' + this.oQuote.Opportunity.Opportunity_Reason__c + '\') ' +
                        'OR Opportunity_Reason_Not_Needed__c = TRUE ) ' +
                        'AND ( Contract_Duration__c INCLUDES (\'' + this.oQuote.Contract_Duration__c + '\') ' +
                        'OR Contract_Duration_Not_Needed__c = TRUE ) ' +
                        'AND Tank_Property__c INCLUDES (\'' + sTank_Property + '\') ' +
                        'AND Tank_Type__c INCLUDES (\'' + sTank_Type + '\') ' +
                        'AND ( Prescriber__c = ' + this.oQuote.Opportunity.Account.Prescriber_Client_GEC_DOM__c + ' ' +
                        'OR Prescriber_Not_Needed__c = TRUE ) ' +
                        'AND ( Collaborator__c = ' + this.oQuote.Opportunity.Account.Collaborator__c + ' ' +
                        'OR Collaborator_Not_Needed__c = TRUE ) ' +
                        'AND ( Account_Owner_Market_subtype__c = \'' + this.oQuote.Opportunity.Account_Owner_Market_subtype__c + '\' ' +
                        'OR Account_Owner_Market_subtype_Not_Needed__c = TRUE ) ' +
                        'AND ( Market_subtype__c INCLUDES (\'' + this.oQuote.Opportunity.Project_market_subtype__c + '\') ' +
                        'OR Market_subtype_Not_Needed__c = TRUE ) ' +
                        'AND Volume_Min__c <= ' + this.oQuote.Sum_PTL_Consumption__c + ' ' +
                        'AND ( Volume_Max__c >= ' + this.oQuote.Sum_PTL_Consumption__c + ' OR Volume_Max__c = NULL ) ' +
                        'AND VAT_code__c INCLUDES (\'' + this.oQuote.VAT_code__c + '\') ' +
                        'AND Client_Reenlistment__c INCLUDES (\'' + this.oQuote.Client_Reenlistment__c + '\') ' +
                        'AND ( Product_Scale__c INCLUDES (\'' + this.oQuote.Product_Scale__c + '\') ' +
                        'OR Product_Scale_Not_Needed__c = TRUE ) ' +
                        'AND ( Bio_Product__c INCLUDES (\'' + this.selectedBioOption + '\') ' +
                        'OR Bio_Product_Not_Needed__c = TRUE ) ' +
                        'AND T_Pack__c INCLUDES (\'' + this.oQuote.Opportunity.T_Pack__c + '\') ' ;
                      
                    if ( this.oquote.Opportunity.Project_Type__c == 'FIDE' ){
                        acQuery +=
                        'AND EtaitPackIDEOSOLOECOCFT__c = ' + mTrueFalse.get(Integer.valueOf(this.oquote.T_LAT_GEC_ALL_EtaitPackIDEOSOLOECOCFT__c)) + ' ' +
                        'AND Seniority_Min__c <= ' + this.oQuote.T_Anciennete_Contrat__c + ' ' +
                        'AND ( Seniority_Max__c >= ' + this.oQuote.T_Anciennete_Contrat__c + ' OR Seniority_Max__c = NULL ) ' ;
                    }
                    
                    // if Prescriber filled on the opty, we need to check if it is required for the commercial offer
                    if ( this.oQuote.Opportunity.Prescriber_Account__c != null ){
                        acQuery +=
                            'AND ( Prescribed_Opportunity__c = TRUE ' +
                                'OR Prescribed_Opportunity_Not_Needed__c = TRUE ) ' ;
                    }else{
                        acQuery +=
                            'AND ( Prescribed_Opportunity__c = FALSE ' +
                                'OR Prescribed_Opportunity_Not_Needed__c = TRUE ) ' ;
                    }
                    /*
                    if ( this.oQuote.Opportunity.Prescriber_Account__c != null && this.oQuote.Opportunity.Prescriber_Account__r.Prescriber_Activity__c != null ){
                        acQuery +=
                            'AND Prescriber_Activity__c INCLUDES (\'' + this.oQuote.Opportunity.Prescriber_Account__r.Prescriber_Activity__c + '\') ' ;
                    } else {
                        acQuery +=
                            'AND Prescriber_Activity__c = null ' ;
                    }*/
                    acQuery +=
                        'AND Start_Date__c <= ' + Datetime.now().format('yyyy-MM-dd') + ' ' +
                        'AND ( End_Date__c >= ' + Datetime.now().format('yyyy-MM-dd') + ' OR End_Date__c = NULL ) ' ;
                if (null != this.oQuote.QuantiteRestante__c){
                   acQuery +=   
                        'AND ( QuantiteRestante__c<= ' + this.oQuote.QuantiteRestante__c+ ' ' +
                       'OR QuantiteRestanteNonRequis__c= TRUE ) ' +
                        'AND (( QuantiteRestanteMax__c>= ' + this.oQuote.QuantiteRestante__c+ ' OR QuantiteRestanteMax__c= NULL ) ' +
                           'OR QuantiteRestanteNonRequis__c = TRUE ) ' ; 
                }
                
                acQuery +='Order By Name';
                System.debug(logginglevel.WARN,'### acQuery = ' + acQuery);
                
                // Reset allAcMs
                // ORO: 140901 START
                //List<Action_Commerciale__c> allAcMs = new List<Action_Commerciale__c>();
                //allAcMs = Database.query(acQuery);
                // ORO: 140901 END
                this.lActionsCommerciales.clear();
                this.lActionsCommerciales = Database.query(acQuery);       
            
            }
        //}
        
        Set<String> autoProductsSet = new Set<String>();
        if(lActionsCommerciales.size() > 0) {
            // Get all additional products
            for(Action_Commerciale__c tmpACC: lActionsCommerciales) {
                if(tmpACC.Articles__c != null) {
                    List<String> tmpArticleList = tmpACC.Articles__c.split(';');
                    for (String tmpString: tmpArticleList) {
                        //System.debug('### found code:' + tmpString);
                        // ELC 20151130 : pour demande "Exonération pour succession familiale"
                        if(tmpString=='S000000132' && this.oQuote.Application_fee_exemption__c==true){
                            // Si "Exonération pour succession familiale", on n'ajoute pas les frais de dossier
                        }else{
                            if(!autoProductsSet.contains(tmpString)) autoProductsSet.add(tmpString);
                        }
                    }
                }
            }
            //System.debug('### autoProductsSet:' + autoProductsSet);
            
            // Adding "No AC line"
            Action_Commerciale__c tmpACC = new Action_Commerciale__c(Name='', Libelle__c = 'Ne pas affecter d\'action commerciale', Locked_Price__c = false);
            lActionsCommerciales.add(tmpACC);
            
        }
            
        List<PricebookEntry> autoPBList = new List<PricebookEntry>([
            SELECT Id, Product2.Id, Product2.Name, Product2.Family, 
                Product2.Capacity__c, Product2.Sub_Type__c, Product2.Payment_type__c, 
                Product2.ProductCode, Product2.UseGerConsumption__c, Product2.UseConnectionType__c,  
                Product2.UseConsumerTarget__c, Product2.is_crea__c, Product2.is_not_pack__c, 
                Product2.Tank_Type__c, Product2.Tank_protection__c, Product2.IsActive, 
                Product2.noSAP__c, UnitPrice,  Product2.Auto_Add__c, Product2.MonthlyPriceDisplay__c,
                Product2.external_ID__c, Product2.Standardized_Form__c, Product2.CapacityMin__c, Product2.CapacityMax__c, Product2.Technical_Action_Type__c, Product2.Tank_Pumping__c
            FROM PricebookEntry
            WHERE Pricebook2Id = :this.PricebookId
            AND (Product2.ProductCode IN :autoProductsSet
                OR(
                    Product2.Standardized_Form__c = true 
                    
                ) 
            )
        ]);
        //AND (Product2.Tank_Type__c = '' OR Product2.Tank_Type__c = :sTank_Type)

        //System.debug('### autoPBList:' + autoPBList);
        
        if (autoProductsMap != null) autoProductsMap.clear();
        if (autoProductsStandardizedFormMap != null) autoProductsStandardizedFormMap.clear();
        if (autoProductsStorageModificationMap != null) autoProductsStandardizedFormMap.clear();
        
        if (autoPBList.size() > 0) {
          
            string cptAutoProductsStandardizedFormMap = '#'; // Used to dissociate each product in the map key so that we can add the same code several times
            // Loop through selected products to find tank related products
            for(SelectedProduct sp: lSelectedProducts) {
                if(sp.oEntry.Product2.Sub_Type__c != null && sp.oEntry.Product2.Sub_Type__c.toLowerCase().equals('citerne')){
                    
                    // We want to add specific products on each tank for the standardized form (Frais de retrait and Frais de neutralisation)
                    for (PricebookEntry pbEntryList: autoPBList){
                        System.debug(logginglevel.WARN,'### pbEntryList.Product2.Capacity__c :' + pbEntryList.Product2.Capacity__c);
                        System.debug(logginglevel.WARN,'### sp.oEntry.Product2.Capacity__c :' + sp.oEntry.Product2.Capacity__c);
                        if( pbEntryList.Product2.Standardized_Form__c == true && pbEntryList.Product2.Capacity__c != null && sp.oEntry.Product2.Capacity__c >= pbEntryList.Product2.CapacityMin__c && sp.oEntry.Product2.Capacity__c <= pbEntryList.Product2.CapacityMax__c
                                    && ( String.isBlank(pbEntryList.Product2.Tank_Type__c) || sp.oEntry.Product2.Tank_Type__c == pbEntryList.Product2.Tank_Type__c ) ){
                            //autoProductsStandardizedFormMap.put(pbEntryList.Product2.ProductCode, pbEntryList);
                            System.debug(logginglevel.WARN,'### pbEntryList.Product2.Capacity__c :' + pbEntryList.Product2.Capacity__c);
                            System.debug(logginglevel.WARN,'### pbEntryList.Product2.ProductCode :' + pbEntryList.Product2.ProductCode + cptAutoProductsStandardizedFormMap);
                            
                            System.debug(logginglevel.WARN,'### sp.lineitem.Tank_Placing_Options__c :' + sp.lineitem.Tank_Placing_Options__c);
                            if(!String.isBlank(pbEntryList.Product2.Technical_Action_Type__c)) 
                                System.debug(logginglevel.WARN,'### pbEntryList.Product2.Technical_Action_Type__c.toLowerCase() :' + pbEntryList.Product2.Technical_Action_Type__c.toLowerCase());
                            System.debug(logginglevel.WARN,'### sp.lineitem.Tank_Pumping_Required__c :' + sp.lineitem.Tank_Pumping_Required__c);
                            
                            // We'll add products to a different map if there's a tank removal so we can flag the corresponding QLIs  
                            // Add tank removal product
                            if( sp.lineitem.Tank_Placing_Options__c == 'RDS' && !String.isBlank(pbEntryList.Product2.Technical_Action_Type__c) && pbEntryList.Product2.Technical_Action_Type__c.toLowerCase() == 'retrait' ){
                                autoProductsStorageModificationMap.put(pbEntryList.Product2.ProductCode + cptAutoProductsStandardizedFormMap, pbEntryList);
                                System.debug(logginglevel.WARN,'### Ajout1 :' + pbEntryList.Product2.ProductCode + ', ' + sp.lineitem.Tank_Placing_Options__c + ', ' + pbEntryList.Product2.Technical_Action_Type__c);
                                
                            // Also add tank pumping product if applicable
                            // Tank Pumping Required
                            }else if( sp.lineitem.Tank_Placing_Options__c == 'RDS' && !String.isEmpty(pbEntryList.Product2.Tank_Pumping__c) && sp.lineitem.Tank_Pumping_Required__c == pbEntryList.Product2.Tank_Pumping__c ){
                                autoProductsStorageModificationMap.put(pbEntryList.Product2.ProductCode + cptAutoProductsStandardizedFormMap, pbEntryList);
                                System.debug(logginglevel.WARN,'### Ajout2 :' + pbEntryList.Product2.ProductCode + ', ' + sp.lineitem.Tank_Placing_Options__c + ', ' + sp.lineitem.Tank_Pumping_Required__c);
                            // Tank Pumping for Standardized Form
                            }else if( sp.lineitem.Tank_Placing_Options__c != 'RDS' && !String.isEmpty(pbEntryList.Product2.Tank_Pumping__c) ){
                                autoProductsStandardizedFormMap.put(pbEntryList.Product2.ProductCode + cptAutoProductsStandardizedFormMap, pbEntryList);
                                System.debug(logginglevel.WARN,'### Ajout3 :' + pbEntryList.Product2.ProductCode + ', ' + sp.lineitem.Tank_Placing_Options__c + ', ' + sp.lineitem.Tank_Pumping_Required__c);
                            // Other products for Standardized Form
                            }else if( sp.lineitem.Tank_Placing_Options__c != 'RDS' && String.isEmpty(pbEntryList.Product2.Tank_Pumping__c) ){
                                autoProductsStandardizedFormMap.put(pbEntryList.Product2.ProductCode + cptAutoProductsStandardizedFormMap, pbEntryList);
                                System.debug(logginglevel.WARN,'### Ajout4 :' + pbEntryList.Product2.ProductCode + ', ' + sp.lineitem.Tank_Placing_Options__c + ', ' + sp.lineitem.Tank_Pumping_Required__c);
                            }
                        }
                    }
                    cptAutoProductsStandardizedFormMap = cptAutoProductsStandardizedFormMap + '#';
                }
            }
            
            for (PricebookEntry pbEntryList: autoPBList) {
                
                // We still need to add the autoProducts from the AcM and the products specific for the standardized form that don't need to be repeated for each tank
                if( pbEntryList.Product2.Standardized_Form__c == false ){
                    autoProductsMap.put(pbEntryList.Product2.ProductCode, pbEntryList);
                    System.debug(logginglevel.WARN,'### Ajout5 :' + pbEntryList.Product2.ProductCode);
                }else if( pbEntryList.Product2.Standardized_Form__c == true && pbEntryList.Product2.Capacity__c == null ){
                    autoProductsStandardizedFormMap.put(pbEntryList.Product2.ProductCode, pbEntryList);
                    System.debug(logginglevel.WARN,'### Ajout6 :' + pbEntryList.Product2.ProductCode);
                }
                
            }
            
        }
        //if (autoProductsMap != null) System.debug('### autoProductsMap:' + autoProductsMap);
        System.debug(logginglevel.WARN,'### autoProductsMap:' + autoProductsMap);
        System.debug(logginglevel.WARN,'### autoProductsStandardizedFormMap:' + autoProductsStandardizedFormMap);
        System.debug(logginglevel.WARN,'### autoProductsStorageModificationMap:' + autoProductsStorageModificationMap);
        
        
        //manageStandardizedFormProducts();
        
        if(lActionsCommerciales.size() > 0) {
          this.hasAvailableAcMs = true;
        } else this.hasAvailableAcMs = false;
        return lActionsCommerciales;
    }
    
    /*boolean bStandardizedFormProductsOK = false;
    
    Public boolean getStandardizedFormProducts(){
      manageStandardizedFormProducts();
        return bStandardizedFormProductsOK;
    }*/
    
    public void manageStandardizedFormProducts(){
      
        for (SelectedProduct selectedPrd: this.lSelectedProducts) {
            if(selectedPrd.oEntry.Product2.Standardized_Form__c ) {  //&& !selectedPrd.lineItem.Got_From_SAP__c) {
                System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | Will remove SelectedProduct: ' + selectedPrd.oEntry.Product2.Name);
                selectedPrd.remove();
                //selectedPrd.syncedWithSAP = false;
            }
            selectedPrd.syncedWithSAP = false;
        }
        
        // Manage products that will only be on the standardized form
        //for(PricebookEntry prd : autoProductsStandardizedFormMap.values()){
        for(string prd : autoProductsStandardizedFormMap.keySet()){
            System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | prd:' + prd);
            //if(prd.Product2.Standardized_Form__c == true){
            if( autoProductsStandardizedFormMap.get(prd).Product2.Standardized_Form__c == true ){
                //AvailableProduct tmpAP = new AvailableProduct(autoProductsStandardizedFormMap.get(prd.Product2.ProductCode), this, null);
                AvailableProduct tmpAP = new AvailableProduct(autoProductsStandardizedFormMap.get(prd), this, null, true);
                if( tmpAP != null ){
                    System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | Will add Product only for standardized form: ' + autoProductsStandardizedFormMap.get(prd).Product2.Name + ' (Code: ' + autoProductsStandardizedFormMap.get(prd).Product2.ProductCode +')...');
                    tmpAP.add();
                }
            }
        }
        
        // Manage products that will both be on the contract and the standardized form
        for(string prd : autoProductsStorageModificationMap.keySet()){
            System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | prd:' + prd);
            AvailableProduct tmpAP = new AvailableProduct(autoProductsStorageModificationMap.get(prd), this, null, false);
            if( tmpAP != null ){
                System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | Will add Product both for contract and standardized form: ' + autoProductsStorageModificationMap.get(prd).Product2.Name + ' (Code: ' + autoProductsStorageModificationMap.get(prd).Product2.ProductCode +')...');
                tmpAP.add();
            }
        }
        
        // Loop through the new selected products, add default QuotePtl
        for (SelectedProduct tmpSelP  : lSelectedProducts) {
            if (ptlDefault != null && tmpSelP.quotePTLID == null) {
                tmpSelP.quotePTLID = ptlDefault.id;
            }
        }
      
        // Re-build PendingLineItem List
        this.lPendingLineItems = this.makeListPendingLineItems();
        //this.lPendingLineItemsView = this.makeListPendingLineItemsView();
        //bStandardizedFormProductsOK = true;
      
    }
    
    
    List<Action_Commerciale__c> selectAcM =new List<Action_Commerciale__c>();
    
    Public List<Action_Commerciale__c> getselectedAcM()
    {
        SelectAcM();
        return selectAcM;
    }
    
    Public void SelectAcM(){
        
        selectAcM.clear();
        this.selectedAC = null;
        if (AcMId2Chosen != null && AcMId2Chosen != '') {
            this.selectedAC  = [
                SELECT Id, Name, Libelle__c, Locked_Price__c, Offered_Months__c, Articles__c, RCE__c, Offered_Redevance__c, RCOM__c, RCOM_AbonnementAccesEnergie__c,
                Fixed_Price__c, Locked_Price_1_Year__c, Locked_Price_2_Years__c, Locked_Price_3_Years__c
                FROM Action_Commerciale__c a 
                WHERE Id=:AcMId2Chosen 
                LIMIT 1
            ];
            selectAcM.add(this.selectedAC);
            if (this.selectedAC != null) {
                this.sOfferedMonths = String.valueOf(this.selectedAC.Offered_Months__c);
                this.sOfferedRedevance = string.valueOf(this.selectedAC.Offered_Redevance__c);
            }
        }
        
        
        System.debug(logginglevel.WARN,'### SelectAcM: AcMId values: AcMIdChosen:' + this.AcMIdChosen + ' AcMId2Chosen' + this.AcMId2Chosen);
        
        if(this.AcMIdChosen != null && this.AcMId2Chosen != null && this.AcMIdChosen != this.AcMId2Chosen) {
            System.debug(logginglevel.WARN,'### Items to add or remove:');
            cptTank = 0;
            for (SelectedProduct selectedPrd: this.lSelectedProducts) {
                if(selectedPrd.oEntry.Product2.Auto_Add__c && !selectedPrd.lineItem.Got_From_SAP__c) {
                    System.debug(logginglevel.WARN,'### Will remove SelectedProduct: ' + selectedPrd.oEntry.Product2.Name);
                    selectedPrd.remove();
                }
                // ELC 20150108 To add one instance of each auto-added articles for each tank
                if(selectedPrd.lineItem.IsTank__c && selectedPrd.lineItem.Tank_Placing_Options__c != 'RDS' && selectedPrd.lineItem.Tank_Placing_Options__c != 'IDE') {
                    cptTank += 1;
                }
                selectedPrd.syncedWithSAP = false;
            }
            
            if (selectAcM.size() == 1 &&  selectAcM[0].Articles__c != null ) {
                // ORO 141010: Bug fix: offered months only applied to selected products (SPPABO0010;SPPABO0008) --> Custom setting
                // Get all product codes we will apply the offered month to
                Set<String> sACOfferedMonthsApplies = new Set<String>();
                sACOfferedMonthsApplies.addAll(AP_PricingUtilities.getCustomSettingValue('ACOfferedMonthsApplies').split(';'));
                System.debug(logginglevel.WARN,'### sACOfferedMonthsApplies content: ' + sACOfferedMonthsApplies);
                
                Set<String> sAC_Prevent_Duplication_on_Articles = new Set<String>();
                sAC_Prevent_Duplication_on_Articles.addAll(AP_PricingUtilities.getCustomSettingValue('AC_Prevent_Duplication_on_Articles').split(';'));
                
                // ELC 20141104
                // Ajouter test sur Project_Type = FIDE et Contrat__r not null dans méthode getNumberOfMonthsRemainingOnContract()
                if ( this.oQuote.Opportunity.Contrat__c != null && this.oQuote.Opportunity.Contrat__r.ContractTerm != null 
                  && selectAcM[0].Offered_Redevance__c != null ){
                    sNumberOfMonthsRemainingOnContract = getNumberOfMonthsRemainingOnContract();
                    System.debug(logginglevel.WARN,'### ELC sNumberOfMonthsRemainingOnContract: ' + sNumberOfMonthsRemainingOnContract);
                    
                    sArticlesOfferedRedevance.addall(selectAcM[0].Offered_Redevance__c.split(';'));
                }
                
                
                List<String> tmpArticles = selectAcM[0].Articles__c.split(';');
                
                for (String articleName: tmpArticles) {
                    integer iCpt = 1;
                    while (iCpt <= cptTank){
                        //System.debug('### ELC autoProductsMap.get(articleName).Product2.ProductCode: ' + autoProductsMap.get(articleName).Product2.ProductCode);
                        if (articleName != null ){
                            if (autoProductsMap.get(articleName)!= null && autoProductsMap.get(articleName).Product2.external_ID__c != null ){
                                System.debug(logginglevel.WARN,'### iCpt ' + iCpt);
                                System.debug(logginglevel.WARN,'### sAC_Prevent_Duplication_on_Articles.contains articleName ' + sAC_Prevent_Duplication_on_Articles.contains(articleName));
                                
                                if ( (!sAC_Prevent_Duplication_on_Articles.contains(articleName)) || (sAC_Prevent_Duplication_on_Articles.contains(articleName) && (iCpt == 1)) ){
                                    // ORO 141011 - Do we need to add offered Months to this new auto added article ?                   
                                    if(sACOfferedMonthsApplies.size() > 0 && sACOfferedMonthsApplies.contains(autoProductsMap.get(articleName).Product2.external_ID__c)) {
                                        
                                        // ELC 20141118
                                        if ( this.oQuote.Opportunity.Contrat__c != null && sNumberOfMonthsRemainingOnContract != null && sArticlesOfferedRedevance.contains(autoProductsMap.get(articleName).Product2.ProductCode) ){
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName), this, integer.valueof(sNumberOfMonthsRemainingOnContract), false);
                                            if (tmpAP != null) {
                                                System.debug(logginglevel.WARN,'### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode + ' and offered Redevance: ' + sNumberOfMonthsRemainingOnContract);
                                                tmpAP.add();
                                            }
                                        } else {
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName), this, selectAcM[0].Offered_Months__c, false);
                                            if (tmpAP != null) {
                                                System.debug(logginglevel.WARN,'### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode +' and offered Month: '+ selectAcM[0].Offered_Months__c);
                                                tmpAP.add();
                                            }
                                        }
                                        /*// ELC 20141106
                                        if ( this.oQuote.Opportunity.Contrat__c != null && sNumberOfMonthsRemainingOnContract != null && sArticlesOfferedRedevance.contains(autoProductsMap.get(articleName).Product2.ProductCode) ){
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName),this, selectAcM[0].Offered_Months__c, integer.valueof(sNumberOfMonthsRemainingOnContract));
                                            if (tmpAP != null) {
                                                System.debug('### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode +' and offered Month: '+ selectAcM[0].Offered_Months__c + ' and offered Redevance: ' + sNumberOfMonthsRemainingOnContract);
                                                tmpAP.add();
                                            }
                                        } else {
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName),this, selectAcM[0].Offered_Months__c, null);
                                            if (tmpAP != null) {
                                                System.debug('### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode +' and offered Month: '+ selectAcM[0].Offered_Months__c);
                                                tmpAP.add();
                                            }
                                        }
                                        // ELC 20141106 Fin*/
                                        
                                        
                                    } else {
                                        // ELC 20141106 
                                        if ( this.oQuote.Opportunity.Contrat__c != null && sNumberOfMonthsRemainingOnContract != null && sArticlesOfferedRedevance.contains(autoProductsMap.get(articleName).Product2.ProductCode) ){
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName), this, integer.valueof(sNumberOfMonthsRemainingOnContract), false);
                                            if (tmpAP != null) {
                                                System.debug(logginglevel.WARN,'### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode + ' and offered Redevance: ' + sNumberOfMonthsRemainingOnContract);
                                                tmpAP.add();
                                            }
                                        } else {
                                            AvailableProduct tmpAP = new AvailableProduct(autoProductsMap.get(articleName), this, null, false);
                                            if (tmpAP != null) {
                                                System.debug(logginglevel.WARN,'### Will add Product: ' + autoProductsMap.get(articleName).Product2.Name + ' (Code: ' + autoProductsMap.get(articleName).Product2.ProductCode +')...');
                                                tmpAP.add();
                                            }
                                        }
                                        // ELC 20141106 Fin
                                            
                                        
                                    }                    
                                }
                            }
                            iCpt++;
                        }
                
                        // Loop through the new selected products, reset flag, set offeredMonths and add default QuotePtl
                        // TODO RCE
                        for (SelectedProduct tmpSelP  : lSelectedProducts) {
                            if (ptlDefault != null && tmpSelP.quotePTLID == null) {
                                tmpSelP.quotePTLID = ptlDefault.id;
                            }
                        }
              
                    }
                }
            }
            
            
            /*for (SelectedProduct selectedPrd: this.lSelectedProducts) {
                if(selectedPrd.oEntry.Product2.Standardized_Form__c ) {  //&& !selectedPrd.lineItem.Got_From_SAP__c) {
                    System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | Will remove SelectedProduct: ' + selectedPrd.oEntry.Product2.Name);
                    selectedPrd.remove();
                    //selectedPrd.syncedWithSAP = false;
                }
                selectedPrd.syncedWithSAP = false;
            }
          
          //for(PricebookEntry prd : autoProductsStandardizedFormMap.values()){
            for(string prd : autoProductsStandardizedFormMap.keySet()){
                System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | prd:' + prd);
                //if(prd.Product2.Standardized_Form__c == true){
                if(autoProductsStandardizedFormMap.get(prd).Product2.Standardized_Form__c == true){
                    //AvailableProduct tmpAP = new AvailableProduct(autoProductsStandardizedFormMap.get(prd.Product2.ProductCode), this, null);
                    AvailableProduct tmpAP = new AvailableProduct(autoProductsStandardizedFormMap.get(prd), this, null);
                    if (tmpAP != null) {
                        System.debug(logginglevel.WARN,'### manageStandardizedFormProducts | Will add Product: ' + autoProductsStandardizedFormMap.get(prd).Product2.Name + ' (Code: ' + autoProductsStandardizedFormMap.get(prd).Product2.ProductCode +')...');
                        tmpAP.add();
                    }
                }
            }
            
            // Loop through the new selected products, add default QuotePtl
            for (SelectedProduct tmpSelP  : lSelectedProducts) {
                if (ptlDefault != null && tmpSelP.quotePTLID == null) {
                    tmpSelP.quotePTLID = ptlDefault.id;
                }
            }*/
            
            if( GetShowAddStandardizedFormProductsBtn() ){
                manageStandardizedFormProducts();
            }
            
            
            // Update AcMIdChosen
            this.AcMIdChosen = this.AcMId2Chosen;
            // Re-build PendingLineItem List
            this.lPendingLineItems = this.makeListPendingLineItems();
            //this.lPendingLineItemsView = this.makeListPendingLineItemsView();
            
            
            /*System.debug('### ELC this.lSelectedProducts: ' + lSelectedProducts);
            for (SelectedProduct tmpSP : lSelectedProducts){
                System.debug('### ELC tmpSP.ProductCode: ' + tmpSP.oEntry.Product2.ProductCode);
                System.debug('### ELC tmpSP..lineitem.Offered_Redevance_Nb_Months__c: ' + tmpSP.lineitem.Offered_Redevance_Nb_Months__c);
                System.debug('### ELC tmpSP..lineitem.Offered_Months__c: ' + tmpSP.lineitem.Offered_Months__c);
            }*/
            // ELC 20141104
            // Ajouter test sur Project_Type = FIDE et Contrat__r not null dans méthode getNumberOfMonthsRemainingOnContract()
            /*string sNumberOfMonthsRemainingOnContract = getNumberOfMonthsRemainingOnContract();
            //System.debug('### ELC sNumberOfMonthsRemainingOnContract: ' + sNumberOfMonthsRemainingOnContract);
            List<String> lArticlesOfferedRedevance = selectAcM[0].Offered_Redevance__c.split(';');
            // Put list in a Set to be able to use the contains() method
            Set<String> setArticlesOfferedRedevance = new Set<String>();
            setArticlesOfferedRedevance.addAll(lArticlesOfferedRedevance);
            
            for (SelectedProduct tmpSelPRed  : lSelectedProducts) {
                System.debug('### ELC tmpSelPRed.ProductCode: ' + tmpSelPRed.oEntry.Product2.ProductCode);
                
                if (setArticlesOfferedRedevance.contains(tmpSelPRed.oEntry.Product2.ProductCode)){
                    System.debug('### ELC Article trouvé tmpSelPRed.lineitem.Offered_Redevance_Nb_Months__c: ' + tmpSelPRed.lineItem.Offered_Redevance_Nb_Months__c);
                    System.debug('### ELC Article trouvé tmpSelPRed.lineitem.Offered_Months__c: ' + tmpSelPRed.lineItem.Offered_Months__c);
                    tmpSelPRed.lineItem.Offered_Redevance_Nb_Months__c = integer.valueof(sNumberOfMonthsRemainingOnContract);
                    System.debug('### ELC Article trouvé tmpSelPRed.lineitem.Offered_Redevance_Nb_Months__c: ' + tmpSelPRed.lineItem.Offered_Redevance_Nb_Months__c);
                }
            }
            
            // Re-build PendingLineItem List
            this.lPendingLineItems = this.makeListPendingLineItems();
            // ELC FIN 20141104
            System.debug('### ELC this.lPendingLineItems: ' + lPendingLineItems);
            for (QuoteLineItem tmpPLI : lPendingLineItems){
                System.debug('### ELC tmpPLI.F_Product_Code__c: ' + tmpPLI.F_Product_Code__c + ' , Offered_Months__c: ' + tmpPLI.Offered_Months__c + ' , Offered_Redevance_Nb_Months__c: ' + tmpPLI.Offered_Redevance_Nb_Months__c);
            }*/
            
        }
        
        System.debug(logginglevel.WARN,'### InfoQLIToRemove:' + lQLIToRemove);
               
    }
    
    //used to calculate number of months remaining on a contract to add offered months on a quote
    public string getNumberOfMonthsRemainingOnContract(){
        
        date dNow = date.newInstance(date.today().year(),date.today().month(),date.today().day());
        date dCtrStartDate = this.oQuote.Opportunity.Contrat__r.StartDate;
        date dCtrCalculatedEndDate;
        Integer iCtrTerm = this.oQuote.Opportunity.Contrat__r.ContractTerm;
        Integer iNbMonths;
         System.debug(logginglevel.WARN,'### this.oQuote.Opportunity.Contrat__r: ' + this.oQuote.Opportunity);
        System.debug(logginglevel.WARN,'### dNow: ' + dNow);
        System.debug(logginglevel.WARN,'### dCtrStartDate: ' + dCtrStartDate);
        System.debug(logginglevel.WARN,'### iCtrTerm: ' + iCtrTerm);
        
        dCtrCalculatedEndDate = dCtrStartDate.addMonths(iCtrTerm);
        iNbMonths = dNow.monthsBetween(dCtrCalculatedEndDate);
        
        System.debug(logginglevel.WARN,'### dCtrCalculatedEndDate: ' + dCtrCalculatedEndDate);
        System.debug(logginglevel.WARN,'### iNbMonths: ' + iNbMonths);
        
        return string.valueof(iNbMonths);
    }
    
    
    //used for switching between '.' and ',' in currency fields
    public string getLocalCurrencyFormat(){
         return UserInfo.getLocale();
    }
         
    // Can't remove because of bug
    private class Paginator{}
    private class ProductQuerySet{}
}