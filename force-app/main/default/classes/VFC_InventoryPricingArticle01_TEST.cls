@isTest
private class VFC_InventoryPricingArticle01_TEST {

    static testMethod void myUnitTest() {
        System.Debug('### >>>>> testing class VFC_InventoryPricingArticle01_TEST <<<<<');
    	
    	String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCIPA',Alias='VFCIPA',
            Email='VFCIPA@shell.com',Username='VFCIPA@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        	
        	list<Brand__c> lBrandToInsert = new list<Brand__c>();
        	Brand__c oBrandButagaz = new Brand__c(Name__c='Butagaz', Type__c='Nationale', Ordre_de_tri__c=1);
        	lBrandToInsert.add(oBrandButagaz);
        	insert lBrandToInsert;
        	
        	// Articles
        	list<Item__c> lItemToInsert = new list<Item__c>();
        
        	Item__c oItemButagaz = new Item__c(Name = 'ItemButagaz', ExternalID__c='000000000000001515', No_BTZ__c=false); 
        	lItemToInsert.add(oItemButagaz);

        	insert lItemToInsert;
        	
        	Inventory_Pricing__c oIPNew = new Inventory_Pricing__c();
        	insert oIPNew;
        	
        	list<Inventory_Pricing_Brand__c> lIPBrandToInsert = new list<Inventory_Pricing_Brand__c>();
        
        	Inventory_Pricing_Brand__c oIPBrandButagaz = new Inventory_Pricing_Brand__c(
            	Brand__c=oBrandButagaz.Id,
            	Inventory_pricing__c=oIPNew.Id,
            	Presence__c = true
        	);
        	lIPBrandToInsert.add(oIPBrandButagaz);
        	insert lIPBrandToInsert;
        	
        	list<Inventory_Pricing_Article__c> lIPArticleToInsert = new list<Inventory_Pricing_Article__c>();
        
        	Inventory_Pricing_Article__c oIPArticleButagaz = new Inventory_Pricing_Article__c(
            	Inventory_Pricing_Brand__c=oIPBrandButagaz.Id,
            	Article__c=oItemButagaz.Id,
            	Bottle_Number__c=12,
            	Charging_Price__c=10.0,
            	Presence__c = true
        	);
        	lIPArticleToInsert.add(oIPArticleButagaz);
        	
        	insert lIPArticleToInsert;
        	
        	test.starttest();
        	// Starting Controller part
        	ApexPages.StandardController sc = new ApexPages.standardController(oIPArticleButagaz);
        	// create an instance of the controller
			VFC_InventoryPricingArticle01 myPageCon = new VFC_InventoryPricingArticle01(sc);
			PageReference pg=myPageCon.getIPPage();
			test.stoptest();
			
        }
    }
}