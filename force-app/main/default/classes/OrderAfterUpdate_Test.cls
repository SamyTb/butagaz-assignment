@isTest private class OrderAfterUpdate_Test 
{
	@isTest static void TestShippingMethodIncrementing()
    {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_Shipping_Method__c shippingMethod = GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        
        Order__c order = GDB_TestDataFactory.createOrder(null);
        
        shippingMethod.gdb_number_of_remaining_use__c = 0;
        
        update shippingMethod;
        
        order.Order_Status__c = '8';
        
        update order;
        
        order.Order_Status__c = '11';
        
        update order;
        
        shippingMethod = [SELECT gdb_number_of_remaining_use__c FROM GDB_Shipping_Method__c WHERE Id = :shippingMethod.Id];
        
        System.assertEquals(1, shippingMethod.gdb_number_of_remaining_use__c, 'Unexpected number of remaining use on Shipping Method.');
    }
}