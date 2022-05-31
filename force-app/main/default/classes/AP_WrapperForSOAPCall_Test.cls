@isTest(seeAllData = true)
public class AP_WrapperForSOAPCall_Test{

    public static testmethod AP_WrapperForSOAPCall.AP_WrapperDataForController getDataWrapper(){
        microsoftLobservicesSapV5.ZBAPI_CRM_BULKORDERResponse_element response_x;
        return new AP_WrapperForSOAPCall.AP_WrapperDataForController(response_x);
    }

    public static testmethod void testSafeStringCheck(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();
        Test.startTest();
        System.assert(!dataWrapper.safeStringCheck(null));
        System.assert(!dataWrapper.safeStringCheck(''));
        System.assert( dataWrapper.safeStringCheck('123'));
        System.assert( dataWrapper.safeStringCheck('ABC'));
        System.assert( dataWrapper.safeStringCheck('10A'));
        Test.stopTest();
    }

    public static testmethod void testConvertStringToDate(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();
        Test.startTest();
        System.assertEquals(null, dataWrapper.convertStringToDate(''));
        System.assertEquals(null, dataWrapper.convertStringToDate(null));
        System.assertEquals(null, dataWrapper.convertStringToDate('123'));
        System.assertEquals(null, dataWrapper.convertStringToDate('AAAAMMJJ'));
        System.assertEquals(Date.newInstance(2012, 10, 16), dataWrapper.convertStringToDate('20121016'));
        Test.stopTest();
    }

    public static testmethod void testConvertStringToTime(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();
        Test.startTest();
        System.assertEquals(null, dataWrapper.convertStringToTime(''));
        System.assertEquals(null, dataWrapper.convertStringToTime(null));
        System.assertEquals(null, dataWrapper.convertStringToTime('123'));
        System.assertEquals(null, dataWrapper.convertStringToTime('HHMMSS'));
        System.assertEquals(Time.newInstance(17, 25, 24, 0), dataWrapper.convertStringToTime('172524'));
        System.assertEquals(Time.newInstance(18, 30, 0 , 0), dataWrapper.convertStringToTime('179000')); // (^ ^)...
        Test.stopTest();
    }

    public static testmethod void testConvertStringsToDatetime(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();
        Test.startTest();
        System.assertEquals(null, dataWrapper.convertStringsToDatetime('', ''));
        System.assertEquals(null, dataWrapper.convertStringsToDatetime('', '123'));
        System.assertEquals(null, dataWrapper.convertStringsToDatetime('', null));
        System.assertEquals(null, dataWrapper.convertStringsToDatetime('H', ''));
        System.assertEquals(null, dataWrapper.convertStringsToDatetime(null, ''));
        System.assertEquals(Datetime.newInstance(2012, 10, 16), dataWrapper.convertStringsToDatetime('20121016', ''));
        System.assertEquals(null, dataWrapper.convertStringsToDatetime('', '172911'));
        System.assertEquals(Datetime.newInstance(2012, 10, 16, 17, 29, 11), dataWrapper.convertStringsToDatetime('20121016', '172911'));
        Test.stopTest();
    }

    public static testmethod void testConvertStringsToBoolean(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();
        Test.startTest();
        System.assert(!dataWrapper.convertStringToBoolean(''));
        System.assert(!dataWrapper.convertStringToBoolean(null));
        System.assert( dataWrapper.convertStringToBoolean('a'));
        System.assert( dataWrapper.convertStringToBoolean('ZZZZ'));
        Test.stopTest();
    }

    public static testmethod void testFetchDateLivraisonProposed(){
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataWrapper;
        microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE del_date_bapi;

        Test.startTest();
        datawrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();

        del_date_bapi                       = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE();
        del_date_bapi.ZBAPI_CRM_TAB_DATE    = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE[4];
        del_date_bapi.ZBAPI_CRM_TAB_DATE[0] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();
        del_date_bapi.ZBAPI_CRM_TAB_DATE[1] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();
        del_date_bapi.ZBAPI_CRM_TAB_DATE[2] = new microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE();

        del_date_bapi.ZBAPI_CRM_TAB_DATE[0].DEL_DATE = '20120926';
        del_date_bapi.ZBAPI_CRM_TAB_DATE[0].STATUS   = '2';
        del_date_bapi.ZBAPI_CRM_TAB_DATE[1].DEL_DATE = '20120927';
        del_date_bapi.ZBAPI_CRM_TAB_DATE[1].STATUS   = '1';
        del_date_bapi.ZBAPI_CRM_TAB_DATE[2].DEL_DATE = '20120928';
        del_date_bapi.ZBAPI_CRM_TAB_DATE[2].STATUS   = '3';

        dataWrapper.fetchDateLivraisonProposed(del_date_bapi);
        // Can't use System.assertEquals() because .equals() is not used by System.assertEquals()...
        System.assert(new DateWithStatusSAP(Date.newInstance(2012, 09, 26), 'orange') == dataWrapper.del_date_proposed[0]);
        System.assert(new DateWithStatusSAP(Date.newInstance(2012, 09, 27), 'green') == dataWrapper.del_date_proposed[1]);
        System.assert(new DateWithStatusSAP(Date.newInstance(2012, 09, 28), 'red') == dataWrapper.del_date_proposed[2]);

        datawrapper = AP_WrapperForSOAPCall_Test.getDataWrapper();

        del_date_bapi                       = new microsoftLobservicesSapV5.ArrayOfZBAPI_CRM_TAB_DATE();
        del_date_bapi.ZBAPI_CRM_TAB_DATE    = new List<microsoftLobservicesSapV5.ZBAPI_CRM_TAB_DATE>();

        dataWrapper.fetchDateLivraisonProposed(del_date_bapi);
        System.assertEquals(new List<DateWithStatusSAP>(), datawrapper.del_date_proposed);

        Test.stopTest();
    }

    /** TESTING METHODS TO TRANSCRIPT DATA FORMAT OF THE CONTROLLERS TO THE BAPI FORMAT **/

    public static testmethod void testconvertDateTimeToStringTime(){
        AP_WrapperForSOAPCall wrapper = new AP_WrapperForSOAPCall();
        Test.startTest();
        String time_x = wrapper.convertDateTimeToStringTime(datetime.newInstance(2008, 12, 1, 12, 30, 2));
        System.assertEquals('123002', time_x);
        System.assertNotEquals('12302', time_x);
        time_x = wrapper.convertDateTimeToStringTime(null);
        System.assertEquals(null, time_x);
        System.assertEquals('000000', wrapper.convertDateTimeToStringTime(datetime.newInstance(2008, 12, 1))); 
        Test.stopTest();        
    }

    public static testmethod void testconvertDateTimeToStringDate(){
        AP_WrapperForSOAPCall wrapper = new AP_WrapperForSOAPCall();
        Test.startTest();
        String date_x = wrapper.convertDateTimeToStringDate(datetime.newInstance(2008, 12, 1, 12, 30, 2));
        System.assertEquals('20081201', date_x);
        System.assertNotEquals('2008121', date_x);
        date_x = wrapper.convertDateTimeToStringDate(null);
        System.assertEquals(null, date_x);
        Test.stopTest(); 
    }

    public static testmethod void testconvertBooleanToString(){
        AP_WrapperForSOAPCall wrapper = new AP_WrapperForSOAPCall();
        Test.startTest();
        System.assertEquals('X', wrapper.convertBooleanToString(true));
        System.assertEquals('', wrapper.convertBooleanToString(false));
        System.assertEquals('', wrapper.convertBooleanToString(null));
    }

    public static testmethod void testconvertDateToString(){
        AP_WrapperForSOAPCall wrapper = new AP_WrapperForSOAPCall();
        Test.startTest();
        String date_x = wrapper.convertDateToString(date.newInstance(2008, 12, 1));
        System.assertEquals('20081201', date_x);
        System.assertNotEquals('2008121', date_x);
        date_x = wrapper.convertDateToString(null);
        System.assertEquals(null, date_x);
        Test.stopTest(); 
    }

    public static testmethod void testintegerToPaddedString(){
        AP_WrapperForSOAPCall wrapper = new AP_WrapperForSOAPCall();
        Test.startTest();
        System.assertEquals('02', wrapper.integerToPaddedString(2, 2));
        System.assertEquals('2', wrapper.integerToPaddedString(2, 1));
        System.assertEquals('2', wrapper.integerToPaddedString(2, 0));
        System.assertEquals('002', wrapper.integerToPaddedString(2, 3));
        Test.stopTest();
    }

    public static testmethod void testupdateApexMessagesWithEmptyList(){
        PageReference p = Page.VFP01_OrderTaking_Simulation_Step1;
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataForController = new AP_WrapperForSOAPCall.AP_WrapperDataForController(null);
        Test.setCurrentPage(p);
        Test.startTest();
        System.assertEquals(false, dataForController.updateApexMessages(null));
        System.assertEquals(true, ApexPages.getMessages().isEmpty());        
    }


    public static testmethod void testupdateApexMessagesWithValueOnList(){
        PageReference p = Page.VFP01_OrderTaking_Simulation_Step1;
        AP_WrapperForSOAPCall.AP_WrapperDataForController dataForController = new AP_WrapperForSOAPCall.AP_WrapperDataForController(null);
        AP_WrapperForSOAPCall.ReturnFields returnField_1 = new AP_WrapperForSOAPCall.ReturnFields();
        returnField_1.Type_x = 'E';
        returnField_1.Message = 'Error Message test';
        AP_WrapperForSOAPCall.ReturnFields returnField_2 = new AP_WrapperForSOAPCall.ReturnFields();
        returnField_2.Type_x = 'S';
        returnField_2.Message = 'Sucess Message test';
        AP_WrapperForSOAPCall.ReturnFields returnField_3 = new AP_WrapperForSOAPCall.ReturnFields();
        returnField_3.Type_x = 'W';
        returnField_3.Message = 'Warning Message test';
        AP_WrapperForSOAPCall.ReturnFields returnField_4 = new AP_WrapperForSOAPCall.ReturnFields();
        returnField_4.Type_x = 'A';
        returnField_4.Message = 'Abort Message test';
        AP_WrapperForSOAPCall.ReturnFields returnField_5 = new AP_WrapperForSOAPCall.ReturnFields();
        returnField_5.Type_x = 'I';
        returnField_5.Message = 'Info Message test';

        dataForController.returnFieldsList.add(returnField_1);
        dataForController.returnFieldsList.add(returnField_2);
        dataForController.returnFieldsList.add(returnField_3);
        dataForController.returnFieldsList.add(returnField_4);
        dataForController.returnFieldsList.add(returnField_5);
        Test.setCurrentPage(p);
        Test.startTest();
        System.assertEquals(true, dataForController.updateApexMessages(dataForController.returnFieldsList));
        System.assertEquals(false, ApexPages.getMessages().isEmpty());
        System.assertEquals(5, ApexPages.getMessages().size());
        System.assert(ApexPages.getMessages().get(0).getSummary().contains(returnField_1.Message));
        System.assert(ApexPages.getMessages().get(1).getSummary().contains(returnField_2.Message));
        System.assert(ApexPages.getMessages().get(2).getSummary().contains(returnField_3.Message));
        System.assert(ApexPages.getMessages().get(3).getSummary().contains(returnField_4.Message));
        System.assert(ApexPages.getMessages().get(4).getSummary().contains(returnField_5.Message));
        Test.stopTest();
    }
}