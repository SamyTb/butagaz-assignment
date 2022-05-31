@isTest
public class Batch_UpdateCaseWorkingDays_Test {
	
	// Dummy CRON expression
    // Because this is a test, job executes immediately after Test.stopTest()
    public static String CRON_EXP = '0 0 0 27 10 ? 2076';
    
    static testmethod void testScheduledJob() {
    	
    	// Mandataire
    	Mandataire__c mand1 = new Mandataire__c(
            name = 'Mand1',
            ExternalID__c = 'MAP1',
            Active__c = true
        );
        insert mand1;
    	
    	// Category
    	Request_Category__c oParentCategory = new Request_Category__c();
        oParentCategory.Name__c = 'TestParentCategory';
        oParentCategory.Code__c = 'TPC';
        oParentCategory.SLA__c = 10;
        insert oParentCategory;
        
        Request_Category__c oCategory = new Request_Category__c();
        oCategory.Name__c = 'TestCategory';
        oCategory.Code__c = 'TC';
        oCategory.SLA__c = 5;
        oCategory.Parent_Category__c = oParentCategory.Id;
        insert oCategory;
    	
        // Create some cases
        List<Case> lcases = new List<Case>();
        //Date closeDate = Date.today().addDays(-7);
        for (Integer i=0; i<10; i++) {
            Case oCase = new Case(
                Subject = 'Case ' + i,
                Mandataire__c = mand1.Id,
                Category__c = oCategory.Id
            );
            lcases.add(oCase);
        }
        insert lcases;
        
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new Batch_UpdateCaseWorkingDays());         
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed, check number of days : still 0 because the date hasn't changed
        List<Case> lCasesToCheck = [SELECT Id, Duration_In_Working_Days__c FROM Case WHERE Id IN :lcases];
        System.assertEquals(0, lCasesToCheck[0].Duration_In_Working_Days__c, 'Number of days after job run');
    }
	
}