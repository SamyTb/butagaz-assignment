@isTest
private class GDB_Split_OrdersController_TEST {
 
    @isTest
    static void testValidateWithChildOrderWithSameQty() {
        PageReference splitOrdePage = new PageReference('apex/GDB_Split_Orders?id=a0Q9E000001FAmU');
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_TestDataFactory.getOrder();
        GDB_TestDataFactory.createItemsInOrder(o);

        GDB_TestDataFactory.createChildorder(o, null);
        Order__c co = GDB_TestDataFactory.getChildOrder();
        GDB_TestDataFactory.createItemsInOrder(co);

        ApexPages.StandardController sc = new ApexPages.standardController(o);
        Test.setCurrentPage(splitOrdePage);
        GDB_Split_OrdersController soCtrl = new GDB_Split_OrdersController(sc);
        PageReference pr = soCtrl.validate();
        System.assertEquals(null, pr, 'Return value should be null');
    }

    @isTest
    static void testValidateWithChildOrderWithDiffQty() {
        PageReference splitOrdePage = new PageReference('apex/GDB_Split_Orders?id=a0Q9E000001FAmU');
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_TestDataFactory.getOrder();
        GDB_TestDataFactory.createItemsInOrder(o);

        GDB_TestDataFactory.createChildorder(o, null);
        Order__c co = GDB_TestDataFactory.getChildOrder();
        GDB_TestDataFactory.createItemsInChildOrder(co);

        ApexPages.StandardController sc = new ApexPages.standardController(o);
        Test.setCurrentPage(splitOrdePage);
        GDB_Split_OrdersController soCtrl = new GDB_Split_OrdersController(sc);
        PageReference pr = soCtrl.validate();
        System.assertEquals(null, pr, 'Return value should be null');
    }


    @isTest
    static void testBackToOrder() {
        PageReference splitOrdePage = new PageReference('apex/GDB_Split_Orders?id=a0Q9E000001FAmU');
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_TestDataFactory.getOrder();
        GDB_TestDataFactory.createItemsInOrder(o);

        GDB_TestDataFactory.createChildorder(o, null);
        Order__c co = GDB_TestDataFactory.getChildOrder();
        GDB_TestDataFactory.createItemsInOrder(co);

        ApexPages.StandardController sc = new ApexPages.standardController(o);
        Test.setCurrentPage(splitOrdePage);
        GDB_Split_OrdersController soCtrl = new GDB_Split_OrdersController(sc);
        PageReference pr = soCtrl.backToOrder();
        System.assertNotEquals(null, pr, 'Return value should be null');
    }
}