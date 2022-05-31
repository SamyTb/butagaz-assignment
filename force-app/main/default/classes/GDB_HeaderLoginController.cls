public with sharing class GDB_HeaderLoginController {
    @AuraEnabled
    public static Map<String, String> getLoginDetails() {
        Boolean authenticated = GDB_AccountMgr.isAuthenticated();
        return new Map<String, String>{
            'authenticated' => String.valueOf(authenticated),
            'loginURL' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(authenticated ? 3 : 1))
        };
    }
}