trigger InventoryPricingAfterInsert on Inventory_Pricing__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Inventory_Pricing__c.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Inventory_Pricing__c> lIP = Trigger.new;
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPDate')){
            AP_InventoryPricing_01.recoverLastIPDate(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterInsert : BYPASS recoverLastIPDate <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPBDPrice')){
            AP_InventoryPricing_01.recoverLastIPBDPrice(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterInsert : BYPASS recoverLastIPBDPrice <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('PTL.copyIPFromPredecessor')){
            AP_PTL_01.copyIPBFromPredecessor(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterInsert : BYPASS copyIPBFromPredecessor <<< run by ' + UserInfo.getName());
        }          
        
        if (PAD.canTrigger('Inventory_Pricing__c.copyIPBrandsToPTL')){
        	System.Debug('##>>> Inventory_Pricing__c.AfterInsert : copyIPBrandsToPTL <<< run by ' + UserInfo.getName());
        	AP_InventoryPricing_01.copyIPBrandsToPTL(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterInsert : BYPASS copyIPBrandsToPTL <<< run by ' + UserInfo.getName());
        }
            
        System.Debug('##>>> Inventory_Pricing__c.AfterInsert : END <<<');
    } 
    else{
        System.Debug('##>>> Inventory_Pricing__c.AfterInsert : FALSE TRIGGER <<<');
    }
}