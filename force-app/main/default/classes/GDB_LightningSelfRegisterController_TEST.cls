@isTest
private with sharing class GDB_LightningSelfRegisterController_TEST {

    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        System.assertEquals(true, GDB_LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334'), 'Return should be true');
        System.assertEquals(false, GDB_LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword'), 'Return should be false');
        System.assertEquals(false, GDB_LightningSelfRegisterController.isValidPassword('password?@12334', null), 'Return should be false');
        System.assertEquals(false, GDB_LightningSelfRegisterController.isValidPassword('password?@123456789', 'fakePwd'), 'Return should be false');
    }

    @IsTest
    static void testSiteAsContainerEnabled() {
        System.assertNotEquals(null, GDB_LightningSelfRegisterController.getAvailableValues(), 'The available values list should not be null.');
        System.assertNotEquals(null, GDB_LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'), 'Return should not be null');
    }

    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map<String, String> paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap, 'Map should not be null');
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
        System.assertEquals(Label.GDB_registerpassword_incompatibility, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, '0123456789', null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be ' + Label.GDB_registerpassword_incompatibility);
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), null, null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
    }


    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest(SeeAllData = true)
    static void testSelfRegisterWithProperCredentials() {
        Map<String, String> paramsMap = initializeParams();
        String response = GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, paramsMap.get('phone'), paramsMap.get('zipcode'), paramsMap.get('howDidYouKnowUs'), Boolean.valueOf(paramsMap.get('optinButagazPartners')), true, paramsMap.get('confirmEmail'));
    }

    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount() {
        GDB_TestDataFactory.createCustomSettings();
        Account acc = new Account(firstName = 'test', lastName = 'test', email__c = 'test@test.com', Phone = '0123456789', RecordTypeId = GDB_Constants.personAccountId);
        insert acc;
        List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map<String, String> paramsMap = initializeParams();
        System.assertEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, '0123456789', null, null, null, true, paramsMap.get('confirmEmail')), 'Return should be null');
    }

    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, GDB_LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true, null, null, null, null, true, paramsMap.get('confirmEmail')), 'Return should not be null');
    }

    @IsTest
    static void GDB_LightningSelfRegisterControllerInstantiation() {
        GDB_LightningSelfRegisterController controller = new GDB_LightningSelfRegisterController();
        System.assertNotEquals(null, controller, 'Return should not be null');
    }

    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        List<Map<String, String>> values = GDB_LightningSelfRegisterController.getAvailableValues();

        Map<String, String> paramsMap = new Map<String, String>();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        String phone = '0101010101';
        String zipcode = '71000';
        String optinButagazPartners = 'false';
        String confirmEmail = 'testUser@salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        paramsMap.put('phone', phone);
        paramsMap.put('zipcode', zipcode);
        paramsMap.put('howDidYouKnowUs', values.get(0).get('value'));
        paramsMap.put('optinButagazPartners', optinButagazPartners);
        paramsMap.put('confirmEmail', confirmEmail);
        return paramsMap;
    }
}