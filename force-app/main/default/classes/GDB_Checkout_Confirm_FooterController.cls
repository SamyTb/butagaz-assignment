public with sharing class GDB_Checkout_Confirm_FooterController { 
    /**
     * getCurrentOrder Return the current Order
     *
     * @returns{Map<String, Object>}
     *
     **/
    @AuraEnabled
    public static Map<String, Object> getCurrentOrder() {
        Order__c o = GDB_OrderMgr.getCurrentOrder();
        if(o == null) { return null; }
        
        Map<String, Object> orderMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
        orderMap.put('bvDeploymentZone', GDB_Constants.bvDeploymentZone);
        
        return orderMap;
    }

    /**
     * getHomeURLAction Return the home URL
     *
     * @returns{String}
     *
     **/
    @AuraEnabled
    public static String getHomeURLAction() {
        return GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, '');
    }
    
    /**
     * getHomeURLActionB2B Return the home URL B2B
     *
     * @returns{String}
     *
     **/
    @AuraEnabled
    public static String getHomeURLActionB2B() {
        return GDB_Utils_B2B.getUrlWithPathPrefix('');        
    }
    
    /**
     * getCurrentAccount Return the current account
     *
     * @returns{Account}
     *
     **/
    @AuraEnabled
    public static Account getCurrentAccount() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    /**
     * getGoogleAnalyticsTrackingForOrder Return the Google Analytics Tracking For Order
     *
     * @returns{String}
     *
     **/
    @AuraEnabled
    public static String getGoogleAnalyticsTrackingForOrder() { 
        return GDB_OrderMgr.getGoogleAnalyticsTrackingForOrder();
    }
}