@isTest
private class AP_ApprovalHierarchy_01_TEST {

    public static testmethod void testNoUser(){
        
        System.Debug('### >>>>> testing class AP_ApprovalHierarchy_01_TEST.testNoUser <<<<<');
        // Tests that an exception is raised when no user is found. (RepNotInHiearchyException)
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        String profileId2 = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Standard User%' LIMIT 1].Id;
        
        User u = new User(FirstName='Test', LastName='APAH1',Alias='APAH1',
            Email='APAH1@shell.com',Username='APAH1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        User user0 = new User(FirstName='Test', LastName='APAH20',Alias='APAH20',
            Email='APAH20@shell.com',Username='APAH20@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user1 = new User(FirstName='Test', LastName='APAH21',Alias='APAH21',
            Email='APAH21@shell.com',Username='APAH21@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user2 = new User(FirstName='Test', LastName='APAH22',Alias='APAH22',
            Email='APAH22@shell.com',Username='APAH22@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_1 = new User(FirstName='Test', LastName='APAH231',Alias='APAH231',
            Email='APAH231@shell.com',Username='APAH231@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_2 = new User(FirstName='Test', LastName='APAH232',Alias='APAH232',
            Email='APAH232@shell.com',Username='APAH232@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        insert new List<User> { user0, user1, user2, user3_1, user3_2 };
        
    
        
        Activity_Domain__c AD_GER = new Activity_Domain__c(Name = 'GER');
        insert AD_GER;
        Activity_Domain__c AD_GEC = new Activity_Domain__c(Name = 'GEC');
        insert AD_GEC;
        
        // Organizations
        Organization__c org1 = new Organization__c(
            Name = 'GEC DOM CREA', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        Organization__c org2 = new Organization__c(
            Name = 'GEC PRO FIDE', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'FIDE'
        );
        Organization__c org3 = new Organization__c(
            Name = 'GER PRO CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'CREA'
        );

        Organization__c org4 = new Organization__c(
            Name = 'GER DOM CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        insert new List<Organization__c>{org1, org2, org3, org4};
        
        // Organization Nodes

        // ORG 1
        Organization_Node__c oNode1_0 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode1_0;

        Organization_Node__c oNode1_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode1_0.Id); 
        insert oNode1_1;

        Organization_Node__c oNode1_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user2.Id, Approval_Level__c = 2, Latitude_Level__c = 3000, 
            Manager_Organization_Node__c = oNode1_1.Id); 
        insert oNode1_2;

        Organization_Node__c oNode1_3_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_1.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_1;

        Organization_Node__c oNode1_3_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_2.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_2;

        // ORG 2
        Organization_Node__c oNode2_0 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode2_0;

        Organization_Node__c oNode2_1 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode2_0.Id); 
        insert oNode2_1;

        // ORG 3
        Organization_Node__c oNode3_0 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode3_0;

        Organization_Node__c oNode3_1 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode3_0.Id); 
        insert oNode3_1;

        // ORG 4
        // Nothing!
        
        System.runAs(u) {
                  
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;

            Canton__c canton = new Canton__c(name = 'Canton', INSEE_Code__c = '_____', Mandataire__c = mandataire1.id); 
            insert canton;
            City__c city   = new City__c(Name = 'City',  Canton__c = canton.Id, INSEE_Code__c = '_____'); 
            insert city;
            City_Postal_Code__c postalCode = new City_Postal_Code__c(Name = '123 - City', Postal_Code__c = '|||||', HEXAPOSTE_Code__c = '_____', City__c = city.Id, Code_Type__c = 'M');
            insert postalCode;
            
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = 'YYYY'); insert oDomain;
            
            Opportunity opty = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user0.Name + 'GER 1 0',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user0.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            insert opty;
            
            Quote oQuote = new Quote(
                Name = 'Quote' + user0.Name + org4.Name + '1 0',
                OpportunityId = opty.Id,
                Latitude__c = 1, Latitude_Level__c = 0,
                T_Organization__c = org4.Id
            );
            // ORO: VR requirements
            oQuote.DO_Payment_method__c = 'V';
            oQuote.Payment_spread__c = 'Z000';
            oQuote.Contract_Duration__c = '5';
            insert oQuote;
            oQuote = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote.Id
            ];
            
            Boolean hasErrored1 = false;

            Test.startTest();

            try {
                AP_ApprovalHierarchy_01.buildApproverChain(new List<Quote>{oQuote});
            } catch (AP_ApprovalHierarchy_01.RepNotInHiearchyException e){
                hasErrored1 = true;
            }
            System.assertEquals(true, hasErrored1);

            Test.stopTest();
        }
        
        System.Debug('### >>>>> testing class AP_ApprovalHierarchy_01_TEST.testNoApproverFound END <<<<<');
 
    }

    public static testmethod void testNoApproverFound(){
        
        System.Debug('### >>>>> testing class AP_ApprovalHierarchy_01_TEST.testNoApproverFound <<<<<');
        
        // Tests that an exception is raised when no user is found. (RepNotInHiearchyException)
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        String profileId2 = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Standard User%' LIMIT 1].Id;
        
        User u = new User(FirstName='Test', LastName='APAH3',Alias='APAH3',
            Email='APAH3@shell.com',Username='APAH3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        User user0 = new User(FirstName='Test', LastName='APAH40',Alias='APAH40',
            Email='APAH40@shell.com',Username='APAH40@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user1 = new User(FirstName='Test', LastName='APAH41',Alias='APAH41',
            Email='APAH41@shell.com',Username='APAH41@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user2 = new User(FirstName='Test', LastName='APAH42',Alias='APAH42',
            Email='APAH42@shell.com',Username='APAH42@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_1 = new User(FirstName='Test', LastName='APAH431',Alias='APAH431',
            Email='APAH431@shell.com',Username='APAH431@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_2 = new User(FirstName='Test', LastName='APAH432',Alias='APAH432',
            Email='APAH432@shell.com',Username='APAH432@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        insert new List<User> { user0, user1, user2, user3_1, user3_2 };
        
        Activity_Domain__c AD_GER = new Activity_Domain__c(Name = 'GER');
        insert AD_GER;
        Activity_Domain__c AD_GEC = new Activity_Domain__c(Name = 'GEC');
        insert AD_GEC;
        
        // Organizations
        Organization__c org1 = new Organization__c(
            Name = 'GEC DOM CREA', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        Organization__c org2 = new Organization__c(
            Name = 'GEC PRO FIDE', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'FIDE'
        );
        Organization__c org3 = new Organization__c(
            Name = 'GER PRO CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'CREA'
        );

        Organization__c org4 = new Organization__c(
            Name = 'GER DOM CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        insert new List<Organization__c>{org1, org2, org3, org4};
        
        // Organization Nodes

        // ORG 1
        Organization_Node__c oNode1_0 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode1_0;

        Organization_Node__c oNode1_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode1_0.Id); 
        insert oNode1_1;

        Organization_Node__c oNode1_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user2.Id, Approval_Level__c = 2, Latitude_Level__c = 3000, 
            Manager_Organization_Node__c = oNode1_1.Id); 
        insert oNode1_2;

        Organization_Node__c oNode1_3_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_1.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_1;

        Organization_Node__c oNode1_3_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_2.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_2;

        // ORG 2
        Organization_Node__c oNode2_0 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode2_0;

        Organization_Node__c oNode2_1 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode2_0.Id); 
        insert oNode2_1;

        // ORG 3
        Organization_Node__c oNode3_0 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode3_0;

        Organization_Node__c oNode3_1 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode3_0.Id); 
        insert oNode3_1;

        // ORG 4
        // Nothing!
        
        System.runAs(u) {
        
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
            
            Canton__c canton = new Canton__c(name = 'Canton', INSEE_Code__c = '_____', Mandataire__c = mandataire1.id); 
            insert canton;
            City__c city   = new City__c(Name = 'City',  Canton__c = canton.Id, INSEE_Code__c = '_____'); 
            insert city;
            City_Postal_Code__c postalCode = new City_Postal_Code__c(Name = '123 - City', Postal_Code__c = '|||||', HEXAPOSTE_Code__c = '_____', City__c = city.Id, Code_Type__c = 'M');
            insert postalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = 'YYYY'); insert oDomain;
            
            Opportunity opty = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user2.Name + 'GEC 50000 0',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user2.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            insert opty;
            
            Quote oQuote = new Quote(
                Name = 'Quote' + user2.Name + org1.Name + ' 50000 0',
                OpportunityId = opty.Id,
                Latitude__c = 50000, Latitude_Level__c = 0,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote.DO_Payment_method__c = 'V';
            oQuote.Payment_spread__c = 'Z000';
            oQuote.Contract_Duration__c = '5';
            insert oQuote;
            oQuote = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote.Id
            ];
            
            Boolean hasErrored1 = false;

            Test.startTest();

            try {
                AP_ApprovalHierarchy_01.buildApproverChain(new List<Quote>{oQuote});
            } catch (AP_ApprovalHierarchy_01.NoApproverFoundException e){
                hasErrored1 = true;
            }
            System.assertEquals(true, hasErrored1);

            Test.stopTest();
            
        }
    }

    public static testmethod void testCorrectApprovers(){
        
        System.Debug('### >>>>> testing class AP_ApprovalHierarchy_01_TEST.testNoApproverFound <<<<<');
        
        // Tests that an exception is raised when no user is found. (RepNotInHiearchyException)
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        String profileId2 = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Standard User%' LIMIT 1].Id;
        
        User u = new User(FirstName='Test', LastName='APAH5',Alias='APAH5',
            Email='APAH5@shell.com',Username='APAH5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        User user0 = new User(FirstName='Test', LastName='APAH60',Alias='APAH60',
            Email='APAH60@shell.com',Username='APAH60@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user1 = new User(FirstName='Test', LastName='APAH61',Alias='APAH61',
            Email='APAH61@shell.com',Username='APAH61@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user2 = new User(FirstName='Test', LastName='APAH62',Alias='APAH62',
            Email='APAH62@shell.com',Username='APAH62@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_1 = new User(FirstName='Test', LastName='APAH631',Alias='APAH631',
            Email='APAH631@shell.com',Username='APAH631@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        User user3_2 = new User(FirstName='Test', LastName='APAH632',Alias='APAH632',
            Email='APAH632@shell.com',Username='APAH632@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId2,
            LanguageLocaleKey='fr');
        insert new List<User> { user0, user1, user2, user3_1, user3_2 };
        
        Activity_Domain__c AD_GER = new Activity_Domain__c(Name = 'GER');
        //insert AD_GER;
        Activity_Domain__c AD_GEC = new Activity_Domain__c(Name = 'GEC');
        //insert AD_GEC;
        insert new List<Activity_Domain__c> {AD_GER, AD_GEC};
        
        // Organizations
        Organization__c org1 = new Organization__c(
            Name = 'GEC DOM CREA', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        Organization__c org2 = new Organization__c(
            Name = 'GEC PRO FIDE', Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'FIDE'
        );
        Organization__c org3 = new Organization__c(
            Name = 'GER PRO CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'PRO', 
            Project_Type__c = 'CREA'
        );

        Organization__c org4 = new Organization__c(
            Name = 'GER DOM CREA', Activity_Domain__c = AD_GER.Id, Market_Type__c = 'DOM', 
            Project_Type__c = 'CREA'
        );
        insert new List<Organization__c>{org1, org2, org3, org4};
        
        // Organization Nodes

        // ORG 1
        Organization_Node__c oNode1_0 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode1_0;

        Organization_Node__c oNode1_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode1_0.Id); 
        insert oNode1_1;

        Organization_Node__c oNode1_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user2.Id, Approval_Level__c = 2, Latitude_Level__c = 3000, 
            Manager_Organization_Node__c = oNode1_1.Id); 
        insert oNode1_2;

        Organization_Node__c oNode1_3_1 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_1.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_1;

        Organization_Node__c oNode1_3_2 = new Organization_Node__c(Organization__c = org1.Id, 
            User__c = user3_2.Id, Approval_Level__c = 3, Latitude_Level__c = 2000, 
            Manager_Organization_Node__c = oNode1_2.Id); 
        insert oNode1_3_2;
        
        // ORG 2
        Organization_Node__c oNode2_0 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode2_0;

        Organization_Node__c oNode2_1 = new Organization_Node__c(Organization__c = org2.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode2_0.Id); 
        insert oNode2_1;

        // ORG 3
        Organization_Node__c oNode3_0 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user0.Id, Approval_Level__c = 0, Latitude_Level__c = 5000); 
        insert oNode3_0;

        Organization_Node__c oNode3_1 = new Organization_Node__c(Organization__c = org3.Id, 
            User__c = user1.Id, Approval_Level__c = 1, Latitude_Level__c = 4000, 
            Manager_Organization_Node__c = oNode3_0.Id); 
        insert oNode3_1;
        
        // ORG 4
        // Nothing!
        
        System.runAs(u) {
        
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
            
            Canton__c canton = new Canton__c(name = 'Canton', INSEE_Code__c = '_____', Mandataire__c = mandataire1.id); 
            insert canton;
            City__c city   = new City__c(Name = 'City',  Canton__c = canton.Id, INSEE_Code__c = '_____'); 
            insert city;
            City_Postal_Code__c postalCode = new City_Postal_Code__c(Name = '123 - City', Postal_Code__c = '|||||', HEXAPOSTE_Code__c = '_____', City__c = city.Id, Code_Type__c = 'M');
            insert postalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = 'YYYY'); insert oDomain;
            
            
            // This one should get to user0 because of the Latitude Score
            Opportunity opty0 = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user3_1.Name + 'GEC 4500 3',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user3_1.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            
            // This one should get to user1 because of the Latitude Level
            Opportunity opty1 = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user3_1.Name + 'GEC 500 1',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user3_2.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            
            // This one should get to user2 because of both values
            Opportunity opty2 = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user3_1.Name + 'GEC 3000 2',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user3_2.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            
            // This one should stay at user3_1
            Opportunity opp3_1 = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user3_1.Name + 'GEC 2000 5',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user3_1.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            
            
            // This one should stay at user3_2
            Opportunity opp3_2 = new Opportunity(
                CloseDate=Date.today(), 
                Name='Opty' + user3_2.Name + 'GEC 1500 3',
                StageName='Prospecting', 
                //Market_Type__c = this.MT_DOM, 
                //City_In_Canton__c = this.City.Id,
                OwnerId = user3_2.Id,
                Assign__c = false,
                DO_Street_Name__c  = '123',
                DO_Street_type__c  = '123',
                DO_Activity_Domain__c = oDomain.Id,
                DO_City_Postal_Code__c = postalCode.Id,
                Project_City_Postal_Code__c = postalCode.Id
            );
            
            insert new List<Opportunity> { opty0, opty1, opty2, opp3_1, opp3_2 };
            
            
            Quote oQuote0 = new Quote(
                Name = 'Quote' + user3_1.Name + org1.Name + ' 4500 3',
                OpportunityId = opty0.Id,
                Latitude__c = 4500, Latitude_Level__c = 3,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote0.DO_Payment_method__c = 'V';
            oQuote0.Payment_spread__c = 'Z000';
            oQuote0.Contract_Duration__c = '5';
            
            
            Quote oQuote1 = new Quote( // Strict for Score, Exact for level
                Name = 'Quote' + user3_1.Name + org1.Name + ' 500 1',
                OpportunityId = opty1.Id,
                Latitude__c = 500, Latitude_Level__c = 1,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote1.DO_Payment_method__c = 'V';
            oQuote1.Payment_spread__c = 'Z000';
            oQuote1.Contract_Duration__c = '5';
            
            
            Quote oQuote2 = new Quote( // Exact for both
                Name = 'Quote' + user3_2.Name + org1.Name + ' 3000 2',
                OpportunityId = opty2.Id,
                Latitude__c = 3000, Latitude_Level__c = 2,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote2.DO_Payment_method__c = 'V';
            oQuote2.Payment_spread__c = 'Z000';
            oQuote2.Contract_Duration__c = '5';
            
            
            Quote oQuote3_1 = new Quote( // Exact for Score, Strict for Level
                Name = 'Quote' + user3_1.Name + org1.Name + ' 2000 5',
                OpportunityId = opp3_1.Id,
                Latitude__c = 2000, Latitude_Level__c = 5,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote3_1.DO_Payment_method__c = 'V';
            oQuote3_1.Payment_spread__c = 'Z000';
            oQuote3_1.Contract_Duration__c = '5';
            
            
            Quote oQuote3_2 = new Quote( // Strict for Score, Exact for Level
                Name = 'Quote' + user3_2.Name + org1.Name + ' 2000 5',
                OpportunityId = opp3_2.Id,
                Latitude__c = 2000, Latitude_Level__c = 5,
                T_Organization__c = org1.Id
            );
            // ORO: VR requirements
            oQuote3_2.DO_Payment_method__c = 'V';
            oQuote3_2.Payment_spread__c = 'Z000';
            oQuote3_2.Contract_Duration__c = '5';
            
            
            insert new List<Quote> { oQuote0, oQuote1, oQuote2, oQuote3_1, oQuote3_2 };
            
            oQuote0 = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote0.Id
            ];
            oQuote1 = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote1.Id
            ];
            oQuote2 = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote2.Id
            ];
            oQuote3_1 = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote3_1.Id
            ];
            oQuote3_2 = [SELECT 
                Name, Opportunity.OwnerId, Latitude__c, Latitude_Level__c, T_Organization__c,
                Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
                FROM Quote where Id = :oQuote3_2.Id
            ];
            
            
            Test.startTest();
            
            List<Quote> lQuotes = new List<Quote>{oQuote0, oQuote1, oQuote2, oQuote3_1, oQuote3_2};

            AP_ApprovalHierarchy_01.buildApproverChain(lQuotes);
            // No refresh is necessary, we didn't even commit the changes to the DB!

            //Quote0
            //System.assertEquals(bp.user3_1.Id, oQuote0.Approver0__c); // We don't put this user in anymore!
            System.assertEquals(user2.Id,   oQuote0.Approver0__c);
            System.assertEquals(user1.Id,   oQuote0.Approver1__c);
            System.assertEquals(user0.Id,   oQuote0.Approver2__c);
            System.assertEquals(null,          oQuote0.Approver3__c);
            System.assertEquals(null,          oQuote0.Approver4__c);

            //Quote1
            //System.assertEquals(bp.user3_2.Id, oQuote1.Approver0__c);
            System.assertEquals(user2.Id,   oQuote1.Approver0__c);
            System.assertEquals(user1.Id,   oQuote1.Approver1__c);
            System.assertEquals(null,          oQuote1.Approver2__c);

            //Quote2
            //System.assertEquals(bp.user3_2.Id, oQuote2.Approver0__c);
            System.assertEquals(user2.Id,   oQuote2.Approver0__c);
            System.assertEquals(null,          oQuote2.Approver1__c);
            System.assertEquals(null,          oQuote2.Approver2__c);
            System.assertEquals(null,          oQuote2.Approver3__c);

            //Quote3_1
            //System.assertEquals(bp.user3_1.Id, oQuote3_1.Approver0__c);
            System.assertEquals(null,          oQuote3_1.Approver0__c);
            System.assertEquals(null,          oQuote3_1.Approver1__c);
            System.assertEquals(null,          oQuote3_1.Approver2__c);
            System.assertEquals(null,          oQuote3_1.Approver3__c);

            //Quote3_2
            //System.assertEquals(bp.user3_2.Id, oQuote3_2.Approver0__c);
            System.assertEquals(null,          oQuote3_2.Approver0__c);
            System.assertEquals(null,          oQuote3_2.Approver1__c);
            System.assertEquals(null,          oQuote3_2.Approver2__c);
            System.assertEquals(null,          oQuote3_2.Approver3__c);
            
            // Let's update anyway, just to check it works.
            update lQuotes;
            

            Test.stopTest();   
        }   
    }
}