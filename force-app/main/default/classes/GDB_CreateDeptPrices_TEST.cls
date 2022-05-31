@isTest
private class GDB_CreateDeptPrices_TEST {

    @isTest
    static void test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createWarehouseArticleJunction();

        GDB_CreateDeptPrices.createPrices('AAA_1','AAA_2','GDB_P55','GDB_BOX_1','BBB_3');
        List<GDB_Department_Has_WarehouseProd__c> dhwList = [SELECT Id FROM GDB_Department_Has_WarehouseProd__c WHERE Name LIKE 'DEPT%'];
        System.assertNotEquals(0, dhwList.size());
    }
}