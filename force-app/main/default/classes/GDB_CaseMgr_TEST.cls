@isTest
private with sharing class GDB_CaseMgr_TEST {
    public static Order__c o;

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
    static void testSubmitCase() {

        Map<String, String> detailsForm = new Map<String, String>();
        Map<String, String> returnObject;
        Map<String, String> returnCaseReasons;
        Case c;
        
        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u) {
        Id a = GDB_TestDataFactory.getGlobalAccountId();
            /**
             * This will test error cases of the submitCase method
             */
            // Test with a null value as parameter
            returnObject = GDB_CaseMgr.submitCase(null);
            System.assertNotEquals(null, returnObject, 'Return value should not be null due to a null-value parameter.');
            System.assertEquals('false', returnObject.get('success'), 'Return value should contains the "success" value to "false".');
            System.assertEquals(System.Label.GDB_contactForm_cannotSubmitForm, returnObject.get('message'), 'Return value should contains the "message" value to "System.Label.GDB_contactForm_cannotSubmitForm".');
            
            // Test with an empty map as parameter
            returnObject = GDB_CaseMgr.submitCase(detailsForm);
            System.assertNotEquals(null, returnObject, 'Return value should not be null due to an empty map as parameter.');
            System.assertEquals('false', returnObject.get('success'), 'Return value should contains the "success" value to "false".');
            System.assertEquals(System.Label.GDB_contactForm_fillRequiredFields, returnObject.get('message'), 'Return value should contains the "message" value to "System.Label.GDB_contactForm_fillRequiredFields".');

            // Test with a valid map as parameter the return of case reasons
            // Test with a valid map as parameter but without any account in the DB
            returnCaseReasons = GDB_CaseMgr.getCaseReasons();
            returnCaseReasons = GDB_CaseMgr.getCaseReasonsQuoteForm();

            /**
             * This will test methods by sending correct parameters and verify that the case is successfully submitted.
             */
            detailsForm.put('salutation', 'Mme');
            detailsForm.put('firstName', 'Test');
            detailsForm.put('lastName', 'Test');
            detailsForm.put('zipCode', '59000');
            detailsForm.put('message', 'test');
            detailsForm.put('phone', '0000000000');
            detailsForm.put('email', 'test@test.com');
            detailsForm.put('reason', 'CDG01');

            returnObject = GDB_CaseMgr.submitCase(detailsForm);
            System.assertNotEquals(null, returnObject, 'Return value should not be null due to a valid map as parameter.');
        }
    }
    
    @isTest
    static void testSubmitAnonymousCase() {
        User u = GDB_TestDataFactory.getGuestUser();
        System.runAs(u) {
            Map<String, String> detailsForm = new Map<String, String>();
            
            detailsForm.put('salutation', 'Mme');
            detailsForm.put('firstName', 'Test');
            detailsForm.put('lastName', 'Test');
            detailsForm.put('zipCode', '59000');
            detailsForm.put('message', 'test');
            detailsForm.put('phone', '0000000000');
            detailsForm.put('email', 'test@test.com');
            detailsForm.put('reason', 'CDG01');

            Map<String, String> returnObject = GDB_CaseMgr.submitCase(detailsForm);
            
            System.assertNotEquals(null, returnObject, 'Return value should not be null due to a valid map as parameter.');
        }
    }
}