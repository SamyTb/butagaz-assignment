public with sharing class GDB_ProductDetailController {

    /**
     * isUniquePriceOnWarehouses Returns true if it's unique price on each warehouses, else false
     *
     * @param {String} recordId
     *
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isUniquePriceOnWarehouses(String recordId) {
        return GDB_ProductUtils.isUniquePriceOnWarehouses(recordId);
    }

    /**
     * isCustomerAlreadyBoughtSampleProduct Returns true if the customer already bought the sample product
     *
     * @param {String} recordId
     *
     * @return {Map<String, Boolean>}
     */
    @AuraEnabled
    public static Map<String, Boolean> isCustomerAlreadyBoughtSampleProduct() {
        Boolean disabledBundleButton = false;
        Boolean alreadyBoughtSixDensifiedLogs = false;
        
        Map<String, Boolean> ret = new Map<String, Boolean>();
        
        ret.put('isSampleAlreadyBought', GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct());
        
        Account a = GDB_AccountMgr.getCurrentCustomer();
       
        if(a != null){
            disabledBundleButton = a.gdb_already_bought_bundle__c;
            alreadyBoughtSixDensifiedLogs = a.GDB_Already_Bought_Six_Densified_Logs__c;
        }
        
        ret.put('disabledBundleButton', disabledBundleButton);
        ret.put('alreadyBoughtSixDensifiedLogs', alreadyBoughtSixDensifiedLogs);
        
        return ret;
    }
    
     /**
     * getCurrentCustomer Return the current customer
     *
     * @return {Account}
     */
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    } 

    /**
     * getProductPrice Return product price to zipcode
     * @param {String} recordId
     * @param {Map<String, Object>} guest
     * @return {Map<String, Object>}
     */
    @AuraEnabled
    public static Map<String, Object> getProductPrice(String recordId, Map<String, Object> guest) {
        Map<String, Object> result = GDB_ProductUtils.getProductPrice(recordId, guest);
        if(guest != null && guest.containsKey('zipcode') 
        && Pattern.matches('[0-9]{4,5}', String.valueOf(guest.get('zipcode')))) 
        {
            String zipcode = String.valueOf(guest.get('zipcode'));
            if(zipcode.length() == 4){ 
                zipcode = '0' + zipcode; 
            }
            GDB_AccountMgr.setCurrentGuest(guest);
            GDB_BasketMgr.updateZipCodeShipping(zipcode);
        }
        return result;
    }

    /**
     * addToGuestCart Add article to the guest cart and return the URL destination page.
     * @param {Map<String, Object>} guestInfos
     * @param {Object} article
     * @param {Integer} Number of buyable quantity
     * @return {String} The URL destination page
     */
    @AuraEnabled
    public static String addToGuestCart(Map<String, Object> guestInfos, Object article) {
        return addToGuestCart(guestInfos, article, 1);
    }

    /**
     * addToGuestCart Add article to the guest cart and return the URL destination page.
     * @param {Map<String, Object>} guestInfos
     * @param {Object} article
     * @param {Integer} Number of buyable quantity
     * @return {String} The URL destination page
     */
    @AuraEnabled
    public static String addToGuestCart(Map<String, Object> guestInfos, Object article, Integer wantedQuantity) {
        if(!guestInfos.containsKey('zipcode')) { 
            return null; 
        } else if(!guestInfos.containsKey('id')) {
            GDB_AccountMgr.createNewGuest(String.valueOf(guestInfos.get('zipcode')));
        } else {
            GDB_AccountMgr.setCurrentGuest(guestInfos);
        }
        
        Map<String, String> guest = GDB_AccountMgr.getCurrentGuest();
        GDB_Basket__c cart = GDB_BasketMgr.getCurrentBasket(false);
        
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
        return GDB_ProductUtils.addToCart(item, wantedQuantity);
    }

    /**
     * Get the item lower price in database
     * @param {String} prodId 
     * @return {Decimal} 
     */
    @AuraEnabled
    public static Decimal getProductLowerPrice(String prodId) {
        return GDB_ProductUtils.getProductLowerPrice(prodId);
    }
    
    @AuraEnabled
    public static Map<String, String> createNewGuest(String zipcode) {
        return GDB_AccountMgr.createNewGuest(zipcode);
    }

    /**
     * Get the home page url
     * 
     * @return {Map<String, String>} 
     */
    @AuraEnabled
    public static Map<String, String> getHomePage() {
        return new Map<String, String>{
            'homepage' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, '')
        };
    }
}