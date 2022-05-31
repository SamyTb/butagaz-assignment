@isTest
private class GDB_WarehouseMgr_TEST {
    public static GDB_Basket__c b;
    public static Account a;
    public static Activity_Domain__c ad;
    public static Canton__c canton;
    public static City__c city;
    public static City_Postal_Code__c cpc;
    public static GDB_Warehouse__c w;

    @isTest
    static void testFindWarehouseBasedOnZipCodeWithZipCodeNull() {
        w = GDB_WarehouseMgr.findWarehouseBasedOnZipCode(null, null);
        System.assertEquals(null, w, 'Return value should be null');
    }

    @isTest
    static void testFindWarehouseBasedOnZipCodeWithEmptyZipCode() {
        w = GDB_WarehouseMgr.findWarehouseBasedOnZipCode('', false);
        System.assertEquals(null, w, 'Return value should be null');
    }

    @isTest
    static void testFindWarehouseBasedOnZipCodeWithZipCodeAvailable() {
        GDB_TestDataFactory.createWarehouses();
        w = GDB_WarehouseMgr.findWarehouseBasedOnZipCode('71000', false);
        System.assertNotEquals(null, w, 'Return value should not be null');
    }

    @isTest
    static void testFindWarehouseBasedOnZipCodeWithBadZipCode() {
        GDB_TestDataFactory.createWarehouses();
        w = GDB_WarehouseMgr.findWarehouseBasedOnZipCode('98000', false);
        System.assertEquals(null, w, 'Return value should be null');
    }

    @isTest
    static void testUpdateWarehouseWithBasketNull() {
        Id wId = Id.valueOf(GDB_TestDataFactory.getGlobalAccountId());
        GDB_WarehouseMgr.updateWarehouse(null, '');
    }

    @isTest
    static void testUpdateWarehouseWithBasketNotNull() {
        initializeObjects();
        b = GDB_BasketMgr.getBasketById((GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a)).Id);
        GDB_WarehouseMgr.updateWarehouse(b, '71000');
    }

    @isTest
    static void testUpdateWarehouseWithBasketWithoutBasketProduct() {
        initializeObjects();
        GDB_TestDataFactory.createBasket(a);
        b = GDB_TestDataFactory.getBasket();
        GDB_WarehouseMgr.updateWarehouse(b, '71000');
    }

    @isTest
    static void testUpdateWarehouseWithBasketNotNullAndBadIdWarehouse() {
        initializeObjects();
        b = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
        Id wId = Id.valueOf(GDB_TestDataFactory.getGlobalAccountId());
        GDB_WarehouseMgr.updateWarehouse(b, '71000');
    }

    static void initializeObjects() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        w = GDB_TestDataFactory.getWarehouseByReference('Dépôt_1');

        canton = new Canton__c(
            Name = 'TestCanton',
            INSEE_Code__c = '12345'
        );
        insert canton;

        city = new City__c(
            Name = 'TestCity',
            Canton__c = canton.Id
        );
        insert city;

        cpc = new City_Postal_Code__c(
            City__c = city.Id,
            Postal_Code__c = '11111',
            HEXAPOSTE_Code__c = '111111'
        );
        insert cpc;

        ad = GDB_TestDataFactory.getActivityDomain();

        a = new Account(
            FirstName = 'Test',
            LastName = 'Test',
            Phone = '0123456789',
            Email__c = 'ordermgrtest@test.com',
            Activity_Domain__c = ad.Id,
            City_Postal_Code__c = cpc.Id
        );
    }
}