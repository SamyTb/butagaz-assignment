@isTest
public class GDB_ProductCarouselController_TEST {

    @isTest
    static void testGetMedia() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createArticles();

        Item__c item = [SELECT Id FROM Item__c LIMIT 1];

        GDB_TestDataFactory.createMedia(item.Id);

        List<GDB_article_media__c> result = GDB_ProductCarouselController.getMedia(item.Id);
        System.assertNotEquals(null, result);
    }

}