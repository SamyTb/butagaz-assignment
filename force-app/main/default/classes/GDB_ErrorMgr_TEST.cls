@isTest
private class GDB_ErrorMgr_TEST {

	@isTest
    static void createError() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_ErrorMgr.createError('clazz', 'method', 'message');
    }
}