@isTest
private class GDB_BasketBatchDelete_TEST {

    @isTest
    static void testBatch() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        
        Account a =  GDB_TestDataFactory.createAccount();
        insert a;
        
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        GDB_Basket__c b2 = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        Test.startTest();
            Database.executeBatch(new GDB_BasketBatchDelete(), 200);
        Test.stopTest();
    }
}