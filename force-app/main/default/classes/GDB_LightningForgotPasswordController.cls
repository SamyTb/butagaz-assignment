global without sharing class GDB_LightningForgotPasswordController {

    public GDB_LightningForgotPasswordController() {

    }

    @AuraEnabled
    public static String forgotPassword(String username) {
        try {

            List < User > userAlreadyRegister = [
                SELECT
                Email
                FROM User
                WHERE Email =: username
                LIMIT 1
            ];

            if(userAlreadyRegister.isEmpty()) {
                return Label.GDB_forgotPassword_error;
            }

            Site.forgotPassword(username);
            if(!Site.isValidUsername(username)) {
                return Label.GDB_forgotPassword_error;
            }
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}