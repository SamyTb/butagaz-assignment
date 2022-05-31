public class AP_Assignment_RFF_01{
    public static void lookupTarget(List<Rep_For_Filter__c> lRFFs){
        //First, validate that we have proper items (IDs ARE Ids, and so on)
        List<Rep_For_Filter__c> lValidRFFs = new List<Rep_For_Filter__c>();
        for (Rep_For_Filter__c oRFF : lRFFs){
            // Check for valid QueueId
            try {
                oRFF.QueueId__c = (Id) oRFF.QueueId__c;
            } catch (System.StringException e){
                oRFF.addError(System.Label.Error_InvalidQueueID + ' ' + oRFF.QueueID__c);
                continue; 
            }
            
            lValidRFFs.add(oRFF);
        }


        // Now, let's lookup what we need to query!
        Set<Id> queueIds = new Set<Id>();
        Set<Id> userIds  = new Set<Id>();
        for (Rep_For_Filter__c oRFF : lValidRFFs){
            // Add the to the Queues
            if (oRFF.Target__c == 'Queue' ) {queueIds.add(oRFF.QueueId__c);}
            if (oRFF.Target__c == 'User'  ) {userIds.add(oRFF.User__c);}
            if ((oRFF.Target__c <> 'Queue') && (oRFF.Target__c <> 'User')){
                oRFF.addError(System.Label.Error_InvalidTarget + ' ' + oRFF.Target__c);
            }
        }

        // Let's the retrieve the objects now!
        Map<Id, Group> queueNames = new Map<Id, Group> ([SELECT Id, Name FROM Group WHERE Id IN :queueIds]);
        Map<Id, User>  userNames  = new Map<Id, User>  ([SELECT Id, Name FROM User  WHERE Id IN :userIds]);

        System.debug('Queues:' + queueNames);
        System.debug('Users:'  + userNames);

        Group loopQueue;
        User loopUser;

        for (Rep_For_Filter__c oRFF : lValidRFFs){
            System.debug('oRFF:' + oRFF);
            loopQueue = null; loopUser = null; // We won't be using both at the same time!
            if (oRFF.Target__c == 'Queue') {
                loopQueue = queueNames.get(oRFF.QueueId__c);
                if (loopQueue <> null){
                    oRFF.TargetName__c = loopQueue.Name;
                } else {
                    oRFF.addError(System.Label.Error_NoQueue + ' ' + oRFF.QueueId__c);
                }
            } 
            if (oRFF.Target__c == 'User')  { 
                loopUser = userNames.get(oRFF.User__c);
                if (loopUser <> null){
                    oRFF.TargetName__c = loopUser.Name;
                } else {
                    oRFF.addError(System.Label.Error_NoUser + ' ' + oRFF.User__c);
                }
            }
        }
    }
}