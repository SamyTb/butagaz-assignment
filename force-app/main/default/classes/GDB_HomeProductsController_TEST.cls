@isTest
private class GDB_HomeProductsController_TEST {

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
    static void testGetProducts(){
        System.assertNotEquals(0, GDB_HomeProductsController.getProducts('').size());
    }

    @isTest
    static void testGetSampleInfos(){
        System.assertNotEquals(null, GDB_HomeProductsController.getSampleInfos());
    }

    @isTest
    static void testIsAuthenticated(){
        System.assertEquals(true, GDB_HomeProductsController.isAuthenticated());
    }

    @isTest
    static void testGetCurrentCustomer(){
        User u = GDB_TestDataFactory.createCommunityUser(null); 
        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 
            System.assertNotEquals(null, GDB_HomeProductsController.getCurrentCustomer());
        }
    }

    @isTest
    static void testAddToCart(){
        insert new Item__c(
            gdb_description__c = 'test',
            Code_Article__c = '123456789',
            Name = 'test'
        );

        User guestUser = [select id, name from User where userType = 'Guest' Limit 1];
        System.runAs(guestUser){
            GDB_ArticleVM article = GDB_ProductUtils.getProducts(null)[0];
            System.assertNotEquals('', GDB_HomeProductsController.addToCart(article, new Map<String, String>{'zipcode' => '71000'}));
        }
    }
}