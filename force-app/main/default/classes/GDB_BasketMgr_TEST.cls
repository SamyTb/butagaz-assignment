@isTest
private class GDB_BasketMgr_TEST {

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
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        System.runAs(currentUser) {
            GDB_BasketMgr.createBasket();
            GDB_BasketMgr.removeBasket(null);
            GDB_BasketMgr.recalculateBasket(null);
            GDB_BasketMgr.getCurrentBasket(null);
            GDB_BasketMgr.getBasketById(null);
            GDB_BasketMgr.getBasketLineItemQuantities();
            GDB_BasketMgr.updateLineItemQuantity(null, null);
            GDB_BasketMgr.getShippingAddressAsMap();
            GDB_BasketMgr.getBillingAddressAsMap();
            GDB_BasketMgr.updateAddresses(null, null, null, null);
        }
    }

    @isTest
    static void testBadReturnValues() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        System.runAs(currentUser) {
            GDB_BasketMgr.getCurrentBasket(true);
            GDB_BasketMgr.getCurrentBasket(false);
            GDB_BasketMgr.getBasketById(Id.valueOf('a2D9E000000XxxX'));
            GDB_BasketMgr.updateLineItemQuantity(Id.valueOf('a2E9E000000DlXX'), 10);
            GDB_BasketMgr.updateAddresses(new Map<String, String>(), new Map<String, String>(), 'test', false);
            GDB_BasketMgr.updateAddresses(new Map<String, String>(), new Map<String, String>(), 'test', true);
        }
    }

    @isTest
    static void testGoodReturnValues() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_Basket__c b2 = GDB_BasketMgr.getCurrentBasket(false);
            System.assertNotEquals(null, b, 'b must not be null');
            System.assertNotEquals(null, b2, 'b2 must not be null');
            System.assertEquals(b.Id, b2.Id);
            GDB_BasketMgr.getBasketLineItemQuantities();

            for (GDB_Basket_Product__c bp : b.Basket_Products__r) {
                GDB_BasketMgr.updateLineItemQuantity(bp.Id, 10);
            }

            GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
            b.gdb_Discount__c = p.Id;
            b.gdb_Shipping_Method__c = null;
            
            GDB_BasketMgr.recalculateBasket(b);
        }
    }

    @isTest
    static void testUpdateAddresses() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            
            GDB_BasketMgr.updateAddresses(GDB_BasketMgr.getShippingAddressAsMap(), GDB_BasketMgr.getBillingAddressAsMap(), 'test', true);

            GDB_BasketMgr.removeBasket(b);
        }
    }

    @isTest
    static void testGetMultiplePaymentDetailsForCurrentBasket() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            Map<String, Object> obj = GDB_BasketMgr.getMultiplePaymentDetailsForCurrentBasket(true);
            System.assertNotEquals(null, obj, 'GetMultiplePaymentDetailsForCurrentBasket return shoud be not null');
        }
    }

    @isTest
    static void testUpdateMultipleShipping() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_BasketMgr.updateMultipleShipping(true);
            GDB_BasketMgr.removeBasket(b);
        }
    }

    @isTest
    static void testUpdateAddressShipping() {
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_BasketMgr.updateAddressShipping(new Map<String, String>(), 'test');

            Map<String, String> form = new Map<String, String>();
            form.put('salutation','M');
            form.put('firstname','test');
            form.put('lastname','test');
            form.put('address1','test');
            form.put('address2','test');
            form.put('address3','test');
            form.put('city','test');
            form.put('zip','71000');
            form.put('country','FR');
            form.put('phone','0231021010');

            GDB_BasketMgr.updateAddressShipping(form, 'test');
            GDB_BasketMgr.removeBasket(b);
        }
    }

    @isTest
    public static void testSetGuestBasketToCustomer() {
        GDB_AccountMgr.createNewGuest('71000');
        List<GDB_ArticleVM> products = GDB_ProductUtils.getProducts('');

        if(products.size() > 0) {
            GDB_ProductUtils.addToCart(products[0]);
        }

        User currentUser = GDB_TestDataFactory.createCommunityUser();
        System.runAs(currentUser) {
            Account acc = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId];
            acc.gdb_shipping_zip__c = '75000';
            GDB_BasketMgr.setGuestBasketToCustomer(acc);
        }

    }

    @isTest
    public static void testUpdateZipCodeShipping() {
        
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser) {     
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_BasketMgr.updateZipCodeShipping(null);
            GDB_BasketMgr.updateZipCodeShipping('59000');
            b = GDB_BasketMgr.getCurrentBasket(false);
            System.assertEquals('59000', b.gdb_shipping_zip__c);
        }
    }

    @isTest
    public static void getQuantityMultipleShippingAllowedTest(){
        User currentUser = GDB_TestDataFactory.createCommunityUser();
        Account a = [SELECT Id FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
        System.runAs(currentUser){
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            b = GDB_BasketMgr.getCurrentBasket(false);
            System.assertNotEquals(null, GDB_BasketMgr.getQuantityMultipleShippingAllowed(b));
        }
    }
}