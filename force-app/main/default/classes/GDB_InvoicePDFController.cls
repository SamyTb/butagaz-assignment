global class GDB_InvoicePDFController {

    GDB_Invoice__c current;
    ApexPages.StandardController stdController;

    /**
     * GDB_InvoicePDFController Constructeur
     * @param  {ApexPages.StandardController} controller
     */
    public GDB_InvoicePDFController(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.current = (GDB_Invoice__c) this.stdController.getRecord();
    }

    /**
     * getCurrencySymbol Returns currency symbol from default currency user
     * @return  {String}
     */
    public String getCurrencySymbol() {
        return GDB_Utils.getCurrencySymbol(UserInfo.getDefaultCurrency());
    }

    /**
     * getProducts Returns articles
     * @return [{GDB_Invoice_Product__c}]
     */
    public List<GDB_Invoice_Product__c> getProducts() {
        return [SELECT
            Article_Name__c,
            gdb_quantity__c,
            gdb_unit_net_price__c,
            gdb_unit_gross_price__c,
            gdb_unit_tax__c,
            gdb_total_net_price__c,
            gdb_total_gross_price__c
            FROM GDB_Invoice_Product__c
            WHERE gdb_Invoice__c =: current.Id
            AND gdb_quantity__c > 0
            ORDER BY Article_Name__c
        ];
    }

    /**
     * SaveInvoicePDF Save the invoice as PDF
     * @param  {Id} invoiceId
     * @param  {String} invoiceNo
     * @return {String}
     */
    WebService static string SaveInvoicePDF(Id invoiceId, String invoiceNo) {

        string outcomeMessage;

        PageReference pdfPage = Page.GDB_InvoicePDF;
        pdfPage.getParameters().put('id', invoiceId);
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('t');

        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = pdfBlob;
            List<String> parameters = new List<String>();
            parameters.add(invoiceNo);
            cv.Title = String.format(System.Label.GDB_invoice_title, parameters);
            cv.PathOnClient = String.format(System.Label.GDB_invoice_filename, parameters);
            insert cv;

            ContentDistribution cd = new ContentDistribution();
            cd.name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesAllowPDFDownload = true;
            cd.PreferencesAllowViewInBrowser = true;
            insert cd;

            ContentDistribution cdFetched = [SELECT Id, DistributionPublicUrl, RelatedRecordId
                from ContentDistribution
                where Id =: cd.Id
            ];
            System.debug(logginglevel.WARN, '### Public cdFetched.DistributionPublicUrl = ' + cdFetched.DistributionPublicUrl);

            // Set URL on the invoice
            List<GDB_Invoice__c> invoicesToUpdate = new List<GDB_Invoice__c>();
            GDB_Invoice__c processingInv = new GDB_Invoice__c(Id = invoiceId);
            processingInv.gdb_Invoice_URL__c = cdFetched.DistributionPublicUrl;
            invoicesToUpdate.add(processingInv);
            update invoicesToUpdate;

            outcomeMessage = System.Label.GDB_invoice_success_message;
        } catch (DmlException e) {
            System.debug(System.Label.GDB_invoice_fail_message + e.getMessage());
            outcomeMessage = System.Label.GDB_invoice_fail_message + e.getMessage();
        }


        return outcomeMessage;
    }

    /**
     * SaveInvoicePDF Save the invoice as PDF
     * @param  {List<GDB_Invoice__c>} lInvoices
     * @return {String}
     */
    @Future(callout = true)
    public static void saveInvoicesPDF(List<Id> lInvoicesId) {

        List<ContentVersion> lCvToInsert = new List<ContentVersion>();
        List<ContentDistribution> lCdToInsert = new List<ContentDistribution>();
        Map<id, ContentVersion> mInvoiceToCV = new map < id, ContentVersion>();
        Map<id, id> mCvToInvoice = new Map<id, id>();
        Map<id, ContentDistribution> mInvoiceToCD = new Map<id, ContentDistribution>();


        List<GDB_Invoice__c> lInvoices = [
            SELECT
            Id,
            Name
            FROM GDB_Invoice__c
            WHERE Id =: lInvoicesId
        ];

        for (GDB_Invoice__c invoiceToManage: lInvoices) {

            // Create PDF
            PageReference pdfPage = Page.GDB_InvoicePDF;
            pdfPage.getParameters().put('id', invoiceToManage.Id);
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('t');

            // Create Content Version
            ContentVersion cv = new ContentVersion();
            cv.VersionData = pdfBlob;
            List<String > parameters = new List<String > ();
            parameters.add(invoiceToManage.Name);
            cv.Title = String.format(System.Label.GDB_invoice_title, parameters);
            cv.PathOnClient = String.format(System.Label.GDB_invoice_filename, parameters);
            lCvToInsert.add(cv);

            mInvoiceToCV.put(invoiceToManage.id, cv);
        }

        insert lCvToInsert;

        for (Id invId: mInvoiceToCV.keySet()) {
            mCvToInvoice.put(mInvoiceToCV.get(invId).Id, invId);
        }

        for (ContentVersion cvToManage: lCvToInsert) {
            // Create Content Distribution based on the above Content Version
            ContentDistribution cd = new ContentDistribution();
            cd.name = cvToManage.Title;
            cd.ContentVersionId = cvToManage.Id;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesAllowPDFDownload = true;
            cd.PreferencesAllowViewInBrowser = true;
            lCdToInsert.add(cd);

            mInvoiceToCD.put(mCvToInvoice.get(cvToManage.id), cd);
        }

        insert lCdToInsert;


        // Retrieve Content Distribution generated URLs
        List<ContentDistribution > lCdFetched = [SELECT Id, DistributionPublicUrl, RelatedRecordId
            from ContentDistribution
            where Id =: lCdToInsert
        ];


        // Set URL on the invoice
        List<GDB_Invoice__c> invoicesToUpdate = new List<GDB_Invoice__c>();

        for (GDB_Invoice__c invoiceToManage: lInvoices) {
            if (invoiceToManage.id != null && mInvoiceToCD.containsKey(invoiceToManage.id)) {
                GDB_Invoice__c processingInv = new GDB_Invoice__c(Id = invoiceToManage.id);

                for (ContentDistribution cdFetched: lCdFetched) {
                    if (cdFetched.Id == mInvoiceToCD.get(invoiceToManage.id).Id) {
                        processingInv.gdb_Invoice_URL__c = cdFetched.DistributionPublicUrl;
                    }
                }
                invoicesToUpdate.add(processingInv);
            }
        }
        update invoicesToUpdate;
    }
}