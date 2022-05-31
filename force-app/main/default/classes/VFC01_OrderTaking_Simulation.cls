public without sharing class VFC01_OrderTaking_Simulation {    
    // CONTROLING SIMULATION PAGE

    // A class to wrap the request from the controller format to the bapi interface format to be able to do the webservice callout
    public AP_WrapperForSOAPCall wrapperForSOAPCall;
    //Object which store the response received from the webservice, in the correct format for controllers
    public AP_WrapperForSOAPCall.AP_WrapperDataForController dataForController;
    
    /** RELATED CONTROLLER **/
    public ApexPages.StandardController stdController {get; set;}
    public VFC01_OrderTaking_Details detailsController {get; set;}

    /** VARIABLE TO MANAGE CURRENT OPERATION **/
    public final String creation ='CREATION';
    public final String modification ='MODIFICATION';
    public String typeOperation {get; set;}
    public String userCRM {get; set;}
    public String typeOperationLabel {get; set;}
    
    /** VARIABLE TO MANAGE THE CURRENT CONTRACT AND THE ORDER (FOR Modification or creation) **/
    private Id idcontract, idorder;
    private Contract contract;
    private Order__c order;
    private Item_in_Order__c itemInOrder;

    /** VARIABLE TO MANAGE DATA OF SIMULATION PAGE **/ 
    public Integer breakCount {get; set;}
    public Integer autonomy {get; set;}
    public Integer autonomyCalculated {get; set;}
    public String quantity {get; set;}
    public String amount {get; set;}
    public String quantity_uom {get; set;}
    public String amount_currency {get; set;}
    public Date lastBreakDate;
    public List<DateWithStatusSAP> datesLivraisonProposed; // List of proposed delivery date with their related color (status) code got from SAP


    /** VARIABLE TO MANAGE THE VIEW (begin with V)**/
    public Boolean VsucessControl {get; set;} // ensure that whether the idcontract or the idorder is set on the URL, flag to render/not the form.
    public Boolean VcontinueButtonVisible {get; set; }
    public Boolean VsimulateButtonVisible {get; set; }
    public String VchangeFrom {get; set; }
    public String VpageTitle {get; set;}
    public String VmessageInfo {get; set;}
    public Boolean VsimulationStepDone {get; set;}
    public Boolean errorGotFromSAPDuringSimulation {get; set;}
    
    /* VARIABLES FOR TEST CODE */
    public Exception lastException {get; set;}

    //Constructor
    public VFC01_OrderTaking_Simulation(ApexPages.StandardController controller) {
        try{
            this.userCRM = UserInfo.getName();
            this.stdController = controller;
            this.detailsController = new VFC01_OrderTaking_Details(this);               
            this.datesLivraisonProposed = new List<DateWithStatusSAP>();

            try{
                // The value of Custom_Settings__c.getInstance('Order_FieldId_Contract').value__c represent the id of the id field of the contract in order 00ND0000003qAxd (depends to the environnement)
                this.idcontract = ApexPages.currentPage().getParameters().get('CF'+ Custom_Settings__c.getInstance('OrderTaking_Order_FieldId_Contract').value__c + '_lkid'); 
                //(if idorder on the URL isn't set --> future creation of the order ; if idorder is set --> modification of an existing order) 
                this.idorder = ApexPages.currentPage().getParameters().get('id');
            }catch(System.StringException e){
                throw new CRMException(System.Label.invalid_url);
            }catch(System.NullPointerException e){
                throw new CRMException('You have to set the custom setting named (Order_FieldId_Contract) to the id of the Contract__c id field in an Order__c object');
            }

            this.initIDs(); // can throw CRMException

            this.initContract(); // can throw CRMException
            this.checkContract(); // can throw CRMException

            this.checkCurrentUserPermissions();// can throw CRMException

            this.sapInitialization();
        }catch(CRMException e){
            this.VsucessControl = false; //don't show the form (error got from sap)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), ''));
            this.lastException = e;
        }catch(System.CalloutException e){
            this.VsucessControl = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.network_connectivity_slow + '(' + e.getMessage() + ')', ''));
            this.lastException = e;
        }
    }

    /** INITIALIZATION METHODS **/

    //Init idcontract, idorder and typeOperation 
    public void initIDs(){    
        if((this.idorder == null) && (this.idcontract == null)){  
            //throw new CRMException('CRM message : ' + Page accessible uniquement à partir d\'un contrat ou d\'une commande en cours');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.error_access_page);
        }else if(this.idcontract != null){
            typeOperation = 'CREATION';
        }else if(this.idorder != null){
            typeOperation = 'MODIFICATION';
            try{
                this.idcontract = ([SELECT Contract__c FROM Order__c WHERE Id = :this.idorder LIMIT 1]).Contract__c;
                if(this.idcontract == null){
                    throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found_for_order);
                }
            }catch(System.QueryException e){
                //throw new CRMException('CRM message : Aucun contrat relié à cette commande');
                throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found_for_order);
            }
        }      
    }

    //Init contract
    public void initContract(){
        //Current Contract
        try{
            this.setContract([
            SELECT 
                Account.ID,
                Account.AccountNumber, Account.Email__c, Account.Email_2__c, 
                Account.No_E_mail__c, Account.Name, Account.Sensible_Client__c,
                Account.Phone, Account.Work_Phone_Number__c, Account.Mobile_Phone_Number__c,                              
                Mandataire__r.Name, 
                PTL__r.ID,
                PTL__r.Code_branche__c, PTL__r.Code_branche_value__c, 
                PTL__r.Code_division__c, PTL__r.Code_division_value__c, 
                PTL__r.Mobile_Phone_Number__c, PTL__r.Phone__c, PTL__r.Work_Phone_Number__c,
                PTL__r.Name, PTL__r.Address__c, 
                Product__r.Name, Product__r.ExternalID__c, Product__c, 
                PTL__r.Limitation_of_Vehicle__c, PTL__r.Limitation_of_Tonnage__c, PTL__r.Temporary_dispensation__c, 
                PTL__r.Permanent_dispensation__c, PTL__r.Date_at_the_End_of_Dispensation__c, 
                PTL__r.Activity_Domain__c, PTL__r.Activity_Domain__r.Name, Equipement__r.Capacity_Tank__c, 
                Equipement__r.Article__r.Name, Equipement__r.Article__c 
            FROM Contract 
            WHERE Id = :this.idcontract
            ]);
        } catch(System.QueryException e){
            //throw new CRMException('CRM message : 'Aucun contrat trouvé');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_not_found);
        }
    }

    //Check the product and ptl of the current contract
    public void checkContract(){
        if(this.contract.Product__r == null){
            //throw new CRMException('CRM message : Le contrat doit obligatoirement avoir un produit');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_musthave_product);
        }

        if(this.contract.PTL__r == null){
            //throw new CRMException('CRM message : Le contrat doit obligatoirement être rattaché à un PTL');
            throw new CRMException(System.Label.crm_message + ' : ' + System.Label.contract_musthave_ptl);
        }
    }

    public void checkCurrentUserPermissions(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Butagaz System Administrator'];
        if(UserInfo.getProfileId() != p.id){
            //String userMandataire = [SELECT Mandataire__c FROM User WHERE id = :UserInfo.getUserId()].Mandataire__c;
            // Gestion multi-plaques
            String userMandataire = [SELECT User_Mandataires__c FROM User WHERE id = :UserInfo.getUserId()].User_Mandataires__c;
            
            if(this.contract.PTL__r.Code_division__c == null){
                throw new CRMException(System.Label.crm_message + ' : ' + System.Label.delivery_code_not_found_on_ptl);        
            }else if(userMandataire == null){
                throw new CRMException(System.Label.crm_message + ' : ' + System.Label.no_mandataire_found_on_user);
            }else{
                 //List<Order_Taking_Permissions__c> l = [SELECT Delivery_code__c FROM Order_Taking_Permissions__c WHERE User_mandataire__c = :userMandataire AND Delivery_code__c INCLUDES (:this.contract.PTL__r.Code_division__c) ];
                 // Gestion multi-plaques
                 String[] userMandataires = userMandataire.split(';',0);
                 List<Order_Taking_Permissions__c> l = [SELECT Delivery_code__c FROM Order_Taking_Permissions__c WHERE User_mandataire__c IN :userMandataires AND Delivery_code__c INCLUDES (:this.contract.PTL__r.Code_division__c) ];
                 
                 if(l.isEmpty()){
                    throw new CRMException(System.Label.crm_message + ' : ' +
                                            System.Label.mandataire_of_user + ' : ' + 
                                            userMandataire + ' ' +
                                            System.Label.is_not_allowed_to_perform_operations_on_orders_for_the_delivery_code+ ' : ' + 
                                            this.contract.PTL__r.Code_division__c);
                 } 
                 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.mandataire_of_user+ ' : ' + userMandataire + ' ' + System.Label.delivery_code + ' : ' + this.contract.PTL__r.Code_division__c, ''));      
            }
        }    
    }

    //Init a new Order__c (case of creation)
    public void initNewOrder(){
        this.setOrder(new Order__c(Contract__c = this.contract.id, Account__c = this.contract.Account.id,
                Mandataire__c = this.contract.Mandataire__c, PTL__c = this.contract.PTL__c,
                Activity_Domain__c = this.contract.PTL__r.Activity_Domain__c,
                Dispatching_point__c = this.contract.PTL__r.Code_division__c
        ));
    }

    //Init an existing Order__c (case of update)
    public void initExistingOrder(){
        try{
            this.setOrder([SELECT id, Name, ExternalID__c, Command_center__c, Meter_Before_Delivery__c, Breakdown__c, Order_Date_and_Time__c, Order_Type2__c, Earliest_Delivery_Date__c, Latest_Delivery_Date__c, Delivery_Man_Message__c, Deletion_flag__c
                FROM Order__c WHERE Id = :idorder]);
        }catch(System.QueryException e){
            //throw new CRMException('CRM message : Aucune commande à modifier trouvée');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.order_not_found);
        }             
    }

    public void initExistingItemInOrder(){
        try{
            this.setItemInOrder([SELECT Article__c, Commande__c, Quantity__c, Unit__c FROM Item_in_Order__c WHERE Commande__c = :this.order.id LIMIT 1]); 
        }catch(System.QueryException e){
            //throw new CRMException('CRM message : ' + Aucun article trouvée pour cette commande en cours');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.article_not_found_for_order); //Aucun article trouvée pour cette commande en cours');
        }        
    }

    //Check the delivery dates of the existing order (update operation) with NOW() 
    //Unable updating of an order already delivered or on delivery for today
    public void checkDeliveryDatesWithNow(){
        Date now_x = datetime.now().date();
        if((this.order.Earliest_Delivery_Date__c != null && this.order.Earliest_Delivery_Date__c <= now_x) 
                || (this.order.Latest_Delivery_Date__c != null && this.order.Latest_Delivery_Date__c <= now_x)) {
            //throw new CRMException('Vous ne pouvez pas modifier une commande livrée ou en livraison aujourd\'hui');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.update_order_delivered);
                }
    }

    public void checkDeletionFlagOfOrder(){
        if(this.order.Deletion_flag__c){
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.deletion_flag_set_message);
        }
    }
    
    public void sapInitialization(){
        //Initialize the object to do webService Callout
        this.wrapperForSOAPCall = new AP_WrapperForSOAPCall();

        if(this.typeOperation.equals(creation)){
            this.VpageTitle = System.Label.creation_new_order; //'Création d\'une nouvelle commande dans CRM et SAP';
            this.typeOperationLabel = System.Label.the_creation;
            this.initNewOrder();                
            //Init a new Item_in_Order__c, we will related it to the current order and the article managed by the contract on the saving action (see VFC01_OrderTaking_Details controller)
            this.setItemInOrder(new Item_in_Order__c()); 
            //CALL SAP FOR SCENARIO : SIMULATION+CREATION
            this.dataForController = this.wrapperForSOAPCall.simulateCreationOrUpdateInitial('C', contract.Account.AccountNumber, contract.PTL__r.Name,'', null);          
        }else if(this.typeOperation.equals(modification)){
            this.VpageTitle = System.Label.update_order ; //'Modification de la commande dans CRM et SAP';
            this.typeOperationLabel = System.Label.the_update;
            this.initExistingOrder(); // can throw CRMException
            //this.checkDeliveryDatesWithNow(); // can throw CRMException 
            this.checkDeletionFlagOfOrder(); //can throw CRMException
            //In update process we retrieve the item of the current order for update
            // For GEC, normally we are sure that we will have one entry of item on the order
            this.initExistingItemInOrder();      
            //CALL SAP FOR SCENARIO : SIMULATION+UPDATE;
            this.dataForController = wrapperForSOAPCall.simulateCreationOrUpdateInitial('U', null, null, order.ExternalID__c, '');    
        }

        this.order.Dispatching_point__c = this.contract.PTL__r.Code_division__c;

        //CHECKING RETURN FIELDS OF THE RESPONSE GOT FROM SAP
        Boolean errorMessageReceived = this.dataForController.updateApexMessages(this.dataForController.returnFieldsList);             
        if(!errorMessageReceived){               
            //UPDATE SIMULATION PAGE VIEW 
            this.updateFields();
            //UPDATE DETAIL PAGE VIEW
            this.detailsController.updateFields();
            //UPDATE BUTTON VIEW               
            this.VcontinueButtonVisible = true;
            this.VsimulateButtonVisible = false;
            //SHOW THE FORM
            this.VsucessControl = true;
        }else{               
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CRM message : Erreur reçue de SAP', ''));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CRM message : ' + System.Label.error_got_fromsap, ''));
            //UPDATE BUTTON VIEW  
            this.VcontinueButtonVisible = false;
            this.VsimulateButtonVisible = false;
            //NO RENDER THE FORM
            this.VsucessControl = false;
        }
        this.VmessageInfo = System.Label.message_clearing_data; //'Merci de patienter pendant la réinitialisation des données....';
    }

    //Catch the onchange Event on the field amount/quantity/gauge (parameter to customize simulation on SAP)
    public void clearData(){
        //UPDATE THE BUTTON VIEW
        this.VcontinueButtonVisible = this.errorGotFromSAPDuringSimulation; //if during simulation, we got an error from sap we show continue button (for flexibility)
        this.VsimulateButtonVisible = true;
        //INSPECT THE FIELD CHANGED ON VchangeFrom variable
        if(VchangeFrom.equals('quantity')){
            if(this.quantity == '') this.quantity = null;
            this.amount = null;
            //this.order.Meter_Before_Delivery__c = null;
        }else if(VchangeFrom.equals('amount')){
            if(this.amount == '') this.amount = null;
            this.quantity = null;
            //this.order.Meter_Before_Delivery__c = null;
        }else if(VchangeFrom.equals('gauge')){
            if(this.order.Meter_Before_Delivery__c == '') this.order.Meter_Before_Delivery__c = null;
            this.amount = null;
            this.quantity = null;
        }
        datesLivraisonProposed.clear();
        this.VmessageInfo = System.Label.message_simulation_progress; //'Merci de patienter pendant la simulation des données dans SAP....';
    }

    /** BUTTONS ON SIMUALTION PAGE **/
   
    //Simulate Button 
    public void simulateButt(){
        try{
            /** SAFE CHECK OF THE QUANTITY, THE AMOUNT AND THE GAUGE BEFORE SENDING SIMULATION TO SAP**/           
            this.checkAmount(this.amount); // can throw CRMException
            this.checkQuantity(this.quantity); // can throw CRMException
            this.checkGauge(this.order.Meter_Before_Delivery__c); // can throw CRMException

            /** CALL SAP FOR CUSTOM SIMULATION **/
            
            
            if(this.typeOperation.equals(creation)){ 
                this.dataForController = this.wrapperForSOAPCall.simulateCreationOrUpdate(
                    'C', contract.Account.AccountNumber, contract.PTL__r.Name, 
                    '', null, contract.Product__r.ExternalID__c, 
                    this.order.Meter_Before_Delivery__c, amount, 'EUR', 
                    quantity, 'TO', this.order.Order_Type2__c, this.order.Delivery_Man_Message__c, this.detailsController.reference, this.order.Earliest_Delivery_Date__c,
                    this.order.Latest_Delivery_Date__c, this.detailsController.periode, this.detailsController.modeContact, this.detailsController.raisonReport, this.detailsController.texteClient1,
                    this.detailsController.texteClient2, this.order.Breakdown__c, this.detailsController.majoration, this.detailsController.preFilling, 
                    this.detailsController.orderOrigin, this.detailsController.rappelClient, this.order.Order_Date_and_Time__c);
            }else{
                this.dataForController = this.wrapperForSOAPCall.simulateCreationOrUpdate(
                    'U', null, null, order.ExternalID__c, null, 
                    contract.Product__r.ExternalID__c, 
                    this.order.Meter_Before_Delivery__c, amount, 'EUR', 
                    quantity, 'TO', this.order.Order_Type2__c, this.order.Delivery_Man_Message__c, this.detailsController.reference, this.order.Earliest_Delivery_Date__c,
                    this.order.Latest_Delivery_Date__c, this.detailsController.periode, this.detailsController.modeContact, this.detailsController.raisonReport, this.detailsController.texteClient1,
                    this.detailsController.texteClient2, this.order.Breakdown__c, this.detailsController.majoration, this.detailsController.preFilling, 
                    this.detailsController.orderOrigin, this.detailsController.rappelClient, this.order.Order_Date_and_Time__c);
            }
            // CHECKING RETURN FIELDS
            Boolean errorMessageReceived = this.dataForController.updateApexMessages(this.dataForController.returnFieldsList);
            /** Update the visibility of The Button **/            
            if(!errorMessageReceived){
                /** UPDATE VIEWS (SIMULATION AND DETAIL PAGES)**/
                this.updateFields();
                this.detailsController.updateFields();
                //UPDATE BUTTON VIEW
                this.errorGotFromSAPDuringSimulation = false;
                this.VcontinueButtonVisible = true;
                this.VsimulateButtonVisible = false;
            }else{
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CRM message : Erreur reçue de SAP', ''));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CRM message : ' + System.Label.error_got_fromsap, ''));
                //UPDATE BUTTON VIEW
                this.errorGotFromSAPDuringSimulation = true;
                this.VcontinueButtonVisible = this.errorGotFromSAPDuringSimulation;
                this.VsimulateButtonVisible = true;
            }    
            this.VmessageInfo = System.Label.message_clearing_data; //'Merci de patienter pendant la réinitialisation des données....';
        }catch(CRMException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), ''));
            this.lastException = e;
        }catch(System.CalloutException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.network_connectivity_slow + '(' + e.getMessage() + ')', ''));
            this.lastException = e;
        }
    }

    public void checkAmount(String amountVal){
        if(amountVal.equals('')){
            this.amount = null;
        }else{
            try{
                Decimal.valueOf(amountVal);
            }catch(System.TypeException e){
                //throw new CRMException('CRM message : Vous devez spécifier un nombre dans le montant');
                throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.invalid_amount_message);
            }
        }        
    }

    public void checkQuantity(String quantityVal){
        if(quantityVal.equals('')){
            this.quantity = null;
        }else{
            try{
                Decimal.valueOf(quantityVal);
            }catch(System.TypeException e){
                //throw new CRMException('CRM message : Vous devez spécifier un nombre dans la quantité');
                throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.invalid_quantity_message);
            }
        }        
    }

    public void checkGauge(String gaugeVal){
        if(gaugeVal.equals('')){
            this.order.Meter_Before_Delivery__c = null;
        }else{
            try{
                Integer.valueOf(gaugeVal);
            }catch(System.TypeException e){
                //throw new CRMException('CRM message : Vous devez spécifier un nombre dans la gauge');
                throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.invalid_gauge_message);
            }
        }        
    }

    //Continue Button
    public PageReference continueButt(){
        this.VsimulationStepDone = true;
        this.dataForController.updateApexMessages(this.dataForController.returnFieldsList);
        this.order.Order_Date_and_Time__c = Datetime.now();
        this.saveAccountAndPTL();
        PageReference p = Page.VFP01_OrderTaking_Details_Step2;
        return p;

    }

    public PageReference cancelButt(){
        if(this.idcontract != null){
            return new PageReference('/'+ this.idcontract);
        }else{
            return stdController.cancel();
        }
    }

    /** UPDATE SIMULATION PAGE AFTER SIMULATE CREATION/UPDATE **/
    public void updateFields(){       
        this.order.Command_center__c = dataForController.orderCenter;

        this.autonomy = dataForController.autonomy;
        this.autonomyCalculated = dataForController.autonomyCalculated;

        this.breakCount = dataForController.breakCount;
        this.lastBreakDate = dataForController.lastBreakDate;

        this.amount = dataForController.amount;
        this.amount_currency = dataForController.currency_x;

        this.quantity = dataForController.quantity;        
        this.quantity_uom = dataForController.quantity_uom; 

        this.contract.Product__r.ExternalID__c = dataForController.materialNumber; // ?? normally equals to contract.Product__r.External_ID__c
        this.order.Meter_Before_Delivery__c = dataForController.gaugeValue;
        this.order.Breakdown__c = dataForController.cust_down; 

        if(typeOperation.equals(modification)){
            this.order.Name = dataForController.orderNumber; // normally order.Name = order.ExternalID = EX_ORDER_NUMBER(get from SAP)
            this.order.ExternalID__c = dataForController.orderNumber; // normally order.Name = order.ExternalID = EX_ORDER_NUMBER(get from SAP)         
        }

        this.datesLivraisonProposed = dataForController.del_date_proposed;
    }  
    
    public pageReference saveAccountAndPTL(){
        
        try{
            update contract.account;
            update contract.PTL__r;
        }
        
        catch(DmlException ex){
            ApexPages.addMessages(ex);            
            return null;
        }   
        return null; 
    }
    
    
    /* GETTERS */
    public Id getIdorder(){
        return this.idorder;
    }

    public Order__c getOrder(){
        return this.order;
    }

    public Item_In_Order__c getItemInOrder(){
        return this.itemInOrder;
    }

    public Id getIdcontract(){
        return this.idcontract;
    }

    public Contract getContract(){
        return this.contract;                        
    }

    public String getLastBreakDate(){
        if(this.lastBreakDate != null)
            return this.lastBreakDate.format();
        return null;    
    }

    public List<DateWithStatusSAP> getDatesLivraisonProposed(){
        return this.datesLivraisonProposed;
    }

    //Return the first delivery date proposed with green status
    public String getFirstDateLivraisonProposed() {
        if(this.datesLivraisonProposed != null && !this.datesLivraisonProposed.isEmpty()){
            for(DateWithStatusSAP date_x : this.datesLivraisonProposed){
                if(date_x.colorCode.equals('green')){
                    return date_x.datee.format();    
                }
            }
        }        
        return null;
    }



    /* SETTER */

    public void setOrder(Order__c order){
        this.order = order;
    }

    public void setItemInOrder(Item_In_Order__c itemInOrder){
        this.itemInOrder = itemInOrder;
    }

    public void setContract(Contract contract){
        this.contract = contract;
    }
    
    public void setLastBreakDate(Date d){
        this.lastBreakDate = d;
    }
    
    public void setDatesLivraisonProposed(List<DateWithStatusSAP> l){
        this.datesLivraisonProposed = l;
    }
    
    public static boolean checkExistingDate(List<DateWithStatusSAP> list_x, String d){
        if(list_x != null && d != null){
            for(DateWithStatusSAP date_x : list_x){
                if(d.equals(date_x.datee.format())){
                    return true;
                }        
            }
        }    
        return false;
    }

    class DateWithStatus{}
}