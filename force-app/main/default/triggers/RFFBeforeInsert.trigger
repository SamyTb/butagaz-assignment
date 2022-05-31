trigger RFFBeforeInsert on Rep_For_Filter__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> RFF.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Rep_For_Filter__c> lRFFs = Trigger.new;
        
        if (PAD.canTrigger('RFF.lookupTarget')) {
            AP_Assignment_RFF_01.lookupTarget(lRFFs);
        } else {
            System.Debug('##>>> RFF.BeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> RFF.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> RFF.BeforeInsert : FALSE TRIGGER <<<');
    }
}