public with sharing class GDB_Utils { 
    /**
     * Get values from the given field picklist
     *
     * @param {Schema.DescribeFieldResult} picklistDescribe
     * @param {Boolean} addNoneValue
     * @param {Set<String>} excludedValues
     *
     * @return {List<Map<String, String>>}
     **/
    public static List<Map<String, String>> getFieldValues(Schema.DescribeFieldResult picklistDescribe, Boolean addNoneValue, Set<String> excludedValues) {
        List<Map<String, String>> values = new List<Map<String, String>>();
        List<Schema.PicklistEntry> picklistEntries = picklistDescribe.getPicklistValues();
        if(excludedValues == null) {
            excludedValues = new Set<String>();
        }

        // Add empty entry at first
        if(addNoneValue == true) {
            values.add(new Map<String, String>{
                'value' => '',
                'label' => 'None'
            });
        }

        for(Schema.PicklistEntry f : picklistEntries) {
            if(!excludedValues.contains(f.getValue())) {
                values.add(new Map<String, String>{
                    'value' => f.getValue(),
                    'label' => f.getLabel()
                });
            }
        }

        return values;
    }

    /**
     * getCommunityURLFromName Returns base URL for community
     *
     * @param  communityName community name
     * @param {Boolean} appendS
     *
     * @return {String}
     */
    public static String getCommunityURLFromName(String communityName, Boolean appendS) {
        List<Domain> dList = [SELECT Domain,DomainType FROM Domain where Domain =: GDB_Constants.domainName ];
        
        if(dList == null || dList.size() == 0){
            return null;
        }
        
        Domain d = dList.get(0);
        
        return 'https://' + d.Domain + getCommunityUrlPathPrefix(communityName, appendS);
    }

    /**
     * getCommunityURLFromNameWithoutPrefix Returns base URL for community without prefix
     *
     * @param  communityName community name
     *
     * @return {String}
     */
    public static String getCommunityURLFromNameWithoutPrefix(String communityName) {
        List<Domain> dList = [SELECT Domain,DomainType FROM Domain where Domain =: GDB_Constants.domainName ];
                
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
    public static String getCommunityUrlPathPrefix(String communityName) {
        return GDB_Constants.communityPathPrefix + '/s/';
    }

    /**
     * getCommunityUrlPathPrefix Return community URL path prefix
     * @param  communityName communityName comunity name
     * @return {String}
     */
    public static String getCommunityUrlPathPrefix(String communityName, Boolean appendS) {
        return GDB_Constants.communityPathPrefix + (appendS == true ? '/s/' : '/');
    }

    /**
     * getUrlWithPathPrefix Returns URL page with community path prefix
     *
     * @param  urlPage URL page to go
     *
     * @return {String}
     */
    public static String getUrlWithPathPrefix(String communityName, String urlPage) {
        return ''.equals(urlPage) ? getCommunityURLFromName(communityName, true) : getCommunityURLFromName(communityName, true) + urlPage;
    }

    /**
     * getUrlWithPathPrefix Returns URL page with community path prefix
     *
     * @param  urlPage URL page to go
     *
     * @return {String}
     */
    public static String getUrlWithPathPrefix(String communityName, String urlPage, Boolean appendS) {
        return ''.equals(urlPage) ? getCommunityURLFromName(communityName, appendS) : getCommunityURLFromName(communityName, appendS) + urlPage;
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
    public static String getLoginPageWithParam(String communityName, String loginPage, String startUrlPage) {
        return ''.equals(startUrlPage) ? getCommunityURLFromName(communityName, true) + loginPage : getCommunityURLFromName(communityName, true) + loginPage + '?startUrl=' + startUrlPage;
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
    public static String getLoginPageWithParam(String communityName, String loginPage, String startUrlPage, Boolean appendS) {
        return ''.equals(startUrlPage) ? getCommunityURLFromName(communityName, appendS) + loginPage : getCommunityURLFromName(communityName, appendS) + loginPage + '?startUrl=' + startUrlPage;
    }


    /**
     * getCurrencySymbol Returns currency symbol from ISO Code
     * @param  {String} isoCode
     * @return {String}
     */
    public static String getCurrencySymbol(String isoCode) {
        return GDB_Constants.currencySymbol.get(isoCode);
    }
}