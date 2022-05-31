global class IT_TestRunnerResults {

    @future(callout=true)
    public static void emailUnprocessedJobStatus() {
        List<IT_Test_Runner_Job__c> jobs = getUnprocessedJobs();

        List<Messaging.SingleEmailMessage> messages = IT_TestRunner.emailMethodStatus(jobs);

        for (IT_Test_Runner_Job__c job: jobs) {
            job.IT_Processed__c = true;
        }

        update jobs;
    }

    public static List <IT_Test_Runner_Job__c> getUnprocessedJobs() {
        return [Select t.Name,
            t.IT_Automated_Test_Run__r.IT_Emails__c,
            t.IT_Automated_Test_Run__r.IT_Email_on_Pass__c,
            t.IT_Automated_Test_Run__r.Name,
            t.IT_Automated_Test_Run__c
            From IT_Test_Runner_Job__c t where IT_Processed__c = false
        ];
    }

}