trigger TaskAfterUpdate on Task (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Task.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Task> lNewTasks = Trigger.new;
        List<Task> lOldTasks = Trigger.old;
        
        if (PAD.canTrigger('Task.updateRelatedTasksCount')) {
            AP_Task_01.updateRelatedTasksCount(lOldTasks); // We also must update the count on the old values.
            AP_Task_01.updateRelatedTasksCount(lNewTasks);
        } else {
            System.Debug('##>>> Task.AfterUpdate : BYPASS updateRelatedTasksCount <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Task.updateActivityHistoryOnCase')) {
            AP_Task_01.updateActivityHistoryOnCase(lNewTasks);
        } else {
            System.Debug('##>>> Task.afterUpdate : BYPASS updateActivityHistoryOnCase <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Task.updateFirstCallOnLead')) {
            AP_Task_01.updateFirstCallOnLead(lNewTasks);
        } else {
            System.Debug(logginglevel.WARN,'##>>> Task.AfterUpdate : BYPASS updateFirstCallOnLead <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> Task.AfterUpdate : END <<<');
    } else {
        System.Debug('##>>> Task.AfterUpdate : FALSE TRIGGER <<<');
    }
}