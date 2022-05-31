@isTest
private class GDB_MyAccount_MyAddressesController_TEST {
    
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
    static void testGetCurrentCustomerWithAccount() {
        User u = GDB_TestDataFactory.createCommunityUser(null); 
        System.runAs(u) {
            Account a;
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users != null || !users.isEmpty()) {
               a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            } 
            System.assertNotEquals(null, a, 'Return value should not be null');
        } 
    }

    @isTest
    static void testGetCurrentCustomerWithoutAccount() {
        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u){
            Account account = GDB_MyAccount_MyAddressesController.getCurrentCustomer();
            System.assertNotEquals(null, account, 'Return value should be null');
        }
    }

    @isTest
    static void testGetAvailableListValues() {
        Map<String, List<Map<String, String>>> mapListValues = GDB_MyAccount_MyAddressesController.getAvailableListValues();
        System.assertNotEquals(null, mapListValues, 'Return map should not be null');

        List<Map<String, String>> billingCountries = mapListValues.get('billingCountries');
        System.assertNotEquals(null, billingCountries, 'Billing Countries should not be null');

        List<Map<String, String>> shippingCountries = mapListValues.get('shippingCountries');
        System.assertNotEquals(null, shippingCountries, 'Shipping Countries should not be null');
    }

    @isTest
    static void testSaveShippingAddress() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: 'Customer Community Login User GDB' LIMIT 1];
        User u = [SELECT Id, AccountId, ProfileId, Name FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1];

        Map <String, String> addressMap = new Map<String,String>{
            'salutation' => 'Mr',
            'firstname' => 'firstname',
            'lastname' => 'lastname',
            'address1' => 'address1',
            'address2' => 'address2',
            'address3' => 'address3',
            'city' => 'city',
            'zip' => '71000',
            'country' => 'France',
            'useshippingasbilling' => 'true'
        };

        Map<String, String> result1 = GDB_MyAccount_MyAddressesController.saveShippingAddress(addressMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyAddressesController.saveShippingAddress(addressMap);

            addressMap.put('useshippingasbilling', 'false');

            Map<String, String> result3 = GDB_MyAccount_MyAddressesController.saveShippingAddress(addressMap);
        }
    }

    @isTest
    static void testSaveBillingAddress() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: 'Customer Community Login User GDB' LIMIT 1];
        User u = [SELECT Id, AccountId, ProfileId, Name FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1];

        Map <String, String> addressMap = new Map<String,String>{
            'salutation' => 'Mr',
            'firstname' => 'firstname',
            'lastname' => 'lastname',
            'address1' => 'address1',
            'address2' => 'address2',
            'address3' => 'address3',
            'city' => 'city',
            'zip' => '71000',
            'country' => 'France',
            'useshippingasbilling' => 'true'
        };

        Map<String, String> result1 = GDB_MyAccount_MyAddressesController.saveBillingAddress(addressMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyAddressesController.saveBillingAddress(addressMap);
        }
    }
}