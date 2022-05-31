public class AP_PTLCommercialResults {

    private static boolean alreadyUpdatedPTLComResult = false;
    
    public static void putCommercialObjective(list<PTL_Commercial_Results__c> lPTLComResults){
        
        List<String> lPTLGEBComResultsUniqueId = new list<String>();
        map<String, Objectif_Article_YearMonth__c> mObjUniqueIdToObjective = new map<String, Objectif_Article_YearMonth__c>();      
        List<PTL_Commercial_Results__c> lPTLComResultsToUpdate = new List<PTL_Commercial_Results__c>();
        
        System.debug('[AP_PTLCommercialResults.putCommercialObjective] lPTLComResults Counts: ' + lPTLComResults.size());   
		
        List<PTL_Commercial_Results__c> lPTLComResultChanged = [Select Id,Unique_Id__c ,Activity_Domain__r.externalID__c, Objectif_Article_Anne_Mois__c from PTL_Commercial_Results__c where id in: lPTLComResults];
        for(PTL_Commercial_Results__c oPTLComResult:lPTLComResultChanged){
        	System.debug('[AP_PTLCommercialResults.putCommercialObjective] oPTLComResult.Unique_Id__c ->: ' +oPTLComResult.Unique_Id__c);
        	System.debug('[AP_PTLCommercialResults.putCommercialObjective] oPTLComResult.Activity_Domain__r.externalID__c ->: ' +oPTLComResult.Activity_Domain__r.externalID__c);        	           		
        	if((oPTLComResult.Activity_Domain__r.externalID__c==41) && (oPTLComResult.Unique_Id__c!=null)){
        		lPTLGEBComResultsUniqueId.add(oPTLComResult.Unique_Id__c);
        	}              
        }
       	
       	System.debug('[AP_PTLCommercialResults.putCommercialObjective] lPTLGEBComResultsUniqueId Counts: ' + lPTLGEBComResultsUniqueId.size());   
        if(lPTLGEBComResultsUniqueId.size()>0){
	        list<Objectif_Article_YearMonth__c> lGEBCommObjectives=[Select id,Unique_Id__c  from Objectif_Article_YearMonth__c Where Unique_Id__c in :lPTLGEBComResultsUniqueId];
	        System.debug('[AP_PTLCommercialResults.putCommercialObjective] lGEBCommObjectives Counts: ' + lGEBCommObjectives.size());           
	        for(Objectif_Article_YearMonth__c oObjective:lGEBCommObjectives){
	            mObjUniqueIdToObjective.put(oObjective.Unique_Id__c,oObjective);                    
	        }
        }    
        System.debug('[AP_PTLCommercialResults.putCommercialObjective] mObjUniqueIdToObjective Counts: ' + mObjUniqueIdToObjective.size());   
        
        for(PTL_Commercial_Results__c oPTLComResult:lPTLComResultChanged){
            if(mObjUniqueIdToObjective.containskey(oPTLComResult.Unique_Id__c)){
                lPTLComResultsToUpdate.add(new PTL_Commercial_Results__c(
                          Id=oPTLComResult.id,
                          Objectif_Article_Anne_Mois__c=mObjUniqueIdToObjective.get(oPTLComResult.Unique_Id__c).Id
                        )
                      );
            }            
        }
    
        // Update database      
        if(lPTLComResultsToUpdate.size()>0){
            try{
                update lPTLComResultsToUpdate;
            } 
            catch(DmlException e){
                System.debug('Error: '+ e);
            }           
        }      
    }
        
    public static boolean hasAlreadyUpdatedPTLComResult() {
        return alreadyUpdatedPTLComResult;
    }
        
    public static void setAlreadyUpdatedPTLComResult(boolean b) {
        alreadyUpdatedPTLComResult = b;
    }   
    
}