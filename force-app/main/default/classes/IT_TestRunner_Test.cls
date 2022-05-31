@isTest
private class IT_TestRunner_Test {
    static IT_Automated_Test_Run__c run;
    static IT_Test_Runner_Job__c job;

    static {
        run = new IT_Automated_Test_Run__c(Name = 'Test Automated Run', IT_Excluded_Classes__c = 'IT_TestRunner, Foo', IT_Emails__c = 'test@test.com', IT_Exclude_Managed_Packages__c = true);
        insert run;

        job = new IT_Test_Runner_Job__c(Name = 'Test', IT_Automated_Test_Run__c = run.Id);
        insert job;

        runJobs();
    }

    static void runJobs() {
        IT_TestRunnerResults.emailUnprocessedJobStatus();
    }

    public static testMethod void enqueueTestsCreatesJobs() {
        IT_TestRunner.ToolingAPIResponse tar = new IT_TestRunner.ToolingAPIResponse();
        IT_TestRunner.ApexCodeCoverageAggregate acca = new IT_TestRunner.ApexCodeCoverageAggregate();
        acca.NumLinesCovered = 10;
        acca.NumLinesUncovered = 15;
        IT_TestRunner.CodeCoverageWrapper ccw = new IT_TestRunner.CodeCoverageWrapper(acca);
        System.assertEquals(0, IT_TestRunner.enqueueTests().size(), 'Tests should not be queued during a test');
    }
}