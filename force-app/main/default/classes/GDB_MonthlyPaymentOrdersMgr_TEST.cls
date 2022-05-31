@isTest
private class GDB_MonthlyPaymentOrdersMgr_TEST {
	
	@isTest
    static void createMonthlyPaymentOrder() {
        
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
        PraxedoSettings__c c2 = new PraxedoSettings__c (name='ExpirationDateNbDays', value__c = '21');
        PraxedoSettings__c c3 = new PraxedoSettings__c (name='PraxedoAccountToUse', value__c = 'ws_test_user');
        PraxedoSettings__c c4 = new PraxedoSettings__c (name='QualificationExpectedDuration', value__c = '60');
        PraxedoSettings__c c5 = new PraxedoSettings__c (name='QualificationType', value__c = 'LIV');
        PraxedoSettings__c c6 = new PraxedoSettings__c (name='StatusOnInsert', value__c = 'Entered');
        insert new List<PraxedoSettings__c> { c0, c1, c2, c3, c4, c5, c6 };
        
        GDB_TestDataFactory.createCustomSettings();
        //GDB_TestDataFactory.createActivityDomain();
        //Activity_Domain__c AD_GDB = new Activity_Domain__c(name = 'GDB - Granulés de bois', ExternalID__c = 50, Active__c = true);
		//insert new List<Activity_Domain__c> { AD_GDB };
		Activity_Domain__c AD_GDB = GDB_TestDataFactory.getActivityDomain();
        
        GDB_TestDataFactory.createArticles();
        GDB_TestDataFactory.createPromotion();
        
        //gdb_Warehouse__c whs = GDB_TestDataFactory.createAndGetWarehouses()[0];
        gdb_Warehouse__c whs = new gdb_Warehouse__c(
        	gdb_codes__c = 'Code1',
        	gdb_reference__c = 'GD12',
        	gdb_shipping_carrier__c = 'PRAXEDO'
        );
        insert whs;
        
        GDB_TestDataFactory.createPaymentMethod();
        GDB_TestDataFactory.createShippingMethod();
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = '999',
            Active__c = true,
            Electronic_Signature_Email__c = 'electronic.signature@butagaz.com'
        );
        insert mand1;
        
        Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
        insert Canton1;
        City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        // Create Account
        Account accGDB = new Account(
            FirstName = 'FName1',
            LastName = 'LName1',
            Market_Type__c = 'DOM',
            Activity_Domain__c = AD_GDB.Id,
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'VFCQLI01City@test.org',
            Mobile_Phone_Number__c = '0616060606',
            Country__c = 'FR',
            Indicatif_Pays__c = '+33',
            channel__c = 'CD',
            accountNumber='12345',
            Mandataire__c = mand1.Id,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
            gdb_shipping_zip__c = '75000',
            Phone = '0123456789'
        );
        insert new List<Account> { accGDB };
        
        // Create Order
        Order__c o = new Order__c();
    	o.Name = 'GDB_123456';
        o.Account__c = accGDB.Id;
        o.Activity_Domain__c = AD_GDB.Id;
        o.gdb_Discount__c = null;
        o.gdb_Payment_Method__c = GDB_TestDataFactory.getPaymentMethod().Id;
        o.gdb_Shipping_Method__c = GDB_TestDataFactory.getShippingMethod().Id;
        o.gdb_Warehouse__c = whs.Id;   // GDB_TestDataFactory.getWarehouseByReference('Dépôt_1').Id;
        o.Dispatching_point__c = whs.gdb_reference__c;
        // Addresses
        o.gdb_billing_salutation__c = 'M';
        o.gdb_billing_firstname__c = 'Test_1';
        o.gdb_billing_lastname__c = 'Test_1';
        o.gdb_billing_address1__c = '1 rue des planches';
        o.gdb_billing_address2__c = '';
        o.gdb_billing_address3__c = '';
        o.gdb_billing_city__c = 'MACON';
        o.gdb_billing_zip__c = '71000';
        o.gdb_billing_country__c = 'FRANCE';
        o.gdb_billing_phone__c = '0123456789';
        o.gdb_shipping_salutation__c = 'M';
        o.gdb_shipping_firstname__c = 'Test_1';
        o.gdb_shipping_lastname__c = 'Test_1';
        o.gdb_shipping_address1__c = '1 rue des planches';
        o.gdb_shipping_address2__c = '';
        o.gdb_shipping_address3__c = '';
        o.gdb_shipping_city__c = 'MACON';
        o.gdb_shipping_zip__c = '71000';
        o.gdb_shipping_country__c = 'FRANCE';
        o.gdb_shipping_phone__c = '0123456789';
        // Account details
        o.gdb_customer_title__c = 'M';
        o.gdb_customer_firstname__c = 'Test_1';
        o.gdb_customer_lastname__c = 'Test_1';
        o.gdb_email__c = 'test1@yopmail.com';
        // Attributes
        o.gdb_coupon_code__c = '';
        o.gdb_payment_method_name__c = GDB_TestDataFactory.getPaymentMethod().Name;
        o.gdb_shipping_method_name__c = GDB_TestDataFactory.getShippingMethod().Name;
        o.gdb_multiple_shipping__c = false;
        o.gdb_multiple_payment__c = false;
        o.gdb_shipping_instructions__c = '';
        o.gdb_warehouse_email__c = 'email.transporteur@yopmail.com';
        o.Order_Date_and_Time__c = DateTime.now();
        o.Order_Status__c = '3';
        // Initialize prices as 0 and bind them after if required
        o.gdb_shipping_price__c = 0;
        o.gdb_discount_price__c = 0;
        o.gdb_total_gross_price__c = 0;
        o.gdb_total_net_price__c = 0;
        o.gdb_total_tax__c = 0;
        o.gdb_isSample__c = false;

        o.Order_Status__c = '3';
        o.RecordTypeId = GDB_Constants.orderTypeId;
        o.gdb_isB2B__c = false;
        
        o.Order_Type__c = 'ZG02';
        
        insert o;
        
        
        // Retrieve article
        Item__c article_1 = [SELECT ID, Name, gdb_description__c FROM Item__c WHERE Name = 'article_1'];
        
        // Create Item In Order
        Item_in_Order__c oiio = new Item_in_Order__c(
			// Attributes
			gdb_name__c = article_1.Name,
			gdb_description__c = article_1.gdb_description__c,
			Unit__c = 'article_1',
			Quantity__c = 5,
			gdb_sku__c = 'GDB_P15_1',
			// Prices
			gdb_total_gross_price__c = 500,
			gdb_total_net_price__c = 450,
			gdb_total_tax__c = 50,
			gdb_unit_gross_price__c = 100,
			gdb_unit_net_price__c = 90,
			gdb_unit_tax__c = 10,
			
			Article__c = article_1.Id,
			Commande__c = o.Id
			//gdb_warehouse__c = whs.Id  // GDB_TestDataFactory.getWarehouseByReference('Dépôt_1').Id
		);
		insert oiio;
        
        
        //GDB_TestDataFactory.createOrder(null);
        //Order__c o = GDB_OrderMgr.getOrderByName('GDB_123456');
        //GDB_TestDataFactory.createItemsInOrderWithWarehouse(o, whs);
        
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
        
        
        Test.stopTest();
    }
	
}