trigger QuoteBeforeInsertOpportunitySync on Quote (before insert) {
    System.Debug('##>>> BEFORE TEST Quote.BeforeInsertOpportunitySync : BEGIN <<< run by ' + UserInfo.getName());
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Quote.BeforeInsertOpportunitySync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Quote.syncQuoteFromOpportunity')) {
            System.Debug('##>>> Calling AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity <<< run by ' + UserInfo.getName());
            AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity(Trigger.new);
        } else {
            System.Debug('##>>> Quote.BeforeInsertOpportunitySync <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Quote.BeforeInsertOpportunitySync : END <<<');
    } else {
        System.Debug('##>>> Quote.BeforeInsertOpportunitySync : FALSE TRIGGER <<<');
    }
}