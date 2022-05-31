trigger LeadAfterUpdate on Lead (after update) {
    
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Lead.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
    
        if (PAD.canTrigger('Lead.CopyMandataireOnConversion')) {
            VFC_Copy_Mandataire_From_Lead.CopyMandataireOnConversion(trigger.new, trigger.oldMap);
        } else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS CopyMandataireOnConversion <<< run by ' + UserInfo.getName());
        }
        
        // Erwan 20170221  Moved from before update to after update when method changed to @future
        if (PAD.canTrigger('Lead.assignLeads')) {
            // Erwan 20172201
            //AP_Assignment_Main_01.assignLeads(lLeads);
            
            if(!System.isFuture() && !System.isBatch()){
                List<Id> lLeads_assignLeads = new List<Id>();
                
                for (Lead oLead : Trigger.new){
                    //if(oLead.CT_BypassInsertTrigger__c!= '1') {
                        lLeads_assignLeads.add(oLead.Id);
                    //}
                }
                
                if (lLeads_assignLeads.size() > 0) 
                    AP_Assignment_Main_01.assignLeads(lLeads_assignLeads); 
            }
        } else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS assignLeads <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Lead.callComparatorWS')) {
            if(!System.isFuture() && !System.isBatch()){
                
                for( Id leadId : Trigger.newMap.keySet() ){
                    if ( Trigger.newMap.get(leadId).ExternalID__c != null ) {
                        if ( Trigger.newMap.get(leadId).ExternalID__c.startsWithIgnoreCase('CMP') ) {
                            if( Trigger.oldMap.get(leadId).Status != Trigger.newMap.get(leadId).Status ){
                                Comparator_CalloutMgr.callComparatorWS(leadId, Trigger.newMap.get(leadId).ExternalID__c, Trigger.newMap.get(leadId).Status);
                            }
                        }
                    }
                }
            }
        } else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS callComparatorWS <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Lead.convertLeads')) {
            if (!System.isFuture() && !System.isBatch()) {
                List<Id> lLeadIds = new List<Id>();
                
                for (Lead oLead : Trigger.new) {
                	if (oLead.Status.equals('To Convert')) {
						lLeadIds.add(oLead.Id);
                	}
                }
                
                if (lLeadIds.size() > 0) 
                    AP04LeadAutoConvert.convertLeads(lLeadIds); 
            }
        } else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS convertLeads <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('Lead.createProjectFromLead')) {
            if (!System.isFuture() && !System.isBatch()) {
                List<Id> lLeadIds = new List<Id>();
                
                for (Lead oLead : Trigger.new) {
                	if (oLead.IsConverted) {
						lLeadIds.add(oLead.Id);
                	}
                }
                
                if (lLeadIds.size() > 0) 
                    ProjectMgr.createProjectFromLead(lLeadIds); 
            }
        } else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS createProjectFromLead <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('Lead.callDoleadCustomerConversionsWS')) {
            if(!System.isFuture() && !System.isBatch()){
                for( Id leadId : Trigger.newMap.keySet() ){
                        if ( Trigger.newMap.get(leadId).LeadSource == 'Dolead' && Trigger.newMap.get(leadId).ExternalID__c != '' ) {
                            if( Trigger.oldMap.get(leadId).Status != Trigger.newMap.get(leadId).Status || Trigger.oldMap.get(leadId).First_Call_DateTime__c != Trigger.newMap.get(leadId).First_Call_DateTime__c ){
                                Dolead_CalloutMgr.callDoleadCustomerConversionsWS(leadId, Trigger.newMap.get(leadId).ExternalID__c, Trigger.newMap.get(leadId).Status);
                            }
                        }
                }
            }
        } 
        else {
            System.Debug('##>>> Lead.AfterUpdate : BYPASS callDoleadCustomerConversionsWS <<< run by ' + UserInfo.getName());   
        }
        
        
        System.Debug('##>>> Lead.AfterUpdate : END <<<');
    } else {
        System.Debug('##>>> Lead.AfterUpdate : FALSE TRIGGER <<<');
    }
    
}