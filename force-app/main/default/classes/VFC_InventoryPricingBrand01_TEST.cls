@isTest
private class VFC_InventoryPricingBrand01_TEST {

    static testMethod void myUnitTest() {
        System.Debug('### >>>>> testing class VFC_InventoryPricingBrand01_TEST <<<<<');
    	
    	String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCIPB',Alias='VFCIPB',
            Email='VFCIPB@shell.com',Username='VFCIPB@shell.com',TimeZoneSidKey='Europe/Paris',
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
        	
        	test.starttest();
        	// Starting Controller part
        	ApexPages.StandardController sc = new ApexPages.standardController(oIPBrandButagaz);
        	// create an instance of the controller
			VFC_InventoryPricingBrand01 myPageCon = new VFC_InventoryPricingBrand01(sc);
			PageReference pg=myPageCon.getIPPage();
			test.stoptest();
			
        }
    }
}