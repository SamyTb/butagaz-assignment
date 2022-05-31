public class RestApiLogging {
	// Log API request and response
    @future
    public static void logRestApiCall(Map<String,String> header, string httpMethod, Map<String,String> params, string remoteAddress, Blob requestBody, string requestURI, string resourcePath, string response){
        //System.debug(logginglevel.WARN,'### logRestApiCall');

        String sLogCall = AP_PricingUtilities.getCustomSettingValue('TrackRestAPICalls');

        if(sLogCall == 'true'){
	        string sHeader = '';
	        for (string headerKey : header.keySet())
	        {
	            sHeader += headerKey + '=' + header.get(headerKey) + ',';
	        }
	        sHeader = sHeader.removeEnd(',');

	        string sParams = '';
	        for (string paramsKey : params.keySet())
	        {
	            sParams += paramsKey + '=' + params.get(paramsKey) + ',';
	        }
	        sParams = sParams.removeEnd(',');

	        Rest_API_Log__c oRestAPILog = new Rest_API_Log__c(
	            Request_Header__c = sHeader,
	            Request_HttpMethod__c = httpMethod,
	            Request_Params__c = sParams,
	            Request_Remote_Address__c = remoteAddress,
	            Request_Body__c = requestBody == null ? '' : requestBody.toString(),
	            Request_URI__c = requestURI,
	            Request_Resource_Path__c = resourcePath,
	            Response__c = response
	        );
	        insert oRestAPILog;
	    }
    }
}