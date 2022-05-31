public with sharing class GDB_MyAccount_MyAddressesController {
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableListValues() {
        return new Map<String, List<Map<String, String>>>{
            'billingCountries' => GDB_CheckoutUtils.getAvailableAccountCountries(),
            'shippingCountries' => GDB_CheckoutUtils.getAvailableShippingCountries()
        };
    }

    @AuraEnabled
    public static Map<String, String> saveShippingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveShippingAddress(addressForm);
    }

    @AuraEnabled
    public static Map<String, String> saveBillingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveBillingAddress(addressForm);
    }
}