public with sharing class GDB_MyAccount_MyOrdersController {
    
    /**
    * Get Orders for the current customer + get new Invoice URL 
    */
    @AuraEnabled
    public static List<Order__c> getOrdersForCurrentCustomer() {
        Account a = GDB_AccountMgr.getCurrentCustomer();

        if(a == null) {
            return null;
        }
        
        List<Order__c> orders = GDB_OrderMgr.getOrdersForAccount(a.Id);
        if(orders != null) {
            for(Order__c o : orders) {
                if(o.Invoices__r != null) {
                    for(GDB_Invoice__c invoice : o.Invoices__r) {
                        invoice.gdb_Invoice_URL__c = GDB_Utils.getCommunityUrlPathPrefix(GDB_Constants.communityName) + GDB_Constants.pagesURLs.get(15) + '?id=' + invoice.Id;
                    }
                }
            }
        }

        return orders;
    }
}