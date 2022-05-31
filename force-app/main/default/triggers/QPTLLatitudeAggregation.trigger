trigger QPTLLatitudeAggregation on Quote_PTL__c (after insert, after undelete, after update) {
    if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.isUpdate || Trigger.isUndelete)) {
        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('QLILatitudeAggregation.PTLToQuote')) {
            AP_Latitude_Aggregations_01.aggregate_PTLToQuote(Trigger.new);
        } else {
            System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : BYPASS PTLToQuote<<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : END <<<');
    } else {
        System.Debug('##>>> QLILatitudeAggregation.QLIAggregate : FALSE TRIGGER <<<');
    }
}