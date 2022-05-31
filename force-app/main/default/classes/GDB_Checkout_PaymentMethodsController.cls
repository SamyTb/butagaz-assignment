public with sharing class GDB_Checkout_PaymentMethodsController {
    /**
     * getPaymentMethodDetails Return the Payment Method Details
     *
     * @returns{Map<String, Object>}
     *
     **/
    @AuraEnabled
    public static Map<String, Object> getPaymentMethodDetails() {
        Map<String, Object> returnObject = new Map<String, Object>();

        returnObject.put('paymentMethods', GDB_PaymentMgr.getPaymentMethods());
        returnObject.put('paymentTimes', GDB_CustomSettingsMgr.self().getMercanetPaymentTimes());
        returnObject.put('multiplePaymentThreshold', GDB_CustomSettingsMgr.self().getMultiplePaymentThreshold());
        returnObject.put('paymentTimesPrice', GDB_CustomSettingsMgr.self().getMercanetPaymentTimesPrice());

        return returnObject;
    }

    /**
     * updateMultiplePaymentPrice : update multiple payment price when changing multiple payment selection
     */
     @AuraEnabled
    public static void updateMultiplePaymentPrice(Boolean isMultiplePayment) {
        GDB_BasketMgr.updateMultiplePaymentPrice(isMultiplePayment);
    }

    /**
     * getCurrentBasket Get the current basket
     * @return   {GDB_Basket__c}
     */
    @AuraEnabled
    public static GDB_Basket__c getCurrentBasket() {
        return GDB_BasketMgr.getCurrentBasket(false);
    }
}