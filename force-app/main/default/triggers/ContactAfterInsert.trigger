trigger ContactAfterInsert on Contact (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Contact.afterInsert : BEGIN <<< run by ' + UserInfo.getName());

        List<Contact> contacts = Trigger.new;
        List<Contact> contactsGDB = new List<Contact>();

        if (PAD.canTrigger('Contact.createContactRole')) {
            AP01_Contact.createContactRole(contacts);

        } else {
            System.Debug('##>>> Contact.afterInsert : BYPASS Contact.createContactRole <<< run by ' + UserInfo.getName());
        }

        for(Contact oContact : contacts){
            if(oContact.IsGDB__c) contactsGDB.add(oContact);
        }

        if(contactsGDB.size()>0) {
            System.Debug('##>>> Contact.afterInsert : contactsGDB ' + contactsGDB);
            GDB_UserMgr.createExternalUserB2B(contactsGDB);
        }

        System.Debug('##>>> Contact.afterInsert : END <<<');
    } else {
        System.Debug('##>>> Contact.afterInsert : FALSE TRIGGER <<<');
    }

}