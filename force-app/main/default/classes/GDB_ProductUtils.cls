public without sharing class GDB_ProductUtils {
    /**
     * getProductId Get record id WHERE ean passed in parameter.
     *
     * @param {String} article ean or empty
     * @return {String} product id or empty 
     */
    public static String getProductId(String productEan) {
        List <Item__c> items = new List <Item__c>(); 
        String recordId = '';
        Id articleRecordId = GDB_Constants.articleTypeId;

        if (String.isNotBlank(productEan)) {
            items = [SELECT
                name
                FROM Item__c
                WHERE Code_Article__c =: productEan
                AND RecordTypeId =: articleRecordId
                ORDER BY name ASC
                LIMIT 1
            ];
            if(items.size() > 0){
                recordId = String.valueOf(items.get(0).Id);
            }
        }
        return recordId;
    }

    /**
     * getProducts Get all articles or an article WHERE id passed in parameter.
     *
     * @param {String} article id or empty 
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProducts(String recordId) {
       return getProductsWithZipCode(recordId, '');
    }

    /**
     * getProducts Get all articles or an article WHERE id passed in parameter and order by sort field.
     *
     * @param {String} article id or empty 
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProducts(String recordId, String sortFieldname, String sortWay) {
       return getProductsWithZipCode(recordId, '', sortFieldname, sortWay);
    }
    
     /**
     * getProductsAvailable Get all articles or an article WHERE id passed in parameter and available for this display.
     *
     * @param {String} article id or empty
     * @param {String} name of the display 
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProductsAvailable(String recordId, String nameDisplay) {
       return getProductsAvailable(recordId, nameDisplay, null, null);
    }
    
     /**
     * getProductsAvailable Get all articles or an article WHERE id passed in parameter, available for this display and order by sort field.
     *
     * @param {String} article id or empty
     * @param {String} name of the display 
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProductsAvailable(String recordId, String nameDisplay, String sortFieldname, String sortWay) {
       List<GDB_ArticleVM> allProducts = getProducts(recordId, sortFieldname, sortWay);
       List<GDB_ArticleVM> productsAvailable = new List<GDB_ArticleVM>();
       
       for(GDB_ArticleVM product : allProducts){
           if(product.isDisplayedOn(nameDisplay)){
               productsAvailable.add(product);
           }
       }       
       
       return productsAvailable;
    }
    
     /**
     * getProductsB2B Get all articles B2B.
     * @return {GDB_ProduitQuantity_B2B[]} List of articles + Quantity
     */
    public static List <GDB_ProduitQuantity_B2B> getProductsB2B() {
        List <Item__c> items = new List <Item__c>();
        List <GDB_ProduitQuantity_B2B> ProduitQuantity = new List <GDB_ProduitQuantity_B2B>();
        
        Id articleRecordId = GDB_Constants.articleTypeId;
        
        //Check is authenticated
        if (GDB_AccountMgr.isAuthenticated()) {
            Account currentUserAccount = GDB_AccountMgr.getCurrentCustomer();
            
            if (currentUserAccount != null) {
                
                String postalCodeUser = currentUserAccount.Postal_Code__c;
                if(!String.isBlank(postalCodeUser)){
                    postalCodeUser = postalCodeUser.substring(0, 2);
                }
                    
                items = [SELECT
                        name,
                        gdb_isSample__c,
                        Code_Article__c,
                        gdb_delivery_description__c,
                        gdb_technical_characteristics__c,
                        gdb_seo_title__c,
                        gdb_seo_description__c,
                        gdb_seo_keywords__c,
                        gdb_image_url__c,
                        gdb_seo_url__c,
                        gdb_page_url__c,
                        gdb_canBeSoldOnB2B__c,
                        gdb_content_B2B__c,
                        gdb_promotion_text__c,
                        gdb_quantity_buyable__c,
                        (SELECT gdb_Article__c, gdb_price__c, gdb_quantity__c, gdb_Warehouse__r.gdb_codes__c
                     FROM Warehouse_Article_Junction__r
                     WHERE gdb_Warehouse__r.gdb_codes__c INCLUDES(: postalCodeUser))                        
                    FROM Item__c
                    WHERE RecordTypeId =: articleRecordId
                    AND gdb_canBeSoldOnB2B__c = true
                    AND gdb_online__c = true
                    ORDER BY name ASC
                ];
            }    
        }
        
        GDB_Basket__c basketCurrent = GDB_BasketMgr.getCurrentBasket(false);
        
        for (Item__c item_current: items) {
           GDB_ProduitQuantity_B2B pq = new GDB_ProduitQuantity_B2B();
           pq.Item = new Item__c(
                                Id = item_current.Id,
                                Name =item_current.Name,
                                Code_Article__c = item_current.Code_Article__c,
                                gdb_content_B2B__c = item_current.gdb_content_B2B__c
                                );
           
           
           // Mise a jour des Quantity en fonction du panier courant                                
           pq.Quantity = 0;
           if(basketCurrent != null && basketCurrent.Basket_Products__r.size() > 0){               
                for(GDB_Basket_Product__c lineItem : basketCurrent.Basket_Products__r) {
                    if(lineItem.gdb_Article__c == pq.Item.Id) {
                        pq.Quantity = Integer.valueOf(lineItem.gdb_quantity__c);
                        break;
                    }
                }               
           }                                
                            
           pq.ImageUrl = item_current.gdb_image_url__c;
            
           ProduitQuantity.add(pq); 
        }
        
        return ProduitQuantity; 
    }

     /**
     * getProductsWithZipCode Get all articles except B2B.
     *   
     * @param {String} article id or empty 
     * @param {String} zipCode customer current   
     * @return {List<GDB_ArticleVM>} List of articles not B2B
     */
    public static List<GDB_ArticleVM> getProductsWithZipCode(String recordId, String zipCode) {
        return getProductsWithZipCode(recordId, zipCode, null, null);
    } 

     /**
     * getProductsWithZipCode Get all articles order by sort field, except B2B
     *   
     * @param {String} article id or empty 
     * @param {String} zipCode customer current  
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles not B2B
     */
    public static List<GDB_ArticleVM> getProductsWithZipCode(String recordId, String zipCode, String sortFieldname, String sortWay) {
        return getProductsWithZipCodeAndClientType(recordId, zipCode, false, sortFieldname, sortWay);
    } 
    
     /**
     * getProductsWithZipCode Get all articles based on Client Typa ( B2B or B2C).
     *     
     * @param {String} article id or empty
     * @param {String} zipCode customer current
     * @param {Boolean} isB2B 
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProductsWithZipCodeAndClientType(String recordId, String zipCode, boolean isB2B) {
        return getProductsWithZipCodeAndClientType(recordId, zipCode, isB2B, null, null);
    }

     /**
     * getProductsWithZipCode Get all articles based on Client Typa ( B2B or B2C) order by sort field.
     *     
     * @param {String} article id or empty
     * @param {String} zipCode customer current
     * @param {Boolean} isB2B 
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles
     */
    public static List<GDB_ArticleVM> getProductsWithZipCodeAndClientType(String recordId, String zipCode, boolean isB2B, String sortFieldname, String sortWay) {
        List<GDB_ArticleVM> items = new List <GDB_ArticleVM>();
        String postalCodeUser = '';
        
        if(String.isBlank(sortFieldname)) {
            sortFieldname = 'gdb_warehouseproduct__r.gdb_article__r.name';
        }
        if(String.isBlank(sortWay)) {
            sortWay = 'ASC';
        }

        //Check is authenticated
        if (GDB_AccountMgr.isAuthenticated() || String.isNotBlank(zipCode)) {
            //Get Postalcode User
            Account currentUserAccount = GDB_AccountMgr.getCurrentCustomer();
            if (currentUserAccount == null && String.isBlank(zipCode)) {
                items = getProductsAsGuestUser(recordId, sortFieldname, sortWay);
            } else {
                if(zipCode != ''){
                    postalCodeUser = zipCode.substring(0, 2);
                }else{
                    postalCodeUser = currentUserAccount.gdb_shipping_zip__c.substring(0, 2);
                }
                
                List<String> whereClause = new List<String>{
                    'gdb_warehouseproduct__r.gdb_article__r.RecordTypeId = :articleRecordId',
                    'gdb_department__c = :postalCodeUser'
                };
                
                String queryLimit = '';
                if (String.isNotBlank(recordId)) {
                    whereClause.add('gdb_warehouseproduct__r.gdb_article__c = :recordId');
                    queryLimit = '1';
                } else {
                    whereClause.add('gdb_warehouseproduct__r.gdb_article__r.gdb_online__c = true');
                }
                
                if(isB2B){
                    whereClause.add('gdb_warehouseproduct__r.gdb_article__r.gdb_canBeSoldOnB2B__c = true');
                } else {
                    whereClause.add('gdb_warehouseproduct__r.gdb_article__r.gdb_canBeSoldOnB2C__c = true');
                }
                
                Map<String, List<String>> mapFields = new Map<String, List<String>>{
                    '' => new List<String> {
                        'gdb_price__c',
                        'gdb_tax__c',
                        'gdb_unit_price_warehouse__c',
                        'gdb_unit_tax_warehouse__c',
                        'gdb_technical_characteristics__c' 
                    },
                    'gdb_warehouseproduct__r' => new List<String>{
                        'gdb_Article__c',
                        'gdb_quantity__c',
                        'gdb_quantitywarehouse__c',
                        'gdb_Warehouse__c',
                        'gdb_sku__c'
                    },
                    'gdb_warehouseproduct__r.gdb_article__r' => new List<String>{
                        'Id',
                        'Name',
                        'gdb_isSample__c',
                        'Code_Article__c',
                        'gdb_delivery_description__c',
                        'gdb_seo_title__c',
                        'gdb_seo_description__c',
                        'gdb_seo_keywords__c',
                        'gdb_image_url__c',
                        'gdb_seo_url__c',
                        'gdb_display_badge__c',
                        'gdb_page_url__c',
                        'gdb_canBeSoldOnB2B__c',
                        'gdb_canBeSoldOnB2C__c',
                        'gdb_LocationDisplay__c',
                        'gdb_sort__c',
                        'gdb_bv_external_id__c',
                        'gdb_badge_color_red__c',
                        'gdb_badge_color_green__c',
                        'gdb_badge_color_blue__c',
                        'gdb_badge_text__c',
                        'gdb_online__c',
                        'gdb_purchasable__c',
                        'gdb_promotion_text__c',
                        'gdb_technical_characteristics__c',
                        'gdb_quantity_buyable__c',
                        'gdb_menu_sort__c',
                        'GDB_Display_ShippingCosts_Message__c'
                    }
                };

                return getArticleVMs(
                    mapFields, 
                    whereClause, 
                    sortFieldname + ' ' + sortWay, 
                    queryLimit, 
                    recordId, 
                    postalCodeUser
                );
            }
            
        } else {
            if(!isB2B){                
                items = getProductsAsGuestUser(recordId, sortFieldname, sortWay);
            }
        }
        return items;
    } 


    /**
    * addToCart Add article to the cart and return addToCart.
     * @param {GDB_ArticleVM} article
     * @return {Methode} addToCart
     */
     public static String addToCart(GDB_ArticleVM article) {
         return addToCart(article, 1);
     }


    /**
     * addToCart Add article to the cart and return the URL destination page.
     * @param {GDB_ArticleVM} article
     * @param {Integer} wantedQuantity
     * @return {String} The URL destination page
     */
    public static String addToCart(GDB_ArticleVM article, Integer wantedQuantity) 
    {
        //Get basket in session via GDB_BasketMgr
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(true);

        if (basket == null) {
            // Go to login
            String param = GDB_Utils.getCommunityUrlPathPrefix(GDB_Constants.communityName) + article.pageUrl;
            String page = GDB_Utils.getLoginPageWithParam(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(1), param);
            return page;
        }

        //Check if basket_product contains article
        List < GDB_Basket_Product__c > lst_basket_product = [SELECT gdb_quantity__c, gdb_description__c, Name,
            gdb_Article__c, gdb_Basket__c
            FROM GDB_Basket_Product__c
            WHERE gdb_product_code__c =: article.code
            AND gdb_basket__c =: basket.Id
        ];
        
        GDB_Basket_Product__c basket_product;
        String sampleCode = GDB_Constants.articleCode.get(1);
        article = getWarehouseArticleForCurrentUser(article.Id);
        
        if(article != null) 
        {
            if (lst_basket_product.isEmpty()) {
                basket_product = new GDB_Basket_Product__c(
                    gdb_quantity__c = 0,
                    gdb_description__c = article.description,
                    gdb_product_code__c = article.code,
                    gdb_Article__c = article.Id,
                    gdb_Basket__c = basket.Id,
                    gdb_sku__c = article.sku,
                    gdb_unit_price__c = article.unit_price,
                    gdb_unit_tax__c = article.unit_tax,
                    Name = article.Name,
                    gdb_warehouse__c = article.getWarehouseId(),
                    gdb_quantitywarehousecoefficient__c = article.getWarehouseQuantity(),
                    gdb_unit_price_warehouse__c =  (article.unit_price == null || 
                                                    article.unit_price == 0) ? 
                                                    article.price : 
                                                    article.unit_price,
                    gdb_unit_tax_warehouse__c = (article.unit_tax == null || 
                                                article.unit_tax == 0) ? 
                                                article.tax : 
                                                article.unit_tax
                );
            } 
            else if( sampleCode != article.code )
            {
                basket_product = lst_basket_product.get(0);
            }

            if( basket_product != null ) 
            {
                basket_product.gdb_quantity__c += wantedQuantity;
                basket_product.gdb_total_price__c = article.price * basket_product.gdb_quantity__c;
                basket_product.gdb_total_tax__c = article.tax * basket_product.gdb_quantity__c;

                upsert basket_product;
            }

            GDB_BasketMgr.recalculateBasket(basket);
        }
        
        return GDB_Constants.checkoutStepURLs.get(1);
    }
    
    /**
     * addToCartB2B Add articles to the cart and return the URL destination page for B2B.
     *
     * @param List < GDB_ProduitQuantity_B2B> articles
     * @return {String} The URL destination page
     */
    public static String addToCartB2B(List<GDB_ProduitQuantity_B2B> ProduitsQuantities) {         
        if (GDB_AccountMgr.isAuthenticated()) {            
            //Get basket in session via GDB_BasketMgr
            GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(true); 

            if (basket == null) {
                // Go to home               
                String page = GDB_Utils_B2B.getUrlWithPathPrefix('');
                return page;
            }
 
            try{
                
                // Configuration du basket en B2B
                basket.gdb_isB2B__c = true;
                update basket;
                
                //Check if basket_product contains article
                List < GDB_Basket_Product__c > lst_basket_product = [SELECT gdb_quantity__c, gdb_description__c, Name,
                    gdb_Article__c, gdb_Basket__c
                    FROM GDB_Basket_Product__c
                    WHERE gdb_basket__c =: basket.Id
                ];            
                
                if (lst_basket_product.isEmpty()) {
                        
                    for(GDB_ProduitQuantity_B2B articleQuantity : ProduitsQuantities){                                          
                                            
                        GDB_ArticleVM article = getWarehouseArticleForCurrentUser(articleQuantity.Item.Id);
                                        
                        if(article != null && articleQuantity.Quantity > 0) {
                            GDB_Basket_Product__c basket_product = new GDB_Basket_Product__c();
                            basket_product.gdb_description__c = articleQuantity.Item.gdb_delivery_description__c;
                            basket_product.gdb_product_code__c = articleQuantity.Item.Code_Article__c;
                            basket_product.gdb_Article__c = articleQuantity.Item.Id;
                            basket_product.gdb_Basket__c = basket.Id;
                            basket_product.gdb_quantity__c = articleQuantity.Quantity;
                            basket_product.gdb_sku__c = article.sku;
                            basket_product.gdb_unit_price__c = 0;
                            basket_product.gdb_unit_tax__c = 0;
                            basket_product.gdb_total_price__c = 0;
                            basket_product.gdb_total_tax__c = 0;
                            basket_product.Name = articleQuantity.Item.Name;
                            basket_product.gdb_warehouse__c = article.getWarehouseId();
                            basket_product.gdb_quantitywarehousecoefficient__c = article.getWarehouseQuantity();
                            lst_basket_product.add(basket_product);                        
                        }
                    }
                } 
                else {
                    for(GDB_Basket_Product__c basket_product_current : lst_basket_product ){
                        
                        for(GDB_ProduitQuantity_B2B articleQuantity : ProduitsQuantities ){
                            
                            if(articleQuantity.Item.Id == basket_product_current.gdb_Article__c && articleQuantity.Quantity > 0){                            
                                basket_product_current.gdb_quantity__c = articleQuantity.Quantity;
                                ProduitsQuantities.remove(ProduitsQuantities.indexOf(articleQuantity));
                                break;
                            }                        
                        }
                    }
                        
                    for(GDB_ProduitQuantity_B2B articleQuantity : ProduitsQuantities){ 
                    
                        GDB_ArticleVM article = getWarehouseArticleForCurrentUser(articleQuantity.Item.Id);
                                
                        if(article != null && articleQuantity.Quantity > 0) {
                            GDB_Basket_Product__c basket_product = new GDB_Basket_Product__c();
                            basket_product.gdb_description__c = articleQuantity.Item.gdb_delivery_description__c;
                            basket_product.gdb_product_code__c = articleQuantity.Item.Code_Article__c;
                            basket_product.gdb_Article__c = articleQuantity.Item.Id;
                            basket_product.gdb_Basket__c = basket.Id;
                            basket_product.gdb_quantity__c = articleQuantity.Quantity;
                            basket_product.gdb_sku__c = article.sku;
                            basket_product.gdb_unit_price__c = 0;
                            basket_product.gdb_unit_tax__c = 0;
                            basket_product.gdb_total_price__c = 0;
                            basket_product.gdb_total_tax__c = 0;
                            basket_product.Name = articleQuantity.Item.Name;
                            basket_product.gdb_warehouse__c = article.getWarehouseId();
                            basket_product.gdb_quantitywarehousecoefficient__c = article.getWarehouseQuantity();
                            lst_basket_product.add(basket_product);
                        }
                    }
                }
    
                upsert lst_basket_product;
                
                // Go to basket step 2 ( adresse )
                return GDB_Constants_B2B.checkoutStepURLsB2B.get(1);
            }
            catch(exception e){                
                GDB_ErrorMgr.createError('GDB_ProductUtils', 'addToCartB2B', e.getStackTraceString());
                
                String page = GDB_Utils_B2B.getUrlWithPathPrefix('');
                return page;
            }
            
        } else {
            // Go to login
            String page = GDB_Utils_B2B.getCommunityUrlPathPrefix(false) + GDB_Constants_B2B.pagesURLsB2B.get(4);
            return page;
        }
    }


    /**
     *
     * getProducts Get all articles or an article WHERE id passed in parameter for guest user order by sort field.
     *
     * @param {String} article id or empty
     * @param {String} sort field name
     * @param {String} sort way (ASC / DESC)
     * @return {List<GDB_ArticleVM>} List of articles
     */
    private static List<GDB_ArticleVM> getProductsAsGuestUser(String recordId, String sortFieldname, String sortWay) {
        List<String> whereClause = new List<String>{
            'gdb_warehouseproduct__r.gdb_article__r.RecordTypeId = :articleRecordId',
            'gdb_warehouseproduct__r.gdb_article__r.gdb_canBeSoldOnB2C__c = true',
            'gdb_warehouseproduct__r.gdb_quantity__c > 0'
        };
        
        String queryLimit = '';
        if (String.isNotBlank(recordId)) {
            whereClause.add('gdb_warehouseproduct__r.gdb_article__c = :recordId');
            queryLimit = '1';
        } else {
            whereClause.add('gdb_warehouseproduct__r.gdb_article__r.gdb_online__c = true');
        }
        
        Map<String, List<String>> mapFields = new Map<String, List<String>>{
            '' => new List<String> {
                'gdb_price__c',
                'gdb_tax__c',
                'gdb_unit_price_warehouse__c',
                'gdb_unit_tax_warehouse__c',
                'gdb_technical_characteristics__c'
            },
            'gdb_warehouseproduct__r' => new List<String>{
                'gdb_Article__c',
                'gdb_quantity__c',
                'gdb_quantitywarehouse__c',
                'gdb_Warehouse__c',
                'gdb_sku__c'
            },
            'gdb_warehouseproduct__r.gdb_article__r' => new List<String>{
                'Id',
                'Name',
                'gdb_isSample__c',
                'Code_Article__c',
                'gdb_delivery_description__c',
                'gdb_seo_title__c',
                'gdb_seo_description__c',
                'gdb_seo_keywords__c',
                'gdb_image_url__c',
                'gdb_seo_url__c',
                'gdb_display_badge__c',
                'gdb_page_url__c',
                'gdb_canBeSoldOnB2B__c',
                'gdb_canBeSoldOnB2C__c',
                'gdb_LocationDisplay__c',
                'gdb_sort__c',
                'gdb_bv_external_id__c',
                'gdb_badge_color_red__c',
                'gdb_badge_color_green__c',
                'gdb_badge_color_blue__c',
                'gdb_badge_text__c',
                'gdb_online__c',
                'gdb_purchasable__c',
                'gdb_promotion_text__c',
                'gdb_technical_characteristics__c',
                'gdb_quantity_buyable__c',
                'gdb_menu_sort__c',
                'GDB_Display_ShippingCosts_Message__c'
            }
        };
        
        List<GDB_ArticleVM> items = getArticleVMs(
            mapFields, 
            whereClause, 
            sortFieldname + ' ' + sortWay, 
            queryLimit, 
            recordId, 
            null
        );
        
        GDB_ArticleVM item_reference = null;
        Map < String, GDB_ArticleVM > mapFinal = new Map < String, GDB_ArticleVM > ();
        List < GDB_ArticleVM > returned_item = new List < GDB_ArticleVM > ();

        //Get minus price for each article
        for (GDB_ArticleVM item_current: items) {
            if (item_reference == null) {
                item_reference = item_current;
                mapFinal.put(item_current.Id, item_current);
            } else {
                if (item_reference.Id.equals(item_current.Id)) {
                    if (item_reference.getPrice() > item_current.getPrice()) {
                        item_reference = item_current;
                        mapFinal.put(item_current.Id, item_current);
                    }
                } else {
                    item_reference = item_current;
                    mapFinal.put(item_current.Id, item_current);
                }
            }
        }
        return mapFinal.values();
    }

    /**
     * getWarehouseArticle description
     * @param  recordId recordId description
     * @return {GDB_ArticleVM}
     */
    public static GDB_ArticleVM getWarehouseArticleForCurrentUser(String recordId) {
        Account currentUserAccount = GDB_AccountMgr.getCurrentCustomer();
        Map<String, String> currentGuest = GDB_AccountMgr.getCurrentGuest();
        if (currentUserAccount != null || currentGuest != null) 
        {
            String postalCodeUser;
            if(currentUserAccount != null) {
                postalCodeUser = currentUserAccount.gdb_shipping_zip__c;
                if(String.isBlank(postalCodeUser)){
                    postalCodeUser = currentUserAccount.Postal_Code__c;
                }
                if(String.isBlank(postalCodeUser)){
                    postalCodeUser = currentUserAccount.City_Postal_Code__r.Postal_Code__c;
                }
            } else {
                postalCodeUser = currentGuest.get('zipcode');
            }

            postalCodeUser = postalCodeUser != null ? postalCodeUser.substring(0,2) : null;
            
            Map<String, List<String>> mapFields = new Map<String, List<String>>{
                '' => new List<String> {
                    'gdb_price__c',
                    'gdb_tax__c',
                    'gdb_unit_price_warehouse__c',
                    'gdb_unit_tax_warehouse__c',
                    'gdb_technical_characteristics__c'
                },
                'gdb_warehouseproduct__r' => new List<String>{
                    'gdb_Article__c',
                    'gdb_quantity__c',
                    'gdb_quantitywarehouse__c',
                    'gdb_Warehouse__c',
                    'gdb_sku__c'
                },
                'gdb_warehouseproduct__r.gdb_article__r' => new List<String>{
                    'Id',
                    'Name',
                    'gdb_isSample__c',
                    'Code_Article__c',
                    'gdb_delivery_description__c',
                    'gdb_seo_title__c',
                    'gdb_seo_description__c',
                    'gdb_seo_keywords__c',
                    'gdb_image_url__c',
                    'gdb_seo_url__c',
                    'gdb_display_badge__c',
                    'gdb_page_url__c',
                    'gdb_canBeSoldOnB2B__c',
                    'gdb_canBeSoldOnB2C__c',
                    'gdb_LocationDisplay__c',
                    'gdb_sort__c',
                    'gdb_bv_external_id__c',
                    'gdb_badge_color_red__c',
                    'gdb_badge_color_green__c',
                    'gdb_badge_color_blue__c',
                    'gdb_badge_text__c',
                    'gdb_online__c',
                    'gdb_purchasable__c',
                    'gdb_promotion_text__c',
                    'gdb_technical_characteristics__c',
                    'gdb_quantity_buyable__c',
                    'gdb_menu_sort__c',
                    'GDB_Display_ShippingCosts_Message__c'
                }
            };
            
            List<String> whereClause = new List<String>{
                'gdb_warehouseproduct__r.gdb_article__c = :recordId',
                'gdb_warehouseproduct__r.gdb_article__r.gdb_online__c = true',
                'gdb_warehouseproduct__r.gdb_article__r.RecordTypeId = :articleRecordId',
                'gdb_department__c = :postalCodeUser'
            };
            
            List<GDB_ArticleVM> items = getArticleVMs(
                mapFields, 
                whereClause, 
                'gdb_warehouseproduct__r.gdb_article__r.Name ASC, gdb_price__c ASC', 
                null, 
                recordId, 
                postalCodeUser
            );
            
            if(items != null && items.size() > 0) {
                return items.get(0);
            }
        }
        
        return null;
    }
    
    /**
     * getArticleVMs build soql query with data passed by params and return a list of GDB_ArticleVMs
     * @param  {Map<String, List<String>>} mapFields
     * @param  {List<String>} whereClause
     * @param  {String} orderBy
     * @param  {String} queryLimit
     * @param  {String} recordId
     * @param  {String} postalCodeUser
     * @return {List<GDB_ArticleVM>}
     */
    public static List<GDB_ArticleVM> getArticleVMs (Map<String, List<String>> mapFields, List<String> whereClause, String orderBy,  String queryLimit, String recordId, String postalCodeUser) {
        
        if(mapFields == null || mapFields.size() <= 0 || whereClause == null) {
            return null;
        }
        
        List<String> queryFields = new List<String>();
        for(String key : mapFields.keySet()) {
            String prefix = String.isNotBlank(key) ? key + '.' : '';
            for(String field : mapFields.get(key)) {
                queryFields.add(prefix + field);
            }
        }
        
        String query = 'SELECT ' + String.join(queryFields, ',') + ' '
            + ' FROM GDB_Department_Has_WarehouseProd__c '
            + ' WHERE ' + String.join(whereClause, ' AND ') + ' '
            + ' ORDER BY ' + orderBy + ' ';
            
        if(String.isNotBlank(queryLimit)) {
            query += 'LIMIT ' + queryLimit;
        }
        
        Id articleRecordId = GDB_Constants.articleTypeId;
        List<GDB_ArticleVM> items = new List <GDB_ArticleVM>();
        List<GDB_Department_Has_WarehouseProd__c> results = Database.query(query);
        for(GDB_Department_Has_WarehouseProd__c dhw : results) {
            items.add(new GDB_ArticleVM(dhw));
        }

        return items;
    }
    
    /**
     * getWarehouseArticle description
     * @param  recordId recordId description
     * @return {GDB_ArticleVM}
     */
    public static GDB_ArticleVM getWarehouseArticleWithZipCode(String recordId, String postalCodeUser) {
        postalCodeUser = postalCodeUser.substring(0, 2);
        List<GDB_ArticleVM> items = getProductsWithZipCodeAndClientType(recordId, postalCodeUser,false,'gdb_warehouseproduct__r.gdb_article__r.name ASC, gdb_price__c', 'ASC');
        
        return items != null  && !items.isEmpty() ? items.get(0) : null;
    }

    /**
     * isUniquePriceOnWarehouses Returns true if it's unique price on each warehouses, else false
     * @param  recordId article id
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isUniquePriceOnWarehouses(String recordId) {
        List <AggregateResult> agResults = [SELECT gdb_Article__r.Id, COUNT_DISTINCT(gdb_price__c)nbPrice
            FROM GDB_Warehouse_Has_Product__c
            WHERE gdb_Article__r.RecordType.Name = 'ECommerce Article'
            AND gdb_Article__r.Id = :recordId
            AND gdb_Article__r.gdb_online__c = true
            group by gdb_Article__r.id
        ];

        if(!agResults.isEmpty()) {
            AggregateResult agResult = agResults.get(0);
            return agResult.get('nbPrice') == 1 ? true : false;
        }

        return false;
    }

    /**
     * Get the item lower price in database
     * @param {String} prodId 
     * @return {Decimal} 
     */
    public static Decimal getProductLowerPrice(String prodId) {
        if(prodId != null)
        { 
            List<AggregateResult> results = [
                SELECT MIN(gdb_price__c)price
                FROM GDB_Department_Has_WarehouseProd__c 
                WHERE gdb_warehouseproduct__r.gdb_Article__c = :prodId
            ];

            if(results.size() > 0) {
                return Decimal.valueOf(String.valueOf(results.get(0).get('price')));
            }
        }

        return null;
    }

    /**
     * getProductPrice Return product price to zipcode
     * @param {String} recordId
     * @param {Map<String, Object>} guest
     * @return {Map<String, Object>}
     */
    @AuraEnabled
    public static Map<String, Object> getProductPrice(String recordId, Map<String, Object> guest) {
        if(guest != null && guest.containsKey('zipcode') 
        && Pattern.matches('[0-9]{4,5}', String.valueOf(guest.get('zipcode')))) 
        {
            String zipcode = String.valueOf(guest.get('zipcode'));
            if(zipcode.length() == 4){ 
                zipcode = '0' + zipcode; 
            }
            List<GDB_ArticleVM> items = GDB_ProductUtils.getProductsWithZipCode(recordId, zipcode);
            if(items != null && items.size() > 0) {
                GDB_ArticleVM item = items.get(0);
                Integer nudgeNbOfMonthsToDisplay = GDB_Constants.nudgeNbOfMonthsToDisplay;
                Integer nudgeMinimumThreshold = GDB_Constants.nudgeNbOfMonthsToDisplay;
                Integer nudgeNbOfMonthsMaxToDisplay = GDB_Constants.nudgeNbOfMonthsToDisplay;
                DateTime startDate = DateTime.now().date().addMonths(-nudgeNbOfMonthsToDisplay);
                
                Integer nbCommandes = [SELECT COUNT() 
                                        FROM Item_in_Order__c 
                                        WHERE Article__c = :recordId 
                                        AND Commande__r.Order_Date_and_Time__c >= :startDate
                                        AND gdb_Warehouse__c = :item.getWarehouseId()];
                                        
                if(nbCommandes < nudgeMinimumThreshold) {
                    startDate = DateTime.now().date().addMonths(-nudgeNbOfMonthsMaxToDisplay);
                    nbCommandes = [SELECT COUNT() 
                                    FROM Item_in_Order__c 
                                    WHERE Article__c = :recordId 
                                    AND Commande__r.Order_Date_and_Time__c >= :startDate
                                    AND gdb_Warehouse__c = :item.getWarehouseId()];
                }
                Map<String, Object> result = new Map<String, Object>{
                    'item' => item,
                    'nb' => String.valueOf(nbCommandes)
                };
                String id = guest.containsKey('id') ? String.valueOf(guest.get('id')) : null;
                if(String.isBlank(id) || 'null'.equals(id)) {
                    guest = GDB_AccountMgr.createNewGuest(zipcode);
                    result.put('guestId', String.valueOf(guest.get('Id')));
                }
                return result;
            }
        }
        
        return null;
    }

    /**
    * getMediaByArticleId: Get all media for the carousel 
    * @param: {String} recordId
    * @return: {List<GDB_article_media__c>}
    */
    public static List<GDB_article_media__c> getMediaByArticleId(String recordId) {
        if(recordId == null ) {
            return null;
        }

        List<GDB_article_media__c> medias = [SELECT 
        Id, 
        Name, 
        gdb_document_id_url__c, 
        gdb_image__c, 
        gdb_media_type__c, 
        gdb_media_url__c, 
        gdb_sort__c,
        gdb_Article__c 
        FROM GDB_article_media__c WHERE gdb_Article__c = :recordId ORDER BY gdb_sort__c];

        if(medias.isEmpty()){
            return null;
        }

        return medias;
    }
}