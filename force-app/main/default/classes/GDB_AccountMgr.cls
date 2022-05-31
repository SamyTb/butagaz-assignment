public without sharing class GDB_AccountMgr { 
    
    public static Map<String, String> currentGuest = null;
    
    /**
     * isAuthenticated Returns true if the current user is authenticated or else if the current user is a guest user
     *
     * @return {Boolean} 
     */
    public static Boolean isAuthenticated() {
        return UserInfo.getUserType() != GDB_Constants.guestUserType; 
    }

    /**
     * isCustomerAlreadyBoughtSampleProduct This method returns true if the current customer already bought the given sample product
     *
     * @param {Id} productId
     *
     * @returns {Boolean}
     *
     **/
    public static Boolean isCustomerAlreadyBoughtSampleProduct() {
        Account a = GDB_AccountMgr.getCurrentCustomer();

        if (a == null) {
            return false;
        }

        List<Order__c> sampleOrders = GDB_OrderMgr.getSampleOrdersForAccount(a.Id);

        return sampleOrders != null && sampleOrders.size() > 0;
    }

    /**
     * getCurrentCustomer Returns the current authenticated customer
     *
     * @return {Account}
     */
    public static Account getCurrentCustomer() {
        String accountKey = GDB_Constants.sessionKeys.get('currentCustomer');
        if(!GDB_AccountMgr.isAuthenticated()) {
            return null;
        }

        if(!Cache.Session.contains(accountKey)) {
            List<User> users = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(users == null || users.size() == 0) {
                return null;
            }
            
            if(Test.isRunningTest() 
            && (users.size() <= 0 || String.isBlank(users.get(0).AccountId))) {
                return GDB_AccountMgr.getAccountById(GDB_TestDataFactory.getGlobalAccountId());
            }
            
            Account a = GDB_AccountMgr.getAccountById(users.get(0).AccountId);
            if(!Test.isRunningTest()) {
                Cache.Session.put(accountKey, a);
            }
            return a;
        } else {
            return (Account)Cache.Session.get(accountKey);
        }
    }

    /**
     * createNewGuest Create a new guest customer
     * @param {string} zipcode
     * @return {Map<String, String>}
     */
    public static Map<String, String> createNewGuest(String zipcode) {
        if(String.isBlank(zipcode)){
            zipcode = GDB_Constants.nudgeDefaultZipCode;
        }
        Blob b = Crypto.GenerateAESKey(256);
        setCurrentGuest(EncodingUtil.ConvertTohex(b), zipcode);
        return currentGuest;
    }

    /**
     * getCurrentGuest Returns the current unauthenticated customer (guest)
     * @return {Map<String, String>}
     */
    public static Map<String, String> getCurrentGuest() {
        return currentGuest;
    }

    /**
     * setCurrentGuest define current guest map
     * @param {Map<String, Object>} guest
     */
    public static void setCurrentGuest(Map<String, Object> guest) {
        if(guest != null) {
            setCurrentGuest(String.valueOf(guest.get('id')), String.valueOf(guest.get('zipcode')));
        }
    }

    /**
     * setCurrentGuest define current guest map
     * @param {string} guestId
     * @param {string} zipcode
     */
    public static void setCurrentGuest(String guestId, String zipcode) {
        currentGuest = new Map<String, String>{
            'id' => guestId,
            'zipcode' => zipcode
        };
    }
    
        /**
     * getCurrentCustomerByContract Returns the current authenticated customer by contract type RE
     *
     * @return {Account}
     */
    public static Account getCurrentAccountREByContract() {
        String accountKey = GDB_Constants.sessionKeys.get('currentCustomer');
        if(!GDB_AccountMgr.isAuthenticated()) {
            return null;
        }

        if(!Cache.Session.contains(accountKey)) {
            // Get account current
            Account a = GDB_AccountMgr.getCurrentCustomer();
            
            if(a == null) {
                return null;
            }
            
            if (Test.isRunningTest()) {
                return GDB_AccountMgr.getAccountByIdB2B(GDB_TestDataFactory.getGlobalAccountId());
            } else {
                // Get conract by accountId
                List<Contract> contractCurrentList = [SELECT Id, Name FROM Contract 
                                                            WHERE AccountId = :a.Id
                                                            LIMIT 1];
    
                if(contractCurrentList == null || contractCurrentList.size() == 0) { 
                    return null;
                }
                
                Contract contractCurrent = contractCurrentList.get(0);
                
                // Get Account RE in Account_in_Contract__c                
                List<Account_in_Contract__c> accountREList = [SELECT Account__c FROM Account_in_Contract__c 
                                                                         WHERE Contract__c =: contractCurrent.Id
                                                                         AND Role__c =: GDB_Constants_B2B.accountRole.get(1)                                                                        
                                                                         LIMIT 1];
                                                                         
                if(accountREList == null || accountREList.size() == 0){
                    return null;
                }
                
                Account_in_Contract__c accountRE = accountREList.get(0);
                
                Account accountForBilling;
                if(accountRE == null){
                    accountForBilling = GDB_AccountMgr.getAccountByIdB2B(a.Id);
                }
                else{
                    accountForBilling = GDB_AccountMgr.getAccountByIdB2B(accountRE.Account__c); 
                }
                
                Cache.Session.put(accountKey, accountForBilling);
                return accountForBilling;
            }
        } else {
            return (Account)Cache.Session.get(accountKey);
        }        
    }

    /**
     * getAccountById Returns the account related to the given Id
     *
     * @param {Id} accountId
     *
     * @returns{Account}
     *
     **/
    public static Account getAccountById(Id accountId) {
        if (accountId == null) {
            return null;
        }

        List<Account> accounts = [
            SELECT
            Name,
            gdb_accountNo__c,
            Activity_Domain__c,
            Mandataire__c,
            AccountNumber,
            gdb_howDidYouKnowUs__c,
            Salutation,
            gdb_billing_salutation__c,
            FirstName,
            LastName,
            Email__c,
            PersonEmail,
            Phone,
            Mobile_Phone_Number__c,
            Street_N__c,
            Number_extention__c,
            Street_type__c,
            Street_name__c,
            Lieu_dit__c,
            City_Postal_Code__r.Postal_Code__c,
            Postal_Code__c,
            City__c,
            Country__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_city__c,
            gdb_billing_postalcode__c,
            gdb_billing_country__c,
            gdb_billing_country_list__c,
            gdb_billing_phone__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_zip__c,
            gdb_shipping_country__c,
            gdb_shipping_phone__c,
            gdb_use_shipping_as_billing__c,
            Optin_1__c,
            Optin_Partenaires__c,
            gdb_already_bought_bundle__c,
            gdb_already_bought_six_densified_logs__c,
            gdb_parrainage_code__c,
            GDB_nb_gdb_order__c
            FROM Account
            WHERE Id = :accountId
        ];

        if(accounts == null || accounts.size() == 0) {
            return null;
        }

        return accounts.get(0);
    }

    /**
     * getAccountById Returns the account related to the given Id
     *
     * @param {Id} accountId
     *
     * @returns{Account}
     *
     **/
    public static Account getAccountByIdB2B(Id accountId) {
        if (accountId == null) {
            return null;
        }

        List<Account> accounts = [
            SELECT 
            Name,
            gdb_accountNo__c,
            Activity_Domain__c,
            Mandataire__c,
            AccountNumber,
            gdb_howDidYouKnowUs__c,
            Salutation,
            gdb_billing_salutation__c,
            FirstName,
            LastName,
            Email__c,
            PersonEmail,
            Phone,
            Mobile_Phone_Number__c,
            Street_Number__c,
            Street_N__c,
            Number_extention__c,
            Street_type__c,
            Street_name__c,
            Lieu_dit__c,
            City_Postal_Code__r.Postal_Code__c,
            City_Postal_Code__r.City__r.Name,
            Postal_Code__c,
            City__c,
            Country__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_zip__c,
            gdb_shipping_country__c,
            gdb_shipping_phone__c,
            gdb_use_shipping_as_billing__c,
            Optin_1__c,
            Company__pc,
            gdb_parrainage_code__c,
            GDB_nb_gdb_order__c
            FROM Account
            WHERE Id = :accountId 
        ];

        if(accounts == null || accounts.size() == 0) {
            return null;
        }

        return accounts.get(0);
    }

    /**
     * getUserForAccount Return the user that matchs the given account Id
     *
     * @param {Id} accountId
     *
     * @return {User}
     */
    public static User getUserForAccount(Id accountId) {
        if(accountId == null) {
            return null;
        }

        List<User> users = [SELECT
            Username,
            AccountId,
            Account.Email__c,
            Account.PersonEmail
            FROM User
            WHERE AccountId != null
            AND Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        if(users == null || users.size() == 0) {
            return null;
        }

        return users.get(0);
    }

    /**
     * saveUserInformations Update the user with the map in parameter
     *
     * @param {Map<string,string>} userInformations
     *
     * @return void
     */
    @future
    public static void saveUserInformations (Map<string,string> userInformations) {
        if (userInformations == null) {
            return;
        }

        try {
            User u = new User();
            u.Id = userInformations.get('id');
            u.Email = userInformations.get('email');
            u.Username = userInformations.get('email');
            update u;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured when saving user informations:' + e.getMessage());
        }
    }

    /**
     * saveCredentials Save new credentials on the current authenticated account
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveCredentials(Map<String, String> detailsForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null) {
            returnObject.put('message', System.Label.GDB_myaccount_cannotSaveCredentials);
            return returnObject;
        }

        try {
            if(String.isBlank(detailsForm.get('oldpassword'))
                || String.isBlank(detailsForm.get('password'))
                || String.isBlank(detailsForm.get('passwordconfirm'))
                || (detailsForm.get('password') != detailsForm.get('passwordconfirm'))
            ) {
                returnObject.put('message', System.Label.GDB_myaccount_passwordDontMatch);
                return returnObject;
            }

            Site.changePassword(detailsForm.get('password'), detailsForm.get('passwordconfirm'), detailsForm.get('oldpassword'));

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myAccount_credentialsSuccessfullySaved);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_pleaseEnterValidPassword);
            return returnObject;
        }
    }

    /**
     * saveShippingAddress Save new shipping address on the current authenticated account
     *
     * @param {Map<String, String>} addressForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveShippingAddress(Map<String, String> addressForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || addressForm == null) {
            returnObject.put('message', System.Label.GDB_myaccount_cannotSaveShippingAddress);
            return returnObject;
        }

        if(String.isBlank(addressForm.get('salutation'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_salutation }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('firstname'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('lastname'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('address1'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('zip'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('country'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('city'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('phone'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
            return returnObject;
        }

        try {
            // Address
            accountToUpdate.No_E_mail__c = false;
            accountToUpdate.gdb_shipping_salutation__c = addressForm.get('salutation');
            accountToUpdate.gdb_shipping_firstname__c = addressForm.get('firstname');
            accountToUpdate.gdb_shipping_lastname__c = addressForm.get('lastname');
            accountToUpdate.gdb_shipping_address1__c = addressForm.get('address1');
            accountToUpdate.gdb_shipping_address2__c = addressForm.get('address2');
            accountToUpdate.gdb_shipping_address3__c = addressForm.get('address3');
            accountToUpdate.gdb_shipping_city__c = addressForm.get('city');
            accountToUpdate.gdb_shipping_zip__c = addressForm.get('zip');
            accountToUpdate.gdb_shipping_country__c = addressForm.get('country');
            accountToUpdate.gdb_shipping_phone__c = addressForm.get('phone');
            accountToUpdate.gdb_use_shipping_as_billing__c = addressForm.get('useshippingasbilling') == 'true';

            if(addressForm.get('useshippingasbilling') == 'true'){
                accountToUpdate.gdb_billing_salutation__c = addressForm.get('salutation');
                accountToUpdate.gdb_billing_firstname__c = addressForm.get('firstname');
                accountToUpdate.gdb_billing_lastname__c = addressForm.get('lastname');
                accountToUpdate.gdb_billing_address1__c = addressForm.get('address1');
                accountToUpdate.gdb_billing_address2__c = addressForm.get('address2');
                accountToUpdate.gdb_billing_address3__c = addressForm.get('address3');
                accountToUpdate.gdb_billing_city__c = addressForm.get('city');
                accountToUpdate.gdb_billing_postalcode__c = addressForm.get('zip');
                accountToUpdate.gdb_billing_country__c = addressForm.get('country');
                accountToUpdate.gdb_billing_phone__c = addressForm.get('phone');
            }

            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myAccount_shippingAddressSuccessfullySaved);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_cannotSaveShippingAddress);
            return returnObject;
        }
    }

    /**
     * saveBillingAddress Save new billing address on the current authenticated account
     *
     * @param {Map<String, String>} addressForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveBillingAddress(Map<String, String> addressForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || addressForm == null) {
            returnObject.put('message', System.Label.GDB_myaccount_cannotSaveBillingAddress);
            return returnObject;
        }

        if(String.isBlank(addressForm.get('salutation'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_salutation }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('firstname'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('lastname'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('address1'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('zip'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('country'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('city'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
            return returnObject;
        } else if(String.isBlank(addressForm.get('phone'))) {
            returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
            return returnObject;
        }

        try {
            // Address
            accountToUpdate.No_E_mail__c = false;
            accountToUpdate.gdb_billing_salutation__c = addressForm.get('salutation');
            accountToUpdate.gdb_billing_firstname__c = addressForm.get('firstname');
            accountToUpdate.gdb_billing_lastname__c = addressForm.get('lastname');
            accountToUpdate.gdb_billing_address1__c = addressForm.get('address1');
            accountToUpdate.gdb_billing_address2__c = addressForm.get('address2');
            accountToUpdate.gdb_billing_address3__c = addressForm.get('address3');
            accountToUpdate.gdb_billing_city__c = addressForm.get('city');
            accountToUpdate.gdb_billing_postalcode__c = addressForm.get('zip');
            accountToUpdate.gdb_billing_country__c = addressForm.get('country');
            accountToUpdate.gdb_billing_phone__c = addressForm.get('phone');
            accountToUpdate.gdb_use_shipping_as_billing__c = addressForm.get('useshippingasbilling') == 'true';
            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myAccount_billingAddressSuccessfullySaved);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_cannotSaveBillingAddress);
            return returnObject;
        }
    }

    /**
     * saveSalutation Save salutation informations on the current authenticated account
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveSalutation(Map<String, String> detailsForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null
        || String.isBlank(detailsForm.get('salutation'))
        || String.isBlank(detailsForm.get('firstname'))
        || String.isBlank(detailsForm.get('lastname'))
        ) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Customer details
            accountToUpdate.Salutation = detailsForm.get('salutation');
            accountToUpdate.Firstname = detailsForm.get('firstname');
            accountToUpdate.Lastname = detailsForm.get('lastname');
            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }
    
        /**
     * saveSalutationB2B Save salutation informations on the current authenticated account for B2B
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveSalutationB2B(Map<String, String> detailsForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();  
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null
        || String.isBlank(detailsForm.get('lastname'))
        ) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Customer details
            accountToUpdate.Lastname = detailsForm.get('lastname');
            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }

    /**
     * savePhone Save phone informations on the current authenticated account
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> savePhone(Map<String, String> detailsForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null
        || String.isBlank(detailsForm.get('phone'))
        ) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Customer details for B2B
            if(detailsForm.get('B2B') != null && detailsForm.get('B2B') == 'true'){
                
                accountToUpdate.phone = detailsForm.get('phone');
                
                // Mobile phone
                if(detailsForm.get('phoneMobile') != null && !String.isBlank(detailsForm.get('phoneMobile'))){
                    accountToUpdate.Mobile_Phone_Number__c = detailsForm.get('phoneMobile');
                }
            }
            // Customer details for B2C
            else{
                accountToUpdate.gdb_billing_phone__c = detailsForm.get('phone');
            }
            
            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }

    /**
     * saveOptins Save optins informations on the current authenticated account
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveOptins(Map<String, String> detailsForm) {
        Account account;
        Account accountToUpdate = new Account();
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        accountToUpdate.Id = account.Id;
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Customer details
            accountToUpdate.Optin_1__c = detailsForm.get('optinbutagaz') == 'false';
            accountToUpdate.Optin_Partenaires__c = detailsForm.get('optinbutagazpartner') == 'false';
            update accountToUpdate;

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }

    /**
     * saveEmail Save email informations on the current authenticated account and user associated
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveEmail(Map<String, String> detailsForm) {
        Account account;
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null
           || String.isBlank(detailsForm.get('email'))
           || String.isBlank(detailsForm.get('emailconfirm'))
        ) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Email & Password details
            if((detailsForm.get('email') != null && detailsForm.get('emailconfirm') == null)
                || (detailsForm.get('email') == null && detailsForm.get('emailconfirm') != null)
                || (detailsForm.get('email') != detailsForm.get('emailconfirm'))) {
                returnObject.put('message', System.Label.GDB_myaccount_emailDontMatch);
                return returnObject;
            }

            User user = GDB_AccountMgr.getUserForAccount(account.Id);
            if(user == null) {
                returnObject.put('message', System.Label.GDB_myaccount_cannotSaveCredentials);
                return returnObject;
            }

            Account a = new Account();
            a.Id = user.AccountId;
            a.Email__c = detailsForm.get('email');
            a.PersonEmail = detailsForm.get('email');
            update a;

            Map<string, string> userInformations = new Map<string,string>();
            userInformations.put('email', detailsForm.get('email'));
            userInformations.put('id', user.Id);
            saveUserInformations(userInformations);

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }

    /**
     * saveEmailB2B Save email informations on the current authenticated account and user associated
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> saveEmailB2B(Map<String, String> detailsForm) {
        Account account;
        
        if(Test.isRunningTest()){
            account = GDB_TestDataFactory.getGlobalAccount();   
        }
        else{
            account = GDB_AccountMgr.getCurrentCustomer();
        }
        
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if(account == null || detailsForm == null
           || String.isBlank(detailsForm.get('email'))
           || String.isBlank(detailsForm.get('emailconfirm'))
        ) {
            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }

        try {
            // Email & Password details
            if((detailsForm.get('email') != null && detailsForm.get('emailconfirm') == null)
                || (detailsForm.get('email') == null && detailsForm.get('emailconfirm') != null)
                || (detailsForm.get('email') != detailsForm.get('emailconfirm'))) {
                returnObject.put('message', System.Label.GDB_myaccount_emailDontMatch);
                return returnObject;
            }

            User user = GDB_AccountMgr.getUserForAccount(account.Id);
            if(user == null) {
                returnObject.put('message', System.Label.GDB_myaccount_cannotSaveCredentials);
                return returnObject;
            }

            Account a = new Account();
            a.Id = user.AccountId;
            a.Email__c = detailsForm.get('email');
            update a;

            Map<string, string> userInformations = new Map<string,string>();
            userInformations.put('email', detailsForm.get('email'));
            userInformations.put('id', user.Id);
            saveUserInformations(userInformations);

            returnObject.put('success', 'true');
            returnObject.put('message', System.Label.GDB_myaccount_successMessage);
            return returnObject;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());

            returnObject.put('message', System.Label.GDB_myaccount_errorMessage);
            return returnObject;
        }
    }
    
    /**
    * Return the customer postal code
    * @param {Account} customer
    * @return {String} 
    */
    public static String getCustomerPostalCode(Account customer) {
        if(customer == null) {
            customer = getCurrentCustomer();
            if (customer == null) { return null; }
        }
        
        String postalCode = customer.gdb_shipping_zip__c;
        if(String.isBlank(postalCode)){
            postalCode = customer.Postal_Code__c;
        }
        if(String.isBlank(postalCode)){
            postalCode = customer.City_Postal_Code__r.Postal_Code__c;
        }
        
        return postalCode;
    }

    /**
    * Return list of Points Of Sales
    * @param {List<String>} filter
    * @return {List<Account>} 
    */
    public static List<Account> getPointsOfSales(List<String> filter) {
        List<Account> allAccounts = new List<Account>();
        // Get all account with type of RE or PR
        allAccounts = [SELECT Id, 
                             Name,
                             Channel__c , 
                             Street_N__c, 
                             toLabel(Street_type__c), 
                             Street_name__c, 
                             City_Postal_Code__r.Postal_Code__c, 
                             City_Postal_Code__r.City__c,
                             Country__c
                        FROM Account 
                        WHERE Channel__c IN :filter 
                        AND gdb_available_on_google_map__c = true
                        AND City_Postal_Code__c != null
                        ORDER BY City_Postal_Code__r.Postal_Code__c];
        
        return allAccounts;
    }
}