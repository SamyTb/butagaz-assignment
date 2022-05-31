trigger InventoryPricingAfterUpdate on Inventory_Pricing__c (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Inventory_Pricing__c> lIP = Trigger.new;
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPDate')){
			if(!AP_InventoryPricing_01.hasAlreadyUpdatedIP()){
        		AP_InventoryPricing_01.setAlreadyUpdatedIP(true);
        		AP_InventoryPricing_01.recoverLastIPDate(lIP);
        	}          	        	
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BYPASS recoverLastIPDate <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPBDPrice')){
			if(!AP_InventoryPricing_01.hasAlreadyUpdatedIPBDPrice()){
        		AP_InventoryPricing_01.setAlreadyUpdatedIPBDPrice(true);
        		AP_InventoryPricing_01.recoverLastIPBDPrice(lIP);
        	}
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BYPASS recoverLastIPBDPrice <<< run by ' + UserInfo.getName());
        }       
        
        if (PAD.canTrigger('Inventory_Pricing__c.copyIPBrandsToPTL')){
        	System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : copyIPBrandsToPTL <<< run by ' + UserInfo.getName());
        	if(!AP_InventoryPricing_01.hasAlreadyUpdatedIPBrands()){
        		AP_InventoryPricing_01.setAlreadyUpdatedIPBrands(true);
        		AP_InventoryPricing_01.copyIPBrandsToPTL(lIP);
        	}
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BYPASS copyIPBrandsToPTL <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : END <<<');
    } 
    else{
        System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : FALSE TRIGGER <<<');
    }
}