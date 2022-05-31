@isTest
private class GDB_AddressMgr_TEST {
    public static Canton__c canton;
    public static City__c city;
    public static City_Postal_Code__c cpc;
    /**
     * This will test methods by sending empty parameters.
     * This will ensure that methods won't crash and return correct values even if parameters are not sent to the methods
     */
    @isTest
    static void testEmptyReturnValues() {
        List<String> cities = GDB_AddressMgr.getCitiesForZipCode(null);
        System.assertNotEquals(null, cities, 'Return value should be an empty list due to null-value parameter.');
        System.assertEquals(0, cities.size(), 'Return value should be an empty list due to null-value parameter.');
    }

    /**
     * This will test methods by sending correct parameters.
     * This will ensure that methods returns correct values when sending correct parameters
     */
    @isTest
    static void testCorrectReturnValues() {
        initializeObjects();

        List<String> cities = GDB_AddressMgr.getCitiesForZipCode('11111');
        System.assertNotEquals(new List<String>(), cities, 'Return value should not be an empty list.');
        System.assertNotEquals(0, cities.size(), 'Return value should not be an empty list.');
    }

    @isTest
    static void initializeObjects() {
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
    }
}