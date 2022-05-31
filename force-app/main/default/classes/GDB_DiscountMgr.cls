public without sharing class GDB_DiscountMgr {

    /**
     * getFirstApplicablePromotion Return the first applicable promotion that can be added to the basket without coupon code
     *
     * @return {GDB_Promotion__c}
     */
    public static GDB_Promotion__c getFirstApplicablePromotion(Account a) {
        DateTime now = DateTime.now();

        List<GDB_Promotion__c> promotions = [
            SELECT
            Name,
            gdb_coupon_code__c,
            gdb_start_date__c,
            gdb_end_date__c,
            gdb_status__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c,
            gdb_min_shipping_price__c
            FROM GDB_Promotion__c
            WHERE gdb_status__c = true
            AND gdb_coupon_code__c = NULL
            AND (gdb_start_date__c = NULL OR gdb_start_date__c < :now)
            AND (gdb_end_date__c = NULL OR gdb_end_date__c > :now)
            AND (gdb_numberOfTotalUse__c > 0 OR gdb_numberOfTotalUse__c = -1)   // -1 = unlimited use
        ];

        if(promotions != null && promotions.size() > 0) {
            // If the account is null, returns the first found promotion
            if (a == null) {
                return promotions.get(0);
            }

            for(GDB_Promotion__c p : promotions) {
                // Return the first available promotion
                if (GDB_DiscountMgr.isCustomerAlreadyHadPromotion(a, p)) {
                    return p;
                }
            }
        }

        return null;
    }

    /**
     * isCustomerAlreadyHadPromotion Check if the customer already pass an order with the given discount
     *
     * @param {GDB_Promotion__c} discount
     *
     * @returns {Boolean}
     *
     **/
    public static Boolean isCustomerAlreadyHadPromotion(Account account, GDB_Promotion__c discount) {
        if (account == null || discount == null) {
            return false;
        }

        Integer maximumOfRows = Integer.valueOf(discount.gdb_numberOfUsePerUser__c);
        if (maximumOfRows == null) {
            maximumOfRows = GDB_CustomSettingsMgr.self().getMaximumUseOfPromotionPerUser() != null ? GDB_CustomSettingsMgr.self().getMaximumUseOfPromotionPerUser() : 1;
        }

        Integer junctionRows = [
            SELECT
            COUNT()
            FROM
            GDB_Account_Has_Promotion__c
            WHERE
            gdb_Account__c = :account.Id
            AND gdb_Promotion__c = :discount.Id
        ];

        return junctionRows >= maximumOfRows;
    }

    /**
     * getPromotionById Return the promotion that matchs with the given {id}
     *
     * @param {Id} id
     *
     * @return {GDB_Promotion__c}
     */
    public static GDB_Promotion__c getPromotionById(Id id) {
        if(id == null) {
            return null;
        }

        DateTime now = DateTime.now();

        List<GDB_Promotion__c> promotions = [
            SELECT
            Name,
            gdb_coupon_code__c,
            gdb_start_date__c,
            gdb_end_date__c,
            gdb_status__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c,
            gdb_min_shipping_price__c
            FROM GDB_Promotion__c
            WHERE Id = :id
            AND gdb_status__c = true
            AND (gdb_start_date__c = NULL OR gdb_start_date__c < :now)
            AND (gdb_end_date__c = NULL OR gdb_end_date__c > :now)
            AND (gdb_numberOfTotalUse__c > 0 OR gdb_numberOfTotalUse__c = -1)   // -1 = unlimited use
        ];

        if(promotions != null && promotions.size() == 1) {
            return promotions.get(0);
        }

        return null;
    }


    /**
     * getPromotionByCouponCode Return the promotion that matchs with the given {couponCode}
     *
     * @param {String} couponCode
     *
     * @return {GDB_Promotion__c}
     */
    public static GDB_Promotion__c getPromotionByCouponCode(String couponCode) {
        if(couponCode == null) {
            return null;
        }

        DateTime now = DateTime.now();

        List<GDB_Promotion__c> promotions = [
            SELECT
            Name,
            gdb_coupon_code__c,
            gdb_start_date__c,
            gdb_end_date__c,
            gdb_status__c,
            gdb_target__c,
            gdb_type__c,
            gdb_value__c,
            gdb_numberOfUsePerUser__c,
            gdb_numberOfTotalUse__c,
            gdb_article__c,
            gdb_article_type__c,
            gdb_shipping_method__c,
            gdb_shipping_option__c,
            gdb_quantite_min_article_ou_type_article__c,
            gdb_quantite_min_du_panier__c,
            gdb_min_shipping_price__c
            FROM GDB_Promotion__c
            WHERE gdb_coupon_code__c = :couponCode
            AND gdb_status__c = true
            AND (gdb_start_date__c = NULL OR gdb_start_date__c < :now)
            AND (gdb_end_date__c = NULL OR gdb_end_date__c > :now)
            AND (gdb_numberOfTotalUse__c > 0 OR gdb_numberOfTotalUse__c = -1)   // -1 = unlimited use
        ];

        if(promotions != null && promotions.size() == 1) {
            return promotions.get(0);
        }

        return null;
    }

    /**
     * applyDiscountOnBasket Apply the given promotion on the given basket
     *
     * @param {GDB_Basket__c} basket
     * @param {GDB_Promotion__c} promotion
     */
    public static void applyPromotionOnBasket(GDB_Basket__c basket, GDB_Promotion__c promotion) {
        if(basket == null) {
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }
        Account a = GDB_AccountMgr.getCurrentCustomer();

        // If the basket is null
        // Or the promotion is null
        // Or the account is not null and the customer already pass an order with this promotion
        // Skip the method and don't apply the promotion
        if (basket == null
        || promotion == null
        || (a != null && GDB_DiscountMgr.isCustomerAlreadyHadPromotion(a, promotion))) {
            return;
        }

        Decimal discountPrice = 0;

        // Promotion to apply on the shipping price
        if (promotion.gdb_target__c == 'Shipping' && basket.gdb_shipping_method_price__c != null && basket.gdb_shipping_method_price__c >= 0) {
            discountPrice = GDB_DiscountMgr.applyPromotionTypeOnValue(promotion.gdb_type__c, basket.gdb_shipping_method_price__c, promotion.gdb_value__c);
        }

        if (discountPrice >= 0) {
            basket.gdb_Discount__c = promotion.Id;
            basket.gdb_discount_name__c = promotion.Name;
            basket.gdb_coupon_code__c = promotion.gdb_coupon_code__c;
            basket.gdb_discount_price__c = discountPrice;
            if(basket.gdb_shipping_method_price__c != null && basket.gdb_shipping_method_price__c > 0) { 
                basket.gdb_discount_tax__c = (discountPrice * basket.gdb_shipping_method_tax__c) / basket.gdb_shipping_method_price__c;
            }

            update basket;
        }
    }

    /**
     * applyPromotionTypeOnValue Apply the given promotion value on the given value based on the given promotion type
     *
     * @param {String} type
     * @param {Decimal} value
     * @param {Decimal} promotionValue
     *
     * @return {Decimal}
     */
    private static Decimal applyPromotionTypeOnValue(String type, Decimal value, Decimal promotionValue) {
        if(value == null || promotionValue == null || type == null) {
            return 0;
        }

        if(type == 'Percentage') { // Apply a percentage of the price
            return (value * (promotionValue / 100));
        } else if(type == 'Price') { // Apply a value on the price
            return (value - promotionValue < 0) ? 0 : promotionValue;
        }

        return 0;
    }

    /**
     * removePromotionOnBasket Remove the coupon code to the basket and recalculate it
     *
     * @param {GDB_Basket__c} basket
     */
    public static void removePromotionOnBasket(GDB_Basket__c basket) {
        if(basket == null) {
            return;
        }
        
        Id promoId = basket.gdb_Discount__c;

        basket.gdb_Discount__c = null;
        basket.gdb_discount_name__c = '';
        basket.gdb_coupon_code__c = '';
        basket.gdb_discount_price__c = 0;
        basket.gdb_discount_tax__c = 0;
        
        update basket;

        GDB_BasketMgr.recalculateBasket(basket);

    }

    /**
     * decreaseTotalUses Decrease the number of total uses for the coupon code
     *
     * @param {Id} promoId
     */
    public static void decreaseTotalUses(Id promoId) {
        if(promoId != null
        && String.isNotBlank(promoId)) {
            List<GDB_Promotion__c> promotions = [SELECT Id, gdb_numberOfTotalUse__c FROM GDB_Promotion__c WHERE Id = :promoId];
            if(promotions.size() > 0
            && promotions.get(0).gdb_numberOfTotalUse__c != null
            && promotions.get(0).gdb_numberOfTotalUse__c >= 0) {
                promotions.get(0).gdb_numberOfTotalUse__c--;
                update promotions.get(0);
            }
        }
    }

    /**
     * checkPromotionIsAvailable check if the promotion is avaible for the currentDecrease the number of total uses for the coupon code
     *
     * @param {Id} promoId
     */
    public static Boolean checkPromotionIsAvailable(GDB_Promotion__c promotion) {
        return checkPromotionIsAvailable(promotion, null);
    }

    /**
     * checkPromotionIsAvailable check if the promotion is avaible for the currentDecrease the number of total uses for the coupon code
     *
     * @param {Id} promoId
     */
    public static Boolean checkPromotionIsAvailable(GDB_Promotion__c promotion, GDB_Basket__c basket) {
        if(promotion == null){
            return false;
        }

        if(basket == null) {
            // Get the current basket with his article
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }

        // Return false because the current basket have zero article or null
        if(basket == null || basket.Basket_Products__r == null || basket.Basket_Products__r.size() == 0 
            || (promotion.gdb_min_shipping_price__c != null && (basket.gdb_shipping_method_price__c + basket.gdb_shipping_option_price__c) < promotion.gdb_min_shipping_price__c)){
            return false;
        }

        // Check if article is correct
        if(promotion.gdb_article__c != null){

            // check if gdb_Article__c is on the current basket
            Boolean articleIsOnBasket = false;
            Decimal articleQuantity = 0;
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r){
                if(bp.gdb_Article__c == promotion.gdb_Article__c){
                    articleIsOnBasket = true;
                    articleQuantity = bp.gdb_quantity__c;
                }
            }

            // Return false because article not present on current basket
            if(!articleIsOnBasket){
                return false;
            }

            // Check if Quantity min article is correct
            if(promotion.gdb_quantite_min_article_ou_type_article__c != null && promotion.gdb_quantite_min_article_ou_type_article__c != 0){
                // Return false because article quantity not enough on current basket
                if(promotion.gdb_quantite_min_article_ou_type_article__c > articleQuantity){
                    return false;
                }
            }
        }

        // Check if type article is correct
        if(promotion.gdb_article_type__c != null){

            // check if gdb_Article__c is on the current basket
            Boolean articleTypeIsOnBasket = false;
            Decimal articleTypeQuantity = 0;
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r){
                if(bp.gdb_Article__r.gdb_item_type__c == promotion.gdb_article_type__c){
                    articleTypeIsOnBasket = true;
                    articleTypeQuantity += bp.gdb_quantity__c;
                }
            }

            // Return false because article not present on current basket
            if(!articleTypeIsOnBasket){
                return false;
            }

            // Check if Quantity min article is correct
            if(promotion.gdb_quantite_min_article_ou_type_article__c != null && promotion.gdb_quantite_min_article_ou_type_article__c != 0){
                // Return false because article quantity not enough on current basket
                if(promotion.gdb_quantite_min_article_ou_type_article__c > articleTypeQuantity){
                    return false;
                }
            }
        }

        // Check if shipping method is correct
        if(promotion.gdb_shipping_method__c != null){
            
            // Return false because the current basket have no shipping method
            if(basket.gdb_Shipping_Method__c == null ){
                return false;
            }

            // Return false because the current shipping method is not correct
            if(basket.gdb_Shipping_Method__c != promotion.gdb_shipping_method__c){
                return false;
            }
        }

        // Check if shipping option is correct
        if(promotion.gdb_shipping_option__c != null){

            // check if gdb_Shipping_Option__c is on the current basket
            Boolean shippingOptionIsOnBasket = false;
            for(gdb_basket_shipping_option__c bso : basket.Baskets_Shippings_options__r){
                if(bso.gdb_Shipping_Option__c == promotion.gdb_shipping_option__c){
                    shippingOptionIsOnBasket = true;
                }
            }

            // Return false because shipping option not present on current basket
            if(!shippingOptionIsOnBasket){
                return false;
            }
        }

        // Check if Quantity min of basket is correct
        if(promotion.gdb_quantite_min_du_panier__c != null && promotion.gdb_quantite_min_du_panier__c != 0){

            // check quantity on the current basket
            Decimal basketQuantity = 0;
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r){
                basketQuantity += bp.gdb_quantity__c;
            }

            // Return false because basket quantity not enough on current basket
            if(promotion.gdb_quantite_min_du_panier__c > basketQuantity){
                return false;
            }
        }

        // Check if current customer use his own code 
        if(GDB_AccountMgr.isAuthenticated()){
            Account currentAccount = GDB_AccountMgr.getCurrentCustomer();
            String couponCode = promotion.gdb_coupon_code__c;
                if(currentAccount != null 
                && (currentAccount.gdb_parrainage_code__c == couponCode 
                    || (couponCode.startsWith('PAR') && currentAccount.GDB_nb_gdb_order__c != 0))) {
                    return false;
                }
        }

        return true;
    }

    /**
     * createSponsorshipDiscount Create sponsorship discount related to new account
     * @param  accounts accounts description
     */
     @InvocableMethod(label='Create Sponsorship Discount')
    public static void createSponsorshipDiscount(List<Account> GDBaccounts){
        List<GDB_Promotion__c> newSponsorshipDiscounts = new List<GDB_Promotion__c>();
        for(Account acc : GDBaccounts) {
            GDB_Promotion__c promotion = new GDB_Promotion__c();
            promotion.Name = acc.gdb_parrainage_code__c;
            promotion.gdb_coupon_code__c = acc.gdb_parrainage_code__c;
            promotion.gdb_end_date__c = GDB_CustomSettingsMgr.self().getSponsorshipMaxEndDate();
            promotion.gdb_numberOfTotalUse__c = 10;
            promotion.gdb_numberOfUsePerUser__c = 1;
            promotion.gdb_start_date__c = DateTime.now();
            promotion.gdb_status__c = true;
            promotion.gdb_target__c = 'Shipping';
            promotion.gdb_type__c = 'Price';
            promotion.gdb_value__c = GDB_CustomSettingsMgr.self().getSponsorshipPrice();
            promotion.gdb_min_shipping_price__c = GDB_CustomSettingsMgr.self().getSponsorshipShippingMinimumPrice();
            newSponsorshipDiscounts.add(promotion);
        }
        if(newSponsorshipDiscounts != null && !newSponsorshipDiscounts.isEmpty()) {
            insert newSponsorshipDiscounts;
        }
    }


}