global class PP_AddQuotaGECDOM_CREAEXE_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin { 
    // This plugin is designed to update the cumul GesteCo by mandataire
    
    
    
        protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        
           // Decimal extraCumulAvecRCE= Decimal.valueOf(String.valueOf(request.inputParameters.get('ExtraCumulAvecRCE')));
           // Decimal extraCumulSansRCE= Decimal.valueOf(String.valueOf(request.inputParameters.get('ExtraCumulSansRCE')));
            String MandataireID = (String) request.inputParameters.get('MandataireID');  
                 
            Decimal CumulOptyParMandataireAvecRCE = 0;
            Decimal CumulOptyParMandataireSansRCE = 0;
            system.debug('@@@ MCHAB PP_AddQuotaGECDOM_CREAEXE_01 - MandataireID:' + MandataireID);
          //  system.debug('@@@ MCHAB PP_AddQuotaGECDOM_CREAEXE_01 - extraCumulAvecRCE:' + extraCumulAvecRCE);
          //  system.debug('@@@ MCHAB PP_AddQuotaGECDOM_CREAEXE_01 - extraCumulSansRCE:' + extraCumulSansRCE);
        
            AggregateResult[] groupedCountOptyAvecRCE = [
                                                SELECT COUNT_DISTINCT( Quote.Opportunity.id) CumulOptyAvecRCE
                                                FROM  QuoteLineItem
                                                WHERE Quote.Opportunity.StageName = 'Closed Won'
                                                AND   Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 42 
                                                AND  (Quote.Opportunity.RecordType.Name='GEC DOM SOLO' OR Quote.Opportunity.RecordType.Name='GEC DOM IDEO')
                                                AND   Quote.T_LAT_Approved__c = TRUE
                                                AND   Quote.IsSyncing  = TRUE
                                                AND   (Quote.Opportunity.Project_Type__c='CREA' OR Quote.Opportunity.Project_Type__c='EXTE')
                                                AND   Quote.Opportunity.Energy_Source__c !='Oil'
                                                AND   Quote.Opportunity.Opportunity_Reason__c != 'Construction neuve' 
                                                AND   Quote.Opportunity.CloseDate = THIS_YEAR 
                                                AND   Quote.Opportunity.CreatedDate  = THIS_Year
                                                AND   Quote.Action_Commerciale__r.Tank_Type__c  ='E'
                                                AND   All_RCE_Rebates_TTC__c >=1.00
                                                AND   All_RCE_Rebates_TTC__c <=500.00
                                                AND   Product_Family__c = 'Produit'
                                                AND   Quote.Opportunity.Account.Prescriber_Client_GEC_DOM__c = false 
                                                AND   Quote_PTL__r.T_LAT_GEC_ALL_MandataireID__c =:MandataireID
                                                ];
                     
            if (groupedCountOptyAvecRCE[0].get('CumulOptyAvecRCE')!=null)
            {
            CumulOptyParMandataireAvecRCE = Decimal.ValueOf('' + groupedCountOptyAvecRCE[0].get('CumulOptyAvecRCE'));
            }
            else
            {
            CumulOptyParMandataireAvecRCE=0;
            }
            system.debug('@@@ MCHAB PP_AddQuotaGECDOM_CREAEXE_01 - groupedCountOptyAvecRCE:' + groupedCountOptyAvecRCE);    
            
            
            
            
            
            AggregateResult[] groupedCountOptySansRCE = [
                                                SELECT COUNT_DISTINCT( Quote.Opportunity.id) CumulOptySansRCE
                                                FROM  QuoteLineItem
                                                WHERE Quote.Opportunity.StageName = 'Closed Won'
                                                AND   Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 42 
                                                AND  (Quote.Opportunity.RecordType.Name='GEC DOM SOLO' OR Quote.Opportunity.RecordType.Name='GEC DOM IDEO')
                                                AND   Quote.T_LAT_Approved__c = TRUE
                                                AND   Quote.IsSyncing  = TRUE
                                                AND   (Quote.Opportunity.Project_Type__c='CREA' OR Quote.Opportunity.Project_Type__c='EXTE')
                                                AND   Quote.Opportunity.Energy_Source__c !='Oil'
                                                AND   Quote.Opportunity.Opportunity_Reason__c != 'Construction neuve' 
                                                AND   Quote.Opportunity.CloseDate = THIS_YEAR 
                                                AND   Quote.Opportunity.CreatedDate  = THIS_Year
                                                AND   Quote.Action_Commerciale__r.Tank_Type__c  ='E'
                                                AND   All_RCE_Rebates_TTC__c = 0.00
                                                AND   Product_Family__c = 'Produit'
                                                AND   Quote.Opportunity.Account.Prescriber_Client_GEC_DOM__c = false 
                                                AND   Quote_PTL__r.T_LAT_GEC_ALL_MandataireID__c =:MandataireID
                                                ];
                     
            if (groupedCountOptySansRCE[0].get('CumulOptySansRCE')!=null)
            {
            CumulOptyParMandataireSansRCE = Decimal.ValueOf('' + groupedCountOptySansRCE[0].get('CumulOptySansRCE'));
            }
            else
            {
            CumulOptyParMandataireSansRCE=0;
            }
            system.debug('@@@ MCHAB PP_AddQuotaGECDOM_CREAEXE_01 - groupedCountOptyAvecRCE:' + groupedCountOptySansRCE);    
            
            
             List<Mandataire__c> lCumulOptyMdt  = [SELECT CumulGECDOM_CREAEXE__c,CumulGECDOM_CREAEXE_SansRCE__c  from Mandataire__c where id = :MandataireID ];
               
             for (Mandataire__c oCumulOptyMdt : lCumulOptyMdt){
                 oCumulOptyMdt.CumulGECDOM_CREAEXE__c  = CumulOptyParMandataireAvecRCE;
                 oCumulOptyMdt.CumulGECDOM_CREAEXE_SansRCE__c = CumulOptyParMandataireSansRCE;
               
             }
             update lCumulOptyMdt;
       
      
        
           /* Decimal newCumulAvecRCE    = this.getNewCumulAvecRCE(extraCumulAvecRCE );
            Decimal newCumulSansRCE    = this.getNewCumulSansRCE(extraCumulSansRCE);
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('NewCumulAvecRCE', newCumulAvecRCE);
            resultMap.put('NewCumulSansRCE', newCumulSansRCE);*/
            
            
            Decimal newCumulAvecRCE    = this.getNewCumulAvecRCE(CumulOptyParMandataireAvecRCE );
            Decimal newCumulSansRCE    = this.getNewCumulSansRCE(CumulOptyParMandataireSansRCE);
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('NewCumulAvecRCE', newCumulAvecRCE);
            resultMap.put('NewCumulSansRCE', newCumulSansRCE);
            
            
            
        
            return resultMap;
    }
    
    
    
    
    
    
     protected override String getPluginName(){
        return 'AddQuotaGECDOMPlugin';
    }

    protected override  String getPluginDescription(){
        return 'This plugin gives you an updated value for the cumul opty gec dom crea field. You provide the former Latitude Score, the increase, and an optional message (provide the current message too then). The Latitude Score will be increased, and you will get back the new cumul and an updated message.';
    }

    private Decimal getNewCumulAvecRCE(Decimal extraCumulAvecRCE){
        return extraCumulAvecRCE;
    }
    
    private Decimal getNewCumulSansRCE(Decimal extraCumulSansRCE){
        return extraCumulSansRCE;
    }
   
     protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
          // new Process.PluginDescribeResult.InputParameter('ExtraCumulAvecRCE', 'How much you want to add to the score.', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
          // new Process.PluginDescribeResult.InputParameter('ExtraCumulSansRCE', 'How much you want to add to the score.', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
           new Process.PluginDescribeResult.InputParameter('MandataireID', 'ID du mandataire ?', Process.PluginDescribeResult.ParameterType.STRING, true)

        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
           new Process.PluginDescribeResult.OutputParameter('NewCumulAvecRCE', 'New (Decimal) Cumul.', Process.PluginDescribeResult.ParameterType.DECIMAL),
           new Process.PluginDescribeResult.OutputParameter('NewCumulSansRCE', 'New (Decimal) Cumul.', Process.PluginDescribeResult.ParameterType.DECIMAL)
        };
    }
    
  
    
}