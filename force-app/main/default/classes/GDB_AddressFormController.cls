public with sharing class GDB_AddressFormController {
    @AuraEnabled
    public static List<Map<String, String>> getAvailableCountries(String fromObject) {
        if(fromObject == 'Account') {
            return GDB_CheckoutUtils.getAvailableAccountCountries();
        } else if(fromObject == 'BasketShipping' || fromObject == 'OrderShipping') {
            return GDB_CheckoutUtils.getAvailableShippingCountries();
        } else if(fromObject == 'BasketBilling' || fromObject == 'OrderBilling') {
            return GDB_CheckoutUtils.getAvailableBillingCountries();
        }

        return null;
    }

    @AuraEnabled
    public static List<String> getAvailableCities(String zipCode) {
        return GDB_AddressMgr.getCitiesForZipCode(zipCode);
    }

    @AuraEnabled
    public static Boolean saveCurrentZipCode(String zipCode){
        return GDB_BasketMgr.updateZipCodeShipping(zipCode);
    }
}