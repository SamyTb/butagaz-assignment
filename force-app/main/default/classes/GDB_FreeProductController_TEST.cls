@isTest
private class GDB_FreeProductController_TEST {
    public static Item__c article;
    public static Item__c article2;
    public static GDB_Basket__c b;
    public static GDB_Shipping_Method__c sm;
    public static GDB_Promotion__c pm;
    public static GDB_Basket_Product__c bp;
    public static GDB_Warehouse__c w;
    public static GDB_Warehouse_Has_Product__c whp;
    public static Account a;
    public static Activity_Domain__c ad;
    public static Canton__c canton;
    public static City__c city;
    public static City_Postal_Code__c cpc;
    public static Map<String,String> detailsForm;
    public static Map<String, String> emptyDetailsForm;

    private static String profileName = 'Butagaz System Administrator';

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
    static void testGetAvailableListValues (){
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            Account a = GDB_FreeProductController.getCurrentCustomer();

            Map<String, List<Map<String, String>>> allAvailableList = GDB_FreeProductController.getAvailableListValues();

            List<Map<String, String>> listCountries = allAvailableList.get('countries');
            System.assertEquals(false, listCountries.isEmpty());
        }
    }

    @isTest
    static void testSubmitFreeProductFormWithEmptyForm(){
        initializeObjects();
        detailsForm.put('salutation', 'Mme');
        Map<String, String> result1 = GDB_FreeProductController.submitFreeProductForm(detailsForm);
        System.assertNotEquals(0, result1.size(), 'Return value should not be empty');
        System.assertEquals(true, result1.containsKey('message'), 'Return value should contain an error message');
    }

    @isTest
    static void testSubmitFreeProductFormWithBadProduct(){
        initializeObjects();
        Map<String, String> result1 = GDB_FreeProductController.submitFreeProductForm(emptyDetailsForm);
        System.assertNotEquals(0, result1.size(), 'Return value should not be empty');
        System.assertEquals(true, result1.containsKey('message'), 'Return value should contain an error message');
    }

    @isTest
    static void testSubmitFreeProductForm (){
        Map<String, String> result1 = GDB_FreeProductController.submitFreeProductForm(null);
        initializeObjects();
        Map<String, String> result2 = GDB_FreeProductController.submitFreeProductForm(detailsForm);
        detailsForm.put('salutation', 'Mme');
        Map<String, String> result3 = GDB_FreeProductController.submitFreeProductForm(detailsForm);

        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u){
            Map<String,String> result5 = GDB_FreeProductController.submitFreeProductForm(detailsForm);
        }
    }
    
    @isTest
    static void isCustomerAlreadyBoughtSampleProduct() {
        initializeObjects();

        User u = GDB_TestDataFactory.getCommunityUserByProfile();

        Id productId = [SELECT ID FROM Item__c WHERE gdb_isSample__c = true LIMIT 1].Id;
        System.runAs(u){
            Boolean res = GDB_FreeProductController.isCustomerAlreadyBoughtSampleProduct(productId);
            System.assertEquals(false, res, 'Return value should be false');
        }
    }

    @isTest
    static void initializeObjects() {
        gdb_item_type__c type1 = new gdb_item_type__c();
        type1.Name = 'Palette';
        insert type1;

        article = new Item__c(
            Name = 'article_1',
            Code_Article__c = 'AAA_1',
            gdb_item_type__c = type1.Id,
            gdb_description__c = 'Desc_Article_1',
            gdb_online__c = true,
            gdb_technical_characteristics__c = 'tech_charact_1',
            RecordTypeId = GDB_Constants.articleTypeId,
            gdb_isSample__c = true
        );
        insert article;

        detailsForm = new Map<String, String>{
               'salutation' => '',
               'firstName' => 'Test',
               'lastName' => 'Test',
               'address1' => 'Test',
               'address2' => 'Test',
               'address3' => 'Test',
               'phone' => 'Test',
               'zip' => 'Test',
               'city' => 'Test',
               'country' => 'Test',
               'productId' => article.Id
            };
            
        emptyDetailsForm = new Map<String, String>{
               'salutation' => '',
               'firstName' => '',
               'lastName' => '',
               'address1' => '',
               'address2' => '',
               'address3' => '',
               'phone' => '',
               'zip' => '',
               'city' => '',
               'country' => '',
               'productId' => article.Id
            };
    }
}