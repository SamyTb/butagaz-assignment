@isTest
private class GDB_Utils_B2B_TEST {

    @isTest
    static void testGetCommunityURLFromName() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getCommunityURLFromName(false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetCommunityUrlPathPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getCommunityUrlPathPrefix();
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetUrlWithPathPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getUrlWithPathPrefix(GDB_Constants_B2B.pagesURLsB2B.get(3));
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetUrlWithPathPrefixWithParams() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getUrlWithPathPrefix(GDB_Constants_B2B.pagesURLsB2B.get(3),
            false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetLoginPageWithParam() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getLoginPageWithParam(GDB_Constants_B2B.pagesURLsB2B.get(1),
            '');
        System.assertNotEquals(null, url, 'Return value should not be null');
    }

    @isTest
    static void testGetLoginPageWithParamWithParams() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getLoginPageWithParam(GDB_Constants_B2B.pagesURLsB2B.get(1),
            '', false);
        System.assertNotEquals(null, url, 'Return value should not be null');
    }
    
    @isTest
    static void testGetCommunityURLFromNameWithoutPrefix() {
        GDB_TestDataFactory.createCustomSettings();
        String url = GDB_Utils_B2B.getCommunityURLFromNameWithoutPrefix();
        System.assertNotEquals(null, url, 'Return value should not be null');
    }
}