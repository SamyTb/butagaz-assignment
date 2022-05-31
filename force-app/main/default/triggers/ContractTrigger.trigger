trigger ContractTrigger on Contract (after insert, after update, after delete, after undelete) {
    
    /* Moved to Apex batch Batch_PTL_Termination 
    Set<Id> ptlSet = new Set<Id>();
    
    if(Trigger.isDelete){
        for(Contract ctr:Trigger.Old) {
            if(ctr.PTL__c != null) {
                ptlSet.add(ctr.PTL__c);
            }
        }
    }else if(Trigger.isUpdate){
        for(Contract ctr:Trigger.New){
            if(ctr.PTL__c != null) {
                ptlSet.add(ctr.PTL__c);
            }
        }
        
        for(Contract ctr:Trigger.Old){
            if(ctr.PTL__c != null) {
                ptlSet.add(ctr.PTL__c);
            }
        }
    }else{
        for(Contract ctr:Trigger.New){
            if(ctr.PTL__c != null) {
                ptlSet.add(ctr.PTL__c);
            }
        }
    }
    
    if(ptlSet != null && !ptlSet.isEmpty()) {
        PTL_Termination_Mgr.updateOpenContractsCountOnPTL(ptlSet);
    }
    */
    
}