@isTest
private class GDB_Order_ScheduleController_TEST {
    @isTest
    static void testValues() {
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

        GDB_Order_ScheduleController osc = new GDB_Order_ScheduleController();
        Order__c o = GDB_TestDataFactory.getOrder();

        osc.order = o;
        System.assertNotEquals(null, osc.infos, 'The infos attribute should not be null.');
    }
}