@isTest
private class CreateWorkOrderAction_TEST {
    
    @isTest
    static void createWorkOrder() {
        
        // Create Praxedo user in settings
        PRAXEDO__MultiAccountsSettings__c multiAccSett = new PRAXEDO__MultiAccountsSettings__c(
            PRAXEDO__Username__c = 'ws_test_user',
            PRAXEDO__Password__c = 'Test',
            PRAXEDO__WebServiceURLEndpoint__c = 'Test'
        );
        insert multiAccSett;
        
        // Custom settings
        PraxedoSettings__c c0 = new PraxedoSettings__c (name='CreateWorkOrderOnOrder', value__c = 'true');
        PraxedoSettings__c c1 = new PraxedoSettings__c (name='EarliestDateNbDays', value__c = '7');
        PraxedoSettings__c c2 = new PraxedoSettings__c (name='ExpirationDateNbDays',value__c = '21');
        PraxedoSettings__c c3 = new PraxedoSettings__c (name='PraxedoAccountToUse',value__c = 'ws_test_user');
        PraxedoSettings__c c4 = new PraxedoSettings__c (name='QualificationExpectedDuration',value__c = '60');
        PraxedoSettings__c c5 = new PraxedoSettings__c (name='QualificationType',value__c = 'LIV');
        PraxedoSettings__c c6 = new PraxedoSettings__c (name='StatusOnInsert',value__c = 'Entered');
        insert new List<PraxedoSettings__c> { c0, c1, c2, c3, c4, c5, c6 };
        
        GDB_TestDataFactory.createCustomSettings();
        GDB_TestDataFactory.createActivityDomain();
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createPromotion();
        //GDB_TestDataFactory.createWarehouses();
        //List<gdb_Warehouse__c> listWhs = new list<gdb_Warehouse__c>();
        gdb_Warehouse__c whs = GDB_TestDataFactory.createAndGetWarehouses()[0];
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        GDB_TestDataFactory.createOrder(null);
        Order__c o = GDB_OrderMgr.getOrderByName('GDB_123456');
        //GDB_TestDataFactory.createItemsInOrder(o);
        GDB_TestDataFactory.createItemsInOrderWithWarehouse(o, whs);
        
        List<Id> orders = new List<Id>();
        orders.add(o.Id);
        
        Test.startTest();
        
        // Test WorkOrder creation
        CreateWorkOrderAction.createWorkOrders(orders);
        
        list<WorkOrder> lWO = [Select Id From WorkOrder where Order__c = :o.Id];
        system.assertEquals(1, lWO.size());
        
        
        
        // Test Order update on WorkOrder updated as shipped to cover UpdateOrderFromWorkOrderAction class
        lWO[0].Livraison_effectuee__c = 'on';
        lWO[0].Statut_de_livraison__c = 'Livraison Totale';
        lWO[0].PRAXEDO__PDAUnloadingDate__c = DateTime.now();
        lWO[0].PRAXEDO__ValidationDate__c = DateTime.now();
        lWO[0].PRAXEDO__PlanificationAppointmentHour__c = DateTime.now();
        update lWO;
        
        // Explicitly call the method because the Process is not executed during deployment to production
        list<Id> lShippedWOIds = new list<Id>();
        lShippedWOIds.add(lWO[0].Id); 
        UpdateOrderFromWorkOrderAction.updateOrdersFromWorkOrders(lShippedWOIds);
        
        // Requery the order to check the updated values
        o = GDB_OrderMgr.getOrderByName('GDB_123456');
        system.assertEquals('7', o.Order_Status__c);
        system.assertEquals('Shipped', o.gdb_shipping_status__c);
        system.assertNotEquals(null, o.gdb_shipping_date__c);
        //system.assertNotEquals(null, o.gdb_validation_date__c);
        
        /*// Test Order update on WorkOrder updated as partially shipped
        lWO[0].Livraison_effectuee__c = 'on';
        lWO[0].Statut_de_livraison__c = 'Livraison Partielle';
        update lWO;
        
        // Explicitly call the method because the Process is not executed during deployment to production
        list<Id> lPartiallyShippedWOIds = new list<Id>();
        lPartiallyShippedWOIds.add(lWO[0].Id); 
        UpdateOrderFromWorkOrderAction.updateOrdersFromWorkOrders(lPartiallyShippedWOIds);
        
        // Requery the order to check the updated values
        o = GDB_OrderMgr.getOrderByName('GDB_123456');
        system.assertEquals('7', o.Order_Status__c);
        system.assertEquals('Partially Shipped', o.gdb_shipping_status__c);
        system.assertNotEquals(null, o.gdb_shipping_date__c);
        system.assertNotEquals(null, o.gdb_validation_date__c);*/
        
        Test.stopTest();
    }
}