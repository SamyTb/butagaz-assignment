global class Batch_Updating_PickLists implements Database.Batchable<sObject> {
    
    String value;
        
    global Batch_Updating_PickLists(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select PTL_MEP_MouvementMemeAdresseButagaz__c, 
                                                PTL_MEP_Cles_en_Main__c, 
                                                PTL_MEP_Precheck_Tank_Connection__c, 
                                                PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c, 
                                                PTL_MEP_Cles_en_Main_Y_N__c, 
                                                PTL_MEP_Precheck_Tank_Connection_Y_N__c
                                        from Opportunity_PTL__c
                                        where (PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c = '' or PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c = null)
                                        and (PTL_MEP_Cles_en_Main_Y_N__c = '' or PTL_MEP_Cles_en_Main_Y_N__c = null)
                                        and (PTL_MEP_Precheck_Tank_Connection_Y_N__c = '' or PTL_MEP_Precheck_Tank_Connection_Y_N__c = null)]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity_PTL__c> optl){
        for(Sobject o : optl){
            if(Boolean.valueOf(o.get('PTL_MEP_MouvementMemeAdresseButagaz__c'))) {
                value = 'Oui';
            } else {
                value = 'Non';
            }
            o.put('PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c',value);
            
            
            if(Boolean.valueOf(o.get('PTL_MEP_Cles_en_Main__c'))) {
                value = 'Oui';
            } else {
                value = 'Non';
            }
            o.put('PTL_MEP_Cles_en_Main_Y_N__c',value);
            
            
            if(Boolean.valueOf(o.get('PTL_MEP_Precheck_Tank_Connection__c'))) {
                value = 'Oui';
            } else {
                value = 'Non';
            }
            o.put('PTL_MEP_Precheck_Tank_Connection_Y_N__c',value);
        }      
        update optl;
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}