public class UpdateOrderFromWorkOrderAction {
    /**
     * updateOrdersFromWorkOrders updates orders linked to the workorders
     *
     * @param {List<ID>} workorderIds
     *
     * @return {void}
     */
	@InvocableMethod(label='Update Orders From Work Orders' description='Updates orders from work orders specified.')
    public static void updateOrdersFromWorkOrders(List<ID> workorderIds) {
		
		map<id, WorkOrder> mWorkOrders = new map<id, WorkOrder>();
		List<Order__c> lOrdersToUpdate = new List<Order__c>();
		List<Item_in_Order__c> lItemsInOrderToUpdate = new List<Item_in_Order__c>();
		
		if (workorderIds.size() == 0) {
            return;
        }
		
		// Retrieve workorders' data
        List<WorkOrder> lWorkOrders= [
            SELECT Id, 
            	Order__c, 
            	Livraison_effectuee__c, 
            	Statut_de_livraison__c, 
            	PRAXEDO__PlanificationAppointmentHour__c, 
            	Motif_de_non_realisation__c, 
            	Raison_de_non_realisation__c, 
            	Motif_du_refus__c, 
            	Raison_du_refus__c, 
            	Quantite_livree_126x8kg__c, 
            	Quantite_livree_66x15kg__c, 
            	Quantite_livree_DemiPal15kg__c, 
            	Signature_chauffeur__c, 
            	Signature_client__c,
            	PRAXEDO__PDAUnloadingDate__c,
            	PRAXEDO__ValidationDate__c
			FROM WorkOrder
            WHERE Id =: workorderIds
        ];
        
        // Fill a map with workorder data
        for(WorkOrder oWorkOrder:lWorkOrders){
            mWorkOrders.put(oWorkOrder.Order__c, oWorkOrder);
        }
		
		// Get the orders related to those workorders
		List<Order__c> lOrdersToSync= [
            SELECT Id, 
            	gdb_shipping_date__c,
            	/*Order_Status__c,
            	gdb_shipping_status__c,
            	gdb_shipping_date__c,
            	gdb_validation_date__c,*/
            	(
                    SELECT Id,
                    gdb_shipping_status__c,
                    gdb_shipping_date__c
                    FROM Articles_dans_Commande__r
                    WHERE gdb_warehouse__r.gdb_shipping_carrier__c = 'PRAXEDO'
                )
			FROM Order__c
            WHERE Id =: mWorkOrders.keySet()
        ];
		
		// Sync fields
		for(Order__c oOrderToSync:lOrdersToSync){
			if(mWorkOrders.containsKey(oOrderToSync.Id)){
				
				oOrderToSync.PlanificationAppointmentHour__c = mWorkOrders.get(oOrderToSync.Id).PRAXEDO__PlanificationAppointmentHour__c; 
				lOrdersToUpdate.add(oOrderToSync);
				
				if(mWorkOrders.get(oOrderToSync.Id).Livraison_effectuee__c == 'on'){
					
					for(Item_in_Order__c io : oOrderToSync.Articles_dans_Commande__r){
						io.gdb_shipping_date__c = mWorkOrders.get(oOrderToSync.Id).PRAXEDO__PDAUnloadingDate__c; 
						
						if(mWorkOrders.get(oOrderToSync.Id).Statut_de_livraison__c == 'Livraison Totale'){
	            			io.gdb_shipping_status__c = 'Shipped';
						}else if(mWorkOrders.get(oOrderToSync.Id).Statut_de_livraison__c == 'Livraison Partielle'){
	            			io.gdb_shipping_status__c = 'Partially Shipped';
						}
						
						lItemsInOrderToUpdate.add(io);
					}
					
				}
			}
		}
		
		
		try {
			if(lOrdersToUpdate.size()>0) 
				update lOrdersToUpdate;
			if(lItemsInOrderToUpdate.size()>0) 
				update lItemsInOrderToUpdate;
		} catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }
		
		
		/*if(lItemsInOrderToUpdate.size()>0){
			try {
	           	update lItemsInOrderToUpdate;
			} catch(Exception e) {
	            System.debug(System.LoggingLevel.ERROR, e.getMessage());
	        }
		}*/
		
		
		
		// Sync fields
		/*for(Order__c oOrderToSync:lOrdersToSync){
			if(mWorkOrders.containsKey(oOrderToSync.Id)){
				if(mWorkOrders.get(oOrderToSync.Id).Livraison_effectuee__c == 'on'){
					oOrderToSync.Order_Status__c = '7';
					oOrderToSync.gdb_shipping_date__c = mWorkOrders.get(oOrderToSync.Id).PRAXEDO__PDAUnloadingDate__c;
					oOrderToSync.gdb_validation_date__c = mWorkOrders.get(oOrderToSync.Id).PRAXEDO__ValidationDate__c; 
					
					if(mWorkOrders.get(oOrderToSync.Id).Statut_de_livraison__c == 'Livraison Totale'){
            			oOrderToSync.gdb_shipping_status__c = 'Shipped';
					}else if(mWorkOrders.get(oOrderToSync.Id).Statut_de_livraison__c == 'Livraison Partielle'){
            			oOrderToSync.gdb_shipping_status__c = 'Partially Shipped';
					}
				}
            	
            	lOrdersToUpdate.add(oOrderToSync);
			}
		}
		
		if(lOrdersToUpdate.size()>0){
			try {
	           	update lOrdersToUpdate;
			} catch(Exception e) {
	            System.debug(System.LoggingLevel.ERROR, e.getMessage());
	        }
		}*/
	
    }
	
	
	/*
	String textAreaInput = [SELECT PRAXEDO__CustomField__c FROM WorkOrder Where Id = '0WO9E0000004XMn'].PRAXEDO__CustomField__c;
	system.debug(logginglevel.WARN, 'textAreaInput = ' + textAreaInput);
	
	//string textAreaInput = '"LIVR_EFF":"on","PQ_NON_REAL":"","RAISON_REFUS":"","AUTRE_REFUS":"","AUTRE_NON_REAL":"","STAT_LIV":"Livraison Partielle","QTE_66_15_A_LIVRER":"","QTE_LIV_66_15":"1234","QTE_126_8_A_LIVRER":"","QTE_LIV_126_8":"122","PHOTO":"","QU_SIGN_CLIENT":"Oui","SIGN_CLIENT":"","NOM_CHAUF":"V8YHKK","SIGN_CHAUF":""';
	//string jsonInput = '{"LIVR_EFF":"on","PQ_NON_REAL":"","RAISON_REFUS":"","AUTRE_REFUS":"","AUTRE_NON_REAL":"","STAT_LIV":"Livraison Partielle","QTE_66_15_A_LIVRER":"","QTE_LIV_66_15":"1234","QTE_126_8_A_LIVRER":"","QTE_LIV_126_8":"122","PHOTO":"","QU_SIGN_CLIENT":"Oui","SIGN_CLIENT":"","NOM_CHAUF":"V8YHKK","SIGN_CHAUF":""}';
	string jsonInput = '{' + textAreaInput.replace('\n', ',') + '}';
	
	
	PraxedoParams pp = (PraxedoParams)JSON.deserialize(jsonInput, PraxedoParams.class);
	system.debug(logginglevel.WARN, 'pp = ' + pp);
	system.debug(logginglevel.WARN, 'pp.LIVR_EFF = ' + pp.LIVR_EFF);
	system.debug(logginglevel.WARN, 'pp.QTE_LIV_66_15 = ' + pp.QTE_LIV_66_15);
	system.debug(logginglevel.WARN, 'pp.QTE_126_8_A_LIVRER = ' + pp.QTE_126_8_A_LIVRER);
	system.debug(logginglevel.WARN, 'pp.QTE_66_15_A_LIVRER = ' + pp.QTE_66_15_A_LIVRER);
	
	
	PraxedoParams pp2 = new PraxedoParams();
	pp2.QTE_66_15_A_LIVRER = '12';
	pp2.QTE_126_8_A_LIVRER = '3';
	
	// String serialize(Object objectToSerialize, Boolean suppressApexObjectNulls)
	string test = JSON.serialize(pp2, True);
	system.debug(logginglevel.WARN, 'test = ' + test);
	string test2 = test.replace('{', '').replace('}', '').replace(',', '\n');
	system.debug(logginglevel.WARN, 'test2 = ' + test2);
	
	
	
	// if pp.LIVR_EFF == 'on' then update order as delivered with a delivery date (set status so that the order status will be exported to SAP)
	
	
	public class PraxedoParams {
		public String LIVR_EFF;
		public String PQ_NON_REAL;
		public String RAISON_REFUS;
		public String AUTRE_REFUS;
		public String AUTRE_NON_REAL;
		public String STAT_LIV;
		public String QTE_66_15_A_LIVRER;
		public String QTE_LIV_66_15;
		public String QTE_126_8_A_LIVRER;
		public String QTE_LIV_126_8;
		public String PHOTO;
		public String QU_SIGN_CLIENT;
		public String SIGN_CLIENT;
		public String NOM_CHAUF;
		public String SIGN_CHAUF;
	}
	*/
}