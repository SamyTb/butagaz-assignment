@isTest
private class GDB_Checkout_PaymentMethodsCtlr_TEST {

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
    static void testGetPaymentMethodDetails() {
        Map<String, Object> ret = GDB_Checkout_PaymentMethodsController.getPaymentMethodDetails();
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertNotEquals(0, ret.size(), 'Return value should not be null');
        GDB_Checkout_PaymentMethodsController.updateMultiplePaymentPrice(false);
    }

    @isTest
    static void testGoodReturnValues() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_Basket__c b2 = GDB_Checkout_PaymentMethodsController.getCurrentBasket();
            System.assertNotEquals(null, b, 'b must not be null');
            System.assertNotEquals(null, b2, 'b2 must not be null');
            System.assertEquals(b.Id, b2.Id, 'Ids must be the same');
        }
    }

}