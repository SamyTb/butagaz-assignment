public with sharing class GDB_HomeProductsController { 

    /**
     * getProducts Get all products or a product where id is passed in parameter.
     *
     * @param {String} product id or empty
     * @return {List<GDB_ArticleVM>} List of products
     */
    @AuraEnabled
    public static List<GDB_ArticleVM> getProducts(String recordId) {
        return GDB_ProductUtils.getProductsAvailable(recordId,GDB_Constants.articleNameDisplay.get(2),'gdb_warehouseproduct__r.gdb_article__r.gdb_sort__c', 'ASC');
    }

    @AuraEnabled
    public static Map<String, String> getSampleInfos() {
        Map<String, String> ret = new Map<String, String>();
        
        ret.put('sampleURL', GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(12)));
        ret.put('sampleCode', GDB_Constants.articleCode.get(1));
        ret.put('sixDensifiedLogsCode', GDB_Constants.articleCode.get(2));
        
        return ret;
    }

    /**
     * addToCart Add article to the cart and return the URL destination page.
     *
     * @param {Object} article
     * @param {Map<String, Object>} guest
     * @return {String} The URL destination page
     */
    @AuraEnabled
    public static String addToCart(Object article, Map<String, Object> guest) {
        if(guest != null 
        && guest.containsKey('zipcode') 
        && String.isNotBlank(String.valueOf(guest.get('zipcode')))) {
            GDB_AccountMgr.setCurrentGuest(guest);
        }
        GDB_ArticleVM item = (GDB_ArticleVM)JSON.deserialize(JSON.serialize(article), GDB_ArticleVM.class);
        return GDB_ProductUtils.addToCart(item);
    }


    /**
     * isAuthenticated Returns true if the current user is authenticated or else if the current user is a guest user
     *
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isAuthenticated() {
        return GDB_AccountMgr.isAuthenticated();
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
     * isCustomerAlreadyBoughtSampleProduct Returns true if the customer already bought the sample product
     *
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isCustomerAlreadyBoughtSampleProduct() {
        return GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct();
    }
}