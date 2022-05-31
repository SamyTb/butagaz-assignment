@isTest
private class GDB_InvoicePDFController_TEST {
    public static GDB_InvoicePDFController invoiceCtrl;
    public static ApexPages.StandardController sc;
    public static GDB_Invoice__c invoice;
    public static List<Id> invoicesId;


    @isTest
    static void testGetCurrencySymbol() {
        initializeObjects();
        System.assertNotEquals(null, invoiceCtrl.getCurrencySymbol());
    }

    @isTest
    static void testGetProducts() {
        initializeObjects();
        System.assertNotEquals(null, invoiceCtrl.getProducts());
    }

    @isTest
    static void testSaveInvoicePDF(){
        initializeObjects();

        System.assertEquals(Label.GDB_invoice_success_message, GDB_InvoicePDFController.SaveInvoicePDF(invoice.Id, '123456789'));
        System.assertNotEquals(Label.GDB_invoice_success_message, GDB_InvoicePDFController.SaveInvoicePDF(null, null));
    }
    
    @isTest
    static void testsaveInvoicesPDF() {
        initializeObjects();
        Test.startTest();
        GDB_InvoicePDFController.saveInvoicesPDF(invoicesId);
        Test.stopTest();
    }

    @isTest
    static void initializeObjects() {
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createWarehouses();
        GDB_TestDataFactory.createDepartementWarehouseArticleJunction();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createPromotion();
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_TestDataFactory.getOrder();
        GDB_TestDataFactory.createItemsInOrder(o);

        invoicesId = new List<Id>();
        invoice = new GDB_Invoice__c();
        invoice = bindOrderToInvoiceAttributes(invoice, o);
        insert invoice;
        invoicesId.add(invoice.Id);

        List<GDB_Invoice_Product__c> invoiceProducts = bindOrderItemsToInvoiceProducts(o, invoice);
        insert invoiceProducts;

        sc = new ApexPages.StandardController(invoice);
        invoiceCtrl = new GDB_InvoicePDFController(sc);
    }

    private static GDB_Invoice__c bindOrderToInvoiceAttributes(GDB_Invoice__c i, Order__c o) {
        i.gdb_Account__c=o.Account__r.Id;
        i.Activity_Domain__c=o.Activity_Domain__c;
        i.gdb_billing_address1__c=o.gdb_billing_address1__c;
        i.gdb_billing_address2__c=o.gdb_billing_address2__c;
        i.gdb_billing_address3__c=o.gdb_billing_address3__c;
        i.gdb_billing_city__c=o.gdb_billing_city__c;
        i.gdb_billing_country__c=o.gdb_billing_country__c;
        i.gdb_billing_zip__c=o.gdb_billing_zip__c;
        i.gdb_coupon_code__c=o.gdb_coupon_code__c;
        i.gdb_discount_name__c=o.gdb_Discount__r.Name;
        i.gdb_discount_price__c=o.gdb_discount_price__c;
        i.gdb_discount_tax__c=0;
        i.gdb_email__c=o.gdb_email__c;
        i.gdb_Invoice_URL__c='';
        i.gdb_multiple_shipping__c=o.gdb_multiple_shipping__c;
        i.gdb_Order__c=o.Id;
        i.gdb_order_date__c=o.Order_Date_and_Time__c;
        i.gdb_order_status__c=o.Order_Status__c;
        i.gdb_payment_date__c=o.gdb_payment_date__c;
        i.gdb_payment_method_name__c=o.gdb_payment_method_name__c;
        i.gdb_payment_status__c=o.gdb_payment_status__c;
        i.gdb_shipping_address1__c=o.gdb_shipping_address1__c;
        i.gdb_shipping_address2__c=o.gdb_shipping_address2__c;
        i.gdb_shipping_address3__c=o.gdb_shipping_address3__c;
        i.gdb_shipping_city__c=o.gdb_shipping_city__c;
        i.gdb_shipping_country__c=o.gdb_shipping_country__c;
        i.gdb_shipping_date__c=o.gdb_shipping_date__c;
        i.gdb_shipping_method_name__c=o.gdb_shipping_method_name__c;
        i.gdb_shipping_method_price__c=o.gdb_shipping_price__c;
        i.gdb_shipping_method_tax__c=o.gdb_shipping_tax__c;
        i.gdb_shipping_status__c=o.gdb_shipping_status__c;
        i.gdb_shipping_zip__c=o.gdb_shipping_phone__c;
        i.gdb_total_price_ht__c=o.gdb_total_net_price__c;
        i.gdb_total_price_ttc__c=o.gdb_total_gross_price__c;
        i.gdb_total_tax__c=o.gdb_total_tax__c;
        i.gdb_transaction_id__c=o.gdb_transaction_id__c;
        i.gdb_validation_date__c=o.gdb_validation_date__c;
        return i;
    }

    private static List<GDB_Invoice_Product__c> bindOrderItemsToInvoiceProducts(Order__c o, GDB_Invoice__c i) {
        List<GDB_Invoice_Product__c> invoiceLineProducts = new List<GDB_Invoice_Product__c>();
        for(Item_in_Order__c io : o.Articles_dans_Commande__r) {
            GDB_Invoice_Product__c ip = new GDB_Invoice_Product__c(
                gdb_description__c=io.gdb_description__c,
                gdb_Invoice__c=i.Id,
                Article__c=io.Article__c,
                gdb_quantity__c=io.Quantity__c,
                gdb_total_gross_price__c=io.gdb_total_gross_price__c,
                gdb_total_net_price__c=io.gdb_total_net_price__c,
                gdb_total_tax__c=io.gdb_total_tax__c,
                gdb_unit_gross_price__c=io.gdb_unit_gross_price__c,
                gdb_unit_net_price__c=io.gdb_unit_net_price__c,
                gdb_unit_tax__c=io.gdb_unit_tax__c
            );
            invoiceLineProducts.add(ip);
        }
        return invoiceLineProducts;
    }
}