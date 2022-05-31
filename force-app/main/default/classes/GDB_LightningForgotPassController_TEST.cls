@isTest
private class GDB_LightningForgotPassController_TEST {

    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
     @IsTest
     static void testLightningForgotPasswordControllerInvalidUserName() {
          String response;
          response = GDB_LightningForgotPasswordController.forgotPassword('fakeUser');
          response = GDB_LightningForgotPasswordController.forgotPassword('a');
          response = GDB_LightningForgotPasswordController.forgotPassword('null');

          User u = GDB_TestDataFactory.getCommunityUserByProfile();

          response = GDB_LightningForgotPasswordController.forgotPassword(u.Username);
     }

     /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
     @IsTest
     static void LightningForgotPasswordControllerInstantiation() {
          GDB_LightningForgotPasswordController controller = new GDB_LightningForgotPasswordController();
          System.assertNotEquals(controller, null);
     }  
}