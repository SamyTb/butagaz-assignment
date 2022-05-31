public without sharing class VFC01_OrderTaking_Details {


    // CONTROLING MAINLY DETAILS PAGE
    
    /** RELATED CONTROLLER **/
    public VFC01_OrderTaking_Simulation simulationController {get;set;}
      
    /** VARIABLE TO MANAGE DATA OF DETAILS AND CONFIRMATION PAGE **/   
    public String rappelClient { get; set; }
    public String orderOrigin { get; set; }
    public String reference {get; set;}
    public Boolean orderTypeDisabled {get; set;}
    public Boolean preFilling {get; set;}
    public Boolean preFillingDisabled {get; set;}
    public Boolean majoration {get; set;}
    public Boolean majorationDisabled {get; set;}
    public String periode { get; set; }
    public String modeContact {get; set;}
    public String raisonReport {get; set;}    
    public String texteClient1 {get; set;}
    public String texteClient2 {get; set;}
    public String texteChauffeur2 { get; set; }
    public String texteChauffeur1 { get; set; }
    public Decimal valeurLimitation {get; set;}
    public Boolean borneDeporte {get; set;}
    public Boolean miCharge {get; set;}
    public String conditionLivraison {get; set;}
    public String dateLivraisonEarliestChoosed;
    public String dateLivraisonLatestChoosed;
    
    public Boolean inputDatePickerLivraisonTotDisabled {get; set;}
    public Boolean inputDatePickerLivraisonTardDisabled {get; set;}
    
    public Boolean VdetailsStepDone {get; set;}
    
    public VFC01_OrderTaking_Details(VFC01_OrderTaking_Simulation simulationController) {
        this.simulationController = simulationController;
    }
    
    public void updateFields(){
     
        this.orderOrigin = this.simulationController.dataForController.orderOrigin;
        this.rappelClient = this.simulationController.dataForController.cust_call;
        this.periode = this.simulationController.dataForController.moment;
        this.modeContact =  this.simulationController.dataForController.medContact;
        this.raisonReport = this.simulationController.dataForController.reasonReport; 
        this.majoration = this.simulationController.dataForController.cust_urgent;
        this.preFilling = this.simulationController.dataForController.cust_preempl;
        this.texteChauffeur1 = this.simulationController.dataForController.driver_text1;
        this.texteChauffeur2 = this.simulationController.dataForController.driver_text2;
        this.texteClient1 = this.simulationController.dataForController.cust_text1;
        this.texteClient2 = this.simulationController.dataForController.cust_text2;
        this.preFillingDisabled = this.simulationController.dataForController.preFillingDisabled;
        this.majorationDisabled = this.simulationController.dataForController.majorationDisabled;
        this.orderTypeDisabled =  this.simulationController.dataForController.orderTypeDisabled;
        this.reference = this.simulationController.dataForController.reference;
        
        this.dateLivraisonEarliestChoosed = this.simulationController.dataForController.ear_del_date;
        this.updateDatePickerLivraisonTot();
        this.dateLivraisonLatestChoosed = this.simulationController.dataForController.lat_del_date;
        this.updateDatePickerLivraisonTard();
        
        // NB : We use now() on continueButt (simulation controller) because in case of Update we will receive old date_time order and we want to set it to now() for both creation and update
        //this.simulationController.getOrder().Order_Date_and_Time__c = this.simulationController.dataForController.orderDateTime;
        this.simulationController.getOrder().Order_Type2__c = this.simulationController.dataForController.orderType;   
        this.simulationController.getOrder().Delivery_Man_Message__c  =  this.simulationController.dataForController.del_req;
                       
        this.updatePTLData();
    
    }

    public void updatePTLData(){
        this.simulationController.contract.PTL__r.Limitation_of_Vehicle__c = this.simulationController.dataForController.restrictionVehicule;
        this.simulationController.contract.PTL__r.Limitation_of_Tonnage__c = this.simulationController.dataForController.limitationTonnage;
        this.simulationController.contract.PTL__r.Temporary_dispensation__c = this.simulationController.dataForController.derogProv;
        this.simulationController.contract.PTL__r.Permanent_dispensation__c = this.simulationController.dataForController.derogPermanent;
        this.simulationController.contract.PTL__r.Date_at_the_End_of_Dispensation__c = this.simulationController.dataForController.dateEndDerog;
        this.valeurLimitation = this.simulationController.dataForController.valeurLimitation;
        this.borneDeporte = this.simulationController.dataForController.borneDeporte;      
        this.miCharge = this.simulationController.dataForController.miCharge;
        this.conditionLivraison = this.simulationController.dataForController.conditionLiv;
    }
    
    /** BUTTONS ON DETAIL PAGE**/
    //Save Button on Details page
    public PageReference sauverButt(){
        /** TRICK TO DO SAP BAPI **/
        try{
 
            //CALLING SAP FOR SCENARIO : UPSERT+CREATIONorUPDATE
            this.simulationController.dataForController = this.upsertCreationOrUpdate();
            // SIMULATE SAP SLOW
            /*
            Integer i = 0;
            while (i < 40000){
                Math.atan(i);
                i += 1;
                if (Math.mod(i, 1000) == 0){
                    System.debug('Waiting: ' + i);
                }
            }
            */
            // END SIMULATE SAP SLOW
            
            // CHECKING RETURN FIELDS OF THE RESPONSE GOT FROM SAP
            Boolean errorMessageReceived = this.simulationController.dataForController.updateApexMessages(this.simulationController.dataForController.returnFieldsList);
            //No error message received from SAP
            if(!errorMessageReceived){
                // Confirmation of the sucess upsert received from SAP              
                if(ApexPages.hasMessages(ApexPages.Severity.CONFIRM)){
                
                    // TODO uncomment this ligne after having network connection to SAP :this.simulationController.updateFields(); 
                    // TODO uncomment this ligne after having network connection to SAP :this.updateFields();
                    //this.simulationController.updateFields();
                    //this.updateFields();
                    
                    this.finishInitOfOrder();
                    // All validation rules concerning the delivery dates of the order will be checked also on the sap side (right they are disbled on SFDC side)                  
                    this.upsertOrderOnSFDC();                   
                    this.finishInitOfItemInOrder();                               
                    this.upsertItemInOrderOnSFDC();                   
                    this.updatePTLonSFDC();
                    
                     //Info message for creation or modification of the order : (visible on the 3rd step)
                    if(this.simulationController.typeOperation.equals(this.simulationController.creation)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.crm_message+ ' : '+
                                                                                                System.Label.new_order_inserted + ' ' +
                                                                                                this.simulationController.getOrder().Name, ''));
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.crm_message+ ' : '+
                                                                                                System.Label.order_with_ID + ' ' +
                                                                                                this.simulationController.getOrder().Name +
                                                                                                System.Label.is_updated, ''));
                    }
                    
                    
                    this.VdetailsStepDone = true;
                    PageReference p = Page.VFP01_OrderTaking_Confirmation_Step3;
                    return p;
                }else{
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'CRM message : Aucune confirmation reçue de SAP, impossible de sauvegarder la commande dans SFDC', ''));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.crm_message+ ' : ' + System.Label.no_confirm_onsap, ''));
                    return null;
                }    
            }else{
                return null;
            }            
        }catch(CRMException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''+ex.getMessage(), ''));
            this.simulationController.lastException = ex;
            return null;
        }catch(System.CalloutException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.network_connectivity_slow + '(' + ex.getMessage() + ')', ''));
            this.simulationController.lastException = ex;
            return null;
        }
    }
    
    //Call the wrapper to do webservice callout for upsert
    public AP_WrapperForSOAPCall.AP_WrapperDataForController upsertCreationOrUpdate(){     
       String actionCode, orderNumber, accountNumber, ptlName;
       
       if(this.simulationController.typeOperation.equals(this.simulationController.creation)){
           actionCode = 'C';
           orderNumber = '';
           accountNumber = this.simulationController.getContract().Account.AccountNumber;
           ptlName = this.simulationController.getContract().PTL__r.Name;
       }else{
           actionCode = 'U';
           orderNumber = this.simulationController.getOrder().Name; // uncomment next line after network connection (and replace this line by the next)
           orderNumber = this.simulationController.getOrder().ExternalID__c;
           accountNumber = null;
           ptlName = null;
       }
       
       this.simulationController.checkQuantity(this.simulationController.quantity); // can throw CRMException
       this.simulationController.checkGauge(this.simulationController.getOrder().Meter_Before_Delivery__c); // can throw CRMException
            
       return this.simulationController.wrapperForSOAPCall.upsertCreationOrUpdate
       (
           actionCode,
           '2',
           accountNumber,
           ptlName,
           orderNumber,
           this.simulationController.userCRM,
           this.simulationController.getContract().Product__r.ExternalID__c,
           this.simulationController.getOrder().Meter_Before_Delivery__c,
           null,
           this.simulationController.amount_currency,
           this.simulationController.quantity,
           this.simulationController.quantity_uom,
           this.simulationController.getOrder().Order_Type2__c,
           this.simulationController.getOrder().Delivery_Man_Message__c,
           this.reference,
           this.simulationController.getOrder().Earliest_Delivery_Date__c,
           this.simulationController.getOrder().Latest_Delivery_Date__c,
           this.periode,
           this.modeContact,
           this.raisonReport,
           this.texteClient1,
           this.texteClient2,
           this.simulationController.getOrder().Breakdown__c,
           this.majoration,
           this.preFilling,
           this.orderOrigin,
           this.rappelClient,
           this.simulationController.getOrder().Order_Date_and_Time__c
        );    
    }
    
    public void finishInitOfOrder(){
        //Update the order number and external ID of the current order (information got from SAP after the confirmation)
        this.simulationController.getOrder().Name = this.simulationController.dataForController.orderNumber;
        // TODO uncomment this ligne :this.simulationController.getOrder().ExternalID__c = this.simulationController.dataForController.orderNumber; 
        this.simulationController.getOrder().ExternalID__c = this.simulationController.dataForController.orderNumber;                
    }
    
    public void upsertOrderOnSFDC(){
        try{
            upsert this.simulationController.getOrder();
        }catch(DmlException e){
            //throw new CRMException('CRM message : Upsert failed for the order on SFDC side after sucess on SAP');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.upsert_order_failSFDC_message + ' -> Dml Exception : ' + e.getMessage());
        }    
    }
    
    public void finishInitOfItemInOrder(){
        //Setting the ItemInOrder Object
        //In creation process we relate the Item_in_order Object to the current order and the article managed by the contract
        if(this.simulationController.typeOperation.equals(this.simulationController.creation)){
            this.simulationController.getItemInOrder().Article__c = this.simulationController.getContract().Product__c;
            this.simulationController.getItemInOrder().Commande__c = this.simulationController.getOrder().id;                      
        }
        this.simulationController.getItemInOrder().Quantity__c = Decimal.valueOf(this.simulationController.quantity);
        this.simulationController.getItemInOrder().Unit__c = this.simulationController.quantity_uom;      
    }
    
    public void upsertItemInOrderOnSFDC(){
        try{
            upsert this.simulationController.getItemInOrder();
        }catch(DmlException e){
            //throw new CRMException('CRM message : Upsert failed for the item in order on SFDC side after sucess on SAP');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.upsert_iteminorder_failSFDC_message + ' -> Dml Exception : ' + e.getMessage());
        }    
    }
    
    public void updatePTLOnSFDC(){
        try{
            update this.simulationController.getContract().PTL__r;
        }catch(DmlException e){
            //throw new CRMException('CRM message : Update failed for the PTL of the contract on SFDC side after sucess on SAP');
            throw new CRMException(System.Label.crm_message+ ' : ' + System.Label.update_ptl_failSFDC_message + ' -> Dml Exception : ' + e.getMessage());
        }            
    }
    
    //Retour Button on Details page
    public PageReference retourButt(){
         this.simulationController.dataForController.updateApexMessages(this.simulationController.dataForController.returnFieldsList);
         this.simulationController.VsimulationStepDone = false;
         return Page.VFP01_OrderTaking_Simulation_Step1;
    }
    
    
    //Terminer Button on Confirmation page
    public PageReference terminerButt(){
       if(this.simulationController.getOrder() != null){
            PageReference orderPage = new ApexPages.StandardController(this.simulationController.getOrder()).view();
            orderPage.setRedirect(true);
            return orderPage;
        }
       return null;
    }
    
    
    /** LIST OPTIONS ON DETAILS PAGE **/
    public List<selectOption> getOrderOriginOptions(){
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('FAX', AP_MappingOptions.orderOriginMap.get('FAX')));
        type.add(new SelectOption('MUEN', AP_MappingOptions.orderOriginMap.get('MUEN')));
        type.add(new SelectOption('SCHR', AP_MappingOptions.orderOriginMap.get('SCHR')));
        type.add(new SelectOption('TELC', AP_MappingOptions.orderOriginMap.get('TELC')));
        type.add(new SelectOption('TELE', AP_MappingOptions.orderOriginMap.get('TELE')));
        type.add(new SelectOption('TELM', AP_MappingOptions.orderOriginMap.get('TELM')));
        type.add(new SelectOption('DFUE', AP_MappingOptions.orderOriginMap.get('DFUE')));
        return type;
    }
    
    public String getPrettyPrintOrderOrigin(){
        return AP_MappingOptions.orderOriginMap.get(orderOrigin);
    }
    
    public List<selectOption> getRappelClientOptions(){
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('0', AP_MappingOptions.custCallMap.get('0')));
        type.add(new SelectOption('1', AP_MappingOptions.custCallMap.get('1')));
        type.add(new SelectOption('2', AP_MappingOptions.custCallMap.get('2')));
        return type;
    }
    
    public String getPrettyPrintCustCall(){
        return AP_MappingOptions.custCallMap.get(rappelClient);
    }
    
    public List<selectOption> getPeriodeOptions(){
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('00', AP_MappingOptions.momentMap.get('00')));
        type.add(new SelectOption('MATIN', AP_MappingOptions.momentMap.get('MATIN')));
        type.add(new SelectOption('APRES-MIDI', AP_MappingOptions.momentMap.get('APRES-MIDI')));
        return type;
    }
    
    public String getPrettyPrintMoment(){
        return AP_MappingOptions.momentMap.get(periode);
    }
    
    public List<selectOption> getModeContactOptions(){
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('00', AP_MappingOptions.medContactMap.get('00')));
        type.add(new SelectOption('01', AP_MappingOptions.medContactMap.get('01')));
        type.add(new SelectOption('02', AP_MappingOptions.medContactMap.get('02')));
        type.add(new SelectOption('03', AP_MappingOptions.medContactMap.get('03')));
        type.add(new SelectOption('04', AP_MappingOptions.medContactMap.get('04')));
        type.add(new SelectOption('05', AP_MappingOptions.medContactMap.get('05')));
        type.add(new SelectOption('06', AP_MappingOptions.medContactMap.get('06')));
        type.add(new SelectOption('07', AP_MappingOptions.medContactMap.get('07')));
        type.add(new SelectOption('08', AP_MappingOptions.medContactMap.get('08')));
        return type;
    }
    
    public String getPrettyPrintMedContact(){
        return AP_MappingOptions.medContactMap.get(modeContact);
    }
    
    public List<selectOption> getRaisonReportOptions(){
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('00', AP_MappingOptions.reasonDelayMap.get('00')));       
        type.add(new SelectOption('A', AP_MappingOptions.reasonDelayMap.get('A')));
        type.add(new SelectOption('B', AP_MappingOptions.reasonDelayMap.get('B')));
        return type;
    }
    
    public String getPrettyPrintReasonDelay(){
        return AP_MappingOptions.reasonDelayMap.get(raisonReport);
    }
    
    public List<selectOption> getDatesLivraisonEarliestProposedOptions() {
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('AUCUN', System.Label.none_label)); 
        for(DateWithStatusSAP d : this.simulationController.getDatesLivraisonProposed()){
            if(d.colorCode.equals('green')){
                SelectOption option = new SelectOption(d.datee.format(), '<span style="color:' + d.colorCode + ';">' + d.datee.format()+ '</span>');
                option.setEscapeItem(false);
                type.add(option);
            }else{
                SelectOption option = new SelectOption(d.datee.format(), '<span style="color:' + d.colorCode + ';">' + d.datee.format()+ '</span>', true);
                option.setEscapeItem(false);
                type.add(option);
            }
        }
        type.add(new SelectOption('AUTRES', System.Label.other_label));
        
        return type;
    }
    
    public List<selectOption> getDatesLivraisonLatestProposedOptions() {
        List<selectOption> type = new List<selectOption>();
        type.add(new SelectOption('AUCUN', System.Label.none_label)); 
        for(DateWithStatusSAP d : this.simulationController.getDatesLivraisonProposed()){
            SelectOption option = new SelectOption(d.datee.format(), '<span style="color:' + d.colorCode + ';">' + d.datee.format()+ '</span>');
            option.setEscapeItem(false);
            type.add(option);
        }
        type.add(new SelectOption('AUTRES', System.Label.other_label));
        
        return type;
    }
   
    public void updateDatePickerLivraisonTot(){
        if(this.dateLivraisonEarliestChoosed != null){
            if(this.dateLivraisonEarliestChoosed.equals('AUCUN')){
                
                this.simulationController.getOrder().Earliest_Delivery_Date__c = null;
                this.inputDatePickerLivraisonTotDisabled = true;
                return;
            }
            if(this.dateLivraisonEarliestChoosed.equals('AUTRES')){
                this.simulationController.getOrder().Earliest_Delivery_Date__c = null;
                this.inputDatePickerLivraisonTotDisabled = false;
                return;
            }
            if(!this.dateLivraisonEarliestChoosed.equals('AUTRES')){
                this.simulationController.getOrder().Earliest_Delivery_Date__c = (date.parse(this.dateLivraisonEarliestChoosed));
                this.inputDatePickerLivraisonTotDisabled = true;
                if(!VFC01_OrderTaking_Simulation.checkExistingDate(this.simulationController.getDatesLivraisonProposed(), this.dateLivraisonEarliestChoosed)){
                    this.dateLivraisonEarliestChoosed = 'AUTRES';
                    this.inputDatePickerLivraisonTotDisabled = false;
                }
            }    
        }       
    }
    
    public void updateDatePickerLivraisonTard(){
        if(this.dateLivraisonLatestChoosed != null){
            if(this.dateLivraisonLatestChoosed.equals('AUCUN')){           
                this.simulationController.getOrder().Latest_Delivery_Date__c = null;
                this.inputDatePickerLivraisonTardDisabled = true;
                return;
            }
            if(this.dateLivraisonLatestChoosed.equals('AUTRES')){           
                this.simulationController.getOrder().Latest_Delivery_Date__c = null;
                this.inputDatePickerLivraisonTardDisabled = false;
                return;
            }
            if(!this.dateLivraisonLatestChoosed.equals('AUTRES')){
                this.simulationController.getOrder().Latest_Delivery_Date__c = (date.parse(this.dateLivraisonLatestChoosed));
                this.inputDatePickerLivraisonTardDisabled = true;            
                if(!VFC01_OrderTaking_Simulation.checkExistingDate(this.simulationController.getDatesLivraisonProposed(), this.dateLivraisonLatestChoosed)){
                    this.dateLivraisonLatestChoosed = 'AUTRES';
                    this.inputDatePickerLivraisonTardDisabled = false;
                }                
            }
        }    
    }
    
    /** GETTER **/ 
    public String getDateLivraisonEarliestChoosed(){
        return this.dateLivraisonEarliestChoosed;
    }
    public String getDateLivraisonLatestChoosed(){
        return this.dateLivraisonLatestChoosed;
    }
    /** SETTER **/
    public void setDateLivraisonEarliestChoosed(String d){
        this.dateLivraisonEarliestChoosed = d;        
        
    }
    
    public void setDateLivraisonLatestChoosed(String d){
        this.dateLivraisonLatestChoosed = d;        
    }
}