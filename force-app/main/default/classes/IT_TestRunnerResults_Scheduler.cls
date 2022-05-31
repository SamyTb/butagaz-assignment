global class IT_TestRunnerResults_Scheduler implements Schedulable {
	
   global void execute(SchedulableContext SC) 
   {
      IT_TestRunnerResults.emailUnprocessedJobStatus(); 
   }

}