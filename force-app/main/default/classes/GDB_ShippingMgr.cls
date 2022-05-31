public without sharing class GDB_ShippingMgr {
    /**
     * getShippingMehtods Returns the list of available shipping methods
     * @return {List<GDB_Shipping_Method__c>}
     */
    public static List<GDB_Shipping_Method__c> getShippingMethods(GDB_Basket__c basket) {
        String basketZipCode = basket.gdb_shipping_zip__c;
        String customerDepartement = basketZipCode != null && basketZipCode.length() > 1 ? basketZipCode.left(2) : null;
        // Get all Article Type for this basket
        Set<Id> articleTypes = new Set<Id>();
        List<GDB_Basket_Product__c> basketProducts = [SELECT Id, gdb_quantity__c, gdb_Article__r.gdb_item_type__c, gdb_Article__r.gdb_eligibility_multiple_shipping__c  FROM GDB_Basket_Product__c WHERE gdb_Basket__c = :basket.Id];
         
        // Get boolean if the current basket is multiple shipping available
        Integer nbQuantity = 0;
        Integer nbQuantityMultipleShippingAllowed = 0;
        Boolean isMultiShippingAvailable = false;
        
        for(GDB_Basket_Product__c lineItem : basketProducts){
            if( lineItem.gdb_Article__r.gdb_item_type__c != null){
                articleTypes.add(lineItem.gdb_Article__r.gdb_item_type__c);
                if(lineItem.gdb_quantity__c != null && lineItem.gdb_quantity__c > 0) {
                    nbQuantity += Integer.valueOf(lineItem.gdb_quantity__c);
                    if ( lineItem.gdb_Article__r.gdb_eligibility_multiple_shipping__c == true) {
                        nbQuantityMultipleShippingAllowed += Integer.valueOf(lineItem.gdb_quantity__c);
                    }
                }
            }
        }

        if (nbQuantityMultipleShippingAllowed > 1) {
            isMultiShippingAvailable = true;
        }

        // Get article shipping link for this article type
        Integer nbArticleType = articleTypes.size();
        Set<Id> shippingMethodIds = new Set<Id>();
        List<gdb_article_shipping_link__c> articleShippingLink = new List<gdb_article_shipping_link__c>();
        if(nbArticleType == 1) {
            articleShippingLink = [SELECT gdb_shipping_method__c
                                    FROM gdb_article_shipping_link__c 
                                    WHERE gdb_item_type__c IN :articleTypes];
            for(gdb_article_shipping_link__c asl : articleShippingLink) {
                shippingMethodIds.add(asl.gdb_shipping_method__c);
            }
        } else {
            AggregateResult[] allArticleShippingLink = [SELECT  gdb_shipping_method__c,
                                                                COUNT(gdb_shipping_method__r.Id) nb
                                                                FROM gdb_article_shipping_link__c 
                                                                WHERE gdb_shipping_method__c != null
                                                                GROUP BY gdb_shipping_method__c];
        }
        
        // if shippingMethodIds is empty, get the first default shipping method
        if(shippingMethodIds.isEmpty()){
                List<GDB_Shipping_Method__c> shippingMethodDefault = [SELECT Id 
                                                                        FROM GDB_Shipping_Method__c 
                                                                        WHERE gdb_active__c = true AND
                                                                        (gdb_start_date__c = null OR gdb_start_date__c <= TODAY) AND
                                                                        (gdb_end_date__c = null OR gdb_end_date__c >= TODAY) AND
                                                                        gdb_price__c != null AND 
                                                                        gdb_is_default__c = true];

                // if allShippingMethodsDefault is empty, get the first shipping method
                if(shippingMethodDefault.isEmpty()){
                    List<GDB_Shipping_Method__c> shippingMethodFirst = [SELECT Id 
                                                                        FROM GDB_Shipping_Method__c WHERE gdb_active__c = true AND
                                                                        (gdb_start_date__c = null OR gdb_start_date__c <= TODAY) AND
                                                                        (gdb_end_date__c = null OR gdb_end_date__c >= TODAY) AND
                                                                        gdb_price__c != null LIMIT 1];

                    shippingMethodIds.add(shippingMethodFirst.get(0).Id);
                }
                else {
                    for(GDB_Shipping_Method__c smd : shippingMethodDefault){
                        shippingMethodIds.add(smd.Id);
                    }
                }
        }

        // Get shipping Method for this set Ids and check if this basket is multi shipping available
        List<GDB_Shipping_Method__c> allShippingMethods = new List<GDB_Shipping_Method__c>();

        if(isMultiShippingAvailable){

            
            allShippingMethods = [SELECT Id,
                                        gdb_title__c,
                                        gdb_description__c,
                                        gdb_promotional_message__c,
                                        gdb_price__c,
                                        gdb_tax__c,
                                        gdb_is_default__c,
                                        gdb_display_order__c,
                                        gdb_cut_price_value__c,
                                  		gdb_number_of_remaining_use__c,
                                        (SELECT Id,
                                                gdb_title__c,
                                                gdb_description__c,
                                                gdb_price__c,
                                                gdb_tax__c,
                                                gdb_display_order__c,
                                                gdb_minimal_product__c,
                                                gdb_minimal_shipping__c,
                                                gdb_multiple_shipping__c
                                                FROM Shippings_Options__r
                                                WHERE gdb_active__c = true AND
                                                (gdb_start_date__c = null OR gdb_start_date__c <= TODAY) AND
                                                (gdb_end_date__c = null OR gdb_end_date__c >= TODAY) AND 
                                                gdb_minimal_product__c <= :nbQuantityMultipleShippingAllowed
                                                ORDER BY gdb_display_order__c),
                                                (SELECT Id, 
                                                        Name, 
                                                        gdb_minimum_article__c,
                                                        gdb_price__c, 
                                                        gdb_tax__c 
                                                        FROM Shipping_Methods_Prices__r
                                                        WHERE gdb_minimum_article__c <= :nbQuantityMultipleShippingAllowed
                                                        ORDER BY gdb_minimum_article__c DESC
                                                        LIMIT 1)
                                        FROM GDB_Shipping_Method__c
                                        WHERE gdb_active__c = true
                                        AND (gdb_start_date__c = null OR gdb_start_date__c <= TODAY)
                                        AND (gdb_end_date__c = null OR gdb_end_date__c >= TODAY)
                                        AND gdb_price__c != null
                                        AND (gdb_deployed_zipcode__c = null OR gdb_deployed_zipcode__c includes(:customerDepartement))
                                        AND Id IN :shippingMethodIds
                                        ORDER BY gdb_display_order__c];
        }
        else {
            allShippingMethods = [SELECT Id,
                                        gdb_title__c,
                                        gdb_description__c,
                                        gdb_promotional_message__c,
                                        gdb_price__c,
                                        gdb_tax__c,
                                        gdb_is_default__c,
                                        gdb_display_order__c,
                                        gdb_cut_price_value__c,
                                  		gdb_number_of_remaining_use__c,
                                        (SELECT Id,
                                                gdb_title__c,
                                                gdb_description__c,
                                                gdb_price__c,
                                                gdb_tax__c,
                                                gdb_display_order__c,
                                                gdb_minimal_product__c,
                                                gdb_minimal_shipping__c,
                                                gdb_multiple_shipping__c
                                                FROM Shippings_Options__r
                                                WHERE gdb_active__c = true AND
                                                (gdb_start_date__c = null OR gdb_start_date__c <= TODAY) AND
                                                (gdb_end_date__c = null OR gdb_end_date__c >= TODAY) AND
                                                gdb_minimal_product__c <= :nbQuantity AND
                                                gdb_multiple_shipping__c = false
                                                ORDER BY Name, gdb_display_order__c),
                                                (SELECT Id, 
                                                        Name, 
                                                        gdb_minimum_article__c,
                                                        gdb_price__c, 
                                                        gdb_tax__c 
                                                        FROM Shipping_Methods_Prices__r
                                                        WHERE gdb_minimum_article__c <= :nbQuantityMultipleShippingAllowed
                                                        ORDER BY gdb_minimum_article__c DESC
                                                        LIMIT 1)
                                        FROM GDB_Shipping_Method__c
                                        WHERE gdb_active__c = true 
                                        AND (gdb_start_date__c = null OR gdb_start_date__c <= TODAY)
                                        AND (gdb_end_date__c = null OR gdb_end_date__c >= TODAY)
                                        AND gdb_price__c != null
                                        AND (gdb_deployed_zipcode__c = null OR gdb_deployed_zipcode__c includes(:customerDepartement))
                                        AND Id IN :shippingMethodIds
                                        ORDER BY gdb_display_order__c];
        }

        // Filter title, description not null
        List<GDB_Shipping_Method__c> shippingMethods = new List<GDB_Shipping_Method__c>();
        
        for(GDB_Shipping_Method__c sm : allShippingMethods){
            if(sm.gdb_title__c != null && sm.gdb_description__c != null )
            {
                if(sm.Shipping_Methods_Prices__r != null && !sm.Shipping_Methods_Prices__r.isEmpty())
                {
                    sm.gdb_price__c = sm.Shipping_Methods_Prices__r.get(0).gdb_price__c;
                    sm.gdb_tax__c = sm.Shipping_Methods_Prices__r.get(0).gdb_tax__c;
                }
                
                if(sm.gdb_number_of_remaining_use__c == null || sm.gdb_number_of_remaining_use__c > 0)
                {
                	shippingMethods.add(sm);
                }
            }
        }
        
        return shippingMethods;
    }

    /**
     * getShippingMehtodById Returns the shipping methods for this Id
     * @param {Id} shippingMethodId
     * @return {GDB_Shipping_Method__c}
     */
    public static GDB_Shipping_Method__c getShippingMehtodById(Id shippingMethodId) {
        GDB_Shipping_Method__c shippingMethod = new GDB_Shipping_Method__c();
        List<GDB_Shipping_Method__c> shippingMethods = [SELECT Id,
                                                                Name,
                                                        		gdb_description__c,
                                                                gdb_title__c,
                                                                gdb_price__c,
                                                                gdb_tax__c,
                                                                gdb_cut_price_value__c
                                                                FROM GDB_Shipping_Method__c
                                                                WHERE gdb_active__c = true AND
                                                                Id =: shippingMethodId];
        
        if( shippingMethods != null && !shippingMethods.isEmpty()){
            shippingMethod = shippingMethods.get(0);
        }

        return shippingMethod;
    }

    /**
     * getShippingMehtodPriceByIdAndQuantity get shipping price according to shipping method and number of products
     * @param {GDB_Basket__c} current basket
     * @param nbQuantityMultipleShippingAllowed nbQuantityMultipleShippingAllowed number of products with multiple shipping eligibilty set to true
     * @return {gdb_shipping_method_price__c}
     */ 
    public static GDB_Shipping_Method__c getShippingMehtodPriceByIdAndQuantity(Id shippingMethodId, Integer nbQuantityMultipleShippingAllowed){
        GDB_Shipping_Method__c shippingMethodWithShippingPrice = [SELECT Id,
                                                                        Name,
                                                                  		gdb_description__c,
                                                                        gdb_title__c,
                                                                        gdb_price__c,
                                                                        gdb_tax__c,
                                                                        gdb_cut_price_value__c,
                                                                        (SELECT Id, 
                                                                                Name, 
                                                                                gdb_minimum_article__c,
                                                                                gdb_price__c, 
                                                                                gdb_tax__c 
                                                                                FROM Shipping_Methods_Prices__r
                                                                                WHERE gdb_minimum_article__c <= :nbQuantityMultipleShippingAllowed
                                                                                ORDER BY gdb_minimum_article__c DESC
                                                                                LIMIT 1)
                                                                        FROM GDB_Shipping_Method__c
                                                                        WHERE gdb_active__c = true AND
                                                                        Id =: shippingMethodId];
        return shippingMethodWithShippingPrice;
    }

    /**
     * updateShippingMethods Update the shipping method for the current basket with the given shipping method ID
     * @param {GDB_Basket__c} basket
     * @param {String} shippingMethodId
     * @return {GDB_Basket__c} basket
     */
    public static GDB_Basket__c updateShippingMethods(GDB_Basket__c basket, String shippingMethodId) {
        if(String.isNotBlank(shippingMethodId) && basket != null) {
            // Remove all basket shipping option
            List<gdb_basket_shipping_option__c> basketShippingOptions = [SELECT Id FROM gdb_basket_shipping_option__c WHERE gdb_Basket__c =: basket.Id];
            if(basketShippingOptions != null && !basketShippingOptions.isEmpty()){
                delete basketShippingOptions;
            }

            basket = GDB_BasketMgr.getBasketById(basket.Id);
            basket.gdb_Shipping_Method__c = shippingMethodId;
            update basket;
            GDB_BasketMgr.recalculateBasket(basket);
        }
        return GDB_BasketMgr.getBasketById(basket.Id);
    }

    /**
     * updateShippingOptions Update the shipping option for the current basket with the given shipping option map
     * @param {GDB_Basket__c} basket
     * @param {List<String>} shippingOptionsIds
     * @return {GDB_Basket__c} basket
     */
    public static GDB_Basket__c updateShippingOptions(GDB_Basket__c basket, List<String> shippingOptionsIds) {
        if(shippingOptionsIds != null && basket != null) {
            List<gdb_basket_shipping_option__c> basketShippingOptions = [SELECT Id FROM gdb_basket_shipping_option__c WHERE gdb_Basket__c =: basket.Id];
            if(basketShippingOptions != null && !basketShippingOptions.isEmpty()){
                delete basketShippingOptions;
            }

            List<gdb_basket_shipping_option__c> basketShippingOptionsToInsert = new List<gdb_basket_shipping_option__c>();
            Integer i = 1;
            for(String shippingOptionsId : shippingOptionsIds){
                gdb_basket_shipping_option__c basketShippingOption = new gdb_basket_shipping_option__c();
                basketShippingOption.Name = basket.Name + ' ' + Label.GDB_prefixe_name_shipping_option + ' ' + i;
                basketShippingOption.gdb_Basket__c = basket.Id;
                basketShippingOption.gdb_Shipping_Option__c = shippingOptionsId;
                basketShippingOptionsToInsert.add(basketShippingOption);
                i++;
            }

            insert basketShippingOptionsToInsert;
            // Reload basket to get all informations
            basket = GDB_BasketMgr.getBasketById(basket.Id);
            GDB_BasketMgr.recalculateBasket(basket);
        }
        return GDB_BasketMgr.getBasketById(basket.Id);
    }
}