@isTest
public class IT_TestRunner_Scheduler_TEST {

    @isTest
    static void testExecute() {
        SchedulableContext sc = null;
        IT_TestRunner_Scheduler its = new IT_TestRunner_Scheduler();
        its.Execute(sc);
    }
}