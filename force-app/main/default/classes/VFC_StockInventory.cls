public class VFC_StockInventory {
    // ************
    // MEMBERS
    // ************ 
    public Stock_Inventory__c oSI {get;set;}
    ApexPages.StandardController oControl;  
    public string sMode {get;set;}
    public PTL__c oPTL {get;set;}
    public list<Stock_Inventory_Brand__c> lSIBrand_Butagaz {get;set;}
    public list<Stock_Inventory_Brand__c> lSIBrand_National {get;set;}
    public list<Stock_Inventory_Brand__c> lSIBrand_Distributor {get;set;}
    public transient list<Stock_Inventory_Brand__c> lSIBrand {get;set;}
    public transient Savepoint sp;
    public boolean bIssue {get;set;}
    
    // ************
    // CONTROLLER
    // ************ 
    public VFC_StockInventory(ApexPages.StandardController oControl_in){
        oControl=oControl_in;        
        oSI=(Stock_Inventory__c)oControl.getRecord();
        
        // Recover page mode
        sMode=(oSI.Id==null?'New':'Edit');
        
        // Recover Stock Inventory information
        if(sMode=='New') oSI.Inventory_Date__c = Date.today();
        
        // Recover PTL information  
        string sPTLId = oSI.PTL__c;
        
        system.debug('### VFC_StockInventory-sPTLId:' + sPTLId);

        // "New button" from the Stock Inventory tab
        if(sPTLId == null){
            bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.FATAL,System.Label.Stock_Inventory_Creation_From_PTL));
        }else{   
            bIssue=false;

            oPTL=[select id, Name, Centrale_Number__c, Enseigne__c, Sous_canal__c from PTL__c where id=:sPTLId];
                 
            if(sMode=='New'){
                string sCentrale=oPTL.Centrale_Number__c;
                
                // Recover National Brands + "Distributeur" of the centrale
                list<Brand__c> lBrands = new list<Brand__c>();
                for(Brand__c oBrand:[select id, Name__c, Centrale__c, Type__c, Ordre_de_tri__c from Brand__c 
                    where Display_On_Stock_Inventory__c = True and ( Type__c = 'Nationale' or (Type__c = 'Distributeur' and Centrale__c=:sCentrale) ) order by Ordre_de_tri__c]){
                    
                    lBrands.add(oBrand);
                }
                
                system.debug('### VFC_StockInventory-lBrands.size:' + lBrands.size());

                // Recover Articles information
                 
                list<string> lCdArticles = new list<string>(); // list of External IDs on CS
                list<Item__c> lArticles = new list<Item__c>(); // list of Item__c (will be used for Butagaz_stock_installed)
                
                // Recover items from Custom Settings
                for (GEB_Code_Articles_BTZ__c mapArticles : GEB_Code_Articles_BTZ__c.getAll().values()){
                    if(mapArticles.Type__c.toUpperCase() == 'BOUTEILLE'){
                        lCdArticles.add(mapArticles.External_ID__c);
                    }
                }

                if(lCdArticles.size()>0){
                    for(Item__c oArticle:[select id, Name, No_BTZ__c, Code_Article__c, ExternalID__c, Capacity__c from Item__c where ExternalID__c in :lCdArticles or No_BTZ__c=true order by No_BTZ__c limit 1000]){
                        lArticles.add(oArticle);
                    }
                }
                
                system.debug('### VFC_StockInventory-lCdArticles.size:' + lCdArticles.size());
                
                // Recover "Stock Inventory Brand"
                lSIBrand_Butagaz = new list<Stock_Inventory_Brand__c>();
                lSIBrand_National = new list<Stock_Inventory_Brand__c>();
                lSIBrand_Distributor = new list<Stock_Inventory_Brand__c>();
        
                if(lArticles.size() > 0){
                    // Recover "Butagaz Stock Installed"
                    map<Id,decimal> mapButagazStockInstalled = new map<Id,decimal>(); 
                    decimal dButagazStockInstalled = null;
                    decimal dButagazStockInstalled_10_13 = 0;
                    decimal dButagazStockInstalled_5_6 = 0;
                    decimal dButagazStockInstalled_35 = 0;
                    boolean bButagazPresence = false;
                    
                    for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, Article__r.Capacity__c, Stock_installe__c from Butagaz_Stock_Installed__c where PTL__c=:sPTLId and Article__c in :lArticles ]){
                        mapButagazStockInstalled.put(oStockInstalled.Article__c, oStockInstalled.Stock_installe__c);
                    }                   
                    
                    for(Brand__c oBrand:lBrands){
                        Stock_Inventory_Brand__c oSIBrand = new Stock_Inventory_Brand__c(Brand__c=oBrand.Id, Brand__r=oBrand);

                        // Using the list of Items
                        for(Item__c oItem : lArticles){
                            // Butagaz Brand : Stock Installed
                            if(oBrand.Name__c.toUpperCase() == 'BUTAGAZ'){
                                dButagazStockInstalled = null;
                                
                                if(mapButagazStockInstalled.containsKey(oItem.Id)){
                                    dButagazStockInstalled = mapButagazStockInstalled.get(oItem.Id);
                                    if(dButagazStockInstalled != 0){
                                   		bButagazPresence = true;
                                        
                                        // Group items by capacity (10-13, 5-6, 35)
                                        switch on Integer.valueOf(oItem.Capacity__c) {
                                            when 10, 13 {
                                                dButagazStockInstalled_10_13 += dButagazStockInstalled;
                                            }
                                            when 5, 6 {
                                                dButagazStockInstalled_5_6 += dButagazStockInstalled;
                                            }
                                            when 35 {
                                                dButagazStockInstalled_35 += dButagazStockInstalled;
                                            }
                                            when else {
                                                // It means it's a capacity we don't manage
                                            }
                                        }

                                    }else{
                                    	dButagazStockInstalled = null;
                                    }
                                }
                                
	                          	if(oItem.No_BTZ__c==false){
                                    oSIBrand.Number_of_Bottle_Slots_10_13__c = dButagazStockInstalled_10_13;
                                    oSIBrand.Number_of_Bottle_Slots_5_6__c = dButagazStockInstalled_5_6;
                                    oSIBrand.Number_of_Bottle_Slots_35__c = dButagazStockInstalled_35;
	                        	}                          
                            }else{
                            	dButagazStockInstalled = null;
                            }

                        }
                        
                        // Butagaz Brand    
                        if(oBrand.Name__c.toUpperCase() == 'BUTAGAZ'){
                            oSIBrand.Presence__c = bButagazPresence;                                                    
                            lSIBrand_Butagaz.add(oSIBrand);
                        }
                        // National Brands
                        else if(oBrand.Type__c.toUpperCase() == 'NATIONALE'){
                            lSIBrand_National.add(oSIBrand);
                        }
                        // Distributor Brand
                        else{
                            lSIBrand_Distributor.add(oSIBrand);
                        }
                    }
                } 
            }
            else{
                // Recover "Stock Inventory Brand" by type
                lSIBrand_Butagaz = new list<Stock_Inventory_Brand__c>();
                lSIBrand_National = new list<Stock_Inventory_Brand__c>();
                lSIBrand_Distributor = new list<Stock_Inventory_Brand__c>();
                
                list<Stock_Inventory_Brand__c> lSIBrands = new list<Stock_Inventory_Brand__c>();
                
                for(Stock_Inventory_Brand__c oSIBrand:[select id, Stock_Inventory__c, Brand__c, Brand__r.Name__c, Brand__r.Type__c, Presence__c, Type__c, Number_of_Bottle_Slots_10_13__c, Number_of_Bottle_Slots_5_6__c, Number_of_Bottle_Slots_35__c, 
                                                    PTL_Stock_Share_10_13__c, PTL_Stock_Share_5_6__c, PTL_Stock_Share_35__c, PTL_Stock_Share_Total__c, Trademark_Stock_Share_10_13__c, Trademark_Stock_Share_5_6__c, Trademark_Stock_Share_35__c, Trademark_Stock_Share_Total__c,
                                                    Subchannel_Stock_Share_10_13__c, Subchannel_Stock_Share_5_6__c, Subchannel_Stock_Share_35__c, Subchannel_Stock_Share_Total__c 
                                                    from Stock_Inventory_Brand__c 
                                                    where Stock_Inventory__c =:oSI.Id]){
                    lSIBrands.add(oSIBrand);
                }
                
                if(lSIBrands.size()>0){
                    for(Stock_Inventory_Brand__c oSIBrand : lSIBrands){
                        // Butagaz Brand    
                        if(oSIBrand.Brand__r.Name__c.toUpperCase() == 'BUTAGAZ'){
                            lSIBrand_Butagaz.add(oSIBrand);
                        }
                        // National Brands
                        else if(oSIBrand.Brand__r.Type__c.toUpperCase() == 'NATIONALE'){
                            lSIBrand_National.add(oSIBrand);
                        }
                        // Distributor Brand
                        else{
                            lSIBrand_Distributor.add(oSIBrand);
                        }                    
                    }       
                }           
            }
        }           
    

    
    }

    // ************
    // METHODS
    // ************     
    
    // ****************************  
    // Calculate Stock Share
    // ****************************
    public pageReference calcStockShareBtn(){
        system.debug('### BEGIN-calcStockShareBtn');
        
        calcStockShare();
        return null;
    }

    public void calcStockShare(){
        system.debug('### BEGIN-calcStockShare');

        Decimal iStockPTL10_13 = 0;
        Decimal iStockPTL5_6 = 0;
        Decimal iStockPTL35 = 0;
        Decimal iStockPTLTotal; // Total stock for the PTL
        
        // Retrieve precalculated Stock national shares
        system.debug(LoggingLevel.WARN, '### oSI.Type__c = ' + oSI.Type__c);
        system.debug(LoggingLevel.WARN, '### oPTL.Centrale_Number__c = ' + oPTL.Centrale_Number__c);
        system.debug(LoggingLevel.WARN, '### oPTL.Enseigne__c = ' + oPTL.Enseigne__c);
        system.debug(LoggingLevel.WARN, '### oPTL.Sous_canal__c = ' + oPTL.Sous_canal__c);
        List<Stock_Inventory_National_Share__c> nationalShares = [select Id, Brand__c, Type__c, Enseigne__c, Sous_canal__c, Stock_Share_10_13__c, Stock_Share_5_6__c, Stock_Share_35__c, Stock_Share_Total__c
                                            from Stock_Inventory_National_Share__c
                                            where Type__c =: oSI.Type__c
                                            and ( Enseigne__c =: oPTL.Enseigne__c or Sous_canal__c =: oPTL.Sous_canal__c ) ];


        lSIBrand = new list<Stock_Inventory_Brand__c>();
        // Butagaz Brand
        for(Stock_Inventory_Brand__c oSIBrand:lSIBrand_Butagaz){
            lSIBrand.add(oSIBrand);
        }
        // National Brands
        for(Stock_Inventory_Brand__c oSIBrand:lSIBrand_National){
            lSIBrand.add(oSIBrand);
        }
        // Distributor Brand
        for(Stock_Inventory_Brand__c oSIBrand:lSIBrand_Distributor){
            lSIBrand.add(oSIBrand);
        }             

        // Calculate PTL stock share
        if(lSIBrand.size()>0){

            // Reset values for rows with Presence__c == false
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                if( !oSIBrand.Presence__c ){
                    oSIBrand.Number_of_Bottle_Slots_10_13__c = null;
                    oSIBrand.Number_of_Bottle_Slots_5_6__c = null;
                    oSIBrand.Number_of_Bottle_Slots_35__c = null;
                    oSIBrand.PTL_Stock_Share_10_13__c = null;
                    oSIBrand.PTL_Stock_Share_5_6__c = null;
                    oSIBrand.PTL_Stock_Share_35__c = null;
                    oSIBrand.PTL_Stock_Share_Total__c = null;
                    oSIBrand.Trademark_Stock_Share_10_13__c = null;
                    oSIBrand.Trademark_Stock_Share_5_6__c = null;
                    oSIBrand.Trademark_Stock_Share_35__c = null;
                    oSIBrand.Trademark_Stock_Share_Total__c = null;
                    oSIBrand.Subchannel_Stock_Share_10_13__c = null;
                    oSIBrand.Subchannel_Stock_Share_5_6__c = null;
                    oSIBrand.Subchannel_Stock_Share_35__c = null;
                    oSIBrand.Subchannel_Stock_Share_Total__c = null;
                }
            }
            
            // Get total per bottle slot
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null) iStockPTL10_13 += oSIBrand.Number_of_Bottle_Slots_10_13__c;
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null) iStockPTL5_6 += oSIBrand.Number_of_Bottle_Slots_5_6__c;
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null) iStockPTL35 += oSIBrand.Number_of_Bottle_Slots_35__c;
            }
            iStockPTLTotal = iStockPTL10_13 + iStockPTL5_6 + iStockPTL35;
            system.debug('### iStockPTLTotal :' + iStockPTLTotal);

            // Calculate share per brand / bottle slot
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                Decimal iStockTotal = 0;
                
                // Calculate share against 10/13 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null && iStockPTL10_13 != null & iStockPTL10_13 != 0){
                    oSIBrand.PTL_Stock_Share_10_13__c = (oSIBrand.Number_of_Bottle_Slots_10_13__c / iStockPTL10_13) * 100;
                }
                // Calculate share against 5/6 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null && iStockPTL5_6 != null & iStockPTL5_6 != 0){
                    oSIBrand.PTL_Stock_Share_5_6__c = (oSIBrand.Number_of_Bottle_Slots_5_6__c / iStockPTL5_6) * 100;
                }
                // Calculate share against 35 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null && iStockPTL35 != null & iStockPTL35 != 0){
                    oSIBrand.PTL_Stock_Share_35__c = (oSIBrand.Number_of_Bottle_Slots_35__c / iStockPTL35) * 100;
                }
                // Calculate share against PTL total stock
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_10_13__c;
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_5_6__c;
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_35__c;
                if(iStockPTLTotal != null & iStockPTLTotal != 0){
                    oSIBrand.PTL_Stock_Share_Total__c = (iStockTotal / iStockPTLTotal) * 100;
                }

                // Put national shares in corresponding fields
                for(Stock_Inventory_National_Share__c oNS:nationalShares){
                    if( oNS.Brand__c == oSIBrand.Brand__c && oSIBrand.Presence__c ){
                        if(oNS.Enseigne__c == oPTL.Enseigne__c){
                            oSIBrand.Trademark_Stock_Share_10_13__c = oNS.Stock_Share_10_13__c;
                            oSIBrand.Trademark_Stock_Share_5_6__c = oNS.Stock_Share_5_6__c;
                            oSIBrand.Trademark_Stock_Share_35__c = oNS.Stock_Share_35__c;
                            oSIBrand.Trademark_Stock_Share_Total__c = oNS.Stock_Share_Total__c;
                        }
                        if(oNS.Sous_canal__c == oPTL.Sous_canal__c){
                            oSIBrand.Subchannel_Stock_Share_10_13__c = oNS.Stock_Share_10_13__c;
                            oSIBrand.Subchannel_Stock_Share_5_6__c = oNS.Stock_Share_5_6__c;
                            oSIBrand.Subchannel_Stock_Share_35__c = oNS.Stock_Share_35__c;
                            oSIBrand.Subchannel_Stock_Share_Total__c = oNS.Stock_Share_Total__c;
                        }
                    }
                }
            }
        }
    }
    
    
    // ****************  
    // Save information
    // ****************
    public pageReference saveBtn(){
        system.debug('### BEGIN-saveBtn');
        
        list<Stock_Inventory_Brand__c> lSIBrandsToUpsert = new list<Stock_Inventory_Brand__c>();
        map<id,id> mapSIBrands=new map<id,id>();
        string sSIId = null;
        

        // Launch Share calculation
        calcStockShare();
        
        try{
            // Define a save point
            sp = Database.setSavepoint();

            // Upsert Stock Inventory
            Stock_Inventory__c oSIToUpsert = oSI.clone(true);
            Database.UpsertResult oUpsertResultSI = database.upsert(oSIToUpsert);
            
            if(oUpsertResultSI.isSuccess()){
                sSIId = oUpsertResultSI.getId();

                // Upsert Stock Inventory Brand
                if(lSIBrand.size()>0){
                    for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                        
                        Stock_Inventory_Brand__c oSIBrandToUpsert = oSIBrand.clone(true);
                        
                        if(sMode=='New'){
                            oSIBrandToUpsert.Stock_Inventory__c = sSIId;
                        }
                        lSIBrandsToUpsert.add(oSIBrandToUpsert);
                    }
        
                    system.debug('### saveBtn-lSIBrandsToUpsert.size' + lSIBrandsToUpsert.size());
                    
                    if(lSIBrandsToUpsert.size()>0){
                        list<Database.UpsertResult> lUpsertResult=database.upsert(lSIBrandsToUpsert,false);
                        
                        system.debug('### saveBtn-lUpsertResult.size:' + lUpsertResult.size() + '-sMode:' + sMode);
                        
                        if(sMode=='New'){
                            // Vérification du résultat de l'opération en base de données
                            for (integer i=0;i<lUpsertResult.size();i++){
                                Database.UpsertResult oUpsertResult=lUpsertResult[i];
            
                                system.debug('### saveBtn-getErrors:' + oUpsertResult.getErrors());
                                if(oUpsertResult.isSuccess()){ 
                                    Stock_Inventory_Brand__c oSIBrand = lSIBrandsToUpsert[i];               
                                    mapSIBrands.put(oSIBrand.Id, oUpsertResult.getId());
                                }
                            }
                        }
                        
                    }
                } 
                return new PageReference('/' + sSIId);
            }
            else{
                return null;
            }
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }     
    }

}