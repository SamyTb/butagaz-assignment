trigger LeadBeforeUpdate on Lead (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> Lead.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Lead> lLeads = Trigger.new;
		
        if (PAD.canTrigger('Lead.LeadSameAddressBeforeInsert')) {
            AP_CopyAddressFields_01.copyAddressFields(Trigger.new);
        } else {
            System.Debug('##>>> Lead.LeadSameAddressBeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
		
		// Erwan 20172201
        /*if (PAD.canTrigger('Lead.assignLeads')) {
            // Erwan 20172201
            //AP_Assignment_Main_01.assignLeads(lLeads);
            
            if (!System.isFuture()) {
	            List<Id> lLeads_assignLeads = new List<Id>();
	            
	            for (Lead oLead : Trigger.new){
	                if(oLead.CT_BypassInsertTrigger__c!= '1') {
	                    lLeads_assignLeads.add(oLead.Id);
	                }
	            }
	            
	            if (lLeads_assignLeads.size() > 0) 
	                AP_Assignment_Main_01.assignLeads(lLeads_assignLeads); 
            }
        } else {
            System.Debug('##>>> Lead.BeforeUpdate : BYPASS assignLeads <<< run by ' + UserInfo.getName());
        }*/
      
        System.Debug('##>>> Lead.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> Lead.BeforeUpdate : FALSE TRIGGER <<<');
    }
}