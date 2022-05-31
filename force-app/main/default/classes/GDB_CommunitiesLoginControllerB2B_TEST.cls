@isTest
global with sharing class GDB_CommunitiesLoginControllerB2B_TEST {
    
    @IsTest
    static void testCommunitiesLoginControllerInstantiation() {
        GDB_CommunitiesLoginControllerB2B controller = new GDB_CommunitiesLoginControllerB2B();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    global static void testForwardToAuthPage() {
        GDB_CommunitiesLoginControllerB2B controller = new GDB_CommunitiesLoginControllerB2B();
        System.assertNotEquals(null, controller.forwardToAuthPage());
    }
}