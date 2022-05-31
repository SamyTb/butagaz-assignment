@isTest
private class GDB_Checkout_AddressesController_TEST {
    @isTest
    static void testGetCurrentBasket() { 
        GDB_Basket__c b = GDB_Checkout_AddressesController.getCurrentBasket();
        System.assertEquals(null, b, 'Return value should be null');
    }

    @isTest
    static void testGetAvailableListValues() {
        Map<String, List<Map<String, String>>> ret = GDB_Checkout_AddressesController.getAvailableListValues('', '');
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
    }

    @isTest
    static void testGetAddressFieldsWithoutCurrentBasket() {
        Map<String, Map<String, String>> ret = GDB_Checkout_AddressesController.getAddressFields();
        System.assertEquals(null, ret, 'Return value should not be null');
    }

    @isTest
    static void testGetAddressFieldsWithCurrentBasket() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.createCommunityUser(null);
        System.runAs(u) {
            GDB_TestDataFactory.createAndGetBasketWithBasketProduct(null);
            Map<String, Map<String, String>> ret = GDB_Checkout_AddressesController.getAddressFields();
            System.assertEquals(null, ret, 'Return value should be null');
        }
    }

    @isTest
    static void testGetAddressFieldsWithCurrentBasketAsAdminUser() {
        GDB_TestDataFactory.createCustomSettings();
        User adminUser = GDB_TestDataFactory.getAdminUser();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createBasket(null);
        System.runAs(adminUser) {
            Map<String, Map<String, String>> ret = GDB_Checkout_AddressesController.getAddressFields();
            System.assertEquals(null, ret, 'Return value should be null');
        }
    }

    @isTest
    static void testSaveShippingAndBilling() {
        Map<String, String> shippingForm = new Map<String, String>();
        Map<String, String> billingForm = new Map<String, String>();
        String shippingInstructions = '';
        Boolean useShippingAsBilling = true;
        Boolean ret = GDB_Checkout_AddressesController.saveShippingAndBilling(shippingForm, billingForm, shippingInstructions, useShippingAsBilling);
        System.assertNotEquals(true, ret, 'Return value should not be true');
    }
    
    @isTest
    static void testGetCurrentCustomer(){
        GDB_Checkout_AddressesController.getCurrentCustomer();   
    } 
    
    @isTest
    static void testGetCurrentAccountREByContract(){
        GDB_TestDataFactory.createCustomSettings();
        
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_Checkout_AddressesController.getCurrentAccountREByContract();   
        }
    } 
    
    @isTest
    static void testSaveShipping(){
        Map<String, String> shippingForm = new Map<String, String>();
        String shippingInstructions = '';
        GDB_Checkout_AddressesController.saveShipping(shippingForm, shippingInstructions);   
    }
}