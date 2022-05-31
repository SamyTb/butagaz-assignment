public without sharing class GDB_Checkout_ValidatePaymentController {
    public String redirectURL { get; set; }

    public GDB_Checkout_ValidatePaymentController() {
        GDB_ErrorMgr.generateToken();
    }

    public PageReference validateResponse() {
        Order__c o;
 
        try 
        {
            /**
             * Get parameters from the POST data from the request
             */
            String data =  ApexPages.currentPage().getParameters().get('Data');
            String seal =  ApexPages.currentPage().getParameters().get('Seal');
            
            // Initialize Mercanet and a new postResponse object to parse the POST data
            GDB_Mercanet mercanetHelper = new GDB_Mercanet();
            GDB_Mercanet.PostResponse postResponse = new GDB_Mercanet.PostResponse(data, seal);
            
            if (postResponse.isValid()) 
            {
                // Get the order based on the transaction reference sent by Mercanet
                o = GDB_OrderMgr.getOrderByOrderNo(postResponse.getTransactionReference());
                
                //Lookup order - Error
                GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'DATA_' + data, o);
                GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'SEAL_' + seal, o);

                // Only treat order if
                // - the order is found
                // - the order transaction id is blank
                if (o != null) 
                {
                    // If status "Success" or "To split" and already paid
                    if (String.isNotBlank(o.gdb_transaction_id__c) && (o.Order_Status__c == '4' || o.Order_Status__c == '8')) 
                    {
                        this.redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(5));

                        Account a = o.Account__r;
                        
                        if(a == null)
                        {
                            GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'The Order Account is null, the Order is success/to split and already paid', o);
                        }
                        else
                        {
                        	// Update Account if buying bundle
                        	List<Item_in_Order__c> op1 = [SELECT Name FROM Item_in_Order__c WHERE Commande__c =: o.Id AND Unit__c =: GDB_Constants.articleCode.get(1)];
                            
                            if(op1 != null && op1.size() > 0)
                            {
                                a.gdb_already_bought_bundle__c = true;
                            }
                            else
                            {
                                GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order items not found, the Order is success/to split and already paid', o);
                            }
                            
                            // Update Account if buying Six Densified Logs
                            List<Item_in_Order__c> op2 = [SELECT Name FROM Item_in_Order__c WHERE Commande__c =: o.Id AND Unit__c =: GDB_Constants.articleCode.get(2)];
                            
                            if(op2 != null && op2.size() > 0)
                            {
                                 a.GDB_Already_Bought_Six_Densified_Logs__c = true;
                            }
                            else
                            {
                            	GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order items not found, the Order is success/to split and already paid', o);    
                            }
                            
                            if(a.gdb_already_bought_bundle__c || a.GDB_Already_Bought_Six_Densified_Logs__c)
                            {
                                update a;
                            }
                        }
                        
                        // Finally remove the current basket as it is not needed anymore
                        GDB_BasketMgr.removeBasket(GDB_BasketMgr.getCurrentBasket(false));

                        // Finally remove the Order ID from the session
                        if (!Test.isRunningTest()) 
                        {
                            removeKeyInSessionCache(GDB_Constants.sessionKeys.get('orderId'));
                        }

                        return null;
                    // Else if status "Created" or "To split" without payment informations
                    }
                    else if(String.isBlank(o.gdb_transaction_id__c) && (o.Order_Status__c == '3' || o.Order_Status__c == '8')) 
                    {
                        if (postResponse.isValid()) { // The response is valid, we can update the current order status to paid
                            // To prevent double action, we check that this is not
                            // the user who come back on website but mercanet response
                            Account a = Test.isRunningTest() ? null : GDB_AccountMgr.getCurrentCustomer();
                            
                            if(a == null) 
                            {
                                // Update the order with the payment details
                                GDB_OrderMgr.updateOrderPaymentDetails(o, postResponse.getTransactionId(), postResponse.getAuthorisationId());
                                GDB_OrderMgr.successOrder(o);
                                GDB_DiscountMgr.decreaseTotalUses(o.gdb_Discount__c);
                                
                                // Updating remaining use of the shipping method if defined
                                GDB_Shipping_Method__c shippingMethod = [SELECT Id, gdb_number_of_remaining_use__c FROM GDB_Shipping_Method__c WHERE Id = :o.gdb_Shipping_Method__c];
                                
                                if(shippingMethod.gdb_number_of_remaining_use__c != null)
                                {
                                    shippingMethod.gdb_number_of_remaining_use__c = shippingMethod.gdb_number_of_remaining_use__c - 1;
                                    
                                    if(shippingMethod.gdb_number_of_remaining_use__c < 0)
                                    {
                                        shippingMethod.gdb_number_of_remaining_use__c = 0;
                                    }
                                    
                                    update shippingMethod;
                                }

                                // Update Account if buying bundle
                                List<Item_in_Order__c> op1 = [SELECT Name FROM Item_in_Order__c WHERE Commande__c =: o.Id AND Unit__c =: GDB_Constants.articleCode.get(1)];
                                
                                if(op1 != null && op1.size() > 0)
                                {
                                    Account accountOnOrder = o.Account__r;
                                    
                                    if(accountOnOrder != null)
                                    {
                                        accountOnOrder.gdb_already_bought_bundle__c = true;
                                        
                                        update accountOnOrder;
                                    } 
                                    else 
                                    {
                                        GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'The Order Account is null, the Order is Created/to split and no payment information', o);
                                    }
                                } 
                                else 
                                {
                                    GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order items not found, the Order is Created/to split and no payment information', o);
                                }
                                
                                List<Item_in_Order__c> op2 = [SELECT Name FROM Item_in_Order__c WHERE Commande__c =: o.Id AND Unit__c =: GDB_Constants.articleCode.get(2)];
                                
                                if(op2 != null && op2.size() > 0)
                                {
                                    Account accountOnOrder = o.Account__r;
                                    
                                    if(accountOnOrder != null)
                                    {
                                        accountOnOrder.GDB_Already_Bought_Six_Densified_Logs__c = true;
                                        
                                        update accountOnOrder;
                                    } 
                                    else 
                                    {
                                        GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'The Order Account is null, the Order is Created/to split and no payment information', o);
                                    }
                                } 
                                else 
                                {
                                    GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order items not found, the Order is Created/to split and no payment information', o);
                                }
                            }
                            
                            // Finally remove the current basket as it is not needed anymore
                            GDB_BasketMgr.removeBasket(GDB_BasketMgr.getCurrentBasket(false));

                            this.redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(5));
                        } 
                        else 
                        { 
                            // The response is not valid, update the current order status to failed
                            // Update fields error of the order
                            String codeError = String.isBlank(postResponse.getParameter('responseCode'))?GDB_Constants.codeErrorMercanet.get('PROBLEME_SERVEUR'):postResponse.getParameter('responseCode');
                            GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Mercanet response is not valid [' + codeError + ']: ' + String.valueOf(postResponse), o);
                            GDB_OrderMgr.failOrder(o, codeError);

                            this.redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(3)) + '?paymenterror=true';
                        }
                        
                        // Update child orders information
                        GDB_OrderMgr.updateChildOrdersAfterPayment(o);

                        // Finally remove the Order ID from the session
                        if (!Test.isRunningTest()) 
                        {
                            removeKeyInSessionCache(GDB_Constants.sessionKeys.get('orderId'));
                        }
                    // Else, Failed or another status which should not be here, return an error
                    } 
                    else 
                    {
                        GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order with an uncatched status which failed to validate the payment', o);
                        this.redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(3)) + '?paymenterror=true';
                        return null;
                    }
                } 
                else 
                {
                    GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Order is not found', o);
                }
            } 
            else 
            {
                o = GDB_OrderMgr.getOrderByOrderNo(postResponse.getTransactionReference());
                String codeError = String.isBlank(postResponse.getParameter('responseCode'))?GDB_Constants.codeErrorMercanet.get('PROBLEME_SERVEUR'):postResponse.getParameter('responseCode');
                GDB_OrderMgr.failOrder(o, codeError);
                GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'validateResponse', 'Mercanet response is not valid: ' + String.valueOf(postResponse), o);
            }

            if (this.redirectURL == null) 
            {
                this.redirectURL = GDB_Utils.getUrlWithPathPrefix(GDB_Constants.communityName, GDB_Constants.checkoutStepURLs.get(1));
            }

            return null;
        } 
        catch(Exception e) 
        {
            if(o != null) 
            {
                GDB_ErrorMgr.createErrorOrder('GDB_Checkout_ValidatePaymentController', 'catch_Exception', 'STACK_TRACE_' + e.getStackTraceString() + ' MESSAGE : ' + e.getMessage(), o);
            } 
            else 
            {
            	GDB_ErrorMgr.createError('GDB_Checkout_ValidatePaymentController', 'catch_Exception', 'STACK_TRACE_' + e.getStackTraceString() + ' MESSAGE : ' + e.getMessage());    
            }
        }

        return null;
    }
    
    /**
     * removeKeyInSessionCache Remove a key from Session cache
     * @param  {String} key
     */
    public void removeKeyInSessionCache(String key) {
        if(Cache.Session.contains(key)) {
            Cache.Session.remove(key);
        }
    }
}