public without sharing class GDB_TileProductController {

    @AuraEnabled
    public static String addToGuestCart(Map<String, Object> guestInfos, Object article) {
        if(!guestInfos.containsKey('zipcode')) { 
            return null; 
        } else if(!guestInfos.containsKey('id') || String.isBlank(String.valueOf(guestInfos.get('id')))) {
            GDB_AccountMgr.createNewGuest(String.valueOf(guestInfos.get('zipcode')));
        } else {
            GDB_AccountMgr.setCurrentGuest(guestInfos);
        }
        
        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        GDB_Basket__c cart = GDB_BasketMgr.getCurrentBasket(true);
        
        if(guest.containsKey('zipcode') 
        && String.isNotBlank(guest.get('zipcode'))
        && cart != null
        && (cart.gdb_shipping_zip__c == null 
        || cart.gdb_shipping_zip__c != guest.get('zipcode'))) 
        {
            cart.gdb_shipping_zip__c = guest.get('zipcode');
            GDB_WarehouseMgr.updateWarehouse(cart, guest.get('zipcode'));
        }
        
        GDB_ArticleVM item = (GDB_ArticleVM)JSON.deserialize(JSON.serialize(article), GDB_ArticleVM.class);

        return GDB_ProductUtils.addToCart(item);
    }

    @AuraEnabled
    public static Map<String, String> createNewGuest(String zipcode) {
        return GDB_AccountMgr.createNewGuest(zipcode);
    }

}