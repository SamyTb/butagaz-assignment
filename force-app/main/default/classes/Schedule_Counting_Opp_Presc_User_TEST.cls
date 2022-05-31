@isTest
private class Schedule_Counting_Opp_Presc_User_TEST {

    static testMethod void myUnitTest() {
    	
    	Custom_Settings__c cs1 = new Custom_Settings__c(name='Window_Won_Prescribed_Opportunities', value__c='24');
    	insert cs1;
    	
        test.starttest();
        
        Schedule_Counting_Opp_Prescriber_User sb = new Schedule_Counting_Opp_Prescriber_User();        
        String sch = '0 0 6 * * ?';        
        system.schedule('Batch Counting Opp Prescriber User', sch, sb);
        
        // Stop test        
        test.stoptest();
    }
}