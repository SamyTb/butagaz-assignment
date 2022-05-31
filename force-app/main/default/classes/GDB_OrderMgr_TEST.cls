@isTest
private class GDB_OrderMgr_TEST {

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

        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        }
    }

    @isTest
    static void testNullReturnValues() {
        System.assertEquals(null, GDB_OrderMgr.createOrder(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.createSampleOrder(null), 'Return value should be null due to null-value parameter.'); 
        System.assertEquals(false, GDB_OrderMgr.isSampleOrderFraudSubsected(null), 'Return value should be false due to null-value parameter.');  
        System.assertEquals(null, GDB_OrderMgr.bindBasketProductsToOrderItems(null, false, null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getOrderByOrderNo(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getOrdersForAccount(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getSampleOrdersForAccount(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getChildOrders(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getOrderById(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.getOrderByName(null), 'Return value should be null due to null-value parameter.');
        System.assertEquals(null, GDB_OrderMgr.bindBasketToOrderAttributes(null, null, false), 'Return value should be null due to null-value parameter.');
        GDB_OrderMgr.successOrder(null);
        GDB_OrderMgr.failOrder(null,'');
        GDB_OrderMgr.applyDiscountOnCustomer(null);
        GDB_OrderMgr.updateOrderPaymentDetails(null, null, null);
        GDB_OrderMgr.updateOrderStatus(null, null);
        GDB_OrderMgr.updatePaymentStatus(null, null);
        GDB_OrderMgr.decreaseStocks(null);
        GDB_OrderMgr.updateChildOrdersAfterPayment(null);
        GDB_OrderMgr.recalculateOrder(null, false);
    }   
    
     /**
     * This will test methods by sending fake parameters for getOrderByOrderNo.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetOrderByOrderNoWitkFakeParam() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            
            System.assertEquals(null, GDB_OrderMgr.getOrderByOrderNo('abcdef'), 'Return value should be null due to non-null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for getOrderByOrderNo.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetOrderByOrderNo() {
        User u = GDB_TestDataFactory.createCommunityUser();

        System.runAs(u) {
            Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);

            System.assertNotEquals(null, GDB_OrderMgr.getOrderByOrderNo(o.gdb_orderNo__c), 'Return value should not be null due to non-null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for getOrdersForAccount.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetOrdersForAccount() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            
            System.assertNotEquals(null, GDB_OrderMgr.getOrdersForAccount(u.AccountId), 'Return value should not be null due to non-null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for getSampleOrdersForAccount.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetSampleOrdersForAccount() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            
            System.assertNotEquals(null, GDB_OrderMgr.getSampleOrdersForAccount(u.AccountId), 'Return value should be null due to null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for getChildOrders.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetChildOrders() {
        GDB_TestDataFactory.createCustomSettings();
        User u = GDB_TestDataFactory.createCommunityUser(null); 
        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);
            GDB_OrderMgr.recalculateOrder(o, true);  
            System.assertNotEquals(null, GDB_OrderMgr.getChildOrders(o.Id), 'Return value should be null due to null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending fake parameters for getOrderByName.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetOrderByNameWithFakeParam() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            
            System.assertEquals(null, GDB_OrderMgr.getOrderByName('test'), 'Return value should be null due to null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for getOrderByName.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testReturnValuesForGetOrderByName() {
        User u = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];

        System.runAs(u) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);
            
            System.assertNotEquals(null, GDB_OrderMgr.getOrderByName(o.Name), 'Return value should be null due to null-value parameter.');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for successOrder.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testSuccessOrder() {
        User u = GDB_OrderMgr_TEST.getUser();
        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.successOrder(o);
        }
    }
    
     /**
     * This will test methods by sending existing parameters for failOrder.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testFailOrder() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();

            GDB_OrderMgr.failOrder(o,'05'); // 05 = Autorisation refusée
        }
    }
    
     /**
     * This will test methods by sending existing parameters for applyDiscountOnCustomer.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testApplyDiscountOnCustomer() {
        User u = GDB_TestDataFactory.createCommunityUser(null);

        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 
            GDB_TestDataFactory.createPromotion();
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Order__c o = GDB_OrderMgr.createOrder(b);
            GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
            o.gdb_Discount__c = p.id;
            GDB_OrderMgr.applyDiscountOnCustomer(o);
        }
    }
    
     /**
     * This will test methods by sending existing parameters for updateOrderPaymentDetails.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testUpdateOrderPaymentDetails() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.updateOrderPaymentDetails(o, '', 'aaaaaaaa');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for updateOrderStatus.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testUpdateOrderStatus() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.updateOrderStatus(o, 'aaaaaaaa');
        }
    }
    
     /**
     * This will test methods by sending existing parameters for updatePaymentStatus.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testUpdatePaymentStatus() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();  
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.updatePaymentStatus(o, 'aaaaaaaa');
        }
    }
    
     /**
     * This will test methods by sending existing number parameters for updateOrderStatus.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testUpdateOrderStatusWithNumber() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.updateOrderStatus(o, '59');
        }
    }
    
     /**
     * This will test methods by sending existing number parameters for updatePaymentStatus.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testUpdatePaymentStatusWithNumber() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
            
            GDB_OrderMgr.updatePaymentStatus(o, '59');
        }
    }
    
    /**
     * This will test methods by sending existing parameters for recalculateOrder.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testRecalculateOrder() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Account a = GDB_AccountMgr.getCurrentCustomer();
            Order__c o = initializeOrderForTest();
       
            GDB_OrderMgr.recalculateOrder(o, true);
        }
    }
    
    /**
     * This will test methods by sending basket for createOrder.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testCreateOrderMethodWithBasket() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            GDB_Basket__c b = GDB_BasketMgr.getCurrentBasket(true);
            b.gdb_multiple_shipping__c = true;
            Account a = GDB_AccountMgr.getCurrentCustomer();

            o = GDB_OrderMgr.createOrder(null);
            // Check if the order is null because basket not associate with a user
            System.assertEquals(null, o, 'Return value should be null.');

            b.gdb_Account__c = u.AccountId;

            o = GDB_OrderMgr.getOrderById(GDB_OrderMgr.createOrder(b).Id);
            // Check if the order is successfully created
            System.assertNotEquals(null, o, 'Return value should not be null.');
        }
    }
    
     /**
     * This will test methods by sending basket for createOrder B2B.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testCreateOrderB2BFail() {
        User u = GDB_TestDataFactory.createCommunityUser(null);

        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
               a.Street_Number__c = '21';
            }

            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            b.gdb_Account__c = u.AccountId;
            b.gdb_isB2B__c = true;
            update b;

            Order__c o = GDB_OrderMgr.createOrderB2B(b);
            Order__c o1 = GDB_OrderMgr.getCurrentOrder();
            System.assertEquals(null, o, 'Return value should be null.');
        }
    }   
    
        /**
     * This will test methods for contorl Order params.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest   
    static void testOrderMethodControl() {
    GDB_TestDataFactory.createCustomSettings();
    User u = GDB_TestDataFactory.createCommunityUser(null);

    System.runAs(u) {
        Account a;
        List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(users != null || !users.isEmpty()) {
            a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
        } 
        
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        Order__c o = GDB_OrderMgr.createOrder(b); 
        b.gdb_Account__c = u.AccountId;

        // Check if the order is related to the account related to the given basket
        System.assertEquals(u.AccountId, o.Account__c, 'The order should be related to the account related to the basket sent as parameter.');
            
        // Check if the order has one order item
        System.assertNotEquals(null, o.Articles_dans_Commande__r, 'The order items list should not be null.');
        System.assertEquals(0, o.Articles_dans_Commande__r.size(), 'The order items list should contains 1 item.');
        }
    }

    /**
     * This will test the "createOrder" method from the GDB_OrderMgr class
     */
    @isTest
    static void testCreateSampleOrderMethodWithNull() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {
            Order__c o = GDB_OrderMgr.createSampleOrder(null);
            
            // Check if the order is not created
            System.assertEquals(null, o, 'Return value should be null.');
        }
    }
    
        /**
     * This will test the "createOrder" method from the GDB_OrderMgr class
     */
    @isTest
    static void testCreateSampleOrderMethodWithFormButWithoutProduct() {
        User u = GDB_OrderMgr_TEST.getUser();

        System.runAs(u) {

            Map<String, String> detailsForm = new Map<String, String>{
                'salutation' => 'Mme',
                'firstName' => 'aaaaaaaaaaaaaaaaaa',
                'lastName' => 'Test',
                'address1' => '200 boulevard de la resistance',
                'address2' => 'Test',
                'address3' => 'Test',
                'phon' => '0238310237',
                'zip' => '11111',
                'city' => 'MACON',
                'country' => 'France',
                'productId' => 'articleid'
            };

            Order__c o = GDB_OrderMgr.createSampleOrder(detailsForm);
            //Check if the order is null because of no products
            System.assertEquals(null, o, 'Return value should be null.');            
        }
    }
    
    /**
     * This will test the "createOrder" method from the GDB_OrderMgr class
     */
    @isTest
    static void testCreateSampleOrderMethodWithFormButWithProduct() {
    User u = GDB_TestDataFactory.createCommunityUser();
    Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId LIMIT 1];
        System.runAs(u) {
            System.assertNotEquals(null, u.accountId, 'Test Account Id ');
            System.assertNotEquals(null, a, 'Return value should not be null.');

            Map<String, String> detailsForm = new Map<String, String>{
                'salutation' => 'Mme',
                'firstName' => 'aaaaaaaaaaaaaaaaaa',
                'lastName' => 'Test',
                'address1' => '200 boulevard de la resistance',
                'address2' => 'Test',
                'address3' => 'Test',
                'phon' => '0238310237',
                'zip' => '11111',
                'city' => 'MACON',
                'country' => 'France',
                'productId' => 'articleid'
            };

            detailsForm.put('firstName','Test');
            Item__c article_2 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_2'];
            article_2.gdb_issample__c = true;
            update article_2;
            detailsForm.put('productId',article_2.Id);

            Order__c o = GDB_OrderMgr.createSampleOrder(detailsForm);
            // Check if the order is successfully created
            System.assertNotEquals(null, o, 'Return value should not be null.');  
            
            // Check if the order has an account associated
            System.assertNotEquals(null, o.Account__c, 'The order should be related to the current account.');
            
            // Check if the order is successfully set as sample order
            System.assertEquals(true, o.gdb_isSample__c, 'The order should be a sample (gdb_isSample__c === true).');
            
            // Check if the order has the "Enregistrée" status as no fraud has been found
            System.assertEquals('4', o.Order_Status__c, 'The order should be in "Enregistrée" status.');
            
            // Check if the order has one order item
            System.assertNotEquals(null, o.Articles_dans_Commande__r, 'The order items list should not be null.');
            System.assertEquals(1, o.Articles_dans_Commande__r.size(), 'The order items list should contains 1 item.');
            
            article_2.gdb_issample__c = false;
            update article_2;
        }
    }

    @isTest
    static User getUser() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.assertNotEquals(null, u, 'The user should not be null.');
        return u;
    }

    @isTest
    static Order__c initializeOrderForTest() {
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

        return o;
    }

    @isTest
    static void testGetGoogleAnalyticsTrackingForOrder() {
        User u = GDB_TestDataFactory.createCommunityUser(null);

        System.runAs(u) {
            Order__c o = initializeOrderForTest();
            String result = GDB_OrderMgr.getGoogleAnalyticsTrackingForOrder();

            System.assertNotEquals(null, result, 'Return value should not be null');
        }
    }
}