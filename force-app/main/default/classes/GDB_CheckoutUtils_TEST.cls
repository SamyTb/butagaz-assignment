@isTest
private class GDB_CheckoutUtils_TEST { 

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
}

@isTest
static void testNullReturnValues() {
    GDB_CheckoutUtils.getTotals(null);
    GDB_CheckoutUtils.verifyAddressFields(null);
    GDB_CheckoutUtils.verifyStock(null);
    GDB_CheckoutUtils.validateCheckoutStep(null);
    GDB_CheckoutUtils.getAvailableShippingCountries();
    GDB_CheckoutUtils.getAvailableBillingCountries();
    GDB_CheckoutUtils.getAvailableAccountCountries();
    GDB_CheckoutUtils.getAvailableShippingSalutations();
    GDB_CheckoutUtils.getAvailableBillingSalutations();
    GDB_CheckoutUtils.getAvailableAccountSalutations();
}

@isTest
static void testGoodReturnValues() {

    User u = GDB_TestDataFactory.createCommunityUser();
    Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
    System.runAs(u) {
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        GDB_CheckoutUtils.getTotals(true);
        Order__c o = GDB_OrderMgr.createOrder(b);
        GDB_CheckoutUtils.getTotals(false);
        GDB_CheckoutUtils.verifyAddressFields(b);

    }
}

@isTest
static void testGoodReturnValues2() {

    User u = GDB_TestDataFactory.createCommunityUser();
    Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
    System.runAs(u) {
        GDB_TestDataFactory.createBasket(a);
        GDB_Basket__c b = GDB_TestDataFactory.getBasket();
        b = GDB_BasketMgr.getBasketById(b.Id);
        GDB_TestDataFactory.createBasketProduct(b);

        GDB_CheckoutUtils.verifyAddressFields(b);
        GDB_CheckoutUtils.verifyStock(b);
        GDB_CheckoutUtils.getNextCheckoutStepURL(2);
        GDB_CheckoutUtils.getNextCheckoutStepURL(4);
    }
}

@isTest
static void testAddressFields() {

    User u = GDB_TestDataFactory.createCommunityUser();
    System.runAs(u) {
        GDB_CheckoutUtils.verifyAddressFields(null);

        Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
        GDB_TestDataFactory.createBasket(a);
        GDB_Basket__c b = GDB_TestDataFactory.getBasket();
        b = GDB_BasketMgr.getBasketById(b.Id);

        b.gdb_shipping_firstname__c = null;
        b.gdb_billing_firstname__c = null;
        b.gdb_shipping_lastname__c = null;
        b.gdb_billing_lastname__c = null;
        b.gdb_shipping_salutation__c = null;
        b.gdb_billing_salutation__c = null;
        b.gdb_shipping_address1__c = null;
        b.gdb_billing_address1__c = null;
        b.gdb_shipping_city__c = null;
        b.gdb_billing_city__c = null;
        b.gdb_shipping_zip__c = null;
        b.gdb_billing_zip__c = null;
        b.gdb_shipping_country__c = null;
        b.gdb_billing_country__c = null;
        b.gdb_shipping_phone__c = null;
        b.gdb_billing_phone__c = null;
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_firstname__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_firstname__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_lastname__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_lastname__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_salutation__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_salutation__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_address1__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_address1__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_city__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_city__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_zip__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_zip__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_country__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_country__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_shipping_phone__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);

        b.gdb_billing_phone__c = '';
        GDB_CheckoutUtils.verifyAddressFields(b);
    }
}

@isTest
static void testAddressFieldsShipping() {


    User u = GDB_TestDataFactory.createCommunityUser();
    System.runAs(u) {
        GDB_CheckoutUtils.verifyAddressFieldsShipping(null);

        Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
        GDB_TestDataFactory.createBasket(a);
        GDB_Basket__c b = GDB_TestDataFactory.getBasket();
        b = GDB_BasketMgr.getBasketById(b.Id);

        b.gdb_shipping_firstname__c = null;
        b.gdb_billing_firstname__c = null;
        b.gdb_shipping_lastname__c = null;
        b.gdb_billing_lastname__c = null;
        b.gdb_shipping_salutation__c = null;
        b.gdb_billing_salutation__c = null;
        b.gdb_shipping_address1__c = null;
        b.gdb_billing_address1__c = null;
        b.gdb_shipping_city__c = null;
        b.gdb_billing_city__c = null;
        b.gdb_shipping_zip__c = null;
        b.gdb_billing_zip__c = null;
        b.gdb_shipping_country__c = null;
        b.gdb_billing_country__c = null;
        b.gdb_shipping_phone__c = null;
        b.gdb_billing_phone__c = null;
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_firstname__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_lastname__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_salutation__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_address1__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_city__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_zip__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_country__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

        b.gdb_shipping_phone__c = '';
        GDB_CheckoutUtils.verifyAddressFieldsShipping(b);

    }
}
}