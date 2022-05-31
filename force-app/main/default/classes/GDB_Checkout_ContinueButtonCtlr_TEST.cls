@isTest
private class GDB_Checkout_ContinueButtonCtlr_TEST { 
    
    public static Map<String, String> guest {get;set;}
    
    @testSetup
    static void setup() {
        guest = GDB_AccountMgr.createNewGuest('71000');
    }

    @isTest
    static void testSubmitContinueButtonStep1() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_TestDataFactory.createBasket(null);
            Map<String, String> ret = GDB_Checkout_ContinueButtonController.submitContinueButton(1, guest);
            System.assertNotEquals(null, GDB_Checkout_ContinueButtonController.getPreviousStepsURLs(), 'Return value should not be null');
            System.assertNotEquals(null, ret, 'Return value should not be null');
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
        }
    }

    @isTest
    static void testGetPSPRedirectionDetails() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        // Fail test
        Map<String, Object> ret = GDB_Checkout_ContinueButtonController.getPSPRedirectionDetails();
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertEquals(0, ret.size(), 'Return value should be empty');

        // Success test
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
                a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
                u = users.get(0);
            }
            
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            b.gdb_Account__c = u.AccountId;
            update b;

            Order__c o = GDB_OrderMgr.createOrder(b);

            ret = GDB_Checkout_ContinueButtonController.getPSPRedirectionDetails();
            System.assertNotEquals(null, ret, 'Return value should not be null');
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
        }
    }
    
    @isTest
    static void testgetReturnForTest() { 
        Boolean test = GDB_Checkout_ContinueButtonController.getReturnForTest(true);
        GDB_Checkout_ContinueButtonController.getReturnForTest(test);
    }
    
    @isTest
    static void testIsAuthenticated() { 
        System.assertNotEquals(null, GDB_Checkout_ContinueButtonController.isAuthenticated());
    }
    
    @isTest
    static void testGetPreviousStepURLs() { 
        Map<String, String> urls = GDB_Checkout_ContinueButtonController.getPreviousStepsURLs();
        System.assertNotEquals(null, urls);
    }
    
    @isTest
    static void testRedirectToCart() {
        GDB_TestDataFactory.createCustomSettings();
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            String res = GDB_Checkout_ContinueButtonController.redirectToCart(true);
            System.assertEquals(null, res);
        }
    }
}