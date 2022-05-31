trigger PTLComsumptionProfileBeforeInsert on PTL_Consumption_Profile__c (before insert) {
 if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> PTL.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL_Consumption_Profile__c> lPTLs = Trigger.new;
        
        if (PAD.canTrigger('PTL.updateConso')) {
            AP_Conso_SObject_01.updateConso(lPTLs);
        } else {
            System.Debug('##>>> PTL.BeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> PTL.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> PTL.BeforeInsert : FALSE TRIGGER <<<');
    }
}