@isTest
public with sharing class GDB_Google_MapController_TEST {
    @isTest
    static void testGetLocations() {
        GDB_TestDataFactory.createCustomSettings();
        List<String> filters = new List<String>();
        filters.add('PR');
        filters.add('RE');

        Account a = GDB_TestDataFactory.createAccount();
        a.Channel__c = 'RE';
        a.gdb_available_on_google_map__c = true;
        insert a;
 
        Map<String, List<GDB_LocationVM.Location>> allLocations = GDB_Google_MapController.getAllLocations(filters);
        System.assertNotEquals(null, allLocations, 'The list should not be null.');


        Map<String,String> accountType = GDB_Google_MapController.getAccountType();
        System.assertNotEquals(null, accountType, 'The map should not be null.');
    }
}