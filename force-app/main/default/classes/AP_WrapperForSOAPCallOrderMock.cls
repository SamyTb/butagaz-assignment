global class AP_WrapperForSOAPCallOrderMock implements WebServiceMock{
    
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
            microsoftLobservicesSapCOMMANDESRfc.ZBAPI_CRM_COMMANDEResponse_element response_x  = new microsoftLobservicesSapCOMMANDESRfc.ZBAPI_CRM_COMMANDEResponse_element();
            response_x.EX_CONTROL = 'KO';
            
            microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2();
            list<microsoftLobservicesSapCOMMANDESTypes.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSapCOMMANDESTypes.BAPIRET2>();
            microsoftLobservicesSapCOMMANDESTypes.BAPIRET2 BAPIRET2 = new microsoftLobservicesSapCOMMANDESTypes.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;
            
            response.put('response_x', response_x);

        }
}