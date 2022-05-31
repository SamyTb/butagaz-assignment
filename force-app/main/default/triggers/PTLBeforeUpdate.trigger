trigger PTLBeforeUpdate on PTL__c(before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        //System.Debug('##>>> PTL.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        List<PTL__c> lPtl = Trigger.new;
        
        if (PAD.canTrigger('PTL.manageMKTContact')){
            AP_PTL_01.manageMKTContact(lPtl);
        } 
        else{
            //System.Debug('##>>> PTL.BeforeUpdate : BYPASS manageMKTContact<<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('PTL.updatePTLFromDO')){
            if(!AP_PTL_01.hasAlreadyUpdatedPTL()){
                AP_PTL_01.setAlreadyUpdatedPTL(true);
                AP_PTL_01.updatePTLFromDO(lPTL);
                AP_PTL_01.setAlreadyUpdatedPTL(false);
            }
        } 
        else{
            //System.Debug('##>>> PTL.BeforeInsert : BYPASS updatePTLFromDO<<< run by ' + UserInfo.getName());
        }
        
        
        //System.Debug('##>>> PTL.BeforeUpdate : END <<<');
    }
    else{
        //System.Debug('##>>> PTL.BeforeUpdate : FALSE TRIGGER <<<');
    }    
}