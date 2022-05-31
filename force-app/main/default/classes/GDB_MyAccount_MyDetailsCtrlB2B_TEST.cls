@isTest
private class GDB_MyAccount_MyDetailsCtrlB2B_TEST {

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
            Account account = GDB_MyAccount_MyDetailsControllerB2B.getCurrentCustomer();
            System.assertNotEquals(null, account, 'Return value should be null');
        }
    }

    @isTest
    static void testGetAvailableListValues() {
        Map<String, List<Map<String, String>>> mapListValues = GDB_MyAccount_MyDetailsControllerB2B.getAvailableListValues();
        System.assertNotEquals(null, mapListValues, 'Return map should not be null');

        List<Map<String, String>> accountSalutations = mapListValues.get('accountSalutations');
        System.assertNotEquals(null, accountSalutations, 'Account Salutations should not be null');

        List<Map<String, String>> billingCountries = mapListValues.get('billingCountries');
        System.assertNotEquals(null, billingCountries, 'Billing Countries should not be null');

        List<Map<String, String>> shippingCountries = mapListValues.get('shippingCountries');
        System.assertNotEquals(null, shippingCountries, 'Shipping Countries should not be null');

        List<Map<String, String>> billingSalutations = mapListValues.get('billingSalutations');
        System.assertNotEquals(null, billingSalutations, 'Billing Salutations should not be null');

        List<Map<String, String>> shippingSalutations = mapListValues.get('shippingSalutations');
        System.assertNotEquals(null, shippingSalutations, 'Shipping Salutations should not be null');
    }

    @isTest
    static void testSaveCredentials() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

        Map<String, String> credentialsMap = new Map<String, String>();
        credentialsMap.put('oldpassword', 'test');
        credentialsMap.put('password', 'Testtest71!');
        credentialsMap.put('passwordconfirm', 'Testtest71!');

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveCredentials(credentialsMap);
        System.assertNotEquals(null, result1.get('success'), 'Success status should be false');
        System.assertNotEquals(null, result1.get('message'), 'No account should be found');

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveCredentials(credentialsMap);
            System.assertEquals('true', result2.get('success'), 'Success status should be true');

            credentialsMap.put('passwordconfirm','Testtest71');

            Map<String, String> result3 = GDB_MyAccount_MyDetailsControllerB2B.saveCredentials(credentialsMap);
            System.assertNotEquals(null, result3.get('success'), 'Success status should be false');
            System.assertEquals(Label.GDB_myaccount_passwordDontMatch, result3.get('message'), 'Passwords should not match');

        }
    }

    @isTest
    static void testSaveShippingAddress() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

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
            'phone' => '012356789',
            'useshippingasbilling' => 'true'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveShippingAddress(addressMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveShippingAddress(addressMap);

            addressMap.put('useshippingasbilling', 'false');
            addressMap.put('phone', '0123567901234567890123456789');

            Map<String, String> result3 = GDB_MyAccount_MyDetailsControllerB2B.saveShippingAddress(addressMap);
        }
    }

    @isTest
    static void testSaveBillingAddress() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

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
            'phone' => '012356789',
            'useshippingasbilling' => 'true'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveBillingAddress(addressMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveBillingAddress(addressMap);
            addressMap.put('phone', '0123567901234567890123456789');
            Map<String, String> result3 = GDB_MyAccount_MyDetailsControllerB2B.saveBillingAddress(addressMap);
        }
    }

    @isTest
    static void testSaveSalutation() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

        Map <String, String> accountMap = new Map<String,String>{
            'salutation' => 'Mr',
            'firstname' => 'firstname',
            'lastname' => 'lastname'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveSalutation(accountMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveSalutation(accountMap);
            accountMap.put('salutation', 'test');
            Map<String, String> result3 = GDB_MyAccount_MyDetailsControllerB2B.saveSalutation(accountMap);
        }
    }

    @isTest
    static void testSavePhone() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

        Map <String, String> accountMap = new Map<String,String>{
            'phone' => '0101010101'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.savePhone(accountMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.savePhone(accountMap);
        }
    }

    @isTest
    static void testSaveOptins() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: 'Customer Community Login User GDB' LIMIT 1];
        User u = [SELECT Id, AccountId, ProfileId, Name FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1];

        Map <String, String> accountMap = new Map<String,String>{
            'optinnewsletter' => 'false',
            'optinpartner' => 'true'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveOptins(accountMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveOptins(accountMap);
        }
    }

    @isTest
    static void testSaveEmail() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();

        Map <String, String> accountMap = new Map<String,String>{
            'email' => 'testemail@test.com',
            'emailconfirm' => 'testemail@test.com'
        };

        Map<String, String> result1 = GDB_MyAccount_MyDetailsControllerB2B.saveEmail(accountMap);

        System.runAs(u){
            Map<String, String> result2 = GDB_MyAccount_MyDetailsControllerB2B.saveEmail(accountMap);

            accountMap.put('emailconfirm', 'test1@test.com');

            Map<String, String> result3 = GDB_MyAccount_MyDetailsControllerB2B.saveEmail(accountMap);
        }
    }
}