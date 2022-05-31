@isTest
private class GDB_MyAccount_MyOrdersController_TEST {

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
        System.assertEquals(null, GDB_MyAccount_MyOrdersController.getOrdersForCurrentCustomer(), 'Return value should be null due to null-value parameter.');
    }

    @isTest
    static void testGetOrdersForCurrentCustomer() {
    User u = GDB_TestDataFactory.createCommunityUser(null); 

        System.runAs(u){
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 

            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);
            List<Order__c> orders1 = GDB_MyAccount_MyOrdersController.getOrdersForCurrentCustomer();
        }
    }
}