@isTest
private class CallSOAPWebService_TEST {

    static testMethod void myUnitTest() {
        CallSOAPWebService plugin = new CallSOAPWebService();
        Map<String, Object> returnMap;
        
		Map<String, Object> inputParameters1 = new Map<String, Object>{
           'Amount to simulate' => 10,
           'Quantity to simulate' => 10,
           'Full Checked' => true
		};
           
        Process.PluginRequest request = new Process.PluginRequest(inputParameters1); 
        Process.PluginResult result   = plugin.invoke(request);
        returnMap = result.outputParameters;
        System.assertEquals(9000, returnMap.get('Quantity simulated'));
        System.assertEquals(90000, returnMap.get('Amount simulated'));
        
        Map<String, Object> inputParameters2 = new Map<String, Object>{
           'Amount to simulate' => 10,
           'Quantity to simulate' => 20,
           'Full Checked' => false
		};
		request = new Process.PluginRequest(inputParameters2);
		result   = plugin.invoke(request);
		returnMap = result.outputParameters;
        System.assertEquals(1, returnMap.get('Quantity simulated'));
        System.assertEquals(10, returnMap.get('Amount simulated'));
		
		Map<String, Object> inputParameters3 = new Map<String, Object>{
           'Quantity to simulate' => 10,
           'Full Checked' => false
		};
		request = new Process.PluginRequest(inputParameters3);
		result   = plugin.invoke(request);
		returnMap = result.outputParameters;
        System.assertEquals(10, returnMap.get('Quantity simulated'));
        System.assertEquals(100, returnMap.get('Amount simulated'));
		
		// Just for coverage...
        Process.PluginDescribeResult coverage = plugin.describe();
    }
}