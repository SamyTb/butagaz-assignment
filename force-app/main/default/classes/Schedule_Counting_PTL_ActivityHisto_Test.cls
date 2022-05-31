@isTest
private class Schedule_Counting_PTL_ActivityHisto_Test {

    static testMethod void Schedule_Counting_PTL_ActivityHisto_Test(){
    Test.startTest();
    
    System.schedule('Schedule_Counting_PTL_ActivityHistory_Test', '0 0 3 * * ?', new Schedule_Counting_PTL_ActivityHistory());
    
    Test.stopTest();
  }
}