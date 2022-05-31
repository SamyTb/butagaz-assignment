trigger Quote_PTL_cBeforeInsertPTL_cSync on Quote_PTL__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Quote_PTL_c.BeforeInsertPTL_cSync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Quote_PTL_c.syncQuote_PTL_cFromPTL_c')) {
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c(Trigger.new);
        } else {
            System.Debug('##>>> Quote_PTL_c.syncQuote_PTL_cFromPTL_c <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Quote_PTL_c.BeforeInsertPTL_cSync : END <<<');
    } else {
        System.Debug('##>>> Quote_PTL_c.BeforeInsertPTL_cSync : FALSE TRIGGER <<<');
    }
}