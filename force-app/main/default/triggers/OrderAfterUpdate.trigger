trigger OrderAfterUpdate on Order__c (after update) {
	if (Trigger.IsAfter && Trigger.IsUpdate)
    {
        Map<Id, GDB_Shipping_Method__c> shippingMethodsToUpdate = new Map<Id, GDB_Shipping_Method__c>();
        
        Set<Id> idsOfRelatedShippingMethods = new Set<Id>();
        
        for(Order__c newOrder : Trigger.New)
        {
            idsOfRelatedShippingMethods.add(newOrder.gdb_Shipping_Method__c);
        }
        
        Map<Id, GDB_Shipping_Method__c> relatedShippingMethodsWithNumberOfRemainingUse = new Map<Id, GDB_Shipping_Method__c>
       	(
            [
                SELECT 	gdb_number_of_remaining_use__c 
                FROM 	GDB_Shipping_Method__c 
                WHERE 	Id in :idsOfRelatedShippingMethods 
                AND 	gdb_number_of_remaining_use__c != null
            ]
        );
        
        Map<Id, Order__c> oldOrders = new Map<Id, Order__c>(Trigger.Old);
        
        Set<String> initialOrderStatuses = new Set<String>();
        
        initialOrderStatuses.add('4'); 	// Enregistrée
        initialOrderStatuses.add('6'); 	// Expédiée
        initialOrderStatuses.add('7'); 	// Livrée
        initialOrderStatuses.add('8'); 	// A Répartir
        initialOrderStatuses.add('9'); 	// A Répartir - Fille
        initialOrderStatuses.add('10'); // Suspicion de fraude
        
        for(Order__c newOrder : Trigger.New)
        {
            Order__c oldOrder = oldOrders.get(newOrder.Id);
            GDB_Shipping_Method__c relatedShippingMethod = relatedShippingMethodsWithNumberOfRemainingUse.get(newOrder.gdb_Shipping_Method__c);
            
            // If the order status changed from a specific initial status to cancelled and the related shipping method has a number of remaining use defined
            if(initialOrderStatuses.contains(oldOrder.Order_Status__c) && (newOrder.Order_Status__c == '11' || newOrder.Order_Status__c == '5') && relatedShippingMethod != null)
            {
                // The number of remaining use is incremented
                relatedShippingMethod.gdb_number_of_remaining_use__c = relatedShippingMethod.gdb_number_of_remaining_use__c + 1;
                
                if(!shippingMethodsToUpdate.containsKey(relatedShippingMethod.Id))
                {
                    shippingMethodsToUpdate.put(relatedShippingMethod.Id, relatedShippingMethod);
                }
            }
        }
        
        if(shippingMethodsToUpdate.size() > 0)
        {
            update shippingMethodsToUpdate.values();
        }
    }
    else
    {
        System.Debug('##>>> Order__c.AfterUpdate : FALSE TRIGGER <<<');
    }
}