global class  Batch_Counting_Opp_Prescriber_Account implements Database.Batchable<sObject> {
    
     // Implement the interface to update the couting Opportunities for Account
    global String query; 
    
    global  Batch_Counting_Opp_Prescriber_Account (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<Account> lAccounts) {
        // Initialize all on 0.
        // That's the value they should have when their not in the AggregateResult
        for (Account oAccount : lAccounts) {
             oAccount.Prescribed_Opportunties_Won__c = 0;
        }

        String duration = Utils.getCustomSetting('Window_Won_Prescribed_Opportunities');
        Date datePeriod = Date.today();
        datePeriod = datePeriod.addMonths(-integer.valueof(duration));
        
        // Update the accounts that have a changed number of closed won opportunities.
        if (lAccounts.size() > 0) {
            List<AggregateResult> RelatedCasesCount = [
                    SELECT
                        Prescriber_Account__c, 
                        count(Id) Won_Opportunities_Count
                    FROM Opportunity 
                    WHERE Prescriber_Account__c IN :lAccounts
                    AND CloseDate > :datePeriod
                    AND ISWON =true
                    GROUP BY Prescriber_Account__c
                ];

            Map<Id, Account> mAccounts = new Map<Id, Account>(); 
            for (Account oAccount : lAccounts){
                mAccounts.put(oAccount.Id, oAccount);
            }

            for (AggregateResult ar : RelatedCasesCount) {
                Account oAccount = mAccounts.get((Id)ar.get('Prescriber_Account__c'));
                oAccount.Prescribed_Opportunties_Won__c = Integer.valueOf(ar.get('Won_Opportunities_Count'));
            }
            update mAccounts.values();
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}