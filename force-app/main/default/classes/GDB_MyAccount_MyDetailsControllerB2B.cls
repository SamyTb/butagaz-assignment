public with sharing class GDB_MyAccount_MyDetailsControllerB2B {
    
    /**
     * getCurrentCustomer Return account for the current customer
     *
     * @return {Account}
     */
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer(); 
    }
    
    /**
     * getCurrentAccountREByContract Return account type RE for the current customer
     *
     * @return {Account}
     */
    @AuraEnabled
    public static Account getCurrentAccountREByContract() {
        return GDB_AccountMgr.getCurrentAccountREByContract(); 
    }
    
    /**
     * getAvailableListValues Return the available List of Values
     *
     * @return {Map<String, List<Map<String, String>>>}
     */
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

    /**
     * saveCredentials Save the Credentials
     *
     * @param {Map<String, String>} 
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveCredentials(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveCredentials(detailsForm);
    }

    /**
     * saveShippingAddress Save the Shipping Address
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveShippingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveShippingAddress(addressForm);
    }

    /**
     * saveBillingAddress Save the Billing Address
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveBillingAddress(Map<String, String> addressForm) {
        return GDB_AccountMgr.saveBillingAddress(addressForm);
    }

    /**
     * saveSalutation Save the Salutation
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveSalutation(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveSalutationB2B(detailsForm);
    } 

    /**
     * savePhone Save the phone number
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> savePhone(Map<String, String> detailsForm) {
        return GDB_AccountMgr.savePhone(detailsForm);
    }

    /**
     * saveOptins Save the Options
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveOptins(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveOptins(detailsForm);
    }

    /**
     * saveEmail Save the email address
     *
     * @param {Map<String, String>}
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> saveEmail(Map<String, String> detailsForm) {
        return GDB_AccountMgr.saveEmailB2B(detailsForm);
    }
}