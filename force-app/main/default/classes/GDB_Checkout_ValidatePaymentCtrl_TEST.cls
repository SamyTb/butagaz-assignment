@isTest(seeAllData=true)
private class GDB_Checkout_ValidatePaymentCtrl_TEST {

    @isTest
    static void testValidateResponse() {
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        
        GDB_Checkout_ValidatePaymentController controller = new GDB_Checkout_ValidatePaymentController();
        PageReference pr = controller.validateResponse();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_OrderMgr.getOrderById(GDB_TestDataFactory.getOrder().Id);
		GDB_TestDataFactory.createItemsInOrder(o);

        String data = 'transactionReference=' + o.gdb_OrderNo__c + '|responseCode=00|s10TransactionId=1234567890|authorisationId=1234567890';
        String seal = '1234567890';

        ApexPages.currentPage().getParameters().put('Data', data);
        ApexPages.currentPage().getParameters().put('Seal', seal);

        GDB_Mercanet.PostResponse postResponse = new GDB_Mercanet.PostResponse(data, seal);

        System.assertNotEquals(null, postResponse.getTransactionReference());
        System.assertNotEquals(null, o.gdb_OrderNo__c);
        System.assertEquals(postResponse.getTransactionReference(), o.gdb_OrderNo__c);

        pr = controller.validateResponse();
        
        o.Order_Status__c = '4';
        o.gdb_transaction_id__c = 'test';
        update o;
        
        pr = controller.validateResponse();
        
        Account account = [SELECT GDB_Already_Bought_Six_Densified_Logs__c FROM Account WHERE Id = :o.Account__c];
        
        System.assertEquals(true, account.GDB_Already_Bought_Six_Densified_Logs__c, 'Already Bought Six Densified Logs must be true.');
        
        o.Order_Status__c = '3';
        update o;
        
        pr = controller.validateResponse();
    }
    
    @isTest
    static void testRemoveKeyInSessionCache() {
        GDB_Checkout_ValidatePaymentController controller = new GDB_Checkout_ValidatePaymentController();
        
        Cache.Session.put('test', 'test');
        
        controller.removeKeyInSessionCache('test');
        
        System.assertEquals(false, Cache.Session.contains('test'),'test key mus be removed.');
    }
}