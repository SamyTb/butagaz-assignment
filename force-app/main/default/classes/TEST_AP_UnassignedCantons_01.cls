public class TEST_AP_UnassignedCantons_01{
    public static Set<Canton__c> findNotAssignedCantonsIds() {
        List<String> allMarketTypes     = new List<String>{null, 'DOM', 'PRO'};
        List<String> allProjectTypes    = new List<String>{null, 'CREA', 'FIDE', 'EXTE', 'SUCC'};
        List<String> allActivityDomains = new List<String>{null}; //TODO: Could be List<Id>.
        for (Activity_Domain__c oAD : [SELECT Id FROM Activity_Domain__c]) {allActivityDomains.add(oAD.Id);}
        
        System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Number of Market Types    : [' + allMarketTypes.size() + ']');
        System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Number of Project Types   : [' + allProjectTypes.size() + ']');
        System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Number of Activity Domains: [' + allActivityDomains.size() + ']');
        
        System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Number of Expected queries: [' + allMarketTypes.size() * allProjectTypes.size() * allActivityDomains.size() + ' + 1]');
        
        Set<Canton__c> unAssignedCantons = new Set<Canton__c>();
        List<Canton__c> loopCantons;
        Boolean firstGo = true;
        
        for (String marketType : allMarketTypes) {
            for (String projectType : allProjectTypes) {
                for (String activityDomain : allActivityDomains) {
                    System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Searching for [' + activityDomain + '.' + projectType + '.' + marketType + ']');
                    System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Number of queries: [' + Limits.getQueries() + ']');
                    System.debug('[TEST_AP_UnassignedCantons_01.findNotAssignedCantonsIds] Max queries: [' + Limits.getLimitQueries() + ']');
                    loopCantons = new List<Canton__c>([ 
                        SELECT Id 
                        FROM Canton__c 
                        WHERE 
                        Id NOT IN (
                            SELECT Canton__c FROM Assignment_Filter__c 
                            WHERE   Activity_Domain__c = null 
                                    AND Market_Type__c = null
                                    AND Project_Type__c = null
                            )
                    ]);
                    if (firstGo) {
                        unAssignedCantons.addAll(loopCantons);
                    } else {
                        unAssignedCantons.retainAll(loopCantons);
                    }
                }
            }
        }
    return unAssignedCantons;
    }
}