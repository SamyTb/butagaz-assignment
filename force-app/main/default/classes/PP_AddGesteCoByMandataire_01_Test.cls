@isTest()
public class PP_AddGesteCoByMandataire_01_Test {

    public static testmethod void testAddGesteCoByMandataire(){
        PP_AddGesteCoByMandataire_01 plugin = new PP_AddGesteCoByMandataire_01();
		Map<String, Object> inputParameters1 = new Map<String, Object>{
           'ExtraCumul' => 15
		};
           
        Process.PluginRequest request = new Process.PluginRequest(inputParameters1); 
        Process.PluginResult result   = plugin.invoke(request);
        
        Map<String, Object> inputParameters2 = new Map<String, Object>{
           'CurrentCumul' => 10,
           'ExtraCumul' => 15,
           'ClientType' => 'RE'
		};
		request = new Process.PluginRequest(inputParameters2);
		result   = plugin.invoke(request);
        Process.PluginDescribeResult resultDesc = plugin.describe();
        //Map<String, Object> returnMap = result.outputParameters;

       
        //System.assertEquals(10.0, returnMap.get('CurrentCumul'));
        // System.assertEquals(0, returnMap.get('NewCumul'));
    }
    
    
}