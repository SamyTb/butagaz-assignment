trigger StockInventoryTrigger on Stock_Inventory__c (after insert, after update, after delete, after undelete) {

    System.Debug('##>>> StockInventoryTrigger : BEGIN <<< run by ' + UserInfo.getName());

    if (PAD.canTrigger('Stock_Inventory__c.recoverLastSIDate')){

        if(Trigger.isBefore){
            // Call Methods for Before Triggers
        }
        
        if(Trigger.isAfter){
            
            // Call After Insert methods
            if(Trigger.isInsert){
                AP_StockInventory_01.recoverLastSIDate(Trigger.new);
            }
            
            // Call After Update methods
            if(Trigger.isUpdate){
                if(!AP_StockInventory_01.hasAlreadyUpdatedSI()){
                    AP_StockInventory_01.setAlreadyUpdatedSI(true);
                    AP_StockInventory_01.recoverLastSIDate(Trigger.new);
                }
            }

            // Call After Delete methods
            if(Trigger.isDelete){
                AP_StockInventory_01.recoverLastSIDate(Trigger.old);
            }

            // Call After Undelete methods
            if(Trigger.isUndelete){
                AP_StockInventory_01.recoverLastSIDate(Trigger.new);
            }
        }
    
    }else{
        System.Debug('##>>> Stock_Inventory__c.AfterInsert : BYPASS recoverLastSIDate <<< run by ' + UserInfo.getName());
    }

}