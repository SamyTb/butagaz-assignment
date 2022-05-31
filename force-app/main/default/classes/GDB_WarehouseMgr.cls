public without sharing class GDB_WarehouseMgr {
    /**
     * findWarehouseBasedOnZipCode Find the warehouse related to the given zip code
     *
     * @param {String} zip
     *
     * @return {GDB_Warehouse__c}
     */
    public static GDB_Warehouse__c findWarehouseBasedOnZipCode(String zip, Boolean onlySample) {
        if (zip == null || zip.length() == 0) {
            return null;
        }

        if (onlySample == null) {
            onlySample = false;
        }

        List<GDB_Warehouse__c> warehouses = [
            SELECT
            gdb_codes__c,
            gdb_reference__c,
            gdb_mail_transporteur__c,
            gdb_is_sample__c            
            FROM GDB_Warehouse__c
            WHERE gdb_codes__c INCLUDES (:zip.substring(0, 2))
            AND gdb_is_sample__c = :onlySample
        ];
        if(warehouses == null || warehouses.size() == 0) {
            return null;
        }

        return warehouses.get(0);
    }

    /**
     * updateWarehouse Update the Warehouse reference on the given (or current if none given) basket
     *
     * @param {GDB_Basket__c} basket
     * @param {Id} warehouseId
     */
    public static void updateWarehouse(GDB_Basket__c basket, String zipCode) {
        if(basket == null) {
            basket = GDB_BasketMgr.getCurrentBasket(false);
        }

        if(basket == null || String.isBlank(zipCode)) {
            return;
        }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // If the basket don't have any basket products yet
            // The next lines are useless, quit the method here
            if(basket.Basket_Products__r == null || basket.Basket_Products__r.size() == 0) {
                return;
            }

            // Fetch basket products to find product IDs
            Set<Id> productIDs = new Set<Id>();
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r) {
                productIDs.add(bp.gdb_Article__c);
            }

            // Find warehouse-products joins based on given productIDs
            List<GDB_ArticleVM> articles = GDB_ProductUtils.getProductsWithZipCode('', zipCode.substring(0,2));
            if(articles == null || articles.size() == 0) {
                return;
            }

            // Update basket product prices
            for(GDB_Basket_Product__c bp : basket.Basket_Products__r) {
                for(GDB_ArticleVM article : articles) {
                    if(bp.gdb_Article__c == article.Id) {
                        article.bind2BasketProduct(bp);
                        break;
                    }
                }
            }
            update basket.Basket_Products__r;
            GDB_BasketMgr.recalculateBasket(basket);
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }
    }
}