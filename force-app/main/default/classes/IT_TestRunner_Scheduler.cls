global class IT_TestRunner_Scheduler implements Schedulable {
	
   global void Execute(SchedulableContext SC) 
   {
      IT_TestRunner.enqueueTests(); 
   }

}