trigger OpportunityConsoBeforeInsert on Opportunity (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Opportunity.ConsoBeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Opportunity.updateConso')) {
            AP_Conso_SObject_01.updateConso(Trigger.new);
        } else {
            System.Debug('##>>> Opportunity.ConsoBeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Opportunity.ConsoBeforeInsert : END <<<');
    } else {
        System.Debug('##>>> Opportunity.ConsoBeforeInsert : FALSE TRIGGER <<<');
    }
}