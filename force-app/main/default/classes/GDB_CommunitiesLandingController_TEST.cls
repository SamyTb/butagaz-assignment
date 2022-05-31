@isTest
global with sharing class  GDB_CommunitiesLandingController_TEST {

    @IsTest
    static void testCommunitiesLandingControllerInstantiation() {
        GDB_CommunitiesLandingController controller = new GDB_CommunitiesLandingController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    global static void testForwardToStartPage() {
        GDB_CommunitiesLandingController controller = new GDB_CommunitiesLandingController();
        System.assertNotEquals(null, controller.forwardToStartPage());
    }
}