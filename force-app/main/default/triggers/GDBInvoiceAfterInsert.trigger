trigger GDBInvoiceAfterInsert on GDB_Invoice__c (after insert) {
    
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug('##>>> GDB_Invoice__c.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        
            GDB_InvoiceMgr.createInvoicesProductsFromItemsInOrders(Trigger.new);
        
        // Call method to create the invoice PDF file
        List<id> lInvoicesIds = new List<id>();
        for(GDB_Invoice__c oInv:Trigger.new){
            lInvoicesIds.add(oInv.Id);
        }
        GDB_InvoicePDFController.saveInvoicesPDF(lInvoicesIds);
        
        System.Debug('##>>> GDB_Invoice__c.AfterInsert : END <<<');
    }else{
        System.Debug('##>>> GDB_Invoice__c.AfterInsert : FALSE TRIGGER <<<');
    }
    
}