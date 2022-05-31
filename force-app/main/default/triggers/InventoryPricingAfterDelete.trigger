trigger InventoryPricingAfterDelete on Inventory_Pricing__c (after delete) {
    if (Trigger.IsAfter && Trigger.IsDelete) {
        System.Debug('##>>> Inventory_Pricing__c.AfterDelete : BEGIN <<< run by ' + UserInfo.getName());
        List<Inventory_Pricing__c> lIP = Trigger.old;
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPDate')){
            AP_InventoryPricing_01.recoverLastIPDate(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterDelete : BYPASS recoverLastIPDate <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPBDPrice')){
            AP_InventoryPricing_01.recoverLastIPBDPrice(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BYPASS recoverLastIPBDPrice <<< run by ' + UserInfo.getName());
        } 
                  
        System.Debug('##>>> Inventory_Pricing__c.AfterDelete : END <<<');
    } 
    else{
        System.Debug('##>>> Inventory_Pricing__c.AfterDelete : FALSE TRIGGER <<<');
    }
}