public without sharing class GDB_OrderMgr {

    /**
     * createOrder Create a new order based on the given basket
     * @param {GDB_Basket__c} b
     * @returns {Order__c}
     */ 
    public static Order__c createOrder(GDB_Basket__c b) {
        String orderIdKey = GDB_Constants.sessionKeys.get('orderId');
        if (b == null) {
            return null;
        }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // Order
            Order__c o = new Order__c(
                RecordTypeId = GDB_Constants.orderTypeId,
                Order_Origin__c = GDB_Constants.orderOrigin,
                Order_Type__c = GDB_Constants.orderType,
                Mandataire__c = GDB_Constants.accountMandataireId,
                Activity_Domain__c = GDB_Constants.activityDomainId
            );
            o = GDB_OrderMgr.bindBasketToOrderAttributes(o, b, true);

            insert o;

            // Then store its ID in the session
            if (!Test.isRunningTest()) {
                Cache.Session.put(orderIdKey, o.Id);
            }
            // Reload order to have the autoincrement field gdb_orderNo__c
            o = GDB_OrderMgr.getOrderById(o.Id);
            o.Name = o.gdb_orderNo__c;
            o.ExternalID__c = o.gdb_orderNo__c;

            update o;

            // Create order line item with the current basket
            List<Item_in_Order__c> orderLineItems = GDB_OrderMgr.bindBasketProductsToOrderItems(b, true, o);
            insert orderLineItems;

            // Create order shipping option with the current basket
            List<gdb_order_shipping_option__c> orderShippingsOptions = GDB_OrderMgr.bindBasketShippingOptionToOrderShippingOption(b, o);
            insert orderShippingsOptions;

            // If multiple shipping is requested, create a new order without any prices
            // And without any line items
            if (b.gdb_multiple_shipping__c == true) {
                o.Order_Status__c = '8';
                o.RecordTypeId = GDB_Constants.orderSplitTypeId;
                update o;

                Order__c o2 = new Order__c(
                    RecordTypeId = GDB_Constants.orderSplitTypeId,
                    Order_Origin__c = GDB_Constants.orderOrigin,
                    Order_Type__c = GDB_Constants.orderType,
                    Mandataire__c = GDB_Constants.accountMandataireId,
                    Activity_Domain__c = GDB_Constants.activityDomainId
                );

                o2 = GDB_OrderMgr.bindBasketToOrderAttributes(o2, b, false);
                o2.gdb_parent_order__c = o.Id;
                o2.Order_Status__c = '9';
                insert o2;

                // Reload order to have the autoincrement field gdb_orderNo__c
                o2 = GDB_OrderMgr.getOrderById(o2.Id);
                o2.Name = o2.gdb_orderNo__c;
                if (!Test.isRunningTest()) {
                    o2.ExternalID__c = o2.gdb_orderNo__c;
                }
                update o2;

                // Create order line item with the current split basket
                List<Item_in_Order__c> orderLineItems2 = GDB_OrderMgr.bindBasketProductsToOrderItems(b, false, o2);
                insert orderLineItems2;

                // Create order shipping option with the current split basket
                List<gdb_order_shipping_option__c> orderShippingsOptions2 = GDB_OrderMgr.bindBasketShippingOptionToOrderShippingOption(b, o2);
                insert orderShippingsOptions2;
            }

            Account a = GDB_AccountMgr.getCurrentCustomer();

            if (String.isBlank(a.gdb_shipping_city__c)) {
                GDB_AccountMgr.saveShippingAddress(getShippingAddressForm(b));
            }

            if (String.isBlank(a.gdb_billing_city__c) && !b.gdb_use_shipping_as_billing__c) {
                GDB_AccountMgr.saveBillingAddress(getBillingAddressForm(b));
            }

            return o;
        } catch (Exception e) {
            Database.rollback(sp);
            if (GDB_Constants.isErrorTracingActive) {
                GDB_ErrorMgr.createError('GDB_OrderMgr', 'createOrder', e.getStackTraceString());
            }
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order creation for the basket "' +
                String.valueOf(b.Id) + '" and the customer "' + b.gdb_Account__c + '": ' + e.getMessage());
        }

        return null;
    }

    /**
     * createOrderB2B Create a new order based on the given basket
     * @param {GDB_Basket__c} b
     * @returns {Order__c}
     */
    public static Order__c createOrderB2B(GDB_Basket__c b) {
        String orderIdKey = GDB_Constants.sessionKeys.get('orderId');
        if (b == null) {
            return null;
        }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // Order
            Order__c o = new Order__c(
                RecordTypeId = GDB_Constants.orderTypeId,
                Order_Origin__c = GDB_Constants.orderOrigin,
                Order_Type__c = GDB_Constants.orderType,
                Mandataire__c = GDB_Constants.accountMandataireId,
                Activity_Domain__c = GDB_Constants.activityDomainId
            );

            o = GDB_OrderMgr.bindBasketToOrderAttributes(o, b, false);

            insert o;

            // Then store its ID in the session
            if (!Test.isRunningTest()) {
                Cache.Session.put(orderIdKey, o.Id);
            }
            // Reload order to have the autoincrement field gdb_orderNo__c
            o = GDB_OrderMgr.getOrderById(o.Id);
            o.Name = o.gdb_orderNo__c;
            o.ExternalID__c = o.gdb_orderNo__c;

            update o;

            List<Item_in_Order__c> orderLineItems = GDB_OrderMgr.bindBasketProductsToOrderItems(b, true, o);
            // Surcharge price
            for(Item_in_Order__c op : orderLineItems ){
                    op.gdb_total_gross_price__c = 0;
                    op.gdb_total_net_price__c = 0;
                    op.gdb_total_tax__c = 0;
                    op.gdb_unit_gross_price__c = 0;
                    op.gdb_unit_net_price__c = 0;
                    op.gdb_unit_tax__c = 0;
                    
                }
            insert orderLineItems;

            o.Order_Status__c = '4';
            o.gdb_payment_status__c = 'Pending';
            update o;

            Account a = GDB_AccountMgr.getCurrentCustomer();

            if (String.isBlank(a.gdb_shipping_city__c)) {
                GDB_AccountMgr.saveShippingAddress(getShippingAddressForm(b));
            }

            GDB_BasketMgr.removeBasket(GDB_BasketMgr.getCurrentBasket(false));

            return o;
        } catch (Exception e) {
            Database.rollback(sp);
            if (GDB_Constants.isErrorTracingActive) {
                GDB_ErrorMgr.createError('GDB_OrderMgr', 'createOrder', e.getMessage() + ' ' + e.getStackTraceString());
            }
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order creation for the basket "' +
                String.valueOf(b.Id) + '" and the customer "' + b.gdb_Account__c + '": ' + e.getMessage());
        }

        return null;
    }

    /**
     * createOrder Create a new order based on the given account
     * @param {Account} a
     * @returns {Order__c}
     */
    public static Order__c createSampleOrder(Map<String, String> detailsForm) {
        if (detailsForm == null) {
            return null;
        }

        String submittedForm = 'Salutation_' + detailsForm.get('salutation');
        submittedForm += '_Firstname_' + detailsForm.get('firstName');
        submittedForm += '_LastName_' + detailsForm.get('lastName');
        submittedForm += '_Address1_' + detailsForm.get('address1');
        submittedForm += '_Address2_' + detailsForm.get('address1');
        submittedForm += '_Address3_' + detailsForm.get('address1');
        submittedForm += '_City_' + detailsForm.get('city');
        submittedForm += '_Zip_' + detailsForm.get('zip');
        submittedForm += '_Country_' + detailsForm.get('country');
        submittedForm += '_Phone_' + detailsForm.get('phone');
        submittedForm += '_ProductId_' + detailsForm.get('productId');

        List<GDB_ArticleVM> items = GDB_ProductUtils.getProducts(detailsForm.get('productId'));
        if (items == null || items.size() == 0) {
            submittedForm += '_No_Product_found';
            GDB_ErrorMgr.createError('GDB_OrderMgr', 'createSampleOrder', submittedForm);
            return null;
        }

        Order__c o;
        Account a;
        try {
            String fullAddress = String.join(new List<String>{
                detailsForm.get('lastName').trim().toLowerCase(),
                detailsForm.get('city').trim().toLowerCase()
            }, '');

            a = GDB_AccountMgr.getCurrentCustomer();
            GDB_Warehouse__c warehouse = GDB_WarehouseMgr.findWarehouseBasedOnZipCode(detailsForm.get('zip'), true);

            if (a == null) {
                submittedForm += '_No_Account_found';
                GDB_ErrorMgr.createError('GDB_OrderMgr', 'createSampleOrder', submittedForm);
                return null;
            }

            // Insert Order
            o = new Order__c(
                RecordTypeId = GDB_Constants.orderTypeId,
                Order_Origin__c = GDB_Constants.orderOrigin,
                Order_Type__c = GDB_Constants.orderType,
                Mandataire__c = GDB_Constants.accountMandataireId,
                Account__c = a.Id,
                Activity_Domain__c = GDB_Constants.activityDomainId,
                Order_Date_and_Time__c = DateTime.now(),
                Order_Status__c = '3',
                gdb_isSample__c = true,
                gdb_Warehouse__c = (warehouse == null) ? null : warehouse.Id,
                // Shipping address
                gdb_shipping_salutation__c = detailsForm.get('salutation'),
                gdb_shipping_firstname__c = detailsForm.get('firstName'),
                gdb_shipping_lastname__c = detailsForm.get('lastName'),
                gdb_shipping_address1__c = detailsForm.get('address1'),
                gdb_shipping_address2__c = detailsForm.get('address2'),
                gdb_shipping_address3__c = detailsForm.get('address3'),
                gdb_shipping_city__c = detailsForm.get('city'),
                gdb_shipping_zip__c = detailsForm.get('zip'),
                gdb_shipping_country__c = detailsForm.get('country'),
                gdb_shipping_phone__c = detailsForm.get('phone'),
                gdb_shipping_instructions__c = detailsForm.get('shippingInstructions'),
                // Billing address
                gdb_billing_salutation__c = detailsForm.get('salutation'),
                gdb_billing_firstname__c = detailsForm.get('firstName'),
                gdb_billing_lastname__c = detailsForm.get('lastName'),
                gdb_billing_address1__c = detailsForm.get('address1'),
                gdb_billing_address2__c = detailsForm.get('address2'),
                gdb_billing_address3__c = detailsForm.get('address3'),
                gdb_billing_city__c = detailsForm.get('city'),
                gdb_billing_zip__c = detailsForm.get('zip'),
                gdb_billing_country__c = detailsForm.get('country'),
                gdb_billing_phone__c = detailsForm.get('phone'),
                // Account details
                gdb_customer_title__c = a.Salutation,
                gdb_customer_firstname__c = detailsForm.get('firstName'),
                gdb_customer_lastname__c = detailsForm.get('lastName'),
                gdb_email__c = a.Email__c,
                Full_Address__c = fullAddress,
                // Prices
                gdb_shipping_price__c = 0,
                gdb_shipping_tax__c = 0,
                gdb_discount_price__c = 0,
                gdb_discount_tax__c = 0,
                gdb_total_gross_price__c = 0,
                gdb_total_net_price__c = 0,
                gdb_total_tax__c = 0
            );
            insert o;
            submittedForm += '_Order inserted';

            // Reload order to have the autoincrement field gdb_orderNo__c
            o = GDB_OrderMgr.getOrderById(o.Id);
            o.ExternalID__c = o.gdb_orderNo__c;
            o.Name = o.gdb_orderNo__c;
            update o;

            submittedForm += '_Order updated';

            // Insert Lineitem
            GDB_ArticleVM i = items.get(0);
            Item_in_Order__c op = new Item_in_Order__c(
                Article__c = i.Id,
                Commande__c = o.Id,
                // Attributes
                gdb_name__c = i.Name,
                gdb_description__c = i.description,
                Unit__c = i.code,
                Quantity__c = 1,
                // Prices
                gdb_total_gross_price__c = 0,
                gdb_total_net_price__c = 0,
                gdb_total_tax__c = 0,
                gdb_unit_gross_price__c = 0,
                gdb_unit_net_price__c = 0,
                gdb_unit_tax__c = 0
            );
            insert op;
            submittedForm += '_Item_in_Order inserted';

            if (GDB_OrderMgr.isSampleOrderFraudSubsected(o)) {
                submittedForm += '_Fraud suspected';
                GDB_OrderMgr.updateOrderStatus(o, '10'); // Mark order as fraud suspected
            } else {
                submittedForm += '_Change order status to registered';
                GDB_OrderMgr.updateOrderStatus(o, '4'); // Mark order as registered
            }
        } catch (Exception e) {
            GDB_ErrorMgr.createError('GDB_OrderMgr', 'createSampleOrder', submittedForm + '_EXCEPTION_' + e.getStackTraceString());
            System.debug(System.LoggingLevel.ERROR,
                'An error occured during the sample order creation for the customer "' + a.Id + '": ' + e.getMessage()
            );
            return null;
        }

        // Update stock for all ordered products
        o = GDB_OrderMgr.getOrderById(o.Id);
        GDB_OrderMgr.decreaseStocks(o);
        submittedForm += '_Stock decreased';
        GDB_ErrorMgr.createError('GDB_OrderMgr', 'createSampleOrder', submittedForm);
        return o;
    }

    /**
     * isSampleOrderFraudSubsected This method check if a sample order exists with the exactly same Full_Address__c field
     * @param {Order__c} o
     **/
    public static Boolean isSampleOrderFraudSubsected(Order__c o) {
        if (o == null) {
            return false;
        }

        Integer numberOfRows = [
            SELECT
            COUNT()
            FROM Order__c
            WHERE gdb_isSample__c = true
            AND Full_Address__c =: o.Full_Address__c
            AND Activity_Domain__c =: GDB_Constants.activityDomainId
        ];

        return numberOfRows > 1;
    }

    /**
     * getCurrentOrder Returns the current order from the session
     * @return {Order__c}
     */
    public static Order__c getCurrentOrder() {
        String idKey = GDB_Constants.sessionKeys.get('orderId');
        List<Order__c> orders = new List<Order__c> ();
        Account account = GDB_AccountMgr.getCurrentCustomer();

        if (Test.isRunningTest() || !Cache.Session.contains(idKey)) {
            if (account != null) {
                orders = [
                    SELECT
                    Account__r.Email__c,
                    Account__r.FirstName,
                    Account__r.LastName,
                    Account__r.gdb_accountNo__c,
                    Account__r.gdb_parrainage_code__c,
                    Activity_Domain__c,
                    Full_Address__c,
                    gdb_isSample__c,
                    gdb_billing_salutation__c,
                    gdb_billing_firstname__c,
                    gdb_billing_lastname__c,
                    gdb_billing_address1__c,
                    gdb_billing_address2__c,
                    gdb_billing_address3__c,
                    gdb_billing_city__c,
                    gdb_billing_country__c,
                    gdb_billing_phone__c,
                    gdb_billing_zip__c,
                    gdb_coupon_code__c,
                    gdb_customer_firstname__c,
                    gdb_customer_lastname__c,
                    gdb_customer_title__c,
                    gdb_discount_price__c,
                    gdb_discount_tax__c,
                    gdb_email__c,
                    gdb_multiple_payment__c,
                    gdb_multiple_shipping__c,
                    gdb_shipping_instructions__c,
                    gdb_orderNo__c,
                    gdb_payment_date__c,
                    gdb_payment_method_name__c,
                    gdb_Payment_Method__c,
                    gdb_payment_status__c,
                    gdb_shipping_salutation__c,
                    gdb_shipping_firstname__c,
                    gdb_shipping_lastname__c,
                    gdb_shipping_address1__c,
                    gdb_shipping_address2__c,
                    gdb_shipping_address3__c,
                    gdb_shipping_city__c,
                    gdb_shipping_country__c,
                    gdb_shipping_date__c,
                    gdb_shipping_method_name__c,
                    gdb_shipping_method_title__c,
                    gdb_Shipping_Method__c,
                    gdb_shipping_phone__c,
                    gdb_shipping_price__c,
                    gdb_shipping_tax__c,
                    gdb_shipping_option_price__c,
                    gdb_shipping_option_tax__c,
                    gdb_shipping_status__c,
                    gdb_shipping_zip__c,
                    gdb_total_gross_price__c,
                    gdb_total_net_price__c,
                    gdb_total_tax__c,
                    gdb_authorisation_id__c,
                    gdb_transaction_id__c,
                    gdb_validation_date__c,
                    gdb_parent_order__c,
                    Name,
                    Order_Date_and_Time__c,
                    Order_Status__c,
                    gdb_isB2B__c,
                    PlanificationAppointmentHour__c,
                    gdb_multiple_payment_price__c,
                    (
                        SELECT Article__c,
                        Article__r.gdb_bv_external_id__c,
                        gdb_description__c,
                        gdb_name__c,
                        gdb_sku__c,
                        gdb_total_gross_price__c,
                        gdb_total_net_price__c,
                        gdb_total_tax__c,
                        gdb_unit_gross_price__c,
                        gdb_unit_net_price__c,
                        gdb_unit_tax__c,
                        Name,
                        Quantity__c,
                        gdb_warehouse__c,
                        gdb_quantitywarehouse__c,
                        Unit__c FROM Articles_dans_Commande__r
                    )
                    FROM Order__c
                    WHERE Account__c =: account.Id
                    AND Order_Status__c != '5'
                    AND Order_Status__c != '9'
                    AND gdb_parent_order__c = null
                    ORDER BY LastModifiedDate desc
                ];
            }
        } else {
            orders.add(GDB_OrderMgr.getOrderById((String) Cache.Session.get(idKey)));
        }

        if (orders == null || orders.size() == 0) {
            if (Test.isRunningTest() && account != null) {
                orders = GDB_OrderMgr.getOrdersForAccount(account.Id);

                if (orders == null || orders.size() == 0) {
                    return null;
                }
            }
            return null;
        }

        return orders.get(0);
    }

    /**
     * getOrderByOrderNo Returns the order that matching with the given order no or null if no order found or if the given order no is null
     * @param {String} orderNo
     * @return {Order__c}
     */
    public static Order__c getOrderByOrderNo(String orderNo) {
        if (String.isBlank(orderNo)) {
            return null;
        }

        List<Order__c> orders = [
            SELECT
            Account__r.Id,
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.gdb_accountNo__c,
            Account__r.gdb_parrainage_code__c,
            Account__r.gdb_already_bought_bundle__c,
            Account__r.GDB_Already_Bought_Six_Densified_Logs__c,
            Activity_Domain__c,
            Full_Address__c,
            gdb_isSample__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_Discount__c,
            gdb_Discount__r.Name,
            gdb_discount_price__c,
            gdb_discount_tax__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_shipping_instructions__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_shipping_method_title__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_option_price__c,
            gdb_shipping_option_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_parent_order__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            ExternalID__c,
            gdb_isB2B__c,
            gdb_error_code__c,
            PlanificationAppointmentHour__c,
            gdb_multiple_payment_price__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                gdb_warehouse__c,
                gdb_quantitywarehouse__c,
                Unit__c FROM Articles_dans_Commande__r
            )
            FROM Order__c
            WHERE gdb_orderNo__c =: orderNo
        ];

        if (orders == null || orders.size() == 0) {
            return null;
        }

        return orders.get(0);
    }

    /**
     * getOrdersForAccount Returns all orders related to the given account id
     * @param {Id} accountId
     * @return {List<Order__c>}
     */
    public static List<Order__c> getOrdersForAccount(Id accountId) {
        if (String.isBlank(accountId)) {
            return null;
        }

        return [
            SELECT
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.gdb_accountNo__c,
            Account__r.gdb_parrainage_code__c,
            Activity_Domain__c,
            Full_Address__c,
            gdb_isSample__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_discount_price__c,
            gdb_discount_tax__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_shipping_instructions__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_shipping_method_title__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_option_price__c,
            gdb_shipping_option_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_parent_order__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            gdb_isB2B__c,
            PlanificationAppointmentHour__c,
            gdb_wished_shipping_date__c,
            gdb_multiple_payment_price__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                gdb_warehouse__c,
                gdb_quantitywarehouse__c,
                Unit__c FROM Articles_dans_Commande__r
            ),
            (
                SELECT gdb_sap_invoice_no__c,gdb_Invoice_URL__c FROM Invoices__r
            )
            FROM Order__c
            WHERE Account__c =: accountId
            AND(Order_Status__c = '4' // Order saved
                OR Order_Status__c = '6' // Order checked
                OR Order_Status__c = '7' // Order delivered
                OR(Order_Status__c = '8' and gdb_transaction_id__c != null and gdb_parent_order__c = null)) // Order to divide
            AND gdb_payment_status__c = :GDB_Constants.orderPaymentStatus.get(2)
            ORDER BY Order_Date_and_Time__c DESC
        ];
    }

    /**
     * getOrderByOrderNo Returns the order that matching with the given order no or null if no order found or if the given order no is null
     * @param {String} orderNo
     * @return {Order__c}
     */
    public static Order__c getOrderByName(String name) {
        if (String.isBlank(name)) {
            return null;
        }

        List<Order__c> orders = [
            SELECT
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.gdb_accountNo__c,
            Account__r.gdb_parrainage_code__c,
            Activity_Domain__c,
            Full_Address__c,
            gdb_isSample__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_Discount__r.Name,
            gdb_discount_price__c,
            gdb_discount_tax__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_shipping_instructions__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_shipping_method_title__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_option_price__c,
            gdb_shipping_option_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_parent_order__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            ExternalID__c,
            gdb_isB2B__c,
            PlanificationAppointmentHour__c,
            gdb_multiple_payment_price__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                gdb_warehouse__c,
                gdb_quantitywarehouse__c,
                Unit__c FROM Articles_dans_Commande__r
            )
            FROM Order__c
            WHERE Name =: name
        ];

        if (orders == null || orders.size() == 0) {
            return null;
        }

        return orders.get(0);
    }

    /**
     * getSampleOrdersForAccount Returns all sample orders related to the given account id
     * @param {Id} accountId
     * @return {List<Order__c>}
     */
    public static List<Order__c> getSampleOrdersForAccount(Id accountId) {
        if (String.isBlank(accountId)) {
            return null;
        }
        return [
            SELECT
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.gdb_accountNo__c,
            Account__r.gdb_parrainage_code__c,
            Activity_Domain__c,
            gdb_isSample__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_discount_price__c,
            gdb_discount_tax__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_shipping_instructions__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_shipping_method_title__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_option_price__c,
            gdb_shipping_option_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_parent_order__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            gdb_isB2B__c,
            PlanificationAppointmentHour__c,
            gdb_multiple_payment_price__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                gdb_warehouse__c,
                gdb_quantitywarehouse__c,
                Unit__c FROM Articles_dans_Commande__r
            ),
            (
                SELECT gdb_Invoice_URL__c FROM Invoices__r
            )
            FROM Order__c
            WHERE Account__c =: accountId
            AND gdb_isSample__c = true
            AND Order_Status__c != '3'
        ];
    }

    /**
     * bindBasketToOrderAttributes Bind basket attributes to a new order instance without inserting it in database
     * @param {Order__c} o
     * @param {GDB_Basket__c} b
     * @param {Boolean} withPrices
     * @return {Order__c}
     */
    public static Order__c bindBasketToOrderAttributes(Order__c o, GDB_Basket__c b, Boolean withPrices) {
        if (o == null || b == null) {
            return null;
        }

        // Relationships
        o.Account__c = b.gdb_Account__c;
        o.Activity_Domain__c = b.gdb_Activity_Domain__c;
        o.gdb_Discount__c = b.gdb_Discount__c;
        o.gdb_Payment_Method__c = b.gdb_Payment_Method__c;
        o.gdb_Shipping_Method__c = b.gdb_Shipping_Method__c;
        o.gdb_wished_shipping_date__c = b.gdb_wished_shipping_date__c;

        // Addresse billing en fonction du type de basket
        if (b.gdb_isB2B__c) {
            Account a = GDB_AccountMgr.getCurrentAccountREByContract();

            o.gdb_billing_lastname__c = a.Name;

            if(String.isEmpty(a.Street_Number__c)){
                String placeholder = '{0} {1} {2} {3}';
                List<String> values = new String[] {
                    !String.isBlank(a.Street_N__c) ? a.Street_N__c : '',
                    !String.isBlank(a.Number_extention__c) ? a.Number_extention__c : '',
                    !String.isBlank(a.Street_type__c) ? a.Street_type__c : '',
                    !String.isBlank(a.Street_name__c) ? a.Street_name__c : ''
                };
                o.gdb_billing_address1__c = String.format(placeholder, values);
            }
            else{
                o.gdb_billing_address1__c = a.Street_Number__c;
            }

            o.gdb_billing_address2__c = a.Lieu_dit__c;
            o.gdb_billing_country__c = a.Country__c;

            if (!String.isBlank(a.City_Postal_Code__r.City__r.Name) && !String.isBlank(a.City_Postal_Code__r.Postal_Code__c)) {
                o.gdb_billing_city__c = a.City_Postal_Code__r.City__r.Name;
                o.gdb_billing_zip__c = a.City_Postal_Code__r.Postal_Code__c;
            } else {
                o.gdb_billing_city__c = a.City__c;
                o.gdb_billing_zip__c = a.Postal_Code__c;
            }

        } else {
            o.gdb_billing_salutation__c = b.gdb_billing_salutation__c;
            o.gdb_billing_firstname__c = b.gdb_billing_firstname__c;
            o.gdb_billing_lastname__c = b.gdb_billing_lastname__c;
            o.gdb_billing_address1__c = b.gdb_billing_address1__c;
            o.gdb_billing_address2__c = b.gdb_billing_address2__c;
            o.gdb_billing_address3__c = b.gdb_billing_address3__c;
            o.gdb_billing_city__c = b.gdb_billing_city__c;
            o.gdb_billing_zip__c = b.gdb_billing_zip__c;
            o.gdb_billing_country__c = b.gdb_billing_country__c;
            o.gdb_billing_phone__c = b.gdb_billing_phone__c;
        }

        // Addresse Shipping
        o.gdb_shipping_salutation__c = b.gdb_shipping_salutation__c;
        o.gdb_shipping_firstname__c = b.gdb_shipping_firstname__c;
        o.gdb_shipping_lastname__c = b.gdb_shipping_lastname__c;
        o.gdb_shipping_address1__c = b.gdb_shipping_address1__c;
        o.gdb_shipping_address2__c = b.gdb_shipping_address2__c;
        o.gdb_shipping_address3__c = b.gdb_shipping_address3__c;
        o.gdb_shipping_city__c = b.gdb_shipping_city__c;
        o.gdb_shipping_zip__c = b.gdb_shipping_zip__c;
        o.gdb_shipping_country__c = b.gdb_shipping_country__c;
        o.gdb_shipping_phone__c = b.gdb_shipping_phone__c;
        // Account details
        o.gdb_customer_title__c = b.gdb_Account__r.Salutation;
        o.gdb_customer_firstname__c = b.gdb_Account__r.FirstName;
        o.gdb_customer_lastname__c = b.gdb_Account__r.LastName;
        o.gdb_email__c = b.gdb_Account__r.Email__c;
        // Attributes
        o.gdb_coupon_code__c = b.gdb_coupon_code__c;
        o.gdb_payment_method_name__c = b.gdb_payment_method_name__c;
        o.gdb_shipping_method_name__c = b.gdb_shipping_method_name__c;
        o.gdb_shipping_method_description__c = b.gdb_shipping_method_description__c;
        o.gdb_shipping_method_title__c = b.gdb_shipping_method_title__c;
        o.gdb_multiple_shipping__c = b.gdb_multiple_shipping__c;
        o.gdb_multiple_payment__c = b.gdb_multiple_payment__c;
        o.gdb_shipping_instructions__c = b.gdb_shipping_instructions__c;
        o.gdb_isB2B__c = b.gdb_isB2B__c;

        o.Order_Date_and_Time__c = DateTime.now();
        o.Order_Status__c = '3';
        // Initialize prices as 0 and bind them after if required
        o.gdb_shipping_price__c = 0;
        o.gdb_shipping_tax__c = 0;
        o.gdb_discount_price__c = 0;
        o.gdb_discount_tax__c = 0;
        o.gdb_total_gross_price__c = 0;
        o.gdb_total_net_price__c = 0;
        o.gdb_total_tax__c = 0;
        o.gdb_shipping_option_price__c = 0;
        o.gdb_shipping_option_tax__c = 0;
        o.gdb_multiple_payment_price__c = 0;

        if (withPrices) {
            // Prices
            o.gdb_shipping_price__c = b.gdb_shipping_method_price__c;
            o.gdb_shipping_tax__c = b.gdb_shipping_method_tax__c;
            o.gdb_shipping_option_price__c = b.gdb_shipping_option_price__c;
            o.gdb_shipping_option_tax__c = b.gdb_shipping_option_tax__c;
            o.gdb_discount_price__c = b.gdb_discount_price__c;
            o.gdb_discount_tax__c = b.gdb_discount_tax__c;
            o.gdb_multiple_payment_price__c = b.gdb_multiple_payment_price__c;
            o.gdb_total_gross_price__c = b.gdb_total_price__c;
            o.gdb_total_net_price__c = b.gdb_total_price__c - b.gdb_total_tax__c;
            o.gdb_total_tax__c = b.gdb_total_tax__c;
        }
        
        // Binding warehouse ( Si au moins une palette alors PRAXEDO sinon STACI)
        Id warehouseId;
        for(GDB_Basket_Product__c lineItem : b.Basket_Products__r) {
            if( lineItem.gdb_warehouse__r.gdb_shipping_carrier__c == GDB_Constants.warehouseName.get(1)){
                warehouseId = lineItem.gdb_warehouse__r.Id;
                break;
            }
            else{
                warehouseId = lineItem.gdb_warehouse__r.Id;
            }
        }
            
        GDB_Warehouse__c warehouseOrder = [SELECT ID FROM GDB_Warehouse__c WHERE id =: warehouseId LIMIT 1];  
        
        if(warehouseOrder != null){
            o.gdb_Warehouse__c = warehouseOrder.Id;
        }

        return o;
    }

    /**
     * bindBasketProductsToOrderItems Bind basket product attributes to new order items without inserting them in database
     * @param {GDB_Basket__c} b
     * @param {Boolean} withPrices
     * @return {Order__c}
     */
    public static List<Item_in_Order__c> bindBasketProductsToOrderItems(GDB_Basket__c b, Boolean withPrices, Order__c o) {
        if (b == null || o == null) {
            return null;
        }

        List<Item_in_Order__c> orderLineItems = new List<Item_in_Order__c>();
        for (GDB_Basket_Product__c bp: b.Basket_Products__r) {
            Item_in_Order__c op = new Item_in_Order__c(
                // Attributes
                gdb_name__c = bp.Name,
                gdb_description__c = bp.gdb_description__c,
                Unit__c = bp.gdb_product_code__c,
                Quantity__c = 0,
                gdb_quantitywarehouse__c = bp.gdb_quantitywarehousecoefficient__c,
                gdb_sku__c = bp.gdb_sku__c,
                // Prices
                gdb_total_gross_price__c = 0,
                gdb_total_net_price__c = 0,
                gdb_total_tax__c = 0,
                gdb_unit_gross_price__c = bp.gdb_unit_price__c,
                gdb_unit_net_price__c = bp.gdb_unit_price__c - bp.gdb_unit_tax__c,
                gdb_unit_tax__c = bp.gdb_unit_tax__c,
                gdb_warehouse__c = bp.gdb_warehouse__c,
                Article__c = bp.gdb_Article__c,
                gdb_unit_price_warehouse__c = bp.gdb_unit_price_warehouse__c,
                gdb_unit_tax_warehouse__c = bp.gdb_unit_tax_warehouse__c,
                Commande__c = o.Id
            );

            if (withPrices) {
                // Calcul de la quantité entrepôt
                if (bp.gdb_quantitywarehousecoefficient__c != null && bp.gdb_quantitywarehousecoefficient__c > 0) {
                    op.gdb_quantitywarehouse__c = bp.gdb_quantity__c * bp.gdb_quantitywarehousecoefficient__c;
                } else {
                    op.gdb_quantitywarehouse__c = bp.gdb_quantity__c;
                }

                // Quantité
                op.Quantity__c = bp.gdb_quantity__c;

                // Prices
                op.gdb_total_gross_price__c = bp.gdb_total_price__c;
                op.gdb_total_net_price__c = bp.gdb_total_price__c - bp.gdb_total_tax__c;
                op.gdb_total_tax__c = bp.gdb_total_tax__c;
            }

            orderLineItems.add(op);
        }

        return orderLineItems;
    }

    /**
     * bindBasketShippingOptionToOrderShipping : Bind basket shipping option to new order without inserting them in database
     * @param {GDB_Basket__c} b
     * @param {Order__c}
     * @return {List<gdb_order_shipping_option__c>}
     */
    public static List<gdb_order_shipping_option__c> bindBasketShippingOptionToOrderShippingOption(GDB_Basket__c b, Order__c o) {
        if (b == null || o == null) {
            return null;
        }

        // Delete oldest order shippings options
        List<gdb_order_shipping_option__c> orderShippingsOptionsToDelete = [SELECT Id FROM gdb_order_shipping_option__c WHERE gdb_order__c = :o.Id];
        if(orderShippingsOptionsToDelete != null && !orderShippingsOptionsToDelete.isEmpty()){
            delete orderShippingsOptionsToDelete;
        }

        // Get basket shipping option fir the current basket
        List<gdb_basket_shipping_option__c> basketShippingsOptions = [SELECT Id, gdb_Shipping_Option__c FROM gdb_basket_shipping_option__c WHERE gdb_Basket__c = :b.Id];

        // Create tne new order shipping option with this list
        List<gdb_order_shipping_option__c> orderShippingsOptions = new List<gdb_order_shipping_option__c>();
        Integer i = 1;
        for (gdb_basket_shipping_option__c bso: basketShippingsOptions) {
            gdb_order_shipping_option__c oso = new gdb_order_shipping_option__c();
            oso.Name = o.Name + ' ' + Label.GDB_prefixe_name_shipping_option + ' ' + i;
            oso.gdb_order__c = o.Id;
            oso.gdb_Shipping_Option__c = bso.gdb_Shipping_Option__c;
            orderShippingsOptions.add(oso);
            i++;
        }

        return orderShippingsOptions;
    }

    /**
     * successOrder Success the given order (Update required statuses and stocks)
     * @param {Order__c} o
     */
    public static void successOrder(Order__c o) {
        if (o == null) {
            return;
        }

        // Don't change status for multiple shipping on success payment
        // because we can't split
        if (!o.gdb_multiple_shipping__c) {
            GDB_OrderMgr.updateOrderStatus(o, '4'); // 4 === Order saved
        }
        
        GDB_OrderMgr.updatePaymentStatus(o, GDB_Constants.orderPaymentStatus.get(2));
        // Update stock for all ordered products
        GDB_OrderMgr.decreaseStocks(o);

        // Finally a    pply the discount on the customer if needed
        if (o.gdb_Discount__c != null) {
            GDB_OrderMgr.applyDiscountOnCustomer(o);
        }
    }

    /**
     * failOrder Fail the given order (Update required statuses)
     *
     * @param {Order__c} o     
     * @param {String} codeError
     *
     */
    public static void failOrder(Order__c o, String codeError) {
        if (o == null) {
            return;
        }

        // Update order statuses
        try {
            if (!String.isBlank(codeError)) {
                o.gdb_error_code__c = codeError;
            }

            if (codeError == GDB_Constants.codeErrorMercanet.get('ANNULATION')) {
                o.gdb_payment_status__c = GDB_Constants.orderPaymentStatus.get(3); // Statut Cancelled
                o.Order_Status__c = '11'; // 11 === Order cancelled
            } else {
                o.gdb_payment_status__c = GDB_Constants.orderPaymentStatus.get(1); // Statut Failed
                o.Order_Status__c = '5'; // 5 === Order failed
            }
            o.gdb_payment_date__c = Datetime.now();

            update o;

        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order update for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * applyDiscountOnCustomer Apply the promotion related to the given order on the current customer
     * This way, the customer cannot apply the promotion twice
     *
     * @param {Order__c} o
     *
     **/
    public static void applyDiscountOnCustomer(Order__c o) {
        if (o != null) {
            Account a = o.Account__r;

            GDB_Account_Has_Promotion__c junction = new GDB_Account_Has_Promotion__c(
                gdb_Account__c = a.Id,
                gdb_Promotion__c = o.gdb_Discount__c
            );

            insert junction;
        }
    }

    /**
     * updateOrderPaymentDetails Update the given order with the given transaction ID and authorisation ID
     *
     * @param {Order__c} o
     * @param {String} transactionId
     * @param {String} authorisationId
     */
    public static void updateOrderPaymentDetails(Order__c o, String transactionId, String authorisationId) {
        if (o == null) {
            return;
        }

        try {
            Order__c o2 = new Order__c();
            o2.Id = o.Id;
            o2.gdb_transaction_id__c = transactionId;
            o2.gdb_authorisation_id__c = authorisationId;
            update o2;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order update for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * updateOrderStatus Update the given order status with the given status
     *
     * @param {Order__c} o
     * @param {String} status
     */
    public static void updateOrderStatus(Order__c o, String status) {
        if (o == null) {
            return;
        }

        try {
            o.Order_Status__c = status;
            update o;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order update for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * updatePaymentStatus Update the given order payment status with the given status
     *
     * @param {Order__c} o
     * @param {String} status
     */
    public static void updatePaymentStatus(Order__c o, String status) {
        if (o == null) {
            return;
        }

        try {
            o.gdb_payment_status__c = status;
            o.gdb_payment_date__c = Datetime.now();
            update o;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the order update for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * decreaseStocks Decrease stocks values on Warehouse_Has_Product records associated to order line items
     *
     * @param {Order__c} o
     **/
    public static void decreaseStocks(Order__c o) {
        if (o == null) {
            return;
        }

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            List<GDB_Warehouse_Has_Product__c> junctions = new List<GDB_Warehouse_Has_Product__c> ();

            for (Item_in_Order__c lineItem: o.Articles_dans_Commande__r) {
                List<GDB_Warehouse_Has_Product__c> wajs = [
                    SELECT
                    gdb_Article__c,
                    gdb_Warehouse__c,
                    gdb_quantity__c
                    FROM GDB_Warehouse_Has_Product__c
                    WHERE gdb_Article__c =: lineItem.Article__c
                    AND gdb_Warehouse__c =: lineItem.gdb_warehouse__c
                    LIMIT 1
                ];

                if (wajs != null && wajs.size() != 0) {
                    GDB_Warehouse_Has_Product__c waj = wajs.get(0);
                    waj.gdb_quantity__c -= lineItem.Quantity__c;
                    junctions.add(waj);
                }
            }

            update junctions;
        } catch (Exception e) {
            Database.rollback(sp);
            if (GDB_Constants.isErrorTracingActive) {
                GDB_ErrorMgr.createError('GDB_OrderMgr', 'decreaseStocks', e.getStackTraceString());
            }
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the stocks update for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * updateChildOrders Updates child order after payment
     * @param  {Order__c} o
     */
    public static void updateChildOrdersAfterPayment(Order__c o) {
        if (o == null) {
            return;
        }

        try {
            List<Order__c> childOrders = getChildOrders(o.Id);
            for (Order__c childOrder: childOrders) {
                childOrder.Order_Status__c = o.Order_Status__c;
                childOrder.gdb_payment_status__c = childOrder.gdb_parent_order__r.gdb_payment_status__c;
                childOrder.gdb_payment_date__c = childOrder.gdb_parent_order__r.gdb_payment_date__c;
                childOrder.gdb_transaction_id__c = childOrder.gdb_parent_order__r.gdb_transaction_id__c;
                childOrder.gdb_authorisation_id__c = childOrder.gdb_parent_order__r.gdb_authorisation_id__c;
            }
            update childOrders;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'An error occured when updating child orders for order "' + o.gdb_orderNo__c +
                '": ' + e.getMessage());
        }
    }

    /**
     * getChildOrders description
     * @param  orderId orderId description
     * @return         return description
     */
    public static List<Order__c> getChildOrders(String orderId) {
        if (String.isBlank(orderId)) {
            return null;
        }

        return [SELECT ID, Name,
            (
                SELECT gdb_description__c,
                Article__c,
                gdb_name__c,
                Article_Name__c,
                gdb_sku__c,
                Name,
                Quantity__c,
                gdb_unit_net_price__c,
                gdb_unit_gross_price__c,
                gdb_unit_tax__c,
                gdb_quantitywarehouse__c FROM Articles_dans_Commande__r ORDER BY gdb_sku__c
            ),
            gdb_parent_order__r.gdb_payment_status__c,
            gdb_parent_order__r.gdb_payment_date__c,
            gdb_parent_order__r.gdb_transaction_id__c,
            gdb_parent_order__r.gdb_authorisation_id__c
            FROM Order__c
            WHERE gdb_parent_order__c =: orderId
        ];
    }

    /**
     * recalculateOrder Recalculate order after divide it.
     * @param {Order__c} order
     * @param {Booelean} parentOrder
     */
    public static void recalculateOrder(Order__c order, Boolean parentOrder) {
        if (order == null || parentOrder == null) {
            return;
        }

        // Update the order totals
        Double totalNetPrice = 0;
        Double totalGrossPrice = 0;
        Double totalTax = 0;

        // Update Items in order
        for (Item_In_Order__c lineItem: order.Articles_dans_commande__r) {
            totalNetPrice += lineItem.gdb_unit_net_price__c * lineItem.Quantity__c;
            totalGrossPrice += lineItem.gdb_unit_gross_price__c * lineItem.Quantity__c;
            totalTax += lineItem.gdb_unit_tax__c * lineItem.Quantity__c;

            lineItem.gdb_total_net_price__c = lineItem.gdb_unit_net_price__c * lineItem.Quantity__c;
            lineItem.gdb_total_gross_price__c = lineItem.gdb_unit_gross_price__c * lineItem.Quantity__c;
            lineItem.gdb_total_tax__c = lineItem.gdb_unit_tax__c * lineItem.Quantity__c;

            update lineItem;
        }

        if (parentOrder) {
            totalNetPrice += (order.gdb_shipping_price__c - order.gdb_shipping_tax__c);
            totalNetPrice += (order.gdb_shipping_option_price__c - order.gdb_shipping_option_tax__c);
            totalGrossPrice += order.gdb_shipping_price__c;
            totalGrossPrice += order.gdb_shipping_option_price__c;
            totalGrossPrice += order.gdb_multiple_payment_price__c;
            totalTax += (order.gdb_shipping_tax__c - order.gdb_discount_tax__c);

            totalNetPrice -= (order.gdb_discount_price__c - order.gdb_discount_tax__c);
            totalGrossPrice -= order.gdb_discount_price__c;
        }

        //Update Order
        order.RecordTypeId = GDB_Constants.orderTypeId;
        order.gdb_total_net_price__c = totalNetPrice;
        order.gdb_total_tax__c = totalTax;
        order.gdb_total_gross_price__c = totalGrossPrice;
        update order;
    }


    /**
     * getOrderById Returns orders that matching with the given order id or empty list if no order found or null if the given order id is null
     * @param  {String} orderId
     * @return {Order__c}
     */
    public static Order__c getOrderById(String orderId) {
        if (String.isBlank(orderId)) {
            return null;
        }

        return [SELECT
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.gdb_accountNo__c,
            Account__r.gdb_parrainage_code__c,
            Activity_Domain__c,
            Full_Address__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_discount_price__c,
            gdb_discount_tax__c,
            gdb_email__c,
            gdb_isSample__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_shipping_method_title__c,
            gdb_Shipping_Method__c,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_option_price__c,
            gdb_shipping_option_tax__c,
            gdb_shipping_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_parent_order__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            ExternalID__c,
            PlanificationAppointmentHour__c,
            gdb_multiple_payment_price__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                Unit__c,
                gdb_warehouse__c,
                gdb_quantitywarehouse__c,
                Article_Name__c FROM Articles_dans_Commande__r ORDER BY gdb_sku__c
            )
            FROM Order__c
            WHERE Id =: (Id) orderId
            LIMIT 1
        ];
    }

    /**
     * getAddressForm: Return addressForm from an order
     * @return {Map<String, String>}
     */
    private static Map<String, String> getBillingAddressForm(GDB_Basket__c b) {
        Map<String, String> addressForm = new Map<String, String>();

        addressForm.put('salutation', b.gdb_billing_salutation__c);
        addressForm.put('firstname', b.gdb_billing_firstname__c);
        addressForm.put('lastname', b.gdb_billing_lastname__c);
        addressForm.put('address1', b.gdb_billing_address1__c);
        addressForm.put('address2', b.gdb_billing_address2__c);
        addressForm.put('address3', b.gdb_billing_address3__c);
        addressForm.put('city', b.gdb_billing_city__c);
        addressForm.put('zip', b.gdb_billing_zip__c);
        addressForm.put('country', b.gdb_billing_country__c);
        addressForm.put('phone', b.gdb_billing_phone__c);

        return addressForm;
    }

    /**
     * getAddressForm: Return addressForm from an order
     * @return {Map<String, String>}
     */
    private static Map<String, String> getShippingAddressForm(GDB_Basket__c b) {
        Map<String, String> addressForm = new Map<String, String>();

        addressForm.put('salutation', b.gdb_shipping_salutation__c);
        addressForm.put('firstname', b.gdb_shipping_firstname__c);
        addressForm.put('lastname', b.gdb_shipping_lastname__c);
        addressForm.put('address1', b.gdb_shipping_address1__c);
        addressForm.put('address2', b.gdb_shipping_address2__c);
        addressForm.put('address3', b.gdb_shipping_address3__c);
        addressForm.put('city', b.gdb_shipping_city__c);
        addressForm.put('zip', b.gdb_shipping_zip__c);
        addressForm.put('country', b.gdb_shipping_country__c);
        addressForm.put('phone', b.gdb_shipping_phone__c);

        return addressForm;
    }

    /**
     * getGoogleAnalyticsTrackingForOrder
     * @return {String}
     */
    public static String getGoogleAnalyticsTrackingForOrder() {
        Order__c order = getCurrentOrder();
        if (order == null) {
            return null;
        }

        if (GDB_Constants.isGoogleAnalyticsTrackingActive || Test.isRunningTest()) {
            String[] params = new String[] {
                order.gdb_total_gross_price__c.format(), 
                order.gdb_total_gross_price__c.format()
            };
            return String.format(System.Label.GDB_confirmation_googleAnalytics, params);
        }

        return null;
    }
}