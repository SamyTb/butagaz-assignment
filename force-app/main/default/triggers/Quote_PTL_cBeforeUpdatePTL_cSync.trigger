trigger Quote_PTL_cBeforeUpdatePTL_cSync on Quote_PTL__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Quote_PTL_c.BeforeUpdatePTL_cSync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Quote_PTL_c.syncQuote_PTL_cFromQuote_PTL_c')) {
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Quote_PTL_c.syncQuote_PTL_cFromQuote_PTL_c <<< run by ' + UserInfo.getName());
        }


        if (PAD.canTrigger('Quote_PTL_c.syncQuote_PTL_cFromPTL_c')) {
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Quote_PTL_c.syncQuote_PTL_cFromPTL_c <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Quote_PTL_c.BeforeUpdatePTL_cSync : END <<<');
    } else {
        System.Debug('##>>> Quote_PTL_c.BeforeUpdatePTL_cSync : FALSE TRIGGER <<<');
    }
}