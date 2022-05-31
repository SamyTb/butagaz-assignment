@isTest
global class Sche_CountingOppPrescriberUser_Test {

   Map<Id, Integer> mUserValues = new Map<Id, Integer>();
     public static Opportunity CreateOpportunity(Id acctId, Id prescriberId, String status, Integer duration){
        // duration is the nomber of month before taday's date, and is representaed by months.
        // if you want to check for opportunities closed since less than 2 years you enter a number less than '24' months
        
        Date datePeriod = Date.today();
        Opportunity oOpportunity = new Opportunity (Name = 'oppName', Project_Type__c = 'Succession', 
                                                    CloseDate = datePeriod.addMonths(-duration), StageName = status, Assign__c= false, 
                                                    Channel__c = 'Mail', LeadSource = 'Other', AccountId = acctId, Client_Type__c = 'Locataire' 
                                                    );
        if (prescriberId != null) {
            oOpportunity.Prescriber_User__c = prescriberId;
        }
        
        return oOpportunity; 
    }
     
    public static Map<Id, Integer> CreateUserOppotunities(){
        List<User> lTestUsers = new List<User>();
        List<Opportunity> lTestOpportunities = new List<Opportunity>();
        Map<Id, Integer> mUserValues = new Map<Id, Integer>();
       

        
        Account oAcct = new Account(Name = 'acctName', Market_Type__c = 'DOM', 
                                    Street_Number__c ='23 Test Avenue', City__c = 'Test_City', 
                                    Postal_Code__c ='12345', Country__c = 'FR',Email__c='titi.tata@gmail.com'); // NOT a prescriber (it's to have the MT). 
                                    
       insert oAcct;   
            
       Profile profile = [SELECT Id FROM Profile WHERE Name ='Butagaz Standard User'  LIMIT 1];                    
       for (Integer i = 0; i < 150; i++) {
            //lTestUsers.add(TestUtilitiesOrganization.CreateInactivePrescriberTestUser('test'+i, profile.Id));
        }
        insert lTestUsers ;
        Integer i=0;
        for (User oUser:lTestUsers ){
            System.debug('## Class Sche_CountingOppPrescriberUser_Test - CreateUserOppotunities:'+i);

                if (i < 20) {// Case of Opportunities are won
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 4); 
                        lTestOpportunities.add(oOpportunity);
                        
                    }
                    mUserValues.put(oUser.Id,5);
    
                } else if ((i >= 20) && (i < 40)) {// Case of Opportunities are Lost
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Lost', 4); 
                        lTestOpportunities.add(oOpportunity);
                    }
                    mUserValues.put(oUser.Id,0);
                    
                } else if ((i >= 40) && (i < 60)) {// Case of Opportunities are Mixte between Won and Lost
                    for (Integer j = 0; j < 5; j++){
                        if(math.mod(j, 2) == 0){
                            Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 4); 
                            lTestOpportunities.add(oOpportunity);
                        } else {
                            Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Lost', 4);                            
                            lTestOpportunities.add(oOpportunity);
                        }
                    }
                    mUserValues.put(oUser.Id,3);
                    
                } else if ((i >= 60) && (i < 80)) { // Case of Opportunities are Won since more than 2 years
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 27); 
                        lTestOpportunities.add(oOpportunity);
                    }
                    mUserValues.put(oUser.Id,0);
                    
                } else if ((i >= 80) && (i < 100)) { // Case of Opportunities are mixte Won since 2  years and more than 2 years
                    for(Integer j = 0; j < 8; j++){
                        if (math.mod(j,2) == 0){
                            Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 27);
                            lTestOpportunities.add(oOpportunity);
                        } else {
                            Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 4);
                            lTestOpportunities.add(oOpportunity);
                        }
                    }
                    mUserValues.put(oUser.Id,4);
                    
                } else if ((i >= 100) && (i < 120)) {// Opportunity not linked to a Prescriber
                    Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, null, 'Close Won', 4);
                    lTestOpportunities.add(oOpportunity);
    
                   
                      
                } else { // Case of Opportunities are Won 
                    Opportunity oOpportunity = Sche_CountingOppPrescriberUser_Test.CreateOpportunity(oAcct.Id, oUser.id, 'Close Won', 4);
                    lTestOpportunities.add(oOpportunity);
                    mUserValues.put(oUser.Id,1);
                }
                i++; 
        }
        System.debug('## Class Sche_CountingOppPrescriberUser_Test - Insert lTestOpportunities');
        
        insert lTestOpportunities;
     
        return mUserValues;
 }
 
    public static testmethod void execute() {
      
      
      User userA=TestUtilitiesOrganization.CreateTestUser('testUser', 'Butagaz System Administrator');
        userA.Bypass_Apex_Triggers__c='Account.syncOpportunityFromAccount';
        userA.Bypass_Validation_Rules__c=true;
       insert userA;
       
       Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c =  '005D0000002Dx4R;005D0000002EgIr;005D0000002EgIw');
       insert new List<Custom_Settings__c> { c1 };
       
       System.runas(userA){
                
         //Start Test
          Test.startTest();
          System.debug('##Sche_CountingOppPrescriberUser_Test - CreateUserOppotunities');
          Map<Id, User> mUsers = new Map<Id, User>(); 
          Map<Id,Integer> mUsersNumber= new Map<Id, Integer>(); 
          mUsersNumber= Sche_CountingOppPrescriberUser_Test.CreateUserOppotunities();
          System.debug('##Sche_CountingOppPrescriberUser_Test - finish CreateUserOppotunities');
          
          System.debug('##Sche_CountingOppPrescriberUser_Test - The Batch for counting won opportunities');
          //Call the Bath Counting Batch_CountingOppPrescriberUser 
          String queryString = 'SELECT id, Prescribed_Opportunties_Won__c FROM User WHERE Prescriber__c =true and Name Like \'%Test%\'';
          Batch_Counting_Opp_Prescriber_User iBatch = new Batch_Counting_Opp_Prescriber_User(queryString);
          ID batchprocessid = Database.executeBatch(iBatch,1000);
          Test.stopTest();
          // Test if the batch process has completed successfull
          AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
          System.AssertEquals(0, a.NumberOfErrors);
          System.AssertEquals('Completed', a.status);
          
          System.debug('##Sche_CountingOppPrescriberUser_Test - The Batch for counting won opportunities');
  
  
          System.debug('##Sche_CountingOppPrescriberUser_Test - Testing the batch\'s results');
          //fetch all the database again
          
  
      mUsers=new map<Id,User>([select Id,Prescribed_Opportunties_Won__c from User where Name like '%Test%']);
      
      for(ID eId:mUsersNumber.keyset()){
        system.assertequals(mUsersNumber.get(eId),mUsers.get(eId).Prescribed_Opportunties_Won__c);
      }
           
       }
    }


}