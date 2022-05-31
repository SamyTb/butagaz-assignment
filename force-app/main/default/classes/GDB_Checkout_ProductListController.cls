public with sharing class GDB_Checkout_ProductListController {
    /**
     * getCurrentBasket Returns the current basket
     * @param {Map<String, Object>} guest
     * @returns{GDB_Basket__c}
     **/
    @AuraEnabled
    public static GDB_Basket__c getCurrentBasket(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        return GDB_BasketMgr.getCurrentBasket(false);
    }

    @AuraEnabled
    public static Map<String, String> verifyStock(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        return GDB_CheckoutUtils.verifyStock(null);
    }

    @AuraEnabled
    public static Order__c getCurrentOrder() {
        return GDB_OrderMgr.getCurrentOrder();
    }

    @AuraEnabled
    public static void saveQuantity(String lineItemId, String quantity, Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        GDB_BasketMgr.updateLineItemQuantity(Id.valueOf(lineItemId), Integer.valueOf(quantity));
    }
    
    /**
     * getSampleInfos Returns url Sample and CodeArtcile
     *
     *
     * @return {Map<String, String>}
     */
    @AuraEnabled 
    public static Map<String, String> getSampleInfos() {
        Map<String, String> ret = new Map<String, String>();
        
        ret.put('sampleURL', GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(12)));
        ret.put('sampleCode', GDB_Constants.articleCode.get(1));
                
        return ret;
    }
    
    
     /**
     * getGuestBasketErrorsAction Returns errors list of guest basket merged
     * @param {List<Object>} errors
     * @return {List<Map<String, String>>}
     */
    @AuraEnabled
    public static List<Map<String, String>> getGuestBasketErrorsAction(List<Object> errors) {
        List<Map<String, String>> errorList = new List<Map<String, String>>();
        for(Object err : errors) 
        {
            Integer errno;
            String message;
            Map<String, Object> error = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(err));
            if(error.containsKey('errno')
            && error.get('errno') != null) {
                errno = Integer.valueOf(String.valueOf(error.get('errno')));
                if(GDB_Constants.mergeGuestBasketErrors.containsKey(errno)) {
                    message =  GDB_Constants.mergeGuestBasketErrors.get(errno);
                    if(error.containsKey('params')
                    && error.get('params') != null) {
                        List<String> params = (List<String>) JSON.deserialize(JSON.serialize(error.get('params')), List<String>.class);
                        message = String.format(message, params);
                    }
                }
            }

            errorList.add(new Map<String, String>{
                'message' => message,
                'backToCart' => errno == 30 ? GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1)) : null
            });
        }
        return errorList;
    }
    
    /**
     * getHomePage Returns homepage URL 
     * @return {String}
     */
    @AuraEnabled
    public static String getHomePage() {
        return GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, '');
    }
}