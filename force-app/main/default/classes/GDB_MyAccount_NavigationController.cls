public with sharing class GDB_MyAccount_NavigationController {
    @AuraEnabled
    public static Map<String, String> getURLs() {
        return new Map<String, String>{
            'myDetails' => GDB_Constants.pagesURLs.get(3),
            'myOrders' => GDB_Constants.pagesURLs.get(4),
            'myAddresses' => GDB_Constants.pagesURLs.get(11),
            'contact' => GDB_Constants.pagesURLs.get(6)
        };
    }
}