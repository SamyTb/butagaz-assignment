public class VFC_PECArticles01 {
	public PEC_Article__c oPECArticle {get;set;}
	public ID iPECId {get;set;}
    ApexPages.StandardController oControl; 
	 
	 public VFC_PECArticles01(ApexPages.StandardController oControl_in){
	 	this.oControl=oControl_in;   
	 	oPECArticle=(PEC_Article__c)oControl.getRecord();
	 	iPECId = [SELECT Prise_en_Charge__c FROM PEC_Article__c WHERE id=:oPECArticle.id].Prise_en_Charge__c;
	 	system.debug('iPECId: ' + iPECId);	 	
	 }
	
	    /* return the PEC page */
    public PageReference getPECPage(){
    	
        return new PageReference('/apex/VFP_PriseEnCharge01?id=' + iPECId);
    }


}