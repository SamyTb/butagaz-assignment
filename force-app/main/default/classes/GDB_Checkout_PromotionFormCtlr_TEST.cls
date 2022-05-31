@isTest
private class GDB_Checkout_PromotionFormCtlr_TEST {
    
    public static Map<String, String> guest {get;set;}
    
    @testSetup
    static void setup() {
        guest = GDB_AccountMgr.createNewGuest('71000');
    }
    
    @isTest
    static void testSubmitCouponCode() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();        
        
        System.runAs(u) {
            GDB_TestDataFactory.createCustomSettings();                  
            GDB_TestDataFactory.createShippingMethod();
            GDB_TestDataFactory.createPromotion();
            GDB_TestDataFactory.createWarehouses();
            GDB_TestDataFactory.createArticles();
        
            Map<String, String> ret = GDB_Checkout_PromotionFormController.submitCouponCode('TEST', guest);            
        
            System.assertNotEquals(null, ret, 'Return value should not be null');
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
        }
    }
    
    @isTest
    static void testSubmitCouponCodeWithBasket() {        
        User u = GDB_TestDataFactory.getCommunityUserByProfile();        
        
        System.runAs(u) {         
            //Initialisation des objets
            GDB_TestDataFactory.createCustomSettings();        
            GDB_TestDataFactory.createShippingMethod();
            GDB_TestDataFactory.createPromotion();
            GDB_TestDataFactory.createWarehouses();
            GDB_TestDataFactory.createArticles();
            
            // Basket = null
            Map<String, String> ret = GDB_Checkout_PromotionFormController.submitCouponCode('BASKETPROMO_PRICE', guest);            
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
            System.assertEquals(System.Label.GDB_cannotAddPromotion, ret.get('errorMessage'), 'Return value should be ' + System.Label.GDB_cannotAddPromotion);
            System.assertEquals('false', ret.get('success'), 'Return value should be "false"');            
            
            // Basket != null avec une promo existante
            ret = GDB_Checkout_PromotionFormController.submitCouponCode('PROMO_PRICE ', guest);             
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
            System.assertEquals(System.Label.GDB_removePromotionBeforeAddingANewOne, ret.get('errorMessage'), 'Return value should be ' + System.Label.GDB_removePromotionBeforeAddingANewOne);
            System.assertEquals('false', ret.get('success'), 'Return value should be "false"');

            // basket != null sans promo
            ret = GDB_Checkout_PromotionFormController.submitCouponCode('TESTPROMO_PRICE', guest);            
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');
            System.assertEquals('panier', ret.get('returnURL'), 'Return value should be "panier"');
            System.assertEquals('true', ret.get('success'), 'Return value should be "true"'); 
        }
    }
        
    @isTest
    static void testRemoveCouponCodeWithoutBasket() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();        
        
        System.runAs(u) {         
            GDB_TestDataFactory.createCustomSettings();        
            GDB_TestDataFactory.createShippingMethod();
            GDB_TestDataFactory.createPromotion();
            GDB_TestDataFactory.createWarehouses();
            GDB_TestDataFactory.createArticles();
            
            Map<String, String> ret = GDB_Checkout_PromotionFormController.removeCouponCode(guest);
            System.assertNotEquals(null, ret, 'Return value should not be null');
            System.assertNotEquals(0, ret.size(), 'Return value should not be empty');    
        }    
    } 
}