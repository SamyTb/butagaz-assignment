trigger RequestCategoryAfterUpdate on Request_Category__c (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        if (PAD.canTrigger('Request_Category__c.after_update')) {
            System.Debug('##>>> Request_Category__c.after_update : BEGIN <<< run by ' + UserInfo.getName());
            
            List<Request_Category__c> requestCategories = Trigger.new;
            if (requestCategories.size() > 0) {
                AP_RequestCategory.afterUpdate(requestCategories);
            }
        
            System.Debug('##>>> Request_Category__c.after_update : END <<<');
        } else {
            System.Debug('##>>> Request_Category__c.after_update : BYPASS <<< run by ' + UserInfo.getName());
        }
    } else {
        System.Debug('##>>> Request_Category__c.after_update : FALSE TRIGGER <<<');
    }
}