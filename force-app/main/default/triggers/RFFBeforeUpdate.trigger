trigger RFFBeforeUpdate on Rep_For_Filter__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> RFF.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Rep_For_Filter__c> lRFFs = Trigger.new;
        
        if (PAD.canTrigger('RFF.lookupTarget')) {
            AP_Assignment_RFF_01.lookupTarget(lRFFs);
        } else {
            System.Debug('##>>> RFF.BeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> RFF.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> RFF.BeforeUpdate : FALSE TRIGGER <<<');
    }
}