global class PP_AddVolBouteilleParCompte_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin { 
    // ce plugin met à jour le cumul du nombre de vol bouteille sur le compte
    
   
    
        protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        String AccountID = (String) request.inputParameters.get('AccountID'); 
        String ClientType = (String) request.inputParameters.get('ClientType');   
        Integer CumulNbVolBouteille = 0;
    
        system.debug('@@@ MCHAB PP_AddVolBouteilleParCompte_01- MandataireID:' + AccountID);
        system.debug('@@@ cgilb PP_AddVolBouteilleParCompte_01- MandataireID:' + AccountID);
      
          IF (ClientType=='RE')
        {
                  
        CumulNbVolBouteille  = [SELECT count() 
                     FROM QUOTE 
                     WHERE
                     Quote.Opportunity.Client_Type__c = 'RE' 
                     AND Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 41 
                     AND Type_de_remuneration__c='Vol'
                     AND Client_Reenlistment__c='Commercial offer'
                     AND Client_Code__c =:AccountID 
                     AND Quote.Opportunity.CloseDate = THIS_YEAR
                   
                     ];
                     
              
               
              system.debug('@@@ MCHAB PP_AddVolBouteilleParCompte_01- CumulNbVolBouteille  :' + CumulNbVolBouteille  );       
    
    }
    ELSE
   {
   CumulNbVolBouteille  = [SELECT count() 
                     FROM QUOTE 
                     WHERE
                     Quote.Opportunity.Client_Type__c = 'CS' 
                     AND Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 41 
                     AND Type_de_remuneration__c='Vol'
                     AND Client_Reenlistment__c='Commercial offer'
                     AND Client_Code__c =:AccountID 
                     AND Quote.Opportunity.CloseDate = THIS_YEAR
                   
                     ];
                     
              
               
              system.debug('@@@ MCHAB PP_AddVolBouteilleParCompte_01- CumulNbVolBouteille  :' + CumulNbVolBouteille  );       
    
   }

  
  
    if (CumulNbVolBouteille !=null)
    {
 
       CumulNbVolBouteille = Integer.ValueOf(CumulNbVolBouteille);
    }
    else
    {
        CumulNbVolBouteille =0;
    }
  
    
      
     List<Account> lCumulVolBouteilleCompte  = [SELECT Nb_Avoirs_Vol_Bouteille__c from Account where AccountNumber  = :AccountID ];
           
         for (Account oCumulVolBouteilleCompte : lCumulVolBouteilleCompte  ){
             oCumulVolBouteilleCompte.Nb_Avoirs_Vol_Bouteille__c  = CumulNbVolBouteille ;
           
         }
         update lCumulVolBouteilleCompte  ;
       
    
      
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('CumulNbVolBouteille ', CumulNbVolBouteille );
    
       return resultMap;
   
   
      
    
         }
         
         
     
     
     protected override String getPluginName(){
        return 'AddVolBouteilleParComptePlugin';
    }

    protected override  String getPluginDescription(){
        return 'This plugin gives you an updated value for the cumul theft field. You provide the former Latitude Score, the increase, and an optional message (provide the current message too then). The Latitude Score will be increased, and you will get back the new cumul and an updated message.';
    }

 
    
     protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('AccountID', 'ID du compte?', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('ClientType', 'Type Client ?', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
    }

      protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('CumulNbVolBouteille', 'CumulNbVolBouteille.', Process.PluginDescribeResult.ParameterType.Integer)
        }; 
    }
    
    
  
    
}