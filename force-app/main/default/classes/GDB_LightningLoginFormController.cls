public with sharing class GDB_LightningLoginFormController {

    public GDB_LightningLoginFormController() {

    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        if (Test.isRunningTest()) {
            AuthConfig ac = [Select Url, Id from AuthConfig ORDER BY CreatedDate ASC LIMIT 1];
            Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(ac.Url,'');
            return authConfig;
        }
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    /**
     * redirectUser Redirect the user if he is already authenticated
     *
     **/
    @AuraEnabled
    public static void redirectUser(String startUrl) {
        if(GDB_AccountMgr.isAuthenticated()) {
            String url = startUrl == '' ? GDB_Utils.getCommunityURLFromName(GDB_Constants.communityName, true) : GDB_Utils.getCommunityURLFromNameWithoutPrefix(GDB_Constants.communityName) + startUrl;
            PageReference page = new PageReference(url);
            if (!Test.isRunningTest()) {
                aura.redirect(page);
            }
        }
    }

}