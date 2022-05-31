trigger LeadSameAddressBeforeInsert on Lead (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Lead.LeadSameAddressBeforeInsert: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Lead.LeadSameAddressBeforeInsert')) {
            AP_CopyAddressFields_01.copyAddressFields(Trigger.new);
        } else {
            System.Debug('##>>> Lead.LeadSameAddressBeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Lead.LeadSameAddressBeforeInsert : END <<<');
    } else {
        System.Debug('##>>> Lead.LeadSameAddressBeforeInsert : FALSE TRIGGER <<<');
    }
}