public with sharing class GDB_TagCommander_Controller {

    @AuraEnabled
    public static Map<String, Object> getCurrentBasket(Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        GDB_BasketMgr.recalculateBasket(null);
        GDB_Basket__c basket = GDB_BasketMgr.getCurrentBasket(false);
        Map<String, Object> result = new Map<String, Object> {
            'basket' => basket,
            'isSandbox' => GDB_CustomMetadataMgr.self().isSandbox()
        };
        
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getOrder() {
        Map<String, Object> result = new Map<String, Object> {
            'order' => GDB_OrderMgr.getCurrentOrder(),
            'isSandbox' => GDB_CustomMetadataMgr.self().isSandbox()
        };
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isSandbox() {
        return GDB_CustomMetadataMgr.self().isSandbox();
    }
}