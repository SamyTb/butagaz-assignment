global class LightningLoginFormController {

    public LightningLoginFormController() {

    }

    /**
     * login description
     * @param  username username description
     * @param  password password description
     * @param  startUrl startUrl description
     * @return  {String}
     */
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    /**
     * getIsUsernamePasswordEnabled description
     * @return   return description
     */
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    /**
     * getIsSelfRegistrationEnabled description
     * @return   return description
     */
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    /**
     * getSelfRegistrationUrl description
     * @return   return description
     */
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    /**
     * getForgotPasswordUrl description
     * @return   return description
     */
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    /**
     * getAuthConfig description
     * @return   return description
     */
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig() {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
        return authConfig;
    }
}