@isTest
private class VFC_CloneQuote_01_TEST2 {

    public static testmethod void testQuoteCloned(){
        
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQuoteCloned <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCCQ1',Alias='VFCCQ1',
            Email='VFCCQ1@shell.com',Username='VFCCQ1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123',Mandataire__c=mandataire1.id );
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', 
                City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            Opportunity oOpty = new Opportunity(
                name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id, T_Pack__c = ''
            );
            insert oOpty;
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
            //ORO 140828 - Test Method update
            initialQuote.DO_Payment_method__c = 'C';
            initialQuote.Payment_spread__c = 'Z000';
            initialQuote.Contract_Duration__c = '5';
            insert initialQuote;
            
            // Check that we have one quote
            List<Quote> lQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :oOpty.Id];
            System.assertEquals(1, lQuotes.size());
            
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(initialQuote);
            VFC_CloneQuote_01 controller = new VFC_CloneQuote_01(stdController);
            controller.CloneQuote();

            // Test that we did clone
            lQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :oOpty.Id];
            System.assertEquals(2, lQuotes.size());
            Test.stopTest();
        }
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQuoteCloned END<<<<<');
    }

    public static testmethod void testQuotePTLsCloned(){
        
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQuotePTLsCloned <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCCQ2',Alias='VFCCQ2',
            Email='VFCCQ2@shell.com',Username='VFCCQ2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123', Mandataire__c = mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', 
                City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            Opportunity oOpty = new Opportunity(
                name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id, T_Pack__c = ''
            );
            insert oOpty;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'
            );
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'
            );
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2 };
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
            //ORO 140828 - Test Method update
            initialQuote.DO_Payment_method__c = 'C';
            initialQuote.Payment_spread__c = 'Z000';
            initialQuote.Contract_Duration__c = '5';
            insert initialQuote;
            
            List<Opportunity_PTL__c> lPTLS = [SELECT Id FROM Opportunity_PTL__c WHERE Opportunity__c = :oOpty.Id];
            List<Quote_PTL__c> lQPTLS = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id];
            System.assertEquals(2, lPTLS.size());
            System.assertEquals(2, lQPTLS.size());

            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(initialQuote);
            VFC_CloneQuote_01 controller = new VFC_CloneQuote_01(stdController);
            controller.CloneQuote();
            Quote newQuote = controller.getNewQuote();
            lQPTLS = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :newQuote.Id];
            System.assertEquals(2, lQPTLS.size());
            Test.stopTest();
        }
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQuotePTLsCloned END <<<<<');
    }

    public static testmethod void testQLICloned(){
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQLICloned <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCCQ3',Alias='VFCCQ3',
            Email='VFCCQ3@shell.com',Username='VFCCQ3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
        

            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;        
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123',Mandataire__c = mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', 
                City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            Opportunity oOpty = new Opportunity(
                name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id, T_Pack__c = ''
            );
            insert oOpty;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'

            );
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'

            );
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2 };
            
            Id pb2StandardId = Test.getStandardPricebookId();
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
            //ORO 140828 - Test Method update
            initialQuote.DO_Payment_method__c = 'C';
            initialQuote.Payment_spread__c = 'Z000';
            initialQuote.Contract_Duration__c = '5';
            initialQuote.Pricebook2Id = pb2StandardId;
            insert initialQuote;
            
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            
            Product2 oProduct1 = new Product2(Name = 'p1'); 
            Product2 oProduct2 = new Product2(Name = 'p2');
            insert new List<Product2> {oProduct1, oProduct2};
            
            PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb2StandardId, Product2Id = oProduct1.Id, IsActive = true, UnitPrice = 1); 
            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb2StandardId, Product2Id = oProduct2.Id, IsActive = true, UnitPrice = 1); 
            insert new List<PricebookEntry> {pbe1, pbe2};
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbe1.Id, Quote_PTL__c = oQPTL1.Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbe2.Id, Quote_PTL__c = oQPTL2.Id)
            };
            insert lQLI;
            
            lQLI = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :initialQuote.Id];
            System.assertEquals(2, lQLI.size());
            
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(initialQuote);
            VFC_CloneQuote_01 controller = new VFC_CloneQuote_01(stdController);
            controller.CloneQuote();
            Quote newQuote = controller.getNewQuote();
            Test.stopTest();

            // Check the Quote PTLs have been copied
            lQLI = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :newQuote.Id];
            System.assertEquals(2, lQLI.size());

            // Check the QLI are properly associated with the new Quote PTLs.
            QuoteLineItem QLI1 = [SELECT Id, Quote_PTL__r.Opportunity_PTL__c FROM QuoteLineItem WHERE QuoteId = :newQuote.Id AND PricebookEntryId = :pbe1.Id];
            QuoteLineItem QLI2 = [SELECT Id, Quote_PTL__r.Opportunity_PTL__c FROM QuoteLineItem WHERE QuoteId = :newQuote.Id AND PricebookEntryId = :pbe2.Id];
            System.assertEquals(optyPTL1.Id, QLI1.Quote_PTL__r.Opportunity_PTL__c);
            System.assertEquals(optyPTL2.Id, QLI2.Quote_PTL__r.Opportunity_PTL__c);
        } 
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQLICloned END <<<<<'); 
    }

    public static testmethod void testLatitudeWorkflow(){
        System.Debug('### >>>>> testing class VFC_CloneQuote_01_TEST2.testQLICloned <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCCQ3',Alias='VFCCQ3',
            Email='VFCCQ3@shell.com',Username='VFCCQ3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
           //Mandataire
           Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123',Mandataire__c = mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', 
                City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            Opportunity oOpty = new Opportunity(
                name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id, T_Pack__c = ''
            );
            insert oOpty;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'

            );
            insert optyPTL1;
            
            // Add a Quote (1 PTL), then prevent adding more PTLs
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
            //ORO 140828 - Test Method update
            initialQuote.DO_Payment_method__c = 'C';
            initialQuote.Payment_spread__c = 'Z000';
            initialQuote.Contract_Duration__c = '5';
            insert initialQuote;
            
            initialQuote.T_LAT_ApprovalRequested__c = true;
            update initialQuote;
            
            // Should not be added to the Quote
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'

            );
            insert optyPTL2;

            List<Quote_PTL__c> lQPTLS = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id];
            System.assertEquals(1, lQPTLS.size());

            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(initialQuote);
            VFC_CloneQuote_01 controller = new VFC_CloneQuote_01(stdController);
            controller.CloneQuote();
            Quote newQuote = controller.getNewQuote();
            Test.stopTest();

            // New Quote should still have TWO PTLs!
            lQPTLS = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :newQuote.Id];
            System.assertEquals(2, lQPTLS.size());
            
        }   
    }
}