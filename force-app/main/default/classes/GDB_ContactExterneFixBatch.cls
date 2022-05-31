global class GDB_ContactExterneFixBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
     
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator([SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 10]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts){
        for(Contact contact : contacts)
        {
        }
    }
    
    global void finish(Database.BatchableContext BC ){}
}