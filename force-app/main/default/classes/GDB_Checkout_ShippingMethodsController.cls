public without sharing class GDB_Checkout_ShippingMethodsController {

    /**
     * getShippingMehtods Returns the list of available shipping methods
     * @return {List<GDB_Shipping_Method__c>}
     */
    @AuraEnabled
    public static List<GDB_Shipping_Method__c> getShippingMethods(GDB_Basket__c basket) {
        return GDB_ShippingMgr.getShippingMethods(basket);
    }

    /**
     * updateShippingMethods Update the shipping method for the current basket with the given shipping method ID
     * @param {GDB_Basket__c} basket
     * @param {String} shippingMethodId
     * @return {GDB_Basket__c}
     */
    @AuraEnabled
    public static GDB_Basket__c updateShippingMethods(GDB_Basket__c basket, String shippingMethodId) {
        return GDB_ShippingMgr.updateShippingMethods(basket, shippingMethodId);
    }

    /**
     * updateShippingOptions Update the shipping option for the current basket with the given shipping option map
     * @param {GDB_Basket__c} basket
     * @param {List<String>} mapCheckbox
     * @return {GDB_Basket__c}
     */
    @AuraEnabled
    public static GDB_Basket__c updateShippingOptions(GDB_Basket__c basket, List<String> shippingOptionsIds) {
        return GDB_ShippingMgr.updateShippingOptions(basket, shippingOptionsIds);
    }
}