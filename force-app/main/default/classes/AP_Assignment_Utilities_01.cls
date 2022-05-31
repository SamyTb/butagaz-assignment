public class AP_Assignment_Utilities_01 {

    // These are helper method to update Map<Id, Set<Assignment_Filter__c>>.
    // TODO: Find a way to avoid the duplication of code. (But the types are different...)
    public static Map<Id, Set<Assignment_Filter__c>> helperUpdateSetMap(Map<Id, Set<Assignment_Filter__c>> oMap, Id oKey, Assignment_Filter__c oAssignmentFilter){
        if (!(oMap.containsKey(oKey))){ oMap.put(oKey, new Set<Assignment_Filter__c>()); }
        oMap.get(oKey).add(oAssignmentFilter);
        return oMap;
    }
    public static Map<String, Set<Assignment_Filter__c>> helperUpdateSetMap(Map<String, Set<Assignment_Filter__c>> oMap, String oKey, Assignment_Filter__c oAssignmentFilter){
        if (!(oMap.containsKey(oKey))){ oMap.put(oKey, new Set<Assignment_Filter__c>()); }
        oMap.get(oKey).add(oAssignmentFilter);
        return oMap;
    }

    public class SearchCriteria{
        public Boolean ensureAD {get; set;}
        public Boolean ensureMT {get; set;}
        public Boolean ensureCA {get; set;}
        public Boolean ensurePT {get; set;}

        public SearchCriteria(Boolean ensureAD, Boolean ensureMT, Boolean ensureCA, Boolean ensurePT){
            this.ensureAD = ensureAD;
            this.ensureMT = ensureMT;
            this.ensureCA = ensureCA;
            this.ensurePT = ensurePT;
        }
    }

    public class BaseContext{
        // This class holds a base context, that is, data that was retrieved from the DB (Cantns to Reps, and so on)
        // Basically, this is all the data relevant to the leads we're currently assigning.
        public Set<Assignment_Filter__c>              allReps {get; set;}
        public Map<Id, Set<Assignment_Filter__c>>     ActivityDomainsToReps {get; set;}
        public Map<String, Set<Assignment_Filter__c>> MarketTypesToReps {get; set;}
        public Map<Id, Set<Assignment_Filter__c>>     CantonsToReps {get; set;}
        public Map<String, Set<Assignment_Filter__c>> ProjectTypesToReps {get;set;}

        public BaseContext(
            Set<Assignment_Filter__c>              allReps,
            Map<Id, Set<Assignment_Filter__c>>     ActivityDomainsToReps,
            Map<String, Set<Assignment_Filter__c>> MarketTypesToReps,
            Map<Id, Set<Assignment_Filter__c>>     CantonsToReps,
            Map<String, Set<Assignment_Filter__c>> ProjectTypesToReps
        ) {
            this.allReps = allReps;
            this.ActivityDomainsToReps = ActivityDomainsToReps;
            this.MarketTypesToReps = MarketTypesToReps;
            this.CantonsToReps = CantonsToReps;
            this.ProjectTypesToReps = ProjectTypesToReps;
        }

        public LeadContext getLeadContext(Id ActivityDomainId, String MarketType, Id CantonId, String ProjectType){
            // The variables we'll want to add to our BaseContext to make it a LeadContext!
            Set<Assignment_Filter__c> RepsForLeadActivityDomain = null;
            Set<Assignment_Filter__c> RepsForLeadMarket = null;
            Set<Assignment_Filter__c> RepsForLeadCanton = null;
            Set<Assignment_Filter__c> RepsForLeadProjectType = null;

            if (this.ActivityDomainsToReps.containsKey(ActivityDomainId)){
                RepsForLeadActivityDomain = this.ActivityDomainsToReps.get(ActivityDomainId); 
            } else {
                RepsForLeadActivityDomain = new Set<Assignment_Filter__c>();
            }

            if (this.MarketTypesToReps.containsKey(MarketType)){
                RepsForLeadMarket = this.MarketTypesToReps.get(MarketType); 
            } else {
                RepsForLeadMarket = new Set<Assignment_Filter__c>();
            }

            if (this.CantonsToReps.containsKey(CantonId)){
                RepsForLeadCanton = this.CantonsToReps.get(CantonId);
            } else {
                RepsForLeadCanton = new Set<Assignment_Filter__c>();
            }

            if (this.ProjectTypesToReps.containsKey(ProjectType)){
                RepsForLeadProjectType = this.ProjectTypesToReps.get(ProjectType);
            } else {
                RepsForLeadProjectType = new Set<Assignment_Filter__c>();
            }

            return new AP_Assignment_Utilities_01.LeadContext(
                this.allReps, 
                RepsForLeadActivityDomain, RepsForLeadMarket, RepsForLeadCanton, RepsForLeadProjectType,
                this.ActivityDomainsToReps, this.MarketTypesToReps, this.CantonsToReps, this.ProjectTypesToReps
            );
        }
    }

    public static BaseContext buildContext( Set<Id> sRelevantADs, Set<String> sRelevantMTs, Set<Id> sRelevantCAs, Set<String> sRelevantPTs){
        return AP_Assignment_Utilities_01.buildContext(sRelevantADs, sRelevantMTs, sRelevantCAs, sRelevantPTs, new List<Assignment_Filter__c>());
    }

    public static BaseContext buildContext(Set<Id> sRelevantADs, Set<String> sRelevantMTs, Set<Id> sRelevantCAs, Set<String> sRelevantPTs, List<Assignment_Filter__c> extraFilters){
        // Set up a Mini-DB we can use here.
        Map<Id, Set<Assignment_Filter__c>> ActivityDomainsToReps = new Map<Id, Set<Assignment_Filter__c>>();
        Map<String, Set<Assignment_Filter__c>> MarketTypesToReps = new Map<String, Set<Assignment_Filter__c>>();
        Map<Id, Set<Assignment_Filter__c>> CantonsToReps = new Map<Id, Set<Assignment_Filter__c>>();
        Map<String, Set<Assignment_Filter__c>> ProjectTypesToReps = new Map<String, Set<Assignment_Filter__c>>();
        Set<Assignment_Filter__c> allReps = new Set<Assignment_Filter__c>();

        ActivityDomainsToReps.put(null, new Set<Assignment_Filter__c>());
        MarketTypesToReps.put(null, new Set<Assignment_Filter__c>());
        CantonsToReps.put(null, new Set<Assignment_Filter__c>());
        ProjectTypesToReps.put(null, new Set<Assignment_Filter__c>());

        // TODO We have some code duplication here that would be nice to remove.
        // The goal of having two loops and not a list + addAll is that using the [SOQL] in a for construct 
        // will automatically break the select in smaller parts if needed, which is safer.
        System.Debug('[AP_Assignment_Utilities_01.buildContext] Processing DB AFs');
        for (Assignment_Filter__c oAF : [SELECT Activity_Domain__c, Canton__c, Market_Type__c, Project_Type__c, TargetId__c FROM Assignment_Filter__c WHERE Activity_Domain__c IN :sRelevantADs AND Market_Type__c IN :sRelevantMTs AND Canton__c IN :sRelevantCAs AND Project_Type__c IN :sRelevantPTs]){
            System.Debug('[AP_Assignment_Utilities_01.buildContext] Processing AF ' + oAF);
            // Triggers ensure that this is actually an ID.
            AP_Assignment_Utilities_01.helperUpdateSetMap(ActivityDomainsToReps,oAF.Activity_Domain__c,oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(MarketTypesToReps,oAF.Market_Type__c,oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(CantonsToReps,oAF.Canton__c, oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(ProjectTypesToReps,oAF.Project_Type__c,oAF);
            allReps.add(oAF);
        }

        System.Debug('[AP_Assignment_Utilities_01.buildContext] Processing Extra AFs');
        for (Assignment_Filter__c oAF : extraFilters){
            System.Debug('[AP_Assignment_Utilities_01.buildContext] Processing AF ' + oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(ActivityDomainsToReps,oAF.Activity_Domain__c,oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(MarketTypesToReps,oAF.Market_Type__c,oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(CantonsToReps,oAF.Canton__c, oAF);
            AP_Assignment_Utilities_01.helperUpdateSetMap(ProjectTypesToReps,oAF.Project_Type__c,oAF);
            allReps.add(oAF);
        }

        System.Debug('[AP_Assignment_Utilities_01.buildContext] All AFS: ' + allReps);
        return new AP_Assignment_Utilities_01.BaseContext(allReps, ActivityDomainsToReps, MarketTypesToReps, CantonsToReps, ProjectTypesToReps);
    }

    public class LeadContext{
        // This class holds the search context for a specific lead.
        // Basically, this is data relevant to a single lead. 
        // This data includes the full context + specific data to the lead.
        public Set<Assignment_Filter__c>              allReps {get; set;}
        public Set<Assignment_Filter__c>              RepsForLeadActivityDomain {get; set;}
        public Set<Assignment_Filter__c>              RepsForLeadMarket {get; set;}
        public Set<Assignment_Filter__c>              RepsForLeadCanton {get; set;}
        public Set<Assignment_Filter__c>              RepsForLeadProjectType {get; set;}
        public Map<Id, Set<Assignment_Filter__c>>     ActivityDomainsToReps {get; set;}
        public Map<String, Set<Assignment_Filter__c>> MarketTypesToReps {get; set;}
        public Map<Id, Set<Assignment_Filter__c>>     CantonsToReps {get; set;}
        public Map<String, Set<Assignment_Filter__c>> ProjectTypesToReps {get; set;}

        public LeadContext(
            Set<Assignment_Filter__c> allReps,
            Set<Assignment_Filter__c> RepsForLeadActivityDomain,      
            Set<Assignment_Filter__c> RepsForLeadMarket,
            Set<Assignment_Filter__c> RepsForLeadCanton,              
            Set<Assignment_Filter__c> RepsForLeadProjectType,              
            Map<Id, Set<Assignment_Filter__c>> ActivityDomainsToReps,
            Map<String, Set<Assignment_Filter__c>> MarketTypesToReps, 
            Map<Id, Set<Assignment_Filter__c>> CantonsToReps,
            Map<String, Set<Assignment_Filter__c>> ProjectTypesToReps 
        ) {
            this.allReps = allReps;
            this.RepsForLeadActivityDomain = RepsForLeadActivityDomain;
            this.RepsForLeadMarket = RepsForLeadMarket;
            this.RepsForLeadCanton = RepsForLeadCanton;
            this.RepsForLeadProjectType = RepsForLeadProjectType;
            this.ActivityDomainsToReps = ActivityDomainsToReps;
            this.MarketTypesToReps = MarketTypesToReps;
            this.CantonsToReps = CantonsToReps;
            this.ProjectTypesToReps = ProjectTypesToReps;
        }
    }

    public static Set<Assignment_Filter__c> findRep(LeadContext context, SearchCriteria criteria){
        // Utility method to find reps according to criteria and avoid _massive_ code duplication.
        Set<Assignment_Filter__c> currentReps = context.allReps.clone();
        System.debug('{AP_Assignment_Utilities_01.findRep] --- BEGIN DUMP ---');
        System.debug('{AP_Assignment_Utilities_01.findRep] --- LeadCTX ---');

        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsForLeadAD: ' + context.RepsForLeadActivityDomain);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsForLeadMT: ' + context.RepsForLeadMarket);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsForLeadCA: ' + context.RepsForLeadCanton);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsForLeadPT: ' + context.RepsForLeadProjectType);

        System.debug('{AP_Assignment_Utilities_01.findRep] --- BaseCTX ---');
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsByAD: ' + context.ActivityDomainsToReps);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsByMT: ' + context.MarketTypesToReps);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsByCA: ' + context.CantonsToReps);
        System.debug('{AP_Assignment_Utilities_01.findRep] ctx.RepsByPT: ' + context.ProjectTypesToReps);

        System.debug('{AP_Assignment_Utilities_01.findRep] --- END DUMP ---');

        if (criteria.ensureAD){ currentReps.retainAll(context.RepsForLeadActivityDomain); }
        else { currentReps.retainAll(context.ActivityDomainsToReps.get(null)); }

        if (criteria.ensureMT){ currentReps.retainAll(context.RepsForLeadMarket); }
        else { currentReps.retainAll(context.MarketTypesToReps.get(null)); }

        if (criteria.ensureCA){ currentReps.retainAll(context.RepsForLeadCanton); }
        else { currentReps.retainAll(context.CantonsToReps.get(null)); }

        if (criteria.ensurePT){ currentReps.retainAll(context.RepsForLeadProjectType); }
        else { currentReps.retainAll(context.ProjectTypesToReps.get(null)); }

        return currentReps;
    }
}