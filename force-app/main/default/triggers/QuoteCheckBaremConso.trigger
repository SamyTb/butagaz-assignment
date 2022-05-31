trigger QuoteCheckBaremConso on Quote (before insert, before update) {
    
    List<Quote> quotesToValidate = Trigger.new;
    
    if (Trigger.IsInsert && Trigger.IsUpdate && Trigger.IsBefore) {
        System.Debug('##>>> Quote.QuoteCheckBaremConso: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Quote.QuoteCheckBaremConso')) {
            AP_QuoteCheckBaremeConso.checkQuotesBaremeConso(Trigger.new, Trigger.IsInsert);
        } else {
            System.Debug('##>>> Quote.QuoteCheckBaremConso : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Quote.QuoteCheckBaremConso : END <<<');
    } 
    
}