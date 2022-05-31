public with sharing class GDB_HeaderCartController {

    /**
     * getBasketLineItemQuantities() Returns how many item are in the basket.
     * @param {Map<String, Object>} guest
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> getCustomerDetails(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        Boolean authenticated = GDB_AccountMgr.isAuthenticated();
        Map<String, String> customerDetails = new Map<String, String>{
            'authenticated' => String.valueOf(authenticated),
            'quantities' => String.valueOf(GDB_BasketMgr.getBasketLineItemQuantities())
        };
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
            'basketURL' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1)),
            'logoutURL' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(7), false)
        };
    }
}