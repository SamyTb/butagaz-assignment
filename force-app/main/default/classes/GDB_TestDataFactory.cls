@isTest
public without sharing class GDB_TestDataFactory {

    /**
    * Name of the current Org Instance (DEV,FULL,PROD)
    */
    private static String instanceName {get;set;}

    /**
    * Return the "name" of the current Organization instance (Dev,Full,Prod)
    * @return {String}
    */
    private static String getCurrentInstanceName() {
        try {
            if(instanceName == null) {
                instanceName = String.valueOf(GDB_CustomMetadataMgr.self().getCurrentInstanceName()).toUpperCase();
            }
        } catch(Exception e) {
            System.debug('### GDB_TestDataFactory.getCurrentInstanceName ### ' + e.getMessage());
        }

        return instanceName;
    }

    public static Account getGlobalAccount() {
        Account a = null;
        String currentInstance = getCurrentInstanceName();

        if(currentInstance == 'PROD') {
            a = new Account(Id = '00157000025iQut', Name = 'the_Account', Phone = '0123456789', RecordTypeId = GDB_Constants.personAccountId, gdb_shipping_zip__c = '75000');
        } else if(currentInstance == 'FULL') {
            a = new Account(Id = '00157000025iQut', Name = 'the_Account', Phone = '0123456789', RecordTypeId = GDB_Constants.personAccountId, gdb_shipping_zip__c = '75000');
        } else if(currentInstance == 'DEV') {
            a = new Account(Id = '0014E000014qPpKQAU', Name = 'the_Account', Phone = '0123456789', RecordTypeId = GDB_Constants.personAccountId, gdb_shipping_zip__c = '75000');
        }

        return a;
    }

    public static String getGlobalAccountId() {
        return GDB_TestDataFactory.getGlobalAccount().Id;
    }

    /**
    * Create a new community
    * @return {User}
    */
    public static User createCommunityUser()
    {
        User me = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User u;

        System.runAs(me) {
            Account a = createAccount();
            insert a;

            a = [SELECT Id, PersonContactId FROM Account WHERE Id = :a.Id];

            Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User GDB'];
            String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
            String userEmailPrefix = key.substring(0, 10);

            u = new User(
                Alias = 'standt',
                Email =  userEmailPrefix+'@butagaz.fr',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'Europe/Berlin',
                UserName = userEmailPrefix+'@butagaz.fr',
                communityNickname = userEmailPrefix + '_' + Math.random(),
                ContactId = a.PersonContactId
            );
            insert u;

            u = [SELECT Id, ProfileId, AccountId, Name, Username
                    FROM User
                    WHERE Id = :u.Id
                    LIMIT 1];
        }
        return u;
    }

    /**
    * Create and return a community user
    * @return {User}
    */
    public static User createCommunityUser(Account a)
    {
        if(a == null) {
            a = createAccount();
            insert a;
        }

        Id contactId = [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 1].Id;
        String profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User GDB'].Id;

        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
        String userEmailPrefix = key.substring(0, 10);

        User u = new User(
            Alias = 'standt',
            Email =  userEmailPrefix+'@butagaz.fr',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'Europe/Berlin',
            UserName = userEmailPrefix+'@butagaz.fr',
            ContactId = contactId,
            Bypass_Validation_Rules__c = true,
            isActive = true
        );

        insert u;
        return getCommunityUserById(u.Id);
    }

    /**
    * Return the community user whom Id is passed by params
    * @param {String} userId
    * @return {User}
    */
     public static User getCommunityUserById(String userId) {
        return [SELECT Id, ProfileId, AccountId, Name, Username FROM User WHERE Profile.Name = 'Customer Community Login User GDB' AND Id = :userId LIMIT 1];
    }

    public static User getCommunityUserByProfile() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Customer Community Login User GDB' LIMIT 1];
        return [SELECT Id, ProfileId, AccountId, Name, Username FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1];
    }

    /**
    * Return a person account list which don't have sample order
    * @return {List<Account>}
    */
    public static List<Account> getAccountsWithNoSampleOrder() {
        return [SELECT Id, Name, PersonContactId FROM Account
               WHERE Id IN  ( SELECT Account__c FROM Order__c WHERE gdb_isSample__c = false AND RecordTypeId = :GDB_Constants.orderTypeId )
               AND Id NOT IN ( SELECT Account__c FROM Order__c WHERE gdb_isSample__c = true AND RecordTypeId = :GDB_Constants.orderTypeId )
               AND RecordTypeId = :GDB_Constants.personAccountId LIMIT 10];
    }

    /**
    * Get a community user who has no sample order
    * @return User
    */
    public static User getCommunityUserByProfileAndNoSampleOrder() {
        List<Account> accts = getAccountsWithNoSampleOrder();

        List<Id> acctsIds = new List<Id>();
        for(Account a : accts){
            acctsIds.add(a.Id);
        }

        if(acctsIds.size() <= 0) {
            Account a = createAccount();
            insert a;
            createOrder(a);

            accts = getAccountsWithNoSampleOrder();
            acctsIds.add(accts.get(0).Id);
        }

        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Customer Community Login User GDB' LIMIT 1];

        List<User> uList = [SELECT Id, ProfileId, AccountId, Name, Username
                            FROM User
                            WHERE ProfileId = :p.Id
                            AND isActive = true
                            AND Bypass_Validation_Rules__c = true
                            AND AccountId IN :acctsIds
                            LIMIT 1];

        User u;
        if(uList.size() <= 0) {
            Account a = accts.get(0);
            u = createUser(p.Id, null, a.PersonContactId);
        } else {
            u = uList.get(0);
        }

        return u;
    }

    /**
    * Create a user with Profile, Role and attached to Contact passed by params
    * @param {Id} profileId
    * @param {Id} roleId
    * @param {Id} contactId
    * @return {User}
    */
    public static User createUser(Id profileId, Id roleId, Id contactId)
    {
        if(String.isBlank(profileId)) {
            profileId = [SELECT Id FROM Profile WHERE Name = 'Butagaz System Administrator'].Id;
            roleId = [Select ID from UserRole where Name='Butagaz DO' Limit 1].Id;
        }

        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
        String userEmailPrefix = key.substring(0, 10);

        User u = new User(
                Alias = 'standt',
                Email =  userEmailPrefix+'@butagaz.fr',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                TimeZoneSidKey = 'Europe/Berlin',
                UserName = userEmailPrefix+'@butagaz.fr',
                UserRoleId = roleId,
                ContactId = contactId
        );

        insert u;

        return u;
    }

    public static List<gdb_Warehouse__c> createAndGetWarehouses(){
         String cp_1 = '';
        String cp_2 = '';
        for (Integer i = 1; i < 96; i++) {
            if (i < 10) {
                cp_1 += '0' + i + ';';
            } else if (i < 49) {
                cp_1 += i + ';';
            } else {
                cp_2 += i + ';';
            }
        }


        GDB_Warehouse__c wh_1 = new GDB_Warehouse__c();
        wh_1.gdb_codes__c = cp_1;
        wh_1.gdb_reference__c = 'Dépôt_1';
        wh_1.gdb_shipping_carrier__c = 'PRAXEDO';

        GDB_Warehouse__c wh_2 = new GDB_Warehouse__c();
        wh_2.gdb_codes__c = cp_2;
        wh_2.gdb_reference__c = 'Dépôt_2';
        wh_2.gdb_shipping_carrier__c = 'PRAXEDO';

        insert wh_1;
        insert wh_2;

        List<gdb_Warehouse__c> listWhs = new list<gdb_Warehouse__c>();
        listWhs.add(wh_1);
        listWhs.add(wh_2);
        return listWhs;
    }


    public static void createWarehouses() {
       createAndGetWarehouses();
    }

    public static GDB_Warehouse__c getWarehouseByReference(String reference) {
        GDB_Warehouse__c[] w = [SELECT ID FROM GDB_Warehouse__c WHERE gdb_reference__c =: reference LIMIT 1];

        if(w.size() > 0){
            return w[0];
        }
        else{
            return null;
        }
    }

    public static void createWarehouseArticleJunction() {
        Item__c article_1 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_1'];
        System.assertNotEquals(null, article_1, 'createWarehouseArticleJunction need article data');
        Item__c article_2 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_2'];
        System.assertNotEquals(null, article_2, 'createWarehouseArticleJunction need article data');

        GDB_Warehouse__c wh_1 = [SELECT ID, gdb_reference__c FROM GDB_Warehouse__c WHERE gdb_reference__c =
            'Dépôt_1'
        ];
        System.assertNotEquals(null, wh_1, 'createWarehouseArticleJunction need warehouse data');
        GDB_Warehouse__c wh_2 = [SELECT ID, gdb_reference__c FROM GDB_Warehouse__c WHERE gdb_reference__c =
            'Dépôt_2'
        ];
        System.assertNotEquals(null, wh_2, 'createWarehouseArticleJunction need warehouse data');

        GDB_Warehouse_Has_Product__c whhp_1 = new GDB_Warehouse_Has_Product__c();
        whhp_1.gdb_inventory_threshold__c = 50;
        whhp_1.Name = wh_1.gdb_reference__c + article_1.Name;
        whhp_1.gdb_price__c = 50;
        whhp_1.gdb_Article__c = article_1.Id;
        whhp_1.gdb_quantity__c = 20;
        whhp_1.gdb_Warehouse__c = wh_1.Id;
        whhp_1.gdb_sku__c = wh_1.gdb_reference__c + article_1.Name;
        whhp_1.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_2 = new GDB_Warehouse_Has_Product__c();
        whhp_2.gdb_inventory_threshold__c = 50;
        whhp_2.Name = wh_2.gdb_reference__c + article_1.Name;
        whhp_2.gdb_price__c = 100;
        whhp_2.gdb_Article__c = article_1.Id;
        whhp_2.gdb_quantity__c = 20;
        whhp_2.gdb_Warehouse__c = wh_2.Id;
        whhp_2.gdb_sku__c = wh_2.gdb_reference__c + article_1.Name;
        whhp_2.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_3 = new GDB_Warehouse_Has_Product__c();
        whhp_3.gdb_inventory_threshold__c = 50;
        whhp_3.Name = wh_1.gdb_reference__c + article_2.Name;
        whhp_3.gdb_price__c = 150;
        whhp_3.gdb_Article__c = article_2.Id;
        whhp_3.gdb_quantity__c = 20;
        whhp_3.gdb_Warehouse__c = wh_1.Id;
        whhp_3.gdb_sku__c = wh_1.gdb_reference__c + article_2.Name;
        whhp_3.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_4 = new GDB_Warehouse_Has_Product__c();
        whhp_4.gdb_inventory_threshold__c = 50;
        whhp_4.Name = wh_2.gdb_reference__c + article_2.Name;
        whhp_4.gdb_price__c = 200;
        whhp_4.gdb_Article__c = article_2.Id;
        whhp_4.gdb_quantity__c = 20;
        whhp_4.gdb_Warehouse__c = wh_2.Id;
        whhp_4.gdb_sku__c = wh_2.gdb_reference__c + article_2.Name;
        whhp_4.gdb_tax__c = 10;

        insert whhp_1;
        insert whhp_2;
        insert whhp_3;
        insert whhp_4;
    }

    public static List<GDB_Department_Has_WarehouseProd__c> createDepartementWarehouseArticleJunction() {
        List<GDB_Warehouse_Has_Product__c> whp = [SELECT Id,gdb_price__c,gdb_tax__c,gdb_unit_price_warehouse__c,gdb_unit_tax_warehouse__c
                                                    FROM GDB_Warehouse_Has_Product__c];
        if(whp.size() <= 0) {
            createWarehouseArticleJunction();
            whp = [SELECT Id,gdb_price__c,gdb_tax__c,gdb_unit_price_warehouse__c,gdb_unit_tax_warehouse__c
                    FROM GDB_Warehouse_Has_Product__c];
        }

        List<GDB_Department_Has_WarehouseProd__c> dhwList = new List<GDB_Department_Has_WarehouseProd__c>();
        for(GDB_Warehouse_Has_Product__c w : whp) {
            GDB_Department_Has_WarehouseProd__c dhw = new GDB_Department_Has_WarehouseProd__c(
                gdb_department__c = '71',
                gdb_price__c = w.gdb_price__c != null ? w.gdb_price__c : 0,
                gdb_tax__c = w.gdb_tax__c != null ? w.gdb_tax__c : 0,
                gdb_unit_price_warehouse__c = w.gdb_unit_price_warehouse__c != null ? w.gdb_unit_price_warehouse__c : 0,
                gdb_unit_tax_warehouse__c = w.gdb_unit_tax_warehouse__c != null ? w.gdb_unit_tax_warehouse__c : 0,
                gdb_warehouseproduct__c = w.Id
            );

            dhwList.add(dhw);
        }

        insert dhwList;
        return dhwList;
    }

    public static void createArticles() {

        System.assertNotEquals(null, GDB_Constants.articleTypeId, 'createArticles need custom settings data');

        gdb_item_type__c type1 = new gdb_item_type__c();
        type1.Name = 'Palette';
        type1.gdb_cut_price_available__c = true;
        insert type1;

        gdb_item_type__c type2 = new gdb_item_type__c();
        type2.Name = 'Demie Palette';
        insert type2;
        
        gdb_item_type__c type3 = new gdb_item_type__c();
        type3.Name = 'LIV STACI';
        insert type3;

        Item__c article_1 = new Item__c();
        article_1.Name = 'article_1';
        article_1.Code_Article__c = 'AAA_1';
        article_1.gdb_description__c = 'Desc_Article_1';
        article_1.gdb_online__c = true;
        article_1.gdb_technical_characteristics__c = 'tech_charact_1';
        article_1.RecordTypeId = GDB_Constants.articleTypeId;
        article_1.gdb_type__c = 'PRAXEDO';
        article_1.gdb_item_type__c = type1.Id;
        article_1.gdb_canBeSoldOnB2C__c = true;
        article_1.gdb_LocationDisplay__c = 'Menu;Tuile';
        article_1.gdb_eligibility_multiple_shipping__c = true;

        Item__c article_2 = new Item__c();
        article_2.Name = 'article_2';
        article_2.Code_Article__c = 'AAA_2';
        article_2.gdb_description__c = 'Desc_Article_2';
        article_2.gdb_online__c = true;
        article_2.gdb_technical_characteristics__c = 'tech_charact_1';
        article_2.RecordTypeId = GDB_Constants.articleTypeId;
        article_2.gdb_type__c = 'STACI';
        article_2.gdb_item_type__c = type2.Id;
        article_2.gdb_canBeSoldOnB2C__c = true;
        article_2.gdb_LocationDisplay__c = 'Menu;Tuile';
        
        Item__c article_3 = new Item__c();
        article_3.Name = '6 bûches de bois compressé';
        article_3.Code_Article__c = GDB_Constants.articleCode.get(2);
        article_3.gdb_description__c = 'Desc_Article_3';
        article_3.gdb_online__c = true;
        article_3.gdb_technical_characteristics__c = 'tech_charact_3';
        article_3.RecordTypeId = GDB_Constants.articleTypeId;
        article_3.gdb_type__c = 'STACI';
        article_3.gdb_item_type__c = type3.Id;
        article_3.gdb_canBeSoldOnB2C__c = true;
        article_3.gdb_LocationDisplay__c = 'Menu;Tuile';
        
        insert article_1;
        insert article_2;
        insert article_3;
    }

    public static void createArticlesB2B() {

        createArticles();
        Item__c article_1 = [SELECT ID, Name, gdb_canBeSoldOnB2B__c FROM Item__c WHERE Name = 'article_1'];
        Item__c article_2 = [SELECT ID, Name, gdb_canBeSoldOnB2B__c FROM Item__c WHERE Name = 'article_2'];

        article_1.gdb_canBeSoldOnB2B__c = true;
        article_2.gdb_canBeSoldOnB2B__c = true;

        update article_1;
        update article_2;

    }

    public static void createArticleShippingLink() {
        List<GDB_Shipping_Method__c> shippingsMethods = [SELECT Id FROM GDB_Shipping_Method__c];
        List<gdb_item_type__c> articlesTypes = [SELECT Id FROM gdb_item_type__c];

        List<gdb_article_shipping_link__c> asls = new List<gdb_article_shipping_link__c>();
        Integer i = 1;
        for(gdb_item_type__c at : articlesTypes){
            gdb_article_shipping_link__c asl = new gdb_article_shipping_link__c();
            asl.Name = 'Link ' + i;
            asl.gdb_item_type__c = at.Id;
            asl.gdb_shipping_method__c = shippingsMethods.get(0).Id;
            asls.add(asl);
            i++;
        }

        insert asls;
    }

    public static void createWarehouseArticleJunctionWithSamePrice() {
        Item__c article_1 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_1'];
        Item__c article_2 = [SELECT ID, Name FROM Item__c WHERE Name = 'article_2'];

        GDB_Warehouse__c wh_1 = [SELECT ID, gdb_reference__c FROM GDB_Warehouse__c WHERE gdb_reference__c =
            'Dépôt_1'
        ];
        GDB_Warehouse__c wh_2 = [SELECT ID, gdb_reference__c FROM GDB_Warehouse__c WHERE gdb_reference__c =
            'Dépôt_2'
        ];

        GDB_Warehouse_Has_Product__c whhp_1 = new GDB_Warehouse_Has_Product__c();
        whhp_1.gdb_inventory_threshold__c = 50;
        whhp_1.Name = wh_1.gdb_reference__c + article_1.Name + 'Same_Price';
        whhp_1.gdb_price__c = 50;
        whhp_1.gdb_Article__c = article_1.Id;
        whhp_1.gdb_quantity__c = 20;
        whhp_1.gdb_Warehouse__c = wh_1.Id;
        whhp_1.gdb_sku__c = wh_1.gdb_reference__c + article_1.Name;
        whhp_1.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_2 = new GDB_Warehouse_Has_Product__c();
        whhp_2.gdb_inventory_threshold__c = 50;
        whhp_2.Name = wh_2.gdb_reference__c + article_1.Name + 'Same_Price';
        whhp_2.gdb_price__c = 50;
        whhp_2.gdb_Article__c = article_1.Id;
        whhp_2.gdb_quantity__c = 20;
        whhp_2.gdb_Warehouse__c = wh_2.Id;
        whhp_2.gdb_sku__c = wh_2.gdb_reference__c + article_1.Name;
        whhp_2.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_3 = new GDB_Warehouse_Has_Product__c();
        whhp_3.gdb_inventory_threshold__c = 50;
        whhp_3.Name = wh_1.gdb_reference__c + article_2.Name + 'Same_Price';
        whhp_3.gdb_price__c = 150;
        whhp_3.gdb_Article__c = article_2.Id;
        whhp_3.gdb_quantity__c = 20;
        whhp_3.gdb_Warehouse__c = wh_1.Id;
        whhp_3.gdb_sku__c = wh_1.gdb_reference__c + article_2.Name;
        whhp_3.gdb_tax__c = 10;

        GDB_Warehouse_Has_Product__c whhp_4 = new GDB_Warehouse_Has_Product__c();
        whhp_4.gdb_inventory_threshold__c = 50;
        whhp_4.Name = wh_2.gdb_reference__c + article_2.Name + 'Same_Price';
        whhp_4.gdb_price__c = 150;
        whhp_4.gdb_Article__c = article_2.Id;
        whhp_4.gdb_quantity__c = 20;
        whhp_4.gdb_Warehouse__c = wh_2.Id;
        whhp_4.gdb_sku__c = wh_2.gdb_reference__c + article_2.Name;
        whhp_4.gdb_tax__c = 10;

        insert whhp_1;
        insert whhp_2;
        insert whhp_3;
        insert whhp_4;
    }

    public static void createButaCustomSettings(Id personAccountID) {
        // Custom settings
        Custom_Settings__c c0 = new Custom_Settings__c(name='Account_RecordTypeId_GDBPA', value__c = personAccountID);
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c3 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c4 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c5 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c6 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c0, c1, c2, c3, c4, c5, c6 };
    }

    public static void createCustomSettings() {
        Id personAccountID = Id.valueOf(String.valueOf([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account'
            AND DeveloperName = 'GDB_PersonAccount'
            LIMIT 1
        ].Id).subString(0, 15));

        Activity_Domain__c ad = getActivityDomain();
        if(ad == null) {
            createActivityDomain();
            ad = getActivityDomain();
        }

        GDB_Configurations__c setting = new GDB_Configurations__c();
        setting.mercanetMerchantID__c = 'test';
        setting.mercanetSecretKey__c = 'test';
        setting.mercanetURL__c = 'test';
        setting.mercanetPaymentTimes__c = 5;
        setting.mercanetTimeBetweenPayments__c = 5;
        setting.maximumUseOfPromotionPerUser__c = 5;
        setting.mercanetFraudData__c = '{}';
        setting.guestType__c = 'Guest';
        setting.activityDomainType__c = ad.Id;
        setting.articleType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Item__c'
            AND DeveloperName = 'ECommerce_Article'
            LIMIT 1
        ].Id;
        setting.orderType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c'
            AND DeveloperName = 'GDB_Ecom'
            LIMIT 1
        ].Id;
        setting.communityName__c = 'Butagaz Ecommerce Community';
        setting.b2b_communityName__c = 'Butagaz Ecommerce Community B2B';
        setting.orderSplitType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c'
            AND DeveloperName = 'GDB_Split_Orders'
            LIMIT 1
        ].Id;
        setting.maximumUseOfPromotionPerUser__c = 1;

        setting.accountMandataireId__c = createAndGetMandataire().Id;

        setting.orderOrigin__c = 'WEB';
        setting.orderTypeOrigin__c = 'WB';
        setting.productScale__c = 'DGB2C';
        setting.personAccountTypeId__c = personAccountID;
        setting.docapost_endpoint__c  = 'https://sae.docapost-dps.com/9217751_welcome/index.php?numero_document={0}';
        setting.docapost_certificate_name__c  = 'wsdocapostp_butagaz_com_20180807';
        setting.activateErrorTracing__c = true;
        setting.activateGoogleAnalyticsTracking__c = true;
        setting.gdb_parrainage_montant__c = 20;
        setting.gdb_parrainage_shipping_minimum_price__c = 20;
        setting.gdb_parrainage_max_end_date__c = Datetime.newInstance(2099, 12, 31).date();
        setting.GDB_Bulk_Delivered_Zip_Codes__c = '71,69';
    
        insert setting;

        GDB_Product_Nudge__c nudgeSettings = new GDB_Product_Nudge__c();
        nudgeSettings.gdb_display_nb_months__c = 3;
        nudgeSettings.gdb_display_nb_months_max__c = 6;
        nudgeSettings.gdb_min_threshold__c = 10;
        nudgeSettings.gdb_default_zipcode__c = '59000';
        insert nudgeSettings; 

        GDB_TestDataFactory.createButaCustomSettings(personAccountID);
    }

    public static User getAdminUser() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Butagaz System Administrator' LIMIT 1];
        return [SELECT Id, AccountId, ProfileId, Name FROM User WHERE ProfileId = :p.Id AND isActive = true AND Bypass_Validation_Rules__c = true LIMIT 1];
    }

    public static User getGuestUser() {
        return [select id, name from User where userType = 'Guest'
            LIMIT 1
        ];
    }

    public static String getLoginURL(GDB_ArticleVM article) {
        System.assertNotEquals(null, GDB_Constants.communityName, 'getLoginURL need custom settings data');
        String param = GDB_Utils.getCommunityUrlPathPrefix(GDB_Constants.communityName) + article.pageUrl;
        String page = GDB_Utils.getLoginPageWithParam(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(1), param);
        return page;
    }

    public static void createActivityDomain() {
        if(getActivityDomain() == null) {
            Activity_Domain__c activityDomain = new Activity_Domain__c();
            activityDomain.Name = 'GDB - Granulés de bois';
            activityDomain.Active__c = true;
            activityDomain.ExternalID__c = 50;
            insert activityDomain;
        }
    }

    public static Activity_Domain__c getActivityDomain() {
        Activity_Domain__c[] ad = [SELECT ID FROM Activity_Domain__c where ExternalID__c = 50 LIMIT 1];

        if(ad.size() > 0){
            return ad[0];
        }
        else{
            return null;
        }
    }


    public static void createPromotion() {
        GDB_Promotion__c promotion = new GDB_Promotion__c();
        promotion.Name = 'Test promotion';
        promotion.gdb_coupon_code__c = 'PERCENTAGE_PRICE';
        promotion.gdb_end_date__c = DateTime.newInstance(2025, 12, 31, 0, 0, 0);
        promotion.gdb_numberOfTotalUse__c = 1;
        promotion.gdb_numberOfUsePerUser__c = 1;
        promotion.gdb_start_date__c = DateTime.newInstance(2017, 1, 1, 0, 0, 0);
        promotion.gdb_status__c = true;
        promotion.gdb_target__c = 'Shipping';
        promotion.gdb_type__c = 'Percentage';
        promotion.gdb_value__c = 50;
        insert promotion;


        GDB_Promotion__c promotionPrice = new GDB_Promotion__c();
        promotionPrice.Name = 'PROMO_PRICE';
        promotionPrice.gdb_coupon_code__c = 'PROMO_PRICE';
        promotionPrice.gdb_end_date__c = DateTime.newInstance(2025, 12, 31, 0, 0, 0);
        promotionPrice.gdb_numberOfTotalUse__c = 1;
        promotionPrice.gdb_numberOfUsePerUser__c = 1;
        promotionPrice.gdb_start_date__c = DateTime.newInstance(2017, 1, 1, 0, 0, 0);
        promotionPrice.gdb_status__c = true;
        promotionPrice.gdb_target__c = 'Shipping';
        promotionPrice.gdb_type__c = 'Price';
        promotionPrice.gdb_value__c = 20;
        insert promotionPrice;

        GDB_Promotion__c promotionWithoutType = new GDB_Promotion__c();
        promotionWithoutType.Name = 'Promotion without type';
        promotionWithoutType.gdb_coupon_code__c = 'Promotion_without_type';
        promotionWithoutType.gdb_end_date__c = DateTime.newInstance(2025, 12, 31, 0, 0, 0);
        promotionWithoutType.gdb_numberOfTotalUse__c = 1;
        promotionWithoutType.gdb_numberOfUsePerUser__c = 1;
        promotionWithoutType.gdb_start_date__c = DateTime.newInstance(2017, 1, 1, 0, 0, 0);
        promotionWithoutType.gdb_status__c = true;
        promotionWithoutType.gdb_target__c = 'Shipping';
        promotionWithoutType.gdb_type__c = '';
        promotionWithoutType.gdb_value__c = 50;
        insert promotionWithoutType;

        GDB_Promotion__c promotionBadType = new GDB_Promotion__c();
        promotionBadType.Name = 'Promotion bad type';
        promotionBadType.gdb_coupon_code__c = 'Promotion_bad_type';
        promotionBadType.gdb_end_date__c = DateTime.newInstance(2025, 12, 31, 0, 0, 0);
        promotionBadType.gdb_numberOfTotalUse__c = 1;
        promotionBadType.gdb_numberOfUsePerUser__c = 1;
        promotionBadType.gdb_start_date__c = DateTime.newInstance(2017, 1, 1, 0, 0, 0);
        promotionBadType.gdb_status__c = true;
        promotionBadType.gdb_target__c = 'Shipping';
        promotionBadType.gdb_type__c = 'Bad_Type';
        promotionBadType.gdb_value__c = 50;
        insert promotionBadType;
    }


    public static void createPromotionWithoutNumberOfUsePerUser() {
        GDB_Promotion__c promotion = new GDB_Promotion__c();
        promotion.Name = 'Test promotion';
        promotion.gdb_coupon_code__c = 'TEST';
        promotion.gdb_end_date__c = DateTime.newInstance(2025, 12, 31, 0, 0, 0);
        promotion.gdb_numberOfTotalUse__c = 1;
        promotion.gdb_numberOfUsePerUser__c = null;
        promotion.gdb_start_date__c = DateTime.newInstance(2017, 1, 1, 0, 0, 0);
        promotion.gdb_status__c = true;
        promotion.gdb_target__c = 'Shipping';
        promotion.gdb_type__c = 'Percentage';
        promotion.gdb_value__c = 50;
        insert promotion;
    }

    public static GDB_Promotion__c getPromotion() {
        GDB_Promotion__c[] p = [SELECT ID, Name,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_coupon_code__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c,
            gdb_min_shipping_price__c
            FROM GDB_Promotion__c LIMIT 1
        ];

        if(p.size() > 0){
            return p[0];
        }
        else{
            return null;
        }
    }

    public static GDB_Promotion__c getPourcentagePromotion() {
        return [SELECT ID, Name,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_coupon_code__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c
            FROM GDB_Promotion__c WHERE gdb_type__c = 'Percentage'
            LIMIT 1
        ];
    }

    public static GDB_Promotion__c getPricePromotion() {
        return [SELECT ID, Name,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_coupon_code__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c
            FROM GDB_Promotion__c WHERE gdb_type__c = 'Price'
            LIMIT 1
        ];
    }

    public static GDB_Promotion__c getPromotionWithoutType() {
        return [SELECT ID, Name,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_coupon_code__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c
            FROM GDB_Promotion__c
            WHERE gdb_type__c = ''
            LIMIT 1
        ];
    }

    public static GDB_Promotion__c getPromotionBadType() {
        return [SELECT ID, Name,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_coupon_code__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c
            FROM GDB_Promotion__c
            WHERE gdb_type__c = 'Bad_Type'
            LIMIT 1
        ];
    }

    public static void createPaymentMethod() {
        GDB_Payment_Method__c paymentMethod = new GDB_Payment_Method__c();
        paymentMethod.Name = 'Mercanet';
        paymentMethod.gdb_isMethodPaymentDisplayed__c = true;
        insert paymentMethod;
    }

    public static GDB_Payment_Method__c getPaymentMethod() {
        return [SELECT ID, Name fROM GDB_Payment_Method__c WHERE Name = 'Mercanet'
            LIMIT 1
        ];
    }

    public static GDB_Shipping_Method__c createShippingMethod() {
        GDB_Shipping_Method__c shippingMethod = new GDB_Shipping_Method__c();
        shippingMethod.Name = 'Livraison Standard';
        shippingMethod.gdb_title__c = 'Livraison Standard';
        shippingMethod.gdb_description__c = 'Description Livraison Standard';
        shippingMethod.gdb_promotional_message__c = 'Promo Message';
        shippingMethod.gdb_active__c = true;
        shippingMethod.gdb_is_default__c = true;
        shippingMethod.gdb_display_order__c = 1;
        shippingMethod.gdb_price__c = 60;
        shippingMethod.gdb_tax__c = 5.46;
        shippingMethod.gdb_number_of_remaining_use__c = 100;
        insert shippingMethod;
        
        return shippingMethod;
    }

    public static void createShippingMethodOption() {
        List<GDB_Shipping_Method__c> sm = [SELECT Id FROM GDB_Shipping_Method__c];

        if(sm.size() > 0){
            GDB_Shipping_Option__c shippingMethodOption = new GDB_Shipping_Option__c();
            shippingMethodOption.Name = 'Option Livraison 2 fois';
            shippingMethodOption.gdb_shipping_method__c = sm.get(0).id;
            shippingMethodOption.gdb_active__c = true;
            shippingMethodOption.gdb_multiple_shipping__c = true;
            shippingMethodOption.gdb_minimal_product__c = 1;
            shippingMethodOption.gdb_minimal_shipping__c = 1;
            shippingMethodOption.gdb_title__c = 'Livraison 2 fois';
            shippingMethodOption.gdb_description__c = 'description';
            shippingMethodOption.Promotional_Message__c = 'message promo';
            shippingMethodOption.gdb_display_order__c = 1;
            shippingMethodOption.gdb_price__c = 20;
            shippingMethodOption.gdb_tax__c = 5.46;
            insert shippingMethodOption;
        }
    }

    public static void createShippingMethodPrice(){
        gdb_shipping_method_price__c shippingMethodPrice = new gdb_shipping_method_price__c();
        GDB_Shipping_Method__c sm = getShippingMethod();
        shippingMethodPrice.gdb_minimum_article__c = 2;
        shippingMethodPrice.gdb_price__c = 50;
        shippingMethodPrice.gdb_tax__c = 4.56;
        shippingMethodPrice.gdb_shipping_method__c = sm.ID;

        insert shippingMethodPrice;
    }

    public static GDB_Shipping_Method__c getShippingMethod() {
        GDB_Shipping_Method__c[] sm = [SELECT ID, Name, gdb_description__c, gdb_price__c, gdb_tax__c FROM GDB_Shipping_Method__c WHERE Name =
            'Livraison Standard'
            LIMIT 1
        ];

        if(sm.size() > 0){
            return sm[0];
        }
        else{
            return null;
        }
    }

    public static Order__c createOrder(Account a) {
        Order__c o = new Order__c();
        Boolean withPrices = false;

        if(a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }

        System.assertNotEquals(null, getActivityDomain(), 'createOrder need activityDomain data');
        System.assertNotEquals(null, getPaymentMethod(), 'createOrder need paymentMethod data');
        System.assertNotEquals(null, getShippingMethod(), 'createOrder need shippingMethod data');
        System.assertNotEquals(null, getWarehouseByReference('Dépôt_1'), 'createOrder need warehouse data');
        System.assertNotEquals(null, '3', 'createOrder need custom settings data');

        o.Name = 'GDB_123456';
        o.Account__c = a.Id;
        o.Activity_Domain__c = getActivityDomain().Id;
        o.gdb_Discount__c = null;
        o.gdb_Payment_Method__c = getPaymentMethod().Id;
        o.gdb_Shipping_Method__c = getShippingMethod().Id;
        o.gdb_Warehouse__c = getWarehouseByReference('Dépôt_1').Id;
        // Addresses
        o.gdb_billing_salutation__c = 'M';
        o.gdb_billing_firstname__c = 'Test_1';
        o.gdb_billing_lastname__c = 'Test_1';
        o.gdb_billing_address1__c = '1 rue des planches';
        o.gdb_billing_address2__c = '';
        o.gdb_billing_address3__c = '';
        o.gdb_billing_city__c = 'MACON';
        o.gdb_billing_zip__c = '71000';
        o.gdb_billing_country__c = 'FRANCE';
        o.gdb_billing_phone__c = '0123456789';
        o.gdb_shipping_salutation__c = 'M';
        o.gdb_shipping_firstname__c = 'Test_1';
        o.gdb_shipping_lastname__c = 'Test_1';
        o.gdb_shipping_address1__c = '1 rue des planches';
        o.gdb_shipping_address2__c = '';
        o.gdb_shipping_address3__c = '';
        o.gdb_shipping_city__c = 'MACON';
        o.gdb_shipping_zip__c = '71000';
        o.gdb_shipping_country__c = 'FRANCE';
        o.gdb_shipping_phone__c = '0123456789';
        // Account details
        o.gdb_customer_title__c = 'M';
        o.gdb_customer_firstname__c = 'Test_1';
        o.gdb_customer_lastname__c = 'Test_1';
        o.gdb_email__c = 'test1@yopmail.com';
        // Attributes
        o.gdb_coupon_code__c = '';
        o.gdb_payment_method_name__c = getPaymentMethod().Name;
        
        GDB_Shipping_Method__c shippingMethod = getShippingMethod();
        o.gdb_shipping_method_name__c = shippingMethod.Name;
        o.gdb_shipping_method_description__c = shippingMethod.gdb_description__c;
        o.gdb_multiple_shipping__c = false;
        o.gdb_multiple_payment__c = false;
        o.gdb_shipping_instructions__c = '';
        o.gdb_warehouse_email__c = 'email.transporteur@yopmail.com';
        o.Order_Date_and_Time__c = DateTime.now();
        o.Order_Status__c = '3';
        // Initialize prices as 0 and bind them after if required
        o.gdb_shipping_price__c = 0;
        o.gdb_discount_price__c = 0;
        o.gdb_total_gross_price__c = 0;
        o.gdb_total_net_price__c = 0;
        o.gdb_total_tax__c = 0;
        o.gdb_isSample__c = false;

        o.Order_Status__c = '3';
        o.RecordTypeId = GDB_Constants.orderTypeId;
        o.gdb_isB2B__c = false;

        if (withPrices) {
            // Prices
            o.gdb_shipping_price__c = getShippingMethod().gdb_price__c;
            o.gdb_discount_price__c = 0;
            o.gdb_total_gross_price__c = 0;
            o.gdb_total_net_price__c = 0;
            o.gdb_total_tax__c = 0;
        }

        insert o;
        
        return o;
    }

    public static void createChildorder(Order__c parentOrder, Account a) {
        Order__c o = new Order__c();
        Boolean withPrices = false;

        if(a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }

        System.assertNotEquals(null, getActivityDomain(), 'createOrder need activityDomain data');
        System.assertNotEquals(null, getPaymentMethod(), 'createOrder need paymentMethod data');
        System.assertNotEquals(null, getShippingMethod(), 'createOrder need shippingMethod data');
        System.assertNotEquals(null, getWarehouseByReference('Dépôt_1'), 'createOrder need warehouse data');
        System.assertNotEquals(null, '3', 'createOrder need custom settings data');

        o.Name = 'GDB_123456789';
        o.Account__c = a.Id;
        o.Activity_Domain__c = getActivityDomain().Id;
        o.gdb_Discount__c = null;
        o.gdb_Payment_Method__c = getPaymentMethod().Id;
        o.gdb_Shipping_Method__c = getShippingMethod().Id;
        o.gdb_Warehouse__c = getWarehouseByReference('Dépôt_1').Id;
        // Addresses
        o.gdb_billing_salutation__c = 'M';
        o.gdb_billing_firstname__c = 'Test_1';
        o.gdb_billing_lastname__c = 'Test_1';
        o.gdb_billing_address1__c = '1 rue des planches';
        o.gdb_billing_address2__c = '';
        o.gdb_billing_address3__c = '';
        o.gdb_billing_city__c = 'MACON';
        o.gdb_billing_zip__c = '71000';
        o.gdb_billing_country__c = 'FRANCE';
        o.gdb_billing_phone__c = '0123456789';
        o.gdb_shipping_salutation__c = 'M';
        o.gdb_shipping_firstname__c = 'Test_1';
        o.gdb_shipping_lastname__c = 'Test_1';
        o.gdb_shipping_address1__c = '1 rue des planches';
        o.gdb_shipping_address2__c = '';
        o.gdb_shipping_address3__c = '';
        o.gdb_shipping_city__c = 'MACON';
        o.gdb_shipping_zip__c = '71000';
        o.gdb_shipping_country__c = 'FRANCE';
        o.gdb_shipping_phone__c = '0123456789';
        // Account details
        o.gdb_customer_title__c = 'M';
        o.gdb_customer_firstname__c = 'Test_1';
        o.gdb_customer_lastname__c = 'Test_1';
        o.gdb_email__c = 'test1@yopmail.com';
        // Attributes
        o.gdb_coupon_code__c = '';
        o.gdb_payment_method_name__c = getPaymentMethod().Name;
        
        GDB_Shipping_Method__c shippingMethod = getShippingMethod();
        o.gdb_shipping_method_name__c = shippingMethod.Name;
        o.gdb_shipping_method_description__c = shippingMethod.gdb_description__c;
        o.gdb_multiple_shipping__c = false;
        o.gdb_multiple_payment__c = false;
        o.gdb_shipping_instructions__c = '';
        o.gdb_warehouse_email__c = 'email.transporteur@yopmail.com';
        o.Order_Date_and_Time__c = DateTime.now();
        o.Order_Status__c = '3';
        // Initialize prices as 0 and bind them after if required
        o.gdb_shipping_price__c = 0;
        o.gdb_discount_price__c = 0;
        o.gdb_total_gross_price__c = 0;
        o.gdb_total_net_price__c = 0;
        o.gdb_total_tax__c = 0;
        o.gdb_isSample__c = false;

        o.gdb_parent_order__c = parentOrder.Id;
        o.Order_Status__c = '3';
        o.RecordTypeId = GDB_Constants.orderTypeId;

        o.gdb_isB2B__c = false;

        if (withPrices) {
            // Prices
            o.gdb_shipping_price__c = getShippingMethod().gdb_price__c;
            o.gdb_discount_price__c = 0;
            o.gdb_total_gross_price__c = 0;
            o.gdb_total_net_price__c = 0;
            o.gdb_total_tax__c = 0;
        }

        insert o;
    }


    public static Order__c getOrder() {
        List<Order__c> orders = [SELECT
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Activity_Domain__c,
            Full_Address__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_discount_price__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_warehouse_email__c,
            gdb_Warehouse__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            ExternalID__c,
            RecordTypeId,
            gdb_Discount__r.Name,
            gdb_isB2B__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                Unit__c,
                Article_Name__c FROM Articles_dans_Commande__r ORDER BY gdb_sku__c
            )
          FROM Order__c WHERE Name = 'GDB_123456' LIMIT 1];

          if (orders == null || orders.size() == 0) {
              return null;
          }

          return orders.get(0);
    }

    public static Order__c getChildOrder() {
        return [SELECT ID FROM Order__c WHERE Name = 'GDB_123456789' LIMIT 1];
    }

    public static void createItemsInOrderWithWarehouse(Order__c o, gdb_warehouse__c war) {
        Item__c article_1 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_1'];
            System.assertNotEquals(null, article_1, 'createItemsInOrder need article data');
            Item_in_Order__c op = new Item_in_Order__c(
                // Attributes
                gdb_name__c = article_1.Name,
                gdb_description__c = article_1.gdb_description__c,
                Unit__c = 'article_1',
                Quantity__c = 5,
                gdb_sku__c = 'GB_P15_BRA',  //'GDB_P15_1',
                // Prices
                gdb_total_gross_price__c = 500,
                gdb_total_net_price__c = 450,
                gdb_total_tax__c = 50,
                gdb_unit_gross_price__c = 100,
                gdb_unit_net_price__c = 90,
                gdb_unit_tax__c = 10,

                Article__c = article_1.Id,
                Commande__c = o.Id
            );
            if(war != null) {
                op.gdb_warehouse__c = war.Id;
            }
            insert op;

            Item__c article_2 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_2'];
            System.assertNotEquals(null, article_2, 'createItemsInOrder need article data');
            Item_in_Order__c op2 = new Item_in_Order__c(
                // Attributes
                gdb_name__c = article_2.Name,
                gdb_description__c = article_2.gdb_description__c,
                Unit__c = 'article_2',
                Quantity__c = 5,
                gdb_sku__c = 'GB_P08_BRA',  //'GDB_P8_1',
                // Prices
                gdb_total_gross_price__c = 500,
                gdb_total_net_price__c = 450,
                gdb_total_tax__c = 50,
                gdb_unit_gross_price__c = 100,
                gdb_unit_net_price__c = 90,
                gdb_unit_tax__c = 10,
                Article__c = article_2.Id,
                Commande__c = o.Id
            );
            if(war != null) {
                op2.gdb_warehouse__c = war.Id;
            }
            insert op2;
        
          Item__c article_3 = [SELECT ID, Name, gdb_description__c,Code_Article__c FROM Item__c WHERE Code_Article__c = :GDB_Constants.articleCode.get(2) LIMIT 1];
            System.assertNotEquals(null, article_3, 'createItemsInOrder need article data');
            Item_in_Order__c op3 = new Item_in_Order__c(
                // Attributes
                gdb_name__c = article_3.Name,
                gdb_description__c = article_3.gdb_description__c,
                Unit__c = article_3.Code_Article__c,
                Quantity__c = 5,
                gdb_sku__c = article_3.Code_Article__c,
                // Prices
                gdb_total_gross_price__c = 500,
                gdb_total_net_price__c = 450,
                gdb_total_tax__c = 50,
                gdb_unit_gross_price__c = 100,
                gdb_unit_net_price__c = 90,
                gdb_unit_tax__c = 10,
                Article__c = article_2.Id,
                Commande__c = o.Id
            );
            if(war != null) {
                op3.gdb_warehouse__c = war.Id;
            }
            insert op3;
        
          List<Item__c> articles4 = [SELECT ID, Name, gdb_description__c,Code_Article__c FROM Item__c WHERE Code_Article__c = :GDB_Constants.articleCode.get(1) LIMIT 1];
        
          if(!articles4.isEmpty())
            {
                Item__c article_4 = articles4.get(0);
                
                System.assertNotEquals(null, article_4, 'createItemsInOrder need article data');
                Item_in_Order__c op4 = new Item_in_Order__c(
                    // Attributes
                    gdb_name__c = article_4.Name,
                    gdb_description__c = article_4.gdb_description__c,
                    Unit__c = article_4.Code_Article__c,
                    Quantity__c = 5,
                    gdb_sku__c = article_4.Code_Article__c,
                    // Prices
                    gdb_total_gross_price__c = 500,
                    gdb_total_net_price__c = 450,
                    gdb_total_tax__c = 50,
                    gdb_unit_gross_price__c = 100,
                    gdb_unit_net_price__c = 90,
                    gdb_unit_tax__c = 10,
                    Article__c = article_2.Id,
                    Commande__c = o.Id
                );
                if(war != null) {
                    op4.gdb_warehouse__c = war.Id;
                }
                insert op4;
            }
    }

    public static void createItemsInOrder(Order__c o) {
       createItemsInOrderWithWarehouse(o, null);
    }


    public static void createItemsInChildOrder(Order__c o) {
        Item__c article_1 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_1'];
        System.assertNotEquals(null, article_1, 'createItemsInOrder need article data');
        Item_in_Order__c op = new Item_in_Order__c(
            // Attributes
            gdb_name__c = article_1.Name,
            gdb_description__c = article_1.gdb_description__c,
            Unit__c = 'article_1',
            Quantity__c = 1,
            gdb_sku__c = 'GB_P15_BRA',
            // Prices
            gdb_total_gross_price__c = 100,
            gdb_total_net_price__c = 90,
            gdb_total_tax__c = 10,
            gdb_unit_gross_price__c = 100,
            gdb_unit_net_price__c = 90,
            gdb_unit_tax__c = 10,
            Article__c = article_1.Id,
            Commande__c = o.Id
        );

        insert op;

        Item__c article_2 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_2'];
        System.assertNotEquals(null, article_1, 'createItemsInOrder need article data');
        Item_in_Order__c op2 = new Item_in_Order__c(
            // Attributes
            gdb_name__c = article_2.Name,
            gdb_description__c = article_2.gdb_description__c,
            Unit__c = 'article_2',
            Quantity__c = 1,
            gdb_sku__c = 'GB_P08_BRA',
            // Prices
            gdb_total_gross_price__c = 100,
            gdb_total_net_price__c = 90,
            gdb_total_tax__c = 10,
            gdb_unit_gross_price__c = 100,
            gdb_unit_net_price__c = 90,
            gdb_unit_tax__c = 10,
            Article__c = article_2.Id,
            Commande__c = o.Id
        );

        insert op2;
    }

    public static void createSampleOrder(Account a) {
        if (a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }
        Order__c o = new Order__c();
        Boolean withPrices = false;

        System.assertNotEquals(null, getActivityDomain(), 'createSampleOrder need activityDomain data');
        System.assertNotEquals(null, getPaymentMethod(), 'createSampleOrder need paymentMethod data');
        System.assertNotEquals(null, getShippingMethod(), 'createSampleOrder need shippingMethod data');
        System.assertNotEquals(null, getWarehouseByReference('Dépôt_1'), 'createSampleOrder need warehouse data');
        System.assertNotEquals(null, '3', 'createSampleOrder need custom settings data');

        o.Name = 'GDB_123456';
        o.Account__c = a.Id;
        o.Activity_Domain__c = getActivityDomain().Id;
        o.gdb_Discount__c = null;
        o.gdb_Payment_Method__c = getPaymentMethod().Id;
        o.gdb_Shipping_Method__c = getShippingMethod().Id;
        o.gdb_Warehouse__c = getWarehouseByReference('Dépôt_1').Id;
        // Addresses
        o.gdb_billing_salutation__c = 'M';
        o.gdb_billing_firstname__c = 'Test_1';
        o.gdb_billing_lastname__c = 'Test_1';
        o.gdb_billing_address1__c = '1 rue des planches';
        o.gdb_billing_address2__c = '';
        o.gdb_billing_address3__c = '';
        o.gdb_billing_city__c = 'MACON';
        o.gdb_billing_zip__c = '71000';
        o.gdb_billing_country__c = 'FRANCE';
        o.gdb_billing_phone__c = '0123456789';
        o.gdb_shipping_salutation__c = 'M';
        o.gdb_shipping_firstname__c = 'Test_1';
        o.gdb_shipping_lastname__c = 'Test_1';
        o.gdb_shipping_address1__c = '1 rue des planches';
        o.gdb_shipping_address2__c = '';
        o.gdb_shipping_address3__c = '';
        o.gdb_shipping_city__c = 'MACON';
        o.gdb_shipping_zip__c = '71000';
        o.gdb_shipping_country__c = 'FRANCE';
        o.gdb_shipping_phone__c = '0123456789';
        // Account details
        o.gdb_customer_title__c = 'M';
        o.gdb_customer_firstname__c = 'Test_1';
        o.gdb_customer_lastname__c = 'Test_1';
        o.gdb_email__c = 'test1@yopmail.com';
        // Attributes
        o.gdb_coupon_code__c = '';
        o.gdb_payment_method_name__c = getPaymentMethod().Name;
        
        GDB_Shipping_Method__c shippingMethod = getShippingMethod();
        o.gdb_shipping_method_name__c = shippingMethod.Name;
        o.gdb_shipping_method_description__c = shippingMethod.gdb_description__c;
        o.gdb_multiple_shipping__c = false;
        o.gdb_multiple_payment__c = false;
        o.gdb_shipping_instructions__c = '';
        o.gdb_warehouse_email__c = 'email.transporteur@yopmail.com';
        o.Order_Date_and_Time__c = DateTime.now();
        o.Order_Status__c = '3';
        // Initialize prices as 0 and bind them after if required
        o.gdb_shipping_price__c = 0;
        o.gdb_discount_price__c = 0;
        o.gdb_total_gross_price__c = 0;
        o.gdb_total_net_price__c = 0;
        o.gdb_total_tax__c = 0;
        o.gdb_isSample__c = true;

        if (withPrices) {
            // Prices
            o.gdb_shipping_price__c = getShippingMethod().gdb_price__c;
            o.gdb_discount_price__c = 0;
            o.gdb_total_gross_price__c = 0;
            o.gdb_total_net_price__c = 0;
            o.gdb_total_tax__c = 0;
        }

        insert o;
    }


    public static void createSampleItemsInSampleOrder(Order__c o) {
        Item__c article_1 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_1'];
        System.assertNotEquals(null, article_1, 'createSampleItemsInSampleOrder need article data');

        Item_in_Order__c op = new Item_in_Order__c(
            // Attributes
            gdb_name__c = article_1.Name,
            gdb_description__c = article_1.gdb_description__c,
            Unit__c = 'article_1',
            Quantity__c = 1,
            gdb_sku__c = 'GB_P15_BRA',
            // Prices
            gdb_total_gross_price__c = 100,
            gdb_total_net_price__c = 90,
            gdb_total_tax__c = 10,
            gdb_unit_gross_price__c = 100,
            gdb_unit_net_price__c = 90,
            gdb_unit_tax__c = 10,
            Article__c = article_1.Id,
            Commande__c = o.Id
        );

        insert op;
    }


    public static void createBasket(Account a) {
        if(a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }

        System.assertNotEquals(null, getActivityDomain(), 'createBasket need activityDomain data');
        System.assertNotEquals(null, getShippingMethod(), 'createBasket need shippingMethod data');
        System.assertNotEquals(null, getPromotion(), 'createBasket need promotion data');
        System.assertNotEquals(null, getPaymentMethod(), 'createBasket need payment method data');
        System.assertNotEquals(null, getWarehouseByReference('Dépôt_1'), 'createBasket need warehouse data');

        GDB_Shipping_Method__c sm = getShippingMethod();
        Activity_Domain__c ad = getActivityDomain();
        GDB_Promotion__c p = getPromotion();
        GDB_Payment_Method__c pm = getPaymentMethod();
        GDB_Basket__c b = new GDB_Basket__c(
            gdb_Account__c = a.Id,
            gdb_Shipping_Method__c = sm.Id,
            gdb_Activity_Domain__c = ad.Id,
            gdb_Payment_Method__c = pm.Id,
            gdb_Discount__c = p.Id,
            gdb_shipping_method_price__c = 1,
            gdb_shipping_method_tax__c = 2,
            gdb_discount_price__c = 0,
            gdb_discount_tax__c = 0,
            gdb_total_price__c = 0,
            gdb_total_tax__c = 0,
            gdb_shipping_firstname__c = 'test',
            gdb_shipping_lastname__c = 'test',
            gdb_shipping_salutation__c = 'Mme',
            gdb_shipping_address1__c = 'test',
            gdb_shipping_city__c = 'test',
            gdb_shipping_zip__c = '71000',
            gdb_shipping_country__c = 'test',
            gdb_shipping_phone__c = '012356789',
            gdb_billing_firstname__c = 'test',
            gdb_billing_lastname__c = 'test',
            gdb_billing_salutation__c = 'Mme',
            gdb_billing_address1__c = 'test',
            gdb_billing_city__c = 'test',
            gdb_billing_zip__c = '71000',
            gdb_billing_country__c = 'test',
            gdb_billing_phone__c = '012356789',
            gdb_warehouse__c = getWarehouseByReference('Dépôt_1').Id
        );
        insert b;
    }

    public static GDB_Basket__c createAndGetGuestBasketWithBasketProduct(String guestId) {
        return createAndGetBasketWithBasketProduct(null, guestId);
    }

    public static GDB_Basket__c createAndGetBasketWithBasketProduct(Account a) {
        if(a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }
        return createAndGetBasketWithBasketProduct(a.Id, null);
    }

    public static GDB_Basket__c createAndGetBasketWithBasketProduct(Id accountId, String guestId) 
    {
        Activity_Domain__c ad = getActivityDomain();

        System.assertNotEquals(null, ad, 'createAndGetBasketWithBasketProduct need activityDomain data');
        
        GDB_Shipping_Method__c sm = getShippingMethod();
        
        System.assertNotEquals(null, sm, 'createAndGetBasketWithBasketProduct need shippingMethod data');
        
        GDB_Promotion__c p = getPromotion();
        
        System.assertNotEquals(null, p, 'createAndGetBasketWithBasketProduct need promotion data');
        
        GDB_Warehouse__c warehouse = getWarehouseByReference('Dépôt_1');
        
        System.assertNotEquals(null, warehouse, 'createBasket need warehouse data');
                
        GDB_Basket__c b = new GDB_Basket__c(
            gdb_Account__c = accountId,
            gdb_guestid__c = guestId,
            gdb_Shipping_Method__c = sm.Id,
            gdb_Activity_Domain__c = ad.Id,
            gdb_Discount__c = p.Id,
            gdb_shipping_method_price__c = 1,
            gdb_discount_price__c = 0,
            gdb_shipping_method_tax__c = 1,
            gdb_shipping_option_price__c = 1,
            gdb_shipping_option_tax__c = 1,
            gdb_discount_tax__c = 0,
            gdb_total_price__c = 0,
            gdb_total_tax__c = 0,
            gdb_warehouse__c = warehouse.Id,
            gdb_multiple_payment_price__c = 0
        );
        insert b;
        
        List<GDB_Basket_Product__c> basketProducts = new List<GDB_Basket_Product__c>();
        List<Item__c> articles = [SELECT ID, Name, gdb_description__c, Code_Article__c FROM Item__c WHERE Name = 'article_1' OR Code_Article__c = :GDB_Constants.articleCode.get(2)];
        
        for(Item__c article : articles)
        {
            GDB_Basket_Product__c basketProduct = new GDB_Basket_Product__c(
                gdb_description__c = article.gdb_description__c,
                gdb_product_code__c = article.Code_Article__c,
                gdb_Article__c = article.Id,
                gdb_Basket__c = b.Id,
                gdb_quantity__c = 1,
                Name = article.Name,
                gdb_unit_price__c = 0,
                gdb_unit_tax__c = 0,
                gdb_total_price__c = 0,
                gdb_total_tax__c = 0,
                gdb_warehouse__c = warehouse.Id
            );
            
            basketProducts.add(basketProduct);
        }
        
        insert basketProducts;

        return GDB_BasketMgr.getBasketById(b.Id);
    }

    public static GDB_Basket__c createAndGetBasketWithMultiBasketProduct(Account a) {
        if(a == null) {
            a = GDB_TestDataFactory.getGlobalAccount();
        }
        
        Activity_Domain__c ad = getActivityDomain();

        System.assertNotEquals(null, ad, 'createAndGetBasketWithBasketProduct need activityDomain data');
        
        GDB_Shipping_Method__c sm = getShippingMethod();
        
        System.assertNotEquals(null, sm, 'createAndGetBasketWithBasketProduct need shippingMethod data');
        
        GDB_Promotion__c p = getPromotion();
        
        System.assertNotEquals(null, p, 'createAndGetBasketWithBasketProduct need promotion data');
        
        GDB_Warehouse__c warehouse = getWarehouseByReference('Dépôt_1');
        
        System.assertNotEquals(null, warehouse, 'createBasket need warehouse data');
        
        
        
        
        GDB_Basket__c b = new GDB_Basket__c(
            gdb_Account__c = a.Id,
            gdb_Shipping_Method__c = sm.Id,
            gdb_Activity_Domain__c = ad.Id,
            gdb_Discount__c = p.Id,
            gdb_shipping_method_price__c = 1,
            gdb_discount_price__c = 0,
            gdb_shipping_method_tax__c = 1,
            gdb_shipping_option_price__c = 0,
            gdb_discount_tax__c = 0,
            gdb_total_price__c = 0,
            gdb_total_tax__c = 0,
            gdb_warehouse__c = warehouse.Id
        );
        insert b;

        Item__c article = [SELECT ID, Name, gdb_description__c, Code_Article__c FROM Item__c WHERE Name =
            'article_1'
            LIMIT 1
        ];
        System.assertNotEquals(null, article, 'createAndGetBasketWithBasketProduct need article data');

        Item__c article2 = [SELECT ID, Name, gdb_description__c, Code_Article__c FROM Item__c WHERE Name =
            'article_2'
            LIMIT 1
        ];
        System.assertNotEquals(null, article2, 'createAndGetBasketWithBasketProduct need article data');

        GDB_Basket_Product__c bp = new GDB_Basket_Product__c(
            gdb_description__c = article.gdb_description__c,
            gdb_product_code__c = article.Code_Article__c,
            gdb_Article__c = article.Id,
            gdb_Basket__c = b.Id,
            gdb_quantity__c = 2,
            Name = article.Name,
            gdb_unit_price__c = 100,
            gdb_unit_tax__c = 10,
            gdb_total_price__c = 0,
            gdb_total_tax__c = 0,
            gdb_warehouse__c = warehouse.Id
        );
        insert bp;

        GDB_Basket_Product__c bp2 = new GDB_Basket_Product__c(
            gdb_description__c = article2.gdb_description__c,
            gdb_product_code__c = article2.Code_Article__c,
            gdb_Article__c = article2.Id,
            gdb_Basket__c = b.Id,
            gdb_quantity__c = 2,
            Name = article.Name,
            gdb_unit_price__c = 0,
            gdb_unit_tax__c = 0,
            gdb_total_price__c = 0,
            gdb_total_tax__c = 0,
            gdb_warehouse__c = warehouse.Id
        );
        insert bp2;

        return GDB_BasketMgr.getBasketById(b.Id);
    }

    public static void createBasketProduct(GDB_Basket__c b) {
        Item__c article = [SELECT ID, Name, gdb_description__c, Code_Article__c FROM Item__c WHERE Name =
            'article_1'
            LIMIT 1
        ];
        System.assertNotEquals(null, article, 'createAndGetBasketWithBasketProduct need article data');

        GDB_Basket_Product__c bp = new GDB_Basket_Product__c(
            gdb_description__c = article.gdb_description__c,
            gdb_product_code__c = article.Code_Article__c,
            gdb_Article__c = article.Id,
            gdb_Basket__c = b.Id,
            gdb_quantity__c = 1,
            Name = article.Name,
            gdb_unit_price__c = 10,
            gdb_unit_tax__c = 5,
            gdb_total_price__c = 15,
            gdb_total_tax__c = 5,
            gdb_warehouse__c = getWarehouseByReference('Dépôt_1').Id
        );
        insert bp;
    }

    public static GDB_Basket_Product__c getBasketProduct() {
        return [SELECT Id, Name FROM GDB_Basket_Product__c LIMIT 1];
    }

    public static GDB_Basket__c getBasket() {
        return [SELECT ID, gdb_shipping_method_price__c, gdb_shipping_zip__c,
                gdb_shipping_method_tax__c, gdb_discount_tax__c, gdb_Discount__c
                FROM GDB_Basket__c
                LIMIT 1];
    }

    public static GDB_Basket__c getBasketWithBasketProduct() {
        return [SELECT ID, gdb_shipping_method_price__c, gdb_shipping_zip__c,
                gdb_shipping_method_tax__c, gdb_discount_tax__c, gdb_Discount__c
                FROM GDB_Basket__c
                LIMIT 1];
    }

    public static GDB_Invoice__c createInvoice(Order__c o) {
        GDB_Invoice__c i = new GDB_Invoice__c();

        System.assertNotEquals(null, getActivityDomain(), 'createInvoice need activityDomain data');

        i.gdb_sap_invoice_no__c = '0000000001';
        i.gdb_Invoice_Date__c = date.today();
        i.gdb_Account__c = o.Account__c;
        i.gdb_Order__c = o.Id;
        i.Activity_Domain__c = getActivityDomain().Id;

        insert i;

        return i;
    }

    public static Account createAccount() {
        Activity_Domain__c ad;
        Canton__c canton;
        City__c city;
        City_Postal_Code__c cpc;

        if(GDB_TestDataFactory.getActivityDomain() == null){
            createActivityDomain();
        }

        ad = GDB_TestDataFactory.getActivityDomain();

        if([SELECT Name FROM Canton__c WHERE Name = 'TestCanton'].size() > 0){
            canton = [SELECT Name,INSEE_Code__c  FROM Canton__c WHERE Name = 'TestCanton'][0];
        }
        else{
            canton = new Canton__c(
            Name = 'TestCanton',
            INSEE_Code__c = '12345'
            );
            insert canton;
        }

        if([SELECT Name FROM City__c WHERE Name = 'TestCity'].size() > 0){
            city = [SELECT Name, Canton__c FROM City__c WHERE Name = 'TestCity'][0];
        }
        else{
            city = new City__c(
            Name = 'TestCity',
            Canton__c = canton.Id
            );
            insert city;
        }

        if([SELECT Postal_Code__c FROM City_Postal_Code__c WHERE Postal_Code__c = '71000'].size() > 0){
            cpc = [SELECT City__c, Postal_Code__c, HEXAPOSTE_Code__c FROM City_Postal_Code__c WHERE Postal_Code__c = '71000'][0];
        }
        else{
            cpc = new City_Postal_Code__c(
                City__c = city.Id,
                Postal_Code__c = '71000',
                HEXAPOSTE_Code__c = '111111'
            );
            insert cpc;
        }

        Account a = new Account(
            FirstName = 'Test',
            LastName = 'Test',
            Phone = '0123456789',
            Email__c = 'ordermgrtest@test.com',
            Activity_Domain__c = ad.Id,
            City_Postal_Code__c = cpc.Id,
            RecordTypeId = GDB_Constants.personAccountId,
            gdb_shipping_zip__c = cpc.Postal_Code__c,
            GDB_Already_Bought_Six_Densified_Logs__c = true
        );

        return a;
    }

    /**
    * Create GDB_article_media__c related to an article
    * @return {List<GDB_article_media__c>}
    */
    public static List<GDB_article_media__c> createMedia(String articleID){

        GDB_article_media__c media_1 = new GDB_article_media__c();
        media_1.Name = 'media_1';
        media_1.gdb_document_id_url__c = '0151X00000080FO';
        media_1.gdb_media_type__c = 'Picture';
        media_1.gdb_sort__c = 20;
        media_1.gdb_Article__c = articleID;

        GDB_article_media__c media_2 = new GDB_article_media__c();
        media_2.Name = 'media_2';
        media_2.gdb_document_id_url__c = '0151X00000080FO';
        media_2.gdb_media_type__c = 'Picture';
        media_2.gdb_sort__c = 10;
        media_2.gdb_Article__c = articleID;

        insert media_1;
        insert media_2;

        List<GDB_article_media__c> mediaList = [SELECT Id FROM GDB_article_media__c];

        return mediaList;
    }

    public static Mandataire__c createAndGetMandataire() {
        // Create mandataire
        Mandataire__c mandataire = new Mandataire__c();
        insert mandataire;

        return mandataire;

    }


}