public with sharing class GDB_DocaPostPdfViewerController {
    
    /** 
    * Get the base64 string to display the invoice pdf whose id is passed by param
    * @param {String} invoiceId
    */
    @AuraEnabled
    public static String getInvoicePdf(String invoiceId) {
        if(invoiceId == null){ return null; }
        User u = [select contact.accountId from user where id = :UserInfo.getUserId()];
        List<GDB_Invoice__c> invoices = [SELECT gdb_sap_invoice_no__c FROM GDB_Invoice__c WHERE Id = :invoiceId AND gdb_Account__c = :u.contact.accountId];
        if(invoices == null || invoices.size() <= 0 || invoices.get(0).gdb_sap_invoice_no__c == null) { return null; }
        
        HttpResponse res = doDocaPostCallout(
            String.valueOf(Integer.valueOf(invoices.get(0).gdb_sap_invoice_no__c)), 
            GDB_Constants.docapostEndpoint,
            GDB_Constants.docapostCertificateName
        );
        
        if(res != null && res.getStatusCode() == 200) {
            Blob pdfContent = res.getBodyAsBlob();
            return 'data:application/pdf;base64,' + EncodingUtil.base64Encode(pdfContent);
        }
        
        return null;
    }
    
    /**
    * Do a call to the endpoint with the certificate name passed by param
    * @param {String} docNum
    * @param {String} endPoint
    * @param {String} certificateName
    * @return {HttpResponse}
    */
    public static HttpResponse doDocaPostCallout(String docNum, String endPoint, String certificateName) {
        if(String.isBlank(docNum) || String.isBlank(endPoint) || String.isBlank(certificateName)){ return null; }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(String.format(endPoint, new String[]{docNum}));
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json'); 
        req.setClientCertificateName(certificateName);
        return h.send(req);
    }
}