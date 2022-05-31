@isTest(seeAllData=true)
public class PP_LatitudePanic_01_Test {
    public static testmethod void testDescribePlugin(){
        Test.startTest();

        PP_LatitudePanic_01 pprq = new PP_LatitudePanic_01();
        Process.PluginDescribeResult describe = pprq.describe();
        Test.stopTest();
    }

    public static testmethod void testLevel(){
        PP_LatitudePanic_01 pprq = new PP_LatitudePanic_01();
        Map<String, Object> inputParams = new Map<String, Object>{
            'PanicReason' => 'aReason',
            'Location'    => 'aLocation'
        };
        Process.PluginRequest request = new Process.PluginRequest(inputParams); 
        Process.PluginResult result   = pprq.invoke(request);
        Map<String, Object> returnMap = result.outputParameters;

        System.assertEquals(PP_LatitudePanic_01.LatLevel_BTZ, returnMap.get('NewLevel'));
    }
}