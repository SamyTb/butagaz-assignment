public with sharing class GDB_Utils_B2B {


    /**
     * getCommunityURLFromName Returns base URL for community
     *
     * @param  communityName community name
     * @param {Boolean} appendS
     *
     * @return {String}
     */
    public static String getCommunityURLFromName(Boolean appendS) {
        List<Domain> dList = [SELECT Domain,DomainType FROM Domain where Domain =: GDB_Constants_B2B.domainName ];
        
        if(dList == null || dList.size() == 0){
            return null;
        }
        
        Domain d = dList.get(0);
        
        return 'https://' + d.Domain + getCommunityUrlPathPrefix(appendS);
    }

    /**
     * getCommunityURLFromNameWithoutPrefix Returns base URL for community without prefix
     *
     * @param  communityName community name
     *
     * @return {String}
     */
    public static String getCommunityURLFromNameWithoutPrefix() {
        List<Domain> dList = [SELECT Domain,DomainType FROM Domain where Domain =: GDB_Constants_B2B.domainName ];
        
        if(dList == null || dList.size() == 0){
            return null;
        }
        
        Domain d = dList.get(0);
        
        return 'https://' + d.Domain;
    }

    /**
     * getCommunityUrlPathPrefix Return community URL path prefix
     *
     * @param  communityName communityName comunity name
     *
     * @return {String}
     */
    public static String getCommunityUrlPathPrefix() {
        return GDB_Constants_B2B.communityPathPrefix + '/s/';
    }

    /**
     * getCommunityUrlPathPrefix Return community URL path prefix
     * @param  communityName communityName comunity name
     * @return {String}
     */
    public static String getCommunityUrlPathPrefix(Boolean appendS) {
        return GDB_Constants_B2B.communityPathPrefix + (appendS == true ? '/s/' : '/');
    }

    /**
     * getUrlWithPathPrefix Returns URL page with community path prefix
     *
     * @param  urlPage URL page to go
     *
     * @return {String}
     */
    public static String getUrlWithPathPrefix(String urlPage) {
        return ''.equals(urlPage) ? getCommunityURLFromName(true) : getCommunityURLFromName(true) + urlPage;
    }

    /**
     * getUrlWithPathPrefix Returns URL page with community path prefix
     *
     * @param  urlPage URL page to go
     *
     * @return {String}
     */
    public static String getUrlWithPathPrefix(String urlPage, Boolean appendS) {
        return ''.equals(urlPage) ? getCommunityURLFromName(appendS) : getCommunityURLFromName(appendS) + urlPage;
    }

    /**
     * getLoginPageWithParam Returns Login page with community path prefix and parameters
     *
     * @param {String} communityName
     * @param {String} loginPage
     * @param {String} startUrlPage URL page to go after login
     *
     * @return {String}
     */
    public static String getLoginPageWithParam(String loginPage, String startUrlPage) {
        return ''.equals(startUrlPage) ? getCommunityURLFromName(true) + loginPage : getCommunityURLFromName(true) + loginPage + '?startUrl=' + startUrlPage;
    }

    /**
     * getLoginPageWithParam Returns Login page with community path prefix and parameters
     *
     * @param {String} communityName
     * @param {String} loginPage 
     * @param {String} startUrlPage URL page to go after login
     * @param {Boolean} appendS
     *
     * @return {String}
     */
    public static String getLoginPageWithParam(String loginPage, String startUrlPage, Boolean appendS) {
        return ''.equals(startUrlPage) ? getCommunityURLFromName(appendS) + loginPage : getCommunityURLFromName(appendS) + loginPage + '?startUrl=' + startUrlPage;
    }
}