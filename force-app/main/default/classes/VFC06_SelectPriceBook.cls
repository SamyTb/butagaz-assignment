public without sharing class VFC06_SelectPriceBook {

    private Apexpages.StandardController stdController;
    private final Quote currentQuote;
    public List<PriceBook2> listPriceBook;
    public Id pricebook2Id;
    public String parentUrl;
    
    public Boolean priceBookChoosed; 
    public Boolean renderSuivantButton;
    
    public VFC06_SelectPriceBook(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.currentQuote = (Quote)stdController.getRecord();
        this.listPriceBook = [SELECT Id, Name FROM PriceBook2 WHERE IsActive=true];
        this.pricebook2Id = this.currentQuote.priceBook2Id;
        this.parentUrl = ApexPages.currentPage().getParameters().get('parentPageURL');
        this.priceBookChoosed = (this.pricebook2Id != null) ? true : false;
    }
    
    //Defautl action on the page 
    public PageReference autoAssignPricebook(){
        return this.assignPriceBookToQuote();
    }
    
    //Method trying to assign automatically a pricebook to the quote depending to its recordType
    public PageReference assignPriceBookToQuote(){
        if(!this.priceBookChoosed){
            Id pricebookTarget = null;
            Id quoteRTId = this.currentQuote.RecordTypeId;
            
            List<RecordTypes_OpportunityToQuote__c> customSettings = RecordTypes_OpportunityToQuote__c.getAll().values();
            for(RecordTypes_OpportunityToQuote__c record : customSettings){
                Id currentQuoteRTId = record.QuoteRecordType__c;
                if(currentQuoteRTId == quoteRTId){
                    try{
                        pricebookTarget = record.QuotePriceBookId__c;
                        Pricebook2 existingPricebook = [SELECT Id FROM Pricebook2 WHERE Id = :pricebookTarget LIMIT 1];
                        if(existingPricebook == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.automatic_assign_pricebook_failed, ''));
                            return null;
                        }
                    }catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.automatic_assign_pricebook_failed, ''));
                        return null;
                    }                    
                    break;
                }    
            }
            if(pricebookTarget != null){
                
                this.currentQuote.pricebook2Id = pricebookTarget;
                update this.currentQuote;
                this.priceBookChoosed= true;
                return this.goToCallingPage();
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.automatic_assign_pricebook_failed, ''));
                return null;
            }
        }
        return null;
    }

    public List<SelectOption> getAvailablePriceBooks(){
        List<SelectOption> listPriceBookOptions = new List<SelectOption>();
        for(PriceBook2 p : this.listPriceBook){
            listPriceBookOptions.add(new SelectOption(p.Id, p.Name));
        }
        return listPriceBookOptions;
    }
    
    /** Buttons on the page **/
    public PageReference updatePriceBook(){
        if(this.currentQuote.priceBook2Id != null){
            update this.currentQuote;
            this.priceBookChoosed = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.pricebook_updated, ''));
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.pricebook_required_on_quote, ''));
        return null;
    }
    
    public PageReference backToQuote(){
        return this.stdController.view();
    }
    
    public PageReference goToCallingPage(){
        String parentUrl = this.parentUrl;
        if(parentUrl != null){
            return new PageReference(parentUrl);
        }else{
            return null;
        }
    }
    
    public Boolean getRenderSuivantButton(){
        return (this.priceBookChoosed && this.parentUrl != null);
    }
    
}