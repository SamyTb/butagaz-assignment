@isTest(seeAllData=true)
public class VFC01_OrderTaking_Simulation_Test{

    public static testmethod void InvalidURLTest(){
        // Test when we use a Contract ID an it's not an ID.
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract('0123456789');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assertEquals(System.Label.invalid_url, simulationController.lastException.getMessage());
        }
        Test.stopTest();
    }

    public static testmethod void initIDsTest(){
        // Test that you need at least one ID for the page to open.
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            PageReference p = new PageReference('/apex/VFP01_OrderTaking_Simulation_Step1');
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(new Order__c());
            VFC01_OrderTaking_Simulation simulationController = new VFC01_OrderTaking_Simulation(std);
            System.assertEquals(System.Label.crm_message+ ' : ' + System.Label.error_access_page, simulationController.lastException.getMessage());
        }
        Test.StopTest();
    }

    public static testmethod void InvalidURLTest_InvalidIDOrder(){
        // Test when we use a Order ID and it's not an ID SFDC
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder('0123456789');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assert(simulationController.lastException.getMessage().contains(System.Label.invalid_url));
        }
        Test.stopTest();
    }

    public static testmethod void InvalidURLTest_InvalidIDContract(){
        // Test when we use a Contract ID an it's not an ID.
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract('0123456789');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assert(simulationController.lastException.getMessage().contains(System.Label.invalid_url));
        }
        Test.stopTest();
    }

    /* testInitIDS: Test InitIds method*/

    public static testmethod void initIDsTest_IDContract_And_IDOrder_Fail(){
        //Testing the case of idcontract = null and idorder = null
        PageReference p = new PageReference('/apex/VFP01_OrderTaking_Simulation_Step1');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assert(simulationController.lastException.getMessage().contains(System.Label.error_access_page));
        }
        Test.stopTest();
    }

    public static testmethod void initIDsTest_IDContract_Fail(){
        //Testing the case of valid idcontract (case of creation of a new order)
        String idcontract = '800M00000009xlI'; // 15 digit
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(idcontract);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assertEquals(simulationController.creation, simulationController.typeOperation);
        }
        Test.stopTest();
    }

    public static testmethod void initIDsTest_IDOrder_Fail(){
        //Testing the case of valid idorder
        String idorder= 'a0QM0000001IdQH'; // 15 digit
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(idorder);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assertEquals(simulationController.modification, simulationController.typeOperation);
        }
        Test.stopTest();
    }

    public static testmethod void ValidOrderIWithNoContractTest(){
        //Testing the case of valid idorder (case of update of existing order ) with no contract found on the order
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount(); 
        Order__c orderWithNoContract = new Order__c(Account__c=oAccount.Id);
        insert orderWithNoContract;
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            PageReference p = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(''+orderWithNoContract.id);
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(p);
            System.assertNotEquals(null, simulationController.getIdOrder(), 'lol');
            System.assertEquals(null, simulationController.getIdContract());
            System.assertEquals(simulationController.modification, simulationController.typeOperation);
            System.assert(simulationController.lastException.getMessage().contains(System.Label.contract_not_found_for_order));
        }
        Test.stopTest();
    }

    /* testInitContract_*: Test Contract initialization (initContract) */

    public static testmethod void testInitContract_IdOK(){
        // Test with a proper contract ID
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation ctrlOK = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(ctrlOK.getContract().Id, ct.Id);
        }
        Test.stopTest();
    }

    public static testmethod void testInitContract_IdKO(){
        // Test with an invalid contract ID (it's an *Account* ID).
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.AccountId); // Hackish.

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assertEquals(null, ctrlKO.getContract());
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.contract_not_found));
        }
        Test.stopTest();
    }

    /* testCheckContract_* : Test the checkContract method */

    public static testmethod void testCheckContract_OK(){
        // Test with a contract + product + PTL
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation ctrlOK = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(null, ctrlOK.lastException);
        }
        Test.stopTest();
    }

    public static testmethod void testCheckContract_KO_NoProduct(){
        // Test with a contract + PTL without product.
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.contract_musthave_product));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckContract_KO_NoPTL(){
        // Test with a contract + product but no PTL
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        oContract.Product__c = oItem.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.contract_musthave_ptl));
        }
        Test.stopTest();
    }

    /* testCheckCurrentUserPermissions_* : test the checkCurrentUserPermissions method */

    public static testmethod void testCheckCurrentUserPermissions_OK(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation ctrlOK = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(null, ctrlOK.lastException);
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_NoPerm(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= 'UUUUU';
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_InvalidPerm(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= 'UUUUU';
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_NoPTLDelCode(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= null;
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.delivery_code_not_found_on_ptl));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_NoUserMandataire(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();
        //u.mandataire__c = null; 
        // Gestion multi-plaques
        u.User_Mandataires__c = null;
        System.runAs(new User(Id = UserInfo.getUserId())){ update u; }

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.no_mandataire_found_on_user));
        }
        Test.stopTest();
    }

    /* testCheckDeliveryDatesWithNow_* : Test the checkDeliveryDatesWithNow method */

    public static testmethod Order__c testCheckDeliveryDatesWithNow_Setup(){
        // Insert an Order with all OK.
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();  
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c oOrder = new Order__c(Account__c=oAccount.Id,Name = 'TestOrder', Contract__c = oContract.Id);
        insert oOrder;

        // Add an article to the Order. Need to add it or it will stack in case of OK!
        Item_In_Order__c oItemInOrder = new Item_In_Order__c(Article__c = oItem.Id, Commande__c = oOrder.Id);
        insert oItemInOrder;

        return oOrder;
    }

    public static testmethod void testCheckDeliveryDatesWithNow_OK(){
        Order__c oOrder = VFC01_OrderTaking_Simulation_Test.testCheckDeliveryDatesWithNow_Setup();
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation ctrlOK = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(null, ctrlOK.lastException);
        }
        Test.stopTest();
    }

    /**public static testmethod void testCheckDeliveryDatesWithNow_KO_Earliest(){
        Order__c oOrder = VFC01_OrderTaking_Simulation_Test.testCheckDeliveryDatesWithNow_Setup();
        oOrder.Earliest_Delivery_Date__c = datetime.now().date();
        oOrder.Earliest_Delivery_Date__c.addDays(-1);
        update oOrder;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.update_order_delivered));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckDeliveryDatesWithNow_KO_Latest(){
        Order__c oOrder = VFC01_OrderTaking_Simulation_Test.testCheckDeliveryDatesWithNow_Setup();
        oOrder.Latest_Delivery_Date__c = datetime.now().date();
        oOrder.Latest_Delivery_Date__c.addDays(-1);
        update oOrder;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.update_order_delivered));
        }
        Test.stopTest();
    }**/

    /* testInitExistingItemInOrder : Test the initExistingItemInOrder method */

    public static testmethod Order__c testInitExistingItemInOrder_Setup(){
        // Insert an Order with all OK.
		Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount(); 		
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c oOrder = new Order__c(Account__c=oAccount.Id,Name = 'TestOrder', Contract__c = oContract.Id);
        insert oOrder;

        return oOrder;
    }

    public static testmethod void testInitExistingItemInOrder_OK(){
        Order__c oOrder = VFC01_OrderTaking_Simulation_Test.testInitExistingItemInOrder_Setup();
        update oOrder;

        Item__c oItem = VFC01_OrderTaking_TestUtilities.getItem();
        Item_In_Order__c oItemInOrder = new Item_In_Order__c(Article__c = oItem.Id, Commande__c = oOrder.Id);
        insert oItemInOrder;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation ctrlOK = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(null, ctrlOK.lastException);
            System.assertEquals(oItemInOrder.Id, ctrlOK.getItemInOrder().Id);
        }
        Test.stopTest();
    }

    public static testmethod void testInitExistingItemInOrder_KO(){
        Order__c oOrder = VFC01_OrderTaking_Simulation_Test.testInitExistingItemInOrder_Setup();
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Simulation ctrlKO = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.article_not_found_for_order));
            System.assertEquals(null, ctrlKO.getItemInOrder());
        }
        Test.stopTest();
    }

    public static testmethod void testCreationInitBeforeCallingSAP(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        Mandataire__c mandataire = new Mandataire__c(Name='TestMandaire');
        insert mandataire;
        ct.Mandataire__c = mandataire.id;
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        Activity_Domain__c act = new Activity_Domain__c(Name='TestActivity');
        insert act;
        ptl.Activity_Domain__c = act.id;
        update ptl;
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            System.assertEquals(null, simulationController.lastException);
            System.assertEquals(simulationController.creation, simulationController.typeOperation);
            System.assertEquals(System.Label.creation_new_order, simulationController.VpageTitle);
            System.assertNotEquals(null, simulationController.getOrder());
            System.assertEquals(ct.Id, simulationController.getOrder().Contract__c);
            System.assertEquals(ct.AccountId, simulationController.getOrder().Account__c);
            System.assertEquals(ct.PTL__c, simulationController.getOrder().PTL__c);
            System.assertEquals(ct.Mandataire__c, simulationController.getOrder().Mandataire__c);
            System.assertEquals(act.Id, simulationController.getOrder().Activity_Domain__c);
            System.assertEquals(ptl.Code_division__c, simulationController.getOrder().Dispatching_point__c);
        }
        Test.stopTest();
    }
    
    public static testmethod void testClearData(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            simulationController.VchangeFrom = 'quantity';
            simulationController.quantity = '';
            simulationController.clearData();
            System.assertEquals(null, simulationController.quantity);
            System.assertEquals(null, simulationController.amount);        
            System.assertNotEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            simulationController.quantity = '20';
            simulationController.clearData();
            System.assertEquals('20', simulationController.quantity);
            System.assertEquals(null, simulationController.amount);
            System.assertNotEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            
            simulationController.VchangeFrom = 'amount';
            simulationController.amount = '';
            simulationController.clearData();
            System.assertEquals(null, simulationController.quantity);
            System.assertEquals(null, simulationController.amount);        
            System.assertNotEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            simulationController.amount = '30';
            simulationController.clearData();
            System.assertEquals('30', simulationController.amount);
            System.assertEquals(null, simulationController.quantity);
            System.assertNotEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            
            simulationController.VchangeFrom = 'gauge';
            simulationController.getOrder().Meter_Before_Delivery__c = '';
            simulationController.clearData();
            System.assertEquals(null, simulationController.quantity);
            System.assertEquals(null, simulationController.amount);        
            System.assertEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            simulationController.getOrder().Meter_Before_Delivery__c = '40';
            simulationController.clearData();
            System.assertEquals('40', simulationController.getOrder().Meter_Before_Delivery__c);
            System.assertEquals(null, simulationController.amount);
            System.assertEquals(null, simulationController.quantity);
            
            System.assertEquals(simulationController.errorGotFromSAPDuringSimulation, simulationController.VcontinueButtonVisible);
            System.assertEquals(true, simulationController.VsimulateButtonVisible);
            System.assertEquals(System.Label.message_simulation_progress, simulationController.VmessageInfo);
            System.assertEquals(true, simulationController.datesLivraisonProposed.isEmpty());
            
        }
        Test.stopTest();
    }
    
    public static testmethod void testCheckAmount(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            simulationController.checkAmount('');
            System.assertEquals(null, simulationController.amount);
            
            simulationController.checkAmount('20');
            System.assertEquals(null, simulationController.lastException);
            
            Boolean exceptionThrown = false;
            try {
                simulationController.checkAmount('invalidNum39');
            }catch(CRMException e){
                exceptionThrown = true;
                System.assert(e.getMessage().contains(System.Label.invalid_amount_message));
            }
            System.assertEquals(true, exceptionThrown);
        }
        Test.stopTest();
        
    }
    
    public static testmethod void testCheckQuantity(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            simulationController.checkQuantity('');
            System.assertEquals(null, simulationController.quantity);
            
            simulationController.checkQuantity('20');
            System.assertEquals(null, simulationController.lastException);
            
            Boolean exceptionThrown = false;
            try {
                simulationController.checkQuantity('invalidNum39');
            }catch(CRMException e){
                exceptionThrown = true;
                System.assert(e.getMessage().contains(System.Label.invalid_quantity_message));
            }
            System.assertEquals(true, exceptionThrown);
        }
        Test.stopTest();
    }
    
    public static testmethod void testCheckGauge(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions(); 
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);        
            simulationController.checkGauge('');
            System.assertEquals(null, simulationController.getOrder().Meter_Before_Delivery__c);
            
            simulationController.checkGauge('20');
            System.assertEquals(null, simulationController.lastException);
            
            Boolean exceptionThrown = false;
            try {
                simulationController.checkGauge('invalidNum39');
            }catch(CRMException e){
                exceptionThrown = true;
                System.assert(e.getMessage().contains(System.Label.invalid_gauge_message));
            }
            System.assertEquals(true, exceptionThrown);
        }
        Test.stopTest();
    }
    
    /* testSimulateButton: check the Simulate Button */

    public static testmethod void testSimulateButton_Create(){
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        PageReference page = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(oContract.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(page);
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(page);

            // Test OK.
            ctrl.amount   = '10.0';
            ctrl.quantity = '10.0';
            ctrl.simulateButt();
            System.assertEquals(null, ctrl.lastException);
            System.assertNotEquals(null, ctrl.dataForController);
            System.assertNotEquals(null, ctrl.getFirstDateLivraisonProposed());

            // Test KO
            ctrl.amount   = 'HU?';
            ctrl.quantity = '10.0';
            ctrl.simulateButt();
            System.assertNotEquals(null, ctrl.lastException);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_amount_message));

            // Test KO
            ctrl.amount   = '10.0';
            ctrl.quantity = 'HU?';
            ctrl.simulateButt();
            System.assertNotEquals(null, ctrl.lastException);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_quantity_message));
        }
        Test.stopTest();
    }

    public static testmethod void testSimulateButton_Update(){
		Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();    	
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c oOrder = new Order__c(Account__c=oAccount.Id,Name = 'TestOrder', Contract__c = oContract.Id);
        insert oOrder;
        Item_In_Order__c oItemInOrder = new Item_In_Order__c(Article__c = oItem.Id, Commande__c = oOrder.Id);
        insert oItemInOrder;

        PageReference page = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(oOrder.Id);

        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(page);
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(page);

            ctrl.amount   = '10.0';
            ctrl.quantity = '10.0';
            ctrl.simulateButt();
            System.assertEquals(null, ctrl.lastException);
            System.assertNotEquals(null, ctrl.dataForController);

            // Test KO
            ctrl.amount   = 'HU?';
            ctrl.quantity = '10.0';
            ctrl.simulateButt();
            System.assertNotEquals(null, ctrl.lastException);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_amount_message));

            // Test KO
            ctrl.amount   = '10.0';
            ctrl.quantity = 'HU?';
            ctrl.simulateButt();
            System.assertNotEquals(null, ctrl.lastException);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_quantity_message));
        }
        Test.stopTest();
    }

    /* testCancelButton: check the Cancel Butt */

    public static testmethod void testCancelButt(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions(); 
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            PageReference contractPage = simulationController.cancelButt();            
            System.assertEquals((new PageReference('/'+ simulationController.getIdcontract())).getUrl(), contractPage.getUrl());
        }
        Test.stopTest();
    }

    /* testContinueButton: check the Continue Button */

    public static testmethod void testContinueButton(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions(); 
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            PageReference detailsStep = simulationController.continueButt();
            System.assertEquals(true, simulationController.VsimulationStepDone);
            System.assertNotEquals(null, simulationController.getOrder().Order_Date_and_Time__c);
            System.assertEquals((Page.VFP01_OrderTaking_Details_Step2).getUrl(), detailsStep.getUrl());
        }
        Test.stopTest();
    }

    /* testGetLastBreakDate: check the getLastBreakDate method */

    public static testmethod void testGetLastBreakDate(){
        Contract ct = VFC01_OrderTaking_TestUtilities.getContract();
        ct.Product__c = VFC01_OrderTaking_TestUtilities.getItem().id;
        PTL__c ptl = VFC01_OrderTaking_TestUtilities.getPTL();
        ct.PTL__c = ptl.id;
        update ct;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(ct.Id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            VFC01_OrderTaking_TestUtilities.makePermissions(); 
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Simulation simulationController = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            simulationController.setLastBreakDate(null);
            System.assertEquals(null, simulationController.getLastBreakDate());
            Date lastBreakDate = date.parse('10/12/2012');
            simulationController.setLastBreakDate(lastBreakDate);
            System.assertEquals(lastBreakDate.format(), simulationController.getLastBreakDate());
        }
        Test.stopTest();
    }
}