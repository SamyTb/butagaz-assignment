/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class GDB_CommunitiesLoginController {

    global GDB_CommunitiesLoginController () {}

    global PageReference forwardToAuthPage() {
    	String param = ApexPages.CurrentPage().getParameters().get('startUrl');
    	String page = GDB_Utils.getLoginPageWithParam(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(1), param);
    	return new PageReference(page);
    }
}