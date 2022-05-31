trigger RequestCategoryBeforeUpdate on Request_Category__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        if (PAD.canTrigger('Request_Category__c.before_update')) {
            System.Debug('##>>> Request_Category__c.before_update : BEGIN <<< run by ' + UserInfo.getName());
            
            List<Request_Category__c> requestCategories = Trigger.new;
            if (requestCategories.size() > 0) {
                AP_RequestCategory.beforeUpdate(requestCategories);
            }
        
            System.Debug('##>>> Request_Category__c.before_update : END <<<');
        } else {
            System.Debug('##>>> Request_Category__c.before_update : BYPASS <<< run by ' + UserInfo.getName());
        }
    } else {
        System.Debug('##>>> Case.before_update : FALSE TRIGGER <<<');
    }
}