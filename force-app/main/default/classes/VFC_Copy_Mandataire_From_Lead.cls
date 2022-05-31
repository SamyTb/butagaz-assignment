public class VFC_Copy_Mandataire_From_Lead {
  
  public static void CopyMandataireOnConversion (List<Lead> newLeads, Map<Id, Lead> mOldLeads){
    
    //List<Lead> newLeads = trigger.new;
    //Map<Id, Lead> mOldLeads = trigger.oldMap;
    Lead oldLead;
    
    Set<Id> convertedAccountIds = new Set<Id>();
    Set<Id> convertedOptyIds = new Set<Id>();
    
    
    // We only want to trigger this process on prescriber leads
    /*List<RecordType> lrecordtypes = [select Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Prescriber_Lead' LIMIT 1 ];  
    System.debug('###ELC lrecordtypes[0].Id =' + lrecordtypes[0].Id);*/
    
    // Get the accounts associated to the updated leads
    for (Lead l : newLeads) {
      
      if (l.convertedAccountId != null) {
        convertedAccountIds.add(l.convertedAccountId);
      }
      if (l.convertedOpportunityId != null) {
        convertedOptyIds.add(l.convertedOpportunityId);
      }
      
    }
    
    // Retrieve records created at conversion
    List<Account> accounts =
      [SELECT Id
      FROM Account
      WHERE Id IN : convertedAccountIds];
       
    Map<Id, Account> mAccounts = new Map<Id, Account>(accounts);
    
    List<Opportunity> opties =
      [SELECT Id, Name, DO_Mandataire__c 
      FROM Opportunity
      WHERE Id IN : convertedOptyIds];
       
    Map<Id, Opportunity> mOpties = new Map<Id, Opportunity>(opties);
    
    
    List<Account> updateAccounts = new List<Account>();
    List<Opportunity> updateOpties = new List<Opportunity>();
    
    // Loop on lead records affected by the trigger
    for (Lead newLead : newLeads) {
      
      oldLead = mOldLeads.get(newLead.Id);
      
      // If Lead is being converted and is a Prescriber Lead
      if ( !oldLead.IsConverted && newLead.isConverted /*&& newLead.RecordTypeId == lrecordtypes[0].Id*/ ) {
        
        Account account = mAccounts.get(newLead.convertedAccountId);
        Opportunity opty = mOpties.get(newLead.convertedOpportunityId);
        
        // Update fields
        System.debug('###ELC newLead.FT_ProjectMandataireId__c =' + newLead.FT_ProjectMandataireId__c);
        account.Mandataire__c = newLead.FT_ProjectMandataireId__c;
        updateAccounts.add(account);
        
        System.debug('###ELC opty =' + opty);
        //System.debug('###ELC opty.DO_Mandataire__c =' + opty.DO_Mandataire__c);
        if (opty != null && opty.DO_Mandataire__c != null){
            opty.DO_Mandataire__c = newLead.FT_ProjectMandataireId__c;
            updateOpties.add(opty);
        }
        
      }
    }
    
    // Update objects with the lists
    if (updateAccounts.size() > 0) {
      update updateAccounts;
    }
    if (updateOpties.size() > 0) {
      update updateOpties;
     }  
    
  }
  
}