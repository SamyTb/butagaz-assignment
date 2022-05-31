@isTest
private class GDB_HomeProductsB2BController_TEST {
    @TestSetup
    static void setup(){
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticlesB2B();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
    }

    @isTest
    static void testGetProducts(){
        User u = GDB_TestDataFactory.createCommunityUser(null); 
        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 
            System.assertNotEquals(0, GDB_HomeProductsB2BController.getProductsB2B().size());
        }
    }

    @isTest
    static void testIsAuthenticated(){
        System.assertEquals(true, GDB_HomeProductsB2BController.isAuthenticated());
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
            System.assertNotEquals(null, GDB_HomeProductsB2BController.getCurrentCustomer());
        }
    }

    @isTest
    static void testAddToCart(){                      
        GDB_ProduitQuantity_B2B prdQuantity = new GDB_ProduitQuantity_B2B();
        prdQuantity.ImageUrl = '/test.jpg';
        prdQuantity.Item = [SELECT ID, Name, Code_Article__c FROM Item__c WHERE Name = 'article_1'];
        prdQuantity.Quantity = 1; 

        String ProduitQuantity = JSON.serialize(prdQuantity); 
        
        ProduitQuantity = '[' + ProduitQuantity + ']';        
        
        User guestUser = [select id, name from User where userType = 'Guest' Limit 1];
        System.runAs(guestUser){
            System.assertNotEquals('', GDB_HomeProductsB2BController.addToCart(ProduitQuantity));
        }
    }
}