public with sharing class GDB_HeaderLogoController {

    /**
     * getHomePage Returns homepage URL 
     * @return {String}
     */
    @AuraEnabled
    public static String getHomePage() {
        return GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, '');
    }
    
    /**
     * getHomePage Returns homepage URL for B2B
     * @return {String}
     */
    @AuraEnabled
    public static String getHomePageB2B() {
        return GDB_Utils_B2B.getUrlWithPathPrefix('');
    }
}