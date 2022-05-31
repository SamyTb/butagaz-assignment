public with sharing class GDB_CommunitiesLandingController {
    public GDB_CommunitiesLandingController() {}

    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        String param = ApexPages.CurrentPage().getParameters().get('startUrl');
        String page = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, (String.isNotBlank(param) ? '?startUrl=' + param : ''));
        return new PageReference(page);
    }
}