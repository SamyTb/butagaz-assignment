@isTest
global class AP_SAPWebServiceMock implements WebServiceMock{
    global void doInvoke(
        Object stub,
        Object request_obj,
        Map<String, Object> response,
        String endpoint, 
        String soapAction,
        String requestName, 
        String responseNS,
        String responseName,
        String responseType
    ){
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDER_element request = (microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDER_element) request_obj;
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element respElement = new microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element();

        // Retrieve variables from the request (We're pretending we're SAP!)
        String IM_ACTION       = request.IM_ACTION;
        String IM_MODE         = request.IM_MODE;
        String IM_ORDER_NUMBER = request.IM_ORDER_NUMBER;
        String IM_ORDER_USER   = request.IM_ORDER_USER;
        String IM_SHIP_TO      = request.IM_SHIP_TO;
        String IM_SOLD_TO      = request.IM_SOLD_TO;

        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM ET_ORDER              = request.ET_ORDER;
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE ET_ORDER_DEL_DATE = request.ET_ORDER_DEL_DATE;
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM ET_ORDER_ITEMS        = request.ET_ORDER_ITEMS;
        microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM IT_ORDER              = request.IT_ORDER;
        microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM IT_ORDER_ITEMS        = request.IT_ORDER_ITEMS;
        microsoftLobservicesSapV5.ArrayOfBAPIRET2 RETURN_x                    = request.RETURN_x;

        // Actually deliver a response

        //init ET_ORDER_DEL_DATE
        respElement.ET_ORDER_DEL_DATE = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE();
        respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE[4];
        respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[0] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();
        respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[1] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();
        respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[2] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();

        //init ET_ORDER_ITEMS
        respElement.ET_ORDER_ITEMS = new microsoftLobservicesSapV5.ArrayOfZBAPISDITM_CRM();
        respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM = new microsoftLobservicesSapV5.ZBAPISDITM_CRM[1];
        respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0] = new microsoftLobservicesSapV5.ZBAPISDITM_CRM();          

        //init ET_ORDER
        respElement.ET_ORDER = new microsoftLobservicesSapV5.ArrayOfZBAPIORDER_CRM();
        respElement.ET_ORDER.ZBAPIORDER_CRM = new microsoftLobservicesSapV5.ZBAPIORDER_CRM[1];
        respElement.ET_ORDER.ZBAPIORDER_CRM[0] = new microsoftLobservicesSapV5.ZBAPIORDER_CRM();
        
        //init RETURN_x
        respElement.RETURN_x = new microsoftLobservicesSapV5.ArrayOfBAPIRET2();
        respElement.RETURN_x.BAPIRET2 = new microsoftLobservicesSapV5.BAPIRET2[2];
        respElement.RETURN_x.BAPIRET2[0] = new microsoftLobservicesSapV5.BAPIRET2();
        respElement.RETURN_x.BAPIRET2[1] = new microsoftLobservicesSapV5.BAPIRET2();

        // SCENARIO: 1 
        // MODE:     Simulation
        // ACTION:   Creation

        if(IM_ACTION.equals('C') && IM_MODE.equals('1')){
            respElement.EX_CCDE = '201';
            respElement.EX_AUTONOMY = 40;
            respElement.EX_AUTONOMY_CALC = 60;
            respElement.EX_BREAK_NB= 3;
            respElement.EX_BREAK_DATE = '20121212';
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = 40;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].AMOUNT = 1500;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].CURRENCY_x = 'EUR';
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY = 100;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY_UOM = 'TO';
            //define delivery date proposed
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[0].DEL_DATE = '20120926';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[0].STATUS = '2';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[1].DEL_DATE = '20120927';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[1].STATUS = '1';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[2].DEL_DATE = '20120928';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[2].STATUS = '3';
            
            respElement.EX_CUST_PREEMPL = '1';
            respElement.EX_CUST_URGENT = '';
            //respElement.ET_ORDER.ZBAPISD_CRM[0].CUST_DOWN = '1';

            respElement.EX_ORDER_TYPE_FLAG = '0';
            respElement.EX_DRIVER_TEXT_1 = 'Driver text 1';
            respElement.EX_DRIVER_TEXT_2 = 'Driver text 2';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_1 = 'Cust text 1';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_2 = 'Cust text 2';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].ORDER_DATE = '20121003';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].ORDER_TIME = '133969';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].MOMENT = '';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].LATEST_DEL_DATE =   '20120928';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].EARLIEST_DEL_DATE = '00000000';
            
            respElement.EX_RETRIC_VEHI = 'D';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].ORDER_ORIGIN = 'DFUE';

            respElement.RETURN_x.BAPIRET2[0].TYPE_x = 'W';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE = 'an error message for testing';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE_V1 = 'V1 message info';
            
            respElement.RETURN_x.BAPIRET2[1].TYPE_x = 'I';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE = 'an info message for testing';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE_V1 = 'V1 message info';
            
            respElement.RETURN_x.BAPIRET2[1].TYPE_x = 'W';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE = 'a warning message for testing';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE_V1 = 'V1 message info';
        } 

        // SCENARIO: 2
        // MODE:     Simulation
        // ACTION:   Update

        if(IM_ACTION.equals('U') && IM_MODE.equals('1')){
            // FOR TESTING WE SENT ONLY THE FIELDS THAT WE DIDNT SAVE IN SFDC SIDE
            
            //respElement.EX_ORDER_NUMBER = 'DUMMY Order Number SAP';
            respElement.EX_CCDE = '201';
            respElement.EX_AUTONOMY = 30;
            respElement.EX_AUTONOMY_CALC = 60;
            respElement.EX_BREAK_NB= 2;
            respElement.EX_BREAK_DATE = '00000000';
            //respElement.EX_CURRENT_ORDER = 'NumComm';
            respElement.EX_CUST_PREEMPL = '1';
            respElement.EX_CUST_URGENT = '0';
            respElement.EX_ORDER_TYPE_FLAG = '0';
            respElement.EX_DRIVER_TEXT_1 = 'Driver text up 1';
            respElement.EX_DRIVER_TEXT_2 = 'Driver text up 2';
            respElement.EX_RETRIC_VEHI = 'D';
            //define delivery date proposed
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[0].DEL_DATE = '20121001';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[0].STATUS = '2';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[1].DEL_DATE = '20121002';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[1].STATUS = '1';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[2].DEL_DATE = '20121003';
            respElement.ET_ORDER_DEL_DATE.ZBAPI_CRM_TAB_DATE[2].STATUS = '3';

            //respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].MATERIAL = 'MatNumber'; 
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].GAUGE = 20;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].AMOUNT = 1600;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].CURRENCY_x = 'EUR';
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY = 200;
            respElement.ET_ORDER_ITEMS.ZBAPISDITM_CRM[0].QUANTITY_UOM = 'TO';



            respElement.ET_ORDER.ZBAPIORDER_CRM[0].ORDER_TYPE = 'PR';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].DEL_REQ = 'chauffeur';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].REFERENCE = '187984';
            //respElement.ET_ORDER.ZBAPIORDER_CRM[0].EARLIEST_DEL_DATE = '';
            //respElement.ET_ORDER.ZBAPIORDER_CRM[0].LATEST_DEL_DATE = '';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].MOMENT = 'APRES-MIDI';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].MED_CONTACT = '03';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].REASON_DELAY = 'B';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_1 = 'Cust text 1';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_TEXT_2 = 'Cust text 2';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_DOWN = '1';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_URGENT = '1';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_PREEMPL = '0';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].ORDER_ORIGIN = 'DFUE';
            respElement.ET_ORDER.ZBAPIORDER_CRM[0].CUST_CALL = '1';


        }

        // SCENARIO: 3 
        // MODE:     Upsert (== Vrai)
        // ACTION:   Creation

        if(IM_ACTION.equals('C') && IM_MODE.equals('2')){
            respElement.EX_ORDER_NUMBER = 'DUMMY' + datetime.now();
            respElement.RETURN_x.BAPIRET2[0].TYPE_x = 'S';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE = 'a sucess message received upsertCreation for testing';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE_V1 = 'V1 message error ';

            respElement.RETURN_x.BAPIRET2[1].TYPE_x = 'W';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE = 'a warning message received upsertCreation for testing';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE_V1 = 'V1 message error ';
        }

        // SCENARIO: 4 
        // MODE:     Upsert (== Vrai)
        // ACTION:   Update

        if(IM_ACTION.equals('U') && IM_MODE.equals('2')){
            respElement.EX_ORDER_NUMBER = 'DUMMY' + datetime.now();
            respElement.RETURN_x.BAPIRET2[0].TYPE_x = 'E';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE = 'an error message received upsertUpdate for testing';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE_V1 = 'V1 message error ';

            respElement.RETURN_x.BAPIRET2[1].TYPE_x = 'W';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE = 'a warning message received upsertUpdate for testing';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE_V1 = 'V1 message error ';
        }

        // SCENARIO: 5 
        // MODE:     Upsert (== Vrai)
        // ACTION:   Delete

        if(IM_ACTION.equals('D') && IM_MODE.equals('2')){
            respElement.EX_ORDER_NUMBER = 'DUMMY Order Number SAP';
            respElement.RETURN_x.BAPIRET2[0].TYPE_x = 'S';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE = 'a success message received upsertDelete for testing';
            respElement.RETURN_x.BAPIRET2[0].MESSAGE_V1 = 'V1 message error ';
            
            respElement.RETURN_x.BAPIRET2[1].TYPE_x = 'W';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE = 'a warning message received upsertDelete for testing';
            respElement.RETURN_x.BAPIRET2[1].MESSAGE_V1 = 'V1 message error ';
        }

        response.put('response_x', respElement);
    }
}