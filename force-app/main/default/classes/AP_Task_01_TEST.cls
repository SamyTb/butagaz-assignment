@isTest
private class AP_Task_01_TEST {

    public static testmethod void testDefaultValues(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT1',Alias='APTT1',
            Email='APTT1@shell.com',Username='APTT1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
             
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
           

             Canton__c Some_Canton = new Canton__c(name = 'SomeCanton4', INSEE_Code__c = '0000' , Mandataire__c =  mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};


            City__c Some_City  = new City__c(Name = 'SomeCity1',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity1', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert c;
            
            Opportunity opty1 =  new Opportunity(
                CloseDate=Date.today(), Name='SomeName', StageName='Prospecting', Assign__c = false,
                AccountId = oAcct.Id, Project_City_Postal_Code__c = Some_Code.Id
            );
            insert opty1;
            
            
            Test.startTest();
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            opty1 = [SELECT Id, Related_Tasks_Count__c FROM Opportunity WHERE Id = :opty1.Id];
            
            System.assertEquals(0, lead1.Related_Tasks_Count__c);
            System.assertEquals(0, opty1.Related_Tasks_Count__c);
            Test.stopTest();
        }
    }

    public static testmethod void testCreateTasks(){
        // Create that the counter gets properly updated on a Lead when it's created.
        // TODO: task related to two objs.
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT2',Alias='APTT2',
            Email='APTT2@shell.com',Username='APTT2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
            //Mandataire
         Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
         insert mandataire1;
            
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton2', INSEE_Code__c = '0000', Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};
            
            
         

            City__c Some_City  = new City__c(Name = 'SomeCity2',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity2', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            Lead lead2 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead2;
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert c;
            
            Opportunity opty1 =  new Opportunity(
                CloseDate=Date.today(), Name='SomeName', StageName='Prospecting', Assign__c = false,
                AccountId = oAcct.Id, Project_City_Postal_Code__c = Some_Code.Id
            );
            insert opty1;
            
            
            Test.startTest();
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', Type = 'Call', WhoId = lead1.Id);
            Task oTask2 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead2.Id);
            Task oTask3 = new Task(Priority = 'High', Status = 'Not Started', WhatId = opty1.Id);
            
            insert new List<Task>{oTask1, oTask2, oTask3};
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            lead2 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead2.Id];
            opty1 = [SELECT Id, Related_Tasks_Count__c FROM Opportunity WHERE Id = :opty1.Id];
            System.assertEquals(1, lead1.Related_Tasks_Count__c);
            System.assertEquals(1, lead2.Related_Tasks_Count__c);
            System.assertEquals(1, opty1.Related_Tasks_Count__c);
            Test.stopTest();
        }
    }

    public static testmethod void testUpdateTasks(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT3',Alias='APTT3',
            Email='APTT3@shell.com',Username='APTT3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton2', INSEE_Code__c = '0000',Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};

           

            City__c Some_City  = new City__c(Name = 'SomeCity3',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity3', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            Lead lead2 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName2@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead2;
            
            Lead lead3 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName3@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead3;
            
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead1.Id);
            Task oTask2 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead3.Id);
            insert new List<Task> {oTask1, oTask2};
            
            
            Test.startTest();
            // Insert task and link to lead1
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            lead3 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead3.Id];
            System.assertEquals(1, lead1.Related_Tasks_Count__c);
            System.assertEquals(1, lead3.Related_Tasks_Count__c);

            // Link to another task
            oTask1.WhoId = lead2.Id;
            oTask2.Priority = 'Low';
            update new List<Task> {oTask1, oTask2};
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            lead2 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead2.Id];
            lead3 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead3.Id];
            System.assertEquals(0, lead1.Related_Tasks_Count__c);
            System.assertEquals(1, lead2.Related_Tasks_Count__c);
            System.assertEquals(1, lead3.Related_Tasks_Count__c);

            Test.stopTest();
        }
            
    }

    public static testmethod void testDeleteTasks(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT4',Alias='APTT4',
            Email='APTT4@shell.com',Username='APTT4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
             
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
             //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
             
           
             Canton__c Some_Canton = new Canton__c(name = 'SomeCanton4', INSEE_Code__c = '0000' , Mandataire__c =  mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};

            City__c Some_City  = new City__c(Name = 'SomeCity4',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity4', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead1.Id);
            insert oTask1;

            Test.startTest();
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(1, lead1.Related_Tasks_Count__c);
            delete oTask1;
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(0, lead1.Related_Tasks_Count__c);
            Test.stopTest();
        }
    }

    public static testmethod void testUndeleteTask(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT5',Alias='APTT5',
            Email='APTT5@shell.com',Username='APTT5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
              //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
             
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton5', INSEE_Code__c = '0000',Mandataire__c =  mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};
            

            City__c Some_City  = new City__c(Name = 'SomeCity5',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity5', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead1.Id);

            Test.startTest();
            insert oTask1;
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(1, lead1.Related_Tasks_Count__c);

            delete oTask1;
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(0, lead1.Related_Tasks_Count__c);

            undelete oTask1;
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(1, lead1.Related_Tasks_Count__c);

            Test.stopTest();
        }
    }

    public static testmethod void testDoubleCreateTask(){
        // Check that you can have a multiple insert on a single object.
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT6',Alias='APTT6',
            Email='APTT6@shell.com',Username='APTT6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
              //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
            
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton6', INSEE_Code__c = '0000' , Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};


            City__c Some_City  = new City__c(Name = 'SomeCity6',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity6', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;

            Test.startTest();
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead1.Id);
            Task oTask2 = new Task(Priority = 'High', Status = 'Not Started', WhoId = lead1.Id);
            insert new List<Task>{oTask1, oTask2};
            lead1 = [SELECT Id, Related_Tasks_Count__c FROM Lead WHERE Id = :lead1.Id];
            System.assertEquals(2, lead1.Related_Tasks_Count__c);
            Test.stopTest();
        }
        
    }

    public static testmethod void testUnrelatedObject(){
        // Check that the trigger doesn't block for unrelated objects (Contact)
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT7',Alias='APTT7',
            Email='APTT7@shell.com',Username='APTT6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
             //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
            
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton7', INSEE_Code__c = '0000'  , Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};
            
            

            City__c Some_City  = new City__c(Name = 'SomeCity7',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity7', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
           // Contact contact1 = new Contact(FirstName = 'SomeFirstName7', LastName = 'SomeLastName7', accountid = oAcct.id);
           // insert contact1;
           
            // New Contact
            Contact contact1  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert contact1;
        
            Test.startTest();
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = contact1.Id);
            insert oTask1;
            Test.stopTest();
        }
    }

    public static testmethod void testTwoContactsOneOpty(){
        // Test that when the same record is on two WhoId / WhatId groups, we still get the right result
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT8',Alias='APTT8',
            Email='APTT8@shell.com',Username='APTT8@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
            
             //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
             
            
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton8', INSEE_Code__c = '0000',Mandataire__c =  mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};

            City__c Some_City  = new City__c(Name = 'SomeCity8',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity7', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
          //  Contact contact1 = new Contact(FirstName = 'SomeFirstName8', LastName = 'SomeLastName8', accountid = oAcct.id);
          //  insert contact1;
          
           // New Contact
            Contact contact1   = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert contact1 ;
            
            Contact contact2 = new Contact(FirstName = 'OtherLastName8', LastName = 'OtherLastName8', accountid = oAcct.id);
            insert contact2;
            
            Opportunity opty1 =  new Opportunity(
                CloseDate=Date.today(), Name='SomeName', StageName='Prospecting', Assign__c = false,
                AccountId = oAcct.Id, Project_City_Postal_Code__c = Some_Code.Id
            );
            insert opty1;
        
            Test.startTest();
            
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhoId = contact1.Id, WhatId = opty1.Id);
            Task oTask2 = new Task(Priority = 'High', Status = 'Not Started', WhoId = contact2.Id, WhatId = opty1.Id);
            insert new List<Task>{oTask1, oTask2};

            Opportunity oOpty1 = [SELECT Id, Related_Tasks_Count__c FROM Opportunity WHERE Id = :opty1.Id];
            System.assertEquals(2, oOpty1.Related_Tasks_Count__c);

            Test.stopTest();
        }
    }

    public static testmethod void testDualObjects(){
        // Check that you wan WhoId & WhatId
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT9',Alias='APTT9',
            Email='APTT9@shell.com',Username='APTT9@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
         
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton8', INSEE_Code__c = '0000'  , Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};

            City__c Some_City  = new City__c(Name = 'SomeCity8',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity7', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;

            String MT_PRO = 'PRO';
            
            Lead lead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', Project_Street_Name__c='Somestreet',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = MT_PRO, Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id, email='SomeName1@SomeCompany.fr',Account_Country__c='FR', Phone='0202020202'
            );
            insert lead1;
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
           // Contact contact1 = new Contact(FirstName = 'SomeFirstName9', LastName = 'SomeLastName9', accountId = oAcct.id);
           // insert contact1;
           
              // New Contact
            Contact contact1   = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert contact1 ;
            
            Opportunity opty1 =  new Opportunity(
                CloseDate=Date.today(), Name='SomeName', StageName='Prospecting', Assign__c = false,
                AccountId = oAcct.Id, Project_City_Postal_Code__c = Some_Code.Id
            );
            insert opty1;
        
            Test.startTest();
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', WhatId = opty1.Id, WhoId = contact1.Id);
            insert oTask1;
            opty1 = [SELECT Id, Related_Tasks_Count__c FROM Opportunity WHERE Id = :opty1.Id];
            Test.stopTest();
        }
    }
    
    
    
    public static testmethod void testUpdateActivityHistoryOnCase(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APTT3',Alias='APTT3',
            Email='APTT3@shell.com',Username='APTT3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            
            //Mandataire
         Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
         insert mandataire1;
         
         
        
            
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton2', INSEE_Code__c = '0000', Mandataire__c = mandataire1.id);
            insert new List<SObject>{AD_GEC, Some_Canton};

            City__c Some_City  = new City__c(Name = 'SomeCity3',  Canton__c = Some_Canton.Id, INSEE_Code__c = '00000');
            insert Some_City;

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '00000 - SomeCity3', City__c = Some_City.Id, HEXAPOSTE_Code__c = '0000', Code_Type__c = 'M');
            insert Some_Code;
            
            // Parent category
            Request_Category__c RC1 = new Request_Category__c(
                Name = '01 | CatRequest', Name__c = 'CatRequest', Code__c = '01'
            );
            insert RC1;
            
            // Child category
            Request_Category__c RC2 = new Request_Category__c(
                Name = '02 | CatRequest2', Name__c = 'CatRequest2', Code__c = '02', Parent_Category__c = RC1.Id
            );
            insert RC2;
            
            String MT_PRO = 'PRO';
            
            Account oAcct = new Account(Name='SomeAcct', Market_Type__c = MT_PRO, Postal_Code__c = '00000', City__c = 'SomeCity',Email__c = 'APTaskTest1@test.org',Country__c='FR', Phone='0202020202');
            insert oAcct;
            
           // Contact contact1 = new Contact(FirstName = 'SomeFirstName8', LastName = 'SomeLastName8', accountid = oAcct.id);
           // insert contact1;
            
              // New Contact
            Contact contact1   = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
            Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
            Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert contact1 ;
            
            Mandataire__c mand1 = new Mandataire__c(name = 'APCTR Mandataire', ExternalID__c = 'APCEI', Active__c = true);
            insert mand1;
            
            Case case1 = new Case(
                Category__c = RC2.Id, AccountId = oAcct.Id, Subject = 'mySubject', Description = 'myDesc', Mandataire__c = mand1.Id
            );
            insert case1;
            
            
            Test.startTest();
            
            Task oTask1 = new Task(Priority = 'High', Status = 'Not Started', Subject = 'mySubject', Type = 'Email', WhatId = case1.Id);
            insert oTask1;
            System.debug(logginglevel.WARN,'### ELC: oTask1.Id test = ' + oTask1.Id);
            System.debug(logginglevel.WARN,'### ELC: oTask1.WhatId test = ' + oTask1.WhatId);
            
            case1 = [SELECT Id, ActivityHistoryMinDate__c FROM Case WHERE Id = :oTask1.WhatId];
            System.debug(logginglevel.WARN,'### ELC: case1.Id test = ' + case1.Id);
            System.debug(logginglevel.WARN,'### ELC: case1.ActivityHistoryMinDate__c test = ' + case1.ActivityHistoryMinDate__c);
            System.Assert(case1.ActivityHistoryMinDate__c != null);
            
            Test.stopTest();
        }
            
    }
    
}