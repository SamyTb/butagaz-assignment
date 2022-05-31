@istest
public class testInvoke_AddLatitude_01 {
  
  @istest public static void testinvokeAddLatitude()
  {
        Invoke_AddLatitude_01.FlowInputs jdd1 = new Invoke_AddLatitude_01.FlowInputs();
      
        jdd1.CurrentMessage ='';
        jdd1.CurrentScore=200;
        jdd1.ExtraScore=400;
        jdd1.NewMessagePart='';
      
        List<Invoke_AddLatitude_01.FlowInputs> inputlist =new List<Invoke_AddLatitude_01.FlowInputs>();  
        inputlist.add(jdd1);
      
     	List<Invoke_AddLatitude_01.FlowOutputs> outputlist = Invoke_AddLatitude_01.invokeAddLatitude(inputlist);
       
          
        System.assertEquals (200,jdd1.CurrentScore);
        System.assertEquals (400,jdd1.ExtraScore);
       
        System.assertEquals(1,outputlist.size());
      Invoke_AddLatitude_01.FlowOutputs jddOutput =outputlist.get(0); 
      System.assertEquals(600,jddOutput.NewScore);
      
      System.assertEquals(jdd1.CurrentMessage + '\r\n' + jdd1.NewMessagePart +'( Score +'+ jdd1.extraScore+' pt)',jddOutput.NewMessage);
  
  }
    
      
    

}