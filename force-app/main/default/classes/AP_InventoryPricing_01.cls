public class AP_InventoryPricing_01 {
	
	private static boolean alreadyUpdatedIP = false;
	private static boolean alreadyUpdatedIPBDPrice = false;
	private static boolean alreadyUpdatedIPbrands = false;	

    public static void recoverLastIPDate(List<Inventory_Pricing__c> lIP){
        String sKeyIP = '';
        Set<String> setIP = new Set<String>();
        List<Id> listUniqueIPId = new list<Id>();
        List<PTL__c> lPTLToUpdate = new list<PTL__c>();
        map<id,date> mapPTLLastIPDate = new map<id,date>();
        
        System.debug('START method AP_InventoryPricing_01.recoverLastIPDate');        
        
        // Recover a list of unique PTL ids
        for(Inventory_Pricing__c oIP:lIP){
            sKeyIP = oIP.PTL__c;
                
            if(setIP.add(sKeyIP))
                listUniqueIPId.add(oIP.PTL__c); 
        }
    
        System.debug('[AP_InventoryPricing_01.recoverLastIPDate] listUniqueIPId Counts: ' + listUniqueIPId.size());
        
        if(listUniqueIPId.size() > 0){
            // Recover Last IP Date per PTL
            AggregateResult[] aggrIP = [Select MAX(Inventory_Date__c) Inventory_Date__c, PTL__c from Inventory_Pricing__c where PTL__c in :listUniqueIPId group by PTL__c];

            // Recover information to Update
            for (AggregateResult ar:aggrIP){ 
                lPTLToUpdate.add(new PTL__c(
                    Id=(Id)ar.get('PTL__c'),
                    Last_Inventory_Pricing_Date__c=(Date)ar.get('Inventory_Date__c')
                ));
                mapPTLLastIPDate.put((Id)ar.get('PTL__c'), (Date)ar.get('Inventory_Date__c'));
            }
            
            // Update "Last Inventory Pricing Date" to null if no more "Inventory Pricing record" on a PTL
            for(Id sPTLId:listUniqueIPId){
                if(!mapPTLLastIPDate.containsKey(sPTLId)){
                    lPTLToUpdate.add(new PTL__c(
                        Id=sPTLId,
                        Last_Inventory_Pricing_Date__c=null
                    ));              
                }
            }
            
            System.debug('[AP_InventoryPricing_01.recoverLastIPDate] lPTLToUpdate Counts: ' + lPTLToUpdate.size());      

            // Update database      
            if(lPTLToUpdate.size()>0){
                try{
                    update lPTLToUpdate;
                } 
                catch(DmlException e){
                    sendErrorMail(e.getMessage());
                }           
            }           
        }
        
        System.debug('END method AP_InventoryPricing_01.recoverLastIPDate');            
    }
  
  public static void recoverLastIPBDPrice(List<Inventory_Pricing__c> lIP){
  
        String sKeyIP = '';
        Set<String> setIP = new Set<String>();
        List<Id> listUniqueIPId = new list<Id>();
        List<PTL__c> lPTLToUpdate = new list<PTL__c>();
        map<id, Inventory_Pricing__c> mPTLLastIP = new map<id, Inventory_Pricing__c>();

    System.debug('START method AP_InventoryPricing_01.recoverLastIPBDPrice');        
    
    // Recover a list of unique PTL ids
    for(Inventory_Pricing__c oIP:lIP){
            sKeyIP = oIP.PTL__c;
            
            if(setIP.add(sKeyIP))
                listUniqueIPId.add(oIP.PTL__c); 
    }
    
    System.debug('[AP_InventoryPricing_01.recoverLastIPBDPrice] listUniqueIPId Counts: ' + listUniqueIPId.size());
    
    if(listUniqueIPId.size() > 0){
        // Recover Last IP Date per PTL
        List<Inventory_Pricing__c> lUniquePTLIP = [Select id, Inventory_Date__c,Prix_BD_Ref__c, PTL__c from Inventory_Pricing__c where PTL__c in :listUniqueIPId];
        
        for(Inventory_Pricing__c oIP :lUniquePTLIP) {
            if(mPTLLastIP.containsKey(oIP.PTL__c)) {
                if(mPTLLastIP.get(oIP.PTL__c).Inventory_Date__c < oIP.Inventory_Date__c) {
                    mPTLLastIP.put(oIP.PTL__c, oIP);
                }
            }
            else {
                mPTLLastIP.put(oIP.PTL__c, oIP);
            }
        }
        
         // Recover information to Update
        for (id PTLID : mPTLLastIP.keySet() ){
            lPTLToUpdate.add(new PTL__c(
                    Id=PTLID,
                    Prix_BD_Ref__c=mPTLLastIP.get(PTLID).Prix_BD_Ref__c
                    )
                    );  
        }   
          
          // Update "Last Inventory Pricing Date" to null if no more "Inventory Pricing record" on a PTL
        for(Id sPTLId:listUniqueIPId){
            if(!mPTLLastIP.containsKey(sPTLId)){
              lPTLToUpdate.add(new PTL__c(
                    Id=sPTLId,
                      Prix_BD_Ref__c=null
                      )
                  );              
            }
        }
          
      System.debug('[AP_InventoryPricing_01.recoverLastIPBDPrice] lPTLToUpdate Counts: ' + lPTLToUpdate.size());      

          // Update database      
          if(lPTLToUpdate.size()>0){
            try{
                  update lPTLToUpdate;
              } 
              catch(DmlException e){
                sendErrorMail(e.getMessage());
              }           
          }           
    }
    
    System.debug('END method AP_InventoryPricing_01.recoverLastIPBDPrice');            
 
    }
    
    public static void sendErrorMail(String errorMessage){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'supportbfi@Butagaz.com'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('supportbfi@Butagaz.com');  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static boolean hasAlreadyUpdatedIP() {
        return alreadyUpdatedIP;
    }
    	
    public static void setAlreadyUpdatedIP(boolean b) {
        alreadyUpdatedIP = b;
    }    
    
    
    public static boolean hasAlreadyUpdatedIPBDPrice() {
        return alreadyUpdatedIPBDPrice;
    }
    	
    public static void setAlreadyUpdatedIPBDPrice(boolean b) {
        alreadyUpdatedIPBDPrice = b;
    }   
    
    
    public static boolean hasAlreadyUpdatedIPBrands() {
        return alreadyUpdatedIPbrands;
    }
    	
    public static void setAlreadyUpdatedIPBrands(boolean b) {
        alreadyUpdatedIPbrands = b;
    }
    
    
    //Erwan 05/02/2015 : Update field "Marques_presentes__c" on the PTL to show which trademarks are on the PTL
    public static void copyIPBrandsToPTL(List<Inventory_Pricing__c> lIP){
        String sKeyIP = '';
        Set<String> setIP = new Set<String>();
        List<Id> listUniqueIPId = new list<Id>();
        List<PTL__c> lPTLToUpdate = new list<PTL__c>();
        String sTmpBrands = '';
        Integer iNbBrands = 0;
        
	    System.debug('START method AP_InventoryPricing_01.copyIPBrandsToPTL');
	    
	    // Recover a list of unique PTL ids
	    for(Inventory_Pricing__c oIP:lIP){
			sKeyIP = oIP.PTL__c;
			
			if(setIP.add(sKeyIP))
				listUniqueIPId.add(oIP.PTL__c);
	    }
	    
	    System.debug('[AP_InventoryPricing_01.copyIPBrandsToPTL] listUniqueIPId Counts: ' + listUniqueIPId.size());
	    
	    if(listUniqueIPId.size() > 0){
	        // Recover PTLs + associated brands
		    List<Inventory_Pricing__c> lUniquePTLIP = [SELECT Id, PTL__c, 
	    													( SELECT Brand_Name__c FROM Inventory_Pricings_Brands__r 
	           													WHERE Presence__c = True AND Release_Date__c = Null ) Brand
													   FROM Inventory_Pricing__c
													   WHERE T_IsPTLLastIPDate__c = True 
													   AND PTL__c in :listUniqueIPId];
	        
	        // Recover information to Update
	        for(Inventory_Pricing__c oIP :lUniquePTLIP) {
	        	
	        	sTmpBrands = '';
	        	iNbBrands = 0;
	        	for(Inventory_Pricing_Brand__c IPB : oIP.Inventory_Pricings_Brands__r){
	        		System.debug('[AP_InventoryPricing_01.copyIPBrandsToPTL] PTL : ' + oIP.PTL__c + ' | Brand: ' + IPB.Brand_Name__c);
	        		sTmpBrands += IPB.Brand_Name__c + ';';
	        		iNbBrands++;
	        	}
	        	
	            lPTLToUpdate.add(new PTL__c(
					Id=oIP.PTL__c,
					Marques_presentes__c=sTmpBrands,
					Nombre_de_marques_presentes__c=iNbBrands
					)
				);
	        }
	      
			System.debug('[AP_InventoryPricing_01.copyIPBrandsToPTL] lPTLToUpdate Counts: ' + lPTLToUpdate.size());
			
			// Update database      
			if(lPTLToUpdate.size() > 0){
				try{
					update lPTLToUpdate;
				}
				catch(DmlException e){}           
			}
	    }
	    
	    System.debug('END method AP_InventoryPricing_01.copyIPBrandsToPTL');            
	}
    
}