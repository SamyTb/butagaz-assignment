global class Schedule_Batch_Updating_PTL_ContactMKT implements Schedulable {
	global void execute (SchedulableContext sc) {  
		Batch_Updating_PTL_ContactMKT iBatch = new Batch_Updating_PTL_ContactMKT();
		
		ID batchprocessid = Database.executeBatch(iBatch);
	}
}