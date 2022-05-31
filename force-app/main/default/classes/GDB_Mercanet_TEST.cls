@isTest
private class GDB_Mercanet_TEST {

    @isTest
    static void testExecuteRequest() {
        GDB_TestDataFactory.createCustomSettings();

        Map<String, Object[]> details = GDB_Mercanet.getMultiplePaymentDetails(300, 'GDB1234567121', DateTime.Now(), false);
        details = GDB_Mercanet.getMultiplePaymentDetails(300, 'GDB1234567121', DateTime.Now(), true);

        GDB_Mercanet mercanetHelperSinglePayment = new GDB_Mercanet();
        mercanetHelperSinglePayment.prepareParameters(null, null, null, null, null, null, null);
        mercanetHelperSinglePayment.prepareParameters(null, null, DateTime.Now(), null, null, null, null);
        mercanetHelperSinglePayment.prepareParameters(300, 'EUR', DateTime.Now(), 'GDB1234567121', '1111', false, 'gdb-test@yopmail.com');
        GDB_Mercanet.Response responseSinglePayment = mercanetHelperSinglePayment.executeRequest();

        GDB_Mercanet mercanetHelperMultiplePayment = new GDB_Mercanet();
        mercanetHelperMultiplePayment.prepareParameters(300, 'EUR', DateTime.Now(), 'GDB12345665121', '1111', true, 'gdb-test@yopmail.com');
        GDB_Mercanet.Response responseMultiplePayment = mercanetHelperMultiplePayment.executeRequest();

        GDB_Mercanet mercanetHelper = new GDB_Mercanet();
        GDB_Mercanet.Response response = mercanetHelper.executeRequest();

        mercanetHelper.setReturnUrl('');
    }

    @isTest
    static void testResponse() {
        GDB_Mercanet.Response testResponse = new GDB_Mercanet.Response();
        String redirectionUrl = testResponse.getRedirectionUrl();
        String redirectionVersion = testResponse.getRedirectionVersion();
        String redirectionData = testResponse.getRedirectionData();
        String redirectionStatusCode = testResponse.getRedirectionStatusCode();
        String redirectionStatusMessage = testResponse.getRedirectionStatusMessage();
        String seal = testResponse.getSeal();
        Boolean isValid = testResponse.isValid();
    }

    @isTest
    static void testFraudData() {
        GDB_Mercanet.FraudData fraudData = new GDB_Mercanet.FraudData();
        List<Map<String, Object>> riskManagementDynamicSettingList = fraudData.getRiskManagementDynamicSettingList();
        List<String> bypassCtrlList = fraudData.getBypassCtrlList();
    }

    @isTest
    static void testPostResponse() {
        GDB_Mercanet.PostResponse testPostResponse = new GDB_Mercanet.PostResponse('d', 's');
        Boolean isValid = testPostResponse.isValid();
        String getTransactionReference = testPostResponse.getTransactionReference();
        String getTransactionId = testPostResponse.getTransactionId();
        String getAuthorisationId = testPostResponse.getAuthorisationId();
    }
}