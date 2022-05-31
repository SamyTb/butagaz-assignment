trigger OpportunityBeforeInsert on Opportunity (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Opportunity.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Opportunity> lOpportunities = Trigger.new;
        
        //AP_Opportunity.validateOpportunity(lOpportunities);
        if (PAD.canTrigger('Opportunity.assignOpties')) {
            AP_Assignment_Main_01.assignOpties(lOpportunities);
        } else {
            System.Debug('##>>> Opportunity.BeforeInsert : BYPASS assignOpties <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Opportunity.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> Opportunity.BeforeInsert : FALSE TRIGGER <<<');
    }
}