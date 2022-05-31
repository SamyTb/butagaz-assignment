public without sharing class GDB_BasketMgr {

    /**
     * createBasket Create a basket with the reference to the current authenticated customer.
     * If there is no authenticated customer, do nothing
     * Also attach the warehouse found for the current customer (if one found) based on the zip code provided in its address
     *
     * @return {GDB_Basket__c}
     */
    public static GDB_Basket__c createBasket() {
        String basketIdKey = GDB_Constants.sessionKeys.get('basketId');
        Account a = GDB_AccountMgr.getCurrentCustomer();
        Map<String, String> currentGuest = GDB_AccountMgr.getCurrentGuest();

        if(a == null && currentGuest == null){ return null; }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // Create the basket
            GDB_Basket__c b = new GDB_Basket__c(
                gdb_Activity_Domain__c = GDB_Constants.activityDomainId,
                gdb_multiple_payment_price__c = 0
            );
            if(a != null) {
                b.gdb_Account__c = a.Id;
                b.gdb_shipping_zip__c = a.gdb_shipping_zip__c;
            }
            else {
                b.gdb_guestid__c = currentGuest.get('id');
                b.gdb_shipping_zip__c = currentGuest.get('zipcode');
            }

            insert b;

            // Then store its ID in the session
            if (!Test.isRunningTest() && GDB_AccountMgr.isAuthenticated()) {
                Cache.Session.put(basketIdKey, b.Id);
            }

            // Retrieve any applicable promotion and apply it if possible
            GDB_Promotion__c promotion = GDB_DiscountMgr.getFirstApplicablePromotion(a);
            if(promotion != null) {
                Boolean isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(promotion);
                if(isAvailable){
                    GDB_DiscountMgr.applyPromotionOnBasket(b, promotion);
                }
            }

            // Retrieve the warehouse for the current customer
            if(a != null && String.isNotBlank(a.gdb_shipping_zip__c)){
                GDB_WarehouseMgr.updateWarehouse(b, a.gdb_shipping_zip__c);
            } else {
                GDB_WarehouseMgr.updateWarehouse(b, currentGuest.get('zipcode'));
            }

            // Finally return it
            return GDB_BasketMgr.getCurrentBasket(false);
        }
        catch(Exception e) {
            Database.rollback(sp);
            return null;
        }
    }

    /**
     * removeBasket Remove the given basket
     *
     * @param {GDB_Basket__c} basket
     */
    public static void removeBasket(GDB_Basket__c basket) {
        if(basket == null) {
            return;
        }

        String basketIdKey = GDB_Constants.sessionKeys.get('basketId');

        // Delete line items
        delete basket.Basket_Products__r;
        // Delete basket
        delete basket;
        // Delete basket ID from session
        if (!Test.isRunningTest()) {
            Cache.Session.remove(basketIdKey);
        }
    }

    /**
     * recalculateBasket Recalculate the basket totals and update it in database
     *
     * @param {GDB_Basket__c} basket
     */
    public static void recalculateBasket(GDB_Basket__c basket) {
        if(basket == null) {
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }

        if(basket == null) {
            return;
        }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // Check Cut Price available and calcul Cut Price
            if(basket.Basket_Products__r != null && basket.Basket_Products__r.size() > 0) {
                basket.gdb_quantity_cut_price__c = 0;
                // Calcul quantity article cut price available
                for(GDB_Basket_Product__c lineItem : basket.Basket_Products__r) {
                    if(lineItem.gdb_Article__r.gdb_item_type__r.gdb_cut_price_available__c){
                        basket.gdb_quantity_cut_price__c += lineItem.gdb_quantity__c;
                    }
                }
            }

            // Update the shipping method details
            Integer nbQuantityMultipleShippingAllowed = getQuantityMultipleShippingAllowed(basket);
            GDB_Shipping_Method__c shippingMethod;
            GDB_Shipping_Method__c shippingMethodWithShippingPrice;

            if(nbQuantityMultipleShippingAllowed > 0 && nbQuantityMultipleShippingAllowed != null){
                shippingMethodWithShippingPrice = GDB_ShippingMgr.getShippingMehtodPriceByIdAndQuantity(basket.gdb_Shipping_Method__c, nbQuantityMultipleShippingAllowed);
            } else {
                shippingMethod = GDB_ShippingMgr.getShippingMehtodById(basket.gdb_Shipping_Method__c);
            }

            if(shippingMethod != null) {
                basket.gdb_shipping_method_name__c = shippingMethod.Name;
                basket.gdb_shipping_method_description__c = shippingMethod.gdb_description__c;
                basket.gdb_shipping_method_price__c = shippingMethod.gdb_price__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_shipping_method_tax__c = shippingMethod.gdb_tax__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_palet_price__c = shippingMethod.gdb_price__c;
                basket.gdb_shipping_method_title__c = shippingMethod.gdb_title__c;
            } else if(shippingMethodWithShippingPrice != null && !shippingMethodWithShippingPrice.Shipping_Methods_Prices__r.isEmpty()) {
                gdb_shipping_method_price__c shippingMethodPriceReturned = shippingMethodWithShippingPrice.Shipping_Methods_Prices__r.get(0);
                basket.gdb_shipping_method_name__c = shippingMethodWithShippingPrice.Name;
                basket.gdb_shipping_method_description__c = shippingMethodWithShippingPrice.gdb_description__c;
                basket.gdb_shipping_method_price__c = shippingMethodPriceReturned.gdb_price__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_shipping_method_tax__c = shippingMethodPriceReturned.gdb_tax__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_palet_price__c = shippingMethodPriceReturned.gdb_price__c;
                basket.gdb_shipping_method_title__c = shippingMethodWithShippingPrice.gdb_title__c;
            } else {
                basket.gdb_shipping_method_name__c = shippingMethodWithShippingPrice.Name;
                basket.gdb_shipping_method_description__c = shippingMethodWithShippingPrice.gdb_description__c;
                basket.gdb_shipping_method_price__c = shippingMethodWithShippingPrice.gdb_price__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_shipping_method_tax__c = shippingMethodWithShippingPrice.gdb_tax__c * basket.gdb_quantity_cut_price__c;
                basket.gdb_palet_price__c = shippingMethodWithShippingPrice.gdb_price__c;
                basket.gdb_shipping_method_title__c = shippingMethodWithShippingPrice.gdb_title__c;
            }

            basket.gdb_cut_price_available__c = (basket.gdb_shipping_method_price__c != null && basket.gdb_quantity_cut_price__c > 1);

            // Update the shipping option details
            List<gdb_basket_shipping_option__c> basketShippingOptions = [SELECT Id,
                                                                                Name,
                                                                                gdb_Shipping_Option__r.gdb_price__c,
                                                                                gdb_Shipping_Option__r.gdb_tax__c,
                                                                                gdb_Shipping_Option__r.gdb_multiple_shipping__c
                                                                                FROM gdb_basket_shipping_option__c
                                                                                WHERE gdb_Basket__c =: basket.Id];

            basket.gdb_shipping_option_price__c = 0;
            basket.gdb_shipping_option_tax__c = 0;
            basket.gdb_multiple_shipping__c = false;
            if(basketShippingOptions != null && !basketShippingOptions.isEmpty()) {

                for(gdb_basket_shipping_option__c option : basketShippingOptions){
                    basket.gdb_shipping_option_price__c = basket.gdb_shipping_option_price__c == null ? option.gdb_Shipping_Option__r.gdb_price__c : basket.gdb_shipping_option_price__c + option.gdb_Shipping_Option__r.gdb_price__c;
                    basket.gdb_shipping_option_tax__c = basket.gdb_shipping_option_tax__c == null ? option.gdb_Shipping_Option__r.gdb_tax__c : basket.gdb_shipping_option_tax__c + option.gdb_Shipping_Option__r.gdb_tax__c;

                    // Update multiple shipping if one option is multiple shipping option
                    if(option.gdb_Shipping_Option__r.gdb_multiple_shipping__c){
                        basket.gdb_multiple_shipping__c = true;
                    }
                }
            }

            // Update the payment method details
            if(basket.gdb_Payment_Method__c != null) {
                GDB_Payment_Method__c paymentMethod = GDB_PaymentMgr.getPaymentMethodById(basket.gdb_Payment_Method__c);

                if(paymentMethod != null) {
                    basket.gdb_payment_method_name__c = paymentMethod.Name;
                } else {
                    basket.gdb_payment_method_name__c = '';
                }
            } else {
                basket.gdb_payment_method_name__c = '';
            }

            // Update the discount details
            if(basket.gdb_Discount__c != null && basket.gdb_shipping_method_price__c > 0) {
                GDB_Promotion__c promotion = GDB_DiscountMgr.getPromotionById(basket.gdb_Discount__c);
                Boolean isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(promotion, basket);

                Account account = GDB_AccountMgr.getCurrentCustomer();

                if (isAvailable && promotion != null && (account == null || (account != null && !GDB_DiscountMgr.isCustomerAlreadyHadPromotion(account, promotion)))) {
                    basket.gdb_discount_name__c = promotion.Name;
                    basket.gdb_coupon_code__c = promotion.gdb_coupon_code__c;
                    GDB_DiscountMgr.applyPromotionOnBasket(basket, promotion);
                } else {
                    basket.gdb_Discount__c = null;
                    basket.gdb_discount_name__c = '';
                    basket.gdb_coupon_code__c = '';
                    basket.gdb_discount_price__c = 0;
                    basket.gdb_discount_tax__c = 0;
                }
            } else {
                basket.gdb_Discount__c = null;
                basket.gdb_discount_name__c = '';
                basket.gdb_coupon_code__c = '';
                basket.gdb_discount_price__c = 0;
                basket.gdb_discount_tax__c = 0;
            }

            // Update the basket totals
            Double totalPrice = 0;
            Double totalTax = 0;
            Decimal nbQuantity = 0;
            Boolean freeMultiShipping = true;
            // Apply product line item prices
            for(GDB_Basket_Product__c lineItem : basket.Basket_Products__r) 
            {
                if(lineItem.gdb_product_code__c.toLowerCase() ==  GDB_Constants.articleCode.get(2).toLowerCase())
                {
                	lineItem.gdb_quantity__c = 1;
                    update lineItem;
                }
                
                if(lineItem.gdb_total_price__c != null && lineItem.gdb_total_price__c >= 0) 
                {
                    totalPrice += lineItem.gdb_total_price__c;
                }
                
                if(lineItem.gdb_total_tax__c != null && lineItem.gdb_total_tax__c >= 0) 
                {
                    totalTax += lineItem.gdb_total_tax__c;
                }
                
                if(lineItem.gdb_Article__r != null && lineItem.gdb_Article__r.gdb_not_free_second_shipping__c) 
                {
                    freeMultiShipping = false;
                }                 
                
                nbQuantity += lineItem.gdb_quantity__c;
            }


            // Apply shipping method and option prices
            if (basket.gdb_Shipping_Method__c != null){
                totalPrice += basket.gdb_shipping_method_price__c;
                totalTax += basket.gdb_shipping_method_tax__c;
            }

            // Apply shipping option prices
            if(basket.gdb_shipping_option_price__c != null && basket.gdb_shipping_option_price__c >= 0
            && basket.gdb_shipping_option_tax__c != null && basket.gdb_shipping_option_tax__c >= 0) {
                totalPrice += basket.gdb_shipping_option_price__c;
                totalTax += basket.gdb_shipping_option_tax__c;
            }

            // Apply discount
            if(basket.gdb_discount_price__c != null && basket.gdb_discount_price__c >= 0
            && basket.gdb_discount_tax__c != null && basket.gdb_discount_tax__c >= 0) {
                totalPrice -= basket.gdb_discount_price__c;
                totalTax -= basket.gdb_discount_tax__c;
            }

            // Apply multiple payment price
            if(basket.gdb_multiple_payment_price__c != null) {
                totalPrice += basket.gdb_multiple_payment_price__c;
            }

            // Set totals
            basket.gdb_total_price__c = totalPrice;
            basket.gdb_total_tax__c = totalTax;
            update basket;
        }
        catch(Exception e) {
            Database.rollback(sp);
            GDB_ErrorMgr.createError('GDB_BasketMgr','recalculateBasket', e.getStackTraceString());
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }
    }

    /**
     * getCurrentBasket Returns the current basket for the current user.
     * This method get the basket ID from the session
     * @param {Boolean} createBasketIfNotExists
     * @return {GDB_Basket__c}
     */
    public static GDB_Basket__c getCurrentBasket(Boolean createBasketIfNotExists) {
        String idKey = GDB_Constants.sessionKeys.get('basketId');
        List<GDB_Basket__c> baskets = new List<GDB_Basket__c>();
        GDB_Basket__c basket = null;

        if (Test.isRunningTest() || !GDB_AccountMgr.isAuthenticated() || !Cache.Session.contains(idKey)) {
            Account account = GDB_AccountMgr.getCurrentCustomer();
            Map<String, String> currentGuest = GDB_AccountMgr.getCurrentGuest();
            baskets = getBasketsByAccountOrGuest(account, currentGuest);

            if(baskets.size() > 0)
            {
                basket = baskets.get(0);
                Integer multiPaymentThreshold = GDB_CustomSettingsMgr.self().getMultiplePaymentThreshold();

                if(Boolean.valueOf(basket.gdb_multiple_payment__c)) {
                    basket.gdb_multiple_payment__c = Boolean.valueOf(basket.gdb_total_price__c > multiPaymentThreshold);
                }

                if(GDB_AccountMgr.isAuthenticated()) {
                    Cache.Session.put(idKey, basket.Id);
                }
            }
        } else {
            baskets.add(GDB_BasketMgr.getBasketById((Id)Cache.Session.get(idKey)));
            basket = baskets.get(0);
        }

        if(baskets == null || baskets.size() == 0) {
            if(createBasketIfNotExists == false) {
                return null;
            }

            return GDB_BasketMgr.createBasket();
        }

        return basket;
    }

    /**
    * Return the current basket of Account or Guest pass by params
    * @param {Account} customer
    * @param {Map<String, String>} guest
    * @return {GDB_Basket__c} guest
    */
    public static GDB_Basket__c getCurrentBasketByAccountOrGuest(Account customer, Map<String, String> guest) {
        List<GDB_Basket__c> baskets = getBasketsByAccountOrGuest(customer, guest);
        if(baskets.size() > 0) {
            return baskets.get(0);
        }

        return null;
    }

    /**
    * Return the baskets list of Account or Guest pass by params
    * @param {Account} customer
    * @param {Map<String, String>} guest
    * @return {List<GDB_Basket__c>}
    */
    public static List<GDB_Basket__c> getBasketsByAccountOrGuest(Account customer, Map<String, String> guest) {
        Id accountId = customer != null ? customer.Id : null;
        String guestId = customer == null && guest != null ? guest.get('id') : null;

        return [SELECT  Id,
                        Name,
                        gdb_guestid__c,
                        gdb_Account__r.Email__c,
                        gdb_Account__r.FirstName,
                        gdb_Account__r.LastName,
                        gdb_Account__r.Salutation,
                        gdb_Account__r.gdb_block_orders__c,
                        gdb_Account__r.gdb_accountNo__c,
                        gdb_Activity_Domain__c,
                        gdb_multiple_payment__c,
                        gdb_multiple_shipping__c,
                        gdb_shipping_instructions__c,
                        gdb_billing_salutation__c,
                        gdb_billing_firstname__c,
                        gdb_billing_lastname__c,
                        gdb_billing_address1__c,
                        gdb_billing_address2__c,
                        gdb_billing_address3__c,
                        gdb_billing_city__c,
                        gdb_billing_zip__c,
                        gdb_billing_country__c,
                        gdb_billing_phone__c,
                        gdb_coupon_code__c,
                        gdb_Discount__c,
                        gdb_discount_name__c,
                        gdb_discount_price__c,
                        gdb_discount_tax__c,
                        gdb_Payment_Method__c,
                        gdb_payment_method_name__c,
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
                        gdb_Shipping_Method__c,
                        gdb_shipping_method_name__c,
                		gdb_shipping_method_description__c,
                        gdb_shipping_method_price__c,
                        gdb_shipping_method_tax__c,
                        gdb_shipping_method_title__c,
                        gdb_shipping_option_price__c,
                        gdb_shipping_option_tax__c,
                        gdb_total_price__c,
                        gdb_total_tax__c,
                        gdb_use_shipping_as_billing__c,
                        gdb_isB2B__c,
                        gdb_Warehouse__c,
                        gdb_wished_shipping_date__c,
                        gdb_cut_price_available__c,
                        gdb_cut_price__c,
                        gdb_quantity_cut_price__c,
                        gdb_palet_price__c,
                        gdb_multiple_payment_price__c,
                        (
                            SELECT
                            gdb_description__c,
                            gdb_Article__c,
                            gdb_Article__r.recordTypeId,
                            gdb_Article__r.gdb_eligibility_multiple_shipping__c,
                            gdb_Article__r.gdb_item_type__c,
                            gdb_Article__r.gdb_item_type__r.gdb_cut_price_available__c,
                            gdb_Article__r.gdb_not_free_second_shipping__c,
                            gdb_product_code__c,
                            gdb_quantity__c,
                            gdb_sku__c,
                            gdb_total_price__c,
                            gdb_total_tax__c,
                            gdb_unit_price__c,
                            gdb_unit_tax__c,
                            Name,
                            gdb_warehouse__c,
                            gdb_warehouse__r.gdb_shipping_carrier__c,
                            gdb_quantitywarehousecoefficient__c,
                            gdb_unit_price_warehouse__c,
                            gdb_unit_tax_warehouse__c
                            FROM Basket_Products__r
                        ),
                        (
                            SELECT
                            Name,
                            gdb_Shipping_Option__c,
                            gdb_Shipping_Option__r.gdb_price__c
                            FROM Baskets_Shippings_options__r
                        )
                        FROM GDB_Basket__c
                        WHERE gdb_Account__c = :accountId
                        AND gdb_guestid__c = :guestId
                        ORDER BY LastModifiedDate desc
                    ];
    }

    /**
    * Set the current basket to customer pass by params or, if null, to the current logged customer
    * @param {Account} customer
    * @return {GDB_Basket__c}
    */
    public static GDB_Basket__c setGuestBasketToCustomer(Account customer) {
        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        if(guest == null){ return null; }
        else if(customer == null) {
            customer = GDB_AccountMgr.getCurrentCustomer();
        }

        GDB_Basket__c cart = getCurrentBasketByAccountOrGuest(null, guest);

        if(cart != null) {
            String postalCodeUser = GDB_AccountMgr.getCustomerPostalCode(customer);

            // Test zipcode changed & recalculate products prices with new zip code
            if(cart.gdb_shipping_zip__c != postalCodeUser) {
                GDB_ArticleVM article;
                for(GDB_Basket_Product__c p : cart.Basket_Products__r) {
                    article = GDB_ProductUtils.getWarehouseArticleWithZipCode(p.gdb_Article__c, postalCodeUser);
                    if(article != null) {
                        article.bind2BasketProduct(p);
                    }
                }

                update cart.Basket_Products__r;
            }

            // Update current guest basket with the current customer id
            cart.gdb_guestid__c = null;
            cart.gdb_Account__c = customer.Id;
            cart.gdb_shipping_zip__c = postalCodeUser;
            update cart;

            recalculateBasket(cart);
            return cart;
        }

        return null;
    }

    /**
     * getBasketById Returns the basket related to this given ID
     *
     * @param {Id} basketId
     *
     * @returns {GDB_Basket__c}
     *
     **/
    public static GDB_Basket__c getBasketById(Id basketId) {
        if (basketId == null) {
            return null;
        }

        List<GDB_Basket__c> baskets = [SELECT
                                            Id,
                                            Name,
                                            gdb_Account__r.Email__c,
                                            gdb_Account__r.FirstName,
                                            gdb_Account__r.LastName,
                                            gdb_Account__r.Salutation,
                                            gdb_Account__r.gdb_block_orders__c,
                                            gdb_Account__r.gdb_accountNo__c,
                                            gdb_Activity_Domain__c,
                                            gdb_multiple_payment__c,
                                            gdb_multiple_shipping__c,
                                            gdb_shipping_instructions__c,
                                            gdb_billing_salutation__c,
                                            gdb_billing_firstname__c,
                                            gdb_billing_lastname__c,
                                            gdb_billing_address1__c,
                                            gdb_billing_address2__c,
                                            gdb_billing_address3__c,
                                            gdb_billing_city__c,
                                            gdb_billing_zip__c,
                                            gdb_billing_country__c,
                                            gdb_billing_phone__c,
                                            gdb_coupon_code__c,
                                            gdb_Discount__c,
                                            gdb_discount_name__c,
                                            gdb_discount_price__c,
                                            gdb_discount_tax__c,
                                            gdb_Payment_Method__c,
                                            gdb_payment_method_name__c,
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
                                            gdb_Shipping_Method__c,
                                            gdb_shipping_method_name__c,
                                       		gdb_shipping_method_description__c,
                                            gdb_shipping_method_price__c,
                                            gdb_shipping_method_tax__c,
                                            gdb_shipping_option_price__c,
                                            gdb_shipping_option_tax__c,
                                            gdb_shipping_method_title__c,
                                            gdb_total_price__c,
                                            gdb_total_tax__c,
                                            gdb_use_shipping_as_billing__c,
                                            gdb_isB2B__c,
                                            gdb_Warehouse__c,
                                            gdb_wished_shipping_date__c,
                                            gdb_cut_price_available__c,
                                            gdb_cut_price__c,
                                            gdb_quantity_cut_price__c,
                                            gdb_multiple_payment_price__c,
                                            (
                                                SELECT
                                                    gdb_description__c,
                                                    gdb_Article__c,
                                                    gdb_Article__r.recordTypeId,
                                                    gdb_Article__r.gdb_eligibility_multiple_shipping__c,
                                                    gdb_Article__r.gdb_item_type__c,
                                                    gdb_Article__r.gdb_item_type__r.gdb_cut_price_available__c,
                                                    gdb_Article__r.gdb_not_free_second_shipping__c,
                                                    gdb_product_code__c,
                                                    gdb_quantity__c,
                                                    gdb_sku__c,
                                                    gdb_total_price__c,
                                                    gdb_total_tax__c,
                                                    gdb_unit_price__c,
                                                    gdb_unit_tax__c,
                                                    Name,
                                                    gdb_warehouse__c,
                                                    gdb_warehouse__r.gdb_shipping_carrier__c,
                                                    gdb_quantitywarehousecoefficient__c,
                                                    gdb_unit_price_warehouse__c,
                                                    gdb_unit_tax_warehouse__c
                                                FROM Basket_Products__r
                                            ),
                                            (
                                                SELECT
                                                Name,
                                                gdb_Shipping_Option__c,
                                                gdb_Shipping_Option__r.gdb_price__c
                                                FROM Baskets_Shippings_options__r
                                            )
                                            FROM GDB_Basket__c
                                            WHERE Id = :basketId
                                            LIMIT 1
                                        ];

        if (baskets == null || baskets.size() == 0) {
            return null;
        }

        return baskets.get(0);
    }

    /**
     * getBasketLineItemQuantities Returns the total of orderable quantities (sum of all quantities of basket line items)
     *
     * @return {Integer}
     */
    public static Integer getBasketLineItemQuantities() {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return 0;
        }

        Integer quantity = 0;

        for(GDB_Basket_Product__c lineItem : basket.Basket_Products__r) {
            if(lineItem.gdb_quantity__c != null && lineItem.gdb_quantity__c > 0) {
                quantity += Integer.valueOf(lineItem.gdb_quantity__c);
            }
        }

        return quantity;
    }

    /**
     * updateLineItemQuantity Update the quantity for the given basket line item of the current basket
     *
     * @param {Id} lineItemId
     * @param {Integer} quantity
     */
    public static void updateLineItemQuantity(Id lineItemId, Integer quantity) {
        if(lineItemId == null || quantity < 0) {
            return;
        }

        updateLineItemQuantity(lineItemId, quantity, GDB_BasketMgr.getCurrentBasket(false));
    }

    /**
     * updateLineItemQuantity Update the quantity for the given basket line item to the basket pass by params
     *
     * @param {Id} lineItemId
     * @param {Integer} quantity
     * @param {GDB_Basket__c} basket
     */
    public static void updateLineItemQuantity(Id lineItemId, Integer quantity, GDB_Basket__c basket) {
        if(lineItemId == null || quantity < 0 || basket == null) {
            return;
        }

        Map<Id, GDB_Basket_Product__c> basketProdMap = new Map<Id, GDB_Basket_Product__c>(basket.Basket_Products__r);
        GDB_Basket_Product__c foundLineItem = basketProdMap.get(lineItemId);

        // If the line item exists in the basket
        if(foundLineItem != null) 
        {
            // Get current basket with all fields necessary
            GDB_Basket__c currentBasket = GDB_BasketMgr.getBasketById(basket.Id);

            // Get the current article VM
            GDB_ArticleVM article = GDB_ProductUtils.getWarehouseArticleForCurrentUser(foundLineItem.gdb_Article__c);

            // If the quantity is greater than 0, update the line item
            if( article != null && quantity > 0 )
            {
                foundLineItem.gdb_quantity__c = quantity;
                foundLineItem.gdb_total_price__c = article.price * foundLineItem.gdb_quantity__c;
                foundLineItem.gdb_total_tax__c = article.tax * foundLineItem.gdb_quantity__c;
                update foundLineItem;

                // Delete shipping option if quantity is less of necessary for this shipping option
                Integer quantiytItemCurrentBasket = getBasketLineItemQuantities();

                List<gdb_basket_shipping_option__c> basketShippingOptions = [SELECT Id,
                                                                                    gdb_Shipping_Option__r.gdb_minimal_product__c
                                                                                    FROM gdb_basket_shipping_option__c
                                                                                    WHERE gdb_Basket__c =: currentBasket.Id AND
                                                                                    gdb_Shipping_Option__r.gdb_minimal_product__c > :quantiytItemCurrentBasket];
                if(basketShippingOptions != null && !basketShippingOptions.isEmpty()){
                    delete basketShippingOptions;
                }
            }

            // Else, remove the line item from the basket
            else {
                // Delete the item in this basket
                delete foundLineItem;
            }

            // Recalculate the current Basket
            GDB_BasketMgr.recalculateBasket(currentBasket);
        }
    }

    /**
     * getShippingAddressAsMap Return the shipping address details as Map<String, String>
     *
     * @return Map<String, String>
     */
    public static Map<String, String> getShippingAddressAsMap() {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return null;
        }

        Map<String, String> verifyStatus = GDB_CheckoutUtils.verifyAddressFields(basket);

        if ('true'.equals(verifyStatus.get('success'))) {
            return new Map<String, String>{
                'salutation' => basket.gdb_shipping_salutation__c,
                'firstname' => basket.gdb_shipping_firstname__c,
                'lastname' => basket.gdb_shipping_lastname__c,
                'address1' => basket.gdb_shipping_address1__c,
                'address2' => basket.gdb_shipping_address2__c,
                'address3' => basket.gdb_shipping_address3__c,
                'city' => basket.gdb_shipping_city__c,
                'zip' => basket.gdb_shipping_zip__c,
                'country' => basket.gdb_shipping_country__c,
                'phone' => basket.gdb_shipping_phone__c
            };
        } else {
            Account account = GDB_AccountMgr.getCurrentCustomer();

            return new Map<String, String>{
                'salutation' => account.gdb_shipping_salutation__c,
                'firstname' => account.gdb_shipping_firstname__c,
                'lastname' => account.gdb_shipping_lastname__c,
                'address1' => account.gdb_shipping_address1__c,
                'address2' => account.gdb_shipping_address2__c,
                'address3' => account.gdb_shipping_address3__c,
                'city' => account.gdb_shipping_city__c,
                'zip' => account.gdb_shipping_zip__c,
                'country' => account.gdb_shipping_country__c,
                'phone' => account.gdb_shipping_phone__c
            };
        }
    }

    /**
     * getBillingAddressAsMap Return the billing address details as Map<String, String>
     *
     * @return Map<String, String>
     */
    public static Map<String, String> getBillingAddressAsMap() {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return null;
        }

        Map<String, String> verifyStatus = GDB_CheckoutUtils.verifyAddressFields(basket);

        if ('true'.equals(verifyStatus.get('success'))) {
            return new Map<String, String>{
                'salutation' => basket.gdb_billing_salutation__c,
                'firstname' => basket.gdb_billing_firstname__c,
                'lastname' => basket.gdb_billing_lastname__c,
                'address1' => basket.gdb_billing_address1__c,
                'address2' => basket.gdb_billing_address2__c,
                'address3' => basket.gdb_billing_address3__c,
                'city' => basket.gdb_billing_city__c,
                'zip' => basket.gdb_billing_zip__c,
                'country' => basket.gdb_billing_country__c,
                'phone' => basket.gdb_billing_phone__c
            };
        } else {
            Account account = GDB_AccountMgr.getCurrentCustomer();
            account.gdb_billing_country__c = account.gdb_billing_country__c == null || account.gdb_billing_country__c == '' ? account.gdb_billing_country_list__c : account.gdb_billing_country__c;
            return new Map<String, String>{
                'salutation' => account.gdb_billing_salutation__c,
                'firstname' => account.gdb_billing_firstname__c,
                'lastname' => account.gdb_billing_lastname__c,
                'address1' => account.gdb_billing_address1__c,
                'address2' => account.gdb_billing_address2__c,
                'address3' => account.gdb_billing_address3__c,
                'city' => account.gdb_billing_city__c,
                'zip' => account.gdb_billing_postalcode__c,
                'country' => account.gdb_billing_country__c,
                'phone' => account.gdb_billing_phone__c
            };
        }
    }

    /**
     * updateAddresses Update addresses for the current basket based on the given forms
     *
     * @param {Map<String, String>} shippingForm
     * @param {Map<String, String>} billingForm
     * @param {String} shippingInstructions
     * @param {Boolean} useShippingAsBilling
     *
     * @return {Boolean}
     */
    public static Boolean updateAddresses(Map<String, String> shippingForm, Map<String, String> billingForm, String shippingInstructions, Boolean useShippingAsBilling) {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null || shippingForm == null || billingForm == null) {
            return false;
        }

        try {
            String previousShippingZip = basket.gdb_shipping_zip__c;

            // Shipping address
            basket.gdb_shipping_salutation__c = shippingForm.get('salutation');
            basket.gdb_shipping_firstname__c = shippingForm.get('firstname');
            basket.gdb_shipping_lastname__c = shippingForm.get('lastname');
            basket.gdb_shipping_address1__c = shippingForm.get('address1');
            basket.gdb_shipping_address2__c = shippingForm.get('address2');
            basket.gdb_shipping_address3__c = shippingForm.get('address3');
            basket.gdb_shipping_city__c = shippingForm.get('city');
            basket.gdb_shipping_zip__c = shippingForm.get('zip');
            basket.gdb_shipping_country__c = shippingForm.get('country');
            basket.gdb_shipping_phone__c = shippingForm.get('phone');

            // Use shipping as billing
            basket.gdb_use_shipping_as_billing__c = useShippingAsBilling;
            // Shipping instructions
            basket.gdb_shipping_instructions__c = shippingInstructions;

            // Billing address
            if(basket.gdb_use_shipping_as_billing__c == true) {
                basket.gdb_billing_salutation__c = shippingForm.get('salutation');
                basket.gdb_billing_firstname__c = shippingForm.get('firstname');
                basket.gdb_billing_lastname__c = shippingForm.get('lastname');
                basket.gdb_billing_address1__c = shippingForm.get('address1');
                basket.gdb_billing_address2__c = shippingForm.get('address2');
                basket.gdb_billing_address3__c = shippingForm.get('address3');
                basket.gdb_billing_city__c = shippingForm.get('city');
                basket.gdb_billing_zip__c = shippingForm.get('zip');
                basket.gdb_billing_country__c = shippingForm.get('country');
                basket.gdb_billing_phone__c = shippingForm.get('phone');
            } else {
                basket.gdb_billing_salutation__c = billingForm.get('salutation');
                basket.gdb_billing_firstname__c = billingForm.get('firstname');
                basket.gdb_billing_lastname__c = billingForm.get('lastname');
                basket.gdb_billing_address1__c = billingForm.get('address1');
                basket.gdb_billing_address2__c = billingForm.get('address2');
                basket.gdb_billing_address3__c = billingForm.get('address3');
                basket.gdb_billing_city__c = billingForm.get('city');
                basket.gdb_billing_zip__c = billingForm.get('zip');
                basket.gdb_billing_country__c = billingForm.get('country');
                basket.gdb_billing_phone__c = billingForm.get('phone');
            }
            update basket;

            // Now that addresses are updated, get the new warehouse if the zip code changed
            if((previousShippingZip == null || previousShippingZip != basket.gdb_shipping_zip__c) && String.isNotBlank(basket.gdb_shipping_zip__c)) {
                GDB_WarehouseMgr.updateWarehouse(basket, basket.gdb_shipping_zip__c);
            }

            // Finally recalculate the basket
            GDB_BasketMgr.recalculateBasket(basket);
            return true;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            return false;
        }

        return false;
    }

     /**
     * updateAddressesShipping Update addresses for the current basket based on the given forms
     *
     * @param {Map<String, String>} shippingForm
     * @param {String} shippingInstructions
     *
     * @return {Boolean}
     */
    public static Boolean updateAddressShipping(Map<String, String> shippingForm, String shippingInstructions) {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null || shippingForm == null ) {
            return false;
        }

        try {
            String previousShippingZip = basket.gdb_shipping_zip__c;

            // Shipping address
            basket.gdb_shipping_salutation__c = shippingForm.get('salutation');
            basket.gdb_shipping_firstname__c = shippingForm.get('firstname');
            basket.gdb_shipping_lastname__c = shippingForm.get('lastname');
            basket.gdb_shipping_address1__c = shippingForm.get('address1');
            basket.gdb_shipping_address2__c = shippingForm.get('address2');
            basket.gdb_shipping_address3__c = shippingForm.get('address3');
            basket.gdb_shipping_city__c = shippingForm.get('city');
            basket.gdb_shipping_zip__c = shippingForm.get('zip');
            basket.gdb_shipping_country__c = shippingForm.get('country');
            basket.gdb_shipping_phone__c = shippingForm.get('phone');

            // Shipping instructions
            basket.gdb_shipping_instructions__c = shippingInstructions;

            update basket;

            // Now that addresses are updated, get the new warehouse if the zip code changed
            if((previousShippingZip == null || previousShippingZip != basket.gdb_shipping_zip__c) && String.isNotBlank(basket.gdb_shipping_zip__c)) {
                GDB_WarehouseMgr.updateWarehouse(basket, basket.gdb_shipping_zip__c);
            }

            // Finally recalculate the basket
            GDB_BasketMgr.recalculateBasket(basket);
            return true;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            return false;
        }

        return false;
    }

    /**
     * updateMultipleShipping description
     * @param  isMultipleShipping isMultipleShipping description
     */
    public static void updateMultipleShipping(Boolean isMultipleShipping) {

        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);

        if(basket == null) {
            return;
        }

        basket.gdb_multiple_shipping__c = isMultipleShipping;
        update basket;
    }

    /**
     * getMultiplePaymentDetailsForCurrentBasket : Return timetable for multiple payment
     * @param  {Boolean} foramt date and price
     * @return Map<String, String>
     */
    public static Map<String, Object> getMultiplePaymentDetailsForCurrentBasket(Boolean format) {
        Map<String, Object[]> returnObject = new Map<String, Object[]>();

        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return null;
        }
        Decimal totalPrice = basket.gdb_total_price__c;
        DateTime d = DateTime.Now();

        Map<Integer, String> monthFrench = GDB_Constants.monthFrench;
        Integer nb = GDB_Mercanet.PAYMENT_TIMES;
        Integer timeBetweenDueDates = GDB_Mercanet.PAYMENT_TIME_BETWEEN_DATES;
        // Initialize the total price to a decimal one
        Decimal intTotalPrice = Integer.valueOf(totalPrice * 100);
        // Get the price for each sub-payment
        Decimal price = Integer.valueOf(intTotalPrice / nb);
        Decimal totalOfPrices = Integer.valueOf(price * nb);
        // The first price is equals all other prices + the difference between the total price and the sum of all prices
        Decimal firstPrice = price + (intTotalPrice - totalOfPrices);

        Object[] dates;

        if (format) {
            dates = new String[] {
                d.format('dd') + ' ' + monthFrench.get(d.month()) + ' ' + d.format('yyyy')
            };
        } else {
            dates = new DateTime[] {
                d
            };
        }

        Object[] prices;
        if (format) {
            prices = new String[] {
                String.valueOf(firstPrice / 100)
            };
        } else {
            prices = new Decimal[] {
                firstPrice / 100
            };
        }

        for (Integer dueDate = 1; dueDate < nb; dueDate++) {
            if (format) {
                dates.add(d.addDays(timeBetweenDueDates * dueDate).format('dd') + ' ' + monthFrench.get(d.addDays(timeBetweenDueDates * dueDate).month()) + ' ' + d.addDays(timeBetweenDueDates * dueDate).format('yyyy'));
            } else {
                dates.add(d.addDays(timeBetweenDueDates * dueDate));
            }
            if (format) {
                prices.add(String.valueOf(price / 100));
            } else {
                prices.add(price / 100);
            }
        }

        returnObject.put('dates', dates);
        returnObject.put('prices', prices);

        return returnObject;
    }

    /**
     * updateZipCodeShipping Update addresses for the current basket based on the given forms
     *
     * @param {String} zipCode
     *
     * @return {Boolean}
     */
    public static Boolean updateZipCodeShipping(String zipCode) {

        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null || zipCode == null ) {
            return false;
        }

        try {
            String previousShippingZip = basket.gdb_shipping_zip__c;

            basket.gdb_shipping_zip__c = zipCode;

            update basket;

            // Now that addresses are updated, get the new warehouse if the zip code changed
            if((previousShippingZip == null || previousShippingZip != basket.gdb_shipping_zip__c) && String.isNotBlank(basket.gdb_shipping_zip__c)) {
                GDB_WarehouseMgr.updateWarehouse(basket, basket.gdb_shipping_zip__c);
            }

            // Finally recalculate the basket
            GDB_BasketMgr.recalculateBasket(basket);
            return true;
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            return false;
        }
    }

    /**
     * getQuantityMultipleShippingAllowed get number of product with eligibility to mulple shipping set to true
     * @param  basket current basket
     * @return return nbQuantityMultipleShippingAllowed
     */
    public static Integer getQuantityMultipleShippingAllowed(GDB_Basket__c basket){
        Integer nbQuantityMultipleShippingAllowed = 0;

        for(GDB_Basket_Product__c lineItem : basket.Basket_Products__r  ){
            if (lineItem.gdb_Article__r.gdb_eligibility_multiple_shipping__c == true) {
                nbQuantityMultipleShippingAllowed += Integer.valueOf(lineItem.gdb_quantity__c);
            }
        }
        return nbQuantityMultipleShippingAllowed;
    }

    /**
     * updateMultiplePaymentPrice : update multiple payment price when changing multiple payment selection
     */
    public static void updateMultiplePaymentPrice(Boolean isMultiplePayment) {
        GDB_Basket__c currentBasket = getCurrentBasket(false);
        if(currentBasket == null) {
            return;
        } else {
            if(isMultiplePayment) {
                currentBasket.gdb_multiple_payment_price__c = GDB_CustomSettingsMgr.self().getMercanetPaymentTimesPrice();
            } else {
                currentBasket.gdb_multiple_payment_price__c = 0;
            }
            currentBasket.gdb_multiple_payment__c = isMultiplePayment;
            update currentBasket;
        }
        recalculateBasket(currentBasket);
    }
}