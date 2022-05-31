public class AP_Assignment_Filter_01{
    public static void enforceUniqueness(List<Assignment_Filter__c> lFilters){
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] START METHOD');
        Set<Id> sUpdatedIds = new Set<Id>();
        // The list of all the filters (the ones from the DB + updated (if we're updating)).
        Map<Id, Assignment_Filter__c> mAllFilters = new Map<Id, Assignment_Filter__c>();

        // These will allow us to find matching filters.
        // We don't filter on Project Type yet.
        Set<Id> sRelevantADs     = new Set<Id>{null};
        Set<String> sRelevantMTs = new Set<String>{null};
        Set<Id> sRelevantCAs     = new Set<Id>{null};
        Set<String> sRelevantPTs = new Set<String>{null};

        for (Assignment_Filter__c oFilter: lFilters){
            if (oFilter.Id <> null){ 
                sUpdatedIds.add(oFilter.Id); 
                mAllFilters.put(oFilter.Id, oFilter); // If we have an ID, let's add the object. We're updating.
            }
            sRelevantADs.add(oFilter.Activity_Domain__c);
            sRelevantMTs.add(oFilter.Market_Type__c);
            sRelevantCAs.add(oFilter.Canton__c);
            sRelevantPTs.add(oFilter.Project_Type__c);
        }
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Relevant ADs: ' + sRelevantADs);
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Relevant MTs: ' + sRelevantMTs);
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Relevant CAs: ' + sRelevantCAs);
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Relevant PTs: ' + sRelevantPTs);

        AP_Assignment_Utilities_01.BaseContext baseContext = AP_Assignment_Utilities_01.buildContext(sRelevantADs, sRelevantMTs, sRelevantCAs, sRelevantPTs, lFilters); // We want lFilters to come back to us. 
        // Two possibilities: we're inserting, and we'll get back the DB filters + those we put there in the first place
        // (lFilters), which WON'T be the same as the lFilters are being inserted and can't come from the DB.
        // Or, we're updating, and the filters might be the same as the ones we have from the DB, but we'll check the ID
        // because it being an update, the IDs exist.
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Found AFs: ' + baseContext.allReps);

        // Loop variable
        Set<Assignment_Filter__c> sMatchingFilters;
        AP_Assignment_Utilities_01.SearchCriteria allMatchCriterion = new AP_Assignment_Utilities_01.SearchCriteria(true,  true,  true, true);

        for (Assignment_Filter__c oFilter : lFilters){
            // Let's pretend our Filter is a Lead an try to assign it!
            AP_Assignment_Utilities_01.LeadContext filterContext = baseContext.getLeadContext(
                oFilter.Activity_Domain__c, oFilter.Market_Type__c, oFilter.Canton__c, oFilter.Project_Type__c
            );
            sMatchingFilters = AP_Assignment_Utilities_01.findRep(filterContext, allMatchCriterion);
            System.debug('[AP_Assignment_Filter_01.enforceUniqueness] AFs for criteria: ' + sMatchingFilters);
            sMatchingFilters.remove(oFilter);
            System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Removing current Item:' + oFilter);
            System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Duplicate AFs: ' + sMatchingFilters);
            for (Assignment_Filter__c oMatchingFilter : sMatchingFilters){
                // We have another filter with the exact same criteria as the current one, let's add an error.
                if ((oFilter.Id <> null) && (oFilter.Id == oMatchingFilter.Id)) {
                    // We are doing an update. Unfortunately, we might not have passed the exact same fields
                    // that we're getting back from the DB, so the Set doesn't come in play and we get two
                    // objects which are the same in DB but not the same in Apex code.

                    // Note.
                    // We don't want to blindly check for oFiter.Id <> oMatchingFilter.Id, because in the case
                    // of an insert, the IDs might be the same but the objects different (hence the set diff).

                    // So basically, we don't do anything here.
                    System.debug('[AP_Assignment_Filter_01.enforceUniqueness] False duplicate.');
                } else {
                    System.debug('[AP_Assignment_Filter_01.enforceUniqueness] Found duplicates.');
                    oFilter.addError(System.Label.Error_DuplicateAssignmentFilters + oMatchingFilter);
                }
            }
        }
        System.debug('[AP_Assignment_Filter_01.enforceUniqueness] END METHOD');
    }
}