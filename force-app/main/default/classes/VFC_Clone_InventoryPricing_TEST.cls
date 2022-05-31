@isTest
public class VFC_Clone_InventoryPricing_TEST {
  public static testmethod void testCloneInventoryPricing(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        // Data Model
        // Custom Settings
        GEB_Code_Articles_BTZ__c oGEBCdArticle = new GEB_Code_Articles_BTZ__c(
            Name='Article-TEST',
            External_ID__c='000000000000001515',
            Type__c = 'Bouteille');
             
        insert oGEBCdArticle;
        
        // Centrale
        Account oAcc = new Account(name='IPAccount', AccountNumber='C65',Country__c='FR', Phone='0202020202');
        insert oAcc;
        
        // PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', Account_DO__c=oAcc.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oPTL;
        
        // Brands
        Brand__c oBrand = new Brand__c(Name__c='Butagaz', Type__c='Nationale', Ordre_de_tri__c=1);
        insert oBrand;
        
        // Articles
        Item__c oItem = new Item__c(Name = 'ItemButagaz', ExternalID__c='000000000000001515', No_BTZ__c=false); 
        insert oItem;
        
        // Butagaz Stock Installed
        Butagaz_Stock_Installed__c oStockInstalled = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=oItem.Id,
            Stock_installe__c=12
        );
        insert oStockInstalled;
                
        // Inventory Pricing
        Inventory_Pricing__c oIP = new Inventory_Pricing__c(PTL__c=oPTL.Id);        
        insert oIP;
        
        // Inventory Pricing Brands
        Inventory_Pricing_Brand__c oIPB = new Inventory_Pricing_Brand__c(
            Brand__c=oBrand.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        insert oIPB;
        
        // Inventory Pricing Articles
        Inventory_Pricing_Article__c oIPA = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPB.Id,
            Article__c=oItem.Id,
            Bottle_Number__c=12,
            Charging_Price__c=10.0,
            Presence__c = true
        );
        insert oIPA;
        
        // Start test
        test.starttest();

        // "New" mode       
        VFC_Clone_InventoryPricing oControl = new VFC_Clone_InventoryPricing(new ApexPages.standardcontroller(oIP));
        
        oControl.CloneInventoryPricing(); 
       
        // Stop test        
        test.stoptest();
    }
}