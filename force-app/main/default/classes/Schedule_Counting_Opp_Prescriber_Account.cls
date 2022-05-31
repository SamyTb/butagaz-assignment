global class Schedule_Counting_Opp_Prescriber_Account implements Schedulable {
/* 
----------------------------------------------------------------------
-- - Name          : Schedule_Counting_Opp_Prescriber_Account 
-- - Author        : Clément Tussiot - Salesforce exepert Services
-- - Description   : Class to schedule batch to calculate the number of opportunity won per Prescriber                    
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 02-AUG-2012  SC    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    global void execute (SchedulableContext sc) {  
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- Start of method execute');       
     
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- execute: retrieve Prescribers');
        
        String queryString = 'SELECT id, Prescribed_Opportunties_Won__c FROM Account WHERE Prescriber__c =true'; 
        
 
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- execute: Create a new instance of class BatchCreateGrid (Batch)');
        Batch_Counting_Opp_Prescriber_Account iBatch=new Batch_Counting_Opp_Prescriber_Account(queryString);         
        
         
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- execute: Query:- '+iBatch.query);
        
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- execute: Execute the Batch');
        ID batchprocessid = Database.executeBatch(iBatch,1000);
        
        System.debug('## Class Schedule_Counting_Opp_Prescriber_Account- end of method execute');  
    }

}