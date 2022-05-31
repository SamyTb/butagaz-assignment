public class VFC_CDSArticles01 {
	public CDS_Article__c oCDSArticle {get;set;}
	public ID iCDSId {get;set;}
    ApexPages.StandardController oControl; 
	 
	 public VFC_CDSArticles01(ApexPages.StandardController oControl_in){
	 	this.oControl=oControl_in;   
	 	oCDSArticle=(CDS_Article__c)oControl.getRecord();
	 	iCDSId = [SELECT CDS__c FROM CDS_Article__c WHERE id=:oCDSArticle.id].CDS__c;
	 	system.debug('iCDSId: ' + iCDSId);	 	
	 }
	
	    /* return the CDS page */
    public PageReference getCDSPage(){
    	
        return new PageReference('/apex/VFP_ControleDesStocks01?id=' + iCDSId);
    }

}