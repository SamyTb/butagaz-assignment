public with sharing class GDB_FreeProductController {

    /**
     * getCurrentCustomer This method returns the current authenticated customer
     **/
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    /**
     * getAvailableListValues This method returns the list of available shipping countries
     **/
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableListValues() {
        return new Map<String, List<Map<String, String>>>{
            'countries' => GDB_CheckoutUtils.getAvailableShippingCountries()
        };
    }

    /**
     * submitFreeProductForm This method is called when the customer submits the Free Product form
     *
     * @param {Map<String, String>} detailsForm
     *
     **/
    @AuraEnabled
    public static Map<String, String> submitFreeProductForm(Map<String, String> detailsForm) {
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if (detailsForm == null) {
            returnObject.put('message', System.Label.GDB_freeProductForm_cannotSubmitForm);
            return returnObject;
        }

        try {
            // Check required fields
            if(String.isBlank(detailsForm.get('salutation'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_salutation }));
            }
            if(String.isBlank(detailsForm.get('firstName'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproduct_firstName }));
            }
            if(String.isBlank(detailsForm.get('lastName'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_lastName }));
            }
            if(String.isBlank(detailsForm.get('address1'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_address1 }));
            }
            if(String.isBlank(detailsForm.get('zip'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_zip }));
            }
            if(String.isBlank(detailsForm.get('country'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_country }));
            }
            if(String.isBlank(detailsForm.get('city'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_city }));
            }
            if(String.isBlank(detailsForm.get('phone'))) {
                returnObject.put('message', String.format(System.Label.GDB_freeProductForm_requiredField, new String[]{ System.Label.GDB_freeproductForm_phone }));
            }

            if(returnObject.containsKey('message')) {
                return returnObject;
            }

            if (GDB_OrderMgr.createSampleOrder(detailsForm) == null) {
                returnObject.put('message', System.Label.GDB_freeProductForm_cannotSubmitForm);
                return returnObject;
            }

            returnObject.put('message', System.Label.GDB_freeProductForm_success);
            returnObject.put('success', 'true');
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            returnObject.put('message', System.Label.GDB_freeProductForm_cannotSubmitForm);
            return returnObject;
        }
        String redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.pagesURLs.get(13));
        PageReference page = new PageReference(redirectURL);
        if(!Test.isRunningTest()){
            aura.redirect(page);
        }

        return returnObject;
    }

    /**
     * isCustomerAlreadyBoughtSampleProduct Returns true if the customer already bought the sample product
     *
     * @param {String} recordId
     *
     * @return {Boolean}
     */
    @AuraEnabled
    public static Boolean isCustomerAlreadyBoughtSampleProduct(String recordId) {
        return GDB_AccountMgr.isCustomerAlreadyBoughtSampleProduct();
    }
}