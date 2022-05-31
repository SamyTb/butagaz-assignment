trigger QuoteBeforeUpdateOpportunitySync on Quote (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> QuoteBeforeUpdateOpportunitySync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Quote.syncQuoteFromOpportunity')) {
            AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> QuoteBeforeUpdateOpportunitySync  <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> QuoteBeforeUpdateOpportunitySync  : END <<<');
    } else {
        System.Debug('##>>> QuoteBeforeUpdateOpportunitySync  : FALSE TRIGGER <<<');
    }
}