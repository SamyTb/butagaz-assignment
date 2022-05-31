public without sharing class GDB_Checkout_Cart_FooterController { 
    /**
     * getCurrentBasket Return the current basket
     * @param {Map<String, Object>} guest
     * @returns{GDB_Basket__c}
     **/
    @AuraEnabled
    public static GDB_Basket__c getCurrentBasket(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        return GDB_BasketMgr.getCurrentBasket(false);
    }
}