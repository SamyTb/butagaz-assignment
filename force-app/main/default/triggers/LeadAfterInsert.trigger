trigger LeadAfterInsert on Lead (after insert) {
    
    // Erwan 20170221
    if (Trigger.IsAfter && Trigger.IsInsert) {
        
        List<Lead> lLeads = Trigger.new;
        
        if(!System.isFuture() && !System.isBatch()){
            if (PAD.canTrigger('Lead.assignLeads')) {
                List<Id> lLeads_assignLeads = new List<Id>();
                
                for (Lead oLead : Trigger.new){
                    if(oLead.CT_BypassInsertTrigger__c!= '1') {
                        lLeads_assignLeads.add(oLead.Id);
                    }
                }
                
                if (lLeads_assignLeads.size() > 0) 
                    AP_Assignment_Main_01.assignLeads(lLeads_assignLeads ); 
            
            } else {
                System.Debug('##>>> Lead.AfterInsert : BYPASS assignLeads <<< run by ' + UserInfo.getName());
            }
            
            if (PAD.canTrigger('Lead.enableLeadAutoResponse')) {
                set<Id> leadIdsSet = new set<Id>();
                for(Lead oLead:lLeads){
                    if(oLead.Channel__c == 'Internet' && oLead.LeadSource != 'Dolead' && oLead.LeadSource != 'Selectra' && oLead.LeadSource != 'Solaire') leadIdsSet.add(oLead.Id);
                }
                
                AP04Lead.enableLeadAutoResponse(leadIdsSet);
            } else {
                System.Debug('##>>> Case.afterInsert : BYPASS Lead.enableLeadAutoResponse <<< run by ' + UserInfo.getName());
            }
        }
    }
    
}