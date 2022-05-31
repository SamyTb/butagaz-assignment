global without sharing class GDB_LightningSelfRegisterController {

    public GDB_LightningSelfRegisterController() {}

    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        if(password.length() > 16) {
            return false;
        }
        return password == confirmPassword;
    }

    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl, '');
        return authConfig.isCommunityUsingSiteAsContainer();
    }

    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if (!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAvailableValues() {
        return GDB_Utils.getFieldValues(Account.gdb_howDidYouKnowUs__c.getDescribe(), false, null);
    }

    /**
     * selfRegister Create a personalAccount from self register form
     * @return  {String}
     */ 
    @AuraEnabled
    public static String selfRegister(String firstname, String lastname, String email, String password, String confirmPassword,
        String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword,
        String phone, String zipcode, String howDidYouKnowUs, Boolean optinButagazPartenaire, Boolean optinButagaz, String confirmEmail) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            if (String.isBlank(lastname)) {
                return null;
            }

            if (String.isBlank(firstname)) {
                return null;
            }

            if (String.isBlank(email)) {
                return null;
            }

            if (String.isBlank(password)) {
                return null;
            }

            if (String.isBlank(confirmPassword)) {
                return null;
            }

            if (String.isBlank(confirmEmail)) {
                return null;
            }
            
            if(!String.isBlank(phone) && !Pattern.matches('^[0-9]{10}$', phone)){
                return null;
            }

            // test pour vérifier que le mail d'enregistrement n'est pas déjà utilisé par un autre user
            List < User > userAlreadyRegister = [
                SELECT
                Email
                FROM User
                WHERE Email =: email
                LIMIT 1
            ];

            if(!userAlreadyRegister.isEmpty()) {
                return System.Label.GDB_userRegisterExisting;
            }


            User u = new User();
            u.Username = email;
            u.Email = email;
            u.FirstName = firstname;
            u.LastName = lastname;
            u.Phone = phone;
            u.Bypass_Validation_Rules__c = true;

            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            /*if(networkId != null && siteAsContainerEnabled(networkId)) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }*/

            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0, 1) : '') + lastname.substring(0, 1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            
            u.put('CommunityNickname', nickname);

            if (extraFields != null) {
                List < Object > extraFieldsList = (List < Object > ) JSON.deserializeUntyped(extraFields);
                for (Object thisFieldObject: extraFieldsList) {
                    Map < String, Object > thisField = (Map < String, Object > ) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }

            try {
                if (includePassword) {
                    if (!isValidPassword(password, confirmPassword)) {
                        return System.Label.GDB_registerpassword_incompatibility;
                    }
                    validatePassword(u, password, confirmPassword);
                } else {
                    password = null;
                }
            }catch (Exception ex){
                GDB_ErrorMgr.createError('GDB_LightningSelfRegisterController', 'selfRegister_validatePassword', 'EMAIL_' + email + '_STACK_TRACE_' + ex.getStackTraceString());
                return System.Label.GDB_registerpassword_error;
            }

            try {
                if (email != confirmEmail) {
                    return System.Label.GDB_register_email_not_equals;
                }
            }catch (Exception ex){
                GDB_ErrorMgr.createError('GDB_LightningSelfRegisterController', 'selfRegister_validateEmail', 'EMAIL_' + email + '_STACK_TRACE_' + ex.getStackTraceString());
                return System.Label.GDB_register_email_not_equals;
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);
            
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Customer Community Login User GDB' LIMIT 1];
                userId = [SELECT Id, ProfileId, Name FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1].Id;
            }
            if (userId != null) {
                if (password != null && password.length() > 1) {
                    
                    List <User> users = [
                        SELECT
                        Username,
                        AccountId
                        FROM User
                        WHERE Id =: userId
                        LIMIT 1
                    ];

                    List <Account> accounts = [
                        SELECT
                        PersonEmail,
                        Email__c,
                        FirstName,
                        LastName,
                        gdb_billing_address1__c,
                        gdb_billing_address2__c,
                        gdb_billing_address3__c,
                        gdb_billing_city__c,
                        gdb_billing_postalcode__c,
                        gdb_billing_country__c,
                        gdb_billing_phone__c,
                        gdb_shipping_zip__c,
                        Optin_1__c,
                        Optin_Partenaires__c,
                        AccountNumber,
                        gdb_accountNo__c,
                        ExternalID__c,
                        GR_PRODUCT_SCALE__c,
                        Mandataire__c
                        FROM Account
                        where Id =: users.get(0).AccountId
                        LIMIT 1
                    ];
                    
                    Account a = accounts.get(0);
                    a.PersonEmail = email;
                    a.Email__c = email;
                    a.Phone = phone;
                    a.gdb_shipping_phone__c = phone;
                    a.gdb_billing_phone__c = phone;
                    a.gdb_shipping_zip__c = zipcode;
                    a.gdb_howDidYouKnowUs__c = howDidYouKnowUs;
                    a.Optin_1__c = optinButagaz;
                    a.Optin_Partenaires__c = optinButagazPartenaire;
                    a.Activity_Domain__c = GDB_Constants.activityDomainId;
                    a.AccountNumber = a.gdb_accountNo__c;
                    a.ExternalID__c = a.gdb_accountNo__c;
                    a.GR_PRODUCT_SCALE__c = GDB_Constants.productScale;
                    a.Mandataire__c = GDB_Constants.accountMandataireId;
                    a.RecordTypeId = GDB_Constants.personAccountId;
                    a.Demat1_chorus__c  = false;
                    a.Demat2_chorus__c  = false;
                    update a;

                    ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                } else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                    }

                }
            }
            return null;
        } catch (Exception ex) {
            Database.rollback(sp);
            GDB_ErrorMgr.createError('GDB_LightningSelfRegisterController', 'selfRegister', 'EMAIL_' + email + '_STACK_TRACE_' + ex.getStackTraceString() + '_ERROR_MESSAGE_' + ex.getMessage());
            System.debug(ex.getMessage() + ex.getLineNumber() + ex.getStackTraceString());
            return System.Label.GDB_register_Error;
        }
    }

}