@isTest()
public class PP_AddQuotaGECDOM_CREAEXE_01_Test {

    public static testmethod void testAddQuotaGECDOM_CREAEXE(){
    /*   PP_AddQuotaGECDOM_CREAEXE_01 plugin = new PP_AddQuotaGECDOM_CREAEXE_01();
    Map<String, Object> inputParameters1 = new Map<String, Object>{
           'extraCumulAvecRCE' => 5,
           'extraCumulSansRCE' => 5,
           'MandataireID' => '123'
           
       
    };
           
        Process.PluginRequest request = new Process.PluginRequest(inputParameters1); 
        Process.PluginResult result   = plugin.invoke(request);
        
        Map<String, Object> inputParameters2 = new Map<String, Object>{
           'CumulOptyParMandataireAvecRCE ' => 3,
             'CumulOptyParMandataireSansRCE ' => 3,
           
           'extraCumulAvecRCE' => 5,
           'extraCumulSansRCE' => 5
           
          
           
    };
    
   
    
    request = new Process.PluginRequest(inputParameters2);
    result   = plugin.invoke(request);
    
    
    
  
    Map<String, Object> returnMapOutPut = result.outputParameters;
     System.assertEquals(0, returnMapOutPut.get('NewCumulAvecRCE'));
     System.assertEquals(0, returnMapOutPut.get('NewCumulSansRCE'));*/
     
      Test.startTest();
     
     
     PP_AddQuotaGECDOM_CREAEXE_01 ppavbpc;
   
        Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;
     
    
        ppavbpc = new PP_AddQuotaGECDOM_CREAEXE_01();
    
        inputParams = new Map<String,Object>();
        inputParams.put('CumulOptyParMandataireAvecRCE','3');
        inputParams.put('CumulOptyParMandataireSansRCE','3');
        inputParams.put('MandataireID', 'MandataireID');
        inputParams.put('extraCumulAvecRCE', '5');
        inputParams.put('extraCumulAvecRCE', '5');
        request = new Process.PluginRequest(inputParams); 
        result = ppavbpc.invoke(request);
        returnMap = result.outputParameters;
        
        
        inputParams = new Map<String,Object>();
        inputParams.put('CumulOptyParMandataireAvecRCE','0');
        inputParams.put('CumulOptyParMandataireSansRCE','0');
        inputParams.put('MandataireID', 'MandataireID');
        inputParams.put('extraCumulAvecRCE', '0');
        inputParams.put('extraCumulAvecRCE', '0');
        request = new Process.PluginRequest(inputParams); 
        result = ppavbpc.invoke(request);
        returnMap = result.outputParameters;
        
        
     // Just for coverage...
     Process.PluginDescribeResult coverage = ppavbpc.describe();

     Test.stopTest();
     
     
    
    }
    
    
}