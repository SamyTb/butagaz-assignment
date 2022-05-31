public class AP_Assignment_Main_01 {

    public static Object safeGet(SObject oSObj, String fieldName){
        // Gives you a field on an SObject, and returns null if the field doesn't exist.
        try {
            return oSObj.get(fieldName);
        } catch (System.SObjectException e){
            return null;
        }
    }

    public static void assignOpties(List<Opportunity> lOpties){
        System.debug('START method AP_Assignment_Main_01.assignOpties');
        System.debug('[AP_Assignment_Main_01.assignOpties] Collecting OwnerIds.');
        Map<Opportunity, Id> oldOwnerIds = new Map<Opportunity, Id>();
        for (Opportunity oOpty : lOpties){
            oldOwnerIds.put(oOpty, oOpty.OwnerId);
        }

        System.debug('[AP_Assignment_Main_01.assignOpties] Assigning.');
        
        // Erwan 20170222
        //AP_Assignment_Main_01.assignLeads(lOpties);
        AP_Assignment_Main_01.assignOpportunities(lOpties);

        // Opportunities may not be assigned to a group.
        System.debug('[AP_Assignment_Main_01.assignOpties] Validating that Owner is an user.');
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult groupDescribe = globalDescribe.get('group').getDescribe();
        String groupPrefix = groupDescribe.getKeyPrefix();

        System.debug('[AP_Assignment_Main_01.assignOpties] Collecting Group names.');
        Set<Id> sOwnerIds = new Set<Id>();
        for (Opportunity oOpty : lOpties){ sOwnerIds.add(oOpty.OwnerId); }
        Map<Id, String> mIdToGroupName = new Map<Id, String>();
        for (Group oGroup : [SELECT Id, Name FROM Group WHERE Id IN :sOwnerIds]){
            mIdToGroupName.put(oGroup.Id, oGroup.Name);
        }

        
        // Loop variable
        String ownerString;

        for (Opportunity oOpty : lOpties){ // Same objects, they are mutables!
            ownerString = (String) oOpty.OwnerId;
            if (ownerString.startsWith(groupPrefix)){
                oOpty.addError(System.Label.Error_CouldNotAssign + mIdToGroupName.get(oOpty.OwnerId)); 
                oOpty.ownerId = oldOwnerIds.get(oOpty); // Rollback the owner or we'd get the wrong ID error first.
            }
        }
        
        System.debug('END method AP_Assignment_Main_01.assignOpties');
    
    }


    /*public static void assignLeads(List<SObject> lSObjs) {
        System.Debug('START method AP_Assignment_Main_01.assignLeads');

        // Let's find all the Activity Domains, Market Types and Cantons we're interested in
        Set<Id> sRelevantADs     = new Set<Id>{null};
        Set<String> sRelevantMTs = new Set<String>{null};
        Set<Id> sRelevantCAs     = new Set<Id>{null};
        Set<String> sRelevantPTs = new Set<String>{null};

        // TODO: validate that the fields EXIST
        for (SObject oSObj : lSObjs){
            sRelevantADs.add((Id) safeGet(oSObj, 'T_Assignment_ActivityDomainId__c'));
            sRelevantMTs.add((String) safeGet(oSObj, 'T_Assignment_MarketType__c'));
            sRelevantCAs.add((Id) safeGet(oSObj, 'T_Assignment_CantonId__c'));
            sRelevantPTs.add((String) safeGet(oSObj, 'T_Assignment_ProjectType__c'));
        }

        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant ADs are:' + sRelevantADs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant MTs are:' + sRelevantMTs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant CAs are:' + sRelevantCAs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant PTs are:' + sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignLeads] Loading Assignment Filters.');
        AP_Assignment_Utilities_01.BaseContext baseContext = AP_Assignment_Utilities_01.buildContext(sRelevantADs, sRelevantMTs, sRelevantCAs, sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignLeads] ADToReps: ' + String.valueOf(baseContext.ActivityDomainsToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] MarketTypesToReps: ' + String.valueOf(baseContext.MarketTypesToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] CantonsToReps: ' + String.valueOf(baseContext.CantonsToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] ProjectTypesToReps: ' + String.valueOf(baseContext.ProjectTypesToReps));

        System.Debug('[AP_Assignment_Main_01.assignLeads] Processing leads');
        Set<Assignment_Filter__c> currentReps; // Loop variable

        for (SObject oSObj : lSObjs){
            if (Integer.valueOf(safeGet(oSObj, 'T_TriggerLeadAssign__c')) == 1){
                // 1 if the lead is to be assigned. 
                // This is formula that says: Assign__c && !Prescriber__c && !Gec_Direct__c
                System.Debug('[AP_Assignment_Main_01.assignLeads] Processing lead with ID ' + String.valueOf(oSObj.Id));

                // This is the LeadContext for this specific Lead.
                AP_Assignment_Utilities_01.LeadContext context = baseContext.getLeadContext(
                    (Id) safeGet(oSObj, 'T_Assignment_ActivityDomainId__c'),
                    (String) safeGet(oSObj, 'T_Assignment_MarketType__c'),
                    (Id) safeGet(oSObj, 'T_Assignment_CantonId__c'),
                    (String) safeGet(oSObj, 'T_Assignment_ProjectType__c')
                );

                // Now, we have ALL the reps that have a chance to handle the lead. (But some will NOT.).
                // All we have left to do is to find the best one.
                //
                // We want one that:
                //  + Works for this Canton
                //  + Works for this MT
                //  + Works tor this AD
                //  + Works for this PT
                //
                // We have an order of resolution, at each level we will prefer having someone working on that
                // PT if possible.
                //
                // The rule is: 
                //  + AD / MT / CA (+PT)
                //  + MT / CA (+ All AD) (+PT)
                //  + AD / CA (+ All MT) (+PT)
                //  + CA (+ All AD + All MT) (+PT)
                //  + AD / MT (+ All Cantons) (+PT)
                //  + MT (+ All AD + All Cantons) ? (+PT)
                //  + AD (+ All MT + All Cantons) ?  (+PT)
                //  + ? (All AD All MT All Canton) (+PT)

                List<AP_Assignment_Utilities_01.SearchCriteria> lCriteria = new List<AP_Assignment_Utilities_01.SearchCriteria> {
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, true),   // AD MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, false),   // AD MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, true),   // MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, false),   // MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, true),   // AD CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, false),   // AD CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, true),   // CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, false),   // CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, true),  // AD MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, false),  // AD MT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, true),  // MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, false),  // MT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, true),  // AD PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, false),  // AD
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, true),   // ANY1 PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, false)   // ANY1
                };

                currentReps = new Set<Assignment_Filter__c>();

                System.debug('Searching for Rep in context ' + context);
                AP_Assignment_Utilities_01.SearchCriteria currentCriteria;
                try {
                    while (!(currentReps.size()>0)){
                        currentCriteria = lCriteria.remove(0);
                        System.debug('Searching with criteria: ' + currentCriteria);
                        currentReps = AP_Assignment_Utilities_01.findRep(context, currentCriteria); // Let's take the first criterion on the list.
                        System.debug('Found: ' + currentReps);
                    }
                } catch (System.ListException e){
                    System.debug('Finished list - found no rep.');
                    // We reached the end of the list and still found no solution: that's an error.
                }

                // We have a more stringent check here, we want to know if there's a config issue
                if (currentReps.size() == 1){ 
                    // We have a rep!
                    // So... this is clumsy, but can we do it another way?
                    for(Assignment_Filter__c oAF : currentReps){
                        // It's "repId", but it could actually be a Queue's ID.
                        System.Debug('[AP_Assignment_Main_01.assignLeads] Lead assigned to Rep with ID: ' + String.valueOf(oAF.TargetId__c));
                        oSObj.put('OwnerId', (Id) oAF.TargetId__c);
                        oSObj.put('Assign__c', false); // Once assigned, always un-flag the Lead.
                     
                    }
                } else {
                    if (currentReps.size() > 1){
                        oSObj.addError(System.Label.Error_MultipleRepsFound);
                    } else {
                        oSObj.addError(System.Label.Error_NoRepFound);
                    }
                }
            } else {
                System.debug('[AP_Assignment_Main_01.assignLeads] Trigger should not run for this Lead.');
            }
        }

        System.Debug('END method AP_Assignment_Main_01.assignLeads'); 
    }*/
    
    // Erwan 20170222
    public static void assignOpportunities(List<SObject> lSObjs) {
        System.Debug('START method AP_Assignment_Main_01.assignOpportunities');

        // Let's find all the Activity Domains, Market Types and Cantons we're interested in
        Set<Id> sRelevantADs     = new Set<Id>{null};
        Set<String> sRelevantMTs = new Set<String>{null};
        Set<Id> sRelevantCAs     = new Set<Id>{null};
        Set<String> sRelevantPTs = new Set<String>{null};

        // TODO: validate that the fields EXIST
        for (SObject oSObj : lSObjs){
            sRelevantADs.add((Id) safeGet(oSObj, 'T_Assignment_ActivityDomainId__c'));
            sRelevantMTs.add((String) safeGet(oSObj, 'T_Assignment_MarketType__c'));
            sRelevantCAs.add((Id) safeGet(oSObj, 'T_Assignment_CantonId__c'));
            sRelevantPTs.add((String) safeGet(oSObj, 'T_Assignment_ProjectType__c'));
        }

        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Relevant ADs are:' + sRelevantADs);
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Relevant MTs are:' + sRelevantMTs);
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Relevant CAs are:' + sRelevantCAs);
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Relevant PTs are:' + sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Loading Assignment Filters.');
        AP_Assignment_Utilities_01.BaseContext baseContext = AP_Assignment_Utilities_01.buildContext(sRelevantADs, sRelevantMTs, sRelevantCAs, sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignOpportunities] ADToReps: ' + String.valueOf(baseContext.ActivityDomainsToReps));
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] MarketTypesToReps: ' + String.valueOf(baseContext.MarketTypesToReps));
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] CantonsToReps: ' + String.valueOf(baseContext.CantonsToReps));
        System.Debug('[AP_Assignment_Main_01.assignOpportunities] ProjectTypesToReps: ' + String.valueOf(baseContext.ProjectTypesToReps));

        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Processing leads');
        Set<Assignment_Filter__c> currentReps; // Loop variable

        for (SObject oSObj : lSObjs){
            if (Integer.valueOf(safeGet(oSObj, 'T_TriggerLeadAssign__c')) == 1){
                // 1 if the lead is to be assigned. 
                // This is formula that says: Assign__c && !Prescriber__c && !Gec_Direct__c
                System.Debug('[AP_Assignment_Main_01.assignOpportunities] Processing lead with ID ' + String.valueOf(oSObj.Id));

                // This is the LeadContext for this specific Lead.
                AP_Assignment_Utilities_01.LeadContext context = baseContext.getLeadContext(
                    (Id) safeGet(oSObj, 'T_Assignment_ActivityDomainId__c'),
                    (String) safeGet(oSObj, 'T_Assignment_MarketType__c'),
                    (Id) safeGet(oSObj, 'T_Assignment_CantonId__c'),
                    (String) safeGet(oSObj, 'T_Assignment_ProjectType__c')
                );

                // Now, we have ALL the reps that have a chance to handle the lead. (But some will NOT.).
                // All we have left to do is to find the best one.
                //
                // We want one that:
                //  + Works for this Canton
                //  + Works for this MT
                //  + Works tor this AD
                //  + Works for this PT
                //
                // We have an order of resolution, at each level we will prefer having someone working on that
                // PT if possible.
                //
                // The rule is: 
                //  + AD / MT / CA (+PT)
                //  + MT / CA (+ All AD) (+PT)
                //  + AD / CA (+ All MT) (+PT)
                //  + CA (+ All AD + All MT) (+PT)
                //  + AD / MT (+ All Cantons) (+PT)
                //  + MT (+ All AD + All Cantons) ? (+PT)
                //  + AD (+ All MT + All Cantons) ?  (+PT)
                //  + ? (All AD All MT All Canton) (+PT)

                List<AP_Assignment_Utilities_01.SearchCriteria> lCriteria = new List<AP_Assignment_Utilities_01.SearchCriteria> {
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, true),   // AD MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, false),   // AD MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, true),   // MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, false),   // MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, true),   // AD CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, false),   // AD CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, true),   // CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, false),   // CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, true),  // AD MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, false),  // AD MT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, true),  // MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, false),  // MT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, true),  // AD PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, false),  // AD
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, true),   // ANY1 PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, false)   // ANY1
                };

                currentReps = new Set<Assignment_Filter__c>();

                System.debug('Searching for Rep in context ' + context);
                AP_Assignment_Utilities_01.SearchCriteria currentCriteria;
                try {
                    while (!(currentReps.size()>0)){
                        currentCriteria = lCriteria.remove(0);
                        System.debug('Searching with criteria: ' + currentCriteria);
                        currentReps = AP_Assignment_Utilities_01.findRep(context, currentCriteria); // Let's take the first criterion on the list.
                        System.debug('Found: ' + currentReps);
                    }
                } catch (System.ListException e){
                    System.debug('Finished list - found no rep.');
                    // We reached the end of the list and still found no solution: that's an error.
                }

                // We have a more stringent check here, we want to know if there's a config issue
                if (currentReps.size() == 1){ 
                    // We have a rep!
                    // So... this is clumsy, but can we do it another way?
                    for(Assignment_Filter__c oAF : currentReps){
                        // It's "repId", but it could actually be a Queue's ID.
                        System.Debug('[AP_Assignment_Main_01.assignOpportunities] Lead assigned to Rep with ID: ' + String.valueOf(oAF.TargetId__c));
                        oSObj.put('OwnerId', (Id) oAF.TargetId__c);
                        oSObj.put('Assign__c', false); // Once assigned, always un-flag the Lead.
                     
                    }
                } else {
                    if (currentReps.size() > 1){
                        oSObj.addError(System.Label.Error_MultipleRepsFound);
                    } else {
                        oSObj.addError(System.Label.Error_NoRepFound);
                    }
                }
            } else {
                System.debug('[AP_Assignment_Main_01.assignOpportunities] Trigger should not run for this Lead.');
            }
        }

        System.Debug('END method AP_Assignment_Main_01.assignOpportunities'); 
    }
    
    // Erwan 20170221 Method changed
    @future 
    public static void assignLeads(List<Id> recordIds) {
        System.Debug('START method AP_Assignment_Main_01.assignLeads');

        // Let's find all the Activity Domains, Market Types and Cantons we're interested in
        Set<Id> sRelevantADs     = new Set<Id>{null};
        Set<String> sRelevantMTs = new Set<String>{null};
        Set<Id> sRelevantCAs     = new Set<Id>{null};
        Set<String> sRelevantPTs = new Set<String>{null};
        
        List<Lead> leadsToUpdate = new List<Lead>{};
		
		List<Lead> leads = [SELECT T_Assignment_ActivityDomainId__c, T_Assignment_MarketType__c, T_Assignment_CantonId__c, T_Assignment_ProjectType__c, T_TriggerLeadAssign__c 
							FROM Lead 
							WHERE Id IN :recordIds];
		
		
        // TODO: validate that the fields EXIST
        for (Lead oLead : leads){
        	System.Debug('[AP_Assignment_Main_01.assignLeads] Lead ADs are:' + oLead.T_Assignment_ActivityDomainId__c);
        	System.Debug('[AP_Assignment_Main_01.assignLeads] Lead MTs are:' + oLead.T_Assignment_MarketType__c);
        	System.Debug('[AP_Assignment_Main_01.assignLeads] Lead CAs are:' + oLead.T_Assignment_CantonId__c);
        	System.Debug('[AP_Assignment_Main_01.assignLeads] Lead PTs are:' + oLead.T_Assignment_ProjectType__c);
        	
            sRelevantADs.add(oLead.T_Assignment_ActivityDomainId__c);
            sRelevantMTs.add(oLead.T_Assignment_MarketType__c);
            sRelevantCAs.add(oLead.T_Assignment_CantonId__c);
            sRelevantPTs.add(oLead.T_Assignment_ProjectType__c);
        }

        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant ADs are:' + sRelevantADs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant MTs are:' + sRelevantMTs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant CAs are:' + sRelevantCAs);
        System.Debug('[AP_Assignment_Main_01.assignLeads] Relevant PTs are:' + sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignLeads] Loading Assignment Filters.');
        AP_Assignment_Utilities_01.BaseContext baseContext = AP_Assignment_Utilities_01.buildContext(sRelevantADs, sRelevantMTs, sRelevantCAs, sRelevantPTs);

        System.Debug('[AP_Assignment_Main_01.assignLeads] ADToReps: ' + String.valueOf(baseContext.ActivityDomainsToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] MarketTypesToReps: ' + String.valueOf(baseContext.MarketTypesToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] CantonsToReps: ' + String.valueOf(baseContext.CantonsToReps));
        System.Debug('[AP_Assignment_Main_01.assignLeads] ProjectTypesToReps: ' + String.valueOf(baseContext.ProjectTypesToReps));

        System.Debug('[AP_Assignment_Main_01.assignLeads] Processing leads');
        Set<Assignment_Filter__c> currentReps; // Loop variable

        for (Lead oLead : leads){
            if (Integer.valueOf(oLead.T_TriggerLeadAssign__c) == 1){
                // 1 if the lead is to be assigned. 
                // This is formula that says: Assign__c && !Prescriber__c && !Gec_Direct__c
                System.Debug('[AP_Assignment_Main_01.assignLeads] Processing lead with ID ' + String.valueOf(oLead.Id));

                // This is the LeadContext for this specific Lead.
                AP_Assignment_Utilities_01.LeadContext context = baseContext.getLeadContext(
                    (Id) oLead.T_Assignment_ActivityDomainId__c,
                    (String) oLead.T_Assignment_MarketType__c,
                    (Id) oLead.T_Assignment_CantonId__c,
                    (String) oLead.T_Assignment_ProjectType__c
                );

                // Now, we have ALL the reps that have a chance to handle the lead. (But some will NOT.).
                // All we have left to do is to find the best one.
                //
                // We want one that:
                //  + Works for this Canton
                //  + Works for this MT
                //  + Works tor this AD
                //  + Works for this PT
                //
                // We have an order of resolution, at each level we will prefer having someone working on that
                // PT if possible.
                //
                // The rule is: 
                //  + AD / MT / CA (+PT)
                //  + MT / CA (+ All AD) (+PT)
                //  + AD / CA (+ All MT) (+PT)
                //  + CA (+ All AD + All MT) (+PT)
                //  + AD / MT (+ All Cantons) (+PT)
                //  + MT (+ All AD + All Cantons) ? (+PT)
                //  + AD (+ All MT + All Cantons) ?  (+PT)
                //  + ? (All AD All MT All Canton) (+PT)

                List<AP_Assignment_Utilities_01.SearchCriteria> lCriteria = new List<AP_Assignment_Utilities_01.SearchCriteria> {
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, true),   // AD MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, false),   // AD MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, true),   // MT CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  true, false),   // MT CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, true),   // AD CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, true, false),   // AD CA
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, true),   // CA PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, true, false),   // CA
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, true),  // AD MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  false, false),  // AD MT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, true),  // MT PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, true,  false, false),  // MT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, true),  // AD PT
                    new AP_Assignment_Utilities_01.SearchCriteria(true,  false, false, false),  // AD
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, true),   // ANY1 PT
                    new AP_Assignment_Utilities_01.SearchCriteria(false, false, false, false)   // ANY1
                };

                currentReps = new Set<Assignment_Filter__c>();

                System.debug('Searching for Rep in context ' + context);
                AP_Assignment_Utilities_01.SearchCriteria currentCriteria;
                try {
                    while (!(currentReps.size()>0)){
                        currentCriteria = lCriteria.remove(0);
                        System.debug('Searching with criteria: ' + currentCriteria);
                        currentReps = AP_Assignment_Utilities_01.findRep(context, currentCriteria); // Let's take the first criterion on the list.
                        System.debug('Found: ' + currentReps);
                    }
                } catch (System.ListException e){
                    System.debug('Finished list - found no rep.');
                    // We reached the end of the list and still found no solution: that's an error.
                }

                // We have a more stringent check here, we want to know if there's a config issue
                if (currentReps.size() == 1){ 
                    // We have a rep!
                    // So... this is clumsy, but can we do it another way?
                    for(Assignment_Filter__c oAF : currentReps){
                        // It's "repId", but it could actually be a Queue's ID.
                        System.Debug('[AP_Assignment_Main_01.assignLeads] Lead assigned to Rep with ID: ' + String.valueOf(oAF.TargetId__c));
                        
                        oLead.OwnerId = (Id) oAF.TargetId__c;
                        oLead.Assign__c = false; // Once assigned, always un-flag the Lead.
                    }
                } else {
                    if (currentReps.size() > 1){
                        oLead.addError(System.Label.Error_MultipleRepsFound);
                    } else {
                        oLead.addError(System.Label.Error_NoRepFound);
                    }
                }
                
                leadsToUpdate.add(oLead);
                
            } else {
                System.debug('[AP_Assignment_Main_01.assignLeads] Trigger should not run for this Lead.');
            }
        }
        
        if(leadsToUpdate.size()>0){
        	update leadsToUpdate;
        }

        System.Debug('END method AP_Assignment_Main_01.assignLeads'); 
    }

}