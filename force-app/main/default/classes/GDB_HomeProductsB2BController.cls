public with sharing class GDB_HomeProductsB2BController {
 /**
     * getProductsB2B Get all products B2B.
     *
     * @param {String} product id or empty
     * @return {List<GDB_ProduitQuantity_B2B>} List of products 
     */
    @AuraEnabled 
    public static List<GDB_ProduitQuantity_B2B> getProductsB2B() {
        return GDB_ProductUtils.getProductsB2B();  
    }

    /**
     * addToCart Add article to the cart and return the URL destination page.
     *
     * @param {List<GDB_ProduitQuantity_B2B>} ProduitsQuantities
     * @return {String} The URL destination page
     */
    @AuraEnabled
    public static String addToCart(String ProduitsQuantities) {                
            
        Type idArrType=Type.forName('List<GDB_ProduitQuantity_B2B>');
        List<GDB_ProduitQuantity_B2B> prds = (List<GDB_ProduitQuantity_B2B>) JSON.deserialize(ProduitsQuantities, idArrType);
        
        return GDB_ProductUtils.addToCartB2B(prds);  
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
}