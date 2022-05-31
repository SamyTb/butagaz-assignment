@isTest
private class GDB_ProductDetailController_TEST {

    @isTest
    static void isUniquePriceOnWarehouses_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();

        Item__c article_1 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_1' LIMIT 1];
        Boolean ret = GDB_ProductDetailController.isUniquePriceOnWarehouses(article_1.ID);

        System.assertEquals(true, ret, 'Return value should be true');
    }

    // un user n'a pas encore acheté l'échantillon gratuit
    @isTest
    static void isCustomerNotAlreadyBoughtSampleProduct_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPaymentMethod();
        User guestUser = GDB_TestDataFactory.getGuestUser();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_TestDataFactory.createSampleOrder(null);
            Order__c sampleOrder = [SELECT ID FROM Order__c WHERE gdb_isSample__c = true LIMIT 1];
            GDB_TestDataFactory.createSampleItemsInSampleOrder(sampleOrder);
        }

        Item__c article_1 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_1'];

        System.runAs(guestUser) {
            // test d'un echantillon non acheté
            Map<String, Boolean> ret = GDB_ProductDetailController.isCustomerAlreadyBoughtSampleProduct();
        }
    }

    // un user a acheté l'échantillon gratuit
    @isTest
    static void isCustomerAlreadyBoughtSampleProduct_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPaymentMethod();
        User guestUser = GDB_TestDataFactory.getGuestUser();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_TestDataFactory.createOrder(null);
            Order__c sampleOrder = [SELECT ID FROM Order__c WHERE gdb_isSample__c = false LIMIT 1];
            GDB_TestDataFactory.createItemsInOrder(sampleOrder);
        }

        Item__c article_1 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_1'];

        System.runAs(guestUser) {
            // test d'un echantillon non acheté
            Map<String, Boolean> ret = GDB_ProductDetailController.isCustomerAlreadyBoughtSampleProduct();
        }
    }

        @isTest
    static void testGetCurrentCustomer() {
        GDB_ProductDetailController.getCurrentCustomer();
    }

    @isTest
    static void testGetProductPrice() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPaymentMethod();

        Item__c item = [SELECT Id FROM Item__c LIMIT 1].get(0);
        Map<String, Object> result = GDB_ProductDetailController.getProductPrice(item.Id, null);
        System.assertEquals(null, result);

        result = GDB_ProductDetailController.getProductPrice(item.Id, new Map<String, String>{'zipcode' => '71000'});
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testAddToGuestCart() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPaymentMethod();

        String result = GDB_ProductDetailController.addToGuestCart( new Map<String, String>(), null);
        System.assertEquals(null, result);

        GDB_ArticleVM item = GDB_ProductUtils.getProducts('').get(0);
        result = GDB_ProductDetailController.addToGuestCart( new Map<String, String>{'zipcode' => '71000'}, item);
        System.assertNotEquals(null, result);

        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        result = GDB_ProductDetailController.addToGuestCart( new Map<String, String>{
            'zipcode' => guest.get('ZipCode'),
            'id' => guest.get('Id')
        }, item);
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetProductLowerPrice() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();

        Item__c item = [SELECT Id FROM Item__c LIMIT 1];
        System.assertNotEquals(0, GDB_ProductDetailController.getProductLowerPrice(item.Id));
    }

    @isTest
    static void testCreateNewGuest() {
        Map<String, String> newGuest = GDB_ProductDetailController.createNewGuest('75002');
        System.assertNotEquals(null, newGuest, 'newGuest should not be null');
    }

    @isTest
    static void testGetHomePage() {
        GDB_TestDataFactory.createCustomSettings();
        Map<String, String> homePage = GDB_ProductDetailController.getHomePage();
        System.assertNotEquals(null, homePage, 'homePage should not be null');
    }
}