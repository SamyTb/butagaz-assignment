global class Schedule_Update_Prescriber_KPI_For_FY  implements Schedulable {
    
        
/* 
----------------------------------------------------------------------
-- - Name          : Schedule_Update_Prescriber_KPI_For_FY 
-- - Author        : DPA
-- - Description   : Class to schedule batch to calculate KPI's on the prescriber account
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 01-juin-2021  SC    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/

       global void execute (SchedulableContext sc) {  
       
        
      String queryString = 'SELECT Id, Nb_de_visites_realisees__c '
			+ 'FROM Account '
			+ 'WHERE Prescriber__c = true ';
			
        Batch_Update_Prescriber_KPI_For_FY iBatch=new Batch_Update_Prescriber_KPI_For_FY(queryString);         
        ID batchprocessid = Database.executeBatch(iBatch,200);
    }

    
}