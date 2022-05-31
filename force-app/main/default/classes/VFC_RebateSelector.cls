public class VFC_RebateSelector {
    
    public Account oAccount {get;set;}
    public Opportunity oOpty {get;set;}
    public Quote oQuote {get;set;}

    private Pricebook2 pricebook;
    private Id pricebookId;
    
    public string productScale {get;set;}
    
    public Boolean bInitSAPDone {get;set;}
    
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Date creditPriceDate {get;set;}
    
    public String duration {get; set;}
    
    public String inputNoteTitle{get;set;}
    public String inputNoteTextArea{get;set;}
    
    //List<PTL__c> selectedPTLs = new List<PTL__c>();
    
    public List<QuoteLineItem> currentQLIs {get; set;}
    public List<wrappedQLI> targetQLIs {get; set;}
    List<QuoteLineItem> selectedTargetQLIsToUpdate = new List<QuoteLineItem>();
    List<QuoteLineItem> selectedTargetQLIsToInsert = new List<QuoteLineItem>();
    public List<Quote_PTL__c> qptlList {get; set;}
    
    /** The Wrapper For SOAP Rebate Call**/
    public AP_WrapperForSOAPCallRebate wrapperForSOAPCall;
    /** The object which stores data for controller **/
    public AP_WrapperForSOAPCallRebate.AP_WrapperDataForController dataForController;
    public List<AP_VFMessage> listAPVFMessage {get; set;} // List of Messages to add on makeStatusMessages
    
    public Boolean showForm {get; set;}
    public Boolean onlyShowMode {get; set;}
    public String rebateType {get; set;}   // Possible values : REBATE, CREDIT
    //public Boolean accountOriginalGeneralDeletionFlagValue {get; set;}

    public Boolean runCalloutAction {get; set;}  // Flag to check if records have been correctly created and that we can perform the BAPI Pricing callout
    
    public String selectedCreditReason {get; set;}
    public Map<String, Reason_For_Credit_Order__c> mReasonsForCreditOrder {get; set;}
    public Map<String, PricebookEntry> mapPricebookEntries {get; set;}
    public wrappedCreditProductToAdd creditProductToAdd {get; set;}
    public Set<String> contractProductsPerPTLSet {get; set;}
    
    
    public List<SelectOption> getDurations() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('12','12'));
        options.add(new SelectOption('18','18'));
       // options.add(new SelectOption('24','24'));
       if( !oAccount.isPersonAccount  || GetisGECPack () ) options.add(new SelectOption('24','24')); // SP308 202012 | MLC
        return options;
    }
    
    /*public List<SelectOption> getRCEReasons() {    // ToDo : Create field on QLI and get picklist values
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('068','Geste Commercial (à rembourser)'));
        options.add(new SelectOption('071','Geste Commercial (à déduire)'));
        return options;
    }*/
    
    public List<SelectOption> getRCEReasons(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = QuoteLineItem.Reason_For_Order__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple ){
            options.add(new SelectOption(f.getValue(),f.getLabel()));
        }
        
        return options;
    }

    public List<SelectOption> getCreditReasons(){
        List<SelectOption> optionsReasonsForCreditOrder = new List<SelectOption>();
        
        optionsReasonsForCreditOrder.add(new SelectOption('', ' --'+System.Label.none_label+'-- '));

        // Get Reasons for credit order related to the current activity domain
        mReasonsForCreditOrder = new Map<String, Reason_For_Credit_Order__c>();
        for (Reason_For_Credit_Order__c oRFCO : [SELECT Id, ExternalID__c, Name, Activity_Domain__c, GEC_Product_Family__c, GEB_Product_Family__c
                                            FROM Reason_For_Credit_Order__c
                                            WHERE Activity_Domain__c includes (: string.valueof(oAccount.Activity_Domain__r.ExternalID__c))
                                            ORDER BY Name ASC]){
            
            mReasonsForCreditOrder.put(oRFCO.ExternalID__c, oRFCO);
            optionsReasonsForCreditOrder.add(new SelectOption(oRFCO.ExternalID__c, oRFCO.Name));
        }

        return optionsReasonsForCreditOrder;
    }

    // Get list of product families associated with the selected credit order reason from the credit order reasons map
    public List<SelectOption> getProductFamilyOptions() {

        String families = '';
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ' --'+System.Label.none_label+'-- '));

        System.debug(logginglevel.WARN,'### mReasonsForCreditOrder = '+ mReasonsForCreditOrder);
        System.debug(logginglevel.WARN,'### selectedCreditReason = '+ selectedCreditReason);
        if( mReasonsForCreditOrder == null || String.isBlank(selectedCreditReason) ) return null;

        if(oAccount.Activity_Domain__r.ExternalID__c == 41){        
            families = mReasonsForCreditOrder.get(selectedCreditReason).GEB_Product_Family__c;
        }else if(oAccount.Activity_Domain__r.ExternalID__c == 42){
            families = mReasonsForCreditOrder.get(selectedCreditReason).GEC_Product_Family__c;
        }
        List<String> lstFamilies = families.split(';');
        System.debug(logginglevel.WARN,'### lstFamilies = '+ lstFamilies);
        for (String oFamily : lstFamilies){
            options.add(new SelectOption(oFamily, oFamily));
        }
        return options;
    }

    // Get list of QPTLs associated with the quote
    public List<SelectOption> getQPTLOptions() {

        List<SelectOption> options = new List<SelectOption>();
        
        for (Quote_PTL__c oQPTL : qptlList){
            options.add(new SelectOption(oQPTL.PTL_Name__c, oQPTL.PTL_Name__c));
        }
        return options;
    }
    
   /*public static Map<Id,Account> GetCompteSuperieur{
    List<Account> options = new List<SelectOption>();
        if(accounts==null){
            accounts = new Map<Id,Account>([Select Id,Name From Account]); 
            System.debug('Querying Accounts');
        }
        System.debug('Returning Accounts');
        return accounts;
    
}*/
    
    public VFC_RebateSelector(ApexPages.standardcontroller stdController) {
        
        bInitSAPDone = false;
        
        try{            
            this.listAPVFMessage = new List<AP_VFMessage>();
            
            if(ApexPages.currentPage().getParameters().containsKey('rebateType')) {
                this.rebateType = ApexPages.currentPage().getParameters().get('rebateType');
            }
            creditPriceDate = system.Today();

            // ZGZM and ZABG contract type excluded in the query so we don't hit duplicate error on OPTL creation
            this.oAccount = [
                SELECT Id, Name, isPersonAccount, PersonContactId, Activity_Domain__c, AccountNumber, City_Postal_Code__c, Payment_method__c, Payment_Time_Code__c, Scale__c, Shipping_Condition__c, TVA__c, 
                    Type_de_relation__c, ADV_Deletion_Flag__c, General_Deletion_Flag__c, Channel__c, Sub_Channel__c, GR_PRODUCT_SCALE__c, Activity_Domain__r.ExternalID__c, Parent.AccountNumber, Compte_Superieur__c,
                    ( SELECT Id, Scale__c FROM PTL1__r WHERE ADV_deletion_flag__c = false AND Gal_deletion_flag__c = false ), 
                    ( SELECT Id FROM Contacts ),  // ToDo : Filter on Contact_Marketing__c = True / False ?
                    ( SELECT Id FROM Contracts WHERE ( EndDate = null OR EndDate >: system.Today() ) AND PTL__r.ADV_deletion_flag__c = false AND PTL__r.Gal_deletion_flag__c = false and Contract_Label__c NOT IN ('ZGZM', 'ZABG') )
                FROM Account
                WHERE Id=:stdController.getRecord().Id
            ];
            
            //this.accountOriginalGeneralDeletionFlagValue = this.oAccount.General_Deletion_Flag__c;
            this.creditProductToAdd = new wrappedCreditProductToAdd(this);
            targetQLIs = new List<wrappedQLI>();

            this.showForm = true;
            
            this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### ApexPages.currentPage().getParameters().containsKey(onlyShowMode) = '+ ApexPages.currentPage().getParameters().containsKey('onlyShowMode') );
            System.debug(logginglevel.WARN,'### ApexPages.currentPage().getParameters().get(onlyShowMode) = '+ ApexPages.currentPage().getParameters().get('onlyShowMode') );
            if(ApexPages.currentPage().getParameters().containsKey('onlyShowMode')) {
                this.onlyShowMode = ( ApexPages.currentPage().getParameters().get('onlyShowMode') == '1' ? true : false);
            }
            
            // if URL parameters contain Quote Id it means the quote has already been created and we called this page to post the rebates to SAP
            if(ApexPages.currentPage().getParameters().containsKey('quoteId')) {
                this.oQuote = new Quote( Id = ApexPages.currentPage().getParameters().get('quoteId') );

                this.oQuote = getcurrentQuote();

                // Find the rebate type
                System.debug(logginglevel.WARN,'### this.oQuote.Client_Reenlistment__c = '+ this.oQuote.Client_Reenlistment__c );
                if( this.oQuote.Client_Reenlistment__c == 'Commercial offer' && this.oQuote.Type_de_remuneration__c != 'Avoir' ){
                    this.rebateType = 'REBATE';
                }else if( this.oQuote.Client_Reenlistment__c == 'Credit' || (this.oQuote.Client_Reenlistment__c == 'Commercial offer' && this.oQuote.Type_de_remuneration__c == 'Avoir') ){
                    this.rebateType = 'CREDIT';
                }
                System.debug(logginglevel.WARN,'### this.rebateType = '+ this.rebateType );

                currentQLIs = getcurrentQLIs();
                System.debug(logginglevel.WARN,'### this.oQuote = '+ this.oQuote );
                System.debug(logginglevel.WARN,'### currentQLIs = '+ currentQLIs );
                
                this.oOpty = new Opportunity( Id = this.oQuote.OpportunityId );
                oOpty = getcurrentOpty();
                
                /*// Check if the quote has already been sent to SAP. If so, we'll prevent the user to send it again
                if( this.oQuote.Sent_To_SAP__c ) {
                    throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Remises déjà envoyées vers SAP'});
                }*/
                
                // Initialize the wrapper
                this.wrapperForSOAPCall = new AP_WrapperForSOAPCallRebate(this.oQuote);
            }
            
            
        } catch(AP_CRMException e){
            this.showForm = false;
            this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
        }
        
        this.startDate = system.Today();
        this.endDate = system.Today() + 30;
        
    }
    
    public PageReference initializePage(){
        // Checks before creating the opty and rebates
        
        if( !onlyShowMode ){
            if( (oAccount.ADV_Deletion_Flag__c || oAccount.General_Deletion_Flag__c ) && (this.rebateType != 'CREDIT')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce compte n\'est pas actif.'));
            }
            /*if (oAccount.PTL1__r.size() == 0) {  // We cannot use the direct link between the account and its PTLs because there are no PTL linked to the account in case of renter
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce compte n\'a pas de PTL actif.'));
            }*/
            if ((oAccount.Contracts.size() == 0) && (this.rebateType != 'CREDIT')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce compte n\'a pas de contrat ou de PTL actif.'));
            }
            if ( oAccount.General_Deletion_Flag__c && this.rebateType == 'CREDIT' ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous ne pouvez pas créer d\'avoir sur un compte sur lequel est apposé un témoin de suppression général.'));
            }
        }
        
        System.debug(logginglevel.WARN,'### oQuote = '+ oQuote);
        System.debug(logginglevel.WARN,'### onlyShowMode = '+ onlyShowMode);
        System.debug(logginglevel.WARN,'### this.onlyShowMode = '+ this.onlyShowMode);
        
        // Checks before posting to SAP
        if( oQuote != null && onlyShowMode ){
            
            if( (oQuote != null) && (this.rebateType == 'CREDIT')&&(oQuote.Opportunity.StageName == 'Closed Lost')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous ne pouvez pas envoyer l\'avoir vers SAP lorsque le statut est perdu.'));
            }
            if( oQuote != null && onlyShowMode && !oQuote.isSyncing ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce devis n\'est pas synchronisé.'));
            }
            if( oQuote != null && onlyShowMode && !oQuote.T_LAT_Approved__c ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce devis n\'est pas encore approuvé.'));
            }
            // Check if the quote has already been sent to SAP. If so, we'll prevent the user from sending it again
            if( alreadySentToSAP() ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Remises déjà envoyées vers SAP.'));
            }
        }
        if( ApexPages.hasMessages() ) this.showForm = false;
        
        return null;
    }
    
    public Opportunity getcurrentOpty(){
        //if(this.oOpty == null){
            
            this.oOpty = [
                SELECT  
                    Id,
                    recordtypeId,
                    SyncedQuoteId,
                    Name,
                    DO_Activity_Domain__c,
                    Project_market_type__c,
                    Project_Type__c,
                    Project_Sub_Type__c,
                    T_Pack__c,
                    StageName, 
                    AccountId, 
                    DO_AccountNumber__c,
                    CloseDate, 
                    Project_City_Postal_Code__c, 
                    DO_City_Postal_Code__c, 
                    Assign__c, 
                    OwnerId,
                    DO_Payment_method__c, 
                    Installation_date__c,
                    Client_Type__c,
                    Energy_Source__c,
                    Avez_vous_votre_Kbis__c,
                    Pricebook2Id,
                    Reason__c
                FROM Opportunity 
                WHERE Id=:this.oOpty.Id LIMIT 1];
        //}
        
        return this.oOpty;
    }
    
    public Quote getcurrentQuote(){
        //if(this.oQuote == null){
            
            this.oQuote = [
                SELECT  
                    Id,
                    QuoteNumber,
                    IsSyncing,
                    OpportunityId,
                    Name,
                    DO_Payment_method__c,
                    Product_Scale__c,
                    Scale__c,
                    Client_Reenlistment__c,
                    Shipping_Condition__c,
                    VAT_code__c,
                    Contract_Duration__c,
                    Pricebook2Id,
                    ExpirationDate,
                    Date_de_cotation__c,
                    Date_debut_offre__c,
                    ContactId,
                    T_LAT_Approved__c,
                    Latitude_Message__c,
                    Sent_To_SAP__c,
                    Opportunity.Account.AccountNumber,
                    Opportunity.Account.Mandataire__r.ExternalID__c,
                    Opportunity.Account.Activity_Domain__r.ExternalID__c,
                  Opportunity.StageName,
                    RecordTypeId,
                    Credit_Comment_For_Customer__c,
                    /*Reason_For_Credit_Order__c,*/
                    Credit_Price_Date__c,
                    Opportunity.Reason__c,
                    Type_de_remuneration__c,
                    Remise_en_euro__c,
                    Action_Commerciale__c,
                    Action_Commerciale__r.Fixed_Price__c,
                    Action_Commerciale__r.Locked_Price__c,
                    Action_Commerciale__r.Locked_Price_1_Year__c,
                    Action_Commerciale__r.Locked_Price_2_Years__c,
                    Action_Commerciale__r.Locked_Price_3_Years__c
                FROM Quote 
                WHERE Id=:this.oQuote.Id LIMIT 1];
        //}
        
        return this.oQuote;
    }

    public List<QuoteLineItem> getcurrentQLIs(){
        //if(currentQLIs == null){
            currentQLIs = new List<QuoteLineItem>();
        
            for(QuoteLineItem qli : [
                SELECT  
                    Id,
                    UnitPrice, 
                    Quote_PTL__c, 
                    Quote_PTL__r.PTL_Name__c, 
                    QuoteId, 
                    Quantity,
                    Quantity_Unit__c,
                    PricebookEntryId,
                    PricebookEntry.Product2Id,
                    PricebookEntry.Product2.IsActive,
                    PriceBookEntry.Product2.ProductCode,
                    PricebookEntry.Product2.Name,
                    PricebookEntry.Product2.Family,
                    PricebookEntry.Product2.Capacity__c,
                    PricebookEntry.Product2.Sub_Type__c,
                    PricebookEntry.Product2.UseGerConsumption__c,
                    PricebookEntry.Product2.MonthlyPriceDisplay__c,
                    Remise_Grpt_one_shot_HT__c, 
                    Consignation_Grpt_one_shot_HT__c, 
                    Group_Commercial_Rebate_HT__c, 
                    Group_Commercial_Rebate_TTC__c, 
                    Group_Cyclical_Rebate_HT__c, 
                    Group_Cyclical_Rebate_TTC__c, 
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
                    Price_List_HT__c,
                    Price_List_TTC__c,
                    VAT_Percentage__c,
                    Pricing_Unit__c,
                    Amount_Unit__c,
                    Reason_For_Order__c,
                    Rebate_Starting_Date__c,
                    Credit_Quantity__c,
                    Credit_Unit_Price_HT__c,
                    Credit_Total_Price_HT__c,
                    Remise_Post_Offre_HT__c,
                    Remise_Post_Offre_TTC__c,
                    Got_From_SAP__c
                FROM QuoteLineItem 
                WHERE QuoteId=:this.oQuote.Id]){
                
                // For rebateType == REBATE, we're only interested in the 'Produit' product family.
                // For rebateType == CREDIT, we want all products
                if(rebateType == 'REBATE'){
                    if(qli.PricebookEntry.Product2.Family == 'Produit')
                        currentQLIs.add(qli);
                }else if(rebateType == 'CREDIT'){
                    currentQLIs.add(qli);
                }
            }
        //}
        return currentQLIs;
    }
    
    
    public List<wrappedQLI> getTargetQLIs(){
        System.debug(logginglevel.WARN,'### getTargetQLIs.targetQLIs = ' + targetQLIs);
        System.debug(logginglevel.WARN,'### getTargetQLIs.currentQLIs = ' + currentQLIs);
        if( targetQLIs == null || targetQLIs.isEmpty() ){
            targetQLIs = new List<wrappedQLI>();
            
            for (QuoteLineItem oQLI : currentQLIs) {
                targetQLIs.add(new wrappedQLI(this, oQLI, null, null, null));
                System.debug(logginglevel.WARN,'### getTargetQLIs.targetQLIs2 = ' + targetQLIs);
            }
        }
        return targetQLIs;
    }
    
    public class wrappedQLI{
        private VFC_RebateSelector parent;
        public QuoteLineItem qli {get; set;}
        
        public Decimal tempRCE {get; set;}
        public String tempReasonForOrder {get; set;}
        public Decimal tempRCONJ {get; set;}
        public Date tempStartDate {get; set;}
        public Integer tempDuration {get; set;}
        
        public String tempPTL {get; set;}
        public String tempProductFamily {get; set;}
        public String tempProduct {get; set;}
        public Decimal tempCreditQuantity {get; set;}
        public Decimal tempCreditUnitPriceHT {get; set;}
        public Decimal tempCreditTotalPriceHT {get; set;}

        public Integer counter{get;set;}
        
        /*This is the contructor method. When we create a new cQLI object we pass a 
        QuoteLineItem that is set to the q property.*/
        public wrappedQLI(VFC_RebateSelector parent, QuoteLineItem q, String pPTLName, String pProductFamily, String pProductName){
            this.parent = parent;
            qli = q;
            
            if(q.Id != null){  // Line from SAP
                tempPTL = qli.Quote_PTL__r.PTL_Name__c;
                tempProductFamily = qli.PricebookEntry.Product2.Family;
                tempProduct = qli.PricebookEntry.Product2.Name;
            }else if(q.Id == null){  // Manual line
                tempPTL = pPTLName;
                tempProductFamily = pProductFamily;
                tempProduct = pProductName;
            }

            tempRCE = 0.00;
            tempReasonForOrder = '';
            tempRCONJ = 0.00;
            tempStartDate = system.Today();
            tempDuration = null;
            
            tempCreditQuantity = qli.Credit_Quantity__c;
            tempCreditUnitPriceHT = qli.Credit_Unit_Price_HT__c;
            if( tempCreditQuantity != null && tempCreditUnitPriceHT != null )
                tempCreditTotalPriceHT = tempCreditQuantity * tempCreditUnitPriceHT;
        }
    }

    public void removeTargetCreditRow(){
        System.debug(logginglevel.WARN,'### parent.tarApexpages.currentpage().getParameters().get(index) = ' + Apexpages.currentpage().getParameters().get('index'));
        Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
        targetQLIs.remove(indexVal - 1);
        System.debug(logginglevel.WARN,'### parent.targetQLIs.size() = ' + targetQLIs.size());
        System.debug(logginglevel.WARN,'### parent.targetQLIs = ' + targetQLIs);
    }

    public class wrappedCreditProductToAdd{
        private VFC_RebateSelector parent;
        
        public String selectedPTL {get; set;}
        
        public String tempSelectedProductFamily {get;}
        public String selectedProductFamily {get;set;}
        
        public SelectOption[] productOptions {get;set;}
        public String selectedProduct {get;set;}
        public String productValue {get;set;}

        public Decimal tempCreditQuantity {get; set;}
        public Decimal tempCreditUnitPriceHT {get; set;}
        public Decimal tempCreditTotalPriceHT {get;}
        
        /*This is the contructor method.*/
        public wrappedCreditProductToAdd(VFC_RebateSelector parent){
            this.parent = parent;

            selectedProduct = '';
            tempCreditQuantity = 0;
            tempCreditUnitPriceHT = 0.00;
        }

        /*public String getProductFamilyValue(){
            return selectedProductFamily;
        }*/

        // Changing the product family value will replace the product options
        public void setTempSelectedProductFamily(String value){
            System.debug(logginglevel.WARN,'### setTempSelectedProductFamily : value = ' + value);
            System.debug(logginglevel.WARN,'### parent.contractProductsPerPTLSet = ' + parent.contractProductsPerPTLSet);
            
            // Fill productOptions with products related to the selected product family
            productOptions = new SelectOption[]{};
            //productOptions.add(new SelectOption('', ' --'+System.Label.none_label_male+'-- '));

            // In case of Product or Redevance family option, only show Products got from SAP from Pricing BAPI callout
            for(String mapKey : parent.mapPricebookEntries.keyset()){
                System.debug(logginglevel.WARN,'### parent.mapPricebookEntries.get(mapKey).Product2.Family = ' + parent.mapPricebookEntries.get(mapKey).Product2.Family);
                
                if( parent.mapPricebookEntries.get(mapKey).Product2.Family == value ){
                    System.debug(logginglevel.WARN,'### parent.mapPricebookEntries.get(mapKey).Product2.ProductCode = ' + parent.mapPricebookEntries.get(mapKey).Product2.ProductCode);
                    // In case of Product or Redevance family option for GEC, only show Products got from SAP from Pricing BAPI callout
                    if( parent.oAccount.Activity_Domain__r.ExternalID__c == 42 && (value == 'Produit' || value == 'Redevance') ){
                        
                        if(parent.contractProductsPerPTLSet.contains( this.selectedPTL + '#' + parent.mapPricebookEntries.get(mapKey).Product2.ProductCode )){
                            productOptions.add(new SelectOption(parent.mapPricebookEntries.get(mapKey).Product2.ProductCode, parent.mapPricebookEntries.get(mapKey).Product2.Name));
                        }
                    }else{
                        productOptions.add(new SelectOption(parent.mapPricebookEntries.get(mapKey).Product2.ProductCode, parent.mapPricebookEntries.get(mapKey).Product2.Name));
                    }
                }
            }

            System.debug(logginglevel.WARN,'### productOptions = ' + productOptions);
            selectedProductFamily = value;
        }

        public PageReference add(){

            // Check a product has been selected
            if( this.selectedProduct == null ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Veuillez sélectionner un article.'));
                return null;
            }

            // Check the PriceBookEntry hasn't already been added for this PTL
            // The business asked to remove this check. We now can send the same product for the same PTL multiple times
            /*if(parent.targetQLIs != null){
                for (VFC_RebateSelector.wrappedQLI oQLI : parent.targetQLIs) {
                    System.debug(logginglevel.WARN,'### oQLI.tempPTL = ' + oQLI.tempPTL);
                    System.debug(logginglevel.WARN,'### this.selectedPTL = ' + this.selectedPTL);
                    System.debug(logginglevel.WARN,'### oQLI.tempProduct = ' + oQLI.tempProduct);
                    System.debug(logginglevel.WARN,'### this.selectedProduct = ' + this.selectedProduct);
                    if( oQLI.tempPTL == this.selectedPTL && oQLI.tempProduct == this.selectedProduct ){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Vous avez déjà ajouté cet article sur ce PTL.'));
                        return null;
                    }
                }
            }*/

            // In case of GEC, if product family == Product or Redevance, we want to get the existing QLI got from SAP. Otherwise create a new QLI
            if( parent.oAccount.Activity_Domain__r.ExternalID__c == 42 && (this.selectedProductFamily == 'Produit' || this.selectedProductFamily == 'Redevance') ){
                for (QuoteLineItem oQLI : parent.currentQLIs) {
                    if( oQLI.Quote_PTL__r.PTL_Name__c == this.selectedPTL && oQLI.PriceBookEntry.Product2.ProductCode == this.selectedProduct ){
                        oQLI.Credit_Quantity__c = tempCreditQuantity;
                        oQLI.Credit_Unit_Price_HT__c = tempCreditUnitPriceHT;
                        parent.targetQLIs.add(new wrappedQLI(this.parent, oQLI, null, null, null));
                        break;
                    }
                }
            }else{
                // Get the Id of the QPTL corresponding to the PTL selected
                Id qptlId = null;
                for (Quote_PTL__c oqptl: parent.qptlList) {
                    System.debug(logginglevel.WARN,'### oqptl.PTL_Name__c = ' + oqptl.PTL_Name__c);
                    System.debug(logginglevel.WARN,'### this.selectedPTL = ' + this.selectedPTL);
                    if(oqptl.PTL_Name__c == this.selectedPTL){
                        qptlId = oqptl.Id;
                    }
                }

                // Get the Id of the PriceBookEntry corresponding to the selected product
                Id pbeId = parent.mapPricebookEntries.get(this.selectedProduct).Id;
                System.debug(logginglevel.WARN,'### pbeId = ' + pbeId);

                // Create a QLI instance and add it to the targetQLIs list
                QuoteLineItem oQLI = new QuoteLineItem(QuoteId = parent.oQuote.Id, PricebookEntryId = pbeId, Quote_PTL__c = qptlId,
                    RCE_Rebate_TTC__c = 0, Quantity = 1, UnitPrice = 1, Credit_Quantity__c = tempCreditQuantity, Credit_Unit_Price_HT__c = tempCreditUnitPriceHT, 
                    Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'CDP', Got_From_SAP__c = false
                );
                System.debug(logginglevel.WARN,'### oQLI = ' + oQLI);

                parent.targetQLIs.add(new wrappedQLI(parent, oQLI, this.selectedPTL, this.selectedProductFamily, this.selectedProduct));
                System.debug(logginglevel.WARN,'### parent.targetQLIs.size() = ' + parent.targetQLIs.size());
                System.debug(logginglevel.WARN,'### parent.targetQLIs = ' + parent.targetQLIs);
            }

            return null;
        }
    }
    
    
    public void initRebatesFromSAP(){
        
        // We don't want to init QLIs from SAP in case of GEB
        if(oAccount.Activity_Domain__r.ExternalID__c == 41){
            bInitSAPDone = true;
            return;
        }

        try{
            // Call BAPI Pricing on mode 2 to initialize products and prices from SAP
            System.debug(logginglevel.WARN,'### oQuote : '+ oQuote);
            VFC06_Quote_InitQuoteLineItems initQLICtrlr = new VFC06_Quote_InitQuoteLineItems(new ApexPages.StandardController(oQuote));
            System.debug(logginglevel.WARN,'### initQLICtrlr : '+ initQLICtrlr);
            initQLICtrlr.initQuoteLineItems();
            //currentQLIs = initQLICtrlr.selectQuoteLineItemsQuery();
            currentQLIs = getcurrentQLIs();
            System.debug(logginglevel.WARN,'### currentQLIs : ' + currentQLIs);
            
            // Fill product codes in a Set so we can lookup for their existence later on
            contractProductsPerPTLSet = new Set<String>();
            for(QuoteLineItem oQli : currentQLIs){
                contractProductsPerPTLSet.add(oQli.Quote_PTL__r.PTL_Name__c + '#' + oQli.PriceBookEntry.Product2.ProductCode);
            }

            oOpty = getcurrentOpty();
            oQuote = getcurrentQuote();
            targetQLIs = getTargetQLIs();
            System.debug(logginglevel.WARN,'### targetQLIs : ' + targetQLIs);
            
            // Update opty with synced quote
            oOpty.SyncedQuoteId = oQuote.Id;
            update new List<Opportunity> { oOpty };
            
        } catch(Exception e){
            this.showForm = false;
            this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return;
        }
        
        bInitSAPDone = true;
        
        System.debug(logginglevel.WARN,'### oOpty.SyncedQuoteId : ' + oOpty.SyncedQuoteId);
        
    }
    
    
    public void createRelatedRecords(){
        
        //DateTime d = datetime.now();
        //String dateStr = d.format('dd/MM/yyyy HH:mm:ss');
        string contractNumber = '';
        Id contractId = null;
        Id projectPostalCode = null;
        String projectMarketSubType = null;
        string paymentSpread = '';
        //Id ptlId = null;
        string fiscalClass = '';
        string shippingCondition = '';
        string sPrefix = '';
        string projectSubType = '';
        string optyReason = '';
        string clientReenlistment = '';
        string clientType = '';

        string emballagePivot = '';
        Decimal consoEstimeeButane_10 = 0;
        Decimal consoEstimeeButane_13 = 0;
        Decimal consoEstimeeCubeBut = 0;
        Decimal consoEstimeeCubeProd = 0;
        Decimal consoEstimeePropane_13 = 0;
        Decimal consoEstimeePropane_35 = 0;
        Decimal consoEstimeeProp_Carb = 0;
        
        List<Id> ptlIdList = new List<Id>();
        List<PTL__c> ptlList = new List<PTL__c>(); 
        
        runCalloutAction = false;
        
        SavePoint svp = Database.setSavepoint();
        
        try{
            
            // Get the current contract
            /*List<Contract> contractList = [select Id, ExternalID__c, ContractNumber, Scale_c__c, Condition_for_Payment_Package_Code__c, Abonnement_Spread_Code__c, PTL__c, PTL__r.Fiscal_class_PTL__c, PTL__r.Shipping_Condition__c,
                                            PTL__r.Emballage_Pivot__c, PTL__r.Consommation_estimee_Butane_10__c, PTL__r.Consommation_estimee_Butane_13__c, PTL__r.Consommation_estimee_Cube_But__c,
                                            PTL__r.Consommation_estimee_Cube_Prop__c, PTL__r.Consommation_estimee_propane_13__c, PTL__r.Consommation_estimee_Propane_35__c, PTL__r.Consommation_estimee_Prop_Carb__c,
                                            PTL__r.City_Postal_Code__c, PTL__r.Market_Sub_Type_F__c
                                            from Contract
                                            where AccountId =: oAccount.Id 
                                            and Contract_End_Flag_Filter__c = 1
                                            and PTL__r.ADV_deletion_flag__c = false 
                                            and PTL__r.Gal_deletion_flag__c = false
                                            and Contract_Label__c NOT IN ('ZGZM', 'ZABG')
                                            ];*/

            Id oAccountId = oAccount.Id;
            String where_clause = '';

            if (rebateType == 'REBATE'){
                where_clause = 'and Contract_End_Flag_Filter__c = 1 and PTL__r.ADV_deletion_flag__c = false and PTL__r.Gal_deletion_flag__c = false';
            }

            List<Contract> contractList = Database.query( 'select Id, ExternalID__c, ContractNumber, Scale_c__c, Condition_for_Payment_Package_Code__c, Abonnement_Spread_Code__c, PTL__c, PTL__r.Fiscal_class_PTL__c, PTL__r.Shipping_Condition__c, '+
                                                    +'PTL__r.Emballage_Pivot__c, PTL__r.Consommation_estimee_Butane_10__c, PTL__r.Consommation_estimee_Butane_13__c, PTL__r.Consommation_estimee_Cube_But__c, '+
                                                    +'PTL__r.Consommation_estimee_Cube_Prop__c, PTL__r.Consommation_estimee_propane_13__c, PTL__r.Consommation_estimee_Propane_35__c, PTL__r.Consommation_estimee_Prop_Carb__c, '+
                                                    +'PTL__r.City_Postal_Code__c, PTL__r.Market_Sub_Type_F__c '+
                                                    +'from Contract '+
                                                    +'where AccountId =: oAccountId '+
                                                    +'and Contract_Label__c NOT IN (\'ZGZM\', \'ZABG\') '+
                                                    + where_clause +
                                                    + ' ORDER BY EndDate DESC NULLS FIRST'
                                                    );
            // LIMIT 1
            
            for (Contract oCont: contractList) {
                contractNumber = oCont.ExternalID__c;    //  /!\ What if multiple PTLs ???
                contractId = oCont.Id;
                productScale = oCont.Scale_c__c;
                if(oCont.PTL__c != null){
                    projectPostalCode = oCont.PTL__r.City_Postal_Code__c;
                    projectMarketSubType = oCont.PTL__r.Market_Sub_Type_F__c;
                }
                
                // To get the payment spread, we need to perform several checks
                if( !String.isBlank(oCont.Condition_for_Payment_Package_Code__c) ){  // Check if payment spread on Propane
                    paymentSpread = oCont.Condition_for_Payment_Package_Code__c;
                }else if( oCont.Scale_c__c == 'ECOCFT' && !String.isBlank(oCont.Abonnement_Spread_Code__c) ){  // Check if payment spread on subscription (ECOCFT)
                    paymentSpread = oCont.Abonnement_Spread_Code__c;
                }else{  // Otherwise we get the payment spread from the account
                    paymentSpread = oAccount.Payment_Time_Code__c;
                }
                
                //ptlId = oCont.PTL__c;
                fiscalClass = oCont.PTL__r.Fiscal_class_PTL__c;
                shippingCondition = oCont.PTL__r.Shipping_Condition__c;

                if(oAccount.Activity_Domain__r.ExternalID__c == 41){
                    if(oCont.PTL__r.Emballage_Pivot__c != null){
                        emballagePivot = oCont.PTL__r.Emballage_Pivot__c.right(3);
                    }
                    
                    consoEstimeeButane_10 = oCont.PTL__r.Consommation_estimee_Butane_10__c;
                    consoEstimeeButane_13 = oCont.PTL__r.Consommation_estimee_Butane_13__c;
                    consoEstimeeCubeBut = oCont.PTL__r.Consommation_estimee_Cube_But__c;
                    consoEstimeeCubeProd = oCont.PTL__r.Consommation_estimee_Cube_Prop__c;
                    consoEstimeePropane_13 = oCont.PTL__r.Consommation_estimee_propane_13__c;
                    consoEstimeePropane_35 = oCont.PTL__r.Consommation_estimee_Propane_35__c;
                    consoEstimeeProp_Carb = oCont.PTL__r.Consommation_estimee_Prop_Carb__c;
                }
                
                if(!ptlIdList.contains(oCont.PTL__c)){
                    ptlIdList.add(oCont.PTL__c);
                    ptlList.add( new PTL__c(Id = oCont.PTL__c) );
                }
            }
            
            if(rebateType == 'REBATE'){
                sPrefix = 'OpRemise - ';
                projectSubType = 'GC';
                optyReason = 'Autres';
                clientReenlistment = 'Commercial offer';
            }else if (rebateType == 'CREDIT'){
                sPrefix = 'OpAvoir - ';
                projectSubType = 'Credit';
                optyReason = 'Autres';   // selectedCreditReason;
                clientReenlistment = 'Credit';
            }
            
            /*// Get the first related PTL we find
            List<PTL__c> ptlList = [select Id, Fiscal_class_PTL__c, Shipping_Condition__c
                                            from PTL__c
                                            where Id =: ptlIdList
                                            and ADV_deletion_flag__c = false and Gal_deletion_flag__c = false
                                            ];
            for (PTL__c oPTL: ptlList) {
                // We'll get the first record to get the info to feed the quote
                fiscalClass = oPTL.Fiscal_class_PTL__c;
                shippingCondition = oPTL.Shipping_Condition__c;
                break;
            }*/
            
            
            // Match the scale with the pack
            string optyPack = '';
            if(oAccount.Activity_Domain__r.ExternalID__c == 42){
                map<string, string> mPack = new map<string, string>{'CART1' => 'IDEO', 'CART2' => 'SOLO', 'ECOCFT' => 'ECOCFT', 'V1DOM' => 'OldContracts', 'V1LIB' => 'OldContracts', 'V1PK' => 'OldContracts', 'V1PRO' => 'PRO', 'V1GR' => 'PRO'};
                
                // SHP 482 le bareme optimo etant cart1 , ici je test le compte supérieur du compte afin de forcer le pack à Optimo
                if( String.IsNotBlank(oAccount.Compte_Superieur__c) &&  mPack.get(productScale) =='IDEO' ){
                    optyPack = 'OPTIMO';
                }else{
                    System.debug(logginglevel.WARN,'### optyPack : ' + optyPack);
                    optyPack = mPack.get(productScale);
                }
            }

            /*string optyPack = '';
            switch on oPTL.Scale__c {
                when 'CART1' {
                    optyPack = 'IDEO';
                }   
                when 'CART2' {
                    optyPack = 'SOLO';
                }
                when 'ECOCFT' {
                    optyPack = 'ECOCFT';
                }
                when 'V1DOM', 'V1LIB', 'V1PK' {
                    optyPack = 'OldContracts';
                }
                when else {
                    optyPack = 'PRO';  // To check once PRO is implemented
                }
            }*/
            
            
            // Fetch the customSettings related to the Quote/Opty Record type
            Map<String, RecordTypes_OpportunityToQuote__c> csRTOptyToQuote = RecordTypes_OpportunityToQuote__c.getAll();
            //build the map with the id
            map<Id,Id> mapRTQuoteIdRTOptyId = new map<Id,Id>();
            map<Id,Id> mapPBOptyId = new map<Id,Id>();
            
            // Feed the map
            for (String s : csRTOptyToQuote.keySet()) {
                RecordTypes_OpportunityToQuote__c rt = csRTOptyToQuote.get(s);
                if( rt != null && rt.QuoteRecordType__c instanceOf Id && rt.QuotePriceBookId__c instanceOf Id ){
                    mapRTQuoteIdRTOptyId.put(rt.OpportunityRecordType__c, rt.QuoteRecordType__c);
                    mapPBOptyId.put(rt.OpportunityRecordType__c, rt.QuotePriceBookId__c);
                }
            }

            if(oAccount.Activity_Domain__r.ExternalID__c == 42){
                clientType = 'Owner';
            }else if(oAccount.Activity_Domain__r.ExternalID__c == 41){
                clientType = oAccount.Channel__c;
            }
            
            /*// Remove deletion flag so we're not blocked by an Apex control preventing closed accounts to be modified.
            // We'll set the flag back to its original value when we're done creating the related records
            if( rebateType == 'CREDIT' && this.accountOriginalGeneralDeletionFlagValue == true ){
                oAccount.General_Deletion_Flag__c = false;
                update oAccount;
            }*/

            // Set Apex context flag to true so we can bypass control preventing closed accounts to be modified
            oAccount.T_Apex_Context__c = true;
            update oAccount;
            
            // Add an Opty
            Opportunity oRelatedOpty = new Opportunity(
                Name = sPrefix + oAccount.Name,  // + '-' + dateStr,
                DO_Activity_Domain__c = oAccount.Activity_Domain__c,
                Project_market_type__c = (oAccount.isPersonAccount ? 'DOM' : 'PRO'),
                Project_market_subtype__c = projectMarketSubType,
                Project_Type__c = 'FIDE',
                Project_Sub_Type__c = projectSubType,   // Geste Co 
                T_Pack__c = optyPack,
                StageName = 'Negotiation/Review', 
                Opportunity_Reason__c = optyReason,  // 'Autres',
                Reason__c = '',
                AccountId = oAccount.Id, 
                DO_AccountNumber__c = oAccount.AccountNumber,
                Contrat__c = contractId,
                Number__c = contractNumber,
                Project_Start_Date__c = Date.today(), 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = projectPostalCode,
                DO_City_Postal_Code__c = oAccount.City_Postal_Code__c, 
                Assign__c = false, 
                OwnerId = UserInfo.getUserId(),
                DO_Payment_method__c = oAccount.Payment_method__c, 
                Installation_date__c = Date.today() + 15,
                Client_Type__c = clientType,  //'Owner',  // (oAccount.Type_de_relation__c == 'Locataire' ? 'Renter' : 'Owner'),
                Energy_Source__c = 'Propane',
                Current_Provider__c = 'Butagaz',
                /*Project_market_subtype__c = (oAccount.isPersonAccount ? 'Domestique' : 'Industrie'),*/
                Channel__c = 'Outcoming call',
                LeadSource = 'Commercial',
                Avez_vous_votre_Kbis__c = 'Oui'
            );
            insert new List<Opportunity> { oRelatedOpty };
            oOpty = oRelatedOpty;
            System.debug(logginglevel.WARN,'### oRelatedOpty.Id : ' + oRelatedOpty.Id);
            
            
            // Add OPTLs
            List <Opportunity_PTL__c> optlList = new List <Opportunity_PTL__c> ();
            //for(PTL__c oPTL1 : oAccount.PTL1__r){
            for(PTL__c oPTL : ptlList){
                Opportunity_PTL__c optyPTL = new Opportunity_PTL__c(
                    Opportunity__c = oOpty.Id, 
                    PTL__c = oPTL.Id
                );
                optlList.add(optyPTL);
                
                //productScale = oPTL1.Scale__c;
            }
            if(optlList.size() > 0) insert optlList;
            
            // Fetch a contact related to the account to link to the quote for B2B customers
            Id b2bContactId;
            if(!oAccount.isPersonAccount){
                for(Contact oCon : oAccount.Contacts){ 
                    b2bContactId = oCon.Id;
                }
            }
            
            // Fetch the Quote RT corresponding to the Opty
            Id rtOptyId = [SELECT RecordTypeId FROM Opportunity WHERE Id =: oRelatedOpty.Id].RecordTypeId;
            String rtID = String.valueOf(mapRTQuoteIdRTOptyId.get(rtOptyId));
            // Fetch the PriceBook corresponding to the Opty
            String pbID = String.valueOf(mapPBOptyId.get(rtOptyId));
            //SHP 482 :  on récupere l'id du groupement optimo
            Id rtAccCSId;
            if(optyPack == 'OPTIMO')                               
            {               
               
               if (oAccount.Compte_Superieur__c!=null && oAccount.Compte_Superieur__c !=''){
                     rtAccCSId = [SELECT id  FROM Account WHERE ExternalId__c  =: oAccount.Compte_Superieur__c].Id;
                }
               
                System.debug(logginglevel.WARN,'### rtAccCSId : ' + rtAccCSId);
            }
            // Add a Quote
            Quote oRelatedQuote = new Quote(
                OpportunityId = oOpty.Id,
                recordtypeId = rtID,
                Name = sPrefix + oAccount.Name,  // + '-' + dateStr,
                DO_Payment_method__c = oAccount.Payment_method__c,
                Product_Scale__c = productScale,
                Scale__c = oAccount.Scale__c,
                Client_Reenlistment__c = clientReenlistment,   // 'Commercial offer',
                Shipping_Condition__c = shippingCondition,
                VAT_code__c = fiscalClass,
                Payment_spread__c = paymentSpread,  // oAccount.Payment_Time_Code__c,  // paymentSpread,
                Contract_Duration__c = '5',  //(oRelatedOpty.Client_Type__c == 'Owner' ? '5' : '1'),
                Pricebook2Id = pbID,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                ContactId = (oAccount.isPersonAccount ? oAccount.PersonContactId : b2bContactId),
                Emballage_Pivot__c = emballagePivot,
                Consommation_estimee_Butane_10__c = consoEstimeeButane_10,
                Consommation_estimee_Butane_13__c = consoEstimeeButane_13,
                Consommation_estimee_Cube_But__c = consoEstimeeCubeBut,
                Consommation_estimee_Cube_Prop__c = consoEstimeeCubeProd,
                Consommation_estimee_propane_13__c = consoEstimeePropane_13,
                Consommation_estimee_Propane_35__c = consoEstimeePropane_35,
                Consommation_estimee_Prop_Carb__c = consoEstimeeProp_Carb,
                DO_Groupement__c = rtAccCSId 
                //T_LAT_Approved__c = true,
            );
            insert new List<Quote> { oRelatedQuote };
            oQuote = oRelatedQuote;
            
            // Manage QPTLs
            //List<Quote_PTL__c> qptlList = [SELECT Id, Name, Quote__c, Opportunity_PTL__c, Estimated_Consumption__c FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optlList];
            qptlList = [SELECT Id, Name, Quote__c, Opportunity_PTL__c, Estimated_Consumption__c, PTL_Name__c FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optlList];
            for (Quote_PTL__c oqptl: qptlList) {
                oqptl.Estimated_Consumption__c = 1;
                oqptl.RPTL_Purposes__c = 'Heating';
            }
            update qptlList;

            // Get Pricebook
            if (pbID != null){
                this.pricebook = [SELECT Id, Name FROM Pricebook2 WHERE Id=:pbID];
                this.pricebookId = this.pricebook.Id;
            } else {
                this.pricebook = null;
                this.pricebookId = null;
            }

            // Load a map containing all PriceBookEntries related to the current PriceBook so we don't have to consume several SOQL queries
            mapPricebookEntries = new Map<String, PricebookEntry>();
            for (PricebookEntry prd:[SELECT Id, Product2.Id, Product2.Name, Product2.Family, 
                        Product2.Capacity__c, Product2.Sub_Type__c, Product2.Payment_type__c, 
                        Product2.ProductCode, Product2.UseGerConsumption__c, Product2.UseConnectionType__c,  
                        Product2.UseConsumerTarget__c, Product2.is_crea__c, Product2.is_not_pack__c, 
                        Product2.Tank_Type__c, Product2.Tank_protection__c, Product2.IsActive, 
                        Product2.noSAP__c, UnitPrice,  Product2.Auto_Add__c, Product2.MonthlyPriceDisplay__c,
                        Product2.external_ID__c, Product2.Standardized_Form__c, Product2.CapacityMin__c, Product2.CapacityMax__c, Product2.Technical_Action_Type__c, Product2.Tank_Pumping__c
                    FROM PricebookEntry
                    WHERE Pricebook2Id =: this.pricebookId
                    AND Product2.Family IN ('Produit', 'Redevance', 'Service', 'Coût logistique', 'Geste commercial')
                    AND Product2.Payment_type__c != 'Consignation'
                    ORDER BY Product2.Family, Product2.Name
            ]){
                mapPricebookEntries.put(prd.Product2.ProductCode, prd);
            }

            /*// Revert the General_Deletion_Flag__c back to its original value
            if( rebateType == 'CREDIT' && this.accountOriginalGeneralDeletionFlagValue == true ){
                oAccount.General_Deletion_Flag__c = this.accountOriginalGeneralDeletionFlagValue;
                update oAccount;
            }*/
            
            runCalloutAction = true;
            
        } catch(Exception e){
            //this.showForm = false;
            //this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
            runCalloutAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(svp);
            //return false;
        }
        
        //return true;
    }
    
    public PageReference redirectToLAT_MAIN(){
        
        Decimal creditSum = 0;

        try{
            
            //Decimal vatAmount = 0.00;
            
            //if(oQuote.VAT_code__c == '1'){
            //  vatAmount = Decimal.valueOf(AP_PricingUtilities.getCustomSettingValue('GER_Accessories_Metropole_VAT'));
            //}else{
            //  vatAmount = Decimal.valueOf(AP_PricingUtilities.getCustomSettingValue('GER_Accessories_Corsica_VAT'));
            //}
            
            System.debug(logginglevel.WARN,'### Enter Save method : ' + targetQLIs);
            
            // Check Comment is not missing in case of Credit rebate type
            if( rebateType == 'CREDIT' && (String.isBlank(inputNoteTitle) || String.isBlank(inputNoteTextArea)) ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner un commentaire.'));
                return null;
            }

            // Save target QLIs before calculating latitudes
            for (wrappedQLI tqli: targetQLIs) {
                tqli.qli.RCE_Rebate_TTC__c = tqli.tempRCE;
                //tqli.qli.RCE_Rebate_HT__c = calculateHT(tqli.tempRCE, vatAmount);
                tqli.qli.Reason_For_Order__c = tqli.tempReasonForOrder;
                tqli.qli.Cyclical_Rebate_TTC__c = tqli.tempRCONJ;
                //tqli.qli.Cyclical_Rebate_HT__c = calculateHT(tqli.tempRCONJ, vatAmount);
                tqli.qli.Rebate_Starting_Date__c = tqli.tempStartDate;
                tqli.qli.Cyclical_Rebate_Months__c = tqli.tempDuration;

                tqli.qli.Credit_Quantity__c = tqli.tempCreditQuantity;
                tqli.qli.Credit_Unit_Price_HT__c = tqli.tempCreditUnitPriceHT;

                if( tqli.qli.Credit_Quantity__c != null && tqli.qli.Credit_Unit_Price_HT__c != null )
                    creditSum += tqli.qli.Credit_Quantity__c * tqli.qli.Credit_Unit_Price_HT__c;
            }

            // Check there's at least one rebate to save, otherwise prevent user from going further
            if( rebateType == 'CREDIT' && creditSum == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez saisir un montant d\'avoir et l\'ajouter à la liste des avoirs à créer.'));
                return null;
            }
            
            // Update QLIs got from SAP and insert manually added QLIs
            selectedTargetQLIsToUpdate.clear();
            selectedTargetQLIsToInsert.clear();
            for(wrappedQLI owQLI : targetQLIs){
                if(owQLI.qli.Id != null){
                    System.debug(logginglevel.WARN,'### Update QLI : ' + owQLI.qli);
                    selectedTargetQLIsToUpdate.add(owQLI.qli);
                }else{
                    System.debug(logginglevel.WARN,'### Insert QLI : ' + owQLI.qli);
                    selectedTargetQLIsToInsert.add(owQLI.qli);
                }
            }
                
            update selectedTargetQLIsToUpdate;
            insert selectedTargetQLIsToInsert;
            
            
            // Save Note related to the quote
            if( !String.IsBlank(inputNoteTitle) && !String.IsBlank(inputNoteTextArea) ){
                note n = new note();
                n.parentId = oQuote.Id;
                n.title = inputNoteTitle;
                n.body = inputNoteTextArea;
                n.isPrivate = false;
                insert n;
            }

            // Update quote so the comment and the credit price date are saved
            oQuote.Credit_Price_Date__c = creditPriceDate;
            // We need to make an exception for credit reasons 068 (Geste commercial (à rembourser)) and 071 (Geste commercial (à déduire)) so the quote goes into GEB RE latitude flow.
            if( selectedCreditReason == '068' || selectedCreditReason == '071' ){
                oQuote.Client_Reenlistment__c = 'Commercial offer';
                oQuote.Type_de_remuneration__c = 'Avoir';
                oQuote.Remise_en_euro__c = creditSum;
            }
            update oQuote;

            // Update Opportunity so the Opty Reason is updated with the Order reason
            oOpty.SyncedQuoteId = oQuote.Id;
            oOpty.Reason__c = selectedCreditReason;
            update oOpty;
            
        } catch(Exception e){
            //this.showForm = false;
            //this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
            //return false;
            //AP_PricingUtilities.showApexErrors(e);
        }
        
        // ToDo : Remove this if after debug
        //if(rebateType == 'REBATE'){
       PageReference pr = new PageReference('/apex/Submit_Latitude');
        pr.getParameters().put('Id', oQuote.Id);
        /*pr.getParameters().put('DEBUG','false');
        pr.getParameters().put('RequestApproval','true');*/
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.
        return pr;
        /*}else{
            PageReference redirect = new PageReference('/' + oQuote.Id);
            redirect.setRedirect(true);
            return redirect;
        }*/
    }
    
    /*private Decimal calculateHT(Decimal priceTTC, Decimal TVA){
        return priceTTC / (1 + TVA/100);
    }*/
    
    /*private Decimal calculateTTC(Decimal priceHT, Decimal TVA){
        return priceHT * (1 + TVA/100);
    }*/
    
    public Boolean GetisGECPack(){      
        if (
               (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM IDEO')) 
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM LOC IDEO SOLO'))
            || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO'))
            ){
            return true;
        } else {
            return false;
        }
    }
    
    public Boolean GetisGECECOCFT(){      
        if (
             (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT')) 
            ){  
            return true;
        } else {
            return false;
        }
    }
    
    public Boolean GetisGECSansRCONJ(){      
        if (
             (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM OPTIMO')) 
              || (this.oQuote.RecordTypeId == AP_PricingUtilities.getQuoteRecordTypeValue('GEC DOM ECOCFT'))
            ){  
            return true;
        } else {
            return false;
        }
    }
    
    /*public PageReference simulateLatitude(){
        
        try{
            // Save target QLIs before calculating latitudes
            for (wrappedQLI tqli: targetQLIs) {
                //tqli.qli.RCE_Rebate_TTC__c = tqli.tempRCEDeduction;
                //tqli.qli.RCE_Rebate_TTC__c = tqli.tempRCEReimbursement;   // ToDo : Create new field on QLI ? Only one RCE rebate at a time
                tqli.qli.RCE_Rebate_TTC__c = tqli.tempRCE;
                tqli.qli.Reason_For_Order__c = tqli.tempReasonForOrder;
                tqli.qli.Cyclical_Rebate_TTC__c = tqli.tempRCONJ;
                tqli.qli.Rebate_Starting_Date__c = tqli.tempStartDate;
                tqli.qli.Cyclical_Rebate_Months__c = tqli.tempDuration;
            }
            
            selectedTargetQLIs.clear();
            for(wrappedQLI owQLI : targetQLIs)
                selectedTargetQLIs.add(owQLI.qli);
                
            update selectedTargetQLIs;  // Rename to TargetQLIsToUpdate ?
            
            
            // Save Note related to the quote
            note n = new note();
            n.parentId = oQuote.Id;
            n.title = inputNoteTitle;
            n.body = inputNoteTextArea;
            n.isPrivate = false;
            insert n;
            
        } catch(Exception e){
            //this.showForm = false;
            //this.onlyShowMode = false;
            System.debug(logginglevel.WARN,'### '+ e);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
            //return false;
            //AP_PricingUtilities.showApexErrors(e);
        }
        
        
        // Call the Flow
        Map<String, Object> params = new Map<String, Object>();
        params.put('Quote_Id', oQuote.Id);
        params.put('DEBUG', false);
        params.put('RequestApproval', false);
        Flow.Interview.LAT_MAIN latmainFlow = new Flow.Interview.LAT_MAIN(params);
        latmainFlow.start();
         
        // Obtain the results
        String returnValue = (String) latmainFlow.getVariableValue('ReturnValue');
        System.debug(logginglevel.WARN,'### Flow returned : '+ returnValue);
        
        
        return this.refresh();
    }*/
    
    
    public PageReference postToSAP(){
        
        if( alreadySentToSAP() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Remises déjà envoyées vers SAP.'));
            //return this.refresh();
            return null;
        }

        if(!isBackOfficeUser()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous devez faire partie du groupe Back Office. Veuillez vous rapprocher de votre service contrat.'));
            return null;
        }
        
        // Post rebate(s) to SAP
        try{
            //if(this.getAllSelectedProductsReadyForSap()){
                System.debug(logginglevel.WARN,'### currentQLIs2 = '+ currentQLIs );
                this.dataForController = this.wrapperForSOAPCall.postRebatesToSAP(currentQLIs);
                
                //Update the Opty and Quote with data got from SAP
                //if ( !this.dataForController.errorGotFromSAP ){
                
                //System.debug(logginglevel.WARN,'### this.dataForController.returnFieldsList = '+ this.dataForController.returnFieldsList );
                if( this.dataForController.exControl == 'OK' ){
                    // Update Opty's StageName and Opportunity_Won_Substage__c
                    System.debug(logginglevel.WARN,'### this.wrapperForSOAPCall.rebateTypes : ' + this.wrapperForSOAPCall.rebateTypes);
                    //oOpty.Name += this.wrapperForSOAPCall.rebateTypes;
                    oOpty.Name = oOpty.Name.substring(0, oOpty.Name.indexOf('-')) + this.wrapperForSOAPCall.rebateTypes + oOpty.Name.substring(oOpty.Name.indexOf('-'), oOpty.Name.length());
                    oOpty.StageName = 'Closed Won';
                    oOpty.Opportunity_Won_Substage__c = 'Data validated by BO';
                    if(rebateType == 'REBATE') oOpty.Reason__c = '068';
                    update oOpty;
                    
                    // Update Quote Sent_To_SAP__c so the quote cannot be sent again
                    oQuote.Name = oQuote.Name.substring(0, oQuote.Name.indexOf('-')) + this.wrapperForSOAPCall.rebateTypes + oQuote.Name.substring(oQuote.Name.indexOf('-'), oQuote.Name.length());
                    oQuote.Sent_To_SAP__c = true;
                    update oQuote;
                    
                //    }
                } else if ( this.dataForController.atLeastOneRebateCreatedInSAP ){  // if at least one rebate has successfully been created in SAP, we flag the quote so it cannot be sent again to SAP
                    oQuote.Sent_To_SAP__c = true;
                    update oQuote;
                }
                this.listAPVFMessage.clear();
                this.listAPVFMessage.addAll(this.dataForController.listAPVFMessage);
            //}    
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
        //this.wrapperForSOAPCall.oBapiTracker.Request__c = String.valueOf(this.wrapperForSOAPCall.webserviceSOAP.request_x);
        //this.wrapperForSOAPCall.oBapiTracker.Response3__c = String.valueOf(this.wrapperForSOAPCall.webserviceSOAP.response_x);
        this.wrapperForSOAPCall.oBapiTracker.User__c = UserInfo.getUserId() ;
        if (this.wrapperForSOAPCall.sStoreTracker.toLowercase() == 'true') upsert this.wrapperForSOAPCall.oBapiTracker;
        
        
        return this.refresh();
        //return null;
    }

    public PageReference initCreditTable(){
        // if credit reason is changed, we want to clear all products added to the target list
        if(targetQLIs != null) targetQLIs.clear();

        this.creditProductToAdd = new wrappedCreditProductToAdd(this);
        return null;
    }
    
    private boolean alreadySentToSAP(){
        return this.oQuote.Sent_To_SAP__c;
    }

    public static Boolean isBackOfficeUser(){
        Id userId = UserInfo.getUserId();
        List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];
        
        if(members != null && !members.isEmpty()){
            return true;
        }
        
        return false;
    }
    
    public PageReference redirectToQuoteDetail(){
        PageReference redirect = new PageReference('/' + oQuote.Id);
        redirect.setRedirect(true);
        return redirect;
    }
    
    public PageReference refresh(){
        
        this.makeStatusMessages();
        
        return null;
    }
    
    
    private void makeStatusMessages(){
        /*// Display Pricebook information
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
        }*/
        
        // Add listAPVFMessage 
        for(AP_VFMessage m : this.listAPVFMessage){
            ApexPages.addMessage(new ApexPages.Message(m.getSeverityFromType(), m.summary, m.details));
        }
    }

    /*
    // Save attachment v1
    public PageReference SaveAttachment(){
        Attachment objAttachment = new Attachment ();
        objAttachment.ParentId = oQuote.Id;
        objAttachment.Body = attachment.body;
        objAttachment.Name = attachment.Name;
        insert objAttachment;
        return null;
    }
    
    // Save attachment v2
    public Attachment attachment {
        get {
            if (attachment == null) attachment = new Attachment();
            return attachment;
        }
        set;
    }
        
    public PageReference upload() {
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = oQuote.Id; // the record the file is attached to
        attachment.IsPrivate = true;
        
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Erreur lors de la sauvegarde de la pièce jointe'));
            return null;
        } finally {
            attachment.body = null; // clears the viewstate
            attachment = new Attachment(); 
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Pièce jointe sauvegardée avec succès'));
        return null;
    }
    */
    
}