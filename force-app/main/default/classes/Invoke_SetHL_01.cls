global class Invoke_SetHL_01{
//global class Invoke_SetHL_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin{
    
    
global class InvalidLatitudeLevelException extends Exception {}

 /* public static Integer LatLevel_CE       = 5;
  public static Integer LatLevel_CDV      = 4;
  public static Integer LatLevel_GdCompte = 3;
  public static Integer LatLevel_RespNat  = 2;
  public static Integer LatLevel_DirCom   = 1;
  public static Integer LatLevel_BTZ      = 0;
  
  public static Integer  newLevelInput ;
  public static Integer  newLevelOutput ;
  
   private static Map<String, Integer> latitudeLevels = new Map<String, Integer>{
        'CE'       => LatLevel_CE,
        'CDV'      => LatLevel_CDV,
        'GdCompte' => LatLevel_GdCompte,
        'RespNat'  => LatLevel_RespNat,
        'DirCom'   => LatLevel_DirCom,
        'BTZ'      => LatLevel_BTZ
    };
  
   private Integer getNewLevel(Integer currentLevel, String newLevelString){
       // Integer newLevel = Invoke_SetHL_01.latitudeLevels.get(newLevelString);
        newLevelInput = Invoke_SetHL_01.latitudeLevels.get(newLevelString);
        if (newLevelInput == null){
            if (newLevelString.isNumeric()){
                newLevelInput = Integer.valueOf(newLevelString);
            } else {
                throw new Invoke_SetHL_01.InvalidLatitudeLevelException('Invalid Latitude Level: ' + newLevelString);
            }
        } 
        System.debug('[getNewLevel] currentLevel is: ' + currentLevel);
        System.debug('[newLevelInput] currentLevel is: ' + newLevelInput);
        return Math.min(currentLevel, newLevelInput ); // Lowest level
    }
  
  
   public Map<String, Object> getResultMap(FlowInputs request ){
        // Required param
        String  newLevelString  = request.NewLevel;

        // Non-required param - boilerplate to get the default values.
        Integer currentLevel;
        //if (request.inputParameters.get('CurrentLevel') == null){ 
        if (request.CurrentLevel == null){ 
            currentLevel = LatLevel_CE; 
           // this.messageExtraInfo = 'CE';
        } else { 
          //  currentLevel = Integer.valueOf(request.inputParameters.get('CurrentLevel')); 
          currentLevel = request.CurrentLevel; 
         //   this.messageExtraInfo = ' (Niveau: ' + newLevelString + ')';
        }

        //Integer newLevel   = this.getNewLevel(currentLevel, newLevelString);
        newLevelOutput  = this.getNewLevel(currentLevel, newLevelString);
        Map<String, Object> resultMap = new Map<String, Object>();
       
        System.debug('[getResultMap] newLevelOutput is: ' + newLevelOutput);

        resultMap.put('NewLevel', newLevelOutput  );

        return resultMap;
    }

  */
  
    @InvocableMethod(label='Invoke Apex')
    
        
    public static List<FlowOutputs> InvokeSetHL01(List<FlowInputs> request) {
    
    FlowOutputs fo = new FlowOutputs() ;
    List<FlowOutputs> theResults = new List<FlowOutputs>();
        for (FlowInputs fi:request)
        {
            
            
         fo.NewLevel = fi.NewLevel  ;
         fo.NewMessage = fi.CurrentMessage + '\r\n' + fi.NewMessagePart +'( Niveau : '+  fi.NewLevel +')';       
         theResults.add(fo) ;
           
         }
      
       return theResults;
    }
    
    

 

    
    //input details that comes to apex from flow
    public class FlowInputs{
    
        @InvocableVariable (required=true)
        public String NewLevelString;
        
         @InvocableVariable (required=true)
        public Integer NewLevel;
        
        @InvocableVariable (required=true)
        public Integer CurrentLevel;
                     
        @InvocableVariable (required=true)
        public String CurrentMessage;
            
        @InvocableVariable (required=true)
        public String NewMessagePart;
        
        
    }
    
    
    
    //output details which goes from apex to flow
    public class FlowOutputs{
        
        @InvocableVariable (required=false)
        public Integer NewLevel;
        
              
        @InvocableVariable
        public String NewMessage;

    }

   

    
  }