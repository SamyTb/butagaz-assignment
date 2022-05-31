@isTest
private class GDB_ItemBatchTransfer_Test {

    @isTest
    static void testBatch(){
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();

        Test.startTest();
            Database.executeBatch(new GDB_ItemBatchTransfer());        
        Test.stopTest();        
    }
}