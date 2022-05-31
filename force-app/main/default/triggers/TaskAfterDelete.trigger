trigger TaskAfterDelete on Task (after delete) {
    if (Trigger.IsAfter && Trigger.IsDelete) {
        System.Debug('##>>> Task.AfterDelete : BEGIN <<< run by ' + UserInfo.getName());
        List<Task> lTasks = Trigger.old;
        
        if (PAD.canTrigger('Task.updateRelatedTasksCount')) {
            AP_Task_01.updateRelatedTasksCount(lTasks);
        } else {
            System.Debug('##>>> Task.AfterDelete : BYPASS updateRelatedTasksCount <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Task.AfterDelete : END <<<');
    } else {
        System.Debug('##>>> Task.AfterDelete : FALSE TRIGGER <<<');
    }
}