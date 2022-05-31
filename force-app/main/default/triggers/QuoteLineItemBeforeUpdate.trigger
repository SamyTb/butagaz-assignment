trigger QuoteLineItemBeforeUpdate on QuoteLineItem (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> QuoteLineItem.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<QuoteLineItem> lQuoteLineItems = Trigger.newMap.values();
        
        if (PAD.canTrigger('QuoteLineItem.QuoteLineItemBeforeUpdate ')) {
            AP_QuoteLineItem_02.calculateTaxes(lQuoteLineItems, Trigger.oldMap);
        } else {
            System.Debug('##>>> QuoteLineItemBeforeUpdate : BYPASS calculateTaxes<<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> QuoteLineItem.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> QuoteLineItem.BeforeUpdate : FALSE TRIGGER <<<');
    }
}