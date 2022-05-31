trigger OpportunityBeforeInsertAccountSync on Opportunity (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Opportunity.BeforeInsertAccountSync : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('Opportunity.syncOpportunityFromAccount')) {
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount(Trigger.new);
        } else {
            System.Debug('##>>> Opportunity.syncOpportunityFromAccount <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> Opportunity.BeforeInsertAccountSync : END <<<');
    } else {
        System.Debug('##>>> Opportunity.BeforeInsertAccountSync : FALSE TRIGGER <<<');
    }
}