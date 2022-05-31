/*
 * Webflow Plugin : Used on GEB RE Latitude webflow. 
 */
global class PP_CalculPDVSautDeTranche_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin {


    protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        
        //Decimal PDVType = (Decimal) request.inputParameters.get('PDVType');
        String MandataireID = (String) request.inputParameters.get('MandataireID');
        
        system.debug('@@@ MCHAB PP_CalculPDVSautDeTranche_01 - MandataireID:' + MandataireID);
        
        /*Integer maxConsoForPDVType = 100000;
        Integer minConsoForPDVType = 0;
        if(PDVType == 1.0){
            maxConsoForPDVType = 250;
            minConsoForPDVType = 0; 
        }else if(PDVType == 2.0){
            minConsoForPDVType = 251;
            maxConsoForPDVType = 1500;
        }*/
                                 
        //Integer nbGebREOptiesSautdeTranche = fetchNumberGebREOptiesSautdeTranche(maxConsoForPDVType,MandataireID,minConsoForPDVType   );
        Integer nbGebREOptiesSautdeTranche = fetchNumberGebREOptiesSautdeTranche(MandataireID);
                                                          
        //Integer nbGebREOpties = fetchNumberGebREOpties();
        //Decimal nbGebREOpties = fetchNumberQuotaGebREOpties(PDVType, MandataireID);
        Decimal nbGebREOpties = fetchNumberQuotaGebREOpties(MandataireID);
        
        Decimal pourcentPDVSautDeTranche = 0;
        
        if(nbGebREOpties > 0){
           // pourcentPDVSautDeTranche = ((Decimal) nbGebREOptiesSautdeTranche / (Decimal) nbGebREOpties) * 100.0;
           pourcentPDVSautDeTranche = ((Decimal) nbGebREOptiesSautdeTranche / (Decimal) nbGebREOpties);
        }
                             
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('PDVPourcent', pourcentPDVSautDeTranche);

        return resultMap;
    }
    
    //private Integer fetchNumberGebREOptiesSautdeTranche(Integer maxConsoForPDVType, string MandataireID, integer minConsoForPDVType  ){
    private Integer fetchNumberGebREOptiesSautdeTranche(string MandataireID){
           return [SELECT count() FROM Opportunity 
                    WHERE Account.Activity_Domain__r.ExternalID__c = 41 
                    AND Client_Type__c = 'RE' 
                    AND CloseDate = THIS_YEAR
                    //AND Project_Type__c = 'CREA'
                    AND StageName = 'Closed Won'
                    AND SyncedQuote.Saut_de_tranche__c != '0' AND SyncedQuote.Saut_de_tranche__c != null
                    /*AND SyncedQuote.Estimated_Consumption__c >= :minConsoForPDVType 
                    AND SyncedQuote.Estimated_Consumption__c < :maxConsoForPDVType*/
                    AND DO_Mandataire__c = :MandataireID 
                ];
    }
    
    /*private Integer fetchNumberGebREOpties(){
        return [SELECT count() FROM Opportunity 
                WHERE Account.Activity_Domain__r.ExternalID__c = 41 
                AND Client_Type__c = 'RE' 
             //   AND Project_Type__c = 'CREA'
                AND StageName = 'Closed Won'
                ];
    }*/

    // Récupération des quotas pour un Mandataire et un Type de PDV donné
    //private Decimal fetchNumberQuotaGebREOpties(Decimal dPDVType, string sMandataireID){
    private Decimal fetchNumberQuotaGebREOpties(string sMandataireID){

        //system.debug('@@@ CVER fetchNumberQuotaGebREOpties - dPDVType:' + dPDVType + '-sMandataireID:' + sMandataireID);
        //system.debug('@@@ MCHAB fetchNumberQuotaGebREOpties - dPDVType:' + dPDVType + '-sMandataireID:' + sMandataireID);
        system.debug('@@@ MCHAB fetchNumberQuotaGebREOpties - sMandataireID:' + sMandataireID);
        //if(dPDVType != null){
            //String sPDVType = (dPDVType==1?'1*':'2*/3*');
            
            if(sMandataireID != null && sMandataireID != ''){
                Decimal dQuota = 0;
                for(Ref_Quota_Saut_de_Tranche_GEB_RE__c oRefQuota:[SELECT Quota__c FROM Ref_Quota_Saut_de_Tranche_GEB_RE__c WHERE Mandataire__c = :sMandataireID and Type_PDV__c = 'All' /*and Type_PDV__c = :sPDVType*/]){
                    dQuota = oRefQuota.Quota__c;
                }
                
                //system.debug('@@@ CVER fetchNumberQuotaGebREOpties - dQuota:' + dQuota);
                system.debug('@@@ MCHAB fetchNumberQuotaGebREOpties - dQuota:' + dQuota);
                return dQuota;
            }else{
                return 0;
            }
        /*}
        else return 0;*/       
    }
    
    protected override String getPluginName(){ return 'Calcul_PDV_SautDeTranche'; }
    protected override String getPluginDescription(){ return 'This plugin calcul the pourcent of opty in Saut de tranche.'; }
    
    protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            //new Process.PluginDescribeResult.InputParameter('PDVType', '[1 or 2] - What kind of PDV should be fetched and calculated ?', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('MandataireID', 'ID du mandataire ?', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('PDVPourcent', 'Pourcent of opty in Saut de tranche.', Process.PluginDescribeResult.ParameterType.DECIMAL)
        }; 
    }
    
   
}