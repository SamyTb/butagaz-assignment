@isTest
private class GDB_ArticleVM_TEST {
    
    @TestSetup
    static void makeData(){
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
    }

    @isTest
    static void test() {
        
        List<GDB_ArticleVM> items = GDB_ProductUtils.getProducts(null);
        items.add(new GDB_ArticleVM(null));
        
        System.assertNotEquals(0, items.size(), 'There is no items');
        
        for(Integer i = 0; i < items.size(); i++) {
            GDB_ArticleVM item = items.get(i);
            if(i < items.size() - 1) {
                System.assertNotEquals(0, item.getWarehouseQuantity(), 'Product ' + i + ': Quantity is empty in Warehouse');
                System.assertEquals(true, item.isDisplayedOn('Tuile'), 'Product ' + i + ': is not displayed on Tuile');
                System.assertNotEquals(null, item.getWarehouseId(), 'Product ' + i + ': has no warehouse article junction associated');
            } else {
                System.assertEquals(null, item.getWarehouseQuantity());
                System.assertEquals(false, item.isDisplayedOn('Tuile'));
                System.assertEquals(null, item.getWarehouseId());
            }
        }
    }

    @isTest
    static void testUpdateWarehouse() {
        Account a = GDB_TestDataFactory.getGlobalAccount();
        GDB_Basket__c b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        GDB_WarehouseMgr.updateWarehouse(b, '71000');
    }
}