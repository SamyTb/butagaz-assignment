@isTest
private with sharing class GDB_QuoteFormController_TEST {

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
    static void testGetAvailableListValues(){
        System.assertNotEquals(null, GDB_QuoteFormController.getAvailableListValues());
    }

    @isTest
    static void testSubmitQuoteForm() {
        Map<String, String> detailsForm = new Map<String, String>();
        Map<String, String> returnObject;
        Map<String, String> returnCaseReasons;
        Case c;

        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u) {
            Account currentCustomer = GDB_QuoteFormController.getCurrentCustomer();
            System.assertNotEquals(null, currentCustomer, 'Should return a customer');

            detailsForm.put('salutation', 'Mme');
            detailsForm.put('firstName', 'Test');
            detailsForm.put('lastName', 'Test');
            detailsForm.put('zipCode', '59000');
            detailsForm.put('message', 'test');
            detailsForm.put('phone', '0000000000');
            detailsForm.put('email', 'test@test.com');
            detailsForm.put('reason', 'CDG01');

            returnObject = GDB_QuoteFormController.submitQuoteForm(detailsForm);
            System.assertNotEquals(null, returnObject, 'Return value should not be null due to a valid map as parameter.');
        }
    }
    
    @isTest
    static void testBulkDeliveredZipCodes()
    {
        GDB_TestDataFactory.createCustomSettings();
        
        Boolean result1 = GDB_QuoteFormController.isZipCodeDeliverable('71000');
        
        System.assertEquals(true, result1, 'Zip code must be bulk delivered.');
        
        Boolean result2 = GDB_QuoteFormController.isZipCodeDeliverable('29000');
        
        System.assertEquals(false, result2, 'Zip code must not be bulk delivered.');
    }
}