public class VFC_Clone_InventoryPricing{
    private ApexPages.Standardcontroller stdController;
    private Inventory_Pricing__c IPToClone;
    private Inventory_Pricing__c IPCloned;
    private string sPTLId;
    
    public VFC_Clone_InventoryPricing(ApexPages.StandardController stdController){
        this.stdController = stdController;
    }
    /* Clone Inventory Pricing*/
    private String getSOQLQueryForIP(Inventory_Pricing__c OldIP){
    String SOQLQuery = 'SELECT ';
    
    List<String> fieldNames = new List<String>();
    for (String fieldName : Schema.SObjectType.Inventory_Pricing__c.fields.getMap().keySet()){
            fieldNames.add(fieldName);
    }
        
    SOQLQuery += String.join(fieldNames, ',');
    SOQLQuery += ' FROM Inventory_Pricing__c WHERE Id = \'';
    SOQLQuery += OldIP.Id;
    SOQLQuery += '\'';
    return SOQLQuery;    
    }

    private Inventory_Pricing__c getOldIP(){
        if (this.IPToClone== null){
            String SOQLQuery = this.getSOQLQueryForIP((Inventory_Pricing__c) this.stdController.getRecord());
            this.IPToClone = Database.query(SOQLQuery);
        }
        return this.IPToClone;
    }

    private void doCloneIP(){
        // Insert the new Inventory Pricing.
        
        this.IPCloned= this.getOldIP().clone();
        this.IPCloned.Inventory_Date__c=date.today();
        insert this.IPCloned;
    }
    
    /* Clone Inventory Pricing Brands*/
    private String getSOQLQueryForIPBrands(){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.Inventory_Pricing_Brand__c.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        SOQLQuery += String.join(fieldNames, ',');
        SOQLQuery += ' FROM Inventory_Pricing_Brand__c WHERE Inventory_Pricing__c = \'';
        SOQLQuery += this.getOldIP().Id;
        SOQLQuery += '\'';
        return SOQLQuery;
    }    

    private void doCloneIPBrands(){
        // Clone Inventory Pricing Brands
        Inventory_Pricing_Brand__c IPBrandCloned;
        for (Inventory_Pricing_Brand__c IPBrandToClone : Database.query(this.getSOQLQueryForIPBrands())){
            IPBrandCloned= IPBrandToClone.clone();
            IPBrandCloned.Inventory_Pricing__c= this.IPCloned.Id;
            insert IPBrandCloned;
            // Clone Inventory Pricing Articles
            this.doCloneIPArticles(IPBrandToClone,IPBrandCloned);                                  
        }
    }
    
    /* Clone Inventory Pricing Articles for a given Inventory Pricing Brand*/
    private String getSOQLQueryForIPArticles(Inventory_Pricing_Brand__c OldIPBrand){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.Inventory_Pricing_Article__c.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        SOQLQuery += String.join(fieldNames, ',');
        SOQLQuery += ' FROM Inventory_Pricing_Article__c WHERE Inventory_Pricing_Brand__c = \'';
        SOQLQuery += OldIPBrand.Id;
        SOQLQuery += '\'';
        return SOQLQuery;
    }    

    private void doCloneIPArticles(Inventory_Pricing_Brand__c OldIPBrand,
                                    Inventory_Pricing_Brand__c NewIPBrand){
        // Clone Inventory Pricing Articles
        Inventory_Pricing_Article__c IPArticleCloned;
        for (Inventory_Pricing_Article__c IPArticleToClone : Database.query(this.getSOQLQueryForIPArticles(OldIPBrand))){
            IPArticleCloned= IPArticleToClone.clone();
            IPArticleCloned.Inventory_Pricing_Brand__c= NewIPBrand.Id;
            insert IPArticleCloned;
        }
    }    
    
    // Update Butagaz Stock Installed
    private void updateButagazStockInstalled(){
    	list<Inventory_Pricing_Article__c> lIPArticle = new list<Inventory_Pricing_Article__c>();
    	list<Inventory_Pricing_Article__c> lIPArticleToUpdate = new list<Inventory_Pricing_Article__c>();
    	Inventory_Pricing_Brand__c oIPBrandToUpdate = null;
    	list<Id> lArticlesId = new list<Id>();
    	map<Id,decimal> mapButagazStockInstalled = new map<Id,decimal>();
    	boolean bButagazPresence=false;
    	    		
    	system.debug('### CVER-updateButagazStockInstalled');

    	// Recover information to update
    	for(Inventory_Pricing_Brand__c oIPBrand:[select Id, Presence__c, (select Id, Presence__c, Bottle_Number__c, Article__r.Id from Inventory_Pricing_Articles__r) from Inventory_Pricing_Brand__c where Inventory_pricing__c =: this.IPCloned.Id and brand__r.Name__c = 'Butagaz']){
	        oIPBrandToUpdate = oIPBrand;
	        lIPArticle = oIPBrand.Inventory_Pricing_Articles__r;
    	}
    	
    	system.debug('### CVER-updateButagazStockInstalled-lIPArticle.size():' + lIPArticle.size());
    	
    	if(lIPArticle.size()>0){
    		for(Inventory_Pricing_Article__c oIPArticle:lIPArticle){
    			lArticlesId.add(oIPArticle.Article__r.Id);
    		}
    		
    		system.debug('### CVER-updateButagazStockInstalled-lArticlesId.size():' + lArticlesId.size());
    		
    		if(lArticlesId.size()>0){    		
				// Recover "Butagaz Stock Installed"
				for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, Stock_installe__c from Butagaz_Stock_Installed__c where PTL__c=:IPCloned.PTL__c and Article__c in :lArticlesId]){
			        mapButagazStockInstalled.put(oStockInstalled.Article__c, oStockInstalled.Stock_installe__c);
		        }
		        
		        // Update Inventory Pricing Article Information
	    		for(Inventory_Pricing_Article__c oIPArticle:lIPArticle){
	    			if(mapButagazStockInstalled.containsKey(oIPArticle.Article__r.Id)){
						bButagazPresence=true;
						oIPArticle.Bottle_Number__c = mapButagazStockInstalled.get(oIPArticle.Article__r.Id);
    					oIPArticle.Presence__c = true;
    				}
    				else{
						oIPArticle.Bottle_Number__c = null;
    					oIPArticle.Presence__c = false;    					
    				}
    				lIPArticleToUpdate.add(oIPArticle);
	    		}
	    		
	    		// Update Inventory Pricing Brand Information
	    		if(bButagazPresence)
	    			oIPBrandToUpdate.Presence__c = true;
	    		else
	    			oIPBrandToUpdate.Presence__c = false;
	    		
	    		// Update database
	    		update oIPBrandToUpdate;
	    		if(lIPArticleToUpdate.size()>0){
	    			update lIPArticleToUpdate;
	    		}
    		}
    	}
    }
    
    /* Call the clone methods */
    public PageReference CloneInventoryPricing(){
        if (this.IPCloned== null){
            this.doCloneIP();
            this.doCloneIPBrands();
            this.updateButagazStockInstalled();
        }
        return new PageReference('/' + this.IPCloned.Id);
    }


}