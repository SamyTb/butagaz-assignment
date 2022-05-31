@isTest
public class VFC_InventoryPricing_TEST {
    public static testmethod void testInventoryPricing(){
        
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
        Account oCentrale = new Account(name='IPCentrale', AccountNumber='C65',Country__c='FR', Phone='0202020202');
        insert oCentrale;
        
        // Enseigne
        Account oEnseigne = new Account(name='IPEnseigne', ParentId=oCentrale.Id,Country__c='FR', Phone='0202020202');
        insert oEnseigne;
        
        // PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', Account_DO__c=oEnseigne.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oPTL;
        
        // Brands
        list<Brand__c> lBrandToInsert = new list<Brand__c>();
        Brand__c oBrandButagaz = new Brand__c(Name__c='Butagaz', Type__c='Nationale', Ordre_de_tri__c=1, Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandButagaz);
        
        Brand__c oBrandNational = new Brand__c(Name__c='BrandNational', Type__c='Nationale', Ordre_de_tri__c=2, Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandNational);
        
        Brand__c oBrandDistributor = new Brand__c(Name__c='BrandDistributor', Type__c='Distributeur', Ordre_de_tri__c=3, Centrale__c='C65', Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandDistributor);

        insert lBrandToInsert;
        
        // Articles
        list<Item__c> lItemToInsert = new list<Item__c>();
        
        Item__c oItemButagaz = new Item__c(Name = 'ItemButagaz', ExternalID__c='000000000000001515', No_BTZ__c=false); 
        lItemToInsert.add(oItemButagaz);

        Item__c oItemNonButagaz = new Item__c(Name = 'ItemNonButagaz', ExternalID__c='NOBTZ', No_BTZ__c=true); 
        lItemToInsert.add(oItemNonButagaz);

        insert lItemToInsert;
        
        // Butagaz Stock Installed
        Butagaz_Stock_Installed__c oStockInstalled = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=oItemButagaz.Id,
            Stock_installe__c=12
        );
        insert oStockInstalled;
                
        // Inventory Pricing
        Inventory_Pricing__c oIPNew = new Inventory_Pricing__c(PTL__c=oPTL.Id);

        // "Edit" mode
        Inventory_Pricing__c oIP = new Inventory_Pricing__c(PTL__c=oPTL.Id);        
        insert oIP;
        
        // Inventory Pricing Brands
        list<Inventory_Pricing_Brand__c> lIPBrandToInsert = new list<Inventory_Pricing_Brand__c>();
        
        Inventory_Pricing_Brand__c oIPBrandButagaz = new Inventory_Pricing_Brand__c(
            Brand__c=oBrandButagaz.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        lIPBrandToInsert.add(oIPBrandButagaz);
        
        Inventory_Pricing_Brand__c oIPBrandNational = new Inventory_Pricing_Brand__c(
            Brand__c=oBrandNational.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        lIPBrandToInsert.add(oIPBrandNational);  
        
        Inventory_Pricing_Brand__c oIPBrandDistributor = new Inventory_Pricing_Brand__c(
            Brand__c=oBrandDistributor.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        lIPBrandToInsert.add(oIPBrandDistributor); 
        
        insert lIPBrandToInsert;  
        
        // Inventory Pricing Articles
        list<Inventory_Pricing_Article__c> lIPArticleToInsert = new list<Inventory_Pricing_Article__c>();
        
        Inventory_Pricing_Article__c oIPArticleButagaz = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandButagaz.Id,
            Article__c=oItemButagaz.Id,
            Bottle_Number__c=12,
            Charging_Price__c=10.0,
            Presence__c = true
        );
        lIPArticleToInsert.add(oIPArticleButagaz);
        
        Inventory_Pricing_Article__c oIPArticleNational_1 = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandNational.Id,
            Article__c=oItemButagaz.Id,
            Bottle_Number__c=12,
            Charging_Price__c=11.0,
            Presence__c = true
        );
        lIPArticleToInsert.add(oIPArticleNational_1);
        
        Inventory_Pricing_Article__c oIPArticleNational_2 = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandNational.Id,
            Article__c=oItemNonButagaz.Id,
            Bottle_Number__c=12,
            Charging_Price__c=11.0,
            Presence__c = true
        );
        lIPArticleToInsert.add(oIPArticleNational_2);                
                
        Inventory_Pricing_Article__c oIPArticleDistributor_1 = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandDistributor.Id,
            Article__c=oItemButagaz.Id,
            Bottle_Number__c=12,
            Charging_Price__c=13.0,
            Presence__c = true
        );
        lIPArticleToInsert.add(oIPArticleDistributor_1);
        
        Inventory_Pricing_Article__c oIPArticleDistributor_2 = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandDistributor.Id,
            Article__c=oItemNonButagaz.Id,
            Bottle_Number__c=12,
            Charging_Price__c=11.0,
            Presence__c = true
        );
        lIPArticleToInsert.add(oIPArticleDistributor_2); 
        
        insert lIPArticleToInsert;
        
        // Start test
        test.starttest();

        // "New" mode       
        VFC_InventoryPricing oControlNew = new VFC_InventoryPricing(new ApexPages.standardcontroller(oIPNew));
        
        oControlNew.calcPriceDifferentialBtn(); 
        oControlNew.saveBtn();
        
        System.assertEquals(1, oControlNew.lBrandArticle_Butagaz.size());
        System.assertEquals(1, oControlNew.lBrandArticle_National.size());
        System.assertEquals(1, oControlNew.lBrandArticle_Distributor.size());
        
        // "Edit" mode      
        VFC_InventoryPricing oControlEdit = new VFC_InventoryPricing(new ApexPages.standardcontroller(oIP));
        
        oControlEdit.calcPriceDifferentialBtn();    
        oControlEdit.saveBtn();
        
        // Check Diff price
        oIPArticleNational_1 = [select Id, BTZ_Price_Differential__c from Inventory_Pricing_Article__c 
        where Inventory_Pricing_Brand__r.Inventory_pricing__c= :oControlEdit.oIP.Id 
        and Inventory_Pricing_Brand__r.Brand__r.Name__c = :oBrandNational.Name__c 
        and Article__r.Id = :oItemButagaz.Id];
        
        system.assertEquals(1, oIPArticleNational_1.BTZ_Price_Differential__c);
        
        // Test Succession process
        // New Account
        Account oNewAccount = new Account(name='IPNewAccount', Predecessor__c=oEnseigne.Id,Country__c='FR', Phone='0202020202');
        insert oNewAccount;   
        
        // New PTL
        PTL__c oNewPTL = new PTL__c(Name = 'IPNewPTL', Account_DO__c=oNewAccount.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oNewPTL;
        
        // Stop test        
        test.stoptest();
    }
    
    public static testmethod void testInventoryPricingDeleteUndelete(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
    
        // Centrale
        Account oCentrale = new Account(name='IPCentrale', AccountNumber='C65',Country__c='FR', Phone='0202020202');
        insert oCentrale;
        
        // Enseigne
        Account oEnseigne = new Account(name='IPEnseigne', ParentId=oCentrale.Id,Country__c='FR', Phone='0202020202');
        insert oEnseigne;
        
        // PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', Account_DO__c=oEnseigne.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oPTL;
        
        // Inventory Pricing
        Inventory_Pricing__c oIPNew = new Inventory_Pricing__c(PTL__c=oPTL.Id);
        insert oIPNew;
        // Start test
        test.starttest();
        delete oIPNew;
        Database.Undelete(oIPNew, false);
        // Stop test        
        test.stoptest();
     }
}