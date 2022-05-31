public with sharing class GDB_MyAccount_MyDetailsController {
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableListValues() {
        return new Map<String, List<Map<String, String>>>{
            'billingCountries' => GDB_CheckoutUtils.getAvailableBillingCountries(),
            'shippingCountries' => GDB_CheckoutUtils.getAvailableShippingCountries(),
            'billingSalutations' => GDB_CheckoutUtils.getAvailableBillingSalutations(),
            'shippingSalutations' => GDB_CheckoutUtils.getAvailableShippingSalutations(),
            'accountSalutations' => GDB_CheckoutUtils.getAvailableAccountSalutations()
        };
    }

    @AuraEnabled
    public static Map<String, String> saveCredentials(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveCredentials(detailsForm);
    }

    @AuraEnabled
    public static Map<String, String> saveShippingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveShippingAddress(addressForm);
    }

    @AuraEnabled
    public static Map<String, String> saveBillingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveBillingAddress(addressForm);
    }

    @AuraEnabled
    public static Map<String, String> saveSalutation(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveSalutation(detailsForm);
    }

    @AuraEnabled
    public static Map<String, String> savePhone(Map<String, String> detailsForm) {
        return GDB_AccountMgr.savePhone(detailsForm);
    }

    @AuraEnabled
    public static Map<String, String> saveOptins(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveOptins(detailsForm);
    }

    @AuraEnabled
    public static Map<String, String> saveEmail(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveEmail(detailsForm);
    }
}