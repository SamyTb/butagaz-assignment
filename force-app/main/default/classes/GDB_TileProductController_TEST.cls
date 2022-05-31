@isTest
private class GDB_TileProductController_TEST {

    @isTest
    static void testAddToGuestCart() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createPaymentMethod();

        String result = GDB_TileProductController.addToGuestCart( new Map<String, String>(), null);
        System.assertEquals(null, result, 'result should be null');

        GDB_ArticleVM item = GDB_ProductUtils.getProducts('').get(0);
        result = GDB_TileProductController.addToGuestCart( new Map<String, String>{'zipcode' => '71000'}, item);
        System.assertNotEquals(null, result, 'result should not be null');

        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        result = GDB_TileProductController.addToGuestCart( new Map<String, String>{
            'zipcode' => guest.get('zipcode'),
            'id' => guest.get('id')
        }, item);
        System.assertNotEquals(null, result, 'result should not be null');

        Map<String, String> newGuest = GDB_TileProductController.createNewGuest('75002');
        System.assertNotEquals(null, newGuest, 'newGuest should not be null');
    }

    @isTest
    static void createNewGuestTest(){
        System.assertNotEquals(null, GDB_TileProductController.createNewGuest('59000'));
    }
}