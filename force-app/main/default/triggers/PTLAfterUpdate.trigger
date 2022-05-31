trigger PTLAfterUpdate on PTL__c (after update) {
    
    // Erwan 20200727 : Deactivated because of errors on data load and not used at the moment
    /*
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> PTL.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        // Known issue : InvalidParameterException in test classes
        List<PTL__c> lPTL = Trigger.new;
        if (!Test.isRunningTest()){
            et4ae5.triggerUtility.automate('PTL__c');
        }
        
        
    }else{
        System.Debug('##>>> PTL.AfterUpdate : FALSE TRIGGER <<<');
    }
    */
}