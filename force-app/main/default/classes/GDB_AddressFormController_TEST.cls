@isTest
private class GDB_AddressFormController_TEST {
    public static Item__c article;
    public static Item__c article2;
    public static GDB_Basket__c b;
    public static GDB_Basket__c b1;
    public static GDB_Shipping_Method__c sm;
    public static GDB_Promotion__c pm;
    public static GDB_Basket_Product__c bp;
    public static GDB_Warehouse__c w;
    public static GDB_Warehouse_Has_Product__c whp;
    public static Account a;
    public static Activity_Domain__c ad;
    public static Canton__c canton;
    public static City__c city;
    public static City_Postal_Code__c cpc;

    @isTest
    static void testGetAvailableCountries() {
        System.assertNotEquals(null, GDB_AddressFormController.getAvailableCountries('Account'));
        System.assertNotEquals(null, GDB_AddressFormController.getAvailableCountries('BasketShipping'));
        System.assertNotEquals(null, GDB_AddressFormController.getAvailableCountries('BasketBilling'));
        System.assertEquals(null, GDB_AddressFormController.getAvailableCountries(''));
    }

    @isTest
    static void testGetAvailableCities() {
        System.assertNotEquals(null, GDB_AddressFormController.getAvailableCities('29000'));
    }

    @isTest
    static void testsaveCurrentZipCode() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        Account a = GDB_TestDataFactory.createAccount();
        GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        
        System.assertEquals(true, GDB_AddressFormController.saveCurrentZipCode('59000'));
    }
}