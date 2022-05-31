@isTest
private class AP_Assignment_Main_01_TEST2 {

    public static testmethod void testAssignment(){
        // This method tests that the lead is assigned
        
        System.Debug('### >>>>> testing class AP_Assignment_Main_01_TEST.testAssignment <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM1',Alias='APAM1',
            Email='APAM1@shell.com',Username='APAM1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            
            Rep_For_Filter__c RFF = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '21'
            );
            insert RFF;
            
            Assignment_Filter__c AF = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '22'
            );
            insert AF;

            Lead oLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
                Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig1@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );
            insert oLead;

            System.debug('[AP_Assignment_Main_01_Test.testAssignment] Running.');
            Test.startTest();

            System.assertEquals(null, oLead.OwnerId);
            oLead = [SELECT Assign__c, T_Assignment_CantonId__c FROM Lead WHERE Id = :oLead.Id];
            System.assertEquals(Some_Canton.Id, oLead.T_Assignment_CantonId__c);

            oLead.Assign__c = true;
            update oLead;
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT OwnerId, Assign__c FROM Lead WHERE Id = :oLead.Id]; // Refresh.
            //System.assertEquals(grp11.Id, oLead.OwnerId);
            //System.assertEquals(false, oLead.Assign__c); // This should be reset

            Test.stopTest();
            System.debug('[AP_Assignment_Main_01_Test.testAssignment] Finished.');
            
        }

    }

    public static testmethod void testPriorities(){
        
        System.Debug('### >>>>> testing class AP_Assignment_Main_01_TEST.testPriorities <<<<<');
        // This method tests that the findRep method finds the proper Rep when there are several ones available.
        System.debug('[AP_Assignment_Main_01_Test.testPriorities] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM2',Alias='APAM2',
            Email='APAM2@shell.com',Username='APAM2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            Lead oLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = false, Project_Street_Name__c = 'ABC', Project_Street_Number__c = '123', Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig2@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );
            insert oLead;

            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Running.');
            Test.startTest();

            // Rep for ALL.
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for All.');
            Rep_For_Filter__c RFF1 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '410'
            );
            insert RFF1;
            Assignment_Filter__c AF1 = new Assignment_Filter__c(
                Activity_Domain__c = null, Market_Type__c = null, Canton__c = null,
                Rep_For_Filter__c = RFF1.Id, Assignment_Managed_Id__c = '23'
            );
            insert AF1; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF1 Id: ' + AF1.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF1 GroupId: ' + grp11.Id);
            oLead.Assign__c = true;
            update oLead; 
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp11.Id, oLead.OwnerId);
        
            // Rep for AD
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct AD & All.');
            Rep_For_Filter__c RFF2 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '411'
            );
            insert RFF2;
            Assignment_Filter__c AF2 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = null, Canton__c = null,
                Rep_For_Filter__c = RFF2.Id, Assignment_Managed_Id__c = '24'
            );
            insert AF2;
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF2 Id: ' + AF2.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF2 GroupId: ' + grp21.Id);
            oLead.Assign__c = true;
            update oLead; 
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp21.Id, oLead.OwnerId);

            // Rep for MT
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct MT & All.');
            Rep_For_Filter__c RFF3 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '401'
            );
            insert RFF3;
            Assignment_Filter__c AF3 = new Assignment_Filter__c(
                Activity_Domain__c = null, Market_Type__c = 'PRO', Canton__c = null,
                Rep_For_Filter__c = RFF3.Id, Assignment_Managed_Id__c = '25'
            );
            insert AF3; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF3 Id: ' + AF3.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF3 GroupId: ' + grp31.Id);
            oLead.Assign__c = true;
            update oLead; 
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp31.Id, oLead.OwnerId);

            // Rep for AD / MT
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct AD & MT & All.');
            Rep_For_Filter__c RFF4 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '402'
            );
            insert RFF4;
            Assignment_Filter__c AF4 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Canton__c = null,
                Rep_For_Filter__c = RFF4.Id, Assignment_Managed_Id__c = '26'
            );
            insert AF4; 
            oLead.Assign__c = true;
            update oLead; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF4 Id: ' + AF4.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF4 GroupId: ' + grp41.Id);
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp41.Id, oLead.OwnerId);

            // Rep for CA
            // NEWWWWW
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct MT & CA & All.');
            Rep_For_Filter__c RFF5 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '403'
            );
            insert RFF5;
            Assignment_Filter__c AF5 = new Assignment_Filter__c(
                Activity_Domain__c = null, Market_Type__c = null, Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF5.Id, Assignment_Managed_Id__c = '27'
            );
            insert AF5; 
            oLead.Assign__c = true;
            update oLead; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF5 Id: ' + AF5.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF5 GroupId: ' + grp51.Id);
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp51.Id, oLead.OwnerId);

            // Rep for AD / CA
            Rep_For_Filter__c RFF6 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '403X'
            );
            insert RFF6;
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct AD & CA & All.');
            Assignment_Filter__c AF6 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = null, Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF6.Id, Assignment_Managed_Id__c = '28'
            );
            insert AF6; 
            oLead.Assign__c = true;
            update oLead; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF6 Id: ' + AF6.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF6 GroupId: ' + grp61.Id);
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp61.Id, oLead.OwnerId);

            // Rep for MT / CA
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct MT & CA & All.');
            Rep_For_Filter__c RFF7 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '404'
            );
            insert RFF7;
            Assignment_Filter__c AF7 = new Assignment_Filter__c(
                Activity_Domain__c = null, Market_Type__c = 'PRO', Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF7.Id, Assignment_Managed_Id__c = '29'
            );
            insert AF7; 
            oLead.Assign__c = true;
            update oLead; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF7 Id: ' + AF7.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF7 GroupId: ' + grp71.Id);
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp71.Id, oLead.OwnerId);

            // Rep for AD / MT / CA
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Rep allowed for correct AD & MT & CA.');
            Rep_For_Filter__c RFF8 = new Rep_For_Filter__c(
                Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '405'
            );
            insert RFF8;
            Assignment_Filter__c AF8 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF8.Id, Assignment_Managed_Id__c = '291'
            );
            insert AF8; 
            oLead.Assign__c = true;
            update oLead; 
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF8 Id: ' + AF8.Id);
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] AF8 GroupId: ' + grp81.Id);
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead.Id];
            //System.assertEquals(grp81.Id, oLead.OwnerId);

            Test.stopTest();
            System.debug('[AP_Assignment_Main_01_Test.testPriorities] Finished.');
        }       
    }

    public static testmethod void testNoTrigger(){
        System.Debug('### >>>>> testing class AP_Assignment_Main_01_TEST.testNoTrigger <<<<<');
        // This method tests that the findRep method finds the proper Rep when there are several ones available.
        System.debug('[AP_Assignment_Main_01_Test.testPriorities] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM3',Alias='APAM3',
            Email='APAM3@shell.com',Username='APAM3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            
            Lead prescriberLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', 
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                RecordTypeId =  prescriberRTId , Assign__c = true, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
                Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig3@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );
            Lead oLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', 
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                RecordTypeId = leadRTId, Assign__c = false, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
                Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig4@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );

            System.debug('[AP_Assignment_Main_01_Test.testNoTrigger] Running.');
            Test.startTest();
            // We do not Assert, because these WOULD raise errors if the trigger fired.
            // (Anothet trigger ensures errors are raised) (TODO)

            // Check for no Assign__c
            System.debug('[AP_Assignment_Main_01_Test.testNoTrigger] Inserting Lead with no Assign__c');
            // We added NO filter, so if we take the assignment code path, we'll get a "NoRepFound" error added.
            insert oLead;

            // Check for prescriber lead
            System.debug('[AP_Assignment_Main_01_Test.testNoTrigger] Inserting Prescriber Lead with Assign__c');
            // We added NO filter, so if we take the assignment code path, we'll get a "NoRepFound" error added.
            insert prescriberLead; 

            // Check for Direct_Client__c
            System.debug('[AP_Assignment_Main_01_Test.testNoTrigger] Inserting GEC Direct Lead with Assign__c');
            oLead.Assign__c = true;
            oLead.Direct_Client__c = true;
            // We added NO filter, so if we take the assignment code path, we'll get a "NoRepFound" error added.
            update oLead;


            Test.stopTest();
            System.debug('[AP_Assignment_Main_01_Test.testNoTrigger] Finished.');
        }

        
    }

    public static testmethod void testNoRep(){
        
        // Check that an Error is raised when no REP is found!
        System.debug('[AP_Assignment_Main_01_Test.testNoRep] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM4',Alias='APAM4',
            Email='APAM4@shell.com',Username='APAM4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            Boolean hasErrored = false;
        
            System.debug('[AP_Assignment_Main_01_Test.testNoRep] Running.');
            Test.startTest();

            Lead oLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                Assign__c = true, Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig5@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );

            try{ 
                insert oLead;
            } catch (System.DMLException e){
                System.assert(e.getMessage().contains(System.Label.Error_NoRepFound));
                hasErrored = true;
            }
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //System.assertEquals(true, hasErrored);

            Test.stopTest();
            System.debug('[AP_Assignment_Main_01_Test.testNoRep] Finished..');
        
        }
    }

    @isTest
    public static void testWorkflows(){
        System.debug('[AP_Assignment_Main_01_Test.testWorkflows] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM5',Alias='APAM5',
            Email='APAM5@shell.com',Username='APAM5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
        
            Group prescriberLeadsQueue = [SELECT Id FROM Group WHERE DeveloperName='Prescriber_Leads'];
            Group directLeadsQueue     = [SELECT Id FROM Group WHERE DeveloperName='Direct_Leads'];

            Lead prescriberLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', 
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                RecordTypeId =  prescriberRTId, Assign__c = true, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
                Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig6@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );
            Lead directLead = new Lead(
                FirstName='aName', LastName='SomeName', Company='SomeCompany', 
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = Some_Code.Id,
                RecordTypeId = leadRTId, Assign__c = true, Direct_Client__c = true, Project_Street_Number__c  = '123', 
                Project_Street_Name__c = 'ABC', Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig7@SomeCompany.com',Account_Country__c='FR', Phone='0202020202'
            );

            System.debug('[AP_Assignment_Main_01_Test.testWorkflows] Running.');
            Test.startTest();

            System.debug('[AP_Assignment_Main_01_Test.testWorkflows] Inserting leads.');
            insert new List<Lead>{prescriberLead, directLead};
            prescriberLead = [SELECT OwnerId, Assign__c FROM Lead WHERE Id=:prescriberLead.Id];
            directLead     = [SELECT OwnerId, Assign__c FROM Lead WHERE Id=:directLead.Id];

            /*System.assertEquals(prescriberLeadsQueue.Id, prescriberLead.OwnerId);
            System.assertEquals(directLeadsQueue.Id, directLead.OwnerId);
            System.assertEquals(false, prescriberLead.Assign__c);
            System.assertEquals(false, directLead.Assign__c);*/

            Test.stopTest();
            System.debug('[AP_Assignment_Main_01_Test.testWorkflows] Finished.');
        }
    }

    public static testmethod void testSimultaneousAssignment(){
        // Here we test that it works when we have several unrelated leads updated at once.
        System.debug('[AP_Assignment_Main_01_Test.testSimultaneousAssignment] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM6',Alias='APAM6',
            Email='APAM6@shell.com',Username='APAM6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_');
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-');
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            Rep_For_Filter__c RFF1 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, 
                Assignment_Managed_Id__c = '406');
            insert RFF1;

            Assignment_Filter__c AF1 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Canton__c = Some_Canton.Id,
                Rep_For_Filter__c = RFF1.Id, Assignment_Managed_Id__c = '292'
            );
            insert AF1;

            Lead oLead1 = new Lead(
                FirstName='aName', LastName='SomeName', Company='Somecompany',
                Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', 
                Project_City_Postal_Code__c = Some_Code.Id, Assign__c = true, Project_Street_Number__c = '123', 
                Project_Street_Name__c = 'ABC', Account_City_Postal_Code__c = Some_Code.Id,
                email='SomeNameAssig8@SomeCompany.com',Account_Country__c='FR',Phone='0202020202'
            );


            Rep_For_Filter__c RFF2 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, 
                Assignment_Managed_Id__c = '407');
            insert RFF2;

            Assignment_Filter__c AF2 = new Assignment_Filter__c(
                Activity_Domain__c = AD_GER.Id, Market_Type__c = 'DOM', Canton__c = Other_Canton.Id,
                Rep_For_Filter__c = RFF2.Id, Assignment_Managed_Id__c = '293'
            );
            insert AF2;

            Lead oLead2 = new Lead(
                FirstName='aName', LastName='SomeName', Project_Street_Name__c = 'Somestreet',
                Activity_Domain__c = AD_GER.Id, Market_Type__c = 'DOM', 
                Project_City_Postal_Code__c = Other_Code.Id,
                Assign__c = true, Account_City_Postal_Code__c = Other_Code.Id,
                email='SomeNameAssig9@SomeCompany.com',Account_Country__c='FR',Phone='0202020202'
            );

            System.debug('[AP_Assignment_Main_01_Test.testSimultaneousAssignment] Running.');
            Test.startTest();

            insert new List<Lead>{oLead1, oLead2};
            
            // Erwan 20170224 Assertion removed because the assignment method has been moved to @future
            //oLead1 = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead1.Id];
            //oLead2 = [SELECT Id, OwnerId FROM Lead WHERE Id = :oLead2.Id];

            //System.assertEquals(grp11.Id, oLead1.OwnerId);
            //System.assertEquals(grp21.Id, oLead2.OwnerId);

            Test.stopTest();
        }
        System.debug('[AP_Assignment_Main_01_Test.testSimultaneousAssignment] Finished.');
    }
    
    /* NOT IMPLEMENTED BY PREVIOUS TEAM
    public static testmethod void testUnrelatedRep(){
        // This methods checks that some unrelated reps won't affect.
        Test.startTest();
        Test.stopTest();
    } */

    /* NOT IMPLEMENTED BY PREVIOUS TEAM
    public static testmethod void testMultipleRep(){
        // Can I make it work??
        Test.startTest();
        Test.stopTest();
    }*/

    // TO FIX: need to test using Users: a Queue can't be owner of an opportunity.
    public static testmethod void testOpty(){
        // Test that we work optys too now!
        System.debug('[AP_Assignment_Main_01_Test.testOpty] Initializing.');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAM7',Alias='APAM7',
            Email='APAM7@shell.com',Username='APAM7@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3
            );
            insert mandataire1;
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');    
            Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
            //this.MT_DOM = 'DOM';                                   this.MT_PRO = 'PRO';
            //this.PT_CREA = 'CREA'; this.PT_SUCC = 'SUCC';          this.PT_FIDE = 'FIDE'; this.PT_EXTE = 'EXTE';
            Canton__c Some_Canton = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '-_-_',Mandataire__c = mandataire1.id );
            Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '_-_-' ,Mandataire__c = mandataire1.id );
            Group grp11 = new Group(Name='AGroup1', Type='Queue');  
            Group grp21 = new Group(Name='BGroup1', Type='Queue');
            Group grp12 = new Group(Name='AGroup2', Type='Queue');  
            Group grp22 = new Group(Name='BGroup2', Type='Queue');
            Group grp31 = new Group(Name='CGroup1', Type='Queue');  
            Group grp41 = new Group(Name='DGroup1', Type='Queue');
            Group grp32 = new Group(Name='CGroup2', Type='Queue');  
            Group grp42 = new Group(Name='DGroup2', Type='Queue');
            Group grp51 = new Group(Name='EGroup1', Type='Queue');  
            Group grp61 = new Group(Name='FGroup1', Type='Queue');
            Group grp52 = new Group(Name='EGroup2', Type='Queue');  
            Group grp62 = new Group(Name='FGroup2', Type='Queue');
            Group grp71 = new Group(Name='HGroup1', Type='Queue');  
            Group grp81 = new Group(Name='IGroup1', Type='Queue');
            Group grp72 = new Group(Name='HGroup2', Type='Queue');  
            Group grp82 = new Group(Name='IGroup2', Type='Queue');
            
            insert new List<Sobject>{ 
                grp11, grp21, grp12, grp22, 
                grp31, grp41, grp32, grp42,
                grp51, grp61, grp52, grp62,
                grp71, grp81, grp72, grp82 
            };
            insert new List<Sobject>{ 
                new QueueSobject(QueueId = grp11.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp21.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp31.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp41.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp51.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp61.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp71.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp81.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp12.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp22.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp32.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp42.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp52.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp62.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp72.Id, SobjectType='Lead'),
                new QueueSobject(QueueId = grp82.Id, SobjectType='Lead')
            };
            
            insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };
            
            City__c Some_City  = new City__c(Name = 'SomeCity',  Canton__c = Some_Canton.Id, INSEE_Code__c = '____-');
            City__c Other_City = new City__c(Name = 'OtherCity', Canton__c = Other_Canton.Id, INSEE_Code__c = '___--');
            insert new List<Sobject>{Some_City, Other_City};

            City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
                HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
                HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');

            insert new List<Sobject> {Some_Code, Other_Code};
            
            Id prescriberRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Prescriber_Lead' AND SObjectType='Lead' LIMIT 1].Id;
            Id leadRTId = [SELECT Id FROM RecordType WHERE DeveloperName='Lead' AND SObjectType='Lead' LIMIT 1].Id;
            
            Rep_For_Filter__c RFF82 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp82.Id, Assignment_Managed_Id__c = '01');
            Rep_For_Filter__c RFF81 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp81.Id, Assignment_Managed_Id__c = '02');
            Rep_For_Filter__c RFF72 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp72.Id, Assignment_Managed_Id__c = '03');
            Rep_For_Filter__c RFF71 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp71.Id, Assignment_Managed_Id__c = '04');
            Rep_For_Filter__c RFF62 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp62.Id, Assignment_Managed_Id__c = '05');
            Rep_For_Filter__c RFF61 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp61.Id, Assignment_Managed_Id__c = '06');
            Rep_For_Filter__c RFF52 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp52.Id, Assignment_Managed_Id__c = '07');
            Rep_For_Filter__c RFF51 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp51.Id, Assignment_Managed_Id__c = '08');
            Rep_For_Filter__c RFF42 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp42.Id, Assignment_Managed_Id__c = '09');
            Rep_For_Filter__c RFF41 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp41.Id, Assignment_Managed_Id__c = '010');
            Rep_For_Filter__c RFF32 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp32.Id, Assignment_Managed_Id__c = '011');
            Rep_For_Filter__c RFF31 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp31.Id, Assignment_Managed_Id__c = '012');
            Rep_For_Filter__c RFF22 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp22.Id, Assignment_Managed_Id__c = '013');
            Rep_For_Filter__c RFF21 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp21.Id, Assignment_Managed_Id__c = '014');
            Rep_For_Filter__c RFF12 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp12.Id, Assignment_Managed_Id__c = '015');
            Rep_For_Filter__c RFF11 = new Rep_For_Filter__c( Target__c = 'Queue', QueueID__c = grp11.Id, Assignment_Managed_Id__c = '016');

            insert new List<Sobject>{ 
                RFF11, RFF21, RFF12, RFF22, 
                RFF31, RFF41, RFF32, RFF42,
                RFF51, RFF61, RFF52, RFF62,
                RFF71, RFF81, RFF72, RFF82 
            };
            
            Assignment_Filter__c AF11 = new Assignment_Filter__c( Rep_For_Filter__c = RFF11.Id, Assignment_Managed_Id__c = '301');
            Assignment_Filter__c AF12 = new Assignment_Filter__c( Rep_For_Filter__c = RFF12.Id, Assignment_Managed_Id__c = '302');
            Assignment_Filter__c AF21 = new Assignment_Filter__c( Rep_For_Filter__c = RFF21.Id, Assignment_Managed_Id__c = '303');
            Assignment_Filter__c AF22 = new Assignment_Filter__c( Rep_For_Filter__c = RFF22.Id, Assignment_Managed_Id__c = '304');
            Assignment_Filter__c AF31 = new Assignment_Filter__c( Rep_For_Filter__c = RFF31.Id, Assignment_Managed_Id__c = '305');
            Assignment_Filter__c AF32 = new Assignment_Filter__c( Rep_For_Filter__c = RFF32.Id, Assignment_Managed_Id__c = '306');
            Assignment_Filter__c AF41 = new Assignment_Filter__c( Rep_For_Filter__c = RFF41.Id, Assignment_Managed_Id__c = '307');
            Assignment_Filter__c AF42 = new Assignment_Filter__c( Rep_For_Filter__c = RFF42.Id, Assignment_Managed_Id__c = '308');
            Assignment_Filter__c AF51 = new Assignment_Filter__c( Rep_For_Filter__c = RFF51.Id, Assignment_Managed_Id__c = '309');
            Assignment_Filter__c AF52 = new Assignment_Filter__c( Rep_For_Filter__c = RFF52.Id, Assignment_Managed_Id__c = '310');
            Assignment_Filter__c AF61 = new Assignment_Filter__c( Rep_For_Filter__c = RFF61.Id, Assignment_Managed_Id__c = '311');
            Assignment_Filter__c AF62 = new Assignment_Filter__c( Rep_For_Filter__c = RFF62.Id, Assignment_Managed_Id__c = '312');
            Assignment_Filter__c AF71 = new Assignment_Filter__c( Rep_For_Filter__c = RFF71.Id, Assignment_Managed_Id__c = '313');
            Assignment_Filter__c AF72 = new Assignment_Filter__c( Rep_For_Filter__c = RFF72.Id, Assignment_Managed_Id__c = '314');
            Assignment_Filter__c AF81 = new Assignment_Filter__c( Rep_For_Filter__c = RFF81.Id, Assignment_Managed_Id__c = '315');
            Assignment_Filter__c AF82 = new Assignment_Filter__c( Rep_For_Filter__c = RFF82.Id, Assignment_Managed_Id__c = '316');
            // End init
            
            Account oAcct = new Account(Name = 'TestAccount', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'Somewhere',Email__c = 'apAssigAccnt@test.org',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert oAcct;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
                Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
                Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
            insert c;
            
            Opportunity oOpty1 = new Opportunity(Name = 'TestOpty', StageName='Open', AccountId = oAcct.Id, Assign__c = True, 
                CloseDate = Date.today(), Project_City_Postal_Code__c = Some_Code.Id, DO_City_Postal_Code__c = Some_Code.Id);
            Opportunity oOpty2 = new Opportunity(Name = 'TestOpty', StageName='Open', AccountId = oAcct.Id, Assign__c = True, 
                CloseDate = Date.today(), Project_City_Postal_Code__c = Some_Code.Id, DO_City_Postal_Code__c = Some_Code.Id);
            AF11.Market_Type__c = 'DOM';
            AF11.Activity_Domain__c = AD_GEC.Id;
            insert AF11;
            AF11 = [SELECT Id, TargetId__c FROM Assignment_Filter__c WHERE Id = :AF11.Id];

            Boolean hasErrored1 = false;

            System.debug('[AP_Assignment_Main_01_Test.testOpty] Running.');
            Test.startTest();

            try{ 
                insert new List<Opportunity>{oOpty1, oOpty2};
            } catch (System.DMLException e){
                //System.assert(e.getMessage().contains(System.Label.Error_CouldNotAssign));
                hasErrored1 = true;
            }
            System.assertEquals(true, hasErrored1);
        
            oOpty1.Assign__c = false;
            oOpty2.Assign__c = false;

            insert new List<SObject>{oOpty1, oOpty2};

            // oOpty = [SELECT Id, OwnerId FROM Opportunity WHERE ID = :oOpty.Id];
            // System.assertEquals(bp.AF11.TargetId__c, oOpty.OwnerId);

            Test.stopTest();
        }
        
        System.debug('[AP_Assignment_Main_01_Test.testOpty] Finished.');
    }
}