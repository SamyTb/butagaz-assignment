@isTest
private class GDB_NavigationController_TEST { 
    
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
    static void testGetNavigationURLs() {
        Map<String, String> navigationsUrls = GDB_NavigationController.getNavigationURLs();
    }
    
    @isTest
    static void testGetNavigationURLsB2B() {
        Map<String, String> navigationsUrls = GDB_NavigationController.getNavigationURLsB2B(); 
    }
}