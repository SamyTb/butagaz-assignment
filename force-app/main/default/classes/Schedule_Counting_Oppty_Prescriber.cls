global class Schedule_Counting_Oppty_Prescriber implements Schedulable {
/* 
----------------------------------------------------------------------
-- - Name          : Schedule_Counting_Oppty_Prescriber 
-- - Author        : DPA
-- - Description   : Class to schedule batch to calculate the number of opportunity on the prescriber account
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 26-mai-2021  SC    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    global void execute (SchedulableContext sc) {  
       
        
      //  String queryString = 'SELECT Id, Nb_de_visites_realisees__c '
		//	+ 'FROM Account '
		//	+ 'WHERE Prescriber__c = true ';
			
         String queryString = 'SELECT Id, Name, StageName,project_market_type__c, Prescriber_Account__c, CloseDate,opportunity_won_Substage__c '
             +' FROM Opportunity'
             +' where Prescriber_Account__c!=null and CloseDate>=LAST_N_MONTHS:24';
        Batch_Counting_Oppty_Prescriber iBatch=new Batch_Counting_Oppty_Prescriber(queryString);         
        ID batchprocessid = Database.executeBatch(iBatch,2000);
    }

}