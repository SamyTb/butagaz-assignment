trigger AccountAcCodeAfterPTLUpdate on PTL__c (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        //System.Debug('##>>> PTL__c.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL__c> lPTL = Trigger.new;
        
        if (PAD.canTrigger('PTL__c.putACCodeInAccount')){
            if(!AP_PTL_01.hasAlreadyUpdatedPTL()){
                AP_PTL_01.setAlreadyUpdatedPTL(true);
                AP_PTL_01.putACCodeInAccount(lPTL);
                //AP_PTL_01.setAlreadyUpdatedPTL(false);
            }
        } 
        else{
            //System.Debug('##>>> PTL__c.AfterUpdate : BYPASS putACCodeInAccount <<< run by ' + UserInfo.getName());
        }
        
       
        /*
         * ce traitement a été à priori mis en place pour de la reprise de donnée. Nous le mettons en commentaire et la reprise de donnée devra être fait par batch
		
       
        if (PAD.canTrigger('PTL.updatePredecessorwithSuccessor')){
            if(!system.isFuture() && !System.isBatch()){
                AP_PTL_01.updatePredecessorwithSuccessor_Async(Trigger.newMap.keySet()); 
            }
           
           //AP_PTL_01.updatePredecessorwithSuccessor(Trigger.newMap);
        } 
        else{
            //System.Debug('##>>> PTL.BeforeUpdate : BYPASS updatePredecessorwithSuccessor<<< run by ' + UserInfo.getName());
        }
         */    
        //System.Debug('##>>> PTL__c.AfterUpdate : END <<<');
        //
        
        
    } 
    else{
        //System.Debug('##>>> PTL__c.AfterUpdate : FALSE TRIGGER <<<');
    }       
}