@isTest
private class GDB_Checkout_Confirm_FooterControl_TEST { 

    @isTest
    static void getCurrentOrder() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        Map<String, Object> ret = GDB_Checkout_Confirm_FooterController.getCurrentOrder();

        System.assertEquals(null, ret, 'Value should be null');
        
        System.runAs(GDB_TestDataFactory.getCommunityUserByProfile()) {
            Account a;
            User u;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
                a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
                u = users.get(0);
            }
            
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            b.gdb_Account__c = u.AccountId;
            update b;

            Order__c o = GDB_OrderMgr.createOrder(b);
            Map<String, Object> result = GDB_Checkout_Confirm_FooterController.getCurrentOrder();
            System.assertNotEquals(null, result, 'Value should not be null');
        }

    }

    @isTest
    static void getHomeURLAction() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createActivityDomain();

        String ret = GDB_Checkout_Confirm_FooterController.getHomeURLAction();

        System.assertNotEquals(null, ret, 'Value should be null');
    }
    
    @isTest
    static void testGetGoogleAnalyticsTrackingForOrder() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createActivityDomain();

        String ret = GDB_Checkout_Confirm_FooterController.getGoogleAnalyticsTrackingForOrder();

        System.assertEquals(null, ret, 'Value should be null');
    }
    
    @isTest
    static void testGetHomeURLActionB2B(){
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Checkout_Confirm_FooterController.getHomeURLActionB2B();
    }
    
    @isTest
    static void testgetCurrentAccount(){
        GDB_Checkout_Confirm_FooterController.getCurrentAccount();
    }
}