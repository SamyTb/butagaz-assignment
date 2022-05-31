@isTest
public class VFC01_OrderTaking_Deletion_Test {
    
    /** test : initOrderID() method **/
    public static testmethod void initOrderID_fail_1(){
        // Test when we use a Order ID an it's not a valid SFDC ID.
        Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4 };
        
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder('0123405');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            System.assertEquals(false, ctrl.VorderExist);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_url));
        }
        Test.stopTest();
    }
    
    /** test : initOrderID() method **/
    public static testmethod void initOrderID_fail_2(){
        // Test when we use a Order ID an it's not a valid SFDC ID.
        Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4 };
        
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder('');
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            System.assertEquals(false, ctrl.VorderExist);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.invalid_url));
        }
        Test.stopTest();
    }
    
    /** test : initExistingOrder() method **/
    public static testmethod void initExistingOrder_fail(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4 };
        
        String validSFDCID = 'a0QM0000001If1F'; // no order for this id
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(validSFDCID);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            System.assertEquals(false, ctrl.VorderExist);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.order_not_found_for_deletion));
                
        }
    }
    
    /** test : initContractID() method **/
    public static testmethod void initContractID_fail_1(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password');
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();  	
        Order__c orderWithNoContract = new Order__c(Account__c=oAccount.Id); 
        insert orderWithNoContract;
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(''+orderWithNoContract.id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            System.assertEquals(false, ctrl.VorderExist);
            System.assert(ctrl.lastException.getMessage().contains(System.Label.contract_not_found_for_order));
                
        }
    }
    
    /** test : initExistingItemInOrder() method **/
    public static testmethod void initExistingItemInOrder_warn(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();  	
        Contract cc = VFC01_OrderTaking_TestUtilities.getContract();      
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = cc.Id);        
        insert order;
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(''+order.id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            System.assertEquals(false, ctrl.VorderExist);
            System.assert(ApexPages.hasMessages(ApexPages.Severity.WARNING));
                
        }
    }
    
    /** test : checkCurrentUserPermission_OK **/
    public static testmethod void testCheckCurrentUserPermissions_OK(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();     	
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Deletion ctrlOK = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageOK);
            System.assertEquals(null, ctrlOK.lastException);
            System.assertEquals(true, ctrlOK.VorderExist);
        }
        Test.stopTest();
    }
    
    public static testmethod void testCheckCurrentUserPermissions_KO_NoPerm(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();     	
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= 'UUUUU';
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Deletion ctrlKO = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_InvalidPerm(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();      	
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= 'UUUUU';
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Deletion ctrlKO = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_NoPTLDelCode(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();   
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oPTL.Code_Division__c= null;
        update oPTL;
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);


        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Deletion ctrlKO = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.delivery_code_not_found_on_ptl));
        }
        Test.stopTest();
    }

    public static testmethod void testCheckCurrentUserPermissions_KO_NoUserMandataire(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
    	Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();   
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
         Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageKO = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();
        //u.mandataire__c = null; 
        // Gestion multi-plaques
        u.User_Mandataires__c = null;
        System.runAs(new User(Id = UserInfo.getUserId())){ update u; }

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageKO);
            VFC01_OrderTaking_Deletion ctrlKO = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageKO);
            System.assert(ctrlKO.lastException.getMessage().contains(System.Label.no_mandataire_found_on_user));
        }
        Test.stopTest();
    }
    
    /** test : checkDeletionFlagOfOrder **/
    public static testmethod void testcheckDeletionFlagOfOrder(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
        Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();    	
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Deletion_flag__c = true, Contract__c = oContract.Id);       
        insert order;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Deletion ctrlOK = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageOK);
            System.assert(ctrlOK.lastException.getMessage().contains(System.Label.deletion_flag_set_message));
        }
        Test.stopTest();     
    }
    
    /** test case of existing contract on order : backButt() method **/
    public static testmethod void testbackButt_WithExistingContract(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
        Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Deletion ctrlOK = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageOK);
            PageReference back = ctrlOK.backButt();
            System.assertEquals((new PageReference('/'+ ctrlOK.idcontract)).getUrl(), back.getUrl());
            
        }
    }
    
     /** test case of no contract on order: backButt() method **/
    public static testmethod void testbackButt_WithNoContract(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
        Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();
        Order__c orderWithNoContract = new Order__c(Account__c=oAccount.Id);
        insert orderWithNoContract;
        PageReference p = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(''+orderWithNoContract.id);
        Test.startTest();
        System.runAs(VFC01_OrderTaking_TestUtilities.getUser()){
            Test.setCurrentPage(p);
            VFC01_OrderTaking_Deletion ctrl = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(p);
            System.assertEquals(false, ctrl.VdeletionOccured);
            PageReference back = ctrl.backButt();
            System.assertEquals(ctrl.stdController.cancel().getUrl(), back.getUrl());
                
        }
    }
    
    /** test case of fail (no external id for the current order): deleteButt() method **/
    public static testmethod void testDeleteButt_Fail_NoExternalIDOnOrder(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
        Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,Contract__c = oContract.Id);       
        insert order;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Deletion ctrlOK = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageOK);
            ctrlOK.deleteButt();
            System.assert(ctrlOK.lastException.getMessage().contains(System.Label.externalid_not_found_on_order));
        }
    }    
    
    /** test case of success : deleteButt() method **/
    public static testmethod void testDeleteButt_success(){
    	Custom_Settings__c c1 = new Custom_Settings__c (name='OrderTaking_Order_FieldId_Contract', value__c = '00ND0000003qAxd');
        Custom_Settings__c c2 = new Custom_Settings__c (name='OrderTaking_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='OrderTaking_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='OrderTaking_Password',value__c = 'password'); 
        Custom_Settings__c c5 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert c1; insert c2;  insert c3;  insert c4;
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5 };
        
        Account  oAccount    =  VFC01_OrderTaking_TestUtilities.getAccount();
        Contract oContract   = VFC01_OrderTaking_TestUtilities.getContract();
        Item__c  oItem       = VFC01_OrderTaking_TestUtilities.getItem();
        PTL__c   oPTL        = VFC01_OrderTaking_TestUtilities.getPTL();
        oContract.Product__c = oItem.Id;
        oContract.PTL__c     = oPTL.Id;
        update oContract;
        Order__c order = new Order__c(Account__c=oAccount.Id,ExternalID__c = 'DummyID', Contract__c = oContract.Id);       
        insert order;
        PageReference pageOK = VFC01_OrderTaking_TestUtilities.getVFPDeletionFromOrder(order.Id);

        User u = VFC01_OrderTaking_TestUtilities.getUser();

        Test.startTest();
        System.runAs(u){
            VFC01_OrderTaking_TestUtilities.makePermissions();
            Test.setCurrentPage(pageOK);
            VFC01_OrderTaking_Deletion ctrlOK = VFC01_OrderTaking_TestUtilities.getDeletionControllerForPage(pageOK);
            ctrlOK.deleteButt();
            System.assertEquals(true, ctrlOK.getOrder().Deletion_flag__c);
            System.assertEquals(true, ctrlOK.VdeletionOccured);
            System.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM));
            System.assertEquals(null, ctrlOK.lastException);
        }
    }
}