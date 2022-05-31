@isTest
public class AP_Opportunity_Test {
    public static boolean isTest = true;
    public static testmethod void isSiretOuEnCoursDImmat() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmat <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT1',Alias='APOT1',
            Email='APOT1@shell.com',Username='APOT1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;
            
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '591',Active__c = true,MatriculeEnCours__c=3);
             insert mandataire1;
        
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
                
            //Canton
            Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
        
           //City
           City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
           insert City1;    
                
           City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                      City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                      insert cityCP1;      
                
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                Code_SIRET__c = '', En_cours_d_immatriculation__c = true, No_E_mail__c  = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
                  
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,
            Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,
            Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
            insert c;
        
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', 
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id,DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,T_MandataireId__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];
                                                        
                                                        
            Mandataire__c IsSiretOuEnCoursDImmatSoql= [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                          FROM Mandataire__c                                   
                                                         WHERE id= :mandataire1.id LIMIT 1];                                            
                                
            opties.add(optyIsSiretOuEnCoursDImmatSoql);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmat END<<<<<');
    }
    
    public static testmethod void isSiretOuEnCoursDImmatBis() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatBis <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
            Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            List<Opportunity> opties = new List<Opportunity>();
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
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
        
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
                
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                Code_SIRET__c = null, En_cours_d_immatriculation__c = true, No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
                  
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,
            Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
            insert c;
            
            
            
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '11111111111110', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', 
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id,DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];
                                                        
            Mandataire__c IsSiretOuEnCoursDImmatSoql= [  SELECT id, MatriculeEnCours__c,ExternalID__c
            FROM Mandataire__c                                   
            WHERE id= :mandataire1.id LIMIT 1];    
                                
            opties.add(optyIsSiretOuEnCoursDImmatSoql);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
            
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatBis END<<<<<');
    }
    
    public static testmethod void isSiretOuEnCoursDImmatTer() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatTer <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT3',Alias='APOT3',
            Email='APOT3@shell.com',Username='APOT3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            List<Opportunity> opties = new List<Opportunity>();
            
            List<Group> lgBO = new List<Group>([Select Id From Group where DeveloperName= 'BackOffice' LIMIT 1]);
            if (lgBO.size() == 0) {
                Group newGroup = new Group();
                newGroup.Name = 'BackOffice';
                newGroup.DeveloperName = 'BackOffice';
                newGroup.DoesIncludeBosses = false; 
                insert newGroup;
                lgBO = new List<Group>([Select Id From Group where Name= 'BackOffice' LIMIT 1]);
            }
            GroupMember gmBOUser = new GroupMember(GroupId=lgBO[0].id, UserOrGroupId=u.id);
            insert gmBOUser;
            
              //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;
                        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '549',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_', Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APOT1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APOT1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
        
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
                
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                Code_SIRET__c = '', En_cours_d_immatriculation__c = false, No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
                   
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,
            Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
            insert c;
            
            
            Account acc2 = new Account(name = 'Butagaz', RecordType = recordTypeAccount,
                Code_SIRET__c = '54209557500859', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert acc2;
            
            
            
             // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = acc2.Id,Street_Number__c = acc2.Street_Number__c,Postal_Box__c = acc2.Postal_Box__c,
            Postal_Code__c = acc2.Postal_Code__c,City__c = acc2.City__c,Email = acc2.Email__c,
            Email_2__c = acc2.Email_2__c,
            Fax = acc2.Fax,Place_Called__c = acc2.Place_Called__c,Country__c = acc2.Country__c,Phone = acc2.Phone);
            insert c2;
        
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(
                name                                = 'isSiretOuEnCoursDImmat', 
                DO_Code_SIRET__c                    = '1111111111111', 
                Project_Type__c                     = 'CREA', 
                AccountId                           = compteIsSiretOuEnCoursDImmat.Id, 
                Assign__c                           = false, 
                StageName                           = 'Closed Won', 
                CloseDate                           = Date.parse('01/02/2014'),  
                Project_City_Postal_Code__c         = cityCP.id,
                DO_En_cours_d_immatriculation__c    = true,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat;
        
            Opportunity optyIsSiretOuEnCoursDImmat2 = new Opportunity(
                name                                = 'isSiretOuEnCoursDImmat2', 
                DO_Code_SIRET__c                    = '11111111111110', 
                Project_Type__c                     = 'CREA', 
                AccountId                           = compteIsSiretOuEnCoursDImmat.Id, 
                Assign__c                           = false, 
                StageName                           = 'Closed Won', 
                CloseDate                           = Date.parse('01/02/2014'), 
                Project_City_Postal_Code__c         = cityCP.id ,
                DO_En_cours_d_immatriculation__c    = true,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat2;
            
            Opportunity optySiretTest = new Opportunity(
                name                                = 'SiretTest', 
                Project_Type__c                     = 'CREA', 
                AccountId                           = compteIsSiretOuEnCoursDImmat.Id, 
                Assign__c                           = false, 
                StageName                           = 'Closed Won', 
                CloseDate                           = Date.parse('01/02/2014'),
                Project_City_Postal_Code__c         = cityCP.id,
                DO_Activity_Domain__c=AD_GEC.Id 
            );
        
            insert optySiretTest;
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = optySiretTest.Id, 
                PTL_Name__c = 'APOT1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );
            insert optyPTL1;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql = [  SELECT DO_Code_SIRET__c, 
                                                            DO_En_cours_d_immatriculation__c, 
                                                            Project_Type__c, 
                                                            T_AccountRecordTypeName__c, 
                                                            StageName, 
                                                            RecordType.Name,
                                                            AccountId,T_MandataireId__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];
                                                        
           Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                                                   
                                                        
            Opportunity optyIsSiretOuEnCoursDImmatSoql2 = [ SELECT DO_Code_SIRET__c, 
                                                            DO_En_cours_d_immatriculation__c, 
                                                            Project_Type__c, 
                                                            T_AccountRecordTypeName__c, 
                                                            StageName, 
                                                            RecordType.Name,
                                                            AccountId,T_MandataireId__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat2.Id];
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql2 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                FROM Mandataire__c                                   
                                                                WHERE id= :mandataire1.id LIMIT 1];                                             
                                                            
            opties.add(optyIsSiretOuEnCoursDImmatSoql);                     
            opties.add(optyIsSiretOuEnCoursDImmatSoql2);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatUpdate(opties, isTest), true);
            
            // Other Siret Tests
            Boolean aBool = AP_Opportunity.isSiretCodeOptyCorrect(optySiretTest);
            optySiretTest.DO_Code_SIRET__c = '54209557500859';
            update optySiretTest;
            aBool = AP_Opportunity.isSiretCodeOptyCorrect(optySiretTest);
            optySiretTest.DO_Code_SIRET__c = '35600000000048';
            optySiretTest.Account_Payer__c = acc2.id;
            optySiretTest.Account_Billed__c = acc2.id;
            optySiretTest.Opportunity_Won_Substage__c = 'Data validated by BO';
            update optySiretTest;
            aBool = AP_Opportunity.isSiretCodeOptyCorrect(optySiretTest);
            aBool = AP_Opportunity.isSiretOuEnCoursDImmatOptyInsert(optySiretTest);
            aBool = AP_Opportunity.isSiretOuEnCoursDImmatOptyUpdate(optySiretTest);
            aBool = AP_Opportunity.isEmailPasDEmailDOOpty(optySiretTest);
            aBool = AP_Opportunity.isEmailPasDEmailBilledOpty(optySiretTest);
            aBool = AP_Opportunity.isEmailPasDEmailPayerOpty(optySiretTest);
 
        
            
            // Back Office User
            aBool = AP_Opportunity.isBackOfficeUser();
            
            // Other methods
            Map<Id,Account> mAcc = new Map<Id,Account>();
            mAcc.put(acc2.id,acc2);
            AP_Opportunity.syncPayer_Fields_Siret(optySiretTest, mAcc);
            AP_Opportunity.syncBilled_Fields_Siret(optySiretTest, mAcc);
            System.assertEquals(optySiretTest.Payer_Siret__c, acc2.Code_SIRET__c);
            System.assertEquals(optySiretTest.Billed_SIRET__c, acc2.Code_SIRET__c);
            
            List<Opportunity> lOppty = new List<Opportunity>();
            lOppty.add(optySiretTest);
            aBool = AP_Opportunity.validateOpportunity(lOppty);
            AP_Opportunity.controlRelatedOpportunityPTLs(lOppty);
            
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class class AP_Opportunity_Test.isSiretOuEnCoursDImmatTer END<<<<<');
    }
    
    public static testmethod void isSiretOuEnCoursDImmatSiretInsertIncorrect() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretInsertIncorrect <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT4',Alias='APOT4',
            Email='APOT4@shell.com',Username='APOT4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
            
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;            
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '852',Active__c = true,MatriculeEnCours__c=3 );
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
            
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                Code_SIRET__c = '11111111111111', En_cours_d_immatriculation__c = false, No_E_mail__c   = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
                  
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
           Postal_Code__c = compteIsSiretOuEnCoursDImmat .Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
           Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
           insert c;
            
            Account compteIsSiretOuEnCoursDImmat2 = new Account(name = 'accountIsSiretOuEnCoursDImmat2', RecordType = recordTypeAccount,
                Code_SIRET__c = '11111111111110', En_cours_d_immatriculation__c = false, No_E_mail__c   = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat2;
            
                  
            // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat2.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat2.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat2 .Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat2.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat2.City__c,Email = compteIsSiretOuEnCoursDImmat2.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat2.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat2.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat2.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat2.Country__c,Phone = compteIsSiretOuEnCoursDImmat2.Phone);
            insert c2;
            
            
            Account compteIsSiretOuEnCoursDImmat3 = new Account(name = 'accountIsSiretOuEnCoursDImmat3', RecordType = recordTypeAccount,
                Code_SIRET__c = '1111111111111', En_cours_d_immatriculation__c = false, No_E_mail__c    = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat3;
            
            // New Contact
            Contact c3  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat3.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat3.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat3.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat3.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat3.City__c,Email = compteIsSiretOuEnCoursDImmat3.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat3.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat3.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat3.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat3.Country__c,Phone = compteIsSiretOuEnCoursDImmat3.Phone);
            insert c3;
            
            
            
            Account compteIsSiretOuEnCoursDImmat4 = new Account(name = 'accountIsSiretOuEnCoursDImmat4', RecordType = recordTypeAccount,
                Code_SIRET__c = '', En_cours_d_immatriculation__c = false, No_E_mail__c = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat4;
            
             // New Contact
            Contact c4  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat4.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat4.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat4.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat4.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat4.City__c,Email = compteIsSiretOuEnCoursDImmat4.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat4.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat4.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat4.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat4.Country__c,Phone = compteIsSiretOuEnCoursDImmat4.Phone);
           insert c4;
            
            //insert new List<Account> { compteIsSiretOuEnCoursDImmat, compteIsSiretOuEnCoursDImmat2, compteIsSiretOuEnCoursDImmat3, compteIsSiretOuEnCoursDImmat4 };
            //insert new List<Contact> { c, c2, c3, c4 };
            
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '11111111111111', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', Project_City_Postal_Code__c=cityCP1.id,
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false,DO_Activity_Domain__c=AD_GEC.Id);
            
            //insert optyIsSiretOuEnCoursDImmat;
            opties.add(optyIsSiretOuEnCoursDImmat);
            
            Opportunity optyIsSiretOuEnCoursDImmat2 = new Opportunity(name = 'isSiretOuEnCoursDImmat2', DO_Code_SIRET__c = '11111111111110', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat2.Id, Assign__c = false, StageName = 'Closed Won', Project_City_Postal_Code__c=cityCP1.id,
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false);
            
            //insert optyIsSiretOuEnCoursDImmat2;
            opties.add(optyIsSiretOuEnCoursDImmat2);
            
            Opportunity optyIsSiretOuEnCoursDImmat3 = new Opportunity(name = 'isSiretOuEnCoursDImmat3', DO_Code_SIRET__c = '1111111111111', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat3.Id, Assign__c = false, StageName = 'Closed Won', Project_City_Postal_Code__c=cityCP1.id,
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false,DO_Activity_Domain__c=AD_GEC.Id);
            
            //insert optyIsSiretOuEnCoursDImmat3;
            opties.add(optyIsSiretOuEnCoursDImmat3);
            
            Opportunity optyIsSiretOuEnCoursDImmat4 = new Opportunity(name = 'isSiretOuEnCoursDImmat4', DO_Code_SIRET__c = '', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat4.Id, Assign__c = false, StageName = 'Closed Won', Project_City_Postal_Code__c=cityCP1.id,
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false,DO_Activity_Domain__c=AD_GEC.Id);
            
            //insert optyIsSiretOuEnCoursDImmat4;
            opties.add(optyIsSiretOuEnCoursDImmat4);
            
            //insert new List<Opportunity> { optyIsSiretOuEnCoursDImmat, optyIsSiretOuEnCoursDImmat2, optyIsSiretOuEnCoursDImmat3, optyIsSiretOuEnCoursDImmat4 };
            insert opties;
            
            
            /*Opportunity optyIsSiretOuEnCoursDImmatSoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,
                                                        Account_Billed__c, Account_Payer__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];*/
            
            List<Opportunity> optiesSOQL = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                            Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,
                                            Account_Billed__c, Account_Payer__c
                                            FROM Opportunity WHERE Id = :opties];
                                            
             Mandataire__c MdtSOQL = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];
            
            
            // Start test
            test.starttest();
            
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatInsert(optiesSOQL, isTest), true);
            
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretInsertIncorrect END<<<<<');
        
        
    }
    
    public static testmethod void isSiretOuEnCoursDImmatSiretUpdIncorrect() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretUpdIncorrect <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT5',Alias='APOT5',
            Email='APOT5@shell.com',Username='APOT5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
        
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;        
            
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '957',Active__c = true,MatriculeEnCours__c=3 );
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
        
        
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
                
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount, No_E_mail__c = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
            Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
            Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
            insert c;
            
        
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '11111111111111', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', Project_City_Postal_Code__c=cityCP1.id,
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false,DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];
                                                        
           Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                             
                                
            opties.add(optyIsSiretOuEnCoursDImmatSoql);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretUpdIncorrect END<<<<<');
        
        
    }
    
    public static testmethod void isSiretOuEnCoursDImmatSiretInsertIncorrectBis() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretInsertIncorrectBis <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT6',Alias='APOT6',
            Email='APOT6@shell.com',Username='APOT6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
        
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');

             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;

            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '990',Active__c = true,MatriculeEnCours__c=3 );
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
            
                
            // Account
            Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                Code_SIRET__c = '11111111111111', En_cours_d_immatriculation__c = false, No_E_mail__c   = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat;
            
                  
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
           Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
           Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
           insert c;
            
        
            // Account
            Account compteIsSiretOuEnCoursDImmat2 = new Account(name = 'accountIsSiretOuEnCoursDImmat2',
            Code_SIRET__c = '11111111111111', En_cours_d_immatriculation__c = false, No_E_mail__c   = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat2;
            
            
                  
           // New Contact
           Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = compteIsSiretOuEnCoursDImmat2.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat2.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat2.Postal_Box__c,
           Postal_Code__c = compteIsSiretOuEnCoursDImmat2.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat2.City__c,Email = compteIsSiretOuEnCoursDImmat2.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat2.Email_2__c,
           Fax = compteIsSiretOuEnCoursDImmat2.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat2.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat2.Country__c,Phone = compteIsSiretOuEnCoursDImmat2.Phone);
           insert c2;
            
        
            // Account
            Account compteIsSiretOuEnCoursDImmat3 = new Account(name = 'accountIsSiretOuEnCoursDImmat3',
           Code_SIRET__c = '11111111111111', En_cours_d_immatriculation__c = false, No_E_mail__c   = true,Country__c='FR', Phone='0202020202');
            insert compteIsSiretOuEnCoursDImmat3;
            
                  
           // New Contact
           Contact c3  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = compteIsSiretOuEnCoursDImmat3.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat3.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat3.Postal_Box__c,
           Postal_Code__c = compteIsSiretOuEnCoursDImmat3.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat3.City__c,Email = compteIsSiretOuEnCoursDImmat3.Email__c,Email_2__c = compteIsSiretOuEnCoursDImmat3.Email_2__c,
           Fax = compteIsSiretOuEnCoursDImmat3.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat3.Place_Called__c,Country__c = compteIsSiretOuEnCoursDImmat3.Country__c,Phone = compteIsSiretOuEnCoursDImmat3.Phone);
           insert c3;
        
            // Opportunity
            Opportunity optyIsSiretOuEnCoursDImmat = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', 
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false, Account_Billed__c = compteIsSiretOuEnCoursDImmat2.Id,Project_City_Postal_Code__c=cityCP1.id,
                Account_Payer__c = compteIsSiretOuEnCoursDImmat3.Id,DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsSiretOuEnCoursDImmat;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,
                                                        Account_Billed__c, Account_Payer__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat.Id];
                                                        
            Opportunity optyIsSiretOuEnCoursDImmat2 = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '11111111111110', 
                Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat.Id, Assign__c = false, StageName = 'Closed Won', 
                CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = false, Account_Billed__c = compteIsSiretOuEnCoursDImmat2.Id,Project_City_Postal_Code__c=cityCP1.id,
                Account_Payer__c = compteIsSiretOuEnCoursDImmat3.Id);
        
            insert optyIsSiretOuEnCoursDImmat2;
        
            Opportunity optyIsSiretOuEnCoursDImmatSoql2 = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, 
                                                        Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,
                                                        Account_Billed__c, Account_Payer__c
                                                        FROM Opportunity WHERE Id = :optyIsSiretOuEnCoursDImmat2.Id];
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql2 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                              
                                
            opties.add(optyIsSiretOuEnCoursDImmatSoql);
            opties.add(optyIsSiretOuEnCoursDImmatSoql2);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.siretOuEnCoursDImmatInsert(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isSiretOuEnCoursDImmatSiretInsertIncorrectBis END<<<<<');
        
        
    }
    
    public static testmethod void isEmailPasDEmailInsert() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailInsert <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT7',Alias='APOT7',
            Email='APOT7@shell.com',Username='APOT7@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
            
            //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '994',Active__c = true,MatriculeEnCours__c=3 );
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
            
            // Account
            Account compteIsEmailPasDEmailDO = new Account(name = 'accountIsEmailPasDEmailDO', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailDO;
            
                  
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = compteIsEmailPasDEmailDO.Id,Street_Number__c = compteIsEmailPasDEmailDO.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailDO.Postal_Box__c,
           Postal_Code__c = compteIsEmailPasDEmailDO.Postal_Code__c,City__c = compteIsEmailPasDEmailDO.City__c,Email = compteIsEmailPasDEmailDO.Email__c,Email_2__c = compteIsEmailPasDEmailDO.Email_2__c,
           Fax = compteIsEmailPasDEmailDO.Fax,Place_Called__c = compteIsEmailPasDEmailDO.Place_Called__c,Country__c = compteIsEmailPasDEmailDO.Country__c,Phone = compteIsEmailPasDEmailDO.Phone);
           insert c;
        
            // Opportunity
            Opportunity optyIsEmailPasDEmail = new Opportunity(
                name            = 'isEmailPasDEmailDO',
                Assign__c       = false, 
                StageName       = 'Closed Won', 
                CloseDate       = Date.parse('01/02/2014'),
                AccountId       = compteIsEmailPasDEmailDO.Id,
                Project_City_Postal_Code__c=cityCP1.id);
        
            insert optyIsEmailPasDEmail;
        
            Opportunity optyIsEmailPasDEmailSoql = [    SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            Account_Billed__c, 
                                                            Account_Payer__c,
                                                            RecordType.Name,
                                                            StageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail.Id];
                                                        
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                              
                                                        
            opties.add(optyIsEmailPasDEmailSoql);
        
            // Account
            Account compteIsEmailPasDEmailDO2 = new Account(name = 'accountIsEmailPasDEmailDO2', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailDO2;
            
             // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsEmailPasDEmailDO2.Id,Street_Number__c = compteIsEmailPasDEmailDO2.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailDO2.Postal_Box__c,
            Postal_Code__c = compteIsEmailPasDEmailDO2.Postal_Code__c,City__c = compteIsEmailPasDEmailDO2.City__c,Email = compteIsEmailPasDEmailDO2.Email__c,Email_2__c = compteIsEmailPasDEmailDO2.Email_2__c,
            Fax = compteIsEmailPasDEmailDO2.Fax,Place_Called__c = compteIsEmailPasDEmailDO2.Place_Called__c,Country__c = compteIsEmailPasDEmailDO2.Country__c,Phone = compteIsEmailPasDEmailDO2.Phone);
            insert c2;
        
            // Opportunity
            Opportunity optyIsEmailPasDEmail2 = new Opportunity(
                name            = 'isEmailPasDEmailDO2',
                Assign__c       = false, 
                StageName       = 'Closed Won', 
                CloseDate       = Date.parse('01/02/2014'),
                AccountId       = compteIsEmailPasDEmailDO2.Id,
                Project_City_Postal_Code__c=cityCP1.id);
        
            insert optyIsEmailPasDEmail2;
        
            Opportunity optyIsEmailPasDEmailSoql2 = [   SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            Account_Billed__c, 
                                                            Account_Payer__c,
                                                            RecordType.Name,
                                                            StageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail2.Id];
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql2 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                              
                                                        
            opties.add(optyIsEmailPasDEmailSoql2);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.emailPasDEmailInsert(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailInsert END<<<<<');
        
        
    }
    
    public static testmethod void isEmailPasDEmailDO() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailDO <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT8',Alias='APOT8',
            Email='APOT8@shell.com',Username='APOT8@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;           
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '749',Active__c = true,MatriculeEnCours__c=3 );
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
        
            // Account
            Account compteIsEmailPasDEmailDO = new Account(name = 'accountIsEmailPasDEmailDO', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailDO;
        
        
                  
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsEmailPasDEmailDO.Id,Street_Number__c = compteIsEmailPasDEmailDO.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailDO.Postal_Box__c,
            Postal_Code__c = compteIsEmailPasDEmailDO.Postal_Code__c,City__c = compteIsEmailPasDEmailDO.City__c,Email = compteIsEmailPasDEmailDO.Email__c,Email_2__c = compteIsEmailPasDEmailDO.Email_2__c,
            Fax = compteIsEmailPasDEmailDO.Fax,Place_Called__c = compteIsEmailPasDEmailDO.Place_Called__c,Country__c = compteIsEmailPasDEmailDO.Country__c,Phone = compteIsEmailPasDEmailDO.Phone);
            insert c;
        
            // Opportunity
            Opportunity optyIsEmailPasDEmail = new Opportunity(
                name            = 'isEmailPasDEmailDO',
                Assign__c       = false, 
                StageName       = 'Closed Won', 
                CloseDate       = Date.parse('01/02/2014'),
                DO_No_E_mail__c = true,
                DO_Email__c     = null,
                DO_Email_2__c   = null,
                FA_DO__c        = true,
                PA_DO__c        = true,
                AccountId       = compteIsEmailPasDEmailDO.Id,
                Project_City_Postal_Code__c=cityCP1.id,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsEmailPasDEmail;
        
            Opportunity optyIsEmailPasDEmailSoql = [    SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            RecordType.Name
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail.Id];
                                                        
                                                        
           Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                               
                                                        
            opties.add(optyIsEmailPasDEmailSoql);
        
            // Account
            Account compteIsEmailPasDEmailDO2 = new Account(name = 'accountIsEmailPasDEmailDO2', No_E_mail__c   = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailDO2;
            
            
            // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsEmailPasDEmailDO2.Id,Street_Number__c = compteIsEmailPasDEmailDO2.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailDO2.Postal_Box__c,
            Postal_Code__c = compteIsEmailPasDEmailDO2.Postal_Code__c,City__c = compteIsEmailPasDEmailDO2.City__c,Email = compteIsEmailPasDEmailDO2.Email__c,Email_2__c = compteIsEmailPasDEmailDO2.Email_2__c,
            Fax = compteIsEmailPasDEmailDO2.Fax,Place_Called__c = compteIsEmailPasDEmailDO2.Place_Called__c,Country__c = compteIsEmailPasDEmailDO2.Country__c,Phone = compteIsEmailPasDEmailDO2.Phone);
            insert c2;
            
            // Opportunity
            Opportunity optyIsEmailPasDEmail2 = new Opportunity(
                name            = 'isEmailPasDEmailDO2',
                Assign__c       = false, 
                StageName       = 'Closed Won', 
                CloseDate       = Date.parse('01/02/2014'),
                DO_No_E_mail__c = true,
                DO_Email__c     = null,
                DO_Email_2__c   = null,
                FA_DO__c        = true,
                PA_DO__c        = true,
                AccountId       = compteIsEmailPasDEmailDO2.Id,
                Project_City_Postal_Code__c=cityCP1.id,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsEmailPasDEmail2;
        
            Opportunity optyIsEmailPasDEmailSoql2 = [   SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            RecordType.Name,
                                                            StageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail2.Id];
                                                        
                                                        
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql2 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                              
                                                        
            opties.add(optyIsEmailPasDEmailSoql2);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.emailPasDEmailUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailDO END<<<<<');
        
        
    }
    
    public static testmethod void isEmailPasDEmailPayer() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailPayer <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT9',Alias='APOT9',
            Email='APOT9@shell.com',Username='APOT9@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            List<Opportunity> opties = new List<Opportunity>();
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;            
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '297',Active__c = true,MatriculeEnCours__c=3 );
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
        
        
        
            // Account
            Account compteIsEmailPasDEmailPayer = new Account(name = 'accountIsEmailPasDEmailPayer', No_E_mail__c   = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailPayer;
            
            
                  
          // New Contact
          Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = compteIsEmailPasDEmailPayer.Id,Street_Number__c = compteIsEmailPasDEmailPayer.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailPayer.Postal_Box__c,
          Postal_Code__c = compteIsEmailPasDEmailPayer.Postal_Code__c,City__c = compteIsEmailPasDEmailPayer.City__c,Email = compteIsEmailPasDEmailPayer.Email__c,Email_2__c = compteIsEmailPasDEmailPayer.Email_2__c,
          Fax = compteIsEmailPasDEmailPayer.Fax,Place_Called__c = compteIsEmailPasDEmailPayer.Place_Called__c,Country__c = compteIsEmailPasDEmailPayer.Country__c,Phone = compteIsEmailPasDEmailPayer.Phone);
          insert c;
            
        
            // Opportunity
            Opportunity optyIsEmailPasDEmail = new Opportunity(
                name                = 'isEmailPasDEmailPayer',
                Assign__c           = false, 
                StageName           = 'Closed Won', 
                CloseDate           = Date.parse('01/02/2014'),
                Payer_No_E_mail__c  = true,
                Payer_Email__c      = null,
                Payer_Email_2__c    = null,
                FA_DO__c            = true,
                PA_DO__c            = false,
                AccountId           = compteIsEmailPasDEmailPayer.Id,
                Project_City_Postal_Code__c=cityCP1.id,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsEmailPasDEmail;
        
            Opportunity optyIsEmailPasDEmailSoql = [    SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            RecordType.Name,
                                                            StageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail.Id];
                                                        
                                                        
            Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                              
                                                        
            opties.add(optyIsEmailPasDEmailSoql);
        
            // Account
            Account compteIsEmailPasDEmailPayer2 = new Account(name = 'accountIsEmailPasDEmailPayer2', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailPayer2;
            
            // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = compteIsEmailPasDEmailPayer2.Id,Street_Number__c = compteIsEmailPasDEmailPayer2.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailPayer2.Postal_Box__c,
            Postal_Code__c = compteIsEmailPasDEmailPayer2.Postal_Code__c,City__c = compteIsEmailPasDEmailPayer2.City__c,Email = compteIsEmailPasDEmailPayer2.Email__c,Email_2__c = compteIsEmailPasDEmailPayer2.Email_2__c,
            Fax = compteIsEmailPasDEmailPayer2.Fax,Place_Called__c = compteIsEmailPasDEmailPayer2.Place_Called__c,Country__c = compteIsEmailPasDEmailPayer2.Country__c,Phone = compteIsEmailPasDEmailPayer2.Phone);
            insert c2;           
            
            
            //Opportunity
            Opportunity optyIsEmailPasDEmail2 = new Opportunity(
                name                = 'isEmailPasDEmailPayer2',
                Assign__c           = false, 
                StageName           = 'Closed Won', 
                CloseDate           = Date.parse('01/02/2014'),
                Payer_No_E_mail__c  = true,
                Payer_Email__c      = null,
                Payer_Email_2__c    = null,
                FA_DO__c            = true,
                PA_DO__c            = false,
                AccountId           = compteIsEmailPasDEmailPayer2.Id,
                Project_City_Postal_Code__c=cityCP1.id,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsEmailPasDEmail2;
        
            Opportunity optyIsEmailPasDEmailSoql2 = [   SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            RecordType.Name,
                                                            StageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail2.Id];
                                                        
                                                        
                                                        
             Mandataire__c MdtIsSiretOuEnCoursDImmatSoql2 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                             
                                                        
            opties.add(optyIsEmailPasDEmailSoql2);
                                
            // Start test
            test.starttest();
        
        System.assertEquals(AP_Opportunity.emailPasDEmailUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailPayer END<<<<<');
        
        
    }
    
    public static testmethod void isEmailPasDEmailBilled() {
        
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailBilled <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT10',Alias='APOT10',
            Email='APOT10@shell.com',Username='APOT10@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            List<Opportunity> opties = new List<Opportunity>();
            
             //Activity Domain
             Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
             insert AD_GEC;            
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '597',Active__c = true,MatriculeEnCours__c=3 );
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
            
        
            // Account
            Account compteIsEmailPasDEmailBilled = new Account(name = 'accountIsEmailPasDEmailBilled', No_E_mail__c = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteIsEmailPasDEmailBilled;
            
            
                  
          // New Contact
          Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = compteIsEmailPasDEmailBilled.Id,Street_Number__c = compteIsEmailPasDEmailBilled.Street_Number__c,Postal_Box__c = compteIsEmailPasDEmailBilled.Postal_Box__c,
          Postal_Code__c = compteIsEmailPasDEmailBilled.Postal_Code__c,City__c = compteIsEmailPasDEmailBilled.City__c,Email = compteIsEmailPasDEmailBilled.Email__c,Email_2__c = compteIsEmailPasDEmailBilled.Email_2__c,
          Fax = compteIsEmailPasDEmailBilled.Fax,Place_Called__c = compteIsEmailPasDEmailBilled.Place_Called__c,Country__c = compteIsEmailPasDEmailBilled.Country__c,Phone = compteIsEmailPasDEmailBilled.Phone);
          insert c;
            
        
            // Opportunity
            Opportunity optyIsEmailPasDEmail = new Opportunity(
                name                = 'isEmailPasDEmailBilled',
                Assign__c           = false, 
                StageName           = 'Closed Won', 
                CloseDate           = Date.parse('01/02/2014'),
                Billed_No_E_mail__c = false,
                Billed_Email__c     = null,
                Billed_Email_2__c   = null,
                DO_No_E_mail__c     = true,
                DO_Email__c         = null,
                DO_Email_2__c       = null,
                FA_DO__c            = false,
                PA_DO__c            = true,
                AccountId           = compteIsEmailPasDEmailBilled.Id,
                Project_City_Postal_Code__c=cityCP1.id,
                DO_Activity_Domain__c=AD_GEC.Id);
        
            insert optyIsEmailPasDEmail;
        
            Opportunity optyIsEmailPasDEmailSoql = [    SELECT  DO_No_E_mail__c,
                                                            DO_Email__c,
                                                            DO_Email_2__c,
                                                            Payer_No_E_mail__c,
                                                            Payer_Email__c,
                                                            Payer_Email_2__c,
                                                            Billed_No_E_mail__c,
                                                            Billed_Email__c,
                                                            Billed_Email_2__c,
                                                            FA_DO__c,
                                                            PA_DO__c,
                                                            AccountId,
                                                            RecordType.Name,
                                                            stageName
                                                        FROM Opportunity WHERE Id = :optyIsEmailPasDEmail.Id];
                                                        
                                                        
           Mandataire__c MdtIsSiretOuEnCoursDImmatSoql = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                                    FROM Mandataire__c                                   
                                                                    WHERE id= :mandataire1.id LIMIT 1];                                               
                                                        
            opties.add(optyIsEmailPasDEmailSoql);
                                
            // Start test
            test.starttest();
        
            System.assertEquals(AP_Opportunity.emailPasDEmailUpdate(opties, isTest), true);
        
            // Stop test        
            test.stoptest();
        }
        System.Debug('### >>>>> testing class AP_Opportunity_Test.isEmailPasDEmailBilled END<<<<<');
    }
    
    
    
    
    public static testmethod void updateReferenceClientSAP() {
        
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
     
     
                    List<Opportunity> opties = new List<Opportunity>();
     
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
                    

                        //Account
                        Account NewAccRefSAP1 = new Account(name='NewAccMKT', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                        CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'DOM',
                        Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                        Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202');
                        insert NewAccRefSAP1;
                        
                        
                     
                         // New Contact
                        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                        accountId = NewAccRefSAP1.Id,Street_Number__c = NewAccRefSAP1.Street_Number__c,Postal_Box__c = NewAccRefSAP1.Postal_Box__c,
                        Postal_Code__c = NewAccRefSAP1.Postal_Code__c,City__c = NewAccRefSAP1.City__c,Email = NewAccRefSAP1.Email__c,Email_2__c = NewAccRefSAP1.Email_2__c,
                        Fax = NewAccRefSAP1.Fax,Place_Called__c = NewAccRefSAP1.Place_Called__c,Country__c = NewAccRefSAP1.Country__c,Phone = NewAccRefSAP1.Phone);
                        insert c;         
                        
            
                        // Opportunity
                        Opportunity optyNewRefClientSAP1 = new Opportunity(name = 'NewRefClientSAP', AccountId = NewAccRefSAP1.Id,
                        Project_Type__c = 'CREA',Project_market_type__c='DOM',Direct_Client__c = false,Assign__c=false,
                        Project_City_Postal_Code__c=cityCP1.id,
                        StageName = 'Closed Won', CloseDate = Date.parse('01/02/2014'));
                        insert optyNewRefClientSAP1 ;
                        
                     
                        
                                        
                        Opportunity optyNewRefSAPSoql = [ SELECT  
                                                         RecordType.Name,
                                                         stageName,ReferenceClientSAP__c,Mandataire_du_projet_NOM__c,T_MandataireId__c
                                                         FROM Opportunity WHERE Id = :optyNewRefClientSAP1.Id   ];
                                                            
                                                        
                        
                      
                      
                        Mandataire__c MandataireRefSAP = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                            FROM Mandataire__c 
                                                           // WHERE id= :optyNewRefSAPSoql.T_MandataireId__c LIMIT 1];
                                                           WHERE id= :MandataireCanton1.id LIMIT 1];
                                        
                                        
                        
                                                            
                        opties.add(optyNewRefSAPSoql);              
                                        
                      
    
                        AP_Opportunity.updateReferenceClientSAP(opties);
                                              
                            
                       //test 2
                    
                        // Update Mandataire.
                        Mandataire__c mandataireToUpdate5 =   [ SELECT id, MatriculeEnCours__c,ExternalID__c FROM Mandataire__c 
                                                           // WHERE id=:optyNewRefSAPSoql.T_MandataireId__c LIMIT 1];
                                                             WHERE id= :MandataireCanton1.id ];
                       mandataireToUpdate5.MatriculeEnCours__c = 333333;
                       update mandataireToUpdate5;

                                        
                       //Account
                       Account NewAccRefSAP6 = new Account(name='NewAccMKT', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                       CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'DOM',
                       Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                       Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202');
                       insert NewAccRefSAP6;
                       
                       
                        // New Contact
                        Contact c6  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                        accountId = NewAccRefSAP6.Id,Street_Number__c = NewAccRefSAP6.Street_Number__c,Postal_Box__c = NewAccRefSAP6.Postal_Box__c,
                        Postal_Code__c = NewAccRefSAP6.Postal_Code__c,City__c = NewAccRefSAP6.City__c,Email = NewAccRefSAP6.Email__c,Email_2__c = NewAccRefSAP6.Email_2__c,
                        Fax = NewAccRefSAP6.Fax,Place_Called__c = NewAccRefSAP6.Place_Called__c,Country__c = NewAccRefSAP6.Country__c,Phone = NewAccRefSAP6.Phone);
                        insert c6;
                            
                       // Opportunity
                       Opportunity optyNewRefClientSAP6 = new Opportunity(name = 'NewRefClientSAP', AccountId = NewAccRefSAP6.Id,
                       Project_Type__c = 'CREA',Project_market_type__c='DOM',Direct_Client__c = false,Assign__c=false,
                       Project_City_Postal_Code__c=cityCP1.id,
                       StageName = 'Closed Won', CloseDate = Date.parse('01/02/2014'));
                       insert optyNewRefClientSAP6 ;
                                        
                      Opportunity optyNewRefSAPSoql6 = [ SELECT  
                                                          RecordType.Name,
                                                          stageName,ReferenceClientSAP__c,Mandataire_du_projet_NOM__c
                                                          FROM Opportunity WHERE Id = :optyNewRefClientSAP6.Id   ];
                                                                            
                                                                        
                     Mandataire__c MandataireRefSAP6 = [  SELECT id, MatriculeEnCours__c,ExternalID__c
                                                          FROM Mandataire__c 
                                                          //WHERE Name = :optyNewRefSAPSoql6.id LIMIT 1];
                                                         WHERE id= :MandataireCanton1.id LIMIT 1];
                                                        
                                        
                                                                            
                     opties.add(optyNewRefSAPSoql6);
                    
                    
                                        
                    test.stopTest();
                
                
           


                  

                    System.Debug('### >>>>> testing class AP_Opportunity_Test.updateReferenceClientSAP END<<<<<');}
     
     }
     
     
     
    
}