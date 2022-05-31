trigger CaseAfterInsert on Case (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Case.afterInsert : BEGIN <<< run by ' + UserInfo.getName());
        
        Map<Id, Case> mCases = Trigger.newMap;
        List<Case> lCases = Trigger.new;
        
        /*if (PAD.canTrigger('Case.updateParents')) {
            AP_Case.updateParents(new Map<Id, Case>(), mCases);
        } else {
            System.Debug('##>>> Case.afterInsert : BYPASS Case.updateParents <<< run by ' + UserInfo.getName());
        }*/
        
        
        if (PAD.canTrigger('Case.enableCaseAutoResponse')) {
            if(!System.isFuture() && !System.isBatch()){
                set<Id> caseIdsSet = new set<Id>();
                for(Case oCase:lCases){
                    if( (oCase.Origin == 'Internet' || oCase.Origin == 'Espace Client') && !oCase.Subject.containsIgnoreCase('solaire')) caseIdsSet.add(oCase.Id);
                }
                
                AP_Case.enableCaseAutoResponse(caseIdsSet);
            }
        } else {
            System.Debug('##>>> Case.afterInsert : BYPASS Case.enableCaseAutoResponse <<< run by ' + UserInfo.getName());
        }
        
        
        
        System.Debug('##>>> Case.afterInsert : END <<<');
    } else {
        System.Debug('##>>> Case.afterInsert : FALSE TRIGGER <<<');
    }
}