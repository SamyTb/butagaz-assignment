public without sharing class GDB_ErrorMgr {
    
    /**
    * @var {String} token Token value to identify errors group
    */
    private static String token;
    
    /**
    * generateToken: Generate an unique token to identify Errors group
    */
    public static void generateToken() {
        Blob b = Crypto.GenerateAESKey(256);
        token = EncodingUtil.ConvertTohex(b);
    }
    
    /**
     * createError: Insert an error in GDB_Error__c
     * @param  {String} clazz
     * @param  {String} method
     * @param  {String} message
     */
    public static void createError(String clazz, String method, String message) {
        if(GDB_Constants.isErrorTracingActive) {
            GDB_Error__c error = new GDB_Error__c(
                GDB_Class__c = clazz, 
                GDB_Method__c = method, 
                GDB_Message__c = message, 
                GDB_order__c = null,
                GDB_Token__c = token
            );
            insert error;
        }
    }
    
        /**
     * createErrorOrder: Insert an error in GDB_Error__c
     * @param  {String} clazz
     * @param  {String} method
     * @param  {String} message
     * @param  {Order__c} Commande
     */
    public static void createErrorOrder(String clazz, String method, String message, Order__c Commande) {
        if(GDB_Constants.isErrorTracingActive) {
            GDB_Error__c error = new GDB_Error__c(
                GDB_Class__c = clazz, 
                GDB_Method__c = method, 
                GDB_Message__c = message, 
                GDB_order__c = commande.Id,
                GDB_Token__c = token
            );
            insert error;
        }
    }
}