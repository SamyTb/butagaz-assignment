trigger CaseBeforeUpdate on Case (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Case.beforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        Map<Id, Case> mOldCases = Trigger.oldMap;
        Map<Id, Case> mNewCases = Trigger.newMap;
        
        if (PAD.canTrigger('Case.updateCalculatedFields')) {
            AP_Case.updateCalculatedFields(mNewCases.values());
        } else {
            System.Debug('##>>> Case.BeforeUpdate : BYPASS updateCalculatedFields <<< run by ' + UserInfo.getName());
        }
         
        if (PAD.canTrigger('Case.updateRelatedLinks')) {
            AP_Case.updateRelatedLinks(mNewCases.values());
        } else {
            System.Debug('##>>> Case.beforeUpdate : BYPASS updateRelatedLinks <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.setActivityDomainAndMandataire')) {
            AP_Case.setActivityDomainAndMandataire(mNewCases.values(), mOldCases);
        } else {
            System.Debug('##>>> Case.beforeUpdate : BYPASS setActivityDomainAndMandataire <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.checkActivitiesWhenClosing')) {
            AP_Case.checkActivitiesWhenClosing(mNewCases.values());
        } else {
            System.Debug('##>>> Case.beforeUpdate : BYPASS checkActivitiesWhenClosing <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Case.beforeUpdate : END <<<');
    } else {
        System.Debug('##>>> Case.beforeUpdate : FALSE TRIGGER <<<');
    }
}