@isTest
private class GDB_Checkout_ShippingMethodsControl_TEST {

    @TestSetup
    static void setup(){
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createShippingMethodOption();
        
    }
    
    @isTest
    static void testGetShippingMethods() {
        Account a = GDB_TestDataFactory.createAccount();
        insert a;
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        List<GDB_Shipping_Method__c> result = GDB_Checkout_ShippingMethodsController.getShippingMethods(b);
        System.assertNotEquals(null, result, 'result should be not null');
    }
    
    @isTest
    static void TestUpdateShippingMethods() {
        Account a = GDB_TestDataFactory.createAccount();
        insert a;
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);

        List<GDB_Shipping_Method__c> sms = [SELECT Id FROM GDB_Shipping_Method__c];
        GDB_Checkout_ShippingMethodsController.updateShippingMethods(b, String.valueOf(sms.get(0).id));
        System.assertEquals(b.gdb_Shipping_Method__c, sms.get(0).id, 'result should be same');
    }

    @isTest
    static void TestUpdateShippingOptions() {
        Account a = GDB_TestDataFactory.createAccount();
        insert a;
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);

        List<GDB_Shipping_Option__c> sos = [SELECT Id FROM GDB_Shipping_Option__c];
        List<String> listIds = new List<String>();
        for(GDB_Shipping_Option__c so : sos){
            listIds.add(String.valueOf(so.Id));
        }

        GDB_Checkout_ShippingMethodsController.updateShippingOptions(b, listIds);

        List<gdb_basket_shipping_option__c> bso = [SELECT Id FROM gdb_basket_shipping_option__c WHERE gdb_Basket__c =: b.Id];
        System.assertNotEquals(0, bso.size(), 'result should be not null');
    }
}