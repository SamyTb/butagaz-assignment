@isTest
global class AP_WrapperForSOAPCallCDSMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
		{
            microsoftLobservicesSap200703Rfc.ZBAPI_CRM_CDSResponse_element response_x  = new microsoftLobservicesSap200703Rfc.ZBAPI_CRM_CDSResponse_element();    

            response_x.EX_CONTROL = 'KO';

            microsoftLobservicesSap200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSap200703Types.ArrayOfBAPIRET2();
            list<microsoftLobservicesSap200703Types.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSap200703Types.BAPIRET2>();
            microsoftLobservicesSap200703Types.BAPIRET2 BAPIRET2 = new microsoftLobservicesSap200703Types.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;

            microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS ET_STEP_STATUS = new microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS();
            list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS> lZBAPI_CRM_CDS_STATUS = new list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS>();
            microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS ZBAPI_CRM_CDS_STATUS1 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS();
            ZBAPI_CRM_CDS_STATUS1.STEP = 'STEP 1';
            ZBAPI_CRM_CDS_STATUS1.STATUS = 'OK';
            microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS ZBAPI_CRM_CDS_STATUS2 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS();
            ZBAPI_CRM_CDS_STATUS2.STEP = 'STEP 2';
            ZBAPI_CRM_CDS_STATUS2.STATUS = 'KO';
            microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS ZBAPI_CRM_CDS_STATUS3 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS();
            ZBAPI_CRM_CDS_STATUS3.STEP = 'STEP 3';
            ZBAPI_CRM_CDS_STATUS3.STATUS = 'KO';
            lZBAPI_CRM_CDS_STATUS.add(ZBAPI_CRM_CDS_STATUS1);
            lZBAPI_CRM_CDS_STATUS.add(ZBAPI_CRM_CDS_STATUS2);
            lZBAPI_CRM_CDS_STATUS.add(ZBAPI_CRM_CDS_STATUS3);
            ET_STEP_STATUS.ZBAPI_CRM_CDS_STATUS = lZBAPI_CRM_CDS_STATUS;
            response_x.ET_STEP_STATUS = ET_STEP_STATUS;

            response.put('response_x', response_x);
           
        }
}