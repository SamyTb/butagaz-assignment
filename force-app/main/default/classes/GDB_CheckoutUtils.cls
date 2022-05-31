public with sharing class GDB_CheckoutUtils { 
    /**
     * getTotals Returns a map of totals (sub-total, shipping price, discount price and total price) of the given object (Basket or Order)
     *
     * @return {Map<String, Decimal>}
     */
    public static Map<String, Decimal> getTotals(Boolean fromBasket) {
        if (fromBasket == null) {
            fromBasket = true;
        }

        Map<String, Decimal> totals = new Map<String, Decimal> {
            'subtotal' => 0,
            'shippingprice' => 0,
            'discountprice' => 0,
            'optionprice' => 0,
            'cutPriceAvailable' => 0,
            'totals' => 0
        };
        Decimal subtotal = 0;
 
        // Let's calculate the basket sub-total
        // Else, calculate the order sub-total
        if (fromBasket == true) {
            GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
            GDB_BasketMgr.recalculateBasket(basket);
            if (basket != null) {
                // Subtotal
                for (GDB_Basket_Product__c lineItem: basket.Basket_Products__r) {
                    if (lineItem.gdb_total_price__c != null && lineItem.gdb_total_price__c >= 0 &&
                        lineItem.gdb_total_tax__c != null && lineItem.gdb_total_tax__c >= 0) {
                        subtotal += lineItem.gdb_total_price__c;
                    }
                }

                // Add multiple payment price
                if(basket.gdb_multiple_payment_price__c != null) {
                    subtotal += basket.gdb_multiple_payment_price__c;
                }
                totals.put('subtotal', subtotal);
                
                // Discount price
                if (basket.gdb_discount_price__c != null && basket.gdb_discount_price__c >= 0) {
                    totals.put('discountprice', basket.gdb_discount_price__c);
                }
                // cut price available
                totals.put('cutPriceAvailable', basket.gdb_cut_price_available__c ? 1 : 0);

                // option price
                if (basket.gdb_shipping_option_price__c != null && basket.gdb_shipping_option_price__c >= 0) {
                    totals.put('optionprice', basket.gdb_shipping_option_price__c);
                }

                totals.put('shippingprice', basket.gdb_palet_price__c);

                if(basket.gdb_total_price__c != null && basket.gdb_total_price__c >=0) {
                    totals.put('totals', basket.gdb_total_price__c);
                }
            }
        } else {
            Order__c order = GDB_OrderMgr.getCurrentOrder();
            if (order != null) {
                // Subtotal
                for (Item_in_Order__c lineItem: order.Articles_dans_Commande__r) {
                    subtotal += lineItem.gdb_total_gross_price__c;
                }

                // Add multiple payment price
                if(order.gdb_multiple_payment_price__c != null) {
                    subtotal += order.gdb_multiple_payment_price__c;
                }
                totals.put('subtotal', subtotal);

                // Shipping price
                totals.put('shippingprice', order.gdb_shipping_price__c);

                // option price
                if (order.gdb_shipping_option_price__c != null && order.gdb_shipping_option_price__c >= 0) {
                    totals.put('optionprice', order.gdb_shipping_option_price__c);
                }
                // Discount price
                if (order.gdb_discount_price__c != null && order.gdb_discount_price__c > 0) {
                    totals.put('discountprice', order.gdb_discount_price__c);
                }
                if(order.gdb_total_gross_price__c != null && order.gdb_total_gross_price__c >=0) {
                    totals.put('totals', order.gdb_total_gross_price__c);
                }
            }
        }

        // Total price
        totals.put('total', totals.get('totals'));

        return totals;
    }

    /**
     * verifyAddressFields
     *
     * @param
     *
     * @return {Map<String,String>}
     */
    public static Map<String, String> verifyAddressFields(GDB_Basket__c basket) {
        Account account = GDB_AccountMgr.getCurrentCustomer();
        Map<String, String> returnObject = new Map<String, String> ();
        if(!returnObject.containsKey('success')) {
            returnObject.put('success', 'true');
        }

        if (account == null || basket == null) {
            returnObject.put('success', 'false');
            returnObject.put('message', System.Label.GDB_cannotValidateStep);
            return returnObject;
        }

        try {
            if(basket.gdb_shipping_firstname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
                return returnObject;
            } else if (basket.gdb_billing_firstname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
                return returnObject;
            } else if (basket.gdb_shipping_lastname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
                return returnObject;
            } else if (basket.gdb_billing_lastname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
                return returnObject;
            } else if (basket.gdb_shipping_salutation__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_salutation }));
                return returnObject;
            } else if (basket.gdb_billing_salutation__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_salutation}));
                return returnObject;
            } else if (basket.gdb_shipping_address1__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
                return returnObject;
            } else if (basket.gdb_billing_address1__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
                return returnObject;
            } else if (basket.gdb_shipping_city__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
                return returnObject;
            } else if (basket.gdb_billing_city__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
                return returnObject;
            } else if (basket.gdb_shipping_zip__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
                return returnObject;
            } else if (basket.gdb_billing_zip__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
                return returnObject;
            } else if (basket.gdb_shipping_country__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
                return returnObject;
            } else if (basket.gdb_billing_country__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
                return returnObject;
            } else if (basket.gdb_shipping_phone__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
                return returnObject;
            } else if (basket.gdb_billing_phone__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_billingRequiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
                return returnObject;
            }

            return returnObject;
        } catch (Exception e) {
            return returnObject;
        }
    }
    
     /**
     * verifyAddressFieldsShipping
     *
     * @param
     *
     * @return {Map<String,String>}
     */
    public static Map<String, String> verifyAddressFieldsShipping(GDB_Basket__c basket) {
        Account account = GDB_AccountMgr.getCurrentCustomer();
        Map<String, String> returnObject = new Map<String, String> ();
        if(!returnObject.containsKey('success')) {
            returnObject.put('success', 'true');
        }

        if (account == null || basket == null) {
            returnObject.put('success', 'false');
            returnObject.put('message', System.Label.GDB_cannotValidateStep);
            return returnObject;
        }

        try {
            if(basket.gdb_shipping_firstname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
                return returnObject;           
            } else if (basket.gdb_shipping_lastname__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
                return returnObject;            
            } else if (basket.gdb_shipping_salutation__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_salutation }));
                return returnObject;           
            } else if (basket.gdb_shipping_address1__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
                return returnObject;            
            } else if (basket.gdb_shipping_city__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
                return returnObject;            
            } else if (basket.gdb_shipping_zip__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
                return returnObject;           
            } else if (basket.gdb_shipping_country__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
                return returnObject;            
            } else if (basket.gdb_shipping_phone__c == null){
                returnObject.put('success', 'false');
                returnObject.put('message', String.format(System.Label.GDB_checkoutAddressform_shippingRequiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
                return returnObject;           
            }

            return returnObject;
        } catch (Exception e) {
            return returnObject;
        }
    }

    /**
     * verifyStock
     *
     * @param
     *
     * @return {Map<String,String>}
     */
    public static Map<String, String> verifyStock(GDB_Basket__c basket) {
        if(basket == null){
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }
        Map<String, String> returnObject = new Map<String, String> ();
        if(!returnObject.containsKey('success')) {
            returnObject.put('success', 'true');
        }
        String zipCode = '';
        if(basket != null && basket.gdb_shipping_zip__c != null && basket.gdb_shipping_zip__c != ''){
            zipCode = basket.gdb_shipping_zip__c;            
        }
        List<GDB_ArticleVM> products = GDB_ProductUtils.getProductsWithZipCode('', zipCode);
        if (basket == null || basket.Basket_Products__r.size() == 0 || products == null || products.size() == 0) {
            returnObject.put('success', 'false');
            returnObject.put('message', System.Label.GDB_cannotValidateStep);
            return returnObject;
        }

        try {
            Boolean productFound = false;
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r){
                productFound = false;
                for(GDB_ArticleVM product : products){
                    
                    if(product.Id == bp.gdb_Article__c){
                        productFound = true;  
                    
                        if(bp.gdb_quantity__c > product.getQuantity()){
                            returnObject.put('success', 'false');
                            returnObject.put('message', String.format(System.Label.GDB_noStockAvailable, new String[]{ bp.Name }));
                            returnObject.put('errorstock', 'true');
                            return returnObject;
                        }
                    }   
                }
                
                if(productFound == false){
                    returnObject.put('success', 'false');
                    returnObject.put('message', String.format(System.Label.GDB_noStockAvailable, new String[]{ bp.Name }));
                    return returnObject;
                }
            }
            return returnObject;
        } catch (Exception e) {
            returnObject.put('success', 'false');
            returnObject.put('message', System.Label.GDB_cannotValidateStep);
            return returnObject;
        }
    }


    /**
     * validateCheckoutStep Validate the checkout step
     *
     * @param {step} step
     *
     * @return {Map<String,String>}
     */
    public static Map<String, String> validateCheckoutStep(Integer step) {
        Map<String, String> validation = new Map <String, String>();
        validation.put('success', 'true');
        validation.put('errorstock', 'false');
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);

        if ((step < 1 || step > 3) && step != 15) {
            validation.put('success', 'false');
            validation.put('message', System.Label.GDB_cannotValidateStep);
            return validation;
        }

        // Basket is null
        // So no steps are valid
        if (basket == null) {
            validation.put('success', 'false');
            validation.put('message', System.Label.GDB_cannotValidateStep);
        }
        
        if (step >= 2 && step != 15 && !basket.gdb_isB2B__c) {
            Map<String, String> resultStockValidation = verifyStock(basket);
            validation.putAll(resultStockValidation);
            if(resultStockValidation.get('success') == 'false'
              || resultStockValidation.get('errorstock') == 'true')
                return validation; 
        }
        
        if (step >= 1 && step != 15 && (basket == null || basket.Basket_Products__r == null || basket.Basket_Products__r.size() == 0 || basket.gdb_Shipping_Method__c == null)) {
            validation.put('success', 'false');
            validation.put('message', System.Label.GDB_cannotValidateStep);
        }
        
        if(step >= 2 && basket.gdb_isB2B__c ){
            validation.putAll(verifyAddressFieldsShipping(basket));
            validation.put('isBasketB2B','true');
        }
        
        if(step >= 2 && step != 15 && !basket.gdb_isB2B__c ){
            validation.putAll(verifyAddressFields(basket));
            validation.put('isBasketB2B','false');
        }

        if (step == 3 && step != 15 && (basket == null || basket.gdb_Payment_Method__c == null)) {
            validation.put('success', 'false');
            validation.put('message', System.Label.GDB_cannotValidateStep);
        }

        return validation;
    }

    /**
     * getNextCheckoutStepURL
     *
     * @param {step} step
     *
     * @return {Map<String,String>}
     */
    public static Map<String, String> getNextCheckoutStepURL(Integer step) {
        String url = GDB_Constants.checkoutStepURLs.get(1);
        Map<String, String> responseMap = validateCheckoutStep(step);
        
        if(!GDB_AccountMgr.isAuthenticated()) {
            responseMap.put('url', GDB_Constants.checkoutStepURLs.get(6));
            responseMap.put('step', '15');
            return responseMap;
        } else if('false'.equals(responseMap.get('success')) || 'true'.equals(responseMap.get('errorstock'))){
            responseMap.put('url', GDB_Constants.checkoutStepURLs.get(1));
            responseMap.put('step', String.valueOf(1));
            return responseMap;
        } else if('true'.equals(responseMap.get('success'))){
            // On redirige vers la confirmation car pas de paiment pour une commande B2B
            if('true'.equals(responseMap.get('isBasketB2B'))){
                step += 3;
                responseMap.put('url', GDB_Constants_B2B.checkoutStepURLsB2B.get(step));
                responseMap.put('step', String.valueOf(step));
                return responseMap;                            
            }
            else{
                step += 1;
                responseMap.put('url', GDB_Constants.checkoutStepURLs.get(step));
                responseMap.put('step', String.valueOf(step));
                return responseMap;                 
            }
        }
        return responseMap;
    }

    /**
     * getAvailableCountries Returns all available contries defined in the {GDB_Basket__c.gdb_shipping_country__c} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableShippingCountries() {
        return GDB_Utils.getFieldValues(GDB_Basket__c.gdb_shipping_country__c.getDescribe(), false, null);
    }

    /**
     * getAvailableCountries Returns all available contries defined in the {GDB_Basket__c.gdb_billing_country__c} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableBillingCountries() {
        return GDB_Utils.getFieldValues(GDB_Basket__c.gdb_billing_country__c.getDescribe(), false, null);
    }

    /**
     * getAvailableCountries Returns all available contries defined in the {Account.gdb_country__c} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableAccountCountries() {
        return GDB_Utils.getFieldValues(Account.gdb_billing_country_list__c.getDescribe(), false, null);
    }

    /**
     * getAvailableShippingSalutations Returns all available salutations defined in the {Basket.gdb_shipping_salutation__c} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableShippingSalutations() {
        return GDB_Utils.getFieldValues(GDB_Basket__c.gdb_shipping_salutation__c.getDescribe(), false, null);
    }

    /**
     * getAvailableBillingSalutations Returns all available salutations defined in the {Basket.gdb_billing_salutation__c} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableBillingSalutations() {
        return GDB_Utils.getFieldValues(GDB_Basket__c.gdb_billing_salutation__c.getDescribe(), false, null);
    }

    /**
     * getAvailableAccountSalutations Returns all available salutations defined in the {Account.Salutation} picklist
     *
     * @return {List<Map<String, String>>}
     */
    public static List<Map<String, String>> getAvailableAccountSalutations() {
        return GDB_Utils.getFieldValues(Account.Salutation.getDescribe(), false, null);
    }
}