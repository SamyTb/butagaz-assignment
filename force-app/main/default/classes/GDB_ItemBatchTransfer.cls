global with sharing class GDB_ItemBatchTransfer implements Database.Batchable<sObject> {
    
    /**
     * start the batch
     * @param  Database.BatchableContext context
     * @return QueryLocator
     */
    global Database.QueryLocator start( Database.BatchableContext context ) {
        Id articleRecordId = GDB_Constants.articleTypeId;
        return Database.getQueryLocator([ SELECT Id, gdb_technical_characteristics__c FROM Item__c WHERE recordTypeId = :articleRecordId]);
    }
    
    /**
     * execute the schedulable batch
     * @param  {SchedulableContext} context
     */
    global void execute( Database.BatchableContext context, List<Item__c> scope) {


        List<GDB_Department_Has_WarehouseProd__c> dhwps = [SELECT ID, gdb_technical_characteristics__c, gdb_warehouseproduct__r.gdb_Article__c
                                                            FROM GDB_Department_Has_WarehouseProd__c
                                                            WHERE gdb_warehouseproduct__r.gdb_Article__r.recordtypeid = :GDB_Constants.articleTypeId];
        Map<Id, Item__c> itemMap = new Map<Id, Item__c>(scope);

        Id articleId;
        for(GDB_Department_Has_WarehouseProd__c dhwp : dhwps){
            articleId = dhwp.gdb_warehouseproduct__r.gdb_Article__c;
            dhwp.gdb_technical_characteristics__c = itemMap.get(articleId).gdb_technical_characteristics__c;
        }
        if(!itemMap.isEmpty()){
            update dhwps;
        }
    }

    /**
     * finish the batch
     * @param Database.BatchableContext context
     */
    global void finish( Database.BatchableContext context) {}
}