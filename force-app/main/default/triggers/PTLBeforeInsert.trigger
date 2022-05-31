trigger PTLBeforeInsert on PTL__c (before insert) {
	if (Trigger.IsBefore && Trigger.IsInsert) {
		System.Debug('##>>> PTL.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
		
        List<PTL__c> lPTL = Trigger.new;
        
		if (PAD.canTrigger('PTL.manageMKTContact')){
            AP_PTL_01.manageMKTContact(lPTL);
        } 
        else{
            System.Debug('##>>> PTL.BeforeInsert : BYPASS manageMKTContact<<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('PTL.updatePTLFromDO')){
            AP_PTL_01.updatePTLFromDO(lPTL);
        } 
        else{
            System.Debug('##>>> PTL.BeforeInsert : BYPASS updatePTLFromDO<<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('PTL.updatePTLFromOPTL')){
            AP_PTL_01.updatePTLFromOPTL(lPTL);
        } 
        else{
            System.Debug('##>>> PTL.BeforeInsert : BYPASS updatePTLFromOPTL<<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> PTL.BeforeInsert : END <<<');
	} 
    else{
        System.Debug('##>>> PTL.BeforeInsert : FALSE TRIGGER <<<');
    }
}