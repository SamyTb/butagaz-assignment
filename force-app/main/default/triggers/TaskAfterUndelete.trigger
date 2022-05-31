trigger TaskAfterUndelete on Task (after undelete) {
    if (Trigger.IsAfter && Trigger.IsUndelete) {
        System.Debug('##>>> Task.AfterUndelete : BEGIN <<< run by ' + UserInfo.getName());
        List<Task> lTasks = Trigger.new;
        
        if (PAD.canTrigger('Task.updateRelatedTasksCount')) {
            AP_Task_01.updateRelatedTasksCount(lTasks);
        } else {
            System.Debug('##>>> Task.AfterUndelete : BYPASS updateRelatedTasksCount <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Task.AfterUndelete : END <<<');
    } else {
        System.Debug('##>>> Task.AfterUndelete : FALSE TRIGGER <<<');
    }
}