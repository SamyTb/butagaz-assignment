trigger InventoryPricingBrandAfterInsert on Inventory_Pricing_Brand__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Inventory_Pricing_Brand__c.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Inventory_Pricing_Brand__c> lIPB = Trigger.new;
        
        if (PAD.canTrigger('PTL.copyIPFromPredecessor')){
            AP_PTL_01.copyIPAFromPredecessor(lIPB);
        } 
        else{
            System.Debug('##>>> Inventory_Pricing_Brand__c.AfterInsert : BYPASS copyIPAFromPredecessor <<< run by ' + UserInfo.getName());
        }          
                 
        System.Debug('##>>> Inventory_Pricing_Brand__c.AfterInsert : END <<<');
    } 
    else{
        System.Debug('##>>> Inventory_Pricing_Brand__c.AfterInsert : FALSE TRIGGER <<<');
    }
}