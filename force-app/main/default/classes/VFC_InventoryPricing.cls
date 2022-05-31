public class VFC_InventoryPricing{
    // ************
    // MEMBERS
    // ************ 
    public Inventory_Pricing__c oIP {get;set;}
    ApexPages.StandardController oControl;  
    public string sMode {get;set;}
    public PTL__c oPTL {get;set;}
    public list<cBrandArticle> lBrandArticle_Butagaz {get;set;}
    public list<cBrandArticle> lBrandArticle_National {get;set;}
    public list<cBrandArticle> lBrandArticle_Distributor {get;set;}
    public transient list<cBrandArticle> lBrandArticle {get;set;}
    public transient Savepoint sp;
    public boolean bIssue {get;set;}
    public string LocalCurrencyFormat {get;set;}
    
    // ************
    // CONTROLLER
    // ************ 
    public VFC_InventoryPricing(ApexPages.StandardController oControl_in){
        oControl=oControl_in;        
        oIP=(Inventory_Pricing__c)oControl.getRecord();
        
        // Recover page mode
        sMode=(oIP.Id==null?'New':'Edit');
        
        // Recover Inventory Pricing information
        if(sMode=='New') oIP.Inventory_Date__c = Date.today();
        
        // Recover PTL information  
        string sPTLId=oIP.PTL__c;
        
        system.debug('### CVER VFC_InventoryPricing-sPTLId:' + sPTLId);

        // "New button" from the Inventory Pricing tab
        if(sPTLId == null){
            bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.FATAL,System.Label.creation_releve_de_prix_depuis_PTL));
        }
        else{   
            bIssue=false;

            oPTL=[select id, Name, Centrale_Number__c from PTL__c where id=:sPTLId];
                 
            if(sMode=='New'){
                string sCentrale=oPTL.Centrale_Number__c;
                
                // Recover National Brands + "Distributeur" of the centrale
                list<Brand__c> lBrands=new list<Brand__c>();
                for(Brand__c oBrand:[select id, Name__c, Centrale__c, Type__c, Ordre_de_tri__c from Brand__c 
                    where Display_On_Inventory_Pricing__c = True and ( Type__c = 'Nationale' or (Type__c = 'Distributeur' and Centrale__c=:sCentrale) ) order by Ordre_de_tri__c]){
                    lBrands.add(oBrand);
                }
                
                system.debug('### CVER VFC_InventoryPricing-lBrands.size:' + lBrands.size());   

                // Recover Articles information
                 
                list<string> lCdArticles = new list<string>(); // list of External IDs on CS
                list<Item__c> lArticles = new list<Item__c>(); // list of Item__c (will be used for Butagaz_stock_installed)
                map<String, Decimal> mapExtIDToOrder = new map<String, Decimal>(); //map of External ID, Order tri
                list<ItemComparable> lArticlesComparable = new List<ItemComparable>(); // list of ItemComparable inner class wrapped item__c and its order
                
                for (GEB_Code_Articles_BTZ__c mapArticles : GEB_Code_Articles_BTZ__c.getAll().values()){
                    if(mapArticles.Type__c.toUpperCase() == 'BOUTEILLE'){
                        lCdArticles.add(mapArticles.External_ID__c);
                        mapExtIDToOrder.put(mapArticles.External_ID__c, mapArticles.Ordre_de_tri__c);
                    }    
                }
                                
                
                if(lCdArticles.size()>0){
                    for(Item__c oArticle:[select id, Name, No_BTZ__c,Code_Article__c, ExternalID__c from Item__c where ExternalID__c in :lCdArticles or No_BTZ__c=true order by No_BTZ__c limit 1000]){
                        lArticles.add(oArticle);
                        lArticlesComparable.add(new ItemComparable(oArticle, mapExtIDToOrder.get(oArticle.ExternalID__c)));
                    }
                }
                lArticlesComparable.sort();
                
                System.debug('ExtID'+lArticlesComparable);
                
                system.debug('### CVER VFC_InventoryPricing-lCdArticles.size:' + lCdArticles.size());
                
                // Recover "Inventory Pricing Brand" and "Inventory Pricing Article"
                lBrandArticle_Butagaz = new list<cBrandArticle>();
                lBrandArticle_National = new list<cBrandArticle>();
                lBrandArticle_Distributor = new list<cBrandArticle>();
        
                if(lArticlesComparable.size()>0){
                    // Recover "Butagaz Stock Installed"
                    map<Id,decimal> mapButagazStockInstalled=new map<Id,decimal>(); 
                    decimal dButagazStockInstalled=null;
                    boolean bButagazPresence=false;
                    boolean bButagazPresenceArticle=false;
                    
                    for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, Stock_installe__c from Butagaz_Stock_Installed__c where PTL__c=:sPTLId and Article__c in :lArticles ]){
                        mapButagazStockInstalled.put(oStockInstalled.Article__c, oStockInstalled.Stock_installe__c);
                    }                   
                    
                    for(Brand__c oBrand:lBrands){
                        //Inventory_Pricing_Brand__c oIPBrand = new Inventory_Pricing_Brand__c(Inventory_pricing__r=oIP, Brand__r=oBrand);
                        Inventory_Pricing_Brand__c oIPBrand = new Inventory_Pricing_Brand__c(Brand__r=oBrand);
                        list<Inventory_Pricing_Article__c> lBrandIPArticles = new list<Inventory_Pricing_Article__c>();
                        
                        //Using the list of ItemComparable already sorted!
                        for(ItemComparable oItemComparable : lArticlesComparable){
                            // Butagaz Brand : Stock Installed
                            if(oBrand.Name__c.toUpperCase() == 'BUTAGAZ'){
                                dButagazStockInstalled = null;
                                bButagazPresenceArticle=false;
                                
                                if(mapButagazStockInstalled.containsKey(oItemComparable.oItem.Id)){
                                    dButagazStockInstalled = mapButagazStockInstalled.get(oItemComparable.oItem.Id);
                                    if(dButagazStockInstalled!=0){
                                        bButagazPresence = true;
                                        bButagazPresenceArticle = true; 
                                    }
                                    else
                                    {
                                        dButagazStockInstalled=null;
                                    }

                                }
                                if(oItemComparable.oItem.No_BTZ__c==false){
                                    lBrandIPArticles.add(new Inventory_Pricing_Article__c(Inventory_Pricing_Brand__r=oIPBrand, Article__c=oItemComparable.oItem.Id, Article__r=oItemComparable.oItem, Bottle_Number__c=dButagazStockInstalled, Presence__c=bButagazPresenceArticle));
                                }                          
                            }
                            else {
                                dButagazStockInstalled = null;
                                bButagazPresenceArticle=false;
                                
                                lBrandIPArticles.add(new Inventory_Pricing_Article__c(Inventory_Pricing_Brand__r=oIPBrand, Article__c=oItemComparable.oItem.Id, Article__r=oItemComparable.oItem, Bottle_Number__c=dButagazStockInstalled, Presence__c=bButagazPresenceArticle));                           
                            }

                        }
                        
                        // Butagaz Brand    
                        if(oBrand.Name__c.toUpperCase() == 'BUTAGAZ'){
                            oIPBrand.Presence__c = bButagazPresence;                                                    
                            lBrandArticle_Butagaz.add(new cBrandArticle(oIPBrand, lBrandIPArticles));                           
                        }
                        // National Brands
                        else if(oBrand.Type__c.toUpperCase() == 'NATIONALE'){
                            lBrandArticle_National.add(new cBrandArticle(oIPBrand, lBrandIPArticles));                          
                        }
                        // Distibutor Brand
                        else{
                            lBrandArticle_Distributor.add(new cBrandArticle(oIPBrand, lBrandIPArticles));
                        }
                    }
                } 
            }
            else{
                // Recover "Inventory Pricing Brand" and "Inventory Pricing Article"
                lBrandArticle_Butagaz = new list<cBrandArticle>();
                lBrandArticle_National = new list<cBrandArticle>();
                lBrandArticle_Distributor = new list<cBrandArticle>();
                
                list<Inventory_Pricing_Brand__c> lIPBrands = new list<Inventory_Pricing_Brand__c>();
                list<Inventory_Pricing_Article__c> lIPArticle = new list <Inventory_Pricing_Article__c>();
                
                for(Inventory_Pricing_Brand__c oIPBrand:[select id, Inventory_pricing__c, Brand__c, Brand__r.Name__c, Brand__r.Type__c, Delivery_Frequency__c, Presence__c, Release_Date__c,Prix_indiferencie__c from Inventory_Pricing_Brand__c where Inventory_pricing__c =:oIP.Id]){
                    lIPBrands.add(oIPBrand);
                }
                
                if(lIPBrands.size()>0){
                    for(Inventory_Pricing_Article__c oIPArticle:[select id, Inventory_Pricing_Brand__c, Inventory_Pricing_Brand__r.Brand__r.Name__c, Article__c, Article__r.Name,Article__r.No_BTZ__c,Article__r.Code_Article__c, Bottle_Number__c, Charging_Price__c, BTZ_Charging_Price__c,Prix_indiferencie__c, BTZ_Price_Differential__c, Presence__c, Promotion__c, Promotion_End_Date__c, Promotion_Start_Date__c, Release_Date__c from Inventory_Pricing_Article__c where Inventory_Pricing_Brand__c in :lIPBrands]){
                        lIPArticle.add(oIPArticle);
                    }
                    
                    for(Inventory_Pricing_Brand__c oIPBrand:lIPBrands){
                        list<Inventory_Pricing_Article__c> lIPArticleTemp = new list <Inventory_Pricing_Article__c>();
                        
                        for(Inventory_Pricing_Article__c oIPArticle:lIPArticle){
                            if(oIPArticle.Inventory_Pricing_Brand__c == oIPBrand.Id){
                                lIPArticleTemp.add(oIPArticle); 
                            }
                        }
                        
                        // Butagaz Brand    
                        if(oIPBrand.Brand__r.Name__c.toUpperCase() == 'BUTAGAZ'){
                            lBrandArticle_Butagaz.add(new cBrandArticle(oIPBrand, lIPArticleTemp));                         
                        }
                        // National Brands
                        else if(oIPBrand.Brand__r.Type__c.toUpperCase() == 'NATIONALE'){
                            lBrandArticle_National.add(new cBrandArticle(oIPBrand, lIPArticleTemp));                        
                        }
                        // Distibutor Brand
                        else{
                            lBrandArticle_Distributor.add(new cBrandArticle(oIPBrand, lIPArticleTemp));
                        }                        
                    }       
                }           
            }
        }           
    
        LocalCurrencyFormat = UserInfo.getLocale();
    
    }
    
    // ************
    // METHODS
    // ************     
    
    // ****************************  
    // Calculate Price Differential
    // ****************************
    public pageReference calcPriceDifferentialBtn(){
        system.debug('### CVER BEGIN-calcPriceDifferentialBtn');
        
        calcPriceDifferential();
        return null;
    }

    public void calcPriceDifferential(){
        system.debug('### CVER BEGIN-calcPriceDifferential');
       
        map<string,decimal> mapButagazPrice=new map<string,decimal>();
        
        lBrandArticle = new list<cBrandArticle>();
        // Butagaz Brand
        for(cBrandArticle oBrandArticle:lBrandArticle_Butagaz){
            lBrandArticle.add(oBrandArticle);
        }
        // National Brands
        for(cBrandArticle oBrandArticle:lBrandArticle_National){
            lBrandArticle.add(oBrandArticle);
        }
        // Distibutor Brand
        for(cBrandArticle oBrandArticle:lBrandArticle_Distributor){
            lBrandArticle.add(oBrandArticle);
        }             

        if(lBrandArticle.size()>0){
            for(cBrandArticle oBrandArticle:lBrandArticle){
                system.debug('### CVER calcPriceDifferential-Brand:' + oBrandArticle.oIPBrand.Brand__r.Name__c);
                
                for(Inventory_Pricing_Article__c oIPArticle:oBrandArticle.lIPArticles){
                    system.debug('### CVER calcPriceDifferential-IP Article:' + oIPArticle.Article__r.Name + ' - Charging Price:' + oIPArticle.Charging_Price__c);

                    if(oIPArticle.Inventory_Pricing_Brand__r.Brand__r.Name__c=='Butagaz'){
                        oIPArticle.BTZ_Charging_Price__c=oIPArticle.Charging_Price__c;
                        mapButagazPrice.put(oIPArticle.Article__r.Id,oIPArticle.Charging_Price__c);
                        
                        if(oIPArticle.Article__r.Name =='BUTANE 13KG') {
                            oIP.Prix_BD_Ref__c=oIPArticle.Charging_Price__c;
                        }                       
                        
                        system.debug('### CVER calcPriceDifferential-mapButagazPrice:' + oIPArticle.Article__r.Name + ' - Price:' + mapButagazPrice.get(oIPArticle.Article__r.Id));
                    }
                    else{
                        if(mapButagazPrice.containsKey(oIPArticle.Article__r.Id)){
                            system.debug('### CVER calcPriceDifferential- Brand Price:' + oIPArticle.Article__r.Name + ' - Price:' + oIPArticle.Charging_Price__c + ' - Butagaz Price:' + mapButagazPrice.get(oIPArticle.Article__r.id));
                            
                            oIPArticle.BTZ_Charging_Price__c=mapButagazPrice.get(oIPArticle.Article__r.Id);
                            if(mapButagazPrice.get(oIPArticle.Article__r.Id) != null && oIPArticle.Charging_Price__c != null){
                                oIPArticle.BTZ_Price_Differential__c = oIPArticle.Charging_Price__c - mapButagazPrice.get(oIPArticle.Article__r.Id);    
                            }
                            else
                                oIPArticle.BTZ_Price_Differential__c = null;
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
        system.debug('### CVER BEGIN-saveBtn');
        
        list<Inventory_Pricing_Brand__c> lIPBrandsToUpsert = new list<Inventory_Pricing_Brand__c>();
        list<Inventory_Pricing_Article__c> lIPArticlesToUpsert = new list <Inventory_Pricing_Article__c>();
        map<id,id> mapIPBrands=new map<id,id>();
        string sIPId = null;
        
        calcPriceDifferential();
        
        try{
            //oControl.save();

            // Define a save point
            sp = Database.setSavepoint();           

            // Upsert Inventory Pricing
            Inventory_Pricing__c oIPToUpsert = oIP.clone(true);
            Database.UpsertResult oUpsertResultIP=database.upsert(oIPToUpsert);
            
            if(oUpsertResultIP.isSuccess()){ 
                sIPId = oUpsertResultIP.getId();
                      
                // Upsert Inventory Pricing Brand
                if(lBrandArticle.size()>0){         
                    for(cBrandArticle oBrandArticle:lBrandArticle){
                        Inventory_Pricing_Brand__c oIPBrandToUpsert = oBrandArticle.oIPBrand.clone(true);
                        
                        if(sMode=='New'){
                            //oIPBrandToUpsert.Inventory_pricing__c=oControl.getId();
                            oIPBrandToUpsert.Inventory_pricing__c=sIPId;
                            oIPBrandToUpsert.Brand__c=oBrandArticle.oIPBrand.Brand__r.id;
                        }
                        lIPBrandsToUpsert.add(oIPBrandToUpsert);
                    }
        
                    system.debug('### CVER saveBtn-lIPBrandsToUpsert.size' + lIPBrandsToUpsert.size());
                    
                    if(lIPBrandsToUpsert.size()>0){
                        list<Database.UpsertResult> lUpsertResult=database.upsert(lIPBrandsToUpsert,false);
                        
                        system.debug('### CVER saveBtn-lUpsertResult.size:' + lUpsertResult.size() + '-sMode:' + sMode);
                        
                        if(sMode=='New'){
                            // Vérification du résultat de l'opération en base de données
                            for (integer i=0;i<lUpsertResult.size();i++){
                                Database.UpsertResult oUpsertResult=lUpsertResult[i];
            
                                system.debug('### CVER saveBtn-getErrors:' + oUpsertResult.getErrors());
                                if(oUpsertResult.isSuccess()){ 
                                    Inventory_Pricing_Brand__c oIPBrand = lIPBrandsToUpsert[i];               
                                    mapIPBrands.put(oIPBrand.Brand__r.Id, oUpsertResult.getId());
                                }
                            }
                        }
                                        
                        // Upsert Inventory Pricing Article
                        for(cBrandArticle oBrandArticle:lBrandArticle){
                            for(Inventory_Pricing_Article__c oIPArticle:oBrandArticle.lIPArticles){
                                Inventory_Pricing_Article__c oIPArticleToUpsert = null;
                                if(sMode=='New'){
                                    oIPArticleToUpsert = new Inventory_Pricing_Article__c(
                                        Inventory_Pricing_Brand__c=mapIPBrands.get(oBrandArticle.oIPBrand.Brand__r.Id),
                                        Article__c=oIPArticle.Article__c,
                                        Bottle_Number__c=oIPArticle.Bottle_Number__c,
                                        Charging_Price__c=oIPArticle.Charging_Price__c,
                                        Prix_indiferencie__c=oIPArticle.Prix_indiferencie__c,
                                        BTZ_Charging_Price__c=oIPArticle.BTZ_Charging_Price__c,
                                        BTZ_Price_Differential__c=oIPArticle.BTZ_Price_Differential__c,
                                        Presence__c=oIPArticle.Presence__c,
                                        Promotion__c=oIPArticle.Promotion__c,
                                        Promotion_End_Date__c=oIPArticle.Promotion_End_Date__c,
                                        Promotion_Start_Date__c=oIPArticle.Promotion_Start_Date__c,
                                        Release_Date__c=oIPArticle.Release_Date__c
                                    );
                                }
                                else{
                                    oIPArticleToUpsert = oIPArticle.clone(true);
                                }
                                
                                lIPArticlesToUpsert.add(oIPArticleToUpsert);                        
                            }
                        }       
                        
                        if(lIPArticlesToUpsert.size()>0){
                            upsert lIPArticlesToUpsert;
                        }   
                    }
                } 
                //return new PageReference('/' + oControl.getId());
                return new PageReference('/' + sIPId); 
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
    
    public class cBrandArticle{
        public Inventory_Pricing_Brand__c oIPBrand {get;set;}
        public list<Inventory_Pricing_Article__c> lIPArticles {get;set;}

        public cBrandArticle(Inventory_Pricing_Brand__c oIPBrand, list<Inventory_Pricing_Article__c> lIPArticles){
            this.oIPBrand = oIPBrand;
            this.lIPArticles = lIPArticles;
        }
    }
    
    public class ItemComparable implements Comparable {
        public Item__c oItem;
        public Decimal sortOrder;
        
        public ItemComparable(Item__c oItem, Decimal sortOrder){
            this.oItem = oItem;
            this.sortOrder = sortOrder;
        }
        
        public Integer compareTo(Object compareTo){
            ItemComparable obj = (ItemComparable)compareTo;
            if(sortOrder == obj.sortOrder) return 0;
            if(sortOrder > obj.sortOrder) return 1;
            return -1;
        }

    }
    
    
}