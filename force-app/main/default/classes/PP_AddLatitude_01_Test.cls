@isTest
class PP_AddLatitude_01_Test{
    public static testmethod void testAddLatitude(){
        Test.startTest();

        PP_AddLatitude_01 pprq;
        Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;

        pprq = new PP_AddLatitude_01();
        inputParams = new Map<String,Object>();
        inputParams.put('ExtraScore', 5.0);
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(5.0, returnMap.get('NewScore'));

        pprq = new PP_AddLatitude_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentScore', 1.4);
        inputParams.put('ExtraScore', 2.3);
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(3.7, returnMap.get('NewScore'));
        
        // Just for coverage...
        Process.PluginDescribeResult coverage = pprq.describe();

        Test.stopTest();
    }
}