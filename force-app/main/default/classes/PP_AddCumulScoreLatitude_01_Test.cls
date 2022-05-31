@isTest()
public class  PP_AddCumulScoreLatitude_01_Test {

    public static testmethod void testAddCumulScoreLatitude(){
       
    
    Test.startTest();
   
   
    PP_AddCumulScoreLatitude_01 ppcspc;
   
       Map<String,Object> inputParams;
        Process.PluginRequest request; 
        Process.PluginResult result;
        Map<String, Object> returnMap;
     
    
        ppcspc= new PP_AddCumulScoreLatitude_01();
    
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentCumulLatitude','350');
        inputParams.put('CumulScore','10');
        inputParams.put('ExtraCumul','10');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('AccountID', '123456');
        inputParams.put('T_Pack', 'T_Pack');
        inputParams.put('T_Pack', '1');
        request = new Process.PluginRequest(inputParams); 
        result = ppcspc.invoke(request);
        returnMap = result.outputParameters;
         
        
        
        ppcspc= new PP_AddCumulScoreLatitude_01();
        inputParams = new Map<String,Object>();
        inputParams.put('CurrentCumulLatitude','0');
        inputParams.put('CumulScore','10');
        inputParams.put('ExtraCumul','10');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('AccountID', '1234567');
        inputParams.put('T_Pack', 'T_Pack');
        inputParams.put('T_Pack', '1');
        request = new Process.PluginRequest(inputParams); 
        result = ppcspc.invoke(request);
        returnMap = result.outputParameters;
        
        ppcspc= new PP_AddCumulScoreLatitude_01();
        inputParams = new Map<String,Object>();
        inputParams.put('Cumul_Point_IDEO_SOLO_ECO__c ','350');
        inputParams.put('ExtraCumul','10');
        inputParams.put('AccountID', 'AccountID');
        inputParams.put('AccountID', '123456');
        inputParams.put('T_Pack', 'T_Pack');
        inputParams.put('T_Pack', '1');
        request = new Process.PluginRequest(inputParams); 
        result = ppcspc.invoke(request);
        returnMap = result.outputParameters;
      
        
     // Just for coverage...
     Process.PluginDescribeResult coverage = ppcspc.describe();

     Test.stopTest();
   
        
    }
    
    
}