public class AP_Task_01 {
    // TODO: constant for Related_Tasks_Count__c
    
    public static List<String> getTrackedObjects(){
        // This method will return the API Names of the Objects that must be updated.
        // Should fetch custom settings.
        return new List<String>{'Lead','Opportunity'};
    }

    public static void updateRelatedSobjects(String SObjectName, Set<Id> SObjectIds){
        // Pass a SOBject Name (e.g. Lead) and Ids, and the SObjects of this type with this ID will have their related
        // tasks count updated.
        // Get the objects we'll want to update

        System.debug('START method AP_Task_01.updateRelatedSobjects');

        Map<Id, SObject> mSObjects = new Map<Id, SObject>();
        String query = 'SELECT Id, Related_Tasks_Count__c FROM ' + String.escapeSingleQuotes(SObjectName) + ' WHERE Id IN :SObjectIds';
        for (SObject oObj : Database.query(query)){
            oObj.put('Related_Tasks_Count__c', 0); // See below [1] why we do that.
            mSObjects.put(oObj.Id, oObj);
        }
        System.debug('[AP_Task_01.updateRelatedSobjects] Related SObjects: ' + mSObjects.values());

        // Get the tasks related to these objects. (/!\ This must therefore be a post-insert task).
        List<AggregateResult> lCounts = [SELECT COUNT(Id) ntasks, WhatId, WhoId FROM Task WHERE (WhatId IN :SObjectIds) OR (WhoId IN :SObjectIds) GROUP BY WhoId, WhatId]; 
        System.debug('[AP_Task_01.updateRelatedSobjects] Counts: ' + lCounts);

        // Loop (lp) variables
        Id      lpWhatId; // WhatId
        Id      lpWhoId; // WhoId
        Integer lpValue; // The current value of the count (Here for safety).
        Integer lpCount; // Count in the AggregateResult
        SObject lpSObj;  // Corresponding object


        // For each count, update the related SOBject.
        for (AggregateResult ar : lCounts) {
            lpWhatId = (Id) ar.get('WhatId');
            lpWhoId  = (Id) ar.get('WhoId');
            lpCount  = (Integer) ar.get('ntasks');

            for (Id lpId : new List<Id>{lpWhatId, lpWhoId}){
                lpSObj = mSObjects.get(lpId);
                if (lpSObj <> null){
                    // We need to use a sum here because we could be in a situation where a single object is in several 
                    // AggregateResults. (For instance, we have a task on opty O with contact A, and on opty O with 
                    // contact B.
                    // See test testTwoContactsOneOpty.
                    lpValue = Integer.valueOf(lpSObj.get('Related_Tasks_Count__c'));
                    if (lpValue == null){ lpValue = 0; }
                    lpSObj.put('Related_Tasks_Count__c', lpValue + lpCount);
                }
            }
        }
        update mSObjects.values();
        System.debug('END method AP_Task_01.updateRelatedSobjects');
    }
    
    public static void updateRelatedTasksCount(List<Task> lTasks){
        // lTasks: the created / deleted / updated tasks
        // creation: are we creating or deleting a task? (shall we increment OR decrement?)
        System.debug('START method AP_Task_01.updateRelatedTasksCount');

        Set<Id> relatedIds = new Set<Id>(); // The IDs of the objects the tasks are related to.
        Map<Id, SObject> mIdToRelatedObjects = new Map<Id, SObject>(); // The objects themselves

        // Gather all the IDs before we get the objects
        // We could select separately Leads, etc. The Idea is to make the trigger evolvable (Just add a SELECT!)
        System.debug('[AP_Task_01.updateRelatedTasksCount] Gathering Related Object IDs.');
        for (Task oTask : lTasks){
            if (oTask.WhoId  <> null){ relatedIds.add(oTask.WhoId); }
            if (oTask.WhatId <> null){ relatedIds.add(oTask.WhatId); }
        }
        System.debug('[AP_Task_01.updateRelatedTasksCount] Related Object IDs: ' + relatedIds);


        for (String SObjectName : AP_Task_01.getTrackedObjects()){
            System.debug('[AP_Task_01.updateRelatedTasksCount] Updating related [' + SObjectName + 's]');
            AP_Task_01.updateRelatedSobjects(SObjectName, relatedIds);
        }
        System.debug('END method AP_Task_01.updateRelatedTasksCount');
    }
    
    
    // ELC 20150708 Update ActivityHistoryMinDate__c field on Case to get the oldest Task for this Case
    public static void updateActivityHistoryOnCase(List<Task> lTasks){
        
        List<Id> lCasesId = new List<Id>();
        List<Case> lCasesToUpdate = new List<Case>();
        
        System.debug(logginglevel.WARN,'### ELC: updateActivityHistoryOnCase lTasks.size() = ' + lTasks.size());
        for (Task oTask:lTasks){
            if (oTask.WhatId != null){
                System.debug(logginglevel.WARN,'### ELC: updateActivityHistoryOnCase oTask.Id.getSObjectType().getDescribe().getName() = ' + oTask.WhatId.getSObjectType().getDescribe().getName());
                // only for tasks related to cases
                if (oTask.WhatId.getSObjectType().getDescribe().getName()=='Case'){
                    // only for outgoing emails but exclude automatic emails identified by the username sophie.houlier@shell.com. We'll use the userId because the UserName is not visible in this context. This user Id won't change so no risk here. This is the base user of the org.
                    // 20200527 : also exclude manually sent confirmation emails that contain the string "a bien été prise en compte" in their subject
                    if (oTask.Type == 'Email' && oTask.OwnerId != '005D0000001bbcQIAQ' && !String.isBlank(oTask.Subject) && !oTask.Subject.contains('a bien été prise en compte')){
                        System.debug(logginglevel.WARN,'### ELC: oTask.WhatId = ' + oTask.WhatId);
                        lCasesId.add(oTask.WhatId);
                    }
                }
            }
        }
        
        List<AggregateResult> lTasksAggr = [SELECT WhatId, min(CreatedDate) minDate FROM Task WHERE WhatId IN :lCasesId AND OwnerId != '005D0000001bbcQIAQ' GROUP BY WhatId];
        
        for (AggregateResult oTaskAggr:lTasksAggr){
            if ((Id)oTaskAggr.get('WhatId') != null){
                lCasesToUpdate.add(new Case(
                    Id=(Id)oTaskAggr.get('WhatId'),
                    ActivityHistoryMinDate__c=(Datetime)oTaskAggr.get('minDate')
                ));
                
                System.debug(logginglevel.WARN,'### ELC: oTask.WhatId = ' + oTaskAggr.get('WhatId') + ' , CreatedDate = ' + (Datetime)oTaskAggr.get('minDate'));
            }
        }
        if (lCasesToUpdate.size()!=0){
            update lCasesToUpdate;
        }
        
    }
    
    
    // ELC 20191217 Update First_Call_DateTime__c field on Lead to get the first Call Task CreatedDateTime for this Lead
    public static void updateFirstCallOnLead(List<Task> lTasks){
        
        List<Id> lLeadsId = new List<Id>();
        List<Lead> lLeadsToUpdate = new List<Lead>();
        
        System.debug(logginglevel.WARN,'### ELC: updateFirstCallOnLead lTasks.size() = ' + lTasks.size());
        for (Task oTask:lTasks){
            if (oTask.WhoId != null){
                System.debug(logginglevel.WARN,'### ELC: updateFirstCallOnLead oTask.Id.getSObjectType().getDescribe().getName() = ' + oTask.WhoId.getSObjectType().getDescribe().getName());
                // only for tasks related to leads
                if (oTask.WhoId.getSObjectType().getDescribe().getName()=='Lead'){
                    // only for calls
                    if (oTask.Type == 'Call'){
                        System.debug(logginglevel.WARN,'### ELC: oTask.WhoId = ' + oTask.WhoId);
                        lLeadsId.add(oTask.WhoId);
                    }
                }
            }
        }
        
        Map<Id, Lead> mapLeadIdToCreatedDate = new Map<Id, Lead>([SELECT Id, CreatedDate FROM Lead WHERE Id IN :lLeadsId]);
        
        List<AggregateResult> lTasksAggr = [SELECT WhoId, min(CreatedDate) minDate FROM Task WHERE Type = 'Call' AND WhoId IN :lLeadsId GROUP BY WhoId];
        
        for (AggregateResult oTaskAggr:lTasksAggr){
            if ((Id)oTaskAggr.get('WhoId') != null){
                lLeadsToUpdate.add(new Lead(
                    Id=(Id)oTaskAggr.get('WhoId'),
                    First_Call_DateTime__c = (Datetime)oTaskAggr.get('minDate'),
                    Duration_Between_Creation_And_First_Call__c = DateUtilities.getGapInMinutes( mapLeadIdToCreatedDate.get( (Id)oTaskAggr.get('WhoId') ).CreatedDate, Datetime.valueOf(oTaskAggr.get('minDate')) )
                ));
                
                System.debug(logginglevel.WARN,'### ELC: oTask.WhoId = ' + oTaskAggr.get('WhoId') + ' , CreatedDate = ' + (Datetime)oTaskAggr.get('minDate'));
            }
        }
        if (lLeadsToUpdate.size()!=0){
            update lLeadsToUpdate;
        }
        
    }
    
}