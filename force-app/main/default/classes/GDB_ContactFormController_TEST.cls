@isTest
private class GDB_ContactFormController_TEST {
    public static Account a;
    public static Order__c o;
    public static Mandataire__c m;
    public static Activity_Domain__c ad;
    public static Map<String, String> mapContact;

    @isTest
    static void testGetCurrentCustomer(){
        System.assertEquals(null, GDB_ContactFormController.getCurrentCustomer(), 'Return should be null');
    }

    @isTest
    static void testGetAvailableListValues(){
        System.assertNotEquals(null, GDB_ContactFormController.getAvailableListValues(), 'Return should not be null');
    }

    @isTest
    static void testSubmitContactForm(){
        System.assertNotEquals(null, GDB_ContactFormController.submitContactForm(null), 'Return should not be null');

        mapContact = new Map<String, String>{
            'salutation' => '',
            'firstName' => 'def',
            'lastName' => 'def',
            'email' => 'def@contactform.com',
            'phone' => '0606060606',
            'reason' => 'CDG01',
            'message' => 'def'
        };

        System.assertNotEquals(null, GDB_ContactFormController.submitContactForm(mapContact), 'Return should not be null');
    }
}