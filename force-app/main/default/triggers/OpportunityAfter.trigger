trigger OpportunityAfter on Opportunity (after insert,after update ) {

    /*
    if (Trigger.IsAfter ) {
        if (PAD.canTrigger('Opportunity.mAJComptePrescripteur')){
            if(!System.isFuture() && !System.isBatch()){
                //AP_Opportunity.DeclencheMajComptePrescriteur(trigger.new);
                 System.Debug('##>>> Opportunity.After :  AP_Opportunity.mAJComptePrescripteur <<< run by ' + UserInfo.getName());  
            }
        }         
    }
	*/
}