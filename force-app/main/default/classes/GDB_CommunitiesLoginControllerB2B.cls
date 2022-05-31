/**
 * An apex page controller that exposes the site login functionality for B2B site
 */
global with sharing class GDB_CommunitiesLoginControllerB2B {

    global GDB_CommunitiesLoginControllerB2B () {}

    global PageReference forwardToAuthPage() {
        String param = ApexPages.CurrentPage().getParameters().get('startUrl');
        String page = GDB_Utils_B2B.getLoginPageWithParam(GDB_Constants_B2B.pagesURLsB2B.get(1), param);
        return new PageReference(page);
    }
}