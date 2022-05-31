global class Batch_Counting_Opp_Prescriber_User implements Database.Batchable<sObject> {
    
     // Implement the interface to update the couting Opportunities for User
    
    global String query; 
    global Batch_Counting_Opp_Prescriber_User (String q){
       this.query = q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<User> lUsers) {
        // Initialize all on 0.
        // That's the value they should have when their not in the AggregateResult
        for (User oUser : lUsers) {
             oUser.Prescribed_Opportunties_Won__c = 0;
        }

        String duration = Utils.getCustomSetting('Window_Won_Prescribed_Opportunities');
        Date datePeriod = Date.today();
        datePeriod = datePeriod.addMonths(-integer.valueof(duration));
        
        
        // Update the accounts that have a changed number of closed won opportunities.
        if (lUsers.size() > 0) {
            List<AggregateResult> RelatedCasesCount = [
                    SELECT
                        Prescriber_User__c, 
                        count(Id) Won_Opportunities_Count
                    FROM Opportunity 
                    WHERE Prescriber_User__c IN :lUsers
                    AND CloseDate > :datePeriod
                    AND ISWON = true
                    GROUP BY Prescriber_User__c
                ];

            Map<Id, User> mUsers = new Map<Id, User>(); 
            for (User oUser : lUsers){
                mUsers.put(oUser.Id, oUser);
            }

            for (AggregateResult ar : RelatedCasesCount) {
                User oUser = mUsers.get((Id)ar.get('Prescriber_User__c'));
                oUser.Prescribed_Opportunties_Won__c = Integer.valueOf(ar.get('Won_Opportunities_Count'));
            }
            update mUsers.values();
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}