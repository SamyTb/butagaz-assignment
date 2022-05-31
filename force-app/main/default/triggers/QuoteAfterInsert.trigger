trigger QuoteAfterInsert on Quote (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Quote.afterInsert: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Quote.copyOptyPTLs')) {
            AP_CopyOptyPTLsToQuote_01.addOptyPTLsAfterQuoteInsert(Trigger.new);
        } else {
            System.Debug('##>>> Quote.afterInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Quote.afterInsert : END <<<');
    } else {
        System.Debug('##>>> Quote.afterInsert : FALSE TRIGGER <<<');
    }
}