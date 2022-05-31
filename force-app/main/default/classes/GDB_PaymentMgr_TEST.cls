@isTest
private class GDB_PaymentMgr_TEST {

    @isTest
    static void testGetPaymentMethods() {
        GDB_TestDataFactory.createPaymentMethod();
        List<GDB_Payment_Method__c> pms = GDB_PaymentMgr.getPaymentMethods();
        System.assertNotEquals(null, pms, 'Return value should not be null');
        System.assertNotEquals(0, pms.size(), 'Return value should not be empty');
    }

    @isTest
    static void testGetPaymentMethodByIdWithNullId() {
        GDB_Payment_Method__c pm = GDB_PaymentMgr.getPaymentMethodById(null);
        System.assertEquals(null, pm, 'Return value should be null');
    }

    @isTest
    static void testGetPaymentMethodByIdWithExistingId() {
        GDB_TestDataFactory.createPaymentMethod();
        GDB_Payment_Method__c pm = GDB_TestDatafactory.getPaymentMethod();
        GDB_Payment_Method__c p = GDB_PaymentMgr.getPaymentMethodById(pm.Id);
        System.assertNotEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testGetPaymentMethodByIdWithNoExistingId() {
        GDB_TestDataFactory.createPaymentMethod();
        Id pId = Id.valueOf(GDB_TestDataFactory.getGlobalAccountId());
        GDB_Payment_Method__c p = GDB_PaymentMgr.getPaymentMethodById(pId);
        System.assertEquals(null, p, 'Return value should be null');
    }

    @isTest
    static void testUpdatePaymentPreferences() {
        GDB_TestDataFactory.createPaymentMethod();
        Id pId = Id.valueOf(GDB_TestDataFactory.getGlobalAccountId());
        GDB_PaymentMgr.updatePaymentPreferences(pId, false);
    }

    @isTest
    static void testUpdatePaymentPreferencesWithIdNull() {
        GDB_PaymentMgr.updatePaymentPreferences(null, false);
    }
}