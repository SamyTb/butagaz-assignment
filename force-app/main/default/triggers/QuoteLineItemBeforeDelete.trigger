//Unable the deletion if the QuoteLineItem to delete is got from SAP on mode 2 of BAPI Pricing (Got_From_SAP__c == true)

trigger QuoteLineItemBeforeDelete on QuoteLineItem (before delete) {
    if (Trigger.IsBefore && Trigger.IsDelete) {
        System.Debug('##>>> QuoteLineItem.BeforeDelete : BEGIN <<< run by ' + UserInfo.getName());
        List<QuoteLineItem> lQuoteLineItems = Trigger.old;
        
        if (PAD.canTrigger('QuoteLineItem.QuoteLineItemBeforeDelete')) {
            AP_QuoteLineItem_01.checkItemsBeforeDelete(lQuoteLineItems);
        } else {
            System.Debug('##>>> QuoteLineItemBeforeDelete : BYPASS CheckItemBeforeDelete <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> QuoteLineItem.BeforeDelete : END <<<');
    } else {
        System.Debug('##>>> QuoteLineItem.BeforeDelete : FALSE TRIGGER <<<');
    }
}