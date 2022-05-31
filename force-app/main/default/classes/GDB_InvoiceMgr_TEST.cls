@isTest
private class GDB_InvoiceMgr_TEST {

    /*@isTest
    static void testCreateInvoiceWithNullOrder() {
        GDB_Invoice__c invoice = GDB_TestDataFactory.createInvoice(null);
        System.assertEquals(null, invoice, 'Return value should be null');
    }*/

    @isTest
    static void testCreateInvoiceWitOrder() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_OrderMgr.getOrderByName('GDB_123456');
        GDB_TestDataFactory.createItemsInOrder(o);
        o = GDB_OrderMgr.getOrderByName('GDB_123456');
        GDB_Invoice__c invoice = GDB_TestDataFactory.createInvoice(o);
        System.assertNotEquals(null, invoice, 'Return value should not be null');
    }
}