public with sharing class IT_AutomatedTestSetup_Controller {
	public Boolean hasScheduledJobs { get; set; }
	public Boolean hasTestRun { get; set; }
	public Boolean isRunning { get; set; }
	public Boolean isEmailing { get; set; }
    public Integer testHour {get; set;}
    public Integer testMinutes {get; set;}
    public String testStartDay {get; set;}
    public String testEndDay {get; set;}
    public Integer emailHour {get; set;}
    public Integer emailMinutes {get; set;}
    public String emailStartDay {get; set;}
    public String emailEndDay {get; set;}
    
	public void refreshHasScheduledJobs() {
		Integer jobCount = [select count() from CronJobDetail where Name like 'IT_TestRunner%' and JobType = '7'];
		hasScheduledJobs = jobCount == 2;		
	}
	
	public void refreshHasTestRun() {
		Integer runCount = [select count() from IT_Automated_Test_Run__c limit 1];
		hasTestRun = runCount > 0;		
	}
	
	public String getTestRunLink() {
		return '/' + IT_Automated_Test_Run__c.SObjectType.getDescribe().getKeyPrefix();
	}
	
	public IT_AutomatedTestSetup_Controller() {
        this.testHour = 2;
        this.testMinutes = 0;
        this.testStartDay = 'MON';
        this.testEndDay = 'FRI';
        
        this.emailHour = 3;
        this.emailMinutes = 0;
        this.emailStartDay = 'MON';
        this.emailEndDay = 'FRI';
        
		this.refreshHasScheduledJobs();
		this.refreshHasTestRun();
	}
	
	public void scheduleJobs() {
		IT_TestRunner.setup(this.testHour, this.testMinutes, this.testStartDay, this.testEndDay, this.emailHour, this.emailMinutes, this.emailStartDay, this.emailEndDay);
        
		this.refreshHasScheduledJobs();
		
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Jobs scheduled'));
	}
	
	public void createTestRun() {
		User currentUser = [select Email from User where Id = :UserInfo.getUserId()];
        
		insert new IT_Automated_Test_Run__c(Name = 'All Tests', IT_Emails__c = currentUser.Email); 
        
		this.refreshHasTestRun();
        
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Automated Test Run created'));
	}
	
	public void run() {
		IT_TestRunner.enqueueTests();
        
		this.isRunning = true;
        
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Tests queued'));
	}
	
	public void email() {
		IT_TestRunnerResults.emailUnprocessedJobStatus();
        
		isEmailing = true;
        
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Results processed and emailed'));
	}
}