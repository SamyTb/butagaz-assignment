trigger AFBeforeInsert on Assignment_Filter__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> AF.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Assignment_Filter__c> lAFs = Trigger.new;
        
        if (PAD.canTrigger('AF.lookupTarget')) {
            AP_Assignment_Filter_01.enforceUniqueness(lAFs);
        } else {
            System.Debug('##>>> AF.BeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> AF.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> AF.BeforeInsert : FALSE TRIGGER <<<');
    }
}