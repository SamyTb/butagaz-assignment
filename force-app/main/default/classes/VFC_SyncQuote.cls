public class VFC_SyncQuote{
    public Quote oQuote {get;set;}
    ApexPages.StandardController control;   
    
    public VFC_SyncQuote(ApexPages.StandardController control_in){
        control=control_in;        
        oQuote=(Quote)control.getRecord();      
    }
    
    public pageReference back() {
        return new PageReference('/' + oQuote.Id);
    }
    
    public pageReference launchSyncQuote(){
      
        
        if (oQuote.T_LAT_ApprovalRequested__c){
            Opportunity oOpp = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id = :oQuote.OpportunityID];

            if(oOpp.Id != null){
                oOpp.SyncedQuoteId = oQuote.Id;
                update oOpp;
            }
            return new PageReference('/' + oQuote.Id);
        
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, Label.VFP_SyncQuote_Error);
            ApexPages.addMessage(myMsg );
            return null;
        }
    }     
}