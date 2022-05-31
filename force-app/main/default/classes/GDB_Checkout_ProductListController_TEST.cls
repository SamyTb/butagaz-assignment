@isTest
private class GDB_Checkout_ProductListController_TEST {
    
    public static Map<String, String> guest {get;set;}
    
    @testSetup
    static void setup() {
        guest = GDB_AccountMgr.createNewGuest('71000');
    }

    @isTest
    static void testGetCurrentBasket() {
        GDB_Basket__c b = GDB_Checkout_ProductListController.getCurrentBasket(guest);
        System.assertEquals(null, b, 'Return value should be null');
    }


    @isTest
    static void testVerifyStock() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createBasket(null);
        Map<String, String> s = GDB_Checkout_ProductListController.verifyStock(guest);
        System.assertNotEquals(null, s, 'Return value should not be null');
        System.assertNotEquals(0, s.size(), 'Return value should not be empty');
    }

    @isTest
    static void testGetCurrentOrder() {
        Order__c o = GDB_Checkout_ProductListController.getCurrentOrder();
        System.assertEquals(null, o, 'Return value should be null');
    }

    @isTest
    static void testSaveQuantity() {
        Id lineItemId = Id.valueOf(GDB_TestDataFactory.getGlobalAccountId());
        GDB_Checkout_ProductListController.saveQuantity(lineItemId, '2', guest);
    }
    
    @isTest
    static void testGetSampleInfos() {
        Map<String, String> ret =  GDB_Checkout_ProductListController.getSampleInfos();
        System.assertNotEquals(null, ret, 'Return value should not be null');
    }
    
    @isTest
    static void testGetGuestBasketErrorsAction() {
        List<Object> error = new List<Map<String, Object>>{
            new Map<String, Object>{
                'errno' => '40',
                'params' => new List<Object>{
                    'test'
                }
            }
        };
        List<Map<String, String>> errors = GDB_Checkout_ProductListController.getGuestBasketErrorsAction(error);
        System.assertNotEquals(null, errors, 'Return value should not be null');
    }
    
    @isTest
    static void testGetHomePage() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Checkout_ProductListController.getHomePage();
        System.assertNotEquals(null, url, 'Return value should not be null');
    }
}