@isTest
private class GDB_TagCommander_Controller_TEST {
    @TestSetup
    static void testSetup(){
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
    static void getCurrentBasketTest(){
        Map<String, Object> guest = GDB_AccountMgr.createNewGuest('29000');
        System.assertNotEquals(null, GDB_TagCommander_Controller.getCurrentBasket(guest), 'Return value should not be null' );
    }

    @isTest
    static void getOrderTest(){
        User u = GDB_TestDataFactory.createCommunityUser(null);
        System.runAs(u){
            Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);
            Map<String, Object> currentOrder = GDB_TagCommander_Controller.getOrder();
            System.assertNotEquals(null, currentOrder,'Return value should not be null');
        }
    }
}