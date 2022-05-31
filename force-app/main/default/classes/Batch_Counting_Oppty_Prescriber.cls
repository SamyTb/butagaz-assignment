global class Batch_Counting_Oppty_Prescriber implements Database.Batchable<sObject> {
    
    // Implement the interface to update the couting Opportunities for Account
    global String query; 
    global  Batch_Counting_Oppty_Prescriber (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
     global void execute(Database.BatchableContext BC, List<Opportunity> lOpptys) {
        // AP_Opportunity.mAJComptePrescripteurNonFuture(lOpptys);
     }
    global void finish(Database.BatchableContext BC) {
    }
}