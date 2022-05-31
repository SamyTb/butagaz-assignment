trigger TaskAfterInsert on Task (after insert) {
    if (Trigger.IsAfter && Trigger.IsInsert) {
        System.Debug(logginglevel.WARN,'##>>> Task.AfterInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Task> lTasks = Trigger.new;
        
        if (PAD.canTrigger('Task.updateRelatedTasksCount')) {
            AP_Task_01.updateRelatedTasksCount(lTasks);
        } else {
            System.Debug(logginglevel.WARN,'##>>> Task.AfterInsert : BYPASS updateRelatedTasksCount <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Task.updateActivityHistoryOnCase')) {
            AP_Task_01.updateActivityHistoryOnCase(lTasks);
        } else {
            System.Debug(logginglevel.WARN,'##>>> Task.afterInsert : BYPASS updateActivityHistoryOnCase <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Task.updateFirstCallOnLead')) {
            AP_Task_01.updateFirstCallOnLead(lTasks);
        } else {
            System.Debug(logginglevel.WARN,'##>>> Task.afterInsert : BYPASS updateFirstCallOnLead <<< run by ' + UserInfo.getName());
        }
        
        System.Debug(logginglevel.WARN,'##>>> Task.AfterInsert : END <<<');
    } else {
        System.Debug(logginglevel.WARN,'##>>> Task.AfterInsert : FALSE TRIGGER <<<');
    }
}