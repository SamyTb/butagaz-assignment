trigger LeadSameAddressBeforeUpdate on Lead (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Lead.LeadSameAddressBeforeUpdate: BEGIN <<< run by ' + UserInfo.getName());
        
        if (PAD.canTrigger('Lead.LeadSameAddressBeforeUpdate')) {
            AP_CopyAddressFields_01.copyAddressFields(Trigger.new);
        } else {
            System.Debug('##>>> Lead.LeadSameAddressBeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Lead.LeadSameAddressBeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> Lead.LeadSameAddressBeforeUpdate : FALSE TRIGGER <<<');
    }
}