trigger OpportunityBeforeUpdateAccountSync on Opportunity (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity.BeforeUpdateAccountSync : BEGIN <<< run by ' + UserInfo.getName());

      /*  if (PAD.canTrigger('Opportunity.syncOpportunityFromOpportunity')) {
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Opportunity.syncOpportunityFromOpportunity <<< run by ' + UserInfo.getName());
        }*/


        if (PAD.canTrigger('Opportunity.syncOpportunityFromAccount')) {
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount(Trigger.oldMap, Trigger.newMap);
        } else {
            System.Debug('##>>> Opportunity.syncOpportunityFromAccount <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Opportunity.BeforeUpdateAccountSync : END <<<');
    } else {
        System.Debug('##>>> Opportunity.BeforeUpdateAccountSync : FALSE TRIGGER <<<');
    }
}