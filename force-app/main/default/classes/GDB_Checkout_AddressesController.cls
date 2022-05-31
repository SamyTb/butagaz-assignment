public with sharing class GDB_Checkout_AddressesController { 
    
    /**
     * getCurrentBasket Returns the basket current
     *
     *
     * @returns{GDB_Basket__c}
     *
     **/
    @AuraEnabled
    public static GDB_Basket__c getCurrentBasket() {
        return GDB_BasketMgr.getCurrentBasket(false);
    }

    /**
     * getAvailableListValues Returns the list of available value for address
     *
     * @param {String} shippingFormID
     * @param {String} billingFormID
     * @returns{Map<String, List<Map<String, String>>>}
     *
     **/
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableListValues(String shippingFormID, String billingFormID) {
        return new Map<String, List<Map<String, String>>>{
            'shippingCountries' => GDB_CheckoutUtils.getAvailableShippingCountries(),
            'billingCountries' => GDB_CheckoutUtils.getAvailableAccountCountries(),
            'shippingSalutations' => GDB_CheckoutUtils.getAvailableShippingSalutations(),
            'billingSalutations' => GDB_CheckoutUtils.getAvailableBillingSalutations()
        };
    }

    /**
     * getAddressFields Returns the fields address
     *
     * @returns{Map<String, Map<String, String>>}
     *
     **/
    @AuraEnabled
    public static Map<String, Map<String, String>> getAddressFields() {
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        if(basket == null) {
            return null;
        }

        return new Map<String, Map<String, String>>{
            'shippingFields' => GDB_BasketMgr.getShippingAddressAsMap(),
            'billingFields' => GDB_BasketMgr.getBillingAddressAsMap()
        };
    }

    /**
     * saveShippingAndBilling Save the shipping and Billing Address
     *
     * @param {Map<String, String>} shippingForm
     * @param {Map<String, String>} billingForm
     * @param {String} shippingInstructions
     * @param {Boolean} useShippingAsBilling
     * @returns{Boolean}
     *
     **/
    @AuraEnabled
    public static Boolean saveShippingAndBilling(Map<String, String> shippingForm, Map<String, String> billingForm, String shippingInstructions, Boolean useShippingAsBilling) {
        return GDB_BasketMgr.updateAddresses(shippingForm, billingForm, shippingInstructions, useShippingAsBilling);
    }
    
    /**
     * saveShipping Save the shipping Address
     *
     * @param {Map<String, String>} shippingForm
     * @param {String} shippingInstructions
     * @returns{Boolean}
     *
     **/
    @AuraEnabled
    public static Boolean saveShipping(Map<String, String> shippingForm, String shippingInstructions) { 
        return GDB_BasketMgr.updateAddressShipping(shippingForm, shippingInstructions);
    }
    
    /**
     * getCurrentCustomer return the Account current
     *          
     * @returns{Account}
     *
     **/
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer(); 
    }
    
    /**
     * getCurrentAccountREByContract return the Account RE associated by contract current
     *          
     * @returns{Account}
     *
     **/
    @AuraEnabled
    public static Account getCurrentAccountREByContract() {
        return GDB_AccountMgr.getCurrentAccountREByContract(); 
    }
}