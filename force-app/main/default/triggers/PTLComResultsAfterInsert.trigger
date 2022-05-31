trigger PTLComResultsAfterInsert on PTL_Commercial_Results__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> PTL_Commercial_Results__c.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL_Commercial_Results__c> lPTLComResults = Trigger.new;
               
        if (PAD.canTrigger('PTL_Commercial_Results__c.putCommercialObjective')){
        	if(!AP_PTLCommercialResults.hasAlreadyUpdatedPTLComResult()){
        		AP_PTLCommercialResults.setAlreadyUpdatedPTLComResult(true);
        		AP_PTLCommercialResults.putCommercialObjective(lPTLComResults);
        		AP_PTLCommercialResults.setAlreadyUpdatedPTLComResult(false);
        		
        	}            
        } 
        else{
            System.Debug('##>>> AP_PTLCommercialResults.putCommercialObjective : BYPASS putCommercialObjective <<< run by ' + UserInfo.getName());
        } 
         
    } 
    else{
        System.Debug('##>>> PTL_Commercial_Results__c.AfterInsert : FALSE TRIGGER <<<');
    }
}