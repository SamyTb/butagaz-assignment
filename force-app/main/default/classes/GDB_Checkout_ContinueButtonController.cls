public with sharing class GDB_Checkout_ContinueButtonController {
    /**
     * submitContinueButton Returns the next URL
     *
     * @param  step Step in the checkout process
     * @param {Map<String, String>} guest
     *
     * @return  {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> submitContinueButton(Integer step, Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        Map<String, String> returnObject = GDB_CheckoutUtils.getNextCheckoutStepURL(Integer.valueOf(step));

        if('4'.equals(returnObject.get('step')) && 'true'.equals(returnObject.get('success'))) {
            Order__c o = GDB_OrderMgr.createOrder(GDB_BasketMgr.getCurrentBasket(false));
        }

        if('5'.equals(returnObject.get('step')) && 'true'.equals(returnObject.get('success')) && 'true'.equals(returnObject.get('isBasketB2B'))) {
            Order__c o = GDB_OrderMgr.createOrderB2B(GDB_BasketMgr.getCurrentBasket(false));
        }

        return returnObject;
    }

    /**
     * getPSPRedirectionDetails Call the PSP with the current order No details and return the PSP details
     *
     * @param {Integer} step
     * @param {String} orderNo
     *
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, Object> getPSPRedirectionDetails() {
        Map<String, Object> returnObject = new Map<String, Object>();

        Order__c o = GDB_OrderMgr.getCurrentOrder();
        Account a = GDB_AccountMgr.getCurrentCustomer();
        if(o == null || a == null) {
            return returnObject;
        }

        GDB_Mercanet mercanetHelper = new GDB_Mercanet();
        mercanetHelper.setReturnUrl(GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(4), false));
        mercanetHelper.prepareParameters(o.gdb_total_gross_price__c, 'EUR', o.Order_Date_and_Time__c, o.gdb_orderNo__c, a.gdb_accountNo__c, o.gdb_multiple_payment__c, a.PersonEmail);
        GDB_Mercanet.Response response = mercanetHelper.executeRequest();

        if (response != null && response.isValid()) {
            returnObject.put('redirectionUrl', response.getRedirectionUrl());
            returnObject.put('redirectionVersion', response.getRedirectionVersion());
            returnObject.put('redirectionData', response.getRedirectionData());
            returnObject.put('redirectionStatusCode', response.getRedirectionStatusCode());
            returnObject.put('redirectionStatusMessage', response.getRedirectionStatusMessage());
        } else {
            // Else, fail the order and create a new one
            GDB_OrderMgr.failOrder(o,'');
            returnObject.put('redirectionUrl', GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(3)) + '?paymenterror=true');
        }
        return returnObject;
    }

    /**
     * isAuthenticated Return true if customer is authenticated
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isAuthenticated() {
        return GDB_AccountMgr.isAuthenticated();
    }

    /**
     * getPreviousStepsURLs List of previous steps urls
     * @return {<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> getPreviousStepsURLs() {
        return new Map<String, String>{
            'step1' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1)) ,
            'step15' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(15)) ,
            'step2' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(2))
        };
    }

    /**
     * redirectToCart Redirect the logged user to cart to prevent view login page
     * @return {String}
     */
    @AuraEnabled
    public static String redirectToCart(Boolean redirect) {
        try{
            if(GDB_AccountMgr.isAuthenticated() && redirect) {
                PageReference page = new PageReference(GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1)));
                if(!Test.isRunningTest()) {
                    aura.redirect(page);
                }
            }
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    public static Boolean getReturnForTest(Boolean b) {
        if(b){
           b = false;
        }
        else{
            b = true;
        }

        return b;
    }

}