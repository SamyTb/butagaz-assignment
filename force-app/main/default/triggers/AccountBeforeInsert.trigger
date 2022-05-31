trigger AccountBeforeInsert on Account (before insert) {

    List<Account> lAccountToInsert = new List<Account>();

    Custom_Settings__c RT_GDB_PA = Custom_Settings__c.getValues('Account_RecordTypeId_GDBPA');
    Id sRT_GDB_PA;
    if(RT_GDB_PA!=null){
        sRT_GDB_PA = RT_GDB_PA.value__c;
               
    }
    
    
    
    Custom_Settings__c RT_PRESC = Custom_Settings__c.getValues('Account_RecordTypeId_Prescripteur');
    Id sRT_PRESC ;
    if(RT_PRESC !=null){
        sRT_PRESC = RT_PRESC.value__c;
               
    }
    
    
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Account.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Account> lAcc = Trigger.new;
        
        for(Account acc : lAcc){
            if(acc.RecordTypeId != sRT_GDB_PA){
                lAccountToInsert.add(acc);
            }
        }
        
        /*if (PAD.canTrigger('Account.emailPasDEmailInsert')){
            AP_Account_01.emailPasDEmailInsert(lAcc, false);
        } 
        else{
            System.Debug('##>>> Account.BeforeInsert : BYPASS copyRemonteeConcurrenceGEB <<< run by ' + UserInfo.getName());
        }*/
        
        
        // Commenté 20160501 pour être comme en PROD (???) // 20170103 MLC remise du trigger
        if (PAD.canTrigger('Account.emailPasDEmailInsertUpdate')){
            AP_Account_01.emailPasDEmailInsertUpdate(lAccountToInsert);
        } 
        else{
            System.Debug('##>>> Account.BeforeInsert : BYPASS emailPasDEmailInsertUpdate <<< run by ' + UserInfo.getName());
        }
        
        
        
      /*   if (PAD.canTrigger('Account.updateReferencePrecripteur')){
              System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur<<< run by ' + UserInfo.getName());
              for(Account acc : lAcc){
               System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur  TRIGGER<<< run by ' + acc.Id);
           if(acc.RecordTypeId ==sRT_PRESC  ){
            AP_Account_01.updateReferencePrecripteur(lAcc);
            }
          }
        
        }
       */
               
        System.Debug('##>>> Account.BeforeInsert : END <<<');
    } 
    else{
        System.Debug('##>>> Account.BeforeInsert : FALSE TRIGGER <<<');
    }
}