trigger Opportunity_PTL_cBeforeUpdatePTL_cSync on Opportunity_PTL__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity_PTL_c.BeforeUpdatePTL_cSync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Opportunity_PTL_c.syncOpportunity_PTL_cFromOpportunity_PTL_c')) {
            AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Opportunity_PTL_c.syncOpportunity_PTL_cFromOpportunity_PTL_c <<< run by ' + UserInfo.getName());
        }


        if (PAD.canTrigger('Opportunity_PTL_c.syncOpportunity_PTL_cFromPTL_c')) {
            AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Opportunity_PTL_c.syncOpportunity_PTL_cFromPTL_c <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Opportunity_PTL_c.BeforeUpdatePTL_cSync : END <<<');
    } else {
        System.Debug('##>>> Opportunity_PTL_c.BeforeUpdatePTL_cSync : FALSE TRIGGER <<<');
    }
}