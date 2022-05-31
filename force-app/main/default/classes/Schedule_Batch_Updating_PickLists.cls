global class Schedule_Batch_Updating_PickLists implements Schedulable {
	global void execute (SchedulableContext sc) {  
		Batch_Updating_PickLists iBatch = new Batch_Updating_PickLists();
		
		ID batchprocessid = Database.executeBatch(iBatch);
	}
}