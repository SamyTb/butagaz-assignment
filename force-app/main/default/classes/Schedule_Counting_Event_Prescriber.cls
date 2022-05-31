global class Schedule_Counting_Event_Prescriber implements Schedulable {
/* 
----------------------------------------------------------------------
-- - Name          : Schedule_Counting_Event_Prescriber 
-- - Author        : MLC
-- - Description   : Class to schedule batch to calculate the number of history events on the prescriber account
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 08-mars-2021  SC    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    global void execute (SchedulableContext sc) {  
       
        
        String queryString = 'SELECT Id, Nb_de_visites_realisees__c '
			+ 'FROM Account '
			+ 'WHERE Prescriber__c = true ';
			
        
    
        Batch_Counting_Event_Prescriber iBatch=new Batch_Counting_Event_Prescriber(queryString);         
        
  
        ID batchprocessid = Database.executeBatch(iBatch,200);
        
       
    }

}