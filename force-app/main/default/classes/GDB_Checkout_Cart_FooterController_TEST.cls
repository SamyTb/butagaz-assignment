@isTest
private class GDB_Checkout_Cart_FooterController_TEST {
    
    public static Map<String, String> guest {get;set;}
    
    @testSetup
    static void setup() {
        guest = GDB_AccountMgr.createNewGuest('71000');
    }
    
    @isTest
    static void testGetCurrentBasket() {
        GDB_Basket__c b = GDB_Checkout_Cart_FooterController.getCurrentBasket(guest);
        System.assertEquals(null, b, 'Return value should be null');
    }
}