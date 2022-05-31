trigger AccountAfterUpdate on Account (after update) {
    // Constant
    boolean RUN_MKT_CONTACT_CREATION = OrganizationSettings__c.getInstance().MKT_Contact_Creation_on_After_Update__c;
    set<String> setEmailAddressesToNullify = new set<String>();

    if (Trigger.IsAfter && Trigger.IsUpdate) {
       // System.Debug('##>>> Account.afterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        /* Erwan 20170922 : To uncomment once Salesforce resolves the conversion bug
        if (PAD.canTrigger('Account.afterUpdate')) {
        
            set<Id> sAccountToConvertToPA=new set<Id>(); 
            set<Id> sAccountToConvertToBA=new set<Id>();
     
            for(Account oAccount: Trigger.new){
                if(oAccount.A_convertir__c && !oAccount.Business_Account__c && !oAccount.isPersonAccount){
                    sAccountToConvertToPA.add(oAccount.Id);
                }
                else if(oAccount.A_convertir__c && oAccount.Business_Account__c && oAccount.isPersonAccount){
                    sAccountToConvertToBA.add(oAccount.Id);
                }
                else {
                    System.debug('Ignored Account: ' + String.valueOf(oAccount));           
                }
             }
             if(sAccountToConvertToPA.size()>0)
                 AP02_Account.convertToPA(sAccountToConvertToPA);
             if(sAccountToConvertToBA.size()>0)
                 AP02_Account.convertToBA(sAccountToConvertToBA);
        } 
        else {  
           // System.Debug('##>>> Account.afterUpdate : BYPASS Account.afterUpdate <<< run by ' + UserInfo.getName());
        }*/
        
        
        /*MLC remplace par Process Builder Account_updatePTLFromDO*/
       /* if (PAD.canTrigger('Account.manageMKTContact') && RUN_MKT_CONTACT_CREATION){
            AP_Account_01.manageMKTContact(Trigger.new);
        } 
        else{
           // System.Debug('##>>> Account.AfterUpdate : BYPASS manageMKTContact <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Account.updatePTLFromDO')){
            if(!AP_Account_01.hasAlreadyUpdatedAccount()){
                AP_Account_01.setAlreadyUpdatedAccount(true);
                AP_Account_01.updatePTLFromDO(Trigger.new);
                AP_Account_01.setAlreadyUpdatedAccount(false);
            }           
        } 
        else{
           // System.Debug('##>>> Account.AfterUpdate : BYPASS updatePTLFromDO<<< run by ' + UserInfo.getName());
        }*/
        
        /* 20181106 Erwan Disabled and replaced by a Workflow Rule / Field Update : AccountConcatenateAddressFields
        if (PAD.canTrigger('Account.updateConcatenatedAddressField')){
            List<Account> lAccountToUpdate = new List<Account>();
            if(!AP_Account_01.hasAlreadyUpdatedAccount()){
                AP_Account_01.setAlreadyUpdatedAccount(true);
                
                for(Account acc : Trigger.new)
                {
                    if( acc.Street_N__c != System.trigger.oldMap.get(acc.id).Street_N__c || acc.Number_extention__c != System.trigger.oldMap.get(acc.id).Number_extention__c || acc.Street_type__c != System.trigger.oldMap.get(acc.id).Street_type__c || acc.Street_name__c != System.trigger.oldMap.get(acc.id).Street_name__c )
                    {
                        lAccountToUpdate.add(acc);
                    }
                }
                if(lAccountToUpdate.size() > 0){
                    AP_Account_01.updateConcatenatedAddressField(lAccountToUpdate);
                }
                
                AP_Account_01.setAlreadyUpdatedAccount(false);
            }
        } 
        else{
           // System.Debug('##>>> Account.AfterUpdate : BYPASS updateConcatenatedAddressField <<< run by ' + UserInfo.getName());
        }*/
        
        /*if (PAD.canTrigger('Account.updatePTLFromDO')){
            if(!AP_Account_01.hasAlreadyUpdatedAccount()){
                AP_Account_01.setAlreadyUpdatedAccount(true);
                if(!system.isFuture()){
                     AP_Account_01.updatePTLFromDO(Trigger.newMap.Keyset());
                }
               
                AP_Account_01.setAlreadyUpdatedAccount(false);
            }           
        } 
        else{
           // System.Debug('##>>> Account.AfterUpdate : BYPASS updatePTLFromDO<<< run by ' + UserInfo.getName());
        }*/
        
        if (PAD.canTrigger('Account.updateEspaceClientEncryptedParams')){
            List<Account> lAccountToUpdate = new List<Account>();
            if(!AP_Account_01.hasAlreadyUpdatedAccount()){
                AP_Account_01.setAlreadyUpdatedAccount(true);
                for(Account acc : Trigger.new){
                    if( null == System.trigger.oldMap.get(acc.id).Espace_Client_Registration_URL__c || acc.AccountNumber != System.trigger.oldMap.get(acc.id).AccountNumber || acc.City_Postal_Code__c != System.trigger.oldMap.get(acc.id).City_Postal_Code__c || acc.Postal_Code__c != System.trigger.oldMap.get(acc.id).Postal_Code__c ){
                        lAccountToUpdate.add(acc);
                    }
                }
                if(lAccountToUpdate.size() > 0){
                    AP_Account_01.updateEspaceClientEncryptedParams(lAccountToUpdate);
                }
                
                AP_Account_01.setAlreadyUpdatedAccount(false);
            }
        } 
        else{
           // System.Debug('##>>> Account.AfterUpdate : BYPASS updateEspaceClientEncryptedParams <<< run by ' + UserInfo.getName());
        }

        // Nullify all email fields containing this email address
        if (PAD.canTrigger('Account.nullifyEmailAddress')) {
            if(!System.isFuture() && !System.isBatch()){
                for(Account oAccount:Trigger.new){
                    if(oAccount.IsPersonAccount && oAccount.PersonEmail=='delete.me@butagaz.mc')
                        setEmailAddressesToNullify.add(Trigger.oldMap.get(oAccount.Id).PersonEmail);
                }
                if(setEmailAddressesToNullify.size()>0)
                    AP03Contact.nullifyEmailAddress(setEmailAddressesToNullify);
            }
        } else { 
           // System.Debug('##>>> Account.afterUpdate : BYPASS Account.nullifyEmailAddress<<< run by ' + UserInfo.getName());
        }
        
        
       
        
        
        
        
        
        

        
       // System.Debug('##>>> Account.afterUpdate : END <<<');
    } 
    else {
       // System.Debug('##>>> Account.afterUpdate : FALSE TRIGGER <<<');
    }

}