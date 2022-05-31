trigger LeadBeforeInsert on Lead (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Lead.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Lead> lLeads = Trigger.new;
      
        if (PAD.canTrigger('Lead.MatchAdress')) {
            AP04Lead.MatchAdress(Trigger.new);
        } else {
            System.Debug('##>>> Lead.MatchAdress : BYPASS <<< run by ' + UserInfo.getName());
        }
         
        if (PAD.canTrigger('Lead.LeadSameAddressBeforeInsert')) {
            AP_CopyAddressFields_01.copyAddressFields(Trigger.new);
        } else {
            System.Debug('##>>> Lead.LeadSameAddressBeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Lead.fillActivityDomainId')) {
            List<Lead> lLeads_W2LActivityDomain = new List<Lead>();
            
            for (Lead oLead : Trigger.new){
                if(oLead.W2L_Activity_Domain__c != null) {
                    lLeads_W2LActivityDomain.add(oLead);
                }
            }
             
            if (lLeads_W2LActivityDomain.size() > 0) 
                AP04Lead.fillActivityDomainId(lLeads_W2LActivityDomain);   
        }
        
        if(PAD.canTrigger('Lead.fillNACEId')){
            List<Lead> lLeads_W2LNACECode = new List<Lead>();
            
            for(Lead oLead : Trigger.new){
                if(oLead.W2L_NACE_Code__c != null){
                    lLeads_W2LNACECode.add(oLead);
                }
            }
             
            if(lLeads_W2LNACECode.size() > 0) 
                AP04Lead.fillNACEId(lLeads_W2LNACECode);   
        }
		
		// Erwan 20172201
        /*if (PAD.canTrigger('Lead.assignLeads')) {
            List<Lead> lLeads_assignLeads = new List<Lead>();
            
            for (Lead oLead : Trigger.new){
                if(oLead.CT_BypassInsertTrigger__c!= '1') {
                    lLeads_assignLeads .add(oLead);
                }
            }
            
            if (lLeads_assignLeads .size() > 0) 
                AP_Assignment_Main_01.assignLeads(lLeads_assignLeads ); 
        
        } else {
            System.Debug('##>>> Lead.BeforeInsert : BYPASS assignLeads <<< run by ' + UserInfo.getName());
        }*/
        
        
        if (PAD.canTrigger('Lead.fill_T_Predecessor')) {
            AP04Lead.fillTPredecessor(Trigger.new);
        } else {
            System.Debug('##>>> Lead.MatchAdress : BYPASS <<< run by ' + UserInfo.getName());
        }        
       
        System.Debug('##>>> Lead.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> Lead.BeforeInsert : FALSE TRIGGER <<<');
    }
}