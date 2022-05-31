global class Schedule_Counting_PTL_ActivityHistory implements Schedulable {
/* 
----------------------------------------------------------------------
-- - Name          : Schedule_Counting_PTL_ActivityHistory 
-- - Author        : Erwan
-- - Description   : Class to schedule batch to calculate the number of history events on the PTL
--                   
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 08-FEB-2016  SC    1.0      Initial version
----------------------------------------------------------------------
**********************************************************************
*/
    global void execute (SchedulableContext sc) {  
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- Start of method execute');       
     
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- execute: retrieve PTLs');
        
        String queryString = 'SELECT Id, Nombre_de_visites__c, Nombre_de_contacts_telephoniques__c, Nombre_de_visites_Percent__c, Nombre_de_contacts_telephoniques_Percent__c '
			+ 'FROM PTL__c '
			+ 'WHERE Activity_Domain__r.ExternalID__c = 41 '
			+ 'AND Code_Canal__c = \'RE\''; 
        
 		
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- execute: Create a new instance of class BatchCreateGrid (Batch)');
        Batch_Counting_PTL_ActivityHistory iBatch=new Batch_Counting_PTL_ActivityHistory(queryString);         
        
         
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- execute: Query:- '+iBatch.query);
        
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- execute: Execute the Batch');
        ID batchprocessid = Database.executeBatch(iBatch,1000);
        
        System.debug('## Class Schedule_Counting_PTL_ActivityHistory- end of method execute');  
    }

}