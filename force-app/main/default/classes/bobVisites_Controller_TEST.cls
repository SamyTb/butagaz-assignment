@isTest
public class bobVisites_Controller_TEST {

    private static testMethod void testBobVisites(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
		insert new List<Custom_Settings__c> { c1 };

        GEB_Code_Articles_BTZ__c GCAB1 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE BOUTEILLE 13 KG', External_ID__c = '000000000000000100', Ordre_de_tri__c = 1, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB2 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE BOUTEILLE 13 KG', External_ID__c = '000000000000000200', Ordre_de_tri__c = 2, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB3 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE CARBURATION BOUTEILLE 13 KG', External_ID__c = '000000000000000400', Ordre_de_tri__c = 3, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB4 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE BOUTEILLE 35 KG', External_ID__c = '000000000000000300', Ordre_de_tri__c = 4, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB5 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE CUBE 6 KG', External_ID__c = '000000000000000500', Ordre_de_tri__c = 5, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB6 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE CUBE 5 KG', External_ID__c = '000000000000000600', Ordre_de_tri__c = 6, Type__c = 'Bouteille');
        GEB_Code_Articles_BTZ__c GCAB7 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE VB 10 KG', External_ID__c = '000000000000000700', Ordre_de_tri__c = 7, Type__c = 'Bouteille');
        insert new List<GEB_Code_Articles_BTZ__c> { GCAB1, GCAB2, GCAB3, GCAB4, GCAB5, GCAB6, GCAB7 };
        
        // Centrale
        Account oCentrale = new Account(name='IPCentrale', AccountNumber='C65',Country__c='FR', Phone='0202020202',Email__c='titi.tata@gmail.com',
        Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', price_panel__c = true);
        insert oCentrale;
        
         // Enseigne
        Account oEnseigne = new Account(name='IPEnseigne', ParentId=oCentrale.Id,Country__c='FR', Phone='0202020202',Email__c='titi.tata@gmail.com',
        Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', price_panel__c = true);
        insert oEnseigne;
       	
        // PTL //Account_DO__c=oEnseigne.Id
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true, Account_DO__c = OEnseigne.Id,
                                Type_de_presentoir_1__c = '10 UB', Nombre_type_de_presentoir_1__c = 2,  Type_de_presentoir_2__c = '10 UB', Nombre_type_de_presentoir_2__c = 2,
                                Type_de_presentoir_3__c = '10 UB', Nombre_type_de_presentoir_3__c = 2,  Type_de_presentoir_4__c = '10 UB', Nombre_type_de_presentoir_4__c = 2,
                                Type_de_presentoir_5__c = '10 UB', Nombre_type_de_presentoir_5__c = 2);
        insert oPTL;
        
        // Events
        Id eventRTId = [Select id from RecordType Where developerName = 'Visite_GEB' Limit 1].id;
        Event event = new Event(RecordTypeId = eventRTId, whatid = oPTL.id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now());
        insert event;
        
        //Event nextEvent = new Event(RecordTypeId = eventRTId, whatid = oPTL.id, StartDateTime = DateTime.now().addDays(5), EndDateTime = DateTime.now().addDays(5));
        //insert nextEvent;
        
        // Brands
        list<Brand__c> lBrandToInsert = new list<Brand__c>();
        Brand__c oBrandButagaz = new Brand__c(Name__c='Butagaz', Type__c='Nationale', Ordre_de_tri__c=1, Display_On_Inventory_Pricing__c = true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandButagaz);
        
        Brand__c oBrandNational = new Brand__c(Name__c='BrandNational', Type__c='Nationale', Ordre_de_tri__c=2, Display_On_Inventory_Pricing__c = true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandNational);
        
        Brand__c oBrandDistributor = new Brand__c(Name__c='BrandDistributor', Type__c='Distributeur', Ordre_de_tri__c=3, Centrale__c='C65', Display_On_Inventory_Pricing__c = true, Display_On_Stock_Inventory__c=true);
        lBrandToInsert.add(oBrandDistributor);

        insert lBrandToInsert;
        
        /*// Articles
        list<Item__c> lItemToInsert = new list<Item__c>();
        
        Item__c oItemButagaz = new Item__c(Name = 'ItemButagaz', Capacity__c=12, ExternalID__c='000000000000001515', No_BTZ__c=false); 
        lItemToInsert.add(oItemButagaz);

        Item__c oItemNonButagaz = new Item__c(Name = 'ItemNonButagaz', Capacity__c=6, ExternalID__c='NOBTZ', No_BTZ__c=true); 
        lItemToInsert.add(oItemNonButagaz);

        insert lItemToInsert;*/
                
        
        // Items
        List<Item__c> items = new List<Item__c>();
        
        Item__c itemBD = new item__c(Name = 'BD', code_Article__c = 'BD', No_BTZ__c=false, Capacity__c = 13, ExternalID__c = '000000000000000100');
        items.add(itemBD);
        Item__c itemG = new item__c(Name = 'G', code_Article__c = 'G', No_BTZ__c=false, Capacity__c = 13, ExternalID__c = '000000000000000200');
        items.add(itemG);
        Item__c itemP = new item__c(Name = 'P', code_Article__c = 'P', No_BTZ__c=false, Capacity__c = 35, ExternalID__c = '000000000000000300');
        items.add(itemP);
        Item__c itemCB = new item__c(Name = 'CB', code_Article__c = 'CB', No_BTZ__c=false, Capacity__c = 6, ExternalID__c = '000000000000000500');
        items.add(itemCB);
        Item__c itemCP = new item__c(Name = 'CP', code_Article__c = 'CP', No_BTZ__c=false, Capacity__c = 5, ExternalID__c = '000000000000000600');
        items.add(itemCP);
        Item__c itemVB = new item__c(Name = 'VB', code_Article__c = 'VB', No_BTZ__c=false, Capacity__c = 10, ExternalID__c = '000000000000000700');
        items.add(itemVB);
        Item__c itemGC = new item__c(Name = 'GC', code_Article__c = 'GC', No_BTZ__c=false, Capacity__c = 13, ExternalID__c = '000000000000000400');
        items.add(itemGC);
        Item__c oItemNonButagaz = new Item__c(Name = 'ItemNonButagaz', ExternalID__c='NOBTZ', No_BTZ__c=true, Capacity__c = 13); 
        items.add(oItemNonButagaz);
        insert(items);

        // Butagaz Stock Installed
        list<Butagaz_Stock_Installed__c> lBtzStockInstalledToInsert = new list<Butagaz_Stock_Installed__c>();

        Butagaz_Stock_Installed__c oStockInstalled1 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemBD.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled1);
        Butagaz_Stock_Installed__c oStockInstalled2 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemG.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled2);
        Butagaz_Stock_Installed__c oStockInstalled3 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemP.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled3);
        Butagaz_Stock_Installed__c oStockInstalled4 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemCB.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled4);
        Butagaz_Stock_Installed__c oStockInstalled5 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemCP.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled5);
        Butagaz_Stock_Installed__c oStockInstalled6 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemVB.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled6);
        Butagaz_Stock_Installed__c oStockInstalled7 = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=itemGC.Id,
            Stock_installe__c=12
        );
        lBtzStockInstalledToInsert.add(oStockInstalled7);

        insert lBtzStockInstalledToInsert;
        
        
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
        
        For(Item__c item : items){
        	Inventory_Pricing_Article__c oIPArticleButagaz = new Inventory_Pricing_Article__c(
            	Inventory_Pricing_Brand__c=oIPBrandButagaz.Id,
            	Article__c=item.Id,
            	//Bottle_Number__c=12,
            	Charging_Price__c=10.0,
            	Presence__c = true
        	);
        	lIPArticleToInsert.add(oIPArticleButagaz);
        }     
        
        For(Item__c item : items){
        	Inventory_Pricing_Article__c oIPArticleNational_1 = new Inventory_Pricing_Article__c(
            	Inventory_Pricing_Brand__c=oIPBrandNational.Id,
            	Article__c=item.Id,
            	//Bottle_Number__c=12,
            	Charging_Price__c=11.0,
            	Presence__c = true
        	);
        	lIPArticleToInsert.add(oIPArticleNational_1);
        }    
        
        For(Item__c item : items){
        	Inventory_Pricing_Article__c oIPArticleNational_2 = new Inventory_Pricing_Article__c(
            	Inventory_Pricing_Brand__c=oIPBrandNational.Id,
            	Article__c=item.Id,
            	//Bottle_Number__c=12,
            	Charging_Price__c=11.0,
            	Presence__c = true
        	);
        	lIPArticleToInsert.add(oIPArticleNational_2);                
        }    
        Inventory_Pricing_Article__c oIPArticleDistributor_1 = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPBrandDistributor.Id,
            Article__c=itemBD.Id,
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

        // Stock Inventory
        Stock_Inventory__c oSINew = new Stock_Inventory__c(PTL__c=oPTL.Id, Inventory_Date__c = Date.Today(), Type__c = 'Rack');

        // "Edit" mode
        Stock_Inventory__c oSI = new Stock_Inventory__c(PTL__c=oPTL.Id, Inventory_Date__c = Date.Today(), Type__c = 'Rack');        
        insert oSI;
        
        // Stock Inventory Brands
        list<Stock_Inventory_Brand__c> lSIBrandToInsert = new list<Stock_Inventory_Brand__c>();
        
        Stock_Inventory_Brand__c oSIBrandButagaz = new Stock_Inventory_Brand__c(
            Brand__c=oBrandButagaz.Id,
            Stock_Inventory__c=oSI.Id,
            Presence__c = true,
            Number_of_Bottle_Slots_10_13__c = 1,
            Number_of_Bottle_Slots_5_6__c = 2,
            Number_of_Bottle_Slots_35__c = 3
        );
        lSIBrandToInsert.add(oSIBrandButagaz);
        
        Stock_Inventory_Brand__c oSIBrandNational = new Stock_Inventory_Brand__c(
            Brand__c=oBrandNational.Id,
            Stock_Inventory__c=oSI.Id,
            Presence__c = true,
            Number_of_Bottle_Slots_10_13__c = 4,
            Number_of_Bottle_Slots_5_6__c = 5,
            Number_of_Bottle_Slots_35__c = 6
        );
        lSIBrandToInsert.add(oSIBrandNational);  
        
        Stock_Inventory_Brand__c oSIBrandDistributor = new Stock_Inventory_Brand__c(
            Brand__c=oBrandDistributor.Id,
            Stock_Inventory__c=oSI.Id,
            Presence__c = true,
            Number_of_Bottle_Slots_10_13__c = 7,
            Number_of_Bottle_Slots_5_6__c = 8,
            Number_of_Bottle_Slots_35__c = 9
        );
        lSIBrandToInsert.add(oSIBrandDistributor); 
        
        insert lSIBrandToInsert;
        

        test.starttest();
        
        String JSONData = bobVisites_Controller.getData(event.id);
        bobVisites_Controller.Data data = (bobVisites_Controller.Data) JSON.deserialize(JSONData, bobVisites_Controller.Data.class);
        
        bobVisites_Controller.nextEvent nextEventCls = new bobVisites_Controller.nextEvent();
        nextEventCls.eventId = Event.Id;
        nextEventCls.eventDateTime = Event.StartDateTime;
        
        bobVisites_Controller.SaveData saveData = new bobVisites_Controller.SaveData();
        saveData.eventId = data.eventId;
        saveData.event = data.event;
        saveData.ptl = data.ptl;
        //saveData.comment;
       	//saveData.description;
        //saveData.divers;
        saveData.nextEvent = nextEventCls;
        saveData.validate = true;
      	//saveData.butagazStocks = data.inventoryPricing.butagazPricing;
        //saveData.competitorsStocks = data.inventoryPricing.competitorsPricing;
        saveData.competitorsStocks = data.stockInventory.competitorsStock;
        saveData.competitorsStocksDAB = data.stockInventoryDAB.competitorsStock;
    	saveData.operations = data.operations;  
        saveData.challenges = data.challenges;
      	saveData.butagazPricing = data.inventoryPricing.butagazPricing ;
       	saveData.competitorsPricing = data.inventoryPricing.competitorsPricing;
        saveData.presentoirs = data.presentoirs; 

		bobVisites_Controller.saveData(JSON.serialize(saveData));
        test.stoptest();
    }        
}