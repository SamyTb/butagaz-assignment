@isTest()
public class  PP_AddVolBouteilleParCompte_01_Test {

    public static testmethod void testAddVolBouteilleByAccount(){
       
      /*  Test.startTest();
        
        PP_AddVolBouteilleParCompte_01 plugin = new  PP_AddVolBouteilleParCompte_01();
        Map<String, Object> inputParameters = new Map<String, Object>{
            'CumulNbVolBouteille ' => 3
        };
        
     
        Process.PluginRequest request = new Process.PluginRequest(inputParameters); 
        Process.PluginResult result   = plugin.invoke(request);
        
        Map<String, Object> returnMap = result.outputParameters;
        
        Map<String, Object> inputParameters2 = new Map<String, Object>{
           'ClientType' => 'RE'
        };
        request = new Process.PluginRequest(inputParameters2);
        result   = plugin.invoke(request);
           
     //  Process.PluginDescribeResult coverage = PP_AddVolBouteilleParCompte_01.describe();

       Test.stopTest();*/
      
        
        
     
     

    
    Test.startTest();
   
   
    PP_AddVolBouteilleParCompte_01 ppavbpc;
   
   		Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;
     
    
        ppavbpc = new PP_AddVolBouteilleParCompte_01();
    
        inputParams = new Map<String,Object>();
        inputParams.put('CumulNbVolBouteille','3');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('ClientType', 'ClientType');
        inputParams.put('ClientType', 'RE');
        request = new Process.PluginRequest(inputParams); 
        result = ppavbpc.invoke(request);
        returnMap = result.outputParameters;
         
        
        
    	ppavbpc = new PP_AddVolBouteilleParCompte_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CumulNbVolBouteille','0');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('ClientType', 'ClientType');
        inputParams.put('ClientType', 'RE');
        request = new Process.PluginRequest(inputParams); 
        result = ppavbpc.invoke(request);
        returnMap = result.outputParameters;
        
        ppavbpc = new PP_AddVolBouteilleParCompte_01();
        inputParams = new Map<String,Object>();
        inputParams.put('Nb_Avoirs_Vol_Bouteille__c','3');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('ClientType', 'ClientType');
        inputParams.put('ClientType', 'RE');
        request = new Process.PluginRequest(inputParams); 
        result = ppavbpc.invoke(request);
        returnMap = result.outputParameters;
      
        
     // Just for coverage...
     Process.PluginDescribeResult coverage = ppavbpc.describe();

     Test.stopTest();
   
        
    }
    
    
}