trigger OpportunityBeforeUpdate on Opportunity (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        List<Opportunity> lOpportunities = Trigger.new;
        
        //AP_Opportunity.validateOpportunity(lOpportunities);
        
        if (PAD.canTrigger('Opportunity.assignOpties')) {
            AP_Assignment_Main_01.assignOpties(lOpportunities);
        }
        
        if (PAD.canTrigger('Opportunity.controlRelatedOpportunityPTLs')) {
            AP_Opportunity.controlRelatedOpportunityPTLs(lOpportunities);
        }
        
        System.Debug('##>>> Opportunity.BeforeUpdate : END <<<');
    }
}