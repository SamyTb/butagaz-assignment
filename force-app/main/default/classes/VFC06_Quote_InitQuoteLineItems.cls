public without sharing class VFC06_Quote_InitQuoteLineItems {
    private Apexpages.StandardController stdController;
        
    private AP_WrapperForSOAPCallPricing wrapperPricing;
    private AP_WrapperForSOAPCallPricing.AP_WrapperDataForController response_x;
    
    private final Quote currentQuote;
    private List<QuoteLineItem> currentQuoteLineItems;
    private List<Quote_PTL__c> currentQuotePTL;
    
    public AP_CRMException lastException;

    public VFC06_Quote_InitQuoteLineItems(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.currentQuote = [
            SELECT Id, Name, T_LAT_ApprovalRequested__c, Call_SAP_Display_Mode_Done__c, CreatedBy.Id, RecordTypeId, Opportunity.Project_Type__c, Opportunity.Project_Sub_Type__c, Opportunity.Project_market_type__c, Opportunity.RecordTypeId, 
                   OpportunityId, Pricebook2Id, Opportunity.Contrat__c,Opportunity.DO_Customer_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Sub_Channel__c, Opportunity.Account.Group_Code__c,Opportunity.Account.Customer_Group__c, Opportunity.Account.Customer_group_1__c,
                   Opportunity.Account.Customer_group_2__c, Opportunity.Account.Customer_group_4__c, Opportunity.Account.Customer_group_5__c, Opportunity.DO_AccountNumber__c,
                   Opportunity.Account.Activity_Domain__r.ExternalID__c, Opportunity.Contrat__r.PTL__r.Name, Scale__c, Opportunity.Account.Parent.AccountNumber, Ger_Consumption__c,
                   Bottle_Leasing_Type__c, Opportunity.Groupe__c, Type_of_charge__c, Payment_spread_SAP__c, DO_Groupement__r.AccountNumber, Estimated_Capacity__c, Sum_PTL_Consumption__c,
                   Product_scale__c, VAT_code__c, Tax_model__c, Shipping_Condition__c, Opportunity.Account_Owner__r.AccountNumber, Opportunity.Predecessor__r.AccountNumber, Client_Type__c,Opportunity.Client_Type__c,Opportunity.Compte_Optimo__c
            FROM Quote 
            WHERE Id=:stdController.getRecord().Id
        ];
        this.currentQuotePTL = this.selectQuotePTLQuery();
        this.currentQuoteLineItems = this.selectQuoteLineItemsQuery();
        
        this.wrapperPricing = new AP_WrapperForSOAPCallPricing(this.currentQuote, this.currentQuote.Pricebook2Id);
       /*
        system.debug('#### MLCCuurentQuote_wrapperPricing : ' + this.wrapperPricing);
        system.debug('#### MLCCuurentQuote_currentQuote : ' + this.currentQuote);
        system.debug('#### MLCCuurentQuote_currentQuotePTL : ' + this.currentQuotePTL);
*/
        //system.debug('#### MLCCuurentQuote_currentQuoteLineItems : ' + this.currentQuoteLineItems);
            
    }
    
    /** Query to get current QuotePTL of the quote **/
    public List<Quote_PTL__c> selectQuotePTLQuery(){
        List<Quote_PTL__c> listQuotePTL = [
           SELECT  Id,
                    Name,
                    PTL_Name__c, 
                    PTL_Label__c,
                    Opportunity_PTL__r.Name,
                    Opportunity_PTL__r.PTL_Department__c, 
                    RPTL_Purposes__c, 
                    Estimated_Capacity__c, 
                    Estimated_Consumption__c
           FROM Quote_PTL__c 
           WHERE Quote__c = :this.currentQuote.Id
        ];
        return listQuotePTL;
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
                // Pricebook fields (Page 1)
                PricebookEntryId,
                PricebookEntry.Product2Id,
                PricebookEntry.Product2.IsActive,
                PriceBookEntry.Product2.ProductCode,
                PricebookEntry.Product2.Name,
                PricebookEntry.Product2.Family,
                PricebookEntry.Product2.Capacity__c,
                PricebookEntry.Product2.Sub_Type__c,
                PricebookEntry.Product2.UseGerConsumption__c,
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

                RCE_Rebate_TTC__c, 
                RCE_Rebate_HT__c, 

                Transport_Increase_TTC__c,
                Transport_Increase_HT__c,

                Price_List_HT__c,
                Price_List_TTC__c,
                VAT_Percentage__c,
                
                Pricing_Unit__c,
                Amount_Unit__c,
                
                Ger_consumption__c,
                
                //Backup
                Group_Commercial_Rebate_HT_Old__c, 
                Group_Commercial_Rebate_TTC_Old__c, 

                Group_Cyclical_Rebate_HT_Old__c, 
                Group_Cyclical_Rebate_TTC_Old__c, 
                //Group_Cyclical_Rebate_lenght_in_Days_Old__c,
                Group_Cyclical_Rebate_lenght_months_Old__c,
                
                Commercial_Rebate_TTC_Old__c, 
                Commercial_Rebate_HT_Old__c,

                Cyclical_Rebate_TTC_Old__c, 
                Cyclical_Rebate_HT_Old__c, 

                RCE_Rebate_TTC_Old__c, 
                RCE_Rebate_HT_Old__c, 

                Transport_Increase_TTC_Old__c,
                Transport_Increase_HT_Old__c,

                Price_List_HT_Old__c,
                Price_List_TTC_Old__c,
                
                // Erwan 20181217
                TICPE_Amount_HT__c,
				TICPE_Amount_TTC__c,
				Remise_Post_Offre_HT__c,
				Remise_Post_Offre_TTC__c,
				
				// Erwan 20191203
				Bio_Product__c,
				Bio_Option_Amount_HT__c,
				Bio_Option_Amount_TTC__c

            FROM QuoteLineItem 
            WHERE QuoteId=:this.currentQuote.Id
        ];
        return listQuoteLineItems;
    }
    
    public PageReference initQuoteLineItems(){
        try{
            if(this.currentQuote.Call_SAP_Display_Mode_Done__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'L\'initialisation des produits SAP a déjà été faite dans le devis'));
                return null;
            }
            
            //Check the approval process of Latitute, if it's done it will be impossible to change a locket Quote
            if(this.currentQuote.T_LAT_ApprovalRequested__c){
                throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + System.Label.quote_locked});
            }

            
            //Check if the Mode 2 (display) is available
            if(this.currentQuote.Opportunity.Project_Type__c.equals('CREA') && !this.currentQuote.Opportunity.Client_Type__c.equals('Renter')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.pricing_mode2_unavailable, ''));
                return null;
            }
            
            //Check Business rules for required fields needed to do callout Pricing
            AP_BusinessControls p = new AP_BusinessControls(this.currentQuote, this.currentQuotePTL);
            p.checkMandatoryOfInputCommonParameters('2');
            p.checkMandatoryFieldsOfInputDeliveryPointParameters(); 
            p.checkListErrors();//can throw AP_CRMException 
            
            if(this.currentQuote.Pricebook2Id != null){        
               return this.initExistingQuoteLineItemsFromSAP();    
            }else{
                // The redirection to SelectPriceBook page
                PageReference selectPriceBook = Page.VFP06_SelectPriceBook;
                selectPriceBook.getParameters().put('id', this.currentQuote.Id);
                selectPriceBook.getParameters().put('parentPageURL', ApexPages.currentPage().getUrl());
                return selectPriceBook;    
            }
        }catch(AP_CRMException e){
            this.lastException = e;
            AP_PricingUtilities.showApexErrors(e);
            return null;
        }        
    }

    /** Call SAP to get information of the current contract of the quote + Insert the QuoteLineItems on the quote **/
    public PageReference initExistingQuoteLineItemsFromSAP(){
        try{
          //this.response_x = this.wrapperPricing.displayPricingOfActiveContract();
          System.debug(' initExistingQuoteLineItemsFromSAP : '+ this.wrapperPricing.currentQuote);
          this.response_x = this.wrapperPricing.displayPricingForExistingCustomer(this.currentQuotePTL);
           System.debug(' this.response_x  : '+ this.response_x );
            if(!this.response_x.errorGotFromSAP){
              this.currentQuoteLineItems.addAll(this.response_x.listQuoteLineItemToCtrl);
              this.currentQuote.Real_CapacitySAP__c = this.response_x.realAnnualCapacityDO;
              this.currentQuote.Real_ConsumptionSAP__c = this.response_x.realAnnualConsumptionDO;
              this.currentQuote.Call_SAP_Display_Mode_Done__c = true;

              System.debug('List of QuoteLineItems : '+this.currentQuoteLineItems); 

              this.upsertQuoteLineItems();
              
              this.updateQuote();
              
              PageReference p = new PageReference('/'+ this.currentQuote.Id);
              return p;
              
          }else{
               // Add listAPVFMessage 
               for(AP_VFMessage m : this.response_x.listAPVFMessage){
                    ApexPages.addMessage(new ApexPages.Message(m.getSeverityFromType(), m.summary, m.details));
               }
               return null;
          }
        }catch(System.CalloutException e){
            this.lastException = new AP_CRMException(new List<String>{e.getMessage()});
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.network_connectivity_slow + '(' + e.getMessage() + ')', ''));
            return null;
        }catch(AP_CRMException e){
            this.lastException = e;
            AP_PricingUtilities.showApexErrors(e);
            return null;
        }
    }
    
    public PageReference retry(){
        return this.initQuoteLineItems();
    }
    
    public void upsertQuoteLineItems(){
        try{
            upsert this.currentQuoteLineItems;
        }catch(DmlException e){
            this.lastException = new AP_CRMException(new List<String>{e.getMessage()});
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + e.getMessage()});
        }
    }
    
    public void updateQuote(){
        try{
            update this.currentQuote;
        }catch(DmlException e){
            this.lastException = new AP_CRMException(new List<String>{e.getMessage()});
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + e.getMessage()});
        }
    }

    public Quote getCurrentQuote(){
        return this.currentQuote;
    }
    
    public AP_WrapperForSOAPCallPricing.AP_WrapperDataForController getResponse_x(){
        return this.response_x;
    }
}