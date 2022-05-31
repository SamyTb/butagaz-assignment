global class PP_AddGesteCoByMandataire_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin { 
    // This plugin is designed to update the cumul GesteCo by mandataire
    
    
    
        protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        
        Decimal extraCumul= Decimal.valueOf(String.valueOf(request.inputParameters.get('ExtraCumul')));
        String MandataireID = (String) request.inputParameters.get('MandataireID');  
        String ClientType = (String) request.inputParameters.get('ClientType');  

    
        
             
        Decimal CumulGesteCoParMandataire = 0;
        
        system.debug('@@@ MCHAB PP_AddGesteCoByMandataire_01 - MandataireID:' + MandataireID);
        system.debug('@@@ MCHAB PP_AddGesteCoByMandataire_01 - extraCumul:' + extraCumul);
         
        
        
        // Non-required param - boilerplate to get the default values.
            Decimal currentCumul;
            if (request.inputParameters.get('CurrentCumul') == null){ 
                currentCumul= 0; 
            } else { 
                currentCumul = Decimal.valueOf(String.valueOf(request.inputParameters.get('CurrentCumul'))); 
           
                this.messageExtraInfo = ' (Cumul GesteCo: +' + String.valueOf(ExtraCumul) + ')';
            }
            
            system.debug('@@@ MCHAB PP_AddGesteCoByMandataire_01 - currentCumul:' + currentCumul);
            
        
        IF (ClientType=='RE')
        {
              
        AggregateResult[] groupedCountRevenue = [SELECT SUM(T_LAT_GEB_RE_ALL_ID_Remise_Quote__c) SumAvoir
                     FROM QUOTE 
                     WHERE
                     Quote.Opportunity.Client_Type__c = 'RE' 
                     AND Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 41 
                     AND Type_de_remuneration__c='Avoir'
                     AND Client_Reenlistment__c='Commercial offer'
                     AND isSyncing = True
                     AND T_LAT_GEB_RE_ALL_ID_MDT_CUMUL__c=:MandataireID
                     AND Quote.Opportunity.CloseDate = THIS_YEAR
                     ];
                     
            if (groupedCountRevenue[0].get('SumAvoir')!=null)
            {
            CumulGesteCoParMandataire = Decimal.ValueOf('' + groupedCountRevenue[0].get('SumAvoir'));
            }
            else
            {
            CumulGesteCoParMandataire=0;
            }
      system.debug('@@@ MCHAB PP_AddGesteCoByMandataire_01 - groupedCountRevenue:' + groupedCountRevenue);       
                     
        }
        ELSE
        {
        AggregateResult[] groupedCountRevenue = [SELECT SUM(T_LAT_GEB_RE_ALL_ID_Remise_Quote__c) SumAvoir
                     FROM QUOTE 
                     WHERE
                     Quote.Opportunity.Client_Type__c = 'CS' 
                     AND Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 41 
                     AND Type_de_remuneration__c='Avoir'
                     AND Client_Reenlistment__c='Commercial offer'
                     AND isSyncing = True
                     AND T_LAT_GEB_RE_ALL_ID_MDT_CUMUL__c=:MandataireID
                     AND Quote.Opportunity.CloseDate = THIS_YEAR
                     ];
              
               
               
               if (groupedCountRevenue[0].get('SumAvoir')!=null)
                {
                CumulGesteCoParMandataire = Decimal.ValueOf('' + groupedCountRevenue[0].get('SumAvoir'));
                }
                else
                {
                CumulGesteCoParMandataire=0;
                }
                  system.debug('@@@ MCHAB PP_AddGesteCoByMandataire_01 - groupedCountRevenue:' + groupedCountRevenue);       
     }  
    
            
        
        

    
    /*
        if (groupedCountRevenue[0].get('SumAvoir')!=null)
        {
        CumulGesteCoParMandataire = Decimal.ValueOf('' + groupedCountRevenue[0].get('SumAvoir'));
        }
        else
        {
        CumulGesteCoParMandataire=0;
        }
    
      */  
          
           IF (ClientType=='RE')
        {
          
             List<Mandataire__c> lCumulGesteCoMdt  = [SELECT Cumul_Avoir_GesteCo__c  from Mandataire__c where id = :MandataireID ];
               
             for (Mandataire__c oCumulGesteCoMdt : lCumulGesteCoMdt){
                 oCumulGesteCoMdt.Cumul_Avoir_GesteCo__c  = CumulGesteCoParMandataire;
               
             }
             update lCumulGesteCoMdt;
       
        }
        ELSE
        {
            List<Mandataire__c> lCumulGesteCoMdt  = [SELECT Cumul_avoir_geste_co_CS__c from Mandataire__c where id = :MandataireID ];
               
             for (Mandataire__c oCumulGesteCoMdt : lCumulGesteCoMdt){
                 oCumulGesteCoMdt.Cumul_avoir_geste_co_CS__c = CumulGesteCoParMandataire;
               
             }
             update lCumulGesteCoMdt;
        }
        
        Decimal newCumul     = this.getNewCumul(currentCumul, extraCumul);
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('NewCumul', newCumul);
    
        return resultMap;
    
         }
         
         
     
     
     protected override String getPluginName(){
        return 'AddGesteCoByMandatairePlugin';
    }

    protected override  String getPluginDescription(){
        return 'This plugin gives you an updated value for the cumul gesteco field. You provide the former Latitude Score, the increase, and an optional message (provide the current message too then). The Latitude Score will be increased, and you will get back the new cumul and an updated message.';
    }

    private Decimal getNewCumul(Decimal currentCumul, Decimal extraCumul){
        return currentCumul + extraCumul;
    }
    
     protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('ExtraCumul', 'How much you want to add to the score.', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('CurrentCumul', 'The Current cumul GesteCo - 0 if not provided.', Process.PluginDescribeResult.ParameterType.DECIMAL, false),
            new Process.PluginDescribeResult.InputParameter('MandataireID', 'ID du mandataire ?', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('ClientType', 'Type Client ?', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('NewCumul', 'New (Decimal) Cumul.', Process.PluginDescribeResult.ParameterType.DECIMAL)
        }; 
    }
    
  
    
}