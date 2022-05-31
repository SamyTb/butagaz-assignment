trigger OpportunityAfterUpdate on Opportunity (after update) {
    
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        /*if (PAD.canTrigger('Opportunity.callComparatorWS')) {
            if(!System.isFuture() && !System.isBatch()){
                for( Id optyId : Trigger.newMap.keySet() ){
                    //if ( Trigger.newMap.get(optyId).Account.Lead_ExternalID__c != null ) {
                        //if ( Trigger.newMap.get(optyId).Account.Lead_ExternalID__c.startsWithIgnoreCase('CMP') ) {
                        if ( Trigger.newMap.get(optyId).Channel__c == 'Extranet comparateur' ) {
                            if( Trigger.oldMap.get(optyId).StageName != Trigger.newMap.get(optyId).StageName ){
                                Comparator_CalloutMgr.callComparatorWS(optyId, Trigger.newMap.get(optyId).Account.Lead_ExternalID__c, Trigger.newMap.get(optyId).StageName);
                            }
                        }
                    //}
                }
            }
        } 
        else {
            System.Debug('##>>> Opportunity.AfterUpdate : BYPASS callComparatorWS <<< run by ' + UserInfo.getName());   
        }*/

        if (PAD.canTrigger('Opportunity.callDoleadCustomerConversionsWS')) {
            if(!System.isFuture() && !System.isBatch()){
                for( Id optyId : Trigger.newMap.keySet() ){
                    if ( Trigger.newMap.get(optyId).LeadSource == 'Dolead' && Trigger.newMap.get(optyId).AccountId != null /*&& Trigger.newMap.get(optyId).Account.Lead_ExternalID__c != ''*/ ) {
                        if( ( Trigger.newMap.get(optyId).StageName == 'Closed Won' || Trigger.newMap.get(optyId).StageName == 'Closed Lost' ) && Trigger.oldMap.get(optyId).StageName != Trigger.newMap.get(optyId).StageName ){
                            Dolead_CalloutMgr.callDoleadCustomerConversionsWS(optyId, Trigger.newMap.get(optyId).Account.Lead_ExternalID__c, Trigger.newMap.get(optyId).StageName);
                        }
                    }
                }
            }
        } 
        else {
            System.Debug('##>>> Opportunity.AfterUpdate : BYPASS callDoleadCustomerConversionsWS <<< run by ' + UserInfo.getName());   
        }

        /*
        if (PAD.canTrigger('Opportunity.mAJComptePrescripteur')){
            if(!System.isFuture() && !System.isBatch()){
                AP_Opportunity.mAJComptePrescripteur(trigger.newMap.keySet());
            }
        }
        */
        System.Debug('##>>> Opportunity.AfterUpdate : END <<<');
    } else {
        System.Debug('##>>> Opportunity.AfterUpdate : FALSE TRIGGER <<<');
    }
    
}