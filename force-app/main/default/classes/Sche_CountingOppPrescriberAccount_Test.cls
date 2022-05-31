@isTest
global class Sche_CountingOppPrescriberAccount_Test {
     Map<Id, Integer> mAccountValues = new Map<Id, Integer>();
     private static Mandataire__c mandataire= null;
     private static Canton__c canton = null;
     private static City__c city = null;
     private static City_Postal_Code__c postalCode = null; 
     
     
     
      private static Mandataire__c getMandataire() {
        if (Sche_CountingOppPrescriberAccount_Test.mandataire== null) {
  
            Mandataire__c oMandataire = new Mandataire__c();
            insert oMandataire ;
            
            if (oMandataire.Id == null) { 
               oMandataire.name = 'NewRefSAP Mandataire';
               oMandataire.ExternalID__c = '773';
               oMandataire.Active__c = true;
               oMandataire.MatriculeEnCours__c=3;
               insert oMandataire;
           }
            
            Sche_CountingOppPrescriberAccount_Test.mandataire= oMandataire;
        }
        
        return Sche_CountingOppPrescriberAccount_Test.mandataire;
    }
     
     
     
     

     private static Canton__c getCanton() {
        if (Sche_CountingOppPrescriberAccount_Test.canton == null) {
        
          
        
            Canton__c oCanton = new Canton__c(
                Name = 'COGNAC-SUD',
                INSEE_Code__c = '1633'
            );
            insert oCanton;
            if (oCanton.Id == null) { 
                oCanton.Name = 'COGNAC-SUD';
                oCanton.INSEE_Code__c = '1633';
                oCanton.Mandataire__c=Sche_CountingOppPrescriberAccount_Test.getMandataire().Id;
                insert oCanton;
            }
            
            Sche_CountingOppPrescriberAccount_Test.canton = oCanton;
        }
        
        return Sche_CountingOppPrescriberAccount_Test.canton;
    }
    
    private static City__c getCity() {
        if (Sche_CountingOppPrescriberAccount_Test.city == null) {
            City__c oCity = new City__c();
            oCity.Name = 'LOUZAC-SAINT-ANDRE';
            oCity.Canton__c = Sche_CountingOppPrescriberAccount_Test.getCanton().Id;
            insert oCity;
            Sche_CountingOppPrescriberAccount_Test.city = oCity;
        }
        
        return Sche_CountingOppPrescriberAccount_Test.city;
    }
    
    private static City_Postal_Code__c getPostalCode() {   
        if (Sche_CountingOppPrescriberAccount_Test.postalCode == null) {
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(
                Code_Type__c = 'M',
                HEXAPOSTE_Code__c = '1234',
                Postal_Code__c = '16100'
            );
            if (oPostalCode.Id == null) { 
                oPostalCode.City__c = Sche_CountingOppPrescriberAccount_Test.getCity().Id;
                oPostalCode.Code_Type__c = 'M';
                oPostalCode.HEXAPOSTE_Code__c = '1234';
                oPostalCode.Postal_Code__c = '16100';
                insert oPostalCode;
            }
                
            Sche_CountingOppPrescriberAccount_Test.postalCode = oPostalCode;
        }
        
        return Sche_CountingOppPrescriberAccount_Test.postalCode;
    }
    
     public static Opportunity CreateOpportunity(Id acctId, Id prescriberId, String status, Integer duration){
        // duration is the nomber of month before taday's date, and is representaed by months.
        // if you want to check for opportunities closed since less than 2 years you enter a number less than '24' months
        
        Date datePeriod = Date.today();
        
        
        
        Opportunity oOpportunity = new Opportunity (Name = 'oppName', Project_Type__c = 'Succession', 
                                                    CloseDate = datePeriod.addMonths(-duration), StageName = status, Assign__c= false, 
                                                    Channel__c = 'Mail', LeadSource = 'Other', AccountId = acctId, Client_Type__c = 'Locataire',
                                                    Project_City_Postal_Code__c = Sche_CountingOppPrescriberAccount_Test.getPostalCode().Id
                                                    );
        
        
        //oOpportunity.Project_City_Postal_Code__c = Sche_CountingOppPrescriberAccount_Test.getPostalCode().Id;
        
        System.debug('## Class Sche_CountingOppPrescriberAccount_Test - CreateOppotunities:'+ oOpportunity.Project_City_Postal_Code__c);
        
        
        if (prescriberId != null) {
            oOpportunity.Prescriber_Account__c = prescriberId;
        }
        
        return oOpportunity; 
    }
     
    public static Map<Id, Integer> CreateAccountOppotunities(){
        List<Account> lTestAccounts = new List<Account>();
        List<Opportunity> lTestOpportunities = new List<Opportunity>();
        Map<Id, Account> mAccounts = new Map<Id, Account>();
        Map<Id, Integer> mAccountValues = new Map<Id, Integer>();
       
        //150
        for (Integer i = 0; i < 10; i++) {
            Account oAccount = new Account (Name = 'TestAccount'+i, Street_Number__c ='23 Test Avenue', City__c = 'Test_City', Postal_Code__c ='12345', Country__c = 'FR', Prescriber__c = true,  
                                            Prescriber_Activity__c = '123', Phone='0202020202',Email__c='titi.tata@gmail.com');
            lTestAccounts.add(oAccount);
        }
        
        insert lTestAccounts;
        Integer i = 0; 
        Account oAcct = new Account(Name = 'acctName', Market_Type__c = 'DOM', 
                                    Street_Number__c ='23 Test Avenue', City__c = 'Test_City', 
                                    Postal_Code__c ='12345', Country__c = 'FR', Phone='0202020202',Email__c='titi.tata@gmail.com'); // NOT a prescriber (it's to have the MT). 
        insert oAcct;
        for (Account oAccount:lTestAccounts){
            System.debug('## Class Sche_CountingOppPrescriberAccount_Test - CreateAccountOppotunities:'+i);

                if (i < 20) {// Case of Opportunities are won
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 4); 
                        lTestOpportunities.add(oOpportunity);
                        
                    }
                    mAccountValues.put(oAccount.Id,5);
    
                } else if ((i >= 20) && (i < 40)) {// Case of Opportunities are Lost
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Lost', 4); 
                        lTestOpportunities.add(oOpportunity);
                    }
                    mAccountValues.put(oAccount.Id,0);
                    
                } else if ((i >= 40) && (i < 60)) {// Case of Opportunities are Mixte between Won and Lost
                    for (Integer j = 0; j < 5; j++){
                        if(math.mod(j, 2) == 0){
                            Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 4); 
                            lTestOpportunities.add(oOpportunity);
                        } else {
                            Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Lost', 4);                            
                            lTestOpportunities.add(oOpportunity);
                        }
                    }
                    mAccountValues.put(oAccount.Id,3);
                    
                } else if ((i >= 60) && (i < 80)) { // Case of Opportunities are Won since more than 2 years
                    for (Integer j = 0; j < 5; j++){ 
                        Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 27); 
                        lTestOpportunities.add(oOpportunity);
                    }
                    mAccountValues.put(oAccount.Id,0);
                    
                } else if ((i >= 80) && (i < 100)) { // Case of Opportunities are mixte Won since 2  years and more than 2 years
                    for(Integer j = 0; j < 8; j++){
                        if (math.mod(j,2) == 0){
                            Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 27);
                            lTestOpportunities.add(oOpportunity);
                        } else {
                            Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 4);
                            lTestOpportunities.add(oOpportunity);
                        }
                    }
                    mAccountValues.put(oAccount.Id,4);
                    
                } else if ((i >= 100) && (i < 120)) {// Opportunity not linked to a Prescriber
                    Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, null, 'Close Won', 4);
                    lTestOpportunities.add(oOpportunity);
    
                    
                       
                } else { // Case of Opportunities are Won 
                    Opportunity oOpportunity = Sche_CountingOppPrescriberAccount_Test.CreateOpportunity(oAcct.Id, oAccount.id, 'Close Won', 4);
                    lTestOpportunities.add(oOpportunity);
                    mAccountValues.put(oAccount.Id,1);
                }
                i++; 
        }
        System.debug('## Class Sche_CountingOppPrescriberAccount_Test - Insert lTestOpportunities');
        
        insert lTestOpportunities;
     
        return mAccountValues;
 }
 
    public static testmethod void execute() {
        
        
        User userA=TestUtilitiesOrganization.CreateTestUser('testUser', 'Butagaz System Administrator');
        userA.Bypass_Apex_Triggers__c='Account.syncOpportunityFromAccount';
        insert userA;
        
        Custom_Settings__c cs1 = new Custom_Settings__c(name='Window_Won_Prescribed_Opportunities',value__c = '24');
        Custom_Settings__c cs2 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert cs1;
        insert new List<Custom_Settings__c> { cs1, cs2 };
        
        
        System.runas(userA){
            
            //Start Test
            Test.startTest();
            
            System.debug('##Sche_CountingOppPrescriberAccount_Test - CreateAccountOppotunities');
             
            
            Map<Id, Account> mAccounts = new Map<Id, Account>(); 
            Map<Id,Integer> mAccountsNumber= new Map<Id, Integer>(); 
            mAccountsNumber = Sche_CountingOppPrescriberAccount_Test.CreateAccountOppotunities();
            
            System.debug('##Sche_CountingOppPrescriberAccount_Test - finish CreateAccountOppotunities');
            
            System.debug('##Sche_CountingOppPrescriberAccount_Test - The Batch for counting won opportunities');
            //Call the Bath Counting Batch_CountingOppPrescriberAccount 
            String queryString = 'SELECT id, Prescribed_Opportunties_Won__c FROM Account WHERE Prescriber__c =true and Name Like \'%TestAccount%\'';
            Batch_Counting_Opp_Prescriber_Account iBatch = new Batch_Counting_Opp_Prescriber_Account(queryString);
            ID batchprocessid = Database.executeBatch(iBatch,1000);
            
            Test.stopTest();
            
            // Test if the batch process has completed successfull
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
            
            System.AssertEquals(0, a.NumberOfErrors);
            System.AssertEquals('Completed', a.status);
            
            System.debug('##Sche_CountingOppPrescriberAccount_Test - The Batch for counting won opportunities');
    
    
            System.debug('##Sche_CountingOppPrescriberAccount_Test - Testing the batch\'s results');
            //fetch all the database again
            
    
            mAccounts=new map<Id,Account>([select Id,Prescribed_Opportunties_Won__c from Account where Name like '%TestAccount%']);
            
            /*for(ID eId:mAccountsNumber.keyset()){
                system.assertequals(mAccountsNumber.get(eId), mAccounts.get(eId).Prescribed_Opportunties_Won__c);
            }*/
                
        }
    }
}