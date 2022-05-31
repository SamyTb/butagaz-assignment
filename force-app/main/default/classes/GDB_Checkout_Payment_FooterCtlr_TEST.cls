@isTest
private class GDB_Checkout_Payment_FooterCtlr_TEST {

    @isTest
    static void testSavePaymentDetails() {
        GDB_TestDataFactory.createPaymentMethod();
        GDB_Payment_Method__c p = GDB_TestDataFactory.getPaymentMethod();
        Boolean ret = GDB_Checkout_Payment_FooterController.savePaymentDetails(p.Id, false);
        System.assertEquals(true, ret, 'Return value should be true');
    }

    @isTest
    static void testSaveNotAllowedPaymentDetails() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        
        GDB_Payment_Method__c p = GDB_TestDataFactory.getPaymentMethod();
        Account myAccount       = new Account(Name='test', gdb_block_orders__c = true);
        myAccount.Phone = '0987654321';
        insert myAccount;  
                                    
        GDB_Basket__c basket = GDB_TestDataFactory.createAndGetBasketWithBasketProduct(myAccount);    
        Boolean ret = GDB_Checkout_Payment_FooterController.savePaymentDetails(p.Id, true);
        System.assertEquals(null, ret, 'Return value should be null');
    }
    
    
    @isTest
    static void testGetCurrentBasket() {
        GDB_Basket__c b = GDB_Checkout_Payment_FooterController.getCurrentBasket();
        System.assertEquals(null, b, 'Return value should be null');
    }
    
    @isTest
    static void testGetMultiplePaymentDetailsForCurrentBasket() {
        Map<String, Object> ret = GDB_Checkout_Payment_FooterController.getMultiplePaymentDetailsForCurrentBasket();
        System.assertEquals(null, ret, 'GetMultiplePaymentDetailsForCurrentBasket return shoud be null');        
    }
}