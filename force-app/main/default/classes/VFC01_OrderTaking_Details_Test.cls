@isTest(seeAllData=true)
public class VFC01_OrderTaking_Details_Test{
   
    /** test case of creation : upsertCreationOrUpdate method **/
    public static testmethod void testUpsertCreationOrUpdate_creation_case(){
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
            ctrl.detailsController.upsertCreationOrUpdate();
            System.assertEquals(ctrl.creation,ctrl.typeOperation);
            System.assertNotEquals(null, ctrl.dataForController);      
        }
        Test.stopTest();
    }
    
    /** test case of update : upsertCreationOrUpdate method **/
    public static testmethod void testUpsertCreationOrUpdate_update_case(){
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
            ctrl.detailsController.upsertCreationOrUpdate();
            System.assertEquals(ctrl.modification,ctrl.typeOperation);
            System.assertNotEquals(null, ctrl.dataForController); 
        }
        Test.stopTest();
    }   

    /** test : finishInitOfOrder method **/
    public static testmethod void testFinishInitOfOrder(){
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
            ctrl.detailsController.upsertCreationOrUpdate();
            System.assertNotEquals(null, ctrl.dataForController);
            ctrl.dataForController.orderNumber = 'DUMMYNUMBER';
            ctrl.detailsController.finishInitOfOrder();
            System.assertEquals('DUMMYNUMBER', ctrl.getOrder().Name);
            System.assertEquals('DUMMYNUMBER', ctrl.getOrder().ExternalID__c);               
        }
        Test.stopTest();
    }
    
    /** test : finishInitOfItemInOrder method **/
    public static testmethod void testFinishInitOfItemInOrder(){
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
            ctrl.detailsController.upsertCreationOrUpdate();
            System.assertNotEquals(null, ctrl.dataForController);
            ctrl.detailsController.finishInitOfItemInOrder();
            System.assertEquals(ctrl.getContract().Product__c, ctrl.getItemInOrder().Article__c);
            System.assertEquals(ctrl.getOrder().id, ctrl.getItemInOrder().Commande__c);
            ctrl.quantity = '100';
            ctrl.quantity_uom = 'TO';
            System.assertEquals(Decimal.valueOf(100), ctrl.getItemInOrder().Quantity__c);
            System.assertEquals('TO', ctrl.getItemInOrder().Unit__c);            
        }
        Test.stopTest();
    }
    
     /** test : retourButt method **/
    public static testmethod void testRetourButton(){
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
            
            PageReference simulationStep = simulationController.detailsController.retourButt();
            System.assertEquals(false, simulationController.VsimulationStepDone);
            System.assertEquals((Page.VFP01_OrderTaking_Simulation_Step1).getUrl(), simulationStep.getUrl());
        }
        Test.stopTest();
    }
    
    /** test : terminerButt method **/
    public static testmethod void testTerminerButton(){
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
            
            PageReference orderPage = simulationController.detailsController.terminerButt();
            System.assertEquals((new ApexPages.StandardController(simulationController.getOrder())).view().getUrl(), orderPage.getUrl());
            
            simulationController.setOrder(null);
            orderPage = simulationController.detailsController.terminerButt();
            System.assertEquals(null, orderPage);
            
        }
        Test.stopTest();
    }
    
    /** test : getOrderOriginOptions method **/
    public static testmethod void testgetOrderOriginOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            List<selectOption> type = ctrl.detailsController.getOrderOriginOptions();
            System.assertEquals(AP_MappingOptions.orderOriginMap.size(), type.size());
            for(SelectOption s : type){
                System.assertEquals(AP_MappingOptions.orderOriginMap.get(s.getValue()),s.getLabel());
            }
        }    
        Test.stopTest();
    }

    /** test : getRappelClientOptions method **/
    public static testmethod void testgetRappelClientOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            List<selectOption> type = ctrl.detailsController.getRappelClientOptions();
            System.assertEquals(AP_MappingOptions.custCallMap.size(), type.size());
            for(SelectOption s : type){
                System.assertEquals(AP_MappingOptions.custCallMap.get(s.getValue()),s.getLabel());
            }
        }    
        Test.stopTest();
    }

    /** test : getPeriodeOptions method **/
    public static testmethod void testgetPeriodeOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            List<selectOption> type = ctrl.detailsController.getPeriodeOptions();
            System.assertEquals(AP_MappingOptions.momentMap.size(), type.size());
            for(SelectOption s : type){
                System.assertEquals(AP_MappingOptions.momentMap.get(s.getValue()),s.getLabel());
            }
        }    
        Test.stopTest();
    }

    /** test : getModeContactOptions method **/
    public static testmethod void testgetModeContactOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            List<selectOption> type = ctrl.detailsController.getModeContactOptions();
            System.assertEquals(AP_MappingOptions.medContactMap.size(), type.size());
            for(SelectOption s : type){
                System.assertEquals(AP_MappingOptions.medContactMap.get(s.getValue()),s.getLabel());
            }
        }    
        Test.stopTest();
    }

    /** test : getgetRaisonReportOptions method **/
    public static testmethod void testgetRaisonReportOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);            
            List<selectOption> type = ctrl.detailsController.getRaisonReportOptions();
            System.assertEquals(AP_MappingOptions.reasonDelayMap.size(), type.size());
            for(SelectOption s : type){
                System.assertEquals(AP_MappingOptions.reasonDelayMap.get(s.getValue()),s.getLabel());
            }
        }    
        Test.stopTest();
    }

    /** test : getPrettyPrintOrderOrigin method **/
    public static testmethod void testgetPrettyPrintOrderOrigin(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            ctrl.detailsController.orderOrigin = 'SCHR';
            System.assertEquals(AP_MappingOptions.orderOriginMap.get('SCHR'), ctrl.detailsController.getPrettyPrintOrderOrigin());
        }
        Test.stopTest();
    }

    /** test : getPrettyPrintCustCall method **/
    public static testmethod void testgetPrettyPrintCustCall(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            ctrl.detailsController.rappelClient = '1';
            System.assertEquals(AP_MappingOptions.custCallMap.get('1'), ctrl.detailsController.getPrettyPrintCustCall());
        }
        Test.stopTest();
    }

    /** test : getPrettyPrintMoment method **/
    public static testmethod void testgetPrettyPrintMoment(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            ctrl.detailsController.periode = 'MATIN';
            System.assertEquals(AP_MappingOptions.momentMap.get('MATIN'), ctrl.detailsController.getPrettyPrintMoment());
        }
        Test.stopTest();
    }

    /** test : getPrettyPrintMedContact method **/
    public static testmethod void testgetPrettyPrintMedContact(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            ctrl.detailsController.modeContact = '01';
            System.assertEquals(AP_MappingOptions.medContactMap.get('01'), ctrl.detailsController.getPrettyPrintMedContact());
        }
        Test.stopTest();
    }

    /** test : getPrettyPrintReasonDelay method **/
    public static testmethod void testgetPrettyPrintReasonDelay(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            ctrl.detailsController.raisonReport = 'B';
            System.assertEquals(AP_MappingOptions.reasonDelayMap.get('B'), ctrl.detailsController.getPrettyPrintReasonDelay());
        }
        Test.stopTest();
    }
    
    /** test : getDatesLivraisonEarliestProposedOptions method **/
    public static testmethod void testgetDatesLivraisonEarliestProposedOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            List<DateWithStatusSAP> l = new List<DateWithStatusSAP>();
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 23), 'green'));
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 24), 'red'));
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 25), 'orange'));
            ctrl.setDatesLivraisonProposed(l);
            List<selectOption> type = ctrl.detailsController.getDatesLivraisonEarliestProposedOptions();
            System.assertEquals('AUCUN', type.get(0).getValue());
            for(Integer i=1; i<= type.size()-2; i++){
                    if(!type.get(i).getDisabled()){
                        System.assert(type.get(i).getLabel().contains('green'));
                    }else{
                        System.assert((type.get(i).getLabel().contains('red') || type.get(i).getLabel().contains('orange')));
                    }
                    System.assertEquals(false, type.get(i).getEscapeItem());
            }
            System.assertEquals('AUTRES', type.get(type.size()-1).getValue());
        }
        Test.stopTest();
    }

    /** test : getDatesLivraisonLatestProposedOptions method **/
    public static testmethod void testgetDatesLivraisonLatestProposedOptions(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            List<DateWithStatusSAP> l = new List<DateWithStatusSAP>();
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 23), 'green'));
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 24), 'red'));
            l.add(new DateWithStatusSAP(date.newinstance(2012, 10, 25), 'orange'));
            ctrl.setDatesLivraisonProposed(l);
            List<selectOption> type = ctrl.detailsController.getDatesLivraisonLatestProposedOptions();
            System.assertEquals('AUCUN', type.get(0).getValue());
            for(Integer i=1; i<= type.size()-2; i++){
                System.assert(type.get(i).getLabel().contains('red') || type.get(i).getLabel().contains('orange') || type.get(i).getLabel().contains('green'));
                System.assertEquals(false, type.get(i).getEscapeItem());
            }
            System.assertEquals('AUTRES', type.get(type.size()-1).getValue());
        }
        Test.stopTest();
    }
        
    /** test case of creation with sucess: sauverButt method **/
    //In the AP_SAPWebServiceMock class which return a dummy response, in the mode:2,action:C we simulate a success from SAP
    public static testmethod void testsauverButt_Success(){
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
            VFC01_OrderTaking_Simulation ctrl = VFC01_OrderTaking_TestUtilities.getSimulationControllerForPage(pageOK);
            PageReference confirmationStep = ctrl.detailsController.sauverButt();
            System.assertNotEquals(null, ctrl.dataForController);
            System.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM));
            System.assertEquals(null, ctrl.lastException);
            System.assertEquals(true, ctrl.detailsController.VdetailsStepDone);
            System.assertEquals((Page.VFP01_OrderTaking_Confirmation_Step3).getUrl(), confirmationStep.getUrl());
        }
        Test.stopTest();
    }
    
     /** test case of update with error got from sap : sauverButt method **/
     //In the AP_SAPWebServiceMock class which return a dummy response, in the mode:2,action:U we simulate an error from SAP
    public static testmethod void testsauverButt_Fail(){
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
            PageReference nullStep = ctrl.detailsController.sauverButt();
            System.assertNotEquals(null, ctrl.dataForController);
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
            System.assertEquals(null, nullStep);
        }
        Test.stopTest();
    }
    
}