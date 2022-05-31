trigger OrderTrigger on Order__c (after insert, after update, after delete, after undelete) {
    
    /* Moved to Apex batch Batch_PTL_Termination 
    Set<Id> ptlSet = new Set<Id>();
    List<Order__c> lOrderToUpdate = new List<Order__c>();
    
    
    if(Trigger.isDelete){
        for(Order__c oOrder:Trigger.Old) {
            if(oOrder.PTL__c != null) {
                ptlSet.add(oOrder.PTL__c);
            }
        }
    }else if(Trigger.isUpdate){
        for(Order__c oOrder:Trigger.New){
            if(oOrder.PTL__c != null) {
                ptlSet.add(oOrder.PTL__c);
            }
        }
        
        for(Order__c oOrder:Trigger.Old){
            if(oOrder.PTL__c != null) {
                ptlSet.add(oOrder.PTL__c);
            }
        }
    }else{
        for(Order__c oOrder:Trigger.New){
            if(oOrder.PTL__c != null) {
                ptlSet.add(oOrder.PTL__c);
            }
        }
    }
    
    if(ptlSet != null && !ptlSet.isEmpty()) {
        PTL_Termination_Mgr.updateLastTankRemovalDateOnPTL(ptlSet);
    }
    */
    
}