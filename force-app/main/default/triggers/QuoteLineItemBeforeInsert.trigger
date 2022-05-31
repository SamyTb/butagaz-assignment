trigger QuoteLineItemBeforeInsert on QuoteLineItem (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> QuoteLineItem.BeforeIsInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<QuoteLineItem> lQuoteLineItems = Trigger.new;
        
        if (PAD.canTrigger('QuoteLineItem.QuoteLineItemBeforeInsert ')) {
            AP_QuoteLineItem_02.calculateTaxes(lQuoteLineItems, new Map<Id, QuoteLineItem>());
        } else {
            System.Debug('##>>> QuoteLineItemBeforeInsert : BYPASS calculateTaxes<<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> QuoteLineItem.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> QuoteLineItem.BeforeInsert : FALSE TRIGGER <<<');
    }
}