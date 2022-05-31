@isTest
public class IT_TestRunnerResults_Scheduler_TEST {

    @isTest
    static void testExecute() {
        SchedulableContext sc = null;
        IT_TestRunnerResults_Scheduler its = new IT_TestRunnerResults_Scheduler();
        its.Execute(sc);
    }

}