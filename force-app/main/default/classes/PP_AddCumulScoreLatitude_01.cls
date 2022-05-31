global class PP_AddCumulScoreLatitude_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin { 
    // This plugin is designed to update the cumul latitude by account
    
    
    
        protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        
        Decimal extraCumul= Decimal.valueOf(String.valueOf(request.inputParameters.get('ExtraCumul')));
        String AccountID = (String) request.inputParameters.get('AccountID');  
        Integer T_Pack = Integer.valueOf(Integer.valueOf(request.inputParameters.get('T_Pack')));
        
              
        Decimal CurrentCumulLatitude= 0;
                
        
        // Non-required param - boilerplate to get the default values.
            Decimal currentCumul;
            if (request.inputParameters.get('CurrentCumulLatitude') == null){ 
                CurrentCumulLatitude= 0; 
            } else { 
                CurrentCumulLatitude = Decimal.valueOf(String.valueOf(request.inputParameters.get('CurrentCumulLatitude'))); 
           
                this.messageExtraInfo = ' (Cumul Latitude: +' + String.valueOf(ExtraCumul) + ')';
            }
            
          
            
           // Nouvelles offres periode 5 ans 
        
           if (T_Pack==1)
            {
      
                AggregateResult[] groupedCountLatitude = [SELECT SUM(Latitude__c) SumLatitude
                     FROM QUOTE 
                     WHERE Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 42 
                     AND (Quote.Opportunity.RecordType.Name='GEC DOM SOLO' OR Quote.Opportunity.RecordType.Name='GEC DOM IDEO')
                     AND Account_Id__c =:AccountID 
                     AND T_LAT_Approved__c = TRUE
                     AND IsSyncing  = TRUE
                   //  AND Quote.Opportunity.Project_Sub_Type__c = 'GC'
                     AND (Quote.Opportunity.CloseDate = LAST_N_YEARS:5
                     OR  Quote.Opportunity.CloseDate =   THIS_YEAR )
                     ];
                     
                    if (groupedCountLatitude[0].get('SumLatitude')!=null)
                    {
                    CurrentCumulLatitude= Decimal.ValueOf('' + groupedCountLatitude[0].get('SumLatitude'));
                    }
                    else
                    {
                    CurrentCumulLatitude=0;
                    }
            
           
            }
            
            else
            
             {
      
                AggregateResult[] groupedCountLatitude = [SELECT SUM(Latitude__c) SumLatitude
                     FROM QUOTE 
                     WHERE Quote.Opportunity.StageName = 'Closed Won'
                     AND Quote.Opportunity.Account.Activity_Domain__r.ExternalID__c = 42 
                     AND (Quote.Opportunity.RecordType.Name='GEC DOM')
                     AND Account_Id__c =:AccountID 
                     AND T_LAT_Approved__c = TRUE
                     AND IsSyncing  = TRUE
                   //  AND Quote.Opportunity.Project_Sub_Type__c = 'GC'
                     AND (Quote.Opportunity.CloseDate =  LAST_N_YEARS:7
                     OR  Quote.Opportunity.CloseDate =   THIS_YEAR )
                     ];
           
           
        
                         
                if (groupedCountLatitude[0].get('SumLatitude')!=null)
                {
                    CurrentCumulLatitude= Decimal.ValueOf('' + groupedCountLatitude[0].get('SumLatitude'));
                }
                 
                else
                {
                
                    CurrentCumulLatitude=0;
                }
            
            
            }      
          
            
               List<Account> lCumulLatitudeCompte  = [SELECT Cumul_Point_IDEO_SOLO_ECO__c from Account where id= :AccountID ];
           
                for (Account oCumulLatitudeCompte : lCumulLatitudeCompte  ){
             oCumulLatitudeCompte.Cumul_Point_IDEO_SOLO_ECO__c  = CurrentCumulLatitude;
           
             }
             update lCumulLatitudeCompte  ;
           
        
          
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('CurrentCumulLatitude', CurrentCumulLatitude);
        
           return resultMap;
           
      
         }
         
         
     
     protected override String getPluginName(){
        return 'AddCumulScoreLatitudePlugin';
    }

    protected override  String getPluginDescription(){
        return 'This plugin gives you an updated value for the cumul latitude field. You provide the former Latitude Score, the increase, and an optional message (provide the current message too then). The Latitude Score will be increased, and you will get back the new cumul and an updated message.';
    }

    private Decimal getNewCumul(Decimal CurrentCumulLatitude, Decimal extraCumul){
        return CurrentCumulLatitude + extraCumul;
    }
    
     protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('ExtraCumul', 'How much you want to add to the score.', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('CurrentCumul', 'The Current cumul GesteCo - 0 if not provided.', Process.PluginDescribeResult.ParameterType.DECIMAL, false),
            new Process.PluginDescribeResult.InputParameter('AccountID', 'ID du compte?', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('T_Pack', 'T_Pack?', Process.PluginDescribeResult.ParameterType.INTEGER, true)
        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('CurrentCumulLatitude', 'CurrentCumulLatitude', Process.PluginDescribeResult.ParameterType.DECIMAL)
        }; 
    }
   
  
    
}