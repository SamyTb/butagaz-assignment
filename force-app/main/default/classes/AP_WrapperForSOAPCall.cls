public class AP_WrapperForSOAPCall {

    //RFC EndPoint for the webservice callout DUMMY just for testing
    public microsoftLobservicesSapV5.RfcEndpoint webserviceSOAP;
    public AP_WrapperDataForController responseForControllers;
    
    public AP_WrapperForSOAPCall(){
         webserviceSOAP = new microsoftLobservicesSapV5.RfcEndpoint();
         try{
            webserviceSOAP.endpoint_x = Custom_Settings__c.getInstance('OrderTaking_EndPointURL').value__c;
            //webserviceSOAP.endpoint_x = 'http://www.lodeblomme.be/log/index.php';
            
            Map<String,String> inputHttpHeaders = new Map<String, String>();
            
            String username = Custom_Settings__c.getInstance('OrderTaking_Username').value__c;
            String password = Custom_Settings__c.getInstance('OrderTaking_Password').value__c;
            Blob headerValue = Blob.valueOf( username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            inputHttpHeaders.put('Authorization', authorizationHeader);
            
            webserviceSOAP.inputHttpHeaders_x = inputHttpHeaders;
            //webserviceSOAP.timeout_x = 
        }catch(System.NullPointerException e){
            throw new CRMException('You have to set the Custom Setting named (EndPointURL_OrderTaking) to the end point of the order taking service cause by ' + e);
        }
    }
    
    /** INITIAL SIMULATION **/
    public AP_WrapperDataForController simulateCreationOrUpdateInitial(String actionCode, String soldTo, String shipTo, String orderNumber, String userCrm){
                                                                                                            
        /** CONSTRUCT REQUEST IN SOAP/BAPI FORMAT **/
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE ET_ORDER_DEL_DATE = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE(); 
              
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM ET_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM IT_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
     
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM IT_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM ET_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfBAPIRET2 RETURN_x = new microsoftLobservicesSapV5.ArrayOfBAPIRET2();
        //Do request and retrieve response
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        if (Test.isRunningTest()){
            response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                actionCode, '1', orderNumber, userCrm, 
                shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE, ET_ORDER_ITEMS,
                IT_ORDER, IT_ORDER_ITEMS, RETURN_x
           );
        } else {
            if(Custom_Settings__c.getInstance('OrderTaking_doCallOuts').value__c.equals('1')){
                //webserviceSOAP.endpoint_x = 'http://www.lodeblomme.be/log/index.php';
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                    actionCode, '1', orderNumber, userCrm, 
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE, ET_ORDER_ITEMS,
                    IT_ORDER, IT_ORDER_ITEMS, RETURN_x
               );
            }else{
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDERDummy(
                    actionCode, '1', orderNumber, userCrm, 
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE, ET_ORDER_ITEMS,
                    IT_ORDER, IT_ORDER_ITEMS, RETURN_x
               );
            }   
        }
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForControllers = new AP_WrapperDataForController(response_x);
       responseForControllers.fetchWithBAPIResponse();
       return responseForControllers;
    }
   
    /** OTHERS CUSTOME SIMULATIONS **/
    public AP_WrapperDataForController simulateCreationOrUpdate(String actionCode, String soldTo, String shipTo, String orderNumber, String userCrm,
                                                                                                             String materialNumber, String gaugeValue, String amount, String amount_curr, String quantity, String quantity_uom,
                                                                                                             String orderType, String delReq, String reference, Date ear_del_date, Date lat_del_date, String moment, String medContact,
                                                                                                             String reasonReport, String cust_text1, String cust_text2,
                                                                                                             Boolean cust_down, Boolean cust_urgent, Boolean cust_preempl, String orderOrigin, String custCall, Datetime order_date_time
                                                                                                 ){
        
        /** CONSTRUCT REQUEST IN SOAP/BAPI FORMAT **/
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE ET_ORDER_DEL_DATE = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE(); 
              
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM ET_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM IT_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        IT_ORDER_ITEMS.ZBAPISDITM_CRM = new microsoftLobservicesSapV5.ZBAPISDITM_CRM[1];
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0] = new microsoftLobservicesSapV5.ZBAPISDITM_CRM();
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].MATERIAL = materialNumber;
        //Due to problems on SAP side which can't distinguish between the zero value and none value, if the user send 0 on the gauge, by convention, we will send 999!!!
        if(gaugeValue != null){
            if(Integer.valueOf(gaugeValue) == 0){
                IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = 999;
            }else{
                IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = Integer.valueOf(gaugeValue);
            }
        }else{
            IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = null;
        }
        //IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = (gaugeValue != null) ? Integer.valueOf(gaugeValue) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].AMOUNT = (amount != null) ? Decimal.valueOf(amount) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].CURRENCY_x = amount_curr;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY = (quantity != null) ? Decimal.valueOf(quantity) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY_UOM = quantity_uom;
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM IT_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        IT_ORDER.ZBAPIORDER_CRM = new microsoftLobservicesSapV5.ZBAPIORDER_CRM[1];
        IT_ORDER.ZBAPIORDER_CRM[0] = new microsoftLobservicesSapV5.ZBAPIORDER_CRM();
        
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_TYPE = orderType;
        IT_ORDER.ZBAPIORDER_CRM[0].DEL_REQ = delReq;
        IT_ORDER.ZBAPIORDER_CRM[0].REFERENCE = reference;
        IT_ORDER.ZBAPIORDER_CRM[0].EARLIEST_DEL_DATE = convertDateToString(ear_del_date);
        IT_ORDER.ZBAPIORDER_CRM[0].LATEST_DEL_DATE = convertDateToString(lat_del_date);
        IT_ORDER.ZBAPIORDER_CRM[0].MOMENT = (moment.equals('00')) ? null : moment;
        IT_ORDER.ZBAPIORDER_CRM[0].MED_CONTACT = (medContact.equals('00')) ? null : medContact;
        IT_ORDER.ZBAPIORDER_CRM[0].REASON_DELAY = (reasonReport.equals('00')) ? null : reasonReport;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_1 = cust_text1;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_2 = cust_text2;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_DOWN = convertBooleanToString(cust_down);
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_URGENT = convertBooleanToString(cust_urgent);
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_PREEMPL = convertBooleanToString(cust_preempl);
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_ORIGIN = orderOrigin;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_CALL = custCall;
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_DATE = convertDateTimeToStringDate(order_date_time);
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_TIME = convertDateTimeToStringTime(order_date_time);
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM ET_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfBAPIRET2 RETURN_x = new microsoftLobservicesSapV5.ArrayOfBAPIRET2();
        //Do request and retrieve response
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        if (Test.isRunningTest()){
            response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                actionCode, '1', orderNumber, userCrm,
                shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
           );
        } else {
            if(Custom_Settings__c.getInstance('OrderTaking_doCallOuts').value__c.equals('1')){
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                    actionCode, '1', orderNumber, userCrm,
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
                );
            }else{
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDERDummy(
                    actionCode, '1', orderNumber, userCrm,
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
                );
            }    
        }
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForControllers = new AP_WrapperDataForController(response_x);
       responseForControllers.fetchWithBAPIResponse();
       return responseForControllers;
    }    
    
    /** UPSERT CREATION OR UPDATE **/
    public AP_WrapperDataForController upsertCreationOrUpdate(String actionCode, String mode, String soldTo, String shipTo, String orderNumber, String userCRM,
                                                                                                         String materialNumber, String gaugeValue, String amount, String amount_curr, String quantity, String quantity_uom,
                                                                                                         String orderType, String delReq, String reference, Date ear_del_date, Date lat_del_date, String moment, String medContact,
                                                                                                         String reasonReport, String cust_text1, String cust_text2,
                                                                                                         Boolean cust_down, Boolean cust_urgent, Boolean cust_preempl, String orderOrigin, String custCall, Datetime order_date_time
                                                                                                        ){
        /** CONSTRUCT REQUEST IN SOAP/BAPI FORMAT **/
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE ET_ORDER_DEL_DATE = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE();
              
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM ET_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM IT_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        IT_ORDER_ITEMS.ZBAPISDITM_CRM = new microsoftLobservicesSapV5.ZBAPISDITM_CRM[1];
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0] = new microsoftLobservicesSapV5.ZBAPISDITM_CRM();
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].MATERIAL = materialNumber;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = (gaugeValue != null) ? Integer.valueOf(gaugeValue) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].AMOUNT = (amount != null ) ? Decimal.valueOf(amount) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].CURRENCY_x = amount_curr;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY = (quantity != null) ? Decimal.valueOf(quantity) : null;
        IT_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY_UOM = quantity_uom;

        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM ET_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM IT_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        IT_ORDER.ZBAPIORDER_CRM = new microsoftLobservicesSapV5.ZBAPIORDER_CRM[1];
        IT_ORDER.ZBAPIORDER_CRM[0] = new microsoftLobservicesSapV5.ZBAPIORDER_CRM();
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_TYPE = orderType;
        IT_ORDER.ZBAPIORDER_CRM[0].DEL_REQ = delReq;
        IT_ORDER.ZBAPIORDER_CRM[0].REFERENCE = reference;
        IT_ORDER.ZBAPIORDER_CRM[0].EARLIEST_DEL_DATE = convertDateToString(ear_del_date);
        IT_ORDER.ZBAPIORDER_CRM[0].LATEST_DEL_DATE = convertDateToString(lat_del_date);
        IT_ORDER.ZBAPIORDER_CRM[0].MOMENT = (moment.equals('00')) ? null : moment;
        IT_ORDER.ZBAPIORDER_CRM[0].MED_CONTACT = (medContact.equals('00')) ? null : medContact;
        IT_ORDER.ZBAPIORDER_CRM[0].REASON_DELAY = (reasonReport.equals('00')) ? null : reasonReport;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_1 = cust_text1;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_2 = cust_text2;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_DOWN = convertBooleanToString(cust_down);
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_URGENT = convertBooleanToString(cust_urgent);
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_PREEMPL = convertBooleanToString(cust_preempl);
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_ORIGIN = orderOrigin;
        IT_ORDER.ZBAPIORDER_CRM[0].CUST_CALL = custCall;
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_DATE = convertDateTimeToStringDate(order_date_time);
        IT_ORDER.ZBAPIORDER_CRM[0].ORDER_TIME = convertDateTimeToStringTime(order_date_time);
        
        microsoftLobservicesSapV5.ArrayOfBAPIRET2 RETURN_x = new microsoftLobservicesSapV5.ArrayOfBAPIRET2();
        
        //Do request and retrieve response
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        if (Test.isRunningTest()){
            response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                actionCode, mode, orderNumber, userCrm,
                shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
           );
        } else {
            if(Custom_Settings__c.getInstance('OrderTaking_doCallOuts').value__c.equals('1')){
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                    actionCode, mode, orderNumber, userCrm,
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
               );
            }else{
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDERDummy(
                    actionCode, mode, orderNumber, userCrm,
                    shipTo, soldTo, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
               );
            }   
        }
          /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/
          responseForControllers = new AP_WrapperDataForController(response_x);                                                                                               
          responseForControllers.fetchWithBAPIResponse();                                                                                         
          return responseForControllers;
    }
    
    /** UPSERT DELETE **/
    public AP_WrapperDataForController upsertDelete(String actionCode, String orderNumber, String userCrm){
                                                                                                            
        /** CONSTRUCT REQUEST IN SOAP/BAPI FORMAT **/
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE ET_ORDER_DEL_DATE = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE(); 
              
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM ET_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM IT_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM IT_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM ET_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        
        microsoftLobservicesSapV5.ArrayOfBAPIRET2 RETURN_x = new microsoftLobservicesSapV5.ArrayOfBAPIRET2();
        //Do request and retrieve response
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        if (Test.isRunningTest()){
            response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                actionCode, '2', orderNumber, userCrm,
                null, null, ET_ORDER, ET_ORDER_DEL_DATE,
                ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
            );
        } else {
            if(Custom_Settings__c.getInstance('OrderTaking_doCallOuts').value__c.equals('1')){
                response_x = webserviceSOAP.ZBAPI_CRM_BULKORDER(
                    actionCode, '2', orderNumber, userCrm,
                    null, null, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
                );
             }else{
                 response_x = webserviceSOAP.ZBAPI_CRM_BULKORDERDummy(
                    actionCode, '2', orderNumber, userCrm,
                    null, null, ET_ORDER, ET_ORDER_DEL_DATE,
                    ET_ORDER_ITEMS, IT_ORDER, IT_ORDER_ITEMS, RETURN_x
                );
             }   
        }
       /** CONSTRUCT RESPONSE FOR CONTROLLERS  **/ 
       responseForControllers = new AP_WrapperDataForController(response_x);
       responseForControllers.fetchWithBAPIResponse();
       return responseForControllers;
    }
    
    public class ReturnFields {      
            public String Type_x;
            public String ID;
            public Integer Number_x;
            public String Message;
            public String LogNo;
            public Integer LogMsgNo;
            public String MessageV1;
            public String MessageV2;
            public String MessageV3;
            public String MessageV4;
            public String Parameter;
            public Integer Row;
            public String Field;
            public String System_x;
            
            public ApexPages.Severity getSeverityFromType(String type){
                if(type != null){
                    if(type.equals('E')){
                        return ApexPages.Severity.ERROR;
                    }else if(type.equals('S')){
                        return ApexPages.Severity.CONFIRM;
                    }else if(type.equals('W')){
                        return ApexPages.Severity.WARNING;
                    }else if(type.equals('I')){
                        return ApexPages.Severity.INFO;
                    }else if(type.equals('A')){
                        return ApexPages.Severity.ERROR;
                    }        
                }
                return ApexPages.Severity.INFO;
            }
    }
    
    //Wrap the data received from SAP (soap/bapi) format to a format that the controllers (VFC_OrderSimulation/Details) expect
    public class AP_WrapperDataForController{        
        //FOR THE SIMULATION MODE WE WILL DIRECTLY FETCH 'Input table 2 IT_ORDER-FIELDS' WITH response_x WITHOUT CONVERTING BAPI DATA TO CONTROLLER DATA (see simulateCreationOrUpdate call in VFC_OrderSimulation class)
        public microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        
        public String orderNumber;
        public String orderCenter;
      //public String EX_ORDER_ITEMS_GAUGE;
      //public Decimal EX_UNIT_PRICE;
      //public String EX_UNIT_PRICE_CURRENCY;         [FIELDS DON'T USED ON THE RESPONSE, THE SAME INFORMATION IS IN ORDER_ITEMS FIELDS]
      //public Decimal EX_TOT_QUANTITY;
      //public String EX_QUANTITY_UOM;
      //public Decimal EX_TOT_AMOUNT;     
      //public String EX_CURRENCY;
        public Integer autonomy;
        public Integer breakCount;
        public Date lastBreakDate;
        public String currentOrder;
        public Boolean preFillingDisabled;
        public Boolean majorationDisabled;
        public Boolean orderTypeDisabled;
      //public String delPostNumber;
        public String driver_text1;
        public String driver_text2;
      //public String EX_LOGISTIC_DATA;
      //public String EX_LOGISTIC_DESCRIP;
        public String restrictionVehicule;
        public Boolean limitationTonnage;
        public Decimal valeurLimitation;
        public Boolean borneDeporte;
        public Boolean derogPermanent;
        public Boolean miCharge;
        public Boolean derogProv;
        public Date dateEndDerog;
        public String conditionLiv;
        public Integer autonomyCalculated;
      //public String amountHTCalculated;
      
        public List<DateWithStatusSAP> del_date_proposed;
        
        public String materialNumber;
        public String gaugeValue;
        public String amount;
        public String currency_x;
        public String quantity;
        public String quantity_uom;
        
        public String orderType;
        public String del_req;
        public String reference;
        public String ear_del_date;
        public String lat_del_date;
        public String moment;
        public String medContact;
        public String reasonReport;
        public String cust_text1;
        public String cust_text2;
        public Boolean cust_down;
        public Boolean cust_urgent;
        public Boolean cust_preempl;
        public String orderOrigin;
        public String cust_call;
        public Datetime orderDateTime;
               
        public List<ReturnFields> returnFieldsList;
        
        public AP_WrapperDataForController(microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x) {
            //Init default values for some fields (mainly the default value for picklists)
            this.response_x = response_x;
            this.orderOrigin = 'TELC';
            this.cust_call = '0';
            this.orderType = 'FE';
            this.moment = '00';
            this.medContact = '00';
            this.reasonReport = '00';
            this.del_date_proposed = new List<DateWithStatusSAP>();
            this.returnFieldsList = new List<ReturnFields>();
        }
        
        public void fetchWithBAPIResponse(){
            if(response_x != null){
                this.orderNumber = response_x.EX_ORDER_NUMBER;
                this.orderCenter = response_x.EX_CCDE;
                this.autonomy = (response_x.EX_AUTONOMY != null ) ? Integer.valueOf(response_x.EX_AUTONOMY) : null;
                this.breakCount = (response_x.EX_BREAK_NB != null) ? Integer.valueOf(response_x.EX_BREAK_NB) : null;
                this.lastBreakDate = convertStringToDate(response_x.EX_BREAK_DATE); 
                this.currentOrder = response_x.EX_CURRENT_ORDER;
                this.preFillingDisabled = !(convertStringToBoolean(response_x.EX_CUST_PREEMPL)); 
                this.majorationDisabled = !(convertStringToBoolean(response_x.EX_CUST_URGENT));
                this.orderTypeDisabled =  !(convertStringToBoolean(response_x.EX_ORDER_TYPE_FLAG)); 
                this.driver_text1 = response_x.EX_DRIVER_TEXT_1;
                this.driver_text2 = response_x.EX_DRIVER_TEXT_2;
                this.restrictionVehicule = response_x.EX_RETRIC_VEHI;
                this.limitationTonnage = convertStringToBoolean(response_x.EX_LIMIT_TONN);
                this.valeurLimitation = response_x.EX_LIMIT_TONN_VALUE;
                this.borneDeporte = convertStringToBoolean(response_x.EX_BORNE_DEP);
                this.derogPermanent = convertStringToBoolean(response_x.EX_DEROG_PERM);
                this.miCharge = convertStringToBoolean(response_x.EX_LIV_CAM_MICHAR);
                this.derogProv = convertStringToBoolean(response_x.EX_DEROG_PROV);
                this.dateEndDerog = convertStringToDate(response_x.EX_DATE_FIN_DEROG);
                this.conditionLiv = response_x.EX_COND_EXPED;
                this.autonomyCalculated = (response_x.EX_AUTONOMY_CALC != null) ? Integer.valueOf(response_x.EX_AUTONOMY_CALC) : null;
                
                fetchDateLivraisonProposed(response_x.ET_ORDER_DEL_DATE);
                
                if(response_x.ET_ORDER_ITEMS != null && response_x.ET_ORDER_ITEMS.ZBAPISDITM_CRM != null && response_x.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0] != null){
                    microsoftLobservicesSapV5.ZBAPISDITM_CRM itemInfo = response_x.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0];
                    this.materialNumber = itemInfo.MATERIAL;
                    this.gaugeValue = (itemInfo.GAUGE != null ) ? String.valueOf(itemInfo.GAUGE) : null;
                    this.amount = (itemInfo.AMOUNT != null) ? String.valueOf(itemInfo.AMOUNT) : null;
                    this.currency_x = itemInfo.CURRENCY_x;
                    this.quantity = (itemInfo.QUANTITY != null) ? String.valueOf(itemInfo.QUANTITY) : null;
                    this.quantity_uom = itemInfo.QUANTITY_UOM;
                }
                
                if(response_x.ET_ORDER != null && response_x.ET_ORDER.ZBAPIORDER_CRM != null && response_x.ET_ORDER.ZBAPIORDER_CRM[0] != null){
                    microsoftLobservicesSapV5.ZBAPIORDER_CRM orderInfo = response_x.ET_ORDER.ZBAPIORDER_CRM[0];
                    this.orderType = (safeStringCheck(orderInfo.ORDER_TYPE)) ? orderInfo.ORDER_TYPE : this.orderType;
                    this.del_req = orderInfo.DEL_REQ;
                    this.reference = orderInfo.REFERENCE;
                    Date ear = convertStringToDate(orderInfo.EARLIEST_DEL_DATE);
                    Date lat = convertStringToDate(orderInfo.LATEST_DEL_DATE);
                    this.ear_del_date = (ear != null) ? ear.format() : 'AUTRES' ;
                    this.lat_del_date = (lat != null) ? lat.format() : 'AUTRES' ;
                    this.moment = (safeStringCheck(orderInfo.MOMENT)) ? orderInfo.MOMENT : this.moment;
                    this.medContact = (safeStringCheck(orderInfo.MED_CONTACT)) ? orderInfo.MED_CONTACT : this.medContact;
                    this.reasonReport = (safeStringCheck(orderInfo.REASON_DELAY)) ? orderInfo.REASON_DELAY : this.reasonReport;
                    this.cust_text1 = orderInfo.CUST_TEXT_1;
                    this.cust_text2 = orderInfo.CUST_TEXT_2;
                    this.cust_down = convertStringToBoolean(orderInfo.CUST_DOWN);
                    this.cust_preempl = convertStringToBoolean(orderInfo.CUST_PREEMPL);
                    this.cust_urgent = convertStringToBoolean(orderInfo.CUST_URGENT);
                    this.orderOrigin = (safeStringCheck(orderInfo.ORDER_ORIGIN)) ? orderInfo.ORDER_ORIGIN : this.orderOrigin;
                    this.cust_call = (safeStringCheck(orderInfo.CUST_CALL)) ? orderInfo.CUST_CALL : this.cust_call;
                    this.orderDateTime = convertStringsToDatetime(orderInfo.ORDER_DATE, orderInfo.ORDER_TIME);
                }
                
                fetchReturnFields(response_x.RETURN_x);
           }     
        }
        
        /** METHODS TO TRANSCRIPT DATA OF BAPI FORMAT TO DATA FOR THE CONTROLLERS **/
    
        public boolean safeStringCheck(String s){
            return s!= null && !s.equals('');
        }
        
        // input format --> AAAAMMJJ
        public Date convertStringToDate(String s){
            if(s != null && !s.equals('00000000')){
                Pattern p = Pattern.compile('^(\\d{4})(\\d{2})(\\d{2})$');
                Matcher m = p.matcher(s);
                if(m.find()){
                    return Date.newInstance(Integer.valueOf(m.group(1)), Integer.valueOf(m.group(2)), Integer.valueOf(m.group(3)));
                }else{
                    return null;
                }
            }else{    
                return null;
            }
        }
        
        // input format --> HHMMSS
        public Time convertStringToTime(String s){
            if(s != null && !s.equals('000000')){
                Pattern p = Pattern.compile('^(\\d{2})(\\d{2})(\\d{2})$');
                Matcher m = p.matcher(s);
                if(m.find()){
                    return Time.newInstance(Integer.valueOf(m.group(1)), Integer.valueOf(m.group(2)), Integer.valueOf(m.group(3)), 0);
                }else{
                    return null;
                }
            }else{    
                return null;
            }
        }
        
        // '0' --> false , '1' --> true  
        public Boolean convertStringToBoolean(String s){
            if(s != null && s.length() > 0){
                return true;
            }else{
                return false;
            }
        }
        
        // date : AAAAMMJJ, time : HHMMSS 
        public Datetime convertStringsToDatetime(String d, String t){
            Date date_x = convertStringToDate(d);
            Time time_x = convertStringToTime(t);
            if(date_x != null && time_x != null){
                return datetime.newInstance(date_x, time_x);
            }
            else if(date_x != null){
                return datetime.newInstance(date_x.year(), date_x.month(), date_x.day());
            }    
            return null;
        }    
        
        public void fetchDateLivraisonProposed(microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE del_date_bapi){
            if(del_date_bapi != null && del_date_bapi.ZBAPI_CRM_TAB_DATE != null ){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'ZBAPI_CRM_TAB_DATE received ' + del_date_bapi.ZBAPI_CRM_TAB_DATE, ''));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Size of ZBAPI_CRM_TAB_DATE received ' + del_date_bapi.ZBAPI_CRM_TAB_DATE.size(), ''));
                for(microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE date_x : del_date_bapi.ZBAPI_CRM_TAB_DATE){
                    if(date_x != null){
                        //Date dd = date.parse(date_x.DEL_DATE);
                        Date dd = convertStringToDate(date_x.DEL_DATE);
                        if( dd != null){
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'date received ' + dd.format() + 'with status ' + DateWithStatusSAP.getColorCodeFromStatus(date_x.STATUS), ''));
                            DateWithStatusSAP d = new DateWithStatusSAP(dd, DateWithStatusSAP.getColorCodeFromStatus(date_x.STATUS));
                            this.del_date_proposed.add(d);
                        }
                    }
                }
            }
        }
        
        public void fetchReturnFields(microsoftLobservicesSapV5.ArrayOfBAPIRET2 returnFieldsListBapi){
            if( returnFieldsListBapi != null && returnFieldsListBapi.BAPIRET2 != null){
                for(microsoftLobservicesSapV5.BAPIRET2 returnFields : returnFieldsListBapi.BAPIRET2){
                    ReturnFields r  = new ReturnFields();
                    r.Type_x = returnFields.TYPE_x;
                    r.ID =  returnFields.ID;
                    r.Number_x = returnFields.NUMBER_x;
                    r.Message = returnFields.MESSAGE;
                    r.LogNo = returnFields.LOG_NO;
                    r.LogMsgNo = returnFields.LOG_MSG_NO;
                    r.MessageV1 = returnFields.MESSAGE_V1;
                    r.MessageV2 = returnFields.MESSAGE_V2;
                    r.MessageV3 = returnFields.MESSAGE_V3;
                    r.MessageV4 = returnFields.MESSAGE_V4;
                    r.Parameter = returnFields.PARAMETER;
                    r.Row = returnFields.ROW;
                    r.Field = returnFields.FIELD;
                    r.System_x = returnFields.SYSTEM_x;
                    this.returnFieldsList.add(r);
                }
            }
        }
        
        public boolean updateApexMessages(List<AP_WrapperForSOAPCall.ReturnFields> returnFieldsList){
           ApexPages.getMessages().clear();     
           if(returnFieldsList != null){
               for(AP_WrapperForSOAPCall.ReturnFields ret : returnFieldsList){
                       if(ret.Type_x != null){
                           ApexPages.Severity severity = ret.getSeverityFromType(ret.Type_x);
                           String summary = System.Label.sap_message + ' : ' + ret.Message;
                           String detail = System.Label.details_message + ' --> ID : ' + ret.ID + ', NUMBER : ' + ret.Number_x + ', LOG_NO : ' + ret.LogNo
                                        + ', LOG_MSG_NO : ' + ret.LogMsgNo + ', MESSAGE V1 : ' + ret.MessageV1 + ', MESSAGE V2 : ' + ret.MessageV2
                                        + ', MESSAGE V3 : ' + ret.MessageV3 + ', MESSAGE V4 : ' + ret.MessageV4 + ', PARAM : ' + ret.Parameter + ', ROW : ' + ret.Row 
                                        + ', FIELD : ' + ret.Field + ', SYSTEM : ' + ret.System_x;               
                           ApexPages.addMessage(new ApexPages.Message(severity, summary, detail));
                       }    
               }
            }   
           return ApexPages.hasMessages(ApexPages.Severity.ERROR);
        }  
    }
    
    /** METHODS TO TRANSCRIPT DATA FORMAT OF THE CONTROLLERS TO THE BAPI FORMAT **/
    public String convertDateTimeToStringTime(Datetime d){
        String s = null;
        if(d != null){
            s = integerToPaddedString(d.hour(), 2) 
                + integerToPaddedString(d.minute(), 2)
                + integerToPaddedString(d.second(), 2);        
        }
        return s;
    }
    
    public String convertDateTimeToStringDate(Datetime d){
        String s = null;
        if(d != null){
            s = integerToPaddedString(d.year(), 4) 
                 + integerToPaddedString(d.month(), 2) 
                 + integerToPaddedString(d.day(), 2);               
        }
        return s;
    }
    
    public String convertBooleanToString(Boolean b){
        // WE HAVE TO BE SURE WHAT IS THE VALUE THAT WE CAN RECEIVE FROM CUST_DOWN....
        if(b != null && b){
            return 'X';
        }else{
            return '';
        }   
        /**if(b != null){
            if(b){
                return '1';
            }else{
                return '0';
            }
        }
        return '0';**/
    }
 
    public String convertDateToString(Date d){
        String s = null;
        if(d != null){
             s = integerToPaddedString(d.year(), 4) 
                 + integerToPaddedString(d.month(), 2) 
                 + integerToPaddedString(d.day(), 2);       
        }
        return s;
    }

     public String integerToPaddedString(Integer i, Integer minSize) {
        String s = String.valueOf(i);
        while (s.length() < minSize) {
            s = '0' + s;
        }
        return s;
    }
}