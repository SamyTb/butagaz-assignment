global class Batch_UpdateCaseWorkingDays implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    // Instance member to retain state across transactions, to be used in the email sent in the finish method
    global Integer recordsProcessed = 0;
    
    
    public void execute(SchedulableContext context){
        Database.executeBatch(this);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select Id, CreatedDate, ClosedDate, CategorySLA__c, F_ClientFirstInteractionDate__c, Communicated_Due_Date__c, Time_Between_Promise_And_Reality__c, Duration_In_Working_Days__c
                                        from Case
                                        where CreatedDate >= THIS_YEAR
                                        and Status != 'Closed'
                                        and Mandataire__r.Active__c = True
                                        and F_ClientFirstInteractionDate__c = null]
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope){
        // Process each batch of records
        if(scope.size() > 0){
            DateUtilities.calculateWorkingDaysOnListOfCases(scope);
            recordsProcessed += scope.size();
            update scope;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed.');
        /* Uncomment if needed
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'erwan.lecaer@butagaz.com'});
        mail.setReplyTo('noreply@butagaz.fr');
        mail.setSenderDisplayName('Batch_UpdateCaseWorkingDays');
        mail.setSubject('Batch Process Completed. ' + recordsProcessed + ' cases updated.');
        mail.setPlainTextBody('Batch Process has completed');
         
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
    
}