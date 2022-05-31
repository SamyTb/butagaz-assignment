public class VFC_InventoryPricingArticle01 {
	
	public Inventory_Pricing_Article__c oIPArticle {get;set;}
	public ID oIPBrandId {get;set;}
	public ID iIPId {get;set;}
    ApexPages.StandardController oControl; 
	 
	 public VFC_InventoryPricingArticle01(ApexPages.StandardController oControl_in){
	 	this.oControl=oControl_in;   
	 	oIPArticle=(Inventory_Pricing_Article__c)oControl.getRecord();
	 	oIPBrandId = [SELECT Inventory_Pricing_Brand__c FROM Inventory_Pricing_Article__c WHERE id=:oIPArticle.Id].Inventory_Pricing_Brand__c;
	 	iIPId = [SELECT Inventory_pricing__c FROM Inventory_Pricing_Brand__c WHERE id=:oIPBrandId].Inventory_pricing__c;
	 	system.debug('iIPdId: ' + iIPId);	 	
	 }
	
	    /* return the IPBrand page */
    public PageReference getIPPage(){
    	
        return new PageReference('/apex/VFP_InventoryPricing?id=' + iIPId);
    }



}