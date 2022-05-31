trigger EquipmentTrigger on Equipement__c (after insert, after update, after delete, after undelete) {
    
    /* Moved to Apex batch Batch_PTL_Termination 
    Set<Id> ptlSet = new Set<Id>();
    
    if(Trigger.isDelete){
        for(Equipement__c equip:Trigger.Old) {
            if(equip.PTL__c != null) {
                ptlSet.add(equip.PTL__c);
            }
        }
    }else if(Trigger.isUpdate){
        for(Equipement__c equip:Trigger.New){
            if(equip.PTL__c != null) {
                ptlSet.add(equip.PTL__c);
            }
        }
        
        for(Equipement__c equip:Trigger.Old){
            if(equip.PTL__c != null) {
                ptlSet.add(equip.PTL__c);
            }
        }
    }else{
        for(Equipement__c equip:Trigger.New){
            if(equip.PTL__c != null) {
                ptlSet.add(equip.PTL__c);
            }
        }
    }
    
    if(ptlSet != null && !ptlSet.isEmpty()) {
        PTL_Termination_Mgr.updateTankCountOnPTL(ptlSet);
    }
    */  
    
}