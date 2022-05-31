global class Schedule_Counting_Opp_Prescriber_User implements Schedulable {

    global void execute (SchedulableContext sc) {  
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- Start of method execute');       
     
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- execute: retrieve Prescribers');
        
        String queryString = 'SELECT id, Prescribed_Opportunties_Won__c FROM User WHERE Prescriber__c =true'; 
        
 
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- execute: Create a new instance of class BatchCreateGrid (Batch)');
        Batch_Counting_Opp_Prescriber_User iBatch=new Batch_Counting_Opp_Prescriber_User(queryString);         
        
         
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- execute: Query:- '+iBatch.query);
        
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- execute: Execute the Batch');
        ID batchprocessid = Database.executeBatch(iBatch,1000);
        
        System.debug('## Class Schedule_Counting_Opp_Prescriber_User- end of method execute');  
    }

}