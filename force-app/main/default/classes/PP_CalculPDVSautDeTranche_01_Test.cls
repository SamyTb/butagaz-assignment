@isTest()
public class PP_CalculPDVSautDeTranche_01_Test {

    public static testmethod void testCalculPDVSautDeTranche(){
        PP_CalculPDVSautDeTranche_01 plugin = new PP_CalculPDVSautDeTranche_01();
        
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = '999',
            Active__c = true
        );
        insert mand1;

        //Ref_Quota_Saut_de_Tranche_GEB_RE__c
        Ref_Quota_Saut_de_Tranche_GEB_RE__c rqstgr1 = new Ref_Quota_Saut_de_Tranche_GEB_RE__c(
            Mandataire__c = mand1.Id,
            Quota__c = 10,
            Type_PDV__c = 'All'
        );
        insert rqstgr1;


        Map<String, Object> inputParameters = new Map<String, Object>{
            /*'PDVType' => 1*/
            'MandataireID' => mand1.Id
        };

        
        Process.PluginRequest request = new Process.PluginRequest(inputParameters); 
        Process.PluginResult result   = plugin.invoke(request);
        
        Process.PluginDescribeResult resultDesc = plugin.describe();

        Map<String, Object> returnMap = result.outputParameters;

        System.assertEquals(0, returnMap.get('PDVPourcent'));




        Map<String, Object> inputParametersNull = new Map<String, Object>{
            /*'PDVType' => 1*/
            'MandataireID' => null
        };
        
        Process.PluginRequest requestNull = new Process.PluginRequest(inputParametersNull); 
        Process.PluginResult resultNull   = plugin.invoke(requestNull);

        Map<String, Object> returnMapNull = resultNull.outputParameters;

        System.assertEquals(0, returnMapNull.get('PDVPourcent'));
    }
    
}