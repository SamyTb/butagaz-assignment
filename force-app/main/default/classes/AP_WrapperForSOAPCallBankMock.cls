global class AP_WrapperForSOAPCallBankMock implements WebServiceMock{

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
            microsoftLobservicesSapBANQUERfc.ZBAPI_CRM_BANQUEResponse_element response_x  = new microsoftLobservicesSapBANQUERfc.ZBAPI_CRM_BANQUEResponse_element();
            response_x.EX_CONTROL = 'KO';
            
            microsoftLobservicesSapBANQUETypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapBANQUETypes.ArrayOfBAPIRET2();
            list<microsoftLobservicesSapBANQUETypes.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSapBANQUETypes.BAPIRET2>();
            microsoftLobservicesSapBANQUETypes.BAPIRET2 BAPIRET2 = new microsoftLobservicesSapBANQUETypes.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;

            
            response.put('response_x', response_x);
            

        }

}