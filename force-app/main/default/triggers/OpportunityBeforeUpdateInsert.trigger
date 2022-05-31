trigger OpportunityBeforeUpdateInsert on Opportunity (before insert, before update) {
    public static boolean isTest = false;
    List<Opportunity> lOpportunities = Trigger.new;
    
    // This SOQL query has been moved to lower SOQL queries used
    map<Id,string> mOptyToContractScale = new map<Id,string>();
    List<Opportunity> fetchedOpportunity = [SELECT Contrat__r.Scale_c__c FROM Opportunity WHERE Id = :lOpportunities];
    for(Opportunity oOpty:fetchedOpportunity){
        mOptyToContractScale.put(oOpty.Id, oOpty.Contrat__r.Scale_c__c);
    }
    
    
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Opportunity.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        AP_Opportunity.validateOpportunity(lOpportunities);
        // ajouté par GGO le 12/09/14
        AP_Assignment_Main_01.assignOpties(lOpportunities);
        AP_Opportunity.siretOuEnCoursDImmatUpdate(lOpportunities, isTest);
        AP_Opportunity.emailPasDEmailUpdate(lOpportunities, isTest);
        
        AP_Opportunity.checkExistingContractScale(lOpportunities, mOptyToContractScale);
        AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO(lOpportunities, mOptyToContractScale);
        AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM(lOpportunities, mOptyToContractScale);
        //AP_Opportunity.checkOptyAccountBailleur(lOpportunities);
        // ajouté par MLC 07/09/16
        AP_Opportunity.updateReferenceClientSAP (lOpportunities);
        if(!System.isFuture() && !System.isBatch()) TLV_LeadMgr.createLeadElectricityFromOpty (trigger.newMap.keySet());
        System.Debug('##>>> Opportunity.BeforeUpdate : END <<<');
        
    }
    
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Opportunity.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        AP_Opportunity.validateOpportunity(lOpportunities);
        // ajouté par GGO le 12/09/14
        AP_Assignment_Main_01.assignOpties(lOpportunities);
        //AP_Opportunity.siretOuEnCoursDImmatInsert(lOpportunities, isTest);
        AP_Opportunity.emailPasDEmailInsert(lOpportunities, isTest);
        
        AP_Opportunity.checkExistingContractScale(lOpportunities, mOptyToContractScale);  
        AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO(lOpportunities, mOptyToContractScale);
        AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM(lOpportunities, mOptyToContractScale);
        //AP_Opportunity.checkOptyAccountBailleur(lOpportunities);
        // ajouté par MLC 07/09/16
        AP_Opportunity.updateReferenceClientSAP (lOpportunities);
        System.Debug('##>>> Opportunity.BeforeInsert : END <<<');
       
    }
}