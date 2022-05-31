trigger PTLAfterInsert on PTL__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        //System.Debug('##>>> PTL.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL__c> lPTL = Trigger.new;

        // Deactivate PTL from Predecessor
        if (PAD.canTrigger('PTL.deactivatPTLFromPredecessor')){
            AP_PTL_01.deactivatPTLFromPredecessor(lPTL);
        } 
        else{
            //System.Debug('##>>> PTL.AfterInsert : BYPASS deactivatPTLFromPredecessor <<< run by ' + UserInfo.getName());
        }
        
        // Copy Inventory Pricing from Predecessor
        if (PAD.canTrigger('PTL.copyIPFromPredecessor')){
            AP_PTL_01.copyIPFromPredecessor(lPTL);
        } 
        else{
            //System.Debug('##>>> PTL.AfterInsert : BYPASS copyIPFromPredecessor <<< run by ' + UserInfo.getName());
        }
          
        if (PAD.canTrigger('PTL.updatePredecessorwithSuccessor')){
            AP_PTL_01.updatePredecessorwithSuccessor(Trigger.newMap);
        } 
        else{
            //System.Debug('##>>> PTL.AFterInsert : BYPASS updatePredecessorwithSuccessor<<< run by ' + UserInfo.getName());
        }
        
          
        //MLC 20171211 copy condition expedition remplace par Proces Builder Masquer toutes les versionsMAJ Condition Expedition PTL to Compte
         if (PAD.canTrigger('PTL.updateShippingConditionAccount')){
            AP_PTL_01.updateShippingConditionAccount(lPTL);
        } 
        else{
            //System.Debug('##>>> PTL.BeforeInsert : BYPASS updateShippingConditionAccount<<< run by ' + UserInfo.getName());
        }
              
        //System.Debug('##>>> PTL.AfterInsert : END <<<');
    } 
    else{
        //System.Debug('##>>> PTL.AfterInsert : FALSE TRIGGER <<<');
    }
}