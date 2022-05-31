trigger InventoryPricingAfterUndelete on Inventory_Pricing__c (after undelete) {
    if (Trigger.IsAfter && Trigger.IsUndelete) {
        System.Debug('##>>> Inventory_Pricing__c.AfterUndelete : BEGIN <<< run by ' + UserInfo.getName());
        List<Inventory_Pricing__c> lIP = Trigger.new;
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPDate')){
            AP_InventoryPricing_01.recoverLastIPDate(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUndelete : BYPASS recoverLastIPDate <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Inventory_Pricing__c.recoverLastIPBDPrice')){
            AP_InventoryPricing_01.recoverLastIPBDPrice(lIP);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing__c.AfterUpdate : BYPASS recoverLastIPBDPrice <<< run by ' + UserInfo.getName());
        }
                   
        System.Debug('##>>> Inventory_Pricing__c.AfterUndelete : END <<<');
    } 
    else{
        System.Debug('##>>> Inventory_Pricing__c.AfterUndelete : FALSE TRIGGER <<<');
    }

}