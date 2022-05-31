public class VFC_CommandeUsagesArticle01 {

	public CUSAGE_Article__c oCUSAGESArticle {get;set;}
	public ID iCUSAGESId {get;set;}
    ApexPages.StandardController oControl; 
	 
	 public VFC_CommandeUsagesArticle01(ApexPages.StandardController oControl_in){
	 	this.oControl=oControl_in;   
	 	oCUSAGESArticle=(CUSAGE_Article__c)oControl.getRecord();
	 	iCUSAGESId = [SELECT CUSAGES__c FROM CUSAGE_Article__c WHERE id=:oCUSAGESArticle.id].CUSAGES__c;
	 	system.debug('iCUSAGESId: ' + iCUSAGESId);	 	
	 }
	
	    /* return the CUSAGES page */
    public PageReference getCUSAGESPage(){
    	
        return new PageReference('/apex/VFP_CommandesUsages?id=' + iCUSAGESId);
    }


}