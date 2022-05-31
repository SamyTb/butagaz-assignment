@isTest
global with sharing class GDB_CommunitiesLoginController_TEST {

    @IsTest
    static void testCommunitiesLoginControllerInstantiation() {
        GDB_CommunitiesLoginController controller = new GDB_CommunitiesLoginController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    global static void testForwardToAuthPage() {
        GDB_CommunitiesLoginController controller = new GDB_CommunitiesLoginController();
        System.assertNotEquals(null, controller.forwardToAuthPage());
    }
}