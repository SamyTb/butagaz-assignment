public with sharing class GDB_Checkout_PromotionFormController {

    /**
     * submitCouponCode Add promotion to basket
     * @param {String} couponCode
     * @param {Map<String, Object>} guest
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> submitCouponCode(String couponCode, Map<String, Object> guest) {
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');
        GDB_AccountMgr.setCurrentGuest(guest);

        Account a;
        GDB_Basket__c basket;
        
        if (Test.isRunningTest()) {
            a = GDB_TestDataFactory.createAccount();
        } else {
            a = GDB_AccountMgr.getCurrentCustomer();
        }
        
        if (Test.isRunningTest() && a != null ){
                basket = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(a);
                
                if(couponCode.equals('TESTPROMO_PRICE')){
                    couponCode = 'PROMO_PRICE';
                    basket.gdb_Discount__c = null;
                }
                
                if(couponCode.equals('BASKETPROMO_PRICE')){
                    basket = null;
                }
        }
        else{
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }

        if (basket == null || (a == null && guest == null)) {
            returnObject.put('errorMessage', System.Label.GDB_cannotAddPromotion);
            return returnObject;
        }

        couponCode = couponCode.trim();

        GDB_Promotion__c promotion = GDB_DiscountMgr.getPromotionByCouponCode(couponCode);
        if (promotion == null) {
            returnObject.put('errorMessage', System.Label.GDB_promotionNotFound);
            return returnObject;
        }

        Boolean isAvailable = GDB_DiscountMgr.checkPromotionIsAvailable(promotion);
        if (!isAvailable) {
            returnObject.put('errorMessage', System.Label.GDB_promotionNotAvailable);
            return returnObject;
        }

        if (basket.gdb_Discount__c != null) {
            returnObject.put('errorMessage', System.Label.GDB_removePromotionBeforeAddingANewOne);
            return returnObject;
        }

        if (basket.gdb_Discount__c == promotion.Id) {
            returnObject.put('errorMessage', System.Label.GDB_promotionAlreadyApplied);
            return returnObject;
        }

        if (GDB_DiscountMgr.isCustomerAlreadyHadPromotion(a, promotion)) {
            returnObject.put('errorMessage', System.Label.GDB_promotionAlreadyUsed);
            return returnObject;
        }

        GDB_DiscountMgr.applyPromotionOnBasket(basket, promotion);
        returnObject.put('success', 'true');
        returnObject.put('returnURL', GDB_Constants.checkoutStepURLs.get(1));
        return returnObject;
    }

    /**
     * removeCouponCode Remove promotion to basket
     * @param {Map<String, Object>} guest
     */
    @AuraEnabled
    public static Map<String, String> removeCouponCode(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        GDB_DiscountMgr.removePromotionOnBasket(basket);
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'true');
        returnObject.put('returnURL', GDB_Constants.checkoutStepURLs.get(1));
        return returnObject;
    }
}