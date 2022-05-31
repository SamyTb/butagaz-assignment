@isTest
private without sharing class GDB_Merge_Guest_BasketController_TEST {
    
    @isTest
    public static void testMergeGuestBasketToCustomer() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        
        GDB_Promotion__c p = GDB_TestDataFactory.getPromotion();
        GDB_Account_Has_Promotion__c junction = new GDB_Account_Has_Promotion__c(
            gdb_Account__c = GDB_TestDataFactory.getGlobalAccountId(),
            gdb_Promotion__c = p.Id
        );
        insert junction;
        
        User u = GDB_TestDataFactory.getGuestUser();
        Map<String, String> guest = GDB_AccountMgr.createNewGuest('71000');
        GDB_Basket__c b;
        System.runAs(u) {
            b = GDB_TestDataFactory.createAndGetGuestBasketWithBasketProduct(guest.get('Id'));
        }
        
        User u2 = GDB_TestDataFactory.createCommunityUser(null);
        System.runAs(u2) {
            Map<String, Object> result = GDB_Merge_Guest_BasketController.mergeGuestBasketToCustomer(null);
            System.assertEquals(null, result, 'result must be null');

            Map<String, String> guestData = new Map<String, String>{
                'id' => guest.get('Id'),
                'zipcode' => guest.get('ZipCode')
            };

            Account a = [SELECT Id FROM Account WHERE Id = :u2.AccountId];
            a.gdb_already_bought_bundle__c = true;
            update a;

            String sampleCode = GDB_Constants.articleCode.get(1);
            for(GDB_Basket_Product__c prod : b.Basket_Products__r) {
                prod.gdb_product_code__c = sampleCode;
                update prod;
                break;
            }

            result = GDB_Merge_Guest_BasketController.mergeGuestBasketToCustomer(guestData);
            System.assertNotEquals(null, result, 'result must not be null');
        
            result = GDB_Merge_Guest_BasketController.mergeGuestBasketToCustomer(guestData);
            System.assertEquals(null, result, 'result must be null');
        }
    }
    
    @isTest
    public static void testMergeGuestBasketToCustomerWithSixDensifiedLogsAlreadyBought() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        
        User u = GDB_TestDataFactory.getGuestUser();
        Map<String, String> guest = GDB_AccountMgr.createNewGuest('71000');
        GDB_Basket__c b;
        
        System.runAs(u) {
            b = GDB_TestDataFactory.createAndGetGuestBasketWithBasketProduct(guest.get('Id'));
        }
        
        User u2 = GDB_TestDataFactory.createCommunityUser(null);
        
        System.runAs(u2) {
            Map<String, String> guestData = new Map<String, String>{
                'id' => guest.get('Id'),
                'zipcode' => guest.get('ZipCode')
            };
            
            Map<String, Object> result = GDB_Merge_Guest_BasketController.mergeGuestBasketToCustomer(guestData);
            System.assertNotEquals(null, 'Result must not be null');
        }
    }

    @isTest
    public static void testDefaultZipCode() {
        GDB_TestDataFactory.createCustomSettings();
        System.assertNotEquals(null, GDB_Merge_Guest_BasketController.getDefaultZipCode());
    }

    @isTest
    public static void testIsAuthenticated() {
        GDB_TestDataFactory.createCustomSettings();
        User u = GDB_TestDataFactory.getGuestUser();
        System.runAs(u) {
            System.assertEquals(false, GDB_Merge_Guest_BasketController.isAuthenticated());
        }
    }
}