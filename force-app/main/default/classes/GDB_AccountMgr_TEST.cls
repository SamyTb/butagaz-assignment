@isTest
private class GDB_AccountMgr_TEST {
    @isTest
    static void testNullReturnValues() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();

        System.assertNotEquals(null, GDB_AccountMgr.isAuthenticated());
        System.assertEquals(false, GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct());
        System.assertEquals(null, GDB_AccountMgr.getCurrentCustomer());
        System.assertEquals(null, GDB_AccountMgr.getAccountById(null));
        System.assertEquals(null, GDB_AccountMgr.getUserForAccount(null));
        GDB_AccountMgr.saveUserInformations(null);

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            GDB_AccountMgr.saveUserInformations(new Map<String, String> {
                'id' => '0059E000000NOSZ',
                'email' => 't@t.com'
            });

            GDB_TestDataFactory.createOrder(null);
            GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct();
            GDB_TestDataFactory.createItemsInOrder(GDB_TestDataFactory.getOrder());
            Order__c o = GDB_OrderMgr.getOrderById(GDB_TestDataFactory.getOrder().Id);
           
            GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct();
        }
    }

    @isTest
    static void testSaveCredentials(){
        Map<String, String> ret = GDB_AccountMgr.saveCredentials(null);
        System.assertEquals(System.Label.GDB_myaccount_cannotSaveCredentials, ret.get('message'), 'Return value should be ' + System.Label.GDB_myaccount_cannotSaveCredentials);
        
        Map<String, String> detailsForm = new Map<String, String>();
        detailsForm.put('oldpassword','');
        
        ret = GDB_AccountMgr.saveCredentials(detailsForm);
        System.assertEquals(System.Label.GDB_myaccount_passwordDontMatch, ret.get('message'), 'Return value should be ' + System.Label.GDB_myaccount_passwordDontMatch);
        
        detailsForm.remove('oldpassword');
        detailsForm.put('oldpassword','test');
        detailsForm.put('password','test01');
        detailsForm.put('passwordconfirm','test01');
        ret = GDB_AccountMgr.saveCredentials(detailsForm);
        System.assertEquals(System.Label.GDB_myAccount_credentialsSuccessfullySaved, ret.get('message'), 'Return value should be ' + System.Label.GDB_myAccount_credentialsSuccessfullySaved);
    }
    
    @isTest
    static void testSaveShippingAddress() {
        Map<String, String> ret = GDB_AccountMgr.saveShippingAddress(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> addressForm = new Map<String, String> ();
        addressForm.put('salutation','');
        addressForm.put('firstname','');
        addressForm.put('lastname','');
        addressForm.put('address1','');
        addressForm.put('zip','');
        addressForm.put('country','');
        addressForm.put('city','');
        addressForm.put('phone','');        
        
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('salutation');
        addressForm.put('salutation','Mr');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('firstname');
        addressForm.put('firstname','Test');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('lastname');
        addressForm.put('lastname','Test');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('address1');
        addressForm.put('address1','Test');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('zip');
        addressForm.put('zip','11111');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('country');
        addressForm.put('country','france');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('city');
        addressForm.put('city','macon');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('phone');
        addressForm.put('phone','1111111111');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('useshippingasbilling');
        addressForm.put('useshippingasbilling','true');
        ret = GDB_AccountMgr.saveShippingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
    @isTest 
    static void testSaveBillingAddress() {
        Map<String, String> ret = GDB_AccountMgr.saveBillingAddress(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> addressForm = new Map<String, String> ();
        addressForm.put('salutation','');
        addressForm.put('firstname','');
        addressForm.put('lastname','');
        addressForm.put('address1','');
        addressForm.put('zip','');
        addressForm.put('country','');
        addressForm.put('city','');
        addressForm.put('phone','');        
        
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('salutation');
        addressForm.put('salutation','Mr');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('firstname');
        addressForm.put('firstname','Test');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('lastname');
        addressForm.put('lastname','Test');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('address1');
        addressForm.put('address1','Test');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('zip');
        addressForm.put('zip','11111');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');

        addressForm.remove('country');
        addressForm.put('country','france');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('city');
        addressForm.put('city','macon');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('phone');
        addressForm.put('phone','1111111111');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        addressForm.remove('useshippingasbilling');
        addressForm.put('useshippingasbilling','true');
        ret = GDB_AccountMgr.saveBillingAddress(addressForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
    @isTest
    static void testSaveOptins() {
        Map<String, String> ret = GDB_AccountMgr.saveOptins(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> detailsForm = new Map<String, String> ();
        detailsForm.put('optinbutagazpartner','false');
              
        ret = GDB_AccountMgr.saveOptins(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
    @isTest
    static void testSaveEmail() {
        Map<String, String> ret = GDB_AccountMgr.saveEmail(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> detailsForm = new Map<String, String> ();
        detailsForm.put('email','');
        detailsForm.put('emailconfirm','test01');
        
        GDB_AccountMgr.saveEmail(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        detailsForm.remove('email');
        detailsForm.put('email','test01');          
        GDB_AccountMgr.saveEmail(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
    @isTest
    static void testSaveSalutation() {
        Map<String, String> ret = GDB_AccountMgr.saveSalutation(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> detailsForm = new Map<String, String> ();
        detailsForm.put('salutation','');
        detailsForm.put('firstname','test02');
        detailsForm.put('lastname','test02');
        
        GDB_AccountMgr.saveSalutation(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        detailsForm.remove('salutation');
        detailsForm.put('salutation','Mr');          
        GDB_AccountMgr.saveSalutation(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
        @isTest
    static void testSavePhone() {
        Map<String, String> ret = GDB_AccountMgr.savePhone(null);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
            
        Map<String, String> detailsForm = new Map<String, String> ();
        detailsForm.put('phone','');
        
        GDB_AccountMgr.savePhone(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
        
        detailsForm.remove('phone');
        detailsForm.put('phone','1111111111');
        GDB_AccountMgr.savePhone(detailsForm);
        System.assertNotEquals(null, ret.get('message'), 'Return value should be not null');
    }
    
    @isTest
    static void testCreateNewGuest() {
        Map<String, String> guest = GDB_AccountMgr.createNewGuest('71000');
        System.assertNotEquals(null, guest);
    }
    
    @isTest
    static void testGetCurrentGuest() {
        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        System.assertEquals(null, guest);
    }
    
    @isTest
    static void testSetCurrentGuest() {
        GDB_AccountMgr.setCurrentGuest(GDB_AccountMgr.createNewGuest('71000'));
        System.assertNotEquals(null, GDB_AccountMgr.getCurrentGuest());
    }
    
    @isTest
    static void testGetCustomerPostalCode() {
        String zipcode = GDB_AccountMgr.getCustomerPostalCode(null);
        System.assertEquals(null, zipcode);
    }

    @isTest
    static void testGetPointsOfSales() {
        List<String> filters = new List<String>();
        filters.add('PR');
        filters.add('RE');

        User me = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        
        System.runAs(me) {
            GDB_TestDataFactory.createCustomSettings();
            GDB_TestDataFactory.createActivityDomain();
            Account a = GDB_TestDataFactory.createAccount();
            insert a;
            
            a = [SELECT Id, Channel__c FROM Account WHERE Id = :a.Id];
            a.Channel__c = 'PR';
            update a;
            
            List<Account> accounts = GDB_AccountMgr.getPointsOfSales(filters);
            System.assertNotEquals(null, accounts, 'The list should not be null.');
        }
    }
}