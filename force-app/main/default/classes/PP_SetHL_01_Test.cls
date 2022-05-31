@isTest
class PP_SetHL_01_Test{
    public static testmethod void testNewHL_STR(){
        Test.startTest();

        PP_SetHL_01 pprq;
        Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('NewLevel', 'BTZ');
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_BTZ, returnMap.get('NewLevel'));

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentLevel', PP_SetHL_01.LatLevel_RespNat);
        inputParams.put('NewLevel', 'DirCom');
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_DirCom, returnMap.get('NewLevel'));

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentLevel', PP_SetHL_01.LatLevel_BTZ);
        inputParams.put('NewLevel', 'DirCom');
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_BTZ, returnMap.get('NewLevel'));

        Boolean hasErrored = false;
        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentLevel', PP_SetHL_01.LatLevel_BTZ);
        inputParams.put('NewLevel', 'DOESNOTEXIST!');
        request = new Process.PluginRequest(inputParams); 
        try {
            result = pprq.invoke(request);
        } catch (PP_SetHL_01.InvalidLatitudeLevelException e){
            hasErrored = true;
        }
        System.assert(hasErrored);

        // Just for coverage...
        Process.PluginDescribeResult coverage = pprq.describe();

        Test.stopTest();
    }

    public static testmethod void testNewHL_INT(){
        Test.startTest();

        PP_SetHL_01 pprq;
        Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('NewLevel', 0);
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_BTZ, returnMap.get('NewLevel'));

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentLevel', PP_SetHL_01.LatLevel_RespNat);
        inputParams.put('NewLevel', 1);
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_DirCom, returnMap.get('NewLevel'));

        pprq = new PP_SetHL_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentLevel', PP_SetHL_01.LatLevel_BTZ);
        inputParams.put('NewLevel', 1);
        request = new Process.PluginRequest(inputParams); 
        result = pprq.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(PP_SetHL_01.LatLevel_BTZ, returnMap.get('NewLevel'));

        // Just for coverage...
        Process.PluginDescribeResult coverage = pprq.describe();

        Test.stopTest();
    }
}