global class AP_WrapperForSOAPCallContractMock implements WebServiceMock{

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
            microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element response_x  = new microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element();
            response_x.EX_CONTROL = 'OK';
            
            microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2();
            list<microsoftLobservicesSapCONTRACTTypes.BAPIRET2> lBAPIRET2 = new list<microsoftLobservicesSapCONTRACTTypes.BAPIRET2>();
            microsoftLobservicesSapCONTRACTTypes.BAPIRET2 BAPIRET2 = new microsoftLobservicesSapCONTRACTTypes.BAPIRET2();
            BAPIRET2.MESSAGE = 'freddy message';
            lBAPIRET2.add(BAPIRET2);
            ET_RETURN.BAPIRET2 = lBAPIRET2;
            response_x.ET_RETURN = ET_RETURN;
            
            response.put('response_x', response_x);
          

        }

}