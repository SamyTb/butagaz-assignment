global class Batch_Updating_PTL_ContactMKT implements Database.Batchable<sObject> {
    
    String value;
        
    global Batch_Updating_PTL_ContactMKT(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select p.Id, 
        										p.Contact_Marketing__c
        								From PTL__c p 
        								where p.T_ConMKT_Name_Equals_ConMKT_AccountDO__c = FALSE 
        									and p.T_ContactMKT_Name__c <> 'Contact Marketing ERREUR' 
        									and p.T_ContactMKT_Name__c like 'Contact Marketing%']);
    }
    
    global void execute(Database.BatchableContext BC, List<PTL__c> ptl){
        for(Sobject o : ptl){
        	o.put('Contact_Marketing__c', '');
        }      
        update ptl;
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}