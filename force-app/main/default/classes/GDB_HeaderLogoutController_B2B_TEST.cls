@isTest
private class GDB_HeaderLogoutController_B2B_TEST {
    @isTest
    static void getHomePage() {        
        
        Map<String, String> details = GDB_HeaderLogoutController_B2B.getCustomerDetails();
        Map<String, String> urls = GDB_HeaderLogoutController_B2B.getURLs();
        
        System.assertNotEquals(null, details, 'The details should not be null.');
        System.assertNotEquals(null, urls, 'The urls should not be null.');
    }
}