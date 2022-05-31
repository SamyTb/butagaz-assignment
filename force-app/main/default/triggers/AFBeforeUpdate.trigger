trigger AFBeforeUpdate on Assignment_Filter__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> AF.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Assignment_Filter__c> lAFs = Trigger.new;
        
        if (PAD.canTrigger('AF.lookupTarget')) {
            AP_Assignment_Filter_01.enforceUniqueness(lAFs);
        } else {
            System.Debug('##>>> AF.BeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> AF.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> AF.BeforeUpdate : FALSE TRIGGER <<<');
    }
}