trigger ItemInOrderAfterInsert on Item_in_Order__c (after insert) {
	
	
	if (Trigger.IsAfter && Trigger.IsInsert) {
		
		// Manage GDB commandes mensualisees coming from SAP
		if (PAD.canTrigger('Item_in_Order__c.updateMonthlyPaymentOrdersWithSAPData')) {
			GDB_MonthlyPaymentOrdersMgr.updateMonthlyPaymentOrdersWithSAPData(Trigger.new);
		} else {
            System.Debug('##>>> Item_in_Order__c.AfterInsert : BYPASS updateMonthlyPaymentOrdersWithSAPData <<< run by ' + UserInfo.getName());
        }
		
	}
	
}