/*
 * Controler class for the Quote Layout's buttons
 */
public with sharing class VFC_Quote {
    
    private final Quote quote;
    private List<Quote_PTL__c> quotePTLs;
    private AP_WrapperForSOAPGEBPricingCall wrapperGEB;
   
    
    /*
     * Constructor: initialisation method
     */
    public VFC_Quote(ApexPages.StandardController stdController) {
            
        //Fetch all the fields we'll need on the Quote    
        this.quote = fetchQuoteByQuoteId(stdController.getRecord().Id);
        
        //Fetch the Quote_PTL__c related to the quote
        this.quotePTLs = fetchQuotePTLByQuoteId(stdController.getRecord().Id);
        
        //Init the Handler for future SAP Call
        this.wrapperGEB = new AP_WrapperForSOAPGEBPricingCall();
            
    }
    
    
    /*
     * Work out and save the "Saut de tranche" on the Quote
     * By calling the SAP BAPI WebService
     */
    public PageReference calculateAndSaveSautDeTranche(){ 
        
        try{
       
            Decimal sautDeTranche = wrapperGEB.calculateSautDeTrancheFromBAPI(quote, quotePTLs);
            
            quote.Saut_de_tranche__c = String.valueOf(sautDeTranche);
            update quote;
            
            return new PageReference('/'+ quote.Id);
            
         }catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.addMessages(e);
         }
         
         return null;
    }

    /*
     * Action back from Error Page
     */
    public PageReference back(){  
        return new PageReference('/'+ quote.Id);
    }
    
    private Quote fetchQuoteByQuoteId(Id quoteId){   
         return [SELECT Id, Name, T_LAT_ApprovalRequested__c, Call_SAP_Display_Mode_Done__c, CreatedBy.Id, RecordTypeId, Opportunity.Project_Type__c, Opportunity.Project_Sub_Type__c, Opportunity.Project_market_type__c, Opportunity.RecordTypeId, 
                   OpportunityId, Pricebook2Id, Opportunity.Contrat__c, Opportunity.Account.Customer_Group__c, Opportunity.Account.Channel__c, Opportunity.Account.Sub_Channel__c, Opportunity.Account.Group_Code__c, Opportunity.Account.Customer_group_1__c,
                   Opportunity.Account.Customer_group_2__c, Opportunity.Account.Customer_group_4__c, Opportunity.Account.Customer_group_5__c, Opportunity.DO_AccountNumber__c,
                   Opportunity.Account.Activity_Domain__r.ExternalID__c, Opportunity.Contrat__r.PTL__r.Name, Scale__c, Opportunity.Account.Parent.AccountNumber, Ger_Consumption__c,
                   Bottle_Leasing_Type__c, Opportunity.Groupe__c, Type_of_charge__c, Payment_spread_SAP__c, DO_Groupement__r.AccountNumber, Estimated_Capacity__c, Sum_PTL_Consumption__c,
                   Product_scale__c, VAT_code__c, Tax_model__c, Shipping_Condition__c, Opportunity.Account_Owner__r.AccountNumber, Opportunity.Predecessor__r.AccountNumber, Opportunity.Client_Type__c
            FROM Quote 
            WHERE Id=:quoteId
        ];
    }
    
    private List<Quote_PTL__c> fetchQuotePTLByQuoteId(Id quoteId){
        return [
           SELECT Id, PTL_Name__c
           FROM Quote_PTL__c 
           WHERE Quote__c = :quoteId
        ];
    }
}