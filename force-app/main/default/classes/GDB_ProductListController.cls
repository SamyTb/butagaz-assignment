public with sharing class GDB_ProductListController {

    /**
     * getProductId Get record id where product ean is passed in parameter.
     *
     * @param {String} product ean or empty
     * @return {String} product id or empty
     */
    @AuraEnabled
    public static String getProductId(String productEan) {
        return GDB_ProductUtils.getProductId(productEan);
    }

    /**
     * getProducts Get all products or a product where id is passed in parameter.
     *
     * @param {String} product id or empty
     * @return {List<GDB_ArticleVM>} List of products
     */
    @AuraEnabled
    public static List<GDB_ArticleVM> getProducts(String recordId) {
        return GDB_ProductUtils.getProducts(recordId);
    }

    /**
     * getProductsWithZipCode Get all products or a product where id and zipcode are passed in parameters.
     *
     * @param {String} product id or empty
     * @param {String} zipcode
     * @return {List<GDB_ArticleVM>} List of products
     */
    @AuraEnabled
    public static List<GDB_ArticleVM> getProductsWithZipCode(String recordId, String zipcode) {
        return GDB_ProductUtils.getProductsWithZipCode(recordId, zipcode);
    }

    /**
     * getSampleInfos Returns url Sample and CodeArtcile
     *
     *
     * @return {Map<String, String>}
     */
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
     * @return {String} The URL destination page
     */
    @AuraEnabled
    public static String addToCart(Object article, Integer quantity) {
        GDB_ArticleVM item = (GDB_ArticleVM)JSON.deserialize(JSON.serialize(article), GDB_ArticleVM.class);
        return GDB_ProductUtils.addToCart(item, quantity);
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

}