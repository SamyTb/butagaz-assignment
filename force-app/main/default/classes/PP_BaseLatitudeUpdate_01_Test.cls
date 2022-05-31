@isTest
class PP_BaseLatitudeUpdate_01_Test{
    public static testmethod void testNewMessage(){
        Test.startTest();

        PP_BaseLatitudeUpdate_01 pprq;
        Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;

        pprq = new PP_BaseLatitudeUpdate_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentMessage', 'Msg1');
        inputParams.put('NewMessagePart', 'Msg2');
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals('Msg1\nMsg2', returnMap.get('NewMessage'));

        // Just for coverage...
        Process.PluginDescribeResult coverage = pprq.describe();

        Test.stopTest();
    }
}