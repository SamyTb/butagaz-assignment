@isTest
private class Schedule_Counting_Opp_Presc_Acc_TEST {

    static testMethod void myUnitTest() {
    	
        test.starttest();
        
        Schedule_Counting_Opp_Prescriber_Account sb = new Schedule_Counting_Opp_Prescriber_Account();        
        String sch = '0 0 6 * * ?';        
        system.schedule('Batch Counting Opp Prescriber Account', sch, sb);
        
        // Stop test        
        test.stoptest();
    }
}