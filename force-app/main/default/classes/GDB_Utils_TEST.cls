@isTest
private class GDB_Utils_TEST { 

    @isTest
    static void testGetFieldValues() {
        List<Map<String, String>> reasons = GDB_Utils.getFieldValues(Case.W2C_CaseCategory__c.getDescribe(),
            true, null);
        System.assertNotEquals(null, reasons, 'Return value should not be null');
        System.assertNotEquals(0, reasons.size(), 'Return value should not be empty');
    }

    @isTest
    static void testGetCommunityURLFromName() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getCommunityURLFromName(GDB_Constants.communityName, false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetCommunityUrlPathPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getCommunityUrlPathPrefix(GDB_Constants.communityName);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetUrlWithPathPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(3));
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetUrlWithPathPrefixWithParams() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(3),
            false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetLoginPageWithParam() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getLoginPageWithParam(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(1),
            '');
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetLoginPageWithParamWithParams() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getLoginPageWithParam(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(1),
            '', false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetCurrencySymbol() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getCurrencySymbol('EUR');
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetCommunityURLFromNameWithoutPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getCommunityURLFromNameWithoutPrefix(GDB_Constants.communityName);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetCommunityURLFromNonExistingName() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils.getCommunityURLFromName('ZZZZZZ', false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }
}