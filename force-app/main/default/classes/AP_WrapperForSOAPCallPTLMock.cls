global class AP_WrapperForSOAPCallPTLMock implements WebServiceMock{

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
            microsoftLobservicesSapPTL200703Rfc.ZBAPI_CRM_PTLResponse_element response_x  = new microsoftLobservicesSapPTL200703Rfc.ZBAPI_CRM_PTLResponse_element();
            response_x.EX_CONTROL = 'OK';
            
            microsoftLobservicesSapPTL200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapPTL200703Types.ArrayOfBAPIRET2();
            list<microsoftLobservicesSapPTL200703Types.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSapPTL200703Types.BAPIRET2>();
            microsoftLobservicesSapPTL200703Types.BAPIRET2 BAPIRET2 = new microsoftLobservicesSapPTL200703Types.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;

            
            response.put('response_x', response_x);

        }

}