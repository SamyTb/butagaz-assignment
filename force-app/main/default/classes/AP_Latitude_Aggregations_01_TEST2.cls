@isTest
private class AP_Latitude_Aggregations_01_TEST2 {

    public static testmethod void testAggregatePTL(){
        
        System.Debug('### >>>>> testing class AP_Latitude_Aggregations_01_Test.testAggregatePTL <<<<<');
        
        // Are the aggregations calculated?
   
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APLA1',Alias='APLA1',
            Email='APLA1@shell.com',Username='APLA1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APLA1 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APLA1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APLA1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APLA1 ', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APLA1City', Email__c = 'APLA1City@test.org',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            //insert c;
            
       
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;           
            
            
            Opportunity oOpty = new Opportunity(Name = 'APLA1', AccountId = a.Id, Assign__c = false, 
                StageName = 'OK', CloseDate = Date.today(), Project_City_Postal_Code__c = cityCP.Id, T_Pack__c = ''); 
            insert oOpty;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'

            );
            insert optyPTL1;
            
            Quote oQuote = new Quote(
                Name = 'PQR', 
                OpportunityId = oOpty.Id,
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c = 'C',
                Contract_Duration__c = '5'
                );
            insert oQuote;
            
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id];
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 3, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 5, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, Quote_PTL__c = oQPTL1.Id)
            };
            
            Test.startTest();
            
            List<AP_Latitude_Aggregations_01.LatitudeAggregation> lAggregations = new List<AP_Latitude_Aggregations_01.LatitudeAggregation>{
                new AP_Latitude_Aggregations_01.LatitudeAggregation('RCE_Rebate_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c')
            };
            AP_Latitude_Aggregations_01.LatitudeAggregator oAggregator = new AP_Latitude_Aggregations_01.LatitudeAggregator('Quote_PTL__c', 'QuoteLineItem', 'Quote_PTL__c', lAggregations);
            List<SObject> lPTLs = oAggregator.aggregate(lQLI);
            Quote_PTL__c actualPTL = (Quote_PTL__c) lPTLS.get(0);
            System.assertEquals(oQPTL1.Id, actualPTL.Id);
            System.assertEquals(11, actualPTL.T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c);
            
            Test.stopTest();
        }
    }

    public static testmethod void testControlFields(){
        
        System.Debug('### >>>>> testing class AP_Latitude_Aggregations_01_Test.testAggregatePTL <<<<<');
        // Are control fields taken into account?
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APLA2',Alias='APLA2',
            Email='APLA2@shell.com',Username='APLA2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;    
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APLA1 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id );
            insert Canton1;
            City__c City1  = new City__c (Name = 'APLA1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APLA1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APLA1 ', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APLA1City', Email__c = 'APLA1City@test.org',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            // Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            // insert c;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;     
            
            
            Opportunity oOpty = new Opportunity(Name = 'APLA1', AccountId = a.Id, Assign__c = false, 
                StageName = 'OK', CloseDate = Date.today(), Project_City_Postal_Code__c = cityCP.Id, T_Pack__c = ''); 
            insert oOpty;
            
            Attache_Commercial__c attCom51 = new Attache_Commercial__c(Name='attCom51', Code_Groupe_Vendeur__c='501');
			insert attCom51;   

            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom51.Id,
				Code_marche__c =  'P100'

            );
            insert optyPTL1;
            
            Quote oQuote = new Quote(
                Name = 'PQR', 
                OpportunityId = oOpty.Id,
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c = 'C',
                Contract_Duration__c = '5'
                );
            insert oQuote;
            
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id];
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 3, RCE_Rebate_HT__c = 1, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 5, RCE_Rebate_HT__c = 0, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, RCE_Rebate_HT__c = 0, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, RCE_Rebate_HT__c = 1, Quote_PTL__c = oQPTL1.Id)
            };

            
            Test.startTest();
            
            List<AP_Latitude_Aggregations_01.LatitudeAggregation> lAggregations = new List<AP_Latitude_Aggregations_01.LatitudeAggregation>{
                new AP_Latitude_Aggregations_01.LatitudeAggregation('RCE_Rebate_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c', 'RCE_Rebate_HT__c')
            };
            AP_Latitude_Aggregations_01.LatitudeAggregator oAggregator = new AP_Latitude_Aggregations_01.LatitudeAggregator('Quote_PTL__c', 'QuoteLineItem', 'Quote_PTL__c', lAggregations);
            List<SObject> lPTLs = oAggregator.aggregate(lQLI);
            Quote_PTL__c actualPTL = (Quote_PTL__c) lPTLS.get(0);
            System.assertEquals(oQPTL1.Id, actualPTL.Id);
            System.assertEquals(5, actualPTL.T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c);
            Test.stopTest();
        }
    }

    public static testmethod void testNoConflicts(){
        
        System.Debug('### >>>>> testing class AP_Latitude_Aggregations_01_Test.testAggregatePTL <<<<<');
        // Can several inserts at once be supported?
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APLA3',Alias='APLA3',
            Email='APLA3@shell.com',Username='APLA3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
                    
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APLA1 Canton', INSEE_Code__c = '-_-_',Mandataire__c= mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APLA1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APLA1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APLA1 ', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APLA1City', Email__c = 'APLA1City@test.org',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            //insert c;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;                
            
            
            Opportunity oOpty = new Opportunity(Name = 'APLA1', AccountId = a.Id, Assign__c = false, 
                StageName = 'OK', CloseDate = Date.today(), Project_City_Postal_Code__c = cityCP.Id, T_Pack__c = ''); 
            insert oOpty;
            
            Attache_Commercial__c attCom52 = new Attache_Commercial__c(Name='attCom52', Code_Groupe_Vendeur__c='502');
			insert attCom52;   

            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom52.Id,
				Code_marche__c =  'P100'
                
            );
            

            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom52.Id,
				Code_marche__c =  'P100'

            );
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom52.Id,
				Code_marche__c =  'P100'
            );
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2, optyPTL3 };
            
            Quote oQuote = new Quote(
                Name = 'PQR', 
                OpportunityId = oOpty.Id,
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c = 'C',
                Contract_Duration__c = '5'
                );
            insert oQuote;
            
            Quote_PTL__c expectedPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c expectedPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            Quote_PTL__c expectedPTL3 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id AND Opportunity_PTL__c = :optyPTL3.Id];
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, Quote_PTL__c = expectedPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, Quote_PTL__c = expectedPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 3, Quote_PTL__c = expectedPTL2.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 4, Quote_PTL__c = expectedPTL2.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 5, Quote_PTL__c = expectedPTL3.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 6, Quote_PTL__c = expectedPTL3.Id)
            };

            
            Test.startTest();
            List<AP_Latitude_Aggregations_01.LatitudeAggregation> lAggregations = new List<AP_Latitude_Aggregations_01.LatitudeAggregation>{
                new AP_Latitude_Aggregations_01.LatitudeAggregation('RCE_Rebate_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c')
            };
            AP_Latitude_Aggregations_01.LatitudeAggregator oAggregator = new AP_Latitude_Aggregations_01.LatitudeAggregator('Quote_PTL__c', 'QuoteLineItem', 'Quote_PTL__c', lAggregations);
            List<SObject> lPTLs = oAggregator.aggregate(lQLI);
            update lPTLs;

            Map<Id, Decimal> expectedValues = new Map<Id, Decimal>{
                expectedPTL1.Id => 3.0,
                expectedPTL2.Id => 7.0,
                expectedPTL3.Id => 11.0
            };

            Integer runs = 0;
            for (Quote_PTL__c oQPTL : new List<Quote_PTL__c>{expectedPTL1, expectedPTL2, expectedPTL3}){
                oQPTL = [SELECT Id, T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c FROM Quote_PTL__c WHERE Id = :oQPTL.Id];
                runs++;
                System.assertEquals(expectedValues.get(oQPTL.Id), oQPTL.T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c);
            }

            System.assertEquals(3, runs);
            Test.stopTest();
        }
    }

    public static testmethod void testPreExistingObjects(){
        //(seeAllData = true)
        System.Debug('### >>>>> testing class AP_Latitude_Aggregations_01_Test.testAggregatePTL <<<<<');
        
         // Are preexisting objects taken into account
   
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APLA4',Alias='APLA4',
            Email='APLA4@shell.com',Username='APLA4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APLA1 Canton', INSEE_Code__c = '-_-_', Mandataire__c =  mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APLA1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APLA1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APLA1 ', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APLA1City', Email__c = 'APLA1City@test.org',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           	// Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
           	// insert c;
           
           
          	// New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;              
            
            Opportunity oOpty = new Opportunity(Name = 'APLA1', AccountId = a.Id, Assign__c = false, 
                StageName = 'OK', CloseDate = Date.today(), Project_City_Postal_Code__c = cityCP.Id, T_Pack__c = ''); 
            insert oOpty;
            
            Attache_Commercial__c attCom53 = new Attache_Commercial__c(Name='attCom53', Code_Groupe_Vendeur__c='503');
			insert attCom53;   

            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'APLA1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom53.Id,
				Code_marche__c =  'P100'

            );
            insert optyPTL1;
            
            Quote oQuote = new Quote(
                Name = 'PQR', 
                OpportunityId = oOpty.Id,
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c = 'C',
                Contract_Duration__c = '5'
                );
            insert oQuote;
            
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :oQuote.Id];
            
            Id pb = Test.getStandardPricebookId();
            oQuote.Pricebook2Id = pb;
            update oQuote;
            Product2 oProduct = new Product2(Name = '34'); insert oProduct;
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb, Product2Id = oProduct.Id, IsActive = true, UnitPrice = 1); insert pbe;

            List<QuoteLineItem> lQLI1 = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, Quote_PTL__c = oQPTL1.Id, QuoteId = oQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, Quote_PTL__c = oQPTL1.Id, QuoteId = oQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe.Id)
            };
            insert lQLI1;
            
            Test.startTest();
            
            oQPTL1 = [SELECT Id, T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c FROM Quote_PTL__c WHERE Id =:oQPTL1.Id];
            System.assertEquals(oQPTL1.T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c, 3); // Test the trigger, while we're at it...

            List<QuoteLineItem> lQLI2 = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 3, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 4, Quote_PTL__c = oQPTL1.Id)
            };

            List<AP_Latitude_Aggregations_01.LatitudeAggregation> lAggregations = new List<AP_Latitude_Aggregations_01.LatitudeAggregation>{
                new AP_Latitude_Aggregations_01.LatitudeAggregation('RCE_Rebate_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c')
            };
            AP_Latitude_Aggregations_01.LatitudeAggregator oAggregator = new AP_Latitude_Aggregations_01.LatitudeAggregator('Quote_PTL__c', 'QuoteLineItem', 'Quote_PTL__c', lAggregations);
            List<SObject> lPTLs = oAggregator.aggregate(lQLI2);
        
            Quote_PTL__c actualPTL = (Quote_PTL__c) lPTLS.get(0);
            System.assertEquals(oQPTL1.Id, actualPTL.Id);
            System.assertEquals(10, actualPTL.T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c);
            Test.stopTest();
        }
    }
}