@isTest
private class GDB_ShippingMgr_TEST { 

    @isTest
    static void testGetShippingMethods() {
        GDB_TestDataFactory.createCustomSettings();
        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u){
            Account a = GDB_AccountMgr.getCurrentCustomer();
            GDB_TestDataFactory.createActivityDomain();
            GDB_TestDataFactory.createShippingMethod();
            GDB_TestDataFactory.createShippingMethodOption();
            GDB_TestDataFactory.createShippingMethodPrice();
            GDB_TestDataFactory.createPromotion();
            GDB_TestDataFactory.createPaymentMethod();
            GDB_TestDataFactory.createWarehouses();
            GDB_TestDataFactory.createArticles();

            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            List<GDB_Shipping_Method__c> sms = GDB_ShippingMgr.getShippingMethods(b);

            System.assertNotEquals(null, sms, 'Return value should not be null');
            System.assertNotEquals(0, sms.size(), 'Return value should not be empty');


            delete b;
            GDB_Basket__c b2 = GDB_TestDataFactory.createAndGetBasketWithMultiBasketProduct(a);
            List<GDB_Shipping_Method__c> sms2 = GDB_ShippingMgr.getShippingMethods(b2);

            System.assertNotEquals(null, sms2, 'Return value should not be null');
            System.assertNotEquals(0, sms2.size(), 'Return value should not be empty');

        }

    }

    @isTest
    static void testGetShippingMehtodById() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createShippingMethod();
        List<GDB_Shipping_Method__c> sms = [SELECT Id FROM GDB_Shipping_Method__c];

        GDB_Shipping_Method__c sm = null;
        
        if(sms != null && !sms.isEmpty()){
            sm = GDB_ShippingMgr.getShippingMehtodById(sms.get(0).Id);
        }

        System.assertNotEquals(null, sm, 'Return value should not be null');
    }

    @isTest
    static void testShippingMehtodPriceByIdAndQuantity() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethodOption();
        GDB_TestDataFactory.createShippingMethodPrice();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();

        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u){
            Account a = GDB_AccountMgr.getCurrentCustomer();
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithMultiBasketProduct(a);
            List<GDB_Shipping_Method__c> sm = GDB_ShippingMgr.getShippingMethods(b);
            GDB_BasketMgr.recalculateBasket(b);
            System.assertNotEquals(null, sm, 'Return value should not be null');
        }
    }

    @isTest
    static void testUpdateShippingMethods() {
        GDB_TestDataFactory.createCustomSettings();
        Account a = GDB_TestDataFactory.createAccount();
        insert a;
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createShippingMethodOption();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithMultiBasketProduct(a);
        b.gdb_Shipping_Method__c = null;
        update b;

        List<GDB_Shipping_Method__c> sms = [SELECT Id FROM GDB_Shipping_Method__c];
        GDB_Basket__c basketUpdated = GDB_ShippingMgr.updateShippingMethods(b, String.valueOf(sms.get(0).id));

        System.assertNotEquals(b.gdb_Shipping_Method__c, basketUpdated.gdb_Shipping_Method__c, 'Return value should not be same');
    }

    @isTest
    static void testUpdateShippingOptions() {
        GDB_TestDataFactory.createCustomSettings();
        Account a = GDB_TestDataFactory.createAccount();
        insert a;
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createShippingMethodOption();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithMultiBasketProduct(a);

        List<GDB_Shipping_Option__c> sos = [SELECT Id FROM GDB_Shipping_Option__c];
        List<String> listIds = new List<String>();
        for(GDB_Shipping_Option__c so : sos){
            listIds.add(String.valueOf(so.Id));
        }
        GDB_Basket__c b2 = GDB_ShippingMgr.updateShippingOptions(b, listIds);

        List<gdb_basket_shipping_option__c> bso = [SELECT Id FROM gdb_basket_shipping_option__c WHERE gdb_Basket__c =: b.Id];
        System.assertNotEquals(0, bso.size(), 'Return value should not be null');
    }
}