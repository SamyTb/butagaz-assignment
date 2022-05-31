/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GDB_ProductListController_TEST {
    // cas d'un article vide
    @isTest
    static void getProductId_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();

        String ret = GDB_ProductListController.getProductId('truc');
        
        System.assertEquals('', ret, 'Return value should be null');
        
    }
    
    
    // récupère tous les articles dans une liste
    @isTest
    static void getProducts_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        
        List<GDB_ArticleVM> ret = GDB_ProductListController.getProducts('');  
        GDB_ArticleVM article1 = ret.get(0);
        
        System.assertNotEquals(article1, ret.get(1), 'Return value should be an GDB_ArticleVM'); 
        System.assertNotEquals(0, ret.size(), 'Return value should be an integer'); 
    }
    
    
    // récupère tous les articles dans une liste
    @isTest
    static void getProductsWithZipCode_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        
        List<GDB_ArticleVM> ret = GDB_ProductListController.getProductsWithZipCode('', '');  
        GDB_ArticleVM article1 = ret.get(0);
        
        System.assertNotEquals(article1, ret.get(1), 'Return value should be an GDB_ArticleVM'); 
        System.assertNotEquals(0, ret.size(), 'Return value should be an integer'); 
    }
    
    @isTest
    static void addToCart_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
         
        Item__c article_1 = [SELECT ID, Name, gdb_page_url__c FROM Item__c WHERE Name = 'article_1'];
        GDB_ArticleVM art = GDB_ProductUtils.getProducts(article_1.Id).get(0);
        
        String ret = GDB_ProductListController.addToCart(art, 1);
        
        System.assertNotEquals('test', ret, 'Return value should be an URL'); 
        
    }
    
    @isTest
    static void isAuthenticated_test() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createActivityDomain();
        
        User userTest = GDB_TestDataFactory.getGuestUser();
        System.runAs(userTest) {            
        Boolean ret = GDB_ProductListController.isAuthenticated();
        System.assertEquals(false, ret, 'Return value should be false'); 
        }
    }
    
    @isTest
    static void testGetSampleInfos() {
        Map<String, String> ret = GDB_ProductListController.getSampleInfos();
        System.assertNotEquals(null, ret, 'getSampleInfos return shoud be not null');
    }
}