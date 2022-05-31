public with sharing class GDB_Merge_Guest_BasketController {

    /**
     * isAuthenticated Return true if customer is authenticated
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isAuthenticated() {
        return GDB_AccountMgr.isAuthenticated();
    }
    
    /**
     * mergeGuestBasketToCustomer Merge the guest basket to the current customer one
     * @param {Map<String, Object>} guest
     * @return {Map<String, Object>}
     **/
    @AuraEnabled
    public static Map<String, Object> mergeGuestBasketToCustomer(Map<String, Object> guest) {
        if(guest == null || !GDB_AccountMgr.isAuthenticated()) {
            return null;
        }
        
        GDB_AccountMgr.setCurrentGuest(guest);
        Map<String, String> guestMap = GDB_AccountMgr.getCurrentGuest();
        GDB_Basket__c guestBasket = GDB_BasketMgr.getCurrentBasketByAccountOrGuest(null, guestMap);
        
        // If guest basket is empty, we don't merge it
        if(guestBasket == null 
        || guestBasket.Basket_Products__r.size() <= 0) {
            return null;
        }
        
        Account customer;
        if(Test.isRunningTest()){
            customer = GDB_TestDataFactory.getGlobalAccount();
        } else {
            customer = GDB_AccountMgr.getCurrentCustomer();
        }
        
        // Merge the guest basket
        GDB_Basket__c customerBasket = GDB_BasketMgr.setGuestBasketToCustomer(customer);
        
        List<Map<String, String>> errorList = new List<Map<String, String>>();
        Map<String, Object> results = new Map<String, Object>();

        if(guestBasket.gdb_shipping_zip__c != customerBasket.gdb_shipping_zip__c) {
            List<GDB_Shipping_Method__c> customerShippingMethods = GDB_ShippingMgr.getShippingMethods(customerBasket);
            Boolean shippingMethodFounded = false;
            // Test if selected shipping method is availbale for the new zipcode
            if(customerShippingMethods != null && !customerShippingMethods.isEmpty()) {
                GDB_Shipping_Method__c firstShippingMethod = customerShippingMethods.get(0);
                for(GDB_Shipping_Method__c sm : customerShippingMethods) {
                    if(guestBasket.gdb_Shipping_Method__c == sm.Id) {
                        shippingMethodFounded = true;
                        break;
                    }
                }

                if(!shippingMethodFounded) {
                    if(customerShippingMethods.size() > 1) {
                        errorList.add(new Map<String, String>{ 
                            'errno' => '50',
                            'message' => GDB_Constants.mergeGuestBasketErrors.get(50), 
                            'redirect' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1))
                        });
                    } else {
                        customerBasket.gdb_Shipping_Method__c = firstShippingMethod.Id;
                        GDB_BasketMgr.recalculateBasket(customerBasket);
                    }
                }
            }

            Map<String, String> result = GDB_CheckoutUtils.verifyStock(customerBasket);
            // if products no more on stock
            if(result != null && result.containsKey('success') && result.get('success') == 'false') {
                errorList.add(new Map<String, String>{ 
                    'errno' => '10',
                    'message' => GDB_Constants.mergeGuestBasketErrors.get(10)
                });
            }

            // Add error about zipcode different if error list is empty
            if(errorList != null && errorList.isEmpty()) {
                errorList.add(new Map<String, String>{ 
                    'errno' => '20',
                    'message' => GDB_Constants.mergeGuestBasketErrors.get(20)
                });
            }
        }

        // Test if the discount is no more applied to customer
        // because already used
        if(guestBasket.gdb_Discount__c != null
        && guestBasket.gdb_Discount__c != customerBasket.gdb_Discount__c) {
            errorList.add(new Map<String, String>{ 
                'errno' => '30',
                'message' => GDB_Constants.mergeGuestBasketErrors.get(30), 
                'backToCart' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1))
            });
        }

        // Test if the product is already bought and can not be bought another time
        Account a = GDB_AccountMgr.getCurrentCustomer();
        Boolean isSampleAlreadyBought = (a != null && a.gdb_already_bought_bundle__c);
        Boolean isSixDensifiedLogsAlreadyBought = (a != null && a.GDB_Already_Bought_Six_Densified_Logs__c);
        String sampleCode = GDB_Constants.articleCode.get(1);
        String sixDensifiedLogsCode = GDB_Constants.articleCode.get(2);
        for(GDB_Basket_Product__c p : customerBasket.Basket_Products__r) {
            if(
                (p.gdb_product_code__c == sampleCode && isSampleAlreadyBought) ||
                (p.gdb_product_code__c == sixDensifiedLogsCode && isSixDensifiedLogsAlreadyBought)
            ) {
                String productName = p.Name;
                errorList.add(new Map<String, String>{ 
                    'errno' => '40',
                    'productName' => productName,
                    'redirect' => GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1))
                });
                delete p;
                GDB_BasketMgr.recalculateBasket(customerBasket);
                break;
            }
        }

        results.put('errors', errorList);
        return results;
    }
    /**
     * Return the default zipcode for guest user
     * @return {String}
     */
    @AuraEnabled
    public static String getDefaultZipCode() {
        return GDB_Constants.nudgeDefaultZipCode;
    }
}