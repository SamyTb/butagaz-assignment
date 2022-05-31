trigger RequestCategoryBeforeInsert on Request_Category__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        if (PAD.canTrigger('Request_Category__c.before_insert')) {
            System.Debug('##>>> Request_Category__c.before_insert : BEGIN <<< run by ' + UserInfo.getName());
            
            List<Request_Category__c> requestCategories = Trigger.new;
            if (requestCategories.size() > 0) {
                AP_RequestCategory.beforeInsert(requestCategories);
            }
        
            System.Debug('##>>> Request_Category__c.before_insert : END <<<');
        } else {
            System.Debug('##>>> Request_Category__c.before_insert : BYPASS <<< run by ' + UserInfo.getName());
        }
    } else {
        System.Debug('##>>> Case.before_insert : FALSE TRIGGER <<<');
    }
}