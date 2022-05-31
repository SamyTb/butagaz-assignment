global class GDB_OptinFixBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
     
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDB_PersonAccount').getRecordTypeId();
        return Database.getQueryLocator([SELECT Optin_Partenaires__c, Optin_1__c, Email__c, Email_2__c, No_E_mail__c FROM Account WHERE RecordTypeId = :personAccountRecordTypeId]);
    }
    
    global void execute( Database.BatchableContext BC, List<Account> accounts){
        for(Account account : accounts)
        {
            account.Optin_Partenaires__c = account.Optin_1__c;
            
            if(String.isBlank(account.Email__c) && String.isBlank(account.Email_2__c)){
                account.No_E_mail__c = true;
            }
        }
        
        update accounts;
    }
    
    global void finish( Database.BatchableContext BC ){}
}