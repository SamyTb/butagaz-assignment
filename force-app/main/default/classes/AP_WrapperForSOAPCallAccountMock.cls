global class AP_WrapperForSOAPCallAccountMock implements WebServiceMock{

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
            microsoftLobservicesSapACC200703Rfc.ZBAPI_CRM_COMPTEResponse_element response_x  = new microsoftLobservicesSapACC200703Rfc.ZBAPI_CRM_COMPTEResponse_element();
            response_x.EX_CONTROL = 'OK';
            
            microsoftLobservicesSapACC200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapACC200703Types.ArrayOfBAPIRET2();
            list<microsoftLobservicesSapACC200703Types.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSapACC200703Types.BAPIRET2>();
            microsoftLobservicesSapACC200703Types.BAPIRET2 BAPIRET2 = new microsoftLobservicesSapACC200703Types.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;

            
            response.put('response_x', response_x);
            

        }


}