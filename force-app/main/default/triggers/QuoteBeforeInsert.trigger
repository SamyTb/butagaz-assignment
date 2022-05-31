trigger QuoteBeforeInsert on Quote (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Quote.beforeInsert: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Quote.copyOptyPTLs')) {
            AP_CopyOptyPTLsToQuote_01.addOptyPTLsInfoBeforeQuoteInsert(Trigger.new);
        } else {
            System.Debug('##>>> Quote.beforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Quote.beforeInsert : END <<<');
    } else {
        System.Debug('##>>> Quote.beforeInsert : FALSE TRIGGER <<<');
    }
}