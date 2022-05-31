public class Invoke_AddLatitude_01{

    
   @InvocableMethod(label='Invoke Apex')
    //  public static List<Integer> invokeAddLatitude(List<FlowInputs> request) {   OK
    public static List<FlowOutputs> invokeAddLatitude(List<FlowInputs> request) {
    
    
     Integer ICurrentScore ;
   // List<Integer> NewScore = new List<Integer>();  OK
    FlowOutputs fo = new FlowOutputs() ;
    List<FlowOutputs> theResults = new List<FlowOutputs>();
        for (FlowInputs fi:request)
        {
           ICurrentScore =  fi.CurrentScore + fi.extraScore;
          //  NewScore.add(ICurrentScore);  OK
          fo.NewScore = ICurrentScore;
          fo.NewMessage = fi.CurrentMessage + '\r\n' + fi.NewMessagePart +'( Score +'+ fi.extraScore+' pt)';
          
         
         theResults.add(fo) ;
           
         }
       //  return  NewScore;  OK
       return theResults;
    }


  /* @InvocableMethod(label='Invoke Apex')
    public static List<FlowOutputs> invokeThisMetho(List<FlowInputs> request) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        return results;
    }*/

    
    //input details that comes to apex from flow
    public class FlowInputs{
        
        
            
        @InvocableVariable (required=false)
        public String CurrentMessage;
        
        @InvocableVariable (required=true)
        public String NewMessagePart;
        
        @InvocableVariable (required=true)
        public Integer CurrentScore;
        
        @InvocableVariable (required=true)
        public Integer ExtraScore;  
        
    }
    
    
    
    //output details which goes from apex to flow
    public class FlowOutputs{
        
        @InvocableVariable
        public Integer NewScore;
              
        @InvocableVariable
        public String NewMessage;

    }

        
    
    

    
  }