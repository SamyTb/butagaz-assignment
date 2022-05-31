trigger OptyPTLAfterInsert on Opportunity_PTL__c (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> OptyPTL.afterInsert: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('OptyPTL.copyOptyPTLs')) {
            AP_CopyOptyPTLsToQuote_01.addOptyPTLsAfterPTLInsert(Trigger.new);
        } else {
            System.Debug('##>>> OptyPTL.afterInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> OptyPTL.afterInsert : END <<<');
    } else {
        System.Debug('##>>> OptyPTL.afterInsert : FALSE TRIGGER <<<');
    }
}