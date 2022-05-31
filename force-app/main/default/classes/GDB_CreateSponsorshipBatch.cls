global with sharing class GDB_CreateSponsorshipBatch implements Database.Batchable<sObject> {
    
    /**
     * start the batch
     * @param  Database.BatchableContext context
     * @return QueryLocator
     */
    global Database.QueryLocator start( Database.BatchableContext context ) {
        return Database.getQueryLocator([SELECT Id, gdb_parrainage_code__c, RecordTypeId FROM Account WHERE RecordTypeId = :GDB_Constants.personAccountId and gdb_parrainage_code__c != null and IsGDB__pc = true]);
    }
    
    /**
     * execute the schedulable batch
     * @param  {SchedulableContext} context
     */
    global void execute( Database.BatchableContext context, List<Account> scope) {
        GDB_DiscountMgr.createSponsorshipDiscount(scope);
    }

    /**
     * finish the batch
     * @param Database.BatchableContext context
     */
    global void finish( Database.BatchableContext context) {}
}