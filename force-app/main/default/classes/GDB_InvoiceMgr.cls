public with sharing class GDB_InvoiceMgr {

    /**
     * updateInvoicesWithOrderData Update a list of invoices based on their corresponding orders
     * @param  [{GDB_Invoice__c}] lInvoices
     * @return void
     */
    public static void updateInvoicesWithOrderData(List<GDB_Invoice__c> lInvoices) {

        List<id> lOrderIds = new List<id>();
        map<id, Order__c> mOrders = new map<id, Order__c>();

        if(lInvoices.size() > 0 ) {

            Savepoint sp = null;
            try {
                sp = Database.setSavepoint();

                // Get a list of orders linked to the invoices
                for(GDB_Invoice__c oInv:lInvoices){
                    lOrderIds.add(oInv.gdb_Order__c);
                }

                // Retrieve orders' data
                List<Order__c> lOrders= [
                    SELECT
                    Account__r.Email__c,
                    Account__r.FirstName,
                    Account__r.LastName,
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
                    gdb_Shipping_Method__c,
                    gdb_shipping_phone__c,
                    gdb_shipping_price__c,
                    gdb_shipping_tax__c,
                    gdb_shipping_status__c,
                    gdb_shipping_zip__c,
                    gdb_total_gross_price__c,
                    gdb_total_net_price__c,
                    gdb_total_tax__c,
                    gdb_authorisation_id__c,
                    gdb_transaction_id__c,
                    gdb_validation_date__c,
                    Name,
                    Order_Date_and_Time__c,
                    Order_Status__c,
                    ExternalID__c,
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
                        Unit__c FROM Articles_dans_Commande__r
                    )
                    FROM Order__c
                    WHERE Id =: lOrderIds
                ];

                // Fill a map with order data
                for(Order__c oOrder:lOrders){
                    mOrders.put(oOrder.id, oOrder);
                }

                // Synchronize invoice with order data
                for(GDB_Invoice__c invoiceToSync:lInvoices){
                    if(invoiceToSync.gdb_Order__c != null && mOrders.containsKey(invoiceToSync.gdb_Order__c)){
                        invoiceToSync.gdb_Account__c = mOrders.get(invoiceToSync.gdb_Order__c).Account__r.Id;
                        invoiceToSync.Activity_Domain__c=mOrders.get(invoiceToSync.gdb_Order__c).Activity_Domain__c;
                        invoiceToSync.gdb_billing_salutation__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_salutation__c;
                        invoiceToSync.gdb_billing_firstname__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_firstname__c;
                        invoiceToSync.gdb_billing_lastname__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_lastname__c;
                        invoiceToSync.gdb_billing_address1__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_address1__c;
                        invoiceToSync.gdb_billing_address2__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_address2__c;
                        invoiceToSync.gdb_billing_address3__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_address3__c;
                        invoiceToSync.gdb_billing_city__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_city__c;
                        invoiceToSync.gdb_billing_country__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_country__c;
                        invoiceToSync.gdb_billing_zip__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_billing_zip__c;
                        invoiceToSync.gdb_coupon_code__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_coupon_code__c;
                        invoiceToSync.gdb_discount_name__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_Discount__r.Name;
                        invoiceToSync.gdb_discount_price__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_discount_price__c;
                        invoiceToSync.gdb_discount_tax__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_discount_tax__c;
                        invoiceToSync.gdb_email__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_email__c;
                        invoiceToSync.gdb_Invoice_URL__c='';
                        invoiceToSync.gdb_multiple_shipping__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_multiple_shipping__c;
                        invoiceToSync.gdb_Order__c=mOrders.get(invoiceToSync.gdb_Order__c).Id;
                        invoiceToSync.gdb_order_date__c=mOrders.get(invoiceToSync.gdb_Order__c).Order_Date_and_Time__c;
                        invoiceToSync.gdb_order_status__c=mOrders.get(invoiceToSync.gdb_Order__c).Order_Status__c;
                        invoiceToSync.gdb_payment_date__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_payment_date__c;
                        invoiceToSync.gdb_payment_method_name__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_payment_method_name__c;
                        invoiceToSync.gdb_payment_status__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_payment_status__c;
                        invoiceToSync.gdb_shipping_salutation__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_salutation__c;
                        invoiceToSync.gdb_shipping_firstname__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_firstname__c;
                        invoiceToSync.gdb_shipping_lastname__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_lastname__c;
                        invoiceToSync.gdb_shipping_address1__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_address1__c;
                        invoiceToSync.gdb_shipping_address2__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_address2__c;
                        invoiceToSync.gdb_shipping_address3__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_address3__c;
                        invoiceToSync.gdb_shipping_city__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_city__c;
                        invoiceToSync.gdb_shipping_country__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_country__c;
                        invoiceToSync.gdb_shipping_date__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_date__c;
                        invoiceToSync.gdb_shipping_method_name__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_method_name__c;
                        invoiceToSync.gdb_shipping_method_price__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_price__c;
                        invoiceToSync.gdb_shipping_method_tax__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_tax__c;
                        invoiceToSync.gdb_shipping_status__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_status__c;
                        invoiceToSync.gdb_shipping_zip__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_shipping_zip__c;
                        invoiceToSync.gdb_total_price_ht__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_total_net_price__c;
                        invoiceToSync.gdb_total_price_ttc__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_total_gross_price__c;
                        invoiceToSync.gdb_total_tax__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_total_tax__c;
                        invoiceToSync.gdb_transaction_id__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_transaction_id__c;
                        invoiceToSync.gdb_validation_date__c=mOrders.get(invoiceToSync.gdb_Order__c).gdb_validation_date__c;
                    }
                }
            }
            catch(Exception e) {
                Database.rollback(sp);
            }
        }

    }

    /**
     * createInvoicesProductsFromItemsInOrders Create Invoice Products based on their corresponding Items in Orders
     * @param  [{GDB_Invoice__c}] lInvoices
     * @return void
     */
    public static void createInvoicesProductsFromItemsInOrders(List<GDB_Invoice__c> lInvoices) {

        List<id> lOrderIds = new List<id>();
        map<id, Order__c> mOrders = new map<id, Order__c>();

        if(lInvoices.size() > 0 ) {

            Savepoint sp = null;
            try {
                sp = Database.setSavepoint();

                // Get a list of orders linked to the invoices
                for(GDB_Invoice__c oInv:lInvoices){
                    lOrderIds.add(oInv.gdb_Order__c);
                }

                // Retrieve orders' data
                List<Order__c> lOrders= [
                    SELECT
                    gdb_orderNo__c,
                    ExternalID__c,
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
                        Unit__c FROM Articles_dans_Commande__r
                    )
                    FROM Order__c
                    WHERE Id =: lOrderIds
                ];

                // Fill a map with order data
                for(Order__c oOrder:lOrders){
                    mOrders.put(oOrder.id, oOrder);
                }

                List<GDB_Invoice_Product__c> lInvoiceLineProducts = new List<GDB_Invoice_Product__c>();


                for(GDB_Invoice__c invoiceToSync:lInvoices){
                    if(invoiceToSync.gdb_Order__c != null && mOrders.containsKey(invoiceToSync.gdb_Order__c)){
                        for(Item_in_Order__c io : mOrders.get(invoiceToSync.gdb_Order__c).Articles_dans_Commande__r) {
                            GDB_Invoice_Product__c ip = new GDB_Invoice_Product__c(
                                gdb_description__c=io.gdb_description__c,
                                gdb_Invoice__c=invoiceToSync.Id,
                                Article__c=io.Article__c,
                                gdb_quantity__c=io.Quantity__c,
                                gdb_total_gross_price__c=io.gdb_total_gross_price__c,
                                gdb_total_net_price__c=io.gdb_total_net_price__c,
                                gdb_total_tax__c=io.gdb_total_tax__c,
                                gdb_unit_gross_price__c=io.gdb_unit_gross_price__c,
                                gdb_unit_net_price__c=io.gdb_unit_net_price__c,
                                gdb_unit_tax__c=io.gdb_unit_tax__c,
                                gdb_sku__c=io.gdb_sku__c
                            );
                            lInvoiceLineProducts.add(ip);
                        }
                    }
                }

                insert lInvoiceLineProducts;

            }
            catch(Exception e) {
                Database.rollback(sp);
            }
        }
    }
}