trigger AccountAcCodeAfterPTLInsert on PTL__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> PTL__c.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<PTL__c> lPTL = Trigger.new;
        
        if (PAD.canTrigger('PTL__c.putACCodeInAccount')){
            AP_PTL_01.putACCodeInAccount(lPTL);
        } 
        else{
            System.Debug('##>>> PTL__c.AfterInsert : BYPASS putACCodeInAccount <<< run by ' + UserInfo.getName());
        }
                     
        System.Debug('##>>> PTL__c.AfterInsert : END <<<');
    } 
    else{
        System.Debug('##>>> PTL__c.AfterInsert : FALSE TRIGGER <<<');
    }   
}