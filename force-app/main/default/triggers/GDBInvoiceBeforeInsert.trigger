trigger GDBInvoiceBeforeInsert on GDB_Invoice__c (before insert) {
    
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> GDB_Invoice__c.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());

        GDB_InvoiceMgr.updateInvoicesWithOrderData(Trigger.new);
        
        System.Debug('##>>> GDB_Invoice__c.BeforeInsert : END <<<');
    }else{
        System.Debug('##>>> GDB_Invoice__c.BeforeInsert : FALSE TRIGGER <<<');
    }
    
}