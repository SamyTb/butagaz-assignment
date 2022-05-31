@isTest
private class GDB_LightningLoginFormController_TEST {
    @IsTest
    static void testLoginWithInvalidCredentials() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertEquals(null, GDB_LightningLoginFormController.login('testUser', 'fakepwd', null), 'Result must be null');
    }

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_LightningLoginFormController controller = new GDB_LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertEquals(true, GDB_LightningLoginFormController.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertEquals(true, GDB_LightningLoginFormController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertNotEquals(null, GDB_LightningLoginFormController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testGetForgotPasswordURL() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertNotEquals(null, GDB_LightningLoginFormController.getForgotPasswordUrl());
    }

    @IsTest
    static void testRedirectUser() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_LightningLoginFormController.redirectUser('');
    }

    @IsTest
    static void testAuthConfig() {
        GDB_TestDataFactory.createCustomSettings();
        Auth.AuthConfiguration authConfig = GDB_LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
}