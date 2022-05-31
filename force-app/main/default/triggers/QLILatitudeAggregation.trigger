trigger QLILatitudeAggregation on QuoteLineItem (after insert, after undelete, after update) {
    if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.isUpdate || Trigger.isUndelete)) {
        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('QLILatitudeAggregation.QLIToPTL')) {
        	list<QuoteLineItem> lQli = new list<QuoteLineItem>();
        	for(QuoteLineItem oQli:Trigger.new){
        		if(oQli.Quote_PTL__c!=null)lQli.add(oQli);
        	}
        	if(lQli.size()>0){
        		AP_Latitude_Aggregations_01.aggregate_QLIToPTL(lQli);
        	}
            
        } else {
            System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : BYPASS QLItoPTl <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('QLILatitudeAggregation.QLIToQuote')) {
            AP_Latitude_Aggregations_01.aggregate_QLIToQuote(Trigger.new);
        } else {
            System.Debug('##>>> QLILatitudeAggregation.QLIToQuote : BYPASS QLItoQuote <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : END <<<');
    } else {
        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : FALSE TRIGGER <<<');
    }
}