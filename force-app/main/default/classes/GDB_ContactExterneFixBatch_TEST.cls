@isTest private class GDB_ContactExterneFixBatch_TEST {
	@isTest static void testBatch() 
    {
        Contact contact = new Contact();
        
        contact.LastName = 'Test';
        
        insert contact;
        
        Test.startTest();
        Database.executeBatch(new GDB_ContactExterneFixBatch(), 200);
        Test.stopTest();
    }
}