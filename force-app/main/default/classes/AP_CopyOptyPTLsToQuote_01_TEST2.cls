@isTest
private class AP_CopyOptyPTLsToQuote_01_TEST2 {

    public static testmethod void testCopyOnAddQuote(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testCopyOnAddQuote <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-1',Alias='COPTL01',
            Email='COPTL01-1@shell.com',Username='COPTL01-1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c1, c9, c10, c11, c12 };   

        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3
            );
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-1 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-1 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP1');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-1 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-1', Email__c = 'COPTL01-1@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'COPTL01 Mandataire',
                ExternalID__c = 'VOP01',
                Active__c = true
            );
            insert mand1;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;  

            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'COPTL01 City 2',
                Postal_Code__c = '09876',
                Code_AC_administrator_New__c = attCom50.Id
            );
            insert ptl1;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            //insert opp1;
            Opportunity opp2 = new Opportunity(Name = 'TestOpty 2', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            //insert opp2;
            insert new List<Opportunity> { opp1, opp2 };
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-1-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL1;
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-1-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL2;
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id,
                PTL__c = ptl1.id,
                PTL_Name__c = 'COPTL01-1-4',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL3;
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2, optyPTL3 };
            
            Test.startTest();
            List<Quote_PTL__c> lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(0, lQuotePTLS.size());
            
            Quote q1 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id);
            q1.DO_Payment_method__c = 'V';
            q1.Payment_Spread__c = 'Z000';
            insert q1;
            
            
            lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(3, lQuotePTLS.size());
            Set<Id> sOptyPTLIds = new Set<Id>();
            for (Quote_PTL__c oQuotePTL : lQuotePTLS){
                sOptyPTLIds.add(oQuotePTL.Opportunity_PTL__c);
                System.assertEquals(q1.Id, oQuotePTL.Quote__c);
            }
            System.assertEquals(new Set<Id>{optyPTL1.Id, optyPTL2.Id, optyPTL3.Id}, sOptyPTLIds);

            Test.stopTest();
            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testCopyOnAddQuote END <<<<<');
            
        }
    }

    public static testmethod void testRespectBypass(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testRespectBypass <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-2',Alias='COPTL02',
            Email='COPTL01-2@shell.com',Username='COPTL01-2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
          	//Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-2 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-2 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP2');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-2', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-2 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-2', Email__c = 'COPTL01-2@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
           	// New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
                );
            insert opp1;

            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-2-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-2-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-2-3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2, optyPTL3 };
            
            Test.startTest();
            List<Quote_PTL__c> lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(0, lQuotePTLS.size());
            
            Quote q1 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id, T_BypassPTLCopy__c = true);
            q1.DO_Payment_method__c = 'V';
            q1.Payment_Spread__c = 'Z000';
            insert q1;
            
            
            lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(0, lQuotePTLS.size());

            Test.stopTest();
            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testRespectBypass END <<<<<');
            
        }
    }

    public static testmethod void testIndependentCopyOnAddQuote(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testIndependentCopyOnAddQuote <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-3',Alias='COPTL03',
            Email='COPTL01-3@shell.com',Username='COPTL01-3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-3 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-3 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP3');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-3', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01003', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-3 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-3', Email__c = 'COPTL01-3@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            Opportunity opp2 = new Opportunity(Name = 'TestOpty 2', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            Opportunity opp3 = new Opportunity(Name = 'TestOpty 3', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert new List<Opportunity> { opp1, opp2, opp3 };
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL21 = new Opportunity_PTL__c(
                Opportunity__c = opp2.Id, 
                PTL_Name__c = 'COPTL01-3-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL31 = new Opportunity_PTL__c(
                Opportunity__c = opp3.Id, 
                PTL_Name__c = 'COPTL01-3-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL32 = new Opportunity_PTL__c(
                Opportunity__c = opp3.Id, 
                PTL_Name__c = 'COPTL01-3-3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert new List<Opportunity_PTL__c> { optyPTL21, optyPTL31, optyPTL32 };
            
            Test.startTest();
            
            Quote oQuote1 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id);
            oQuote1.DO_Payment_method__c = 'V';
            oQuote1.Payment_Spread__c = 'Z000';
            insert oQuote1 ;
            
            System.assertEquals(0, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());
            Quote oQuote2 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp2.Id);
            oQuote2.DO_Payment_method__c = 'V';
            oQuote2.Payment_Spread__c = 'Z000';
            insert oQuote2;
            System.assertEquals(1, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Quote oQuote3 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp3.Id);
            oQuote3.DO_Payment_method__c = 'V';
            oQuote3.Payment_Spread__c = 'Z000';
            insert oQuote3;
            System.assertEquals(3, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Test.stopTest();
            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testIndependentCopyOnAddQuote END <<<<<');
            
        }
    }

    public static testmethod void testNoCopyOnLockedQuote(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testNoCopyOnLockedQuote <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-4',Alias='COPTL04',
            Email='COPTL01-4@shell.com',Username='COPTL01-4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-4 Canton', INSEE_Code__c = '-_-_', Mandataire__c =mandataire1.id );
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-4 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP4');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-4', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01004', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-4 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-4', Email__c = 'COPTL01-4@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert opp1;
            
            Quote oQuote = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id, T_LAT_ApprovalRequested__c = false);
            oQuote.DO_Payment_method__c = 'V';
            oQuote.Payment_Spread__c = 'Z000'; 
            insert oQuote;
            
            Test.startTest();
            
            System.assertEquals(0, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
            insert attCom50;
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-4-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;

            System.assertEquals(1, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());
            oQuote.T_LAT_ApprovalRequested__c = true; // Emulate the behavior of the Approval Process

            update oQuote;

            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-4-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL2;
            System.assertEquals(1, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Test.stopTest();

            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testNoCopyOnLockedQuote END <<<<<');
        }
    }

    public static testmethod void testCopyOnAddOptyPTL(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testCopyOnAddOptyPTL <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-5',Alias='COPTL05',
            Email='COPTL01-5@shell.com',Username='COPTL01-5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-5 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-5 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP5');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-5', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01005', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-5 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-5', Email__c = 'COPTL01-5@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert opp1;
            
            Quote oQuote = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id);
            oQuote.DO_Payment_method__c = 'V';
            oQuote.Payment_Spread__c = 'Z000';
            insert oQuote;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;

            Test.startTest();
            List<Quote_PTL__c> lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(0, lQuotePTLS.size());
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-5-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-5-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-5-3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2, optyPTL3 };

            lQuotePTLS = [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c];
            System.assertEquals(3, lQuotePTLS.size());
            Set<Id> sOptyPTLIds = new Set<Id>();
            for (Quote_PTL__c oQuotePTL : lQuotePTLS){
                sOptyPTLIds.add(oQuotePTL.Opportunity_PTL__c);
                System.assertEquals(oQuote.Id, oQuotePTL.Quote__c);
            }
            System.assertEquals(new Set<Id>{optyPTL1.Id, optyPTL2.Id, optyPTL3.Id}, sOptyPTLIds);

            Test.stopTest();

            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testCopyOnAddOptyPTL END <<<<<');
        }
    }

    public static testmethod void testIndependentCopyOnAddOptyPTL(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testIndependentCopyOnAddOptyPTL <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-6',Alias='COPTL06',
            Email='COPTL01-6@shell.com',Username='COPTL01-6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        	
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-6 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-6 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP6');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-6', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01006', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-6 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-6', Email__c = 'COPTL01-6@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
           	// New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'COPTL01 Mandataire',
                ExternalID__c = 'VOP06',
                Active__c = true
            );
            insert mand1;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'COPTL01 City 6',
                Postal_Code__c = '09876',
                Code_AC_administrator_New__c = attCom50.Id
            );
            insert ptl1;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            Opportunity opp2 = new Opportunity(Name = 'TestOpty 2', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            Opportunity opp3 = new Opportunity(Name = 'TestOpty 3', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert new List<Opportunity> { opp1, opp2, opp3 };
            
            Quote oQuote21 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp2.Id);
            oQuote21.DO_Payment_method__c = 'V';
            oQuote21.Payment_Spread__c = 'Z000';
            Quote oQuote31 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp3.Id);
            oQuote31.DO_Payment_method__c = 'V';
            oQuote31.Payment_Spread__c = 'Z000';
            Quote oQuote32 = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp3.Id);
            oQuote32.DO_Payment_method__c = 'V';
            oQuote32.Payment_Spread__c = 'Z000';
            insert new List<Quote>{oQuote21, oQuote31, oQuote32};
            
            Test.startTest();

            // Test that unwanted PTLs are not inserted and that wanted PTLs are 
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-6-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;
            System.assertEquals(0, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = opp2.Id, 
                PTL_Name__c = 'COPTL01-5-2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL2;
            System.assertEquals(1, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = opp3.Id, 
                PTL_Name__c = 'COPTL01-5-3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL__c = ptl1.id,
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL3;
            System.assertEquals(3, [SELECT Id, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c].size());

            Test.stopTest();

            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testIndependentCopyOnAddOptyPTL END <<<<<');
        }
    }

    @isTest
    public static void testSetRTOnAddOptyPTL(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testSetRTOnAddOptyPTL <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-6',Alias='COPTL07',
            Email='COPTL01-7@shell.com',Username='COPTL01-7@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-7 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-7 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP7');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-7', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01006', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='COPTL01-7 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-7', Email__c = 'COPTL01-7@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(LastName='COPTL01-7', accountId = a.id, email = 'COPTL01-7c@test.com');
            //insert c;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert opp1;
            
            
            Quote oQuote = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id);
            oQuote.Payment_Spread__c = 'Z000';
            oQuote.contactid = c.id;
            oQuote.DO_Payment_method__c = 'V';
            insert oQuote;
            Opportunity_PTL__c oOptyPTL;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;

            Test.startTest();

            Quote_PTL__c oQuotePTL;
            for (RecordTypes_OpportunityToQuote__c oRTAssociation : RecordTypes_OpportunityToQuote__c.getAll().values()){
                oQuote.RecordTypeId = oRTAssociation.QuoteRecordType__c;
                update oQuote;

                Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                    Opportunity__c = opp1.Id, 
                    PTL_Name__c = 'COPTL01-7-1',
                    PTL_Street_Type__c = '456',
                    PTL_Street_Name__c = '789',
                    PTL_City_Postal_Code__c = cityCP.Id,
                    Code_AC_administrator_New__c = attCom50.Id,
                    Code_marche__c =  'P100'
                );
                insert optyPTL1;
                oQuotePTL  = [
                    SELECT Id, Quote__c, Opportunity_PTL__c, RecordTypeId 
                    FROM Quote_PTL__c 
                    WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id
                ];
                System.assertEquals(oRTAssociation.QuotePTLRecordType__c, oQuotePTL.RecordTypeId);
            }

            Test.stopTest();

            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testSetRTOnAddOptyPTL END <<<<<');
        }
    }

    @isTest
    public static void testSetRTOnAddQuote(){
        
        System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testSetRTOnAddQuote <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='COPTL01-8',Alias='COPTL08',
            Email='COPTL01-8@shell.com',Username='COPTL01-8@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'COPTL01-8 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'COPTL01-8 City',  Canton__c = Canton1.Id, INSEE_Code__c = 'COP8');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - COPTL01-8', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01008', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='COPTL01-8 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'COPTL01-8', Email__c = 'COPTL01-8@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Opportunity opp1 = new Opportunity(Name = 'TestOpty 1', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = ''
            );
            insert opp1;
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'COPTL01-7-1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );
            insert optyPTL1;
            
            
            Quote oQuote;
            Quote_PTL__c oQuotePTL;
            
            
            Test.startTest();

            for (RecordTypes_OpportunityToQuote__c oRTAssociation : RecordTypes_OpportunityToQuote__c.getAll().values()){
                oQuote = new Quote(Name = 'C',Contract_Duration__c = '5', opportunityId = opp1.Id);
                oQuote.Payment_Spread__c = 'Z000';
                oQuote.DO_Payment_method__c = 'C';
                oQuote.RecordTypeId = oRTAssociation.QuoteRecordType__c;
                oQuote.Product_Scale__c = 'TEST';
                insert oQuote;

                oQuotePTL  = [
                    SELECT Id, Quote__c, Opportunity_PTL__c, RecordTypeId 
                    FROM Quote_PTL__c 
                    WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id
                ];
                System.assertEquals(oRTAssociation.QuotePTLRecordType__c, oQuotePTL.RecordTypeId);
            }
            Test.stopTest();

            System.Debug('### >>>>> testing class AP_CopyOptyPTLsToQuote_01_Test.testSetRTOnAddQuote END <<<<<');
        }
    }
}