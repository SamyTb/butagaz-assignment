@isTest
private class GDB_DiscountMgr_TEST {

    @isTest
    static void testGetFirstApplicablePromotionWithoutPromotion() {
        Account a = new Account();
        GDB_Promotion__c p = GDB_DiscountMgr.getFirstApplicablePromotion(a);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetFirstApplicablePromotionWithAccountNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_DiscountMgr.getFirstApplicablePromotion(null);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPromotionByCouponCodeWithoutPromotion() {
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionByCouponCode('NO_CODE');
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPromotionByCouponCodeNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionByCouponCode(null);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPromotionByCouponCodeNotNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionByCouponCode('PROMO_PRICE');
        System.assertNotEquals(null, p, 'Return value should not be null');
    }

    @isTest
    static void testGetPromotionByIdNotFound() {
        GDB_TestDataFactory.createPromotion();
        Id promotionId = Id.valueOf('001xa000003DIlo');
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionById(promotionId);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPromotionByIdNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionById(null);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPromotionByIdNotNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c selectedP = GDB_TestDataFactory.getPromotion();
        GDB_Promotion__c p = GDB_DiscountMgr.getPromotionById(selectedP.Id);
        System.assertNotEquals(null, p, 'Return value should not be null');
    }

    @isTest
    static void testIsCustomerAlreadyHadPromotionWithAccountNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
        Boolean hasPromotion = GDB_DiscountMgr.isCustomerAlreadyHadPromotion(null, p);
        System.assertEquals(false, hasPromotion, 'Return value should be false');
    }

    @isTest
    static void testIsCustomerAlreadyHadPromotionWithPromotionNull() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createPromotion();
        Account a = GDB_TestDataFactory.getGlobalAccount();
        Boolean hasPromotion = GDB_DiscountMgr.isCustomerAlreadyHadPromotion(a, null);
        System.assertEquals(false, hasPromotion, 'Return value should be false');
    }

    @isTest
    static void testIsCustomerAlreadyHadPromotionWithoutNumberOfUsePerUser() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createPromotionWithoutNumberOfUsePerUser();
        GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
        Account a = GDB_TestDataFactory.getGlobalAccount();
        Boolean hasPromotion = GDB_DiscountMgr.isCustomerAlreadyHadPromotion(a, p);
        System.assertEquals(false, hasPromotion, 'Return value should be false');
    }

    @isTest
    static void testRemovePromotionOnBasket() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_TestDataFactory.createBasket(null);
            GDB_Basket__c b = GDB_TestDataFactory.getBasket();
            GDB_DiscountMgr.removePromotionOnBasket(b);
        }
    }

    @isTest
    static void testRemovePromotionOnBasketNull() {
        GDB_DiscountMgr.removePromotionOnBasket(null);
    }

    @isTest
    static void testApplyPromotionOnBasketWithPercentagePromotion() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_TestDataFactory.createPromotion();
            GDB_Promotion__c p = GDB_TestDataFactory.getPourcentagePromotion();
            GDB_TestDataFactory.createBasket(null);
            GDB_Basket__c b = GDB_TestDataFactory.getBasket();
            GDB_DiscountMgr.applyPromotionOnBasket(b, p);
        }
    }


    @isTest
    static void testApplyPromotionOnBasketWithPricePromotion() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
	        GDB_TestDataFactory.createPromotion();
	        GDB_Promotion__c p = GDB_TestDataFactory.getPricePromotion();
            GDB_TestDataFactory.createBasket(null);
            GDB_Basket__c b = GDB_TestDataFactory.getBasket();
            GDB_DiscountMgr.applyPromotionOnBasket(b, p);
        }
    }


    @isTest
    static void testApplyPromotionOnBasketWithPromotionWithoutType() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
	        GDB_TestDataFactory.createPromotion();
	        GDB_Promotion__c p = GDB_TestDataFactory.getPromotionWithoutType();
            GDB_TestDataFactory.createBasket(null);
            GDB_Basket__c b = GDB_TestDataFactory.getBasket();
            GDB_DiscountMgr.applyPromotionOnBasket(b, p);
        }
    }

    @isTest
    static void testApplyPromotionOnBasketWithPromotionWithBadType() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPaymentMethod();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
	        GDB_TestDataFactory.createPromotion();
	        GDB_Promotion__c p = GDB_TestDataFactory.getPromotionBadType();
            GDB_TestDataFactory.createBasket(null);
            GDB_Basket__c b = GDB_TestDataFactory.getBasket();
            GDB_DiscountMgr.applyPromotionOnBasket(b, p);
        }
    }

    @isTest
    static void testApplyPromotionOnBasketWithBasketNull() {
        GDB_TestDataFactory.createPromotion();
        GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
        GDB_DiscountMgr.applyPromotionOnBasket(null, p);
    }

    @isTest
    static void testApplyPromotionOnBasketWithBasketNullAndPromotionNull() {
        GDB_DiscountMgr.applyPromotionOnBasket(null, null);
    }

    @isTest
    static void testdecreaseTotalUses() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();

        User u = GDB_TestDataFactory.createCommunityUser(null);
        GDB_Promotion__c p = GDB_TestDataFactory.getPricePromotion();
        System.runAs(u) {
            Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId];
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
            GDB_DiscountMgr.decreaseTotalUses(p.Id);
        }
        p = GDB_TestDataFactory.getPricePromotion();
        System.assertEquals(0, p.gdb_numberOfTotalUse__c, 'The total uses code must be 0');

    }

    @isTest
    static void testCheckPromotionIsAvailable() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createShippingMethodOption();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();

        User u = GDB_TestDataFactory.createCommunityUser(null);
        GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();

        System.runAs(u) {
            Account a = [SELECT Id FROM Account WHERE Id = :u.AccountId];
            GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithMultiBasketProduct(a);
            

            Boolean isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(null);
            System.assertEquals(false, isAvailable, 'This promotion will be not available');

            isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(p);
            System.assertEquals(true, isAvailable, 'This promotion will be available');

            List<GDB_Shipping_Option__c> smo = [SELECT Id FROM GDB_Shipping_Option__c];
            List<String> shippingOptionsIds = new List<String>();
            shippingOptionsIds.add(String.valueOf(smo.get(0).Id));
            b = GDB_ShippingMgr.updateShippingOptions(b,shippingOptionsIds);

            p.gdb_article__c = b.Basket_Products__r.get(0).gdb_Article__c;
            p.gdb_article_type__c = b.Basket_Products__r.get(0).gdb_Article__r.gdb_item_type__c;
            p.gdb_shipping_method__c = b.gdb_Shipping_Method__c;
            p.gdb_shipping_option__c = smo.get(0).Id;
            p.gdb_quantite_min_article_ou_type_article__c = 1;
            p.gdb_quantite_min_du_panier__c = 1;

            isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(p);
            System.assertEquals(true, isAvailable, 'This promotion will be available');
        }
    }

    @isTest
    static void createSponsorshipDiscountTest(){
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouseArticleJunctionWithSamePrice();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
		User currentUser = GDB_TestDataFactory.createCommunityUser();
        System.runAs(currentUser){
            Account a = [SELECT Id, gdb_parrainage_code__c, RecordTypeId FROM Account WHERE Id = :currentUser.AccountId LIMIT 1];
            GDB_Promotion__c p = [SELECT Id, gdb_coupon_code__c FROM GDB_Promotion__c WHERE gdb_coupon_code__c = :a.gdb_parrainage_code__c];
            System.assertNotEquals(null, p, 'p should not be null');
        }
    }
}