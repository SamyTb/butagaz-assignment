public class GDB_ProduitQuantity_B2B {
    
    @AuraEnabled
    public Item__c Item { get; set; }
    
    @AuraEnabled
    public Integer Quantity { get; set; }
    
    @AuraEnabled
    public String ImageUrl { get; set; }
     
}