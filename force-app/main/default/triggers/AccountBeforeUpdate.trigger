trigger AccountBeforeUpdate on Account (before update) {
    
    List<Account> lAccountToUpdate = new List<Account>();
    
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
    
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Account.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Account> lAcc = Trigger.new;
        Boolean IsStandard = true;
        
         for(Account acc : Trigger.new){
            if(acc.RecordTypeId != sRT_GDB_PA){
                lAccountToUpdate.add(acc);
            }
        }
        
        if (PAD.canTrigger('Account.preventClosedAccountToBeUpdated')){
            AP_Account_01.preventClosedAccountToBeUpdated(lAcc);
        } 
        else{
            System.Debug('##>>> Account.BeforeUpdate : BYPASS preventClosedAccountToBeUpdated <<< run by ' + UserInfo.getName());
        }
        
        // Commenté 20160501 pour être comme en PROD (???) // 20170103 MLC remise du trigger
        if (PAD.canTrigger('Account.emailPasDEmailInsertUpdate')){
            AP_Account_01.emailPasDEmailInsertUpdate(lAcc);
        } 
        else{
            System.Debug('##>>> Account.BeforeUpdate : BYPASS emailPasDEmailInsertUpdate <<< run by ' + UserInfo.getName());
        }
        
        // On account creation, if GEB RE set Bareme GEB to C1, if GEB CS set Bareme GEB to C3
        for (Account acc : lAcc) {
            if(acc.Scale_GEB__c == null || acc.Scale_GEB__c == ''){
                if (acc.Activity_Domain_Simple__c=='geb' && acc.Channel__c=='RE') {
                    acc.Scale_GEB__c = 'C1';
                }else if (acc.Activity_Domain_Simple__c=='geb' && acc.Channel__c=='CS') {
                    acc.Scale_GEB__c = 'C3';
                }
            }
        }
        
           
      
      
       
         if (PAD.canTrigger('Account.updateReferencePrecripteur')){
              System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur<<< run by ' + UserInfo.getName());
              for(Account acc : lAcc){
               System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur  TRIGGER<<< run by ' + acc.Id + ' ' + acc.AccountNumber);
           if(acc.RecordTypeId ==sRT_PRESC  ){
            AP_Account_01.updateReferencePrecripteur(lAcc);
            }
          }
        
        }
    
     
      System.Debug('##>>> Account.BeforeUpdate : END <<<');
    } 
    else{
        System.Debug('##>>> Account.BeforeUpdate : FALSE TRIGGER <<<');
    }
}