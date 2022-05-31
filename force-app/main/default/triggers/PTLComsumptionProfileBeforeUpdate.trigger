trigger PTLComsumptionProfileBeforeUpdate on PTL_Consumption_Profile__c (before update) {
 if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> PTL.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL_Consumption_Profile__c> lPTLs = Trigger.new;
        
        if (PAD.canTrigger('PTL.updateConso')) {
            AP_Conso_SObject_01.updateConso(lPTLs);
        } else {
            System.Debug('##>>> PTL.BeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> PTL.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> PTL.BeforeUpdate : FALSE TRIGGER <<<');
}
}