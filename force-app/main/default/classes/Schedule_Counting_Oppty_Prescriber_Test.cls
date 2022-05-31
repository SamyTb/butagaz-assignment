@isTest
private class Schedule_Counting_Oppty_Prescriber_Test {

static testMethod void myUnitTest() {
      
        test.starttest();
        
        Schedule_Counting_Oppty_Prescriber sb = new Schedule_Counting_Oppty_Prescriber();        
        String sch = '0 0 6 * * ?';        
        system.schedule('Batch Counting Opp Prescriber Account', sch, sb);
    /*
    String sch2 = '0 10 6 * * ?';
        Schedule_Counting_Event_Prescriber sb2 =new Schedule_Counting_Event_Prescriber();
    system.schedule('Batch Counting event Prescribed', sch2, sb2);
        // Stop test  
        // */      
        test.stoptest();
	}

}