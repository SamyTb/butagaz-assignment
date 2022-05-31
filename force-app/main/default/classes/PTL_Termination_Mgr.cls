public class PTL_Termination_Mgr {
	
	
	/*
		Used to update Tanks_Count__c, Last_Tank_Removal_Date__c, Open_Contracts_Count__c fields on PTL__c object
		Executed by Batch_PTL_Termination Apex batch
	*/
	public static void managePtlTerminationIndicators(List<PTL__c> ptlRecords){
        
        List<PTL__c> ptlToUpdate = new List<PTL__c>();
		
		
		// Get last tank removal date. This indicator will be used to calculate when the PTL has been terminated.
		map<Id, Date> mapPtlIdToMaxRemovalDate = new map<Id, Date>();
		for(AggregateResult aggr : [select PTL__c, MAX(Actual_Delivery_Date__c) maxDate 
        					  			from Order__c 
        					  			where Order_Type__c = 'ZRTT' 
        					  			and PTL__c in :ptlRecords 
        					  			group by PTL__c]){
			
		    mapPtlIdToMaxRemovalDate.put( (Id) aggr.get('PTL__c'), (date) aggr.get('maxDate') );
		}
		System.debug('### mapPtlIdToMaxRemovalDate : ' + mapPtlIdToMaxRemovalDate);
		
		// Only including Article External Ids starting with C which means the tank is not out of service
		List<PTL__c> lPTL = [ SELECT Id, 
								(SELECT Id FROM Equipement__r WHERE Type__c = 'C' AND Article__r.ExternalID__c LIKE 'C%'),
								(SELECT Id FROM Contracts__r WHERE Contract_End_Flag_Filter__c = 1)
								FROM PTL__c WHERE Activity_Domain__r.ExternalID__c = 42 AND Id IN :ptlRecords ];
		
		for(PTL__c oPTL : lPTL){
			PTL__c ptl = new PTL__c(Id = oPTL.Id);
			ptl.Tanks_Count__c = oPTL.Equipement__r.size();
			ptl.Open_Contracts_Count__c = oPTL.Contracts__r.size();
			if(mapPtlIdToMaxRemovalDate.containsKey(oPTL.Id)){
				System.debug('### mapPtlIdToMaxRemovalDate.get(oPTL.Id) : ' + mapPtlIdToMaxRemovalDate.get(oPTL.Id));
				ptl.Last_Tank_Removal_Date__c = mapPtlIdToMaxRemovalDate.get(oPTL.Id);
			}
			
			ptlToUpdate.add(ptl);
		}
		
		if(ptlToUpdate.size() > 0) update ptlToUpdate;
        
    }
	
	
	
	
	/*
	//
	//	Used to update Tanks_Count__c field on PTL__c object
	//
	@future 
	public static void updateTankCountOnPTL(Set<Id> ptlRecordIds){
        
        List<PTL__c> ptlToUpdate = new List<PTL__c>();
		
		
		// Only including Article External Ids starting with C which means the tank is not out of service
		List<PTL__c> lPTL = [ SELECT Id, 
								(SELECT Id FROM Equipement__r WHERE Type__c = 'C' AND Article__r.ExternalID__c LIKE 'C%')
								FROM PTL__c WHERE Activity_Domain__r.ExternalID__c = 42 AND Id IN :ptlRecordIds ];
		
		for(PTL__c oPTL : lPTL){
			PTL__c ptl = new PTL__c(Id = oPTL.Id);
			ptl.Tanks_Count__c = oPTL.Equipement__r.size();
			
			ptlToUpdate.add(ptl);
		}
		if(ptlToUpdate.size() > 0) update ptlToUpdate;
        
    }
    
    //
	//	Used to update Last_Tank_Removal_Date__c field on PTL__c object
	//
	@future 
	public static void updateLastTankRemovalDateOnPTL(Set<Id> ptlRecordIds){
        
        //List<PTL__c> ptlToUpdate = new List<PTL__c>();
		map<Id,PTL__c> updatePTLMap = new map<Id,PTL__c>();
		
		// Get last tank removal date. This indicator will be used to calculate when the PTL has been terminated.
        List<AggregateResult> AggregateResultList = [ SELECT PTL__c, MAX(Actual_Delivery_Date__c) maxDate 
                                                        FROM Order__c 
                                                        WHERE Order_Type__c = 'ZRTT'
                                                        AND PTL__c IN :ptlRecordIds
                                                        GROUP BY PTL__c ];
        
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult aggr:AggregateResultList){             
                PTL__c ptl = new PTL__c();
                ptl.Id = (id)aggr.get('PTL__c');
                ptl.Last_Tank_Removal_Date__c = (date)aggr.get('maxDate');
                
                updatePTLMap.put(ptl.Id, ptl); 
            } 
        }
		if(updatePTLMap.size() > 0) update updatePTLMap.values();
        
    }
    
    //
	//	Used to update Open_Contracts_Count__c field on PTL__c object
	//
	@future 
	public static void updateOpenContractsCountOnPTL(Set<Id> ptlRecordIds){
        
        List<PTL__c> ptlToUpdate = new List<PTL__c>();
		
		
		// Only including active contracts
		List<PTL__c> lPTL = [ SELECT Id, 
								(SELECT Id FROM Contracts__r WHERE Contract_End_Flag_Filter__c = 1) 
								FROM PTL__c WHERE Activity_Domain__r.ExternalID__c = 42 AND Id IN :ptlRecordIds ];
		
		for(PTL__c oPTL : lPTL){
			PTL__c ptl = new PTL__c(Id = oPTL.Id);
			ptl.Open_Contracts_Count__c = oPTL.Contracts__r.size();
			
			ptlToUpdate.add(ptl);
		}
		if(ptlToUpdate.size() > 0) update ptlToUpdate;
        
    }
	*/
}