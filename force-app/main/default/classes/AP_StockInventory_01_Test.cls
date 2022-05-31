@isTest
public class AP_StockInventory_01_Test {
    
    static testMethod void AP_StockInventory_01_Test() {
    
        System.Debug('### >>>>> testing class AP_StockInventory_01_Test <<<<<');
     
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APInventoryPricing01',Alias='VFCMEP01',
              Email='APStockInventory@butagaz.com',Username='APStockInventory@butagaz.com',TimeZoneSidKey='Europe/Paris',
              LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
              LanguageLocaleKey='fr');
              
        insert u;
          
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c1, c9, c10, c11, c12 };
          
          //System.runAs(u) {
            
            GEB_Code_Articles_BTZ__c GCAB1 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE BOUTEILLE 13 KG', External_ID__c = '000000000000000100', Ordre_de_tri__c = 1, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB2 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE BOUTEILLE 13 KG', External_ID__c = '000000000000000200', Ordre_de_tri__c = 2, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB3 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE CARBURATION BOUTEILLE 13 KG', External_ID__c = '000000000000000400', Ordre_de_tri__c = 3, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB4 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE BOUTEILLE 35 KG', External_ID__c = '000000000000000300', Ordre_de_tri__c = 4, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB5 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE CUBE 6 KG', External_ID__c = '000000000000000500', Ordre_de_tri__c = 5, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB6 = new GEB_Code_Articles_BTZ__c(Name = 'PROPANE CUBE 5 KG', External_ID__c = '000000000000000600', Ordre_de_tri__c = 6, Type__c = 'Bouteille');
            GEB_Code_Articles_BTZ__c GCAB7 = new GEB_Code_Articles_BTZ__c(Name = 'BUTANE VB 10 KG', External_ID__c = '000000000000000700', Ordre_de_tri__c = 7, Type__c = 'Bouteille');
            insert new List<GEB_Code_Articles_BTZ__c> { GCAB1, GCAB2, GCAB3, GCAB4, GCAB5, GCAB6, GCAB7 };
            
            // Data Model
            
            // Activity domain
            Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c = 41);
            insert AD_GEB;
    
            // Centrale
            Account oCentrale = new Account(name='IPCentrale', AccountNumber='C65',Country__c='FR', Phone='0202020202');
            insert oCentrale;
            
            // Enseigne
            Account oEnseigne = new Account(name='IPEnseigne', ParentId=oCentrale.Id,Country__c='FR', Phone='0202020202', Activity_Domain__c=AD_GEB.Id, Group_Code_Value__c='ENS', Sub_Channel__c='GD');
            insert oEnseigne;
            
            // PTL
            List<PTL__c> ptls = new List<PTL__c>();
    
            PTL__c oPTL1 = new PTL__c(Name = 'IPPTL1', Account_DO__c=oEnseigne.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true, Activity_Domain__c=AD_GEB.Id, Enseigne__c='ENS');
            ptls.add(oPTL1);
            /*PTL__c oPTL2 = new PTL__c(Name = 'IPPTL2', Account_DO__c=oEnseigne.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true, Activity_Domain__c=AD_GEB.Id, Sous_canal__c='GD');
            ptls.add(oPTL2);*/
            insert ptls;
    
            // Brands
            list<Brand__c> lBrandToInsert = new list<Brand__c>();
            Brand__c oBrandButagaz = new Brand__c(Name__c='Butagaz', Type__c='Nationale', Ordre_de_tri__c=1, Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
            lBrandToInsert.add(oBrandButagaz);
            
            Brand__c oBrandNational = new Brand__c(Name__c='BrandNational', Type__c='Nationale', Ordre_de_tri__c=2, Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
            lBrandToInsert.add(oBrandNational);
            
            Brand__c oBrandDistributor = new Brand__c(Name__c='BrandDistributor', Type__c='Distributeur', Ordre_de_tri__c=3, Centrale__c='C65', Display_On_Inventory_Pricing__c=true, Display_On_Stock_Inventory__c=true);
            lBrandToInsert.add(oBrandDistributor);
    
            insert lBrandToInsert;
            
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
    
            // Commercial results so the "Actif_Filtre" in the QueryLocator returns records
            List<PTL_Commercial_Results__c> commRes = new List<PTL_Commercial_Results__c>();
            
            PTL_Commercial_Results__c commRes1 = new PTL_Commercial_Results__c(
                Account_DO__c = oEnseigne.Id,
                PTL__c = oPTL1.Id,
                Actif__c = 1,
                Activity_Domain__c = AD_GEB.Id,
                Article__c = itemBD.Id,
                Quantity_In_Tons__c = 1,
                GEB_Quantity_UB_Load__c = 1,
                Year_Month__c = String.valueOf(Date.Today().year()) + String.valueOf(Datetime.now().format('MM')),  //String.valueOf(Date.Today().month().format('mm')),
                External_ID__c = 'Ext1',
                File_Created_Date__c = Date.Today()
            );
            commRes.add(commRes1);
            /*PTL_Commercial_Results__c commRes2 = new PTL_Commercial_Results__c(
                Account_DO__c = oEnseigne.Id,
                PTL__c = oPTL2.Id,
                Actif__c = 1,
                Activity_Domain__c = AD_GEB.Id,
                Article__c = itemBD.Id,
                Quantity_In_Tons__c = 1,
                GEB_Quantity_UB_Load__c = 1,
                Year_Month__c = String.valueOf(Date.Today().year()) + String.valueOf(Datetime.now().format('MM')),  //String.valueOf(Date.Today().month().format('mm')),
                External_ID__c = 'Ext2',
                File_Created_Date__c = Date.Today()
            );
            commRes.add(commRes2);*/
            insert(commRes);
    
            
            // Butagaz Stock Installed
            list<Butagaz_Stock_Installed__c> lBtzStockInstalledToInsert = new list<Butagaz_Stock_Installed__c>();
    
            Butagaz_Stock_Installed__c oStockInstalled1 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemBD.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled1);
            Butagaz_Stock_Installed__c oStockInstalled2 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemG.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled2);
            Butagaz_Stock_Installed__c oStockInstalled3 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemP.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled3);
            Butagaz_Stock_Installed__c oStockInstalled4 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemCB.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled4);
            Butagaz_Stock_Installed__c oStockInstalled5 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemCP.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled5);
            Butagaz_Stock_Installed__c oStockInstalled6 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemVB.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled6);
            Butagaz_Stock_Installed__c oStockInstalled7 = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL1.Id,
                Article__c=itemGC.Id,
                Stock_installe__c=12
            );
            lBtzStockInstalledToInsert.add(oStockInstalled7);
            insert lBtzStockInstalledToInsert;
            system.debug(LoggingLevel.WARN, '### lBtzStockInstalledToInsert.size() : ' + lBtzStockInstalledToInsert.size());
                    
            // Stock Inventory
            list<Stock_Inventory__c> lSIToInsert = new list<Stock_Inventory__c>();
    
            Stock_Inventory__c oSIPTL1Rack = new Stock_Inventory__c(
                PTL__c = oPTL1.Id,
                Inventory_Date__c = Date.Today(),
                Type__c = 'Rack'
            );
            lSIToInsert.add(oSIPTL1Rack);
            Stock_Inventory__c oSIPTL1DAB = new Stock_Inventory__c(
                PTL__c = oPTL1.Id,
                Inventory_Date__c = Date.Today() - 1,
                Type__c = 'DAB'
            );
            lSIToInsert.add(oSIPTL1DAB);
            /*Stock_Inventory__c oSIPTL2Rack = new Stock_Inventory__c(
                PTL__c = oPTL2.Id,
                Inventory_Date__c = Date.Today(),
                Type__c = 'Rack'
            );
            lSIToInsert.add(oSIPTL2Rack);
            Stock_Inventory__c oSIPTL2DAB = new Stock_Inventory__c(
                PTL__c = oPTL2.Id,
                Inventory_Date__c = Date.Today(),
                Type__c = 'DAB'
            );
            lSIToInsert.add(oSIPTL2DAB);*/
            insert lSIToInsert;
            system.debug(LoggingLevel.WARN, '### lSIToInsert.size() : ' + lSIToInsert.size());
            
            // Stock Inventory Brands
            list<Stock_Inventory_Brand__c> lSIBrandToInsert = new list<Stock_Inventory_Brand__c>();
            
            Stock_Inventory_Brand__c oSIBrandButagaz1 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandButagaz.Id,
                Stock_Inventory__c = oSIPTL1Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 1,
                Number_of_Bottle_Slots_5_6__c = 2,
                Number_of_Bottle_Slots_35__c = 3
            );
            lSIBrandToInsert.add(oSIBrandButagaz1);
            
            Stock_Inventory_Brand__c oSIBrandNational1 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandNational.Id,
                Stock_Inventory__c = oSIPTL1Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 4,
                Number_of_Bottle_Slots_5_6__c = 5,
                Number_of_Bottle_Slots_35__c = 6
            );
            lSIBrandToInsert.add(oSIBrandNational1);
            
            Stock_Inventory_Brand__c oSIBrandDistributor1 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandDistributor.Id,
                Stock_Inventory__c = oSIPTL1Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 7,
                Number_of_Bottle_Slots_5_6__c = 8,
                Number_of_Bottle_Slots_35__c = 9
            );
            lSIBrandToInsert.add(oSIBrandDistributor1);
            
            Stock_Inventory_Brand__c oSIBrandButagaz2 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandButagaz.Id,
                Stock_Inventory__c = oSIPTL1DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 1,
                Number_of_Bottle_Slots_5_6__c = 2,
                Number_of_Bottle_Slots_35__c = 3
            );
            lSIBrandToInsert.add(oSIBrandButagaz2);
            
            Stock_Inventory_Brand__c oSIBrandNational2 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandNational.Id,
                Stock_Inventory__c = oSIPTL1DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 4,
                Number_of_Bottle_Slots_5_6__c = 5,
                Number_of_Bottle_Slots_35__c = 6
            );
            lSIBrandToInsert.add(oSIBrandNational2);
            
            Stock_Inventory_Brand__c oSIBrandDistributor2 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandDistributor.Id,
                Stock_Inventory__c = oSIPTL1DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 7,
                Number_of_Bottle_Slots_5_6__c = 8,
                Number_of_Bottle_Slots_35__c = 9
            );
            lSIBrandToInsert.add(oSIBrandDistributor2);
    
            /*Stock_Inventory_Brand__c oSIBrandButagaz3 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandButagaz.Id,
                Stock_Inventory__c = oSIPTL2Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 1,
                Number_of_Bottle_Slots_5_6__c = 2,
                Number_of_Bottle_Slots_35__c = 3
            );
            lSIBrandToInsert.add(oSIBrandButagaz3);
            
            Stock_Inventory_Brand__c oSIBrandNational3 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandNational.Id,
                Stock_Inventory__c = oSIPTL2Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 4,
                Number_of_Bottle_Slots_5_6__c = 5,
                Number_of_Bottle_Slots_35__c = 6
            );
            lSIBrandToInsert.add(oSIBrandNational3);
            
            Stock_Inventory_Brand__c oSIBrandDistributor3 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandDistributor.Id,
                Stock_Inventory__c = oSIPTL2Rack.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 7,
                Number_of_Bottle_Slots_5_6__c = 8,
                Number_of_Bottle_Slots_35__c = 9
            );
            lSIBrandToInsert.add(oSIBrandDistributor3);
    
            Stock_Inventory_Brand__c oSIBrandButagaz4 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandButagaz.Id,
                Stock_Inventory__c = oSIPTL2DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 1,
                Number_of_Bottle_Slots_5_6__c = 2,
                Number_of_Bottle_Slots_35__c = 3
            );
            lSIBrandToInsert.add(oSIBrandButagaz4);
            
            Stock_Inventory_Brand__c oSIBrandNational4 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandNational.Id,
                Stock_Inventory__c = oSIPTL2DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 4,
                Number_of_Bottle_Slots_5_6__c = 5,
                Number_of_Bottle_Slots_35__c = 6
            );
            lSIBrandToInsert.add(oSIBrandNational4);
            
            Stock_Inventory_Brand__c oSIBrandDistributor4 = new Stock_Inventory_Brand__c(
                Brand__c = oBrandDistributor.Id,
                Stock_Inventory__c = oSIPTL2DAB.Id,
                Presence__c = true,
                Number_of_Bottle_Slots_10_13__c = 7,
                Number_of_Bottle_Slots_5_6__c = 8,
                Number_of_Bottle_Slots_35__c = 9
            );
            lSIBrandToInsert.add(oSIBrandDistributor4);*/
    
            insert lSIBrandToInsert;
            system.debug(LoggingLevel.WARN, '### lSIBrandToInsert.size() : ' + lSIBrandToInsert.size());
            
            
            Test.startTest();
    
            VFC_StockInventory oVSIPTL1Rack = new VFC_StockInventory(new ApexPages.standardcontroller(oSIPTL1Rack));
            oVSIPTL1Rack.calcStockShare();
            oVSIPTL1Rack.saveBtn();
            VFC_StockInventory oVSIPTL1DAB = new VFC_StockInventory(new ApexPages.standardcontroller(oSIPTL1DAB));
            oVSIPTL1DAB.calcStockShare();
            oVSIPTL1DAB.saveBtn();
            /*VFC_StockInventory oVSIPTL2Rack = new VFC_StockInventory(new ApexPages.standardcontroller(oSIPTL2Rack));
            oVSIPTL2Rack.calcStockShare();
            oVSIPTL2Rack.saveBtn();
            VFC_StockInventory oVSIPTL2DAB = new VFC_StockInventory(new ApexPages.standardcontroller(oSIPTL2DAB));
            oVSIPTL2DAB.calcStockShare();
            oVSIPTL2DAB.saveBtn();*/
            
            List<PTL__c> lPTLToCheck = [SELECT Id, Last_Stock_Inventory_Date_Rack__c, Last_Stock_Inventory_Date_DAB__c FROM PTL__c WHERE Id =: oPTL1.Id];
            system.debug(LoggingLevel.WARN, '### lPTLToCheck.size() : ' + lPTLToCheck.size());
            System.assertEquals(1, lPTLToCheck.size(), 'Number of records after job run');
            for(PTL__c oPTLToCheck:lPTLToCheck){
                System.assertEquals(Date.Today(), oPTLToCheck.Last_Stock_Inventory_Date_Rack__c, 'Number of records after job run');
                System.assertEquals(Date.Today() - 1, oPTLToCheck.Last_Stock_Inventory_Date_DAB__c, 'Number of records after job run');
            }

            Test.stopTest();
            System.Debug('### >>>>> testing class AP_StockInventory_01_Test END <<<<<');
        //}
          
    }
}