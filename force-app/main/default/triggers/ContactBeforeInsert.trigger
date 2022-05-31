trigger ContactBeforeInsert on Contact (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Contact.beforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        
        List<Contact> contacts = Trigger.new;

        if (PAD.canTrigger('Contact.fillDummyAccount')) {
            for(Contact oContact:Trigger.new){
                if (oContact.AccountId == null) {
                    oContact.AccountId = Utils.getCustomSetting('ContactTrigger_DummyAccountId');
                }
            }
        } else { 
            System.Debug('##>>> Contact.beforeInsert : BYPASS Contact.FillDummyAccount <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Contact.beforeInsert : END <<<');
    } else {
        System.Debug('##>>> Contact.beforeInsert : FALSE TRIGGER <<<');
    }

}