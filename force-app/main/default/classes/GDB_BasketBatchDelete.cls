global class GDB_BasketBatchDelete implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**
    * Execute the schedulable batch
    * @param {SchedulableContext} context
    */
    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
    
    /**
    * Start the current batch
    * @param {Database.BatchableContext} BC
    */
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator([SELECT Id, gdb_Discount__c, (SELECT Id FROM Basket_Products__r) FROM GDB_Basket__c]);
    }
    
    /**
    * execute the current batch
    * @param {Database.BatchableContext} BC
    * @param {List<GDB_Basket__c>} basketList
    */
    global void execute( Database.BatchableContext BC, List<GDB_Basket__c> basketList){
        List<GDB_Basket_Product__c> products = new List<GDB_Basket_Product__c>();
        Map<Id, Integer> promotions = new Map<Id, Integer>();
        for(GDB_Basket__c b : basketList)  {
            products.addAll(b.Basket_Products__r);
        }
        
        delete products;
        delete basketList;
    }
    
    /**
    * Finish the current batch
    * @param {Database.BatchableContext} BC
    */
    global void finish( Database.BatchableContext BC ){}
}