@isTest 
private class GDB_ProductUtils_TEST {

    public static User adminUser;
    public static User guestUser;
    public static GDB_ArticleVM article;
    public static GDB_ArticleVM article2;
    public static GDB_Basket__c b;
    public static GDB_Basket__c b1;
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

    // Tests as guest user
    @isTest
    static void testGetProductIdWithEanNull() {
        String pId = GDB_ProductUtils.getProductId(null);
        System.assertEquals('', pId, 'Return value should be empty value');
    }

    @isTest
    static void testGetProductIdWithEanEmpty() {
        String pId = GDB_ProductUtils.getProductId('');
        System.assertEquals('', pId, 'Return value should be empty value');
    }

    @isTest
    static void testGetProductIdWithEanNotExist() {
        String pId = GDB_ProductUtils.getProductId('AZE');
        System.assertEquals('', pId, 'Return value should be empty value');
    }

    @isTest
    static void testGetProductIdWithEanExisting() {
        String pId = GDB_ProductUtils.getProductId('AAA_1');
        System.assertNotEquals('', pId, 'Return value should not be empty value');
    }

    @isTest
    static void testGetAllProductsAsGuestUser() {
        guestUser = GDB_TestDataFactory.getGuestUser();
        System.runAs(guestUser) {
            List<GDB_ArticleVM> gdb_whp = GDB_ProductUtils.getProducts('');
            System.assertNotEquals(null, gdb_whp.size(), 'Return value should not be null');
            System.assert(gdb_whp.size() > 0);
        }
    }

    @isTest
    static void testGetOneProductAsGuestUser() {
        GDB_ArticleVM article = GetProductForTest();
        guestUser = GDB_TestDataFactory.getGuestUser();
        System.runAs(guestUser) {
            List<GDB_ArticleVM> gdb_whp = GDB_ProductUtils.getProducts(article.Id, 'gdb_warehouseproduct__r.gdb_article__r.gdb_sort__c', 'ASC');
            System.assertEquals(1, gdb_whp.size(), 'Return size value should be 1');
        }
    }


    @isTest
    static void testAddToCartAsGuestUser() {
        guestUser = GDB_TestDataFactory.getGuestUser();
        GDB_ArticleVM article = GetProductForTest();        
        String page = GDB_TestDataFactory.getLoginURL(article);                       
        System.runAs(guestUser) {
            String destinationToGo = GDB_ProductUtils.addToCart(article);                                    
            System.assertNotEquals(null, destinationToGo, 'Return value should not be null');
            System.assertEquals(page, destinationToGo, 'Return value should be login page');
        }
    }

    @isTest
    static void testIsUniquePriceOnWarehousesAsGuestUser() {
        guestUser = GDB_TestDataFactory.getGuestUser();
        GDB_ArticleVM article = GetProductForTest();
        System.runAs(guestUser) {
            Boolean isUniquePrice = GDB_ProductUtils.isUniquePriceOnWarehouses(article.Id);
            System.assertEquals(true, isUniquePrice, 'Return value should be true');
        }
    }

    @isTest
    static void testIsNotUniquePriceOnWarehousesWithBadItemIdAsGuestUser() {
        guestUser = GDB_TestDataFactory.getGuestUser();
        System.runAs(guestUser) {
            Boolean isUniquePrice = GDB_ProductUtils.isUniquePriceOnWarehouses('1');
            System.assertEquals(false, isUniquePrice, 'Return value should be false');
        }
    }

    // Tests as admin user
    @isTest
    static void testGetAllProductsAsAdminUser() {
        adminUser = GDB_TestDataFactory.getAdminUser();
        System.runAs(adminUser) {
            List<GDB_ArticleVM> gdb_whp = GDB_ProductUtils.getProducts('');
            System.assertNotEquals(0, gdb_whp.size(), 'Return size value should be greater than 0');
        }
    }

    @isTest
    static void testAddToCartAsAdminUserWithoutBasket() {
        adminUser = GDB_TestDataFactory.getAdminUser();
        GDB_ArticleVM article = GetProductForTest();
        String page = GDB_TestDataFactory.getLoginURL(article);
        System.runAs(adminUser) {
            String destinationToGo = GDB_ProductUtils.addToCart(article);
            System.assertEquals(page, destinationToGo, 'Return value should be login page');
        }
    }

    @isTest
    static void testAddToCartAsAdminUserWithEmptyBasket() {
        adminUser = GDB_TestDataFactory.getAdminUser();
        GDB_TestDataFactory.createBasket(null);
        GDB_ArticleVM article = GetProductForTest();
        String page = GDB_TestDataFactory.getLoginURL(article);
        System.runAs(adminUser) {
            String destinationToGo = GDB_ProductUtils.addToCart(article);
            System.assertEquals(page, destinationToGo, 'Return value should be login page');
        }
    }

    // Tests as community user
    @isTest
    static void testGetAllProductsAsCommunityUser() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            List<GDB_ArticleVM> gdb_whp = GDB_ProductUtils.getProducts('');
            System.assertNotEquals(0, gdb_whp.size(), 'Return size value should be greater than 0');
        }
    }

    @isTest
    static void testGetOneProductAsCommunityUser() {
        Item__c item = [SELECT Id, gdb_page_url__c FROM Item__c WHERE Name = 'article_1'LIMIT 1];
        User u = GDB_TestDataFactory.getCommunityUserByProfile();
        System.runAs(u) {
            List<GDB_ArticleVM> gdb_whp = GDB_ProductUtils.getProducts(item.Id);
            System.assertNotEquals(0, gdb_whp.size(), 'Return size value should be greater than 0');
        }
    }

    @isTest
    static void testAddToCartAsCommunityUser() {
        User u = GDB_TestDataFactory.createCommunityUser(null);             
        System.runAs(u) {   
            String page = GDB_Constants.checkoutStepURLs.get(1);
            GDB_ArticleVM article = GDB_ProductUtils.getProducts('').get(0);
            String destinationToGo = GDB_ProductUtils.addToCart(article);

            System.assertEquals(page, destinationToGo, 'Return value should be article page');
            
            GDB_Basket__c b = GDB_BasketMgr.getCurrentBasket(false);
            for (GDB_Basket_Product__c bp : b.Basket_Products__r) {
                GDB_BasketMgr.updateLineItemQuantity(bp.Id, 10);
            }
            
            destinationToGo = GDB_ProductUtils.addToCart(article);
            System.assertEquals(page, destinationToGo, 'Return value should be article page');
        }
    }
    
    @isTest
    static GDB_ArticleVM GetProductForTest() {
        List<GDB_ArticleVM> products = GDB_ProductUtils.getProducts('');
        
        if(products.size() > 0)
        {
            return products[0];
        }
        else
        {
            system.debug('Return value should be the first article');
            return null;
        }
    }

    @isTest
    static void testAddToCartExistingArticleAsCommunityUser() {
        String page = GDB_Constants.checkoutStepURLs.get(1);

        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u) {
            GDB_Basket__c b = GDB_BasketMgr.createBasket();
            GDB_TestDataFactory.createBasketProduct(b);
            b = GDB_BasketMgr.getBasketById(b.Id);
            GDB_BasketMgr.getBasketLineItemQuantities();

            for (GDB_Basket_Product__c bp : b.Basket_Products__r) {
                GDB_BasketMgr.updateLineItemQuantity(bp.Id, 10);
            }
            
            GDB_ArticleVM article = GetProductForTest();
            String destinationToGo = GDB_ProductUtils.addToCart(article);
            destinationToGo = GDB_ProductUtils.addToCart(article);
            
            System.assertEquals(page, destinationToGo, 'Return value should be article page');
        }
    }   
        
    @isTest
    static void testAddToCartB2B(){
        User u = GDB_TestDataFactory.createCommunityUser();
        System.runAs(u) {
            GDB_Basket__c b = GDB_BasketMgr.createBasket();
                       
            GDB_TestDataFactory.createBasketProduct(b);
            b = GDB_BasketMgr.getBasketById(b.Id);
                        	                    
	        String destinationToGo = GDB_ProductUtils.addToCartB2B(null);
	        	        
	        List<GDB_ProduitQuantity_B2B> products = GDB_ProductUtils.getProductsB2B();
	          
	        destinationToGo = GDB_ProductUtils.addToCartB2B(products);
	        
	        //Update basket
	        destinationToGo = GDB_ProductUtils.addToCartB2B(products);
        }
    } 
    
    @isTest
    static void testAddToCartB2BNotEmpty(){ 
        String page = GDB_Constants_B2B.checkoutStepURLsB2B.get(1);        
        User u = GDB_TestDataFactory.createCommunityUser();             
        
        System.runAs(u) {
            GDB_Basket__c b = new GDB_Basket__c();           
            GDB_TestDataFactory.createBasketProduct(b);            
            
            b = GDB_BasketMgr.getBasketById(b.Id);
                        
            List<GDB_ProduitQuantity_B2B> prds = GDB_ProductUtils.getProductsB2B();
                                                
            GDB_ProductUtils.addToCartB2B(prds);
            String destinationToGo = GDB_ProductUtils.addToCartB2B(prds);            
        }
    }
    
    @isTest
    static void testAddToCartB2BWithBasketEmpty(){
        String page = GDB_Constants_B2B.checkoutStepURLsB2B.get(1);        
        User u = GDB_TestDataFactory.createCommunityUser();        
        List<GDB_ProduitQuantity_B2B> prds = GDB_ProductUtils.getProductsB2B();             
        
        System.runAs(u) {
            GDB_Basket__c b = GDB_BasketMgr.createBasket();
            
            String destinationToGo = GDB_ProductUtils.addToCartB2B(prds);            
        }
    } 
    
    @isTest
    static void testAddToCartB2BWitkBasketNull(){        
        String page = GDB_Utils_B2B.getUrlWithPathPrefix(''); 
        User u = GDB_TestDataFactory.createCommunityUser();  
                   
        List<GDB_ProduitQuantity_B2B> prds = GDB_ProductUtils.getProductsB2B();
        
        System.runAs(u) {
            String destinationToGo = GDB_ProductUtils.addToCartB2B(prds);            
        }
    } 
    
    @isTest
    static void testAddToCartB2BNotAuthenticated(){        
        String page = GDB_Utils_B2B.getUrlWithPathPrefix('');
        
        List<GDB_ProduitQuantity_B2B> prds = GDB_ProductUtils.getProductsB2B();
        
        String destinationToGo = GDB_ProductUtils.addToCartB2B(prds);
        System.assertEquals(page, destinationToGo, 'Return value should be article page');
    }
    
    @isTest
    static void testGetProductAvailable() {
        User u = GDB_TestDataFactory.getCommunityUserByProfile();             
        System.runAs(u) {
            GDB_ProductUtils.getProductsAvailable('',GDB_Constants.articleNameDisplay.get(2));
        }
    }
    
    @isTest
    static void testGetProductsWithZipCodeAndClientType(){
        User u = GDB_TestDataFactory.getCommunityUserByProfile();             
        System.runAs(u) {
            GDB_ProductUtils.getProductsWithZipCodeAndClientType('test','71000',true);
            GDB_ProductUtils.getProductsWithZipCodeAndClientType('test','71000',false);
            GDB_ProductUtils.getProductsWithZipCodeAndClientType('','71000',true);
            GDB_ProductUtils.getProductsWithZipCodeAndClientType('','71000',false);
        }
    }

    @isTest
    static void testGetProductLowerPrice() {
        Item__c item = [SELECT Id FROM Item__c LIMIT 1];
        System.assertNotEquals(0, GDB_ProductUtils.getProductLowerPrice(item.Id));
        System.assertEquals(null, GDB_ProductUtils.getProductLowerPrice(null));
    }

    @isTest
    static void testGetProductPrice() {   
        Item__c item = [SELECT Id FROM Item__c LIMIT 1].get(0);
        Map<String, Object> result = GDB_ProductUtils.getProductPrice(item.Id, null);
        System.assertEquals(null, result);
        
        result = GDB_ProductUtils.getProductPrice(item.Id, new Map<String, String>{'zipcode' => '71000'});
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetMedia(){
        Item__c item = [SELECT Id FROM Item__c LIMIT 1].get(0);
        GDB_TestDataFactory.createMedia(item.Id); 
        List<GDB_article_media__c> result = GDB_ProductUtils.getMediaByArticleId(item.Id);

        System.assertNotEquals(null, result);
    }
}