public with sharing class GDB_HeaderLogoutController_B2B {
    
     /**
     * getCustomerDetails() Returns Customer Details.
     *
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> getCustomerDetails() {
        Boolean authenticated = GDB_AccountMgr.isAuthenticated();        
        Map<String, String> customerDetails = new Map<String, String>();
        customerDetails.put('authenticated', String.valueOf(authenticated));        
        return customerDetails;
    }

    /**
     * getURLs Return the URLs needed in the Header cart template
     *
     * @return {Map<String, String>}
     **/
    @AuraEnabled
    public static Map<String, String> getURLs() {
        return new Map<String, String>{           
            'logoutURL' => GDB_Utils_B2B.getCommunityUrlPathPrefix(false) + GDB_Constants_B2B.pagesURLsB2B.get(4)
        };
    }
}