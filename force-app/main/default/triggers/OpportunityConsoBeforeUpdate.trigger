trigger OpportunityConsoBeforeUpdate on Opportunity (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity.ConsoBeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Opportunity.updateConso')) {
            AP_Conso_SObject_01.updateConso(Trigger.new);
        } else {
            System.Debug('##>>> Opportunity.ConsoBeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Opportunity.ConsoBeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> Opportunity.ConsoBeforeUpdate : FALSE TRIGGER <<<');
    }
}