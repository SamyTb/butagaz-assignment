trigger CaseAfterUpdate on Case (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Case.afterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        Map<Id, Case> mOldCases = Trigger.oldMap;
        Map<Id, Case> mNewCases = Trigger.newMap;
        
        /*if (PAD.canTrigger('Case.updateParents')) {
            AP_Case.updateParents(mOldCases, mNewCases);
        } else {
            System.Debug('##>>> Case.afterUpdate : BYPASS Case.updateParents <<< run by ' + UserInfo.getName());
        }*/
        
        System.Debug('##>>> Case.afterUpdate : END <<<');
    } else {
        System.Debug('##>>> Case.afterUpdate : FALSE TRIGGER <<<');
    }
}