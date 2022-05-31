trigger CaseAfterDelete on Case (after delete) {
    if (Trigger.IsAfter && Trigger.IsDelete) {
    	System.Debug('##>>> Case.afterDelete : BEGIN <<< run by ' + UserInfo.getName());
    	
        List<Case> cases = Trigger.old;

    	/*if (PAD.canTrigger('Case.updateParents')) {
            AP_Case.updateParents(new Map<Id, Case>(), new Map<Id, Case>(cases));
    	} else {
    		System.Debug('##>>> Case.afterDelete : BYPASS Case.updateParents <<< run by ' + UserInfo.getName());
    	}*/
        
        System.Debug('##>>> Case.afterDelete : END <<<');
    } else {
        System.Debug('##>>> Case.afterDelete : FALSE TRIGGER <<<');
    }
}