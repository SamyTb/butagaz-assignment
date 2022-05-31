public with sharing class GDB_Checkout_Payment_FooterController {
    @AuraEnabled
    public static Boolean savePaymentDetails(Id paymentMethod, Boolean multiplePayment) {
        try {
            GDB_Basket__c basket    = getCurrentBasket(); 
            
            // Check if Account is allowed to pay in multiple times 
            if(multiplePayment == false
            || (basket != null && basket.gdb_Account__r.gdb_block_orders__c == false))
            {
                GDB_PaymentMgr.updatePaymentPreferences(paymentMethod, multiplePayment);
                return true;
            }
            
            // if it is blocked, we return null to display a specific error message
            return null;
        }
        catch(Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static GDB_Basket__c getCurrentBasket() {
        return GDB_BasketMgr.getCurrentBasket(false);
    }

    @AuraEnabled
    public static Map<String, Object> getMultiplePaymentDetailsForCurrentBasket() {
        return GDB_BasketMgr.getMultiplePaymentDetailsForCurrentBasket(true);

    }
}