@isTest
public with sharing class AP_Account_01_Test {
    public static testmethod void testCopyRemonteeConcurrenceGEB(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        // Data Model
        // Activity Domain
        Activity_Domain__c oAdd = new Activity_Domain__c(name = 'Test', ExternalID__c=41);
        insert oAdd;
        
        // Account Predecessor
        Account oAccPredecessor = new Account(name='AccPredecessor', Activity_Domain__c=oAdd.Id,Country__c='FR', Email__c='some.email@test.org', Phone='0202020202');
        insert oAccPredecessor;
        
        // "Remontée Concurrence GEB" of Predecessor
        Remontee_concurrence_GEB__c oRC = new Remontee_concurrence_GEB__c(Compte__c = oAccPredecessor.Id, Declaration_legale__c=true); 
        insert oRC;

        // Start test
        test.starttest();

        // New Account
        Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Predecessor__c=oAccPredecessor.Id,Email__c='titi.tata@gmail.com',Country__c='FR', Phone='0202020202');
        insert oNewAcc;
        
        // Check "Remontée Concurrence GEB" of New Account
        list<Remontee_concurrence_GEB__c> lRCToCheck = new list<Remontee_concurrence_GEB__c>();
        for(Remontee_concurrence_GEB__c oRCToCheck:[select id from Remontee_concurrence_GEB__c where Compte__c = :oNewAcc.Id]){
          lRCToCheck.add(oRCToCheck);
        }
        
       // System.assertEquals(1, lRCToCheck.size());
        
         // Stop test        
        test.stoptest();
    }
    
    
    public static testmethod void testAccountMKTContactWithoutPred(){
    
    Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
    
    Activity_Domain__c oAdd = new Activity_Domain__c(name = 'Test', ExternalID__c=41);
        insert oAdd;
        
        // Account Predecessor
        Account oAccPredecessor = new Account(name='AccPredecessor', Activity_Domain__c=oAdd.Id,Country__c='FR', Phone='0202020202',email__c='toto@tata.com');
        insert oAccPredecessor;
        
        
        // Account Predecessor Contact
        Contact oAccPredecessorContact = new Contact(accountId=oAccPredecessor.Id, LastName='Toto', Contact_Marketing__c=true);
        insert oAccPredecessorContact;
    
    // New Account
        //Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Predecessor__c=oAccPredecessor.Id, CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202');
        Account oNewAcc = new Account(name='NewAccMKT', Activity_Domain__c=oAdd.Id, Predecessor__c=null, CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202');
        insert oNewAcc;
        
        // Delete contact automatically created by the trigger AfterInsert on Account
        //Contact oContactToDel = [select id from Contact where accountId =:oNewAcc.id];
        //delete oContactToDel;
        
    
        // Start test
        test.starttest();
        
        // Check New Account
        list<Account> lAccount = new list<Account>();
        for(Account oAccount:[SELECT Id, Predecessor__c, IsPersonAccount, CT_statutConversion__c, A_convertir__c, Name, Street_Number__c, Postal_Box__c, Postal_Code__c, City__c, Email__c, Email_2__c, Fax, Place_Called__c, Country__c, Phone FROM Account WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oNewAcc.Id]){
          lAccount.add(oAccount);
        }
        System.assertEquals(1, lAccount.size());
        
        
        // Call method
        AP_Account_01.manageMKTContactELC(lAccount);
        
        Contact oContactToTest = [select id, Contact_Marketing__c from Contact where accountId =:oNewAcc.id];
        System.assertEquals(oContactToTest.Contact_Marketing__c, true);
        
         // Stop test
        test.stoptest();
    }
    
    
    public static testmethod void testAccountMKTContactWithPred(){
    
    Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
    
    Activity_Domain__c oAdd = new Activity_Domain__c(name = 'Test', ExternalID__c=41);
        insert oAdd;
        
        // Account Predecessor
        Account oAccPredecessor = new Account(name='AccPredecessor', Activity_Domain__c=oAdd.Id,Email__c='titi.tata@gmail.com',Country__c='FR', Phone='0202020202');
        insert oAccPredecessor;
        
        
        // Account Predecessor Contact
        Contact oAccPredecessorContact = new Contact(accountId=oAccPredecessor.Id, LastName='Toto', Contact_Marketing__c=true);
        insert oAccPredecessorContact;
    
        // New Account
        //Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Predecessor__c=oAccPredecessor.Id, CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202');
        Account oNewAcc = new Account(name='NewAccMKT', Activity_Domain__c=oAdd.Id, Predecessor__c=oAccPredecessor.Id, CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202', Street_type__c='TypeRue', Street_name__c='NomRue');
        insert oNewAcc;
        
        // Delete contact automatically created by the trigger AfterInsert on Account
       // Contact oContactToDel = [select id from Contact where accountId =:oNewAcc.id];
       // delete oContactToDel;
        
        // Account Predecessor Contact
        Contact oAccContact = new Contact(accountId=oAccPredecessor.Id, LastName='Toto', Contact_Marketing__c=true);
        insert oAccContact;
        
    
        // Start test
        test.starttest();
        
        // Check New Account
        list<Account> lAccount = new list<Account>();
        for(Account oAccount:[SELECT Id, Predecessor__c, IsPersonAccount, CT_statutConversion__c, A_convertir__c, Name, Street_Number__c, Postal_Box__c, Postal_Code__c, City__c, Email__c, Email_2__c, Fax, Place_Called__c, Country__c, Phone FROM Account WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oNewAcc.Id]){
          lAccount.add(oAccount);
        }
        System.assertEquals(1, lAccount.size());
        
        
        // Call method
        AP_Account_01.manageMKTContactELC(lAccount);
        
        Contact oContactToTest = [select id, Contact_Marketing__c from Contact where accountId =:oNewAcc.id limit 1];
        System.assertEquals(oContactToTest.Contact_Marketing__c, true);
        
        
         // Stop test
        test.stoptest();
    }
    

    
    
    //MLC 20161103
    public static testmethod void updateTelEmailContactMKT() {
        
         String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
         
         User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
                Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
                LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
                
         insert u;
            
         Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
         insert new List<Custom_Settings__c> { c1 };
            
          System.runAs(u) 
                {
     
                    //Activity Domain
                    Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
                    insert AD_GEC;
                                  
                    //Mandataire
                    Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3
                    );
                    insert mandataire1;
  
               
         
                    //Canton
                    Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
                    insert Canton1;
        
                  
                    //City
                    City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
                    insert City1;
                  
                 
                    City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                    City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                    insert cityCP1; 

                    RecordType rtPA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
                    RecordType rtBA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];

                    //Account
                    Account NewAcc = new Account(name='NewAccMKT', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                    CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'DOM',
                    Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                    Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202' , recordtypeId=rtBA.Id);
                    insert NewAcc;
            
                       
                     // New Contact
                    Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = NewAcc.Id,Street_Number__c = NewAcc.Street_Number__c,Postal_Box__c = NewAcc.Postal_Box__c,
                    Postal_Code__c = NewAcc.Postal_Code__c,City__c = NewAcc.City__c,Email = NewAcc.Email__c,Email_2__c = NewAcc.Email_2__c,
                    Fax = NewAcc.Fax,Place_Called__c = NewAcc.Place_Called__c,Country__c = NewAcc.Country__c,Phone = NewAcc.Phone);
                    insert c;
                     
                     // Start test
                    test.starttest();
                    
                    // Check New Account
                    list<Account> lAccount = new list<Account>();
                    for(Account oAccount:[SELECT Id, Predecessor__c, IsPersonAccount, CT_statutConversion__c, A_convertir__c, Name, Street_Number__c, Postal_Box__c, Postal_Code__c, City__c, Email__c, Email_2__c, Fax, Place_Called__c, Country__c, Phone FROM Account WHERE Activity_Domain__r.ExternalID__c=42 AND Id = :NewAcc.Id]){
                        lAccount.add(oAccount);
                    }
                                      
                    // Call method MLC20161103
                    //AP_Account_01.updateTelEmailContactMKT(lAccount);
                    
                   
                    
                    // Stop test
                    test.stoptest();
    }
    
    
    }
    
    public static testmethod void testUpdateEspaceClientEncryptedParams(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c1, c9, c10, c11, c12 };
        
        // Data Model
        // Activity Domain
        Activity_Domain__c oAdd = new Activity_Domain__c(name = 'Test', ExternalID__c=42);
        insert oAdd;
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = '999',
            Active__c = true
        );
        insert mand1;
        
        Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
        insert Canton1;
        City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        // New Account
        Account oNewAcc = new Account(name='NewAcc', AccountNumber='ACCNUM', Activity_Domain__c=oAdd.Id, City_Postal_Code__c=cityCP.Id, Email__c='titi.tata@gmail.com', Country__c='FR', Phone='0202020202');
        insert oNewAcc;

        // Start test
        test.starttest();

        list<Account> lAccount = new list<Account>();
        for(Account oAccount:[SELECT Id FROM Account WHERE Activity_Domain__r.ExternalID__c=42 AND Id = :oNewAcc.Id]){
            lAccount.add(oAccount);
        }
        
        AP_Account_01.updateEspaceClientEncryptedParams(lAccount);
        
        // System.assertEquals(1, lRCToCheck.size());
        
        // Stop test        
        test.stoptest();
    }
    
    
    //MLC 20180309
   /* public static testmethod void updateReferencePrecripteur() {
        
         String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
         
         User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
                Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
                LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
                
         insert u;
            
         Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
         insert new List<Custom_Settings__c> { c1 };
            
          System.runAs(u) 
                {
     
                    //Activity Domain
                    Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
                    insert AD_GEC;
                                  
                    //Mandataire
                    Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3
                    );
                    insert mandataire1;
  
               
         
                    //Canton
                    Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
                    insert Canton1;
        
                  
                    //City
                    City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
                    insert City1;
                  
                 
                    City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                    City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                    insert cityCP1; 

                    RecordType rtPA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
                    RecordType rtBA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];

                    //Account
                    Account NewAcc = new Account(name='NewAccMKT', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                    CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'PRO',
                    Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                    Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202' , recordtypeId=rtBA.Id);
                    insert NewAcc;
            
                       
                     // New Contact
                    Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = NewAcc.Id,Street_Number__c = NewAcc.Street_Number__c,Postal_Box__c = NewAcc.Postal_Box__c,
                    Postal_Code__c = NewAcc.Postal_Code__c,City__c = NewAcc.City__c,Email = NewAcc.Email__c,Email_2__c = NewAcc.Email_2__c,
                    Fax = NewAcc.Fax,Place_Called__c = NewAcc.Place_Called__c,Country__c = NewAcc.Country__c,Phone = NewAcc.Phone);
                    insert c;
                     
                     // Start test
                    test.starttest();
                    
                    // Check New Account
                    list<Account> lAccount = new list<Account>();
                    for(Account oAccount:[SELECT Id, Predecessor__c, IsPersonAccount, CT_statutConversion__c, A_convertir__c, Name, Street_Number__c, Postal_Box__c, Postal_Code__c, City__c, Email__c, Email_2__c, Fax, Place_Called__c, Country__c, Phone FROM Account WHERE Activity_Domain__r.ExternalID__c=42 AND Id = :NewAcc.Id]){
                        lAccount.add(oAccount);
                    }
                                      
                    // Call method MLC20161103
                    AP_Account_01.updateReferencePrecripteur(lAccount);
                    
                   
                    
                    // Stop test
                    test.stoptest();
    }
    
    
    }*/
    
      public static testmethod void updateReferencePrecripteur() {
        
         String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
          User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
                Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
                LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
                
            insert u;
            
            
            
          System.runAs(u) 
                {
     
     
                    List<account> acc = new List<account>();
     
                    //Activity Domain
                    Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
                    insert AD_GEC;
                                  
                    //Mandataire
                    Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '773',Active__c = true,MatriculeEnCours__c=3
                    );
                    insert mandataire1;
                    
                        Mandataire__c MandataireCanton1 = [ SELECT id,name, MatriculeEnCours__c,ExternalID__c
                                                        FROM Mandataire__c 
                                                        WHERE id = :mandataire1.id
                                                        ];
  
                    //Canton
                       Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=MandataireCanton1.id);
                       insert Canton1;
        
                  
                      //City
                      City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
                      insert City1;
                  
                 
                      City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                      City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                      insert cityCP1; 
                      
                   test.startTest();           
                      
                        Custom_Settings__c c1= new Custom_Settings__c (name='ReferencePrescripteur',value__c = '1');
                        insert new List<Custom_Settings__c> { c1};
            
            
                       string sLatestNumber = c1.value__c;
                       integer iLatestNumber = Integer.valueOf(sLatestNumber);
                      
                      
                      
                         //Account
                        Account NewAccRefPresc = new Account(name='NewAccMKT', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                        CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'DOM',
                        Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                        Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202',Prescriber__c=true, AccountNumber='PRESC00001');
                       acc.add(NewAccRefPresc );
                     
            
                      AP_Account_01.updateReferencePrecripteur(acc);
                                              
                                        
                    test.stopTest();
                
                
           


                  

                    System.Debug('### >>>>> testing class AP_ACCOUNT_01_Test.updateReferencePrecripteur END<<<<<');}
     
     }

    
    
}