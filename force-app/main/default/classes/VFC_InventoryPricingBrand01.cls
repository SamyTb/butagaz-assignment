public class VFC_InventoryPricingBrand01 {
	public Inventory_Pricing_Brand__c oIPBrand {get;set;}
	public ID iIPId {get;set;}
    ApexPages.StandardController oControl; 
	 
	 public VFC_InventoryPricingBrand01(ApexPages.StandardController oControl_in){
	 	this.oControl=oControl_in;   
	 	oIPBrand=(Inventory_Pricing_Brand__c)oControl.getRecord();
	 	iIPId = [SELECT Inventory_pricing__c FROM Inventory_Pricing_Brand__c WHERE id=:oIPBrand.id].Inventory_pricing__c;
	 	system.debug('iIPdId: ' + iIPId);	 	
	 }
	
	    /* return the IPBrand page */
    public PageReference getIPPage(){
    	
        return new PageReference('/apex/VFP_InventoryPricing?id=' + iIPId);
    }


}