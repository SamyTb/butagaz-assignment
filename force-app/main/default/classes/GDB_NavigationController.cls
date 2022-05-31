public with sharing class GDB_NavigationController {
    /**
     * getProducts Get all products or a product where id is passed in parameter.
     *
     * @param {String} product id or empty 
     * @return {List<GDB_ArticleVM>} List of products
     */
    @AuraEnabled
    public static List<GDB_ArticleVM> getProducts(String recordId) {
        return GDB_ProductUtils.getProductsAvailable(recordId,GDB_Constants.articleNameDisplay.get(1),'gdb_warehouseproduct__r.gdb_article__r.gdb_menu_sort__c', 'ASC');
    }

    /**
     * getNavigationURLs Get all Navigation urls.
     *
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> getNavigationURLs() {
        return new Map<String, String>{
            'homepage' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, ''),
            'productsandorder' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(2)),
            'contactus' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(6)),
            'advantages1' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(8)),
            'advantages2' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(9)),
            'advantages3' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(18)),
            'reviews1' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(19)),
            'reviews2' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(20)),
            'faq' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(14)),
            'blog' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(16)),
            'pack_serenissime' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(21)),
            'shippingPage' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(22))
        };
    }    
    
    /**
     * getNavigationURLsB2B Get all Navigation urls for B2B.
     *
     * @return {Map<String, String>}
     */
    @AuraEnabled
    public static Map<String, String> getNavigationURLsB2B() {
        return new Map<String, String>{
            'homepage' => GDB_Utils_B2B.getUrlWithPathPrefix(''),
            'myaccount' => GDB_Utils_B2B.getUrlWithPathPrefix(GDB_Constants_B2B.pagesURLsB2B.get(2)),
            'myorder' => GDB_Utils_B2B.getUrlWithPathPrefix(GDB_Constants_B2B.pagesURLsB2B.get(3))
        }; 
    }
}