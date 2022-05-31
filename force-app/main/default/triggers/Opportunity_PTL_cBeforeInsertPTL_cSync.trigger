trigger Opportunity_PTL_cBeforeInsertPTL_cSync on Opportunity_PTL__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Opportunity_PTL_c.BeforeInsertPTL_cSync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Opportunity_PTL_c.syncOpportunity_PTL_cFromPTL_c')) {
            AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c(Trigger.new);
        } else {
            System.Debug('##>>> Opportunity_PTL_c.syncOpportunity_PTL_cFromPTL_c <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Opportunity_PTL_c.BeforeInsertPTL_cSync : END <<<');
    } else {
        System.Debug('##>>> Opportunity_PTL_c.BeforeInsertPTL_cSync : FALSE TRIGGER <<<');
    }
}