global class Batch_Updating_PTL_ContactMKT_ELC implements Database.Batchable<sObject> {
    
    String value;
        
    global Batch_Updating_PTL_ContactMKT_ELC(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Account_DO__c 
									FROM PTL__c 
									WHERE Activity_Domain__r.ExternalID__c=41]);
									//AND Contact_Marketing__c = null]);
    }
    
    global void execute(Database.BatchableContext BC, List<PTL__c> ptl){
        AP_PTL_01.managePTLMKTContactELC(ptl);
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}