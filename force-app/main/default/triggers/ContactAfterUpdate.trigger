trigger ContactAfterUpdate on Contact (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Contact.afterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        set<Id> setcontacts = new set<Id>();
        set<String> setEmailAddressesToNullify = new set<String>();

        if (PAD.canTrigger('Contact.convertToPa')) {
            for(Contact oContact:Trigger.new){
                if(oContact.A_Convertir__c && oCOntact.AccountId==Label.DummyAccountId)
                    setcontacts.add(oContact.Id);
            }
            if(setContacts.size()>0)
                AP03Contact.convertToPA(setcontacts );
        } else { 
            System.Debug('##>>> Contact.afterUpdate : BYPASS Contact.convertToPa<<< run by ' + UserInfo.getName());
        }
        
        // Nullify all email fields containing this email address
        if (PAD.canTrigger('Contact.nullifyEmailAddress')) {
            if(!System.isFuture() && !System.isBatch()){
                for(Contact oContact:Trigger.new){
                    if(oContact.Email=='delete.me@butagaz.mc')
                        setEmailAddressesToNullify.add(Trigger.oldMap.get(oContact.Id).Email);
                }
                if(setEmailAddressesToNullify.size()>0)
                    AP03Contact.nullifyEmailAddress(setEmailAddressesToNullify);
            }
        } else { 
            System.Debug('##>>> Contact.afterUpdate : BYPASS Contact.nullifyEmailAddress<<< run by ' + UserInfo.getName());
        }

        // Unsubscribe all email fields containing this email address
        /*if (PAD.canTrigger('Contact.unsubscribeEmailAddress')) {
            for(Contact oContact:Trigger.new){
                //if(oContact.Email=='delete.me@butagaz.mc')
                    setEmailAddressesToUnsubscribe.add(Trigger.oldMap.get(oContact.Id).Email);
            }
            if(setEmailAddressesToUnsubscribe.size()>0)
                AP03Contact.unsubscribeEmailAddress(setEmailAddressesToUnsubscribe);
        } else { 
            System.Debug('##>>> Contact.afterUpdate : BYPASS Contact.unsubscribeEmailAddress<<< run by ' + UserInfo.getName());
        }*/




        System.Debug('##>>> Contact.afterUpdate : END <<<');
    } else {
        System.Debug('##>>> Contact.afterUpdate : FALSE TRIGGER <<<');
    }
}