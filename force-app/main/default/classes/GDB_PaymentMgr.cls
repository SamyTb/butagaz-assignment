public with sharing class GDB_PaymentMgr {
    /**
     * getPaymentMethods Returns the list of available payment methods
     *
     * @return {List<GDB_Payment_Method__c>}
     */
    public static List<GDB_Payment_Method__c> getPaymentMethods() {
        return [
            SELECT
            Name, gdb_isMethodPaymentDisplayed__c
            FROM GDB_Payment_Method__c
            WHERE gdb_isMethodPaymentDisplayed__c = true
        ];
    }

    /**
     * getPaymentMethodById Return the payment method that matchs with the given {id}
     * @param {Id} id
     *
     * @return {GDB_Payment_Method__c}
     */
    public static GDB_Payment_Method__c getPaymentMethodById(Id id) {
        if(id == null) {
            return null;
        }

        List<GDB_Payment_Method__c> paymentMethods = [
            SELECT
            Name
            FROM GDB_Payment_Method__c
            WHERE Id = :id
        ];

        if(paymentMethods != null && paymentMethods.size() == 1) {
            return paymentMethods.get(0);
        }

        return null;
    }

    /**
     * updatePaymentMethod Update the payment method for the current basket with the given payment method ID
     *
     * @param {Id} paymentMethodId
     * @param {Boolean} multiplePayment
     */
    public static void updatePaymentPreferences(Id paymentMethodId, Boolean multiplePayment) {
        if(paymentMethodId == null) {
            return;
        }

        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return;
        }

        basket.gdb_Payment_Method__c = paymentMethodId;
        basket.gdb_multiple_payment__c = multiplePayment;
        GDB_BasketMgr.recalculateBasket(basket);
    }
}