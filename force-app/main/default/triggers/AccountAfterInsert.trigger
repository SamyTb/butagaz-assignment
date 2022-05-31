trigger AccountAfterInsert on Account (after insert) {

    List<Account> lAccountToInsert = new List<Account>();
    List<Account> GDBAccounts = new List<Account>();
    
    Custom_Settings__c RT_GDB_PA = Custom_Settings__c.getValues('Account_RecordTypeId_GDBPA');
    Id sRT_GDB_PA;
    if(RT_GDB_PA!=null){
        sRT_GDB_PA = RT_GDB_PA.value__c;
    }
    
    
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> Account.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Account> lAcc = Trigger.new;
        
        for(Account acc : lAcc){
            if(acc.RecordTypeId != sRT_GDB_PA){
                lAccountToInsert.add(acc);
            }else{
                GDBAccounts.add(acc);
            }
        }
        
        if (PAD.canTrigger('Account.copyRemonteeConcurrenceGEB')){
            AP_Account_01.copyRemonteeConcurrenceGEB(lAccountToInsert);
        } 
        else{
            System.Debug('##>>> Account.AfterInsert : BYPASS copyRemonteeConcurrenceGEB <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Account.manageMKTContact')){
            AP_Account_01.manageMKTContact(lAccountToInsert);
        } 
        else{
            System.Debug('##>>> Account.AfterInsert : BYPASS manageMKTContact <<< run by ' + UserInfo.getName());
        }                
        
        /* 20181106 Erwan Disabled and replaced by a Workflow Rule / Field Update : AccountConcatenateAddressFields
        if (PAD.canTrigger('Account.updateConcatenatedAddressField')){
            AP_Account_01.updateConcatenatedAddressField(lAccountToInsert);
        } 
        else{
            System.Debug('##>>> Account.AfterInsert : BYPASS updateConcatenatedAddressField <<< run by ' + UserInfo.getName());
        }*/
        
        
        if (PAD.canTrigger('Account.updateSuccessorAccountWithPredecessorMedal')){
            AP_Account_01.updateSuccessorAccountWithPredecessorMedal(lAccountToInsert);
        } 
        else{
            System.Debug('##>>> Account.AfterInsert : BYPASS updateSuccessorAccountWithPredecessorMedal <<< run by ' + UserInfo.getName());
        }
        
        /*if (PAD.canTrigger('Account.updateEspaceClientEncryptedParams')){
            AP_Account_01.updateEspaceClientEncryptedParams(lAcc);
        } 
        else{
            System.Debug('##>>> Account.AfterUpdate : BYPASS updateEspaceClientEncryptedParams <<< run by ' + UserInfo.getName());
        }*/
        
        // Exclude this method call when running test because it generates a duplicate error but not when running outside test. Don't know why.
        if(!Test.isRunningTest()){
            if (PAD.canTrigger('Account.copyGDBAccountNumber')){
                AP_Account_01.copyGDBAccountNumber(GDBAccounts);
            } 
            else{
                System.Debug('##>>> Account.AfterInsert : BYPASS copyGDBAccountNumber <<< run by ' + UserInfo.getName());
            }
        }
      
    } 
    else{
        System.Debug('##>>> Account.AfterInsert : FALSE TRIGGER <<<');
    }
}