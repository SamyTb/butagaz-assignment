@IsTest 
private class AP_Case_Test
{
    private Mandataire__c mandataire = null;
    private Account account = null;
    private PTL__c ptl = null;
    private Equipement__c equipment = null;
    private Contract contract = null;
    private Order__c order = null;
    private Contact oContact = null;
    
    private Integer activityDomainExternalId = 1;
    
    
    
    public static testmethod void testInsertCase()
    {
        system.debug('##### START testInsertCase #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT01',Alias='APCT01',
            Email='APCT01@shell.com',Username='APCT01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT01', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT01City', Email__c = 'APCT01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APCT01 Contact', AccountId = a.id);
            //insert c;
            
               // New Contact
                    Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
                    Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
                    Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
                    insert c;
            
            
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT01 Mandataire',
                ExternalID__c = 'MAP1',
                Active__c = true
            );
            insert mand1;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.stopTest();
        }
        
        system.debug('##### END testInsertCase #####');
    }
    
    public static testmethod void testUpdateCase()
    {
        system.debug('##### START testUpdateCase #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT02',Alias='APCT02',
            Email='APCT02@shell.com',Username='APCT02@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT02 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT02 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT02', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT02 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT02City', Email__c = 'APCT02City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT02 Contact', AccountId = a.id);
          //  insert c;
          
           // New Contact
                    Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
                    Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
                    Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
                    insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT02 Mandataire',
                ExternalID__c = 'MAP2',
                Active__c = true
            );
            insert mand1;
            
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.startTest();
        
            oCase.Communicated_Due_Date__c = Date.Today();
            update oCase;
        
            Test.stopTest();
        }
        
        system.debug('##### END testUpdateCase #####');
    }
    
    public static testmethod void testDeleteCase()
    {
        system.debug('##### START testDeleteCase #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT03',Alias='APCT03',
            Email='APCT03@shell.com',Username='APCT03@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT03 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT03 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT03', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT03 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT03City', Email__c = 'APCT03City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APCT03 Contact', AccountId = a.id);
            //insert c;
            
            
                
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT03 Mandataire',
                ExternalID__c = 'MAP3',
                Active__c = true
            );
            insert mand1;
            
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.startTest();
        
            delete oCase;
        
            Test.stopTest();
            
        }
        system.debug('##### END testDeleteCase #####');
    }
    
    public static testmethod void testInsertCaseWithParent()
    {
        system.debug('##### START testInsertCaseWithParent #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT04',Alias='APCT04',
            Email='APCT04@shell.com',Username='APCT04@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT04 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT04 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT04', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT04 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT04City', Email__c = 'APCT04@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT04 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT04 Mandataire',
                ExternalID__c = 'MAP4',
                Active__c = true
            );
            insert mand1;
            
            Case parent = new Case();
            parent.Mandataire__c = mand1.id;
            parent.ContactId = c.Id;
            insert parent;
        
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ParentId = parent.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.stopTest();
        
            oCase = [SELECT Id, ParentId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(parent.Id, oCase.ParentId);
            
        }
 
        system.debug('##### END testInsertCaseWithParent #####');
    }
    
    public static testmethod void testChangeParentCase()
    {
        system.debug('##### START testChangeParentCase #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT05',Alias='APCT05',
            Email='APCT05@shell.com',Username='APCT05@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT05 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT05 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT05', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT05 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT05City', Email__c = 'APCT05@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APCT05 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT05 Mandataire',
                ExternalID__c = 'MAP5',
                Active__c = true
            );
            insert mand1;
            
            Case parent1 = new Case();
            parent1.Mandataire__c = mand1.Id;
            parent1.ContactId = c.Id;
            insert parent1;
        
            Case parent2 = new Case();
            parent2.Mandataire__c = mand1.Id;
            parent2.ContactId = c.Id;
            insert parent2;
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ParentId = parent1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.startTest();
        
            oCase.ParentId = parent2.Id;
            update oCase;
        
            Test.stopTest();
        
            oCase = [SELECT Id, ParentId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(parent2.Id, oCase.ParentId);
        }
              
        system.debug('##### END testChangeParentCase #####');
    }
    
    public static testmethod void testRemoveParentCase()
    {
        system.debug('##### START testRemoveParentCase #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT06',Alias='APCT06',
            Email='APCT06@shell.com',Username='APCT06@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT06 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT06 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT06', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT06 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT06City', Email__c = 'APCT06@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APCT06 Contact', AccountId = a.id);
            //insert c;
            
                     
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT06 Mandataire',
                ExternalID__c = 'MAP6',
                Active__c = true
            );
            insert mand1;
            
            Case parent1 = new Case();
            parent1.Mandataire__c = mand1.Id;
            parent1.ContactId = c.Id;
            insert parent1;
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ParentId = parent1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.startTest();
        
            oCase.ParentId = null;
            update oCase;
        
            Test.stopTest();
        
            oCase = [SELECT Id, ParentId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(null, oCase.ParentId);
        }

        system.debug('##### END testRemoveParentCase #####');
    }
    
    public static testmethod void testSLADueDateCalculation()
    {
        system.debug('##### START testSLADueDateCalculation #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT07',Alias='APCT07',
            Email='APCT07@shell.com',Username='APCT07@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT07 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT07 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT07', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT07 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT07City', Email__c = 'APCT07@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT07 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT07 Mandataire',
                ExternalID__c = 'MAP7',
                Active__c = true
            );
            insert mand1;
            
            // 20190529 Create Parent Category to link to the category used in the test so that the test doesn't fail on Category__c lookup filter  
            Request_Category__c oParentCategory = new Request_Category__c();
            oParentCategory.Name__c = 'Test Parent Name';
            oParentCategory.Code__c = 'TPC';
            oParentCategory.SLA__c = 10;
            insert oParentCategory;
            
            Request_Category__c oCategory = new Request_Category__c();
            oCategory.Name__c = 'Test Name';
            oCategory.Code__c = 'TC';
            oCategory.SLA__c = 10;
            oCategory.Parent_Category__c = oParentCategory.Id;
            insert oCategory;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.Category__c = oCategory.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.stopTest();
            
        }
           
        system.debug('##### END testSLADueDateCalculation #####');
    }
    
    public static testmethod void testCheckActivitiesWhenClosing()
    {
        system.debug('##### START testCheckActivitiesWhenClosing #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT08',Alias='APCT08',
            Email='APCT08@shell.com',Username='APCT08@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT08 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT08 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT08', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT08 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT08City', Email__c = 'APCT08@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
          //  Contact c = new Contact(Lastname='APCT08 Contact', AccountId = a.id);
          //  insert c;
          
                   
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT08 Mandataire',
                ExternalID__c = 'MAP8',
                Active__c = true
            );
            insert mand1;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Task oTask = new Task();
            oTask.WhatId = oCase.Id;
            insert oTask;
        
            oCase.Status = 'Closed';
            try {
                update oCase;
            } catch (DmlException e) {
                System.assert(e.getMessage().contains(Label.check_no_Activities_when_closing_Case), e.getMessage());
            }
        
            oTask.Status = 'Completed';
            update oTask;
        
            update oCase;
        
            Test.stopTest();    
        }

        system.debug('##### END testCheckActivitiesWhenClosing #####');
    }
    
    public static testmethod void testFrontOffice()
    {
        system.debug('##### START testFrontOffice #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT09',Alias='APCT09',
            Email='APCT09@shell.com',Username='APCT09@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT09 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT09 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT09', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT09 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT09City', Email__c = 'APCT09@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT09 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT09 Mandataire',
                ExternalID__c = 'MAP9',
                Active__c = true
            );
            insert mand1;
            
            // Get the Mandataire of the logged in user
            User oLoggedInUser = [select User_Mandataires__c from User where Id = :userInfo.getUserId()];
        
            list<Mandataire__c> lMandataire = new list<Mandataire__c>();
            if (!Utils.valueIsNull(oLoggedInUser.User_Mandataires__c)) {
                String[] userMandataires = oLoggedInUser.User_Mandataires__c.split(';',0);          
                try {
                    lMandataire = [select Id from Mandataire__c where ExternalID__c IN :userMandataires];
                } catch (System.QueryException e) {
                    System.Debug('Mandataire(s): ' + oLoggedInUser.User_Mandataires__c + ' not found');
                }
            }
        
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.ContactId = c.Id;
            insert oCase;
        
            Test.stopTest();
        
            oCase = [SELECT Id, Front_Office__c FROM Case WHERE Id = :oCase.Id];
            //System.assertEquals(oFrontOffice.Id, oCase.Front_Office__c);

            if(lMandataire.size()==1){
                System.assertEquals(oCase.Front_Office__c,lMandataire.get(0).Id);
            }
            else if(lMandataire.size()>1){
                System.assertEquals(oCase.Front_Office__c,oCase.Mandataire__c);
            }
        
        }
        
        system.debug('##### END testFrontOffice #####');
    }
    
    
    public static testmethod void testInsertCaseWithLinkedOrder()
    {
        system.debug('##### START testInsertCaseWithLinkedOrder #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT10',Alias='APCT10',
            Email='APCT10@shell.com',Username='APCT10@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT10 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT10 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT10', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT10 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT10City', Email__c = 'APCT10@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT10 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT10 Mandataire',
                ExternalID__c = 'MAP10',
                Active__c = true
            );
            insert mand1;
            
            PTL__c oPtl = new PTL__c();
            oPtl.Activity_Domain__c = AD_GEC.Id;
            oPtl.Mandataire__c = mand1.Id;
            oPTL.City__c = 'A City';
            oPTL.Postal_Code__c = '09877';
            insert oPtl;
            
            Equipement__c oEquipment = new Equipement__c();
            oEquipment.PTL__c = oPtl.Id;
            oEquipment.Activity_Domain__c = AD_GEC.Id;
            oEquipment.Mandataire__c = mand1.Id;
            insert oEquipment;
            
            Contract oContract = new Contract();
            oContract.AccountId = a.Id;
            oContract.PTL__c = oPtl.Id;
            oContract.Equipement__c = oEquipment.Id;
            oContract.Activity_Domain__c = AD_GEC.Id;
            oContract.Mandataire__c = mand1.Id;
            insert oContract;
            
            Order__c oOrder = new Order__c();
            oOrder.Account__c = a.Id;
            oOrder.Contract__c = oContract.Id;
            oOrder.Activity_Domain__c = AD_GEC.Id;
            oOrder.Mandataire__c = mand1.Id;
            insert oOrder;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.Order__c = oOrder.Id;
            insert oCase;
        
            Test.stopTest();
        
            oOrder = [SELECT Id, Activity_Domain__c, Mandataire__c, Contract__c, Contract__r.Ptl__c, Contract__r.Equipement__c, Contract__r.AccountId FROM Order__c WHERE Id = :oOrder.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(oOrder.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(oOrder.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(oOrder.Id, oCase.Order__c);
            System.assertEquals(oOrder.Contract__c, oCase.Contract__c);
            System.assertEquals(oOrder.Contract__r.Equipement__c, oCase.Equipement__c);
            System.assertEquals(oOrder.Contract__r.Ptl__c, oCase.PTL__c);
            System.assertEquals(oOrder.Contract__r.AccountId, oCase.AccountId);
            
        }
        system.debug('##### END testInsertCaseWithLinkedOrder #####');
    }
    
    public static testmethod void testInsertCaseWithLinkedContract() {
        
        system.debug('##### START testInsertCaseWithLinkedContract #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT11',Alias='APCT11',
            Email='APCT11@shell.com',Username='APCT11@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT11 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT11 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT11', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT11 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT11City', Email__c = 'APCT11@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT11 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT11 Mandataire',
                ExternalID__c = 'MAP11',
                Active__c = true
            );
            insert mand1;
            
            PTL__c oPtl = new PTL__c();
            oPtl.Activity_Domain__c = AD_GEC.Id;
            oPtl.Mandataire__c = mand1.Id;
            oPTL.City__c = 'A City';
            oPTL.Postal_Code__c = '09877';
            insert oPtl;
            
            Equipement__c oEquipment = new Equipement__c();
            oEquipment.PTL__c = oPtl.Id;
            oEquipment.Activity_Domain__c = AD_GEC.Id;
            oEquipment.Mandataire__c = mand1.Id;
            insert oEquipment;
            
            Contract oContract = new Contract();
            oContract.AccountId = a.Id;
            oContract.PTL__c = oPtl.Id;
            oContract.Equipement__c = oEquipment.Id;
            oContract.Activity_Domain__c = AD_GEC.Id;
            oContract.Mandataire__c = mand1.Id;
            insert oContract;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.Contract__c = oContract.Id;
            insert oCase;
        
            Test.stopTest();
        
            oContract = [SELECT Id, Activity_Domain__c, Mandataire__c, Ptl__c, Equipement__c, AccountId FROM Contract WHERE Id = :oContract.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(oContract.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(oContract.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(null, oCase.Order__c);
            System.assertEquals(oContract.Id, oCase.Contract__c);
            System.assertEquals(oContract.Equipement__c, oCase.Equipement__c);
            System.assertEquals(oContract.Ptl__c, oCase.PTL__c);
            System.assertEquals(oContract.AccountId, oCase.AccountId);
            
        }
               
        system.debug('##### END testInsertCaseWithLinkedContract #####');
    }
    
    public static testmethod void testInsertCaseWithLinkedEquipment()
    {
        system.debug('##### START testInsertCaseWithLinkedEquipment #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT12',Alias='APCT12',
            Email='APCT12@shell.com',Username='APCT12@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT12 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT12 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT12', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT12 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT12City', Email__c = 'APCT12@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT12 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT12 Mandataire',
                ExternalID__c = 'MAP12',
                Active__c = true
            );
            insert mand1;
            
            PTL__c oPtl = new PTL__c();
            oPtl.Activity_Domain__c = AD_GEC.Id;
            oPtl.Mandataire__c = mand1.Id;
            oPTL.City__c = 'A City';
            oPTL.Postal_Code__c = '09877';
            insert oPtl;
            
            Equipement__c oEquipment = new Equipement__c();
            oEquipment.PTL__c = oPtl.Id;
            oEquipment.Activity_Domain__c = AD_GEC.Id;
            oEquipment.Mandataire__c = mand1.Id;
            insert oEquipment;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.Equipement__c = oEquipment.Id;
            oCase.ContactId = c.Id;
        
            insert oCase;
        
            Test.stopTest();
        
            oEquipment = [SELECT Id, Activity_Domain__c, Mandataire__c, Ptl__c FROM Equipement__c WHERE Id = :oEquipment.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(oEquipment.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(oEquipment.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(null, oCase.Order__c);
            System.assertEquals(null, oCase.Contract__c);
            System.assertEquals(oEquipment.Id, oCase.Equipement__c);
            System.assertEquals(oEquipment.Ptl__c, oCase.PTL__c);
            System.assertEquals(a.id, oCase.AccountId);
    
        }
           
        system.debug('##### END testInsertCaseWithLinkedEquipment #####');
    }
    
    public static testmethod void testInsertCaseWithLinkedPtl()
    {
        system.debug('##### START testInsertCaseWithLinkedPtl #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT13',Alias='APCT13',
            Email='APCT13@shell.com',Username='APCT13@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT13 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT13 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT13', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT13 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT13City', Email__c = 'APCT13@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT13 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT13 Mandataire',
                ExternalID__c = 'MAP13',
                Active__c = true
            );
            insert mand1;

            PTL__c oPtl = new PTL__c();
            oPtl.Activity_Domain__c = AD_GEC.Id;
            oPtl.Mandataire__c = mand1.Id;
            oPTL.City__c = 'A City';
            oPTL.Postal_Code__c = '09877';
            insert oPtl;
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.ContactId = c.Id;
            oCase.Mandataire__c = mand1.Id;
            oCase.PTL__c = oPtl.Id;
            insert oCase;
        
            Test.stopTest();
        
            oPtl = [SELECT Id, Activity_Domain__c, Mandataire__c FROM PTL__c WHERE Id = :oPtl.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(oPtl.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(oPtl.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(null, oCase.Order__c);
            System.assertEquals(null, oCase.Contract__c);
            System.assertEquals(null, oCase.Equipement__c);
            System.assertEquals(oPtl.Id, oCase.PTL__c);
            System.assertEquals(a.id, oCase.AccountId);
            
        }
 
        system.debug('##### END testInsertCaseWithLinkedPtl #####');
    }
    
    public static testmethod void testInsertCaseWithLinkedAccount()
    {
        system.debug('##### START testInsertCaseWithLinkedAccount #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT14',Alias='APCT14',
            Email='APCT14@shell.com',Username='APCT14@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT14 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT14 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT13', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT14 Mandataire',
                ExternalID__c = 'MAP14',
                Active__c = true
            );
            insert mand1;
            
            Account a = new Account(Name='APCT14 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT14City', Email__c = 'APCT14@test.org', channel__c='CD',
                accountNumber='12345', Mandataire__c = mand1.id,Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT14 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            
            
            Test.startTest();
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.AccountId = a.Id;
            insert oCase;
        
            Test.stopTest();
        
            a = [SELECT Id, Activity_Domain__c, Mandataire__c FROM Account WHERE Id = :a.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(a.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(a.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(null, oCase.Order__c);
            System.assertEquals(null, oCase.Contract__c);
            System.assertEquals(null, oCase.Equipement__c);
            System.assertEquals(null, oCase.PTL__c);
            System.assertEquals(a.Id, oCase.AccountId);
            
        }
               
        system.debug('##### END testInsertCaseWithLinkedAccount #####');
    }
    
    public static testmethod void testCaseAdditionnalTests()
    {
        system.debug('##### START testCaseAdditionnalTests #####');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT15',Alias='APCT15',
            Email='APCT15@shell.com',Username='APCT15@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', User_Mandataires__c ='MAP14');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=42);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT14 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT14 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT13', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT14 Mandataire',
                ExternalID__c = 'MAP14',
                Active__c = true
            );
            insert mand1;
            
            
            Account a = new Account(Name='APCT14 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT14City', Email__c = 'APCT14@test.org', channel__c='CD',
                accountNumber='12345', Mandataire__c = mand1.id, ExternalID__c = '20',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APCT14 Contact', AccountId = a.id);
           	// insert c;
            
                     
           	// New Contact
           	Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           	accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           	Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           	Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           	insert c;
           
           	// PTL
	       	PTL__c ptl1 = new PTL__c(
	            Activity_Domain__c = AD_GEC.id,
	            Mandataire__c = mand1.id,
	            City__c = 'VFC06PS City 2',
	            Postal_Code__c = '09876',
	            ExternalID__c = '21',
	            Account_DO__c = a.Id
	       	);
	       	insert ptl1;
            
            // 20190529 Create Parent Category to link to the category used in the test so that the test doesn't fail on Category__c lookup filter  
            Request_Category__c oParentCategory = new Request_Category__c();
            oParentCategory.Name__c = 'Test Parent Name';
            oParentCategory.Code__c = 'TPC';
            oParentCategory.SLA__c = 10;
            insert oParentCategory;
            
            Request_Category__c rc = new Request_Category__c(
                name='Test RC', 
                W2C_RequestCategory__c = 'CDW01',
                Code__c = '000', 
                Name__c = 'CDW01',
                Parent_Category__c = oParentCategory.Id);
            insert rc;
            
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.AccountId = a.Id;
            oCase.W2C_AccountNumber__c = '20';
            oCase.W2C_CaseCategory__c = 'CDW01';
            oCase.W2C_ActivityDomain__c = 99;
            oCase.W2C_PTLNumber__c = '21';
            oCase.Customer_Project__c = 'Vente';
            
            Test.startTest();
        
            insert oCase;
            List<Case> caseList = new List<Case>();
            caseList.add(oCase);
            AP_Case.setFrontOffice(caseList);
        
            Test.stopTest();
            
        }
               
        system.debug('##### END testInsertCaseWithLinkedAccount #####');
    }
}