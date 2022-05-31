public without sharing class VFC01_OrderTaking_Deletion {
    
    // A class to wrap the request from the controller to the bapi interface for the webservice callout
    public AP_WrapperForSOAPCall wrapperForSOAPCall;
    //Object which store the response received from the webservice, in the correct format for controllers
    public AP_WrapperForSOAPCall.AP_WrapperDataForController dataForController;
    
    //Standard controller
    public ApexPages.StandardController stdController {get; set;}
    
    private Order__c order;
    private Contract contract;
    private Item_in_Order__c itemInOrder;
    
    public Id idorder {get; set;}
    public Id idcontract {get; set;}
    
    public Boolean VorderExist {get; set;}
    public Boolean VdeletionOccured {get; set;}
    
    public String userCRM {get; set;}
    
     /* VARIABLES FOR TEST CODE */
    public Exception lastException {get; set;}
    
    
    public VFC01_OrderTaking_Deletion(ApexPages.StandardController controller) {
        try{
            this.stdController = controller;
            this.userCRM = UserInfo.getName();
            this.VdeletionOccured = false;
            this.VorderExist = false;
            this.wrapperForSOAPCall = new AP_WrapperForSOAPCall();
               
            this.initOrderID(); //can throw CRMException           
            this.initExistingOrder(); //can throw CRMException
            
            this.initContractID();
            this.initContract();

            this.initExistingItemInOrder();
            
            this.checkCurrentUserPermissions();
            this.checkDeletionFlagOfOrder(); // can throw CRMException
            
            this.VorderExist = true;    
            
        }catch(CRMException e){
            this.VorderExist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            this.lastException = e;
            return;
        }    
    }
    
    /** INIT AND CHECKS METHODS **/
    public void initOrderID(){
        //Get the id of the order to delete
        try{
            this.idorder = ApexPages.currentPage().getParameters().get('delID');
            if(this.idorder == null){
               throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.invalid_url); 
            }
        }catch(System.StringException e){
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.invalid_url);
        } 
    }
    
    public void initExistingOrder(){
        //Get the information of the order
        try{
            this.setOrder([SELECT id, Name, ExternalID__c, Command_center__c, Meter_Before_Delivery__c, Breakdown__c, Order_Date_and_Time__c, Order_Type2__c, Earliest_Delivery_Date__c, Latest_Delivery_Date__c, Delivery_Man_Message__c,
                             Dispatching_point__c, Deletion_flag__c FROM Order__c WHERE Id = :idorder]);                
        }catch(System.QueryException e){
            //throw new CRMException('CRM message : Aucune commande à supprimer trouvée');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.order_not_found_for_deletion);
        }
    }
    
    public void initContractID(){
        try{
            this.idcontract = ([SELECT Contract__c FROM Order__c WHERE Id = :idorder LIMIT 1]).Contract__c;
            if(this.idcontract == null){
                throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found_for_order);
            }
        }catch(System.QueryException e){
            //throw new CRMException('CRM message : Aucun contrat relié à cette commande');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found_for_order);
        }
    }
    
    public void initContract(){
        //Get the related contract of the order
        try{
            this.setContract([select Account.AccountNumber, Account.Email__c, Account.Email_2__c, Account.No_E_mail__c, Mandataire__r.Name, Account.Name, PTL__r.Code_branche__c, PTL__r.Code_branche_value__c, Account.Sensible_Client__c,
                                 PTL__r.Code_division__c, PTL__r.Code_division_value__c, PTL__r.Mobile_Phone_Number__c, PTL__r.Phone__c, PTL__r.Work_Phone_Number__c,
                                 PTL__r.Name, PTL__r.Address__c, Product__r.Name, Product__r.ExternalID__c, Product__c, PTL__r.Limitation_of_Vehicle__c, PTL__r.Limitation_of_Tonnage__c, PTL__r.Temporary_dispensation__c, PTL__r.Permanent_dispensation__c,
                                  PTL__r.Date_at_the_End_of_Dispensation__c, PTL__r.Activity_Domain__c, PTL__r.Activity_Domain__r.Name, Equipement__r.Capacity_Tank__c, Equipement__r.Article__r.Name, Equipement__r.Article__c from Contract 
                            where Id = :idcontract]);
        }catch(System.QueryException e){
            //throw new CRMException('CRM message : 'Aucun contrat trouvé');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found);
        }
    }
    
    public void initExistingItemInOrder(){
        //Get the article of the order  
        try{
           this.setItemInOrder([SELECT Article__c, Commande__c, Quantity__c, Unit__c FROM Item_in_Order__c WHERE Commande__c = :this.order.id LIMIT 1]); 
        }catch(System.QueryException e){
           //throw new CRMException('CRM message : ' + System.Label.article_not_found_for_order); //Aucun article trouvée pour cette commande en cours');
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.crm_message+ ' : ' + System.Label.article_not_found_for_order));
        }
    }
    
    public void checkCurrentUserPermissions(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Butagaz System Administrator'];
        if(UserInfo.getProfileId() != p.id){
            //String userMandataire = [SELECT Mandataire__c FROM User WHERE id = :UserInfo.getUserId()].Mandataire__c;
            // Gestion multi-plaques
            String userMandataire = [SELECT User_Mandataires__c FROM User WHERE id = :UserInfo.getUserId()].User_Mandataires__c;
            
            if(this.contract.PTL__r.Code_division__c == null){
                throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.delivery_code_not_found_on_ptl);        
            }else if(userMandataire == null){
                throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.no_mandataire_found_on_user);
            }else{
                 //List<Order_Taking_Permissions__c> l = [SELECT Delivery_code__c FROM Order_Taking_Permissions__c WHERE User_mandataire__c = :userMandataire AND Delivery_code__c INCLUDES (:this.contract.PTL__r.Code_division__c) ];
                 // Gestion multi-plaques
                 String[] userMandataires = userMandataire.split(';',0);
                 List<Order_Taking_Permissions__c> l = [SELECT Delivery_code__c FROM Order_Taking_Permissions__c WHERE User_mandataire__c IN :userMandataires AND Delivery_code__c INCLUDES (:this.contract.PTL__r.Code_division__c) ];                 
                 
                 if(l.isEmpty()){
                    throw new CRMException(System.Label.crm_message+ ' : ' +
                                            System.Label.mandataire_of_user + ' : ' + 
                                            userMandataire  + ' ' +
                                            System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code+ ' : ' + 
                                            this.contract.PTL__r.Code_division__c);
                 } 
                 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.mandataire_of_user + ' : ' + userMandataire + ' '+ System.Label.delivery_code + ' : ' + this.contract.PTL__r.Code_division__c, ''));      
            }
        }    
    }
    
    public void checkDeletionFlagOfOrder(){
        if(this.order.Deletion_flag__c){
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.deletion_flag_set_message);
        }
    }
    
    /** BUTTONS **/
    public void deleteButt(){
        try{
           // CALL SAP FOR DELETE
           String orderNumber = this.order.ExternalID__c;
           // TODO remove the comment on orderNumber != null once we will get network connection 
           if(orderNumber != null){
               this.dataForController = this.wrapperForSOAPCall.upsertDelete('D', orderNumber, this.userCRM);
               // CHECKING RETURN FIELDS
               Boolean errorMessageReceived = this.dataForController.updateApexMessages(this.dataForController.returnFieldsList);
                //No error message received from SAP
               if(!errorMessageReceived){
                    // Confirmation of the sucess upsert received from SAP              
                    if(ApexPages.hasMessages(ApexPages.Severity.CONFIRM)){
                        // CALL SFDC FOR DELETE
                        try{
                            //TODO : see if they want to delete the order on sfdc or just set the deletion flag to true and enable the update/delete of orders having deletion flag set to true
                            //delete this.order; (Instead of the deletion, we will set the deletion flag on sfdc to True)
                            this.order.Deletion_flag__c = true;                           
                            update this.order;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.crm_message+ ' : ' + System.Label.order_with_ID + ' ' + orderNumber + ' ' + System.Label.is_deleted + ' ( flag )'));
                            this.VdeletionOccured = true;
                        }catch(DmlException e){
                            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.delete_order_failSFDC_message + ' -> Exception ' + e.getMessage());
                        }                      
                    }else{
                       //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CRM message : Aucune confirmation reçue de SAP, impossible de supprimer la commande dans SFDC'));
                       throw new CRMException(System.Label.crm_message+ ' : '+ System.Label.no_confirm_onsap_to_delete_order);   
                    }
                }
           }else{
                throw new CRMException(System.Label.crm_message+ ' : '+ System.Label.externalid_not_found_on_order);
           }
        }catch(CRMException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), ''));
            this.lastException = e;
        }catch(System.CalloutException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.network_connectivity_slow + '(' + e.getMessage() + ')', ''));
            this.lastException = e;
        }   
    }         
   
    
    public PageReference backButt(){
        if(this.idcontract != null){
            return new PageReference('/'+ this.idcontract);
        }else{
            return stdController.cancel();
        }
    }
    
    public Boolean getRenderComponentBefDelete(){
        return this.VorderExist && !this.VdeletionOccured;
    }
    
    /** GETTERS AND SETTERS **/
    public Order__c getOrder(){
       return this.order;
    }
    
    public Contract getContract(){
       return this.contract;
    }
    
    public void setContract(Contract contract){
        this.contract = contract;
    }
    
    public void setOrder(Order__c order){
        this.order = order;
    }
    
    public Item_in_Order__c getItemInOrder(){
       return this.itemInOrder;
    }
    
    public void setItemInOrder(Item_in_Order__c itemInOrder){
       this.itemInOrder = itemInOrder;
    }    
}