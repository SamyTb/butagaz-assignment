@isTest
public class Schedule_Batch_Upd_PTL_ContactMKT_Test{

  public static testmethod void fieldContactMKT() {
    Batch_Updating_PTL_ContactMKT iBatch = new Batch_Updating_PTL_ContactMKT();
    
    Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
    insert new List<Custom_Settings__c> { c1 };
    
    // Account
    Account oNewAcc= new Account(name = 'Test Account', En_cours_d_immatriculation__c = true, No_E_mail__c = true,Street_Number__c = '10',
    Postal_Box__c = '93420',Postal_Code__c = '93420', City__c = 'Villepinte',Fax = '01.00.00.00.00',Place_Called__c = 'Raspail',
    Country__c='FR', Phone='0101010101');
    insert oNewAcc;
    
    //Contact
     Contact oContactMktTemp = new Contact();
                    oContactMktTemp.Contact_Marketing__c  = true;
                    oContactMktTemp.firstName = 'Contact Marketing';
                    oContactMktTemp.lastName = 'Contact Marketing';
                    oContactMktTemp.accountId = oNewAcc.Id;
                    oContactMktTemp.LastName = oNewAcc.Name;
                    oContactMktTemp.Street_Number__c = oNewAcc.Street_Number__c;
                    oContactMktTemp.Postal_Box__c = oNewAcc.Postal_Box__c;
                    oContactMktTemp.Postal_Code__c = oNewAcc.Postal_Code__c;
                    oContactMktTemp.City__c = oNewAcc.City__c;
                    oContactMktTemp.Email = oNewAcc.Email__c;
                    oContactMktTemp.Email_2__c = oNewAcc.Email_2__c;
                    oContactMktTemp.Fax = oNewAcc.Fax;
                    oContactMktTemp.Place_Called__c = oNewAcc.Place_Called__c;
                    oContactMktTemp.Country__c = oNewAcc.Country__c;
                    oContactMktTemp.Phone = oNewAcc.Phone;
                     
                    insert oContactMktTemp;
    
    
    
     // Activity Domain
        //Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        Activity_Domain__c oAdd = new Activity_Domain__c(Name='GEB',ExternalID__c=41);
        insert oAdd;
    
   // New PTL      
        PTL__c oNewPTL = new PTL__c(Name = 'oNewPTL', Account_DO__c=oNewAcc.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true,Client_ouvert_toute_l_annee__c=true);
        insert oNewPTL;
       
  
    
    // Start test
        test.starttest();
        
        Database.executeBatch(iBatch);
        
        Schedule_Batch_Updating_PTL_ContactMKT sb = new Schedule_Batch_Updating_PTL_ContactMKT();        
        String sch = '0 0 6 * * ?';        
        system.schedule('Batch Updating PTL ContactMKT', sch, sb);
        
        // Stop test        
        test.stoptest();
        
        PTL__c ptlSoql = [Select p.Id, 
                            p.Contact_Marketing__c
                        From PTL__c p WHERE p.Id = :oNewPTL.Id];
          
        System.assertEquals(ptlSoql.Contact_Marketing__c,oContactMktTemp.id );
      
  }
  
  
 
}