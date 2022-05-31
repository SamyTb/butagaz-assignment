@isTest
private class GDB_DocaPostPdfViewerController_TEST {
   
    @isTest
    static void testCallout() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createOrder(null);
        
        Order__c o = GDB_TestDataFactory.getOrder();
        o.Order_Status__c = '7';
        update o;
        GDB_Invoice__c i = GDB_TestDataFactory.createInvoice(o);
        i.gdb_sap_invoice_no__c = '0004942557';
        update i;
        
        Account a = GDB_TestDataFactory.getGlobalAccount();
        User u = [SELECT Id FROM User WHERE AccountId = :a.Id];
        
        System.runAs(u) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new GDB_DocaPostPdfViewerControllerMock());
                GDB_DocaPostPdfViewerController.getInvoicePdf(i.Id);
            Test.stopTest();
        }
    }
}