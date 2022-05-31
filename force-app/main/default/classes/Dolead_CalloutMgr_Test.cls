@isTest
public class Dolead_CalloutMgr_Test {
    
    @testSetup static void setupData(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts', value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='TrackRestAPICalls', value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key', value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv', value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB', value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC', value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c1, c2, c9, c10, c11, c12 };
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert new List<Activity_Domain__c> { AD_GEC };

        RecordType rtLead = [SELECT Id, Name FROM RecordType WHERE SobjectType='Lead' AND DeveloperName='Lead' LIMIT 1];
        //RecordType rtAccountGECDOM = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = '999',
            Active__c = true
        );
        insert mand1;
        
        Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
        insert Canton1;
        City__c City1 = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;

        Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
		insert attCom;

        Id pb2StandardId = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
        insert pbk1;
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
        
        Lead l1 = new Lead(
            LastName = 'LNameGEC1',
            FirstName = 'FNameGEC1',
            LeadSource = 'Dolead',
            Account_Country__c = 'FR', 
            Phone = '0202020202',
            Account_Street_Type__c = 'Rue',
            Account_Street_Name__c = 'Brestoise',  
            Account_City_Postal_Code__c = cityCP.Id,
            Project_City_Postal_Code__c = cityCP.Id,
            Activity_Domain__c = AD_GEC.Id,
            RecordTypeId = rtLead.Id,
            Assign__c = False,
            ExternalId__c = 'Dolead1',
            Market_Sub_Type__c = 'Domestique'
        );
        Lead l2 = new Lead(
            LastName = 'LNameGEC2',
            FirstName = 'FNameGEC2',
            LeadSource = 'Dolead',
            Account_Country__c = 'FR', 
            Phone = '0202020202',
            Account_Street_Type__c = 'Rue',
            Account_Street_Name__c = 'Brestoise',  
            Account_City_Postal_Code__c = cityCP.Id,
            Project_City_Postal_Code__c = cityCP.Id,
            Activity_Domain__c = AD_GEC.Id,
            RecordTypeId = rtLead.Id,
            Assign__c = False,
            ExternalId__c = 'Dolead2',
            Market_Sub_Type__c = 'Domestique'
        );
        Lead l3 = new Lead(
            LastName = 'LNameGEC3',
            FirstName = 'FNameGEC3',
            LeadSource = 'Dolead',
            Account_Country__c = 'FR', 
            Phone = '0202020202',
            Account_Street_Type__c = 'Rue',
            Account_Street_Name__c = 'Brestoise',  
            Account_City_Postal_Code__c = cityCP.Id,
            Project_City_Postal_Code__c = cityCP.Id,
            Activity_Domain__c = AD_GEC.Id,
            RecordTypeId = rtLead.Id,
            Assign__c = False,
            ExternalId__c = 'Dolead3',
            Market_Sub_Type__c = 'Domestique'
        );
        insert new List<Lead> { l1, l2, l3 };
        
        Account accMainOwner = new Account(
            FirstName = 'FName1', 
            LastName = 'LName1', 
            Market_Type__c = 'DOM', 
            Activity_Domain__c = AD_GEC.Id, 
            /*Postal_Code__c = '123', 
            City__c = 'VFCQLI01City',*/ 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'VFCQLI01City@test.org', 
            //Mobile_Phone_Number__c = '+33616060606',
            Mobile_Phone_Number__c = '0616060606',
            Country__c = 'FR',
            Indicatif_Pays__c = '+33',
            channel__c = 'CD',
            accountNumber = '12345',
            Mandataire__c = mand1.Id,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
            Lead_ExternalID__c = 'CMP1234567'
        );
        insert new List<Account> { accMainOwner };
        
        // Add an Opty
        Opportunity oOptyOwner = new Opportunity(
            Name = 'TestOptyOwner',
            Project_Type__c = 'CREA', 
            DO_Activity_Domain__c = AD_GEC.Id,
            StageName = 'Status3', 
            AccountId = accMainOwner.Id, 
            DO_AccountNumber__c = accMainOwner.accountNumber,
            CloseDate = Date.today(), 
            Project_City_Postal_Code__c = cityCP.Id, 
            DO_City_Postal_Code__c = cityCP.Id, 
            Assign__c = false, 
            OwnerId = u.id,
            DO_Payment_method__c = 'V', 
            Installation_date__c = Date.today() + 15,
            T_Pack__c = 'IDEO',
            Client_Type__c = 'Owner',
            Energy_Source__c = 'TestEnergy',
            Project_market_type__c = 'DOM',
            Avez_vous_votre_Kbis__c = 'Oui',
            LeadSource = 'Dolead'
        );
        insert new List<Opportunity> { oOptyOwner };
        
        List <Opportunity_PTL__c > optlList = new List < Opportunity_PTL__c > ();
        // Add Opty PTLs
        Opportunity_PTL__c optyPTLOwner1 = new Opportunity_PTL__c(
            Opportunity__c = oOptyOwner.Id, 
            PTL_Name__c = 'VFC06PS1',
            PTL_Street_Type__c = '456',
            PTL_Street_Name__c = '789',
            PTL_City_Postal_Code__c = cityCP.Id,
            Code_AC_administrator_New__c = attCom.Id
        );
        optlList.add(optyPTLOwner1);
        insert optlList;

        // Products
        List<Product2> prdList1 = new List<Product2>();
            
        Product2 oProduct1 = new Product2(Name = 'p1',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12345', is_crea__c = true, Tank_Type__c = 'A'); 
        Product2 oProduct2 = new Product2(Name = 'p2',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12346', is_crea__c = true, Tank_Type__c = 'A');
        Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c = '904P0001',isactive = true,Family = 'Produit', ProductCode = '904P0001', is_crea__c = true);
        Product2 oProduct6 = new Product2(Name = '000000000000000440',external_ID__c = '000000000000000440',isactive = true,Family = 'Produit', ProductCode = '000000000000000440', is_crea__c = true);
        prdList1.add(oProduct1);
        prdList1.add(oProduct2);
        
        prdList1.add(oProduct5);
        prdList1.add(oProduct6);
        
        //insert prdList;
        insert prdList1;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for (Product2 prd: prdList1) {                
            PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            pbeList.add(pbe);
            pbeList.add(pbe2);
        }
        insert pbeList;
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (7) : ' + Limits.getQueries());
        
        pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];

        List<Quote> quoteList = new List<Quote>();
        Quote QuoteOwner = new Quote(
            OpportunityId = oOptyOwner.Id,
            Name='QuoteOwner', 
            DO_Payment_method__c = 'P',
            Payment_spread__c = 'Z010',
            Contract_Duration__c = '5',
            Pricebook2Id = pbk1.id,
            ExpirationDate = Date.today() + 10,
            Date_de_cotation__c = Date.today(),
            Date_debut_offre__c = Date.today(),
            Product_Scale__c = 'CART1',
            Scale__c = 'OC',
            Ger_Consumption__c='B4',
            //ContactId = c.id,
            Client_Reenlistment__c = 'Contract',
            T_LAT_Approved__c = true,
            Shipping_Condition__c = '01',
            VAT_code__c = '1'
        );
        quoteList.add(QuoteOwner);
        insert quoteList;

        // QPTL
        Quote_PTL__c oQPTLOwner1 = new Quote_PTL__c();
            
        List<Quote_PTL__c> qptlList = [SELECT Id, Name, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c WHERE Quote__c = :quoteList AND Opportunity_PTL__c = :optlList];
        for (Quote_PTL__c oqptl: qptlList) {
            if(oqptl.Quote__c == QuoteOwner.Id && oqptl.Opportunity_PTL__c == optyPTLOwner1.Id){
              oQPTLOwner1 = oqptl;
            }
        }
        
        // QLI
        List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
            // QLI QuoteOwner
              new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteOwner.Id, Quantity = 1, 
                  UnitPrice = 1, PricebookEntryId = pbeList[0].Id, IsTank__c = true,
                  Quote_PTL__c = oQPTLOwner1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
              ),
              new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteOwner.Id, Quantity = 1, 
                  UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                  Quote_PTL__c = oQPTLOwner1.Id,Got_From_SAP__c=true
              )
        }; 
        insert lQLI;

    }
    
    static testMethod void testCalloutLeadContacted() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"result":"success","details":{"success":[{"finder":{"lead_id":"Dolead1","customer_id":111},"setter":{"customer_sale":false,"customer_sale_fail_reason":"other"},"lead_id":"Dolead1"}],"failure":[]}}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead oLead = [SELECT Id, ExternalID__c, Status FROM Lead WHERE ExternalId__c = 'Dolead1' LIMIT 1];

        // Create activity
        if(oLead != null){
            List<Task> tasks = new List<Task>();
            tasks.add(new Task(
                ActivityDate = Date.today(),
                Subject='First Activity',
                WhoId = oLead.Id,
                Status='Completed')
            );
            insert tasks;
        }
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Dolead_CalloutMgr.callDoleadCustomerConversionsWS(oLead.Id, oLead.ExternalID__c, oLead.Status);
        
        // Verify response received contains fake values
        /*String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());*/
        
        Test.stopTest();
    }
    
    static testMethod void testCalloutLeadAbandoned() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"result":"success","details":{"success":[{"finder":{"lead_id":"Dolead2","customer_id":111},"setter":{"customer_sale":false,"customer_sale_fail_reason":"other"},"lead_id":"Dolead2"}],"failure":[]}}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);

        Lead oLead = [SELECT Id, ExternalID__c, Status FROM Lead WHERE ExternalId__c = 'Dolead2' LIMIT 1];
        
        if(oLead != null){
            oLead.Status = 'Abandoned';
            update oLead;
        }

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Dolead_CalloutMgr.callDoleadCustomerConversionsWS(oLead.Id, oLead.ExternalID__c, oLead.Status);
        
        
        Test.stopTest();
    }

    static testMethod void testCalloutLeadConverted() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"result":"success","details":{"success":[{"finder":{"lead_id":"Dolead3","customer_id":111},"setter":{"customer_sale":false,"customer_sale_fail_reason":"other"},"lead_id":"Dolead3"}],"failure":[]}}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);

        Lead oLead = [SELECT Id, ExternalID__c, Status FROM Lead WHERE ExternalId__c = 'Dolead3' LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(oLead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead not successfully converted');

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Dolead_CalloutMgr.callDoleadCustomerConversionsWS(oLead.Id, oLead.ExternalID__c, oLead.Status);
        
        
        Test.stopTest();
    }

    static testMethod void testCalloutOptyWon() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"result":"success","details":{"success":[{"finder":{"lead_id":"Opty","customer_id":111},"setter":{"customer_sale":false,"customer_sale_fail_reason":"other"},"lead_id":"Opty"}],"failure":[]}}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);

        Opportunity oOpty = [SELECT Id, Account.Lead_ExternalID__c, StageName FROM Opportunity WHERE Name = 'TestOptyOwner' LIMIT 1];
        Quote oQuote = [SELECT Id, T_LAT_Approved__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];

        // Update opty with synced quote
        if(oOpty != null && oQuote != null){
            oOpty.SyncedQuoteId = oQuote.Id;
            update oOpty;
        }
        // Update opty again because it raises an error if the synchronisation and the modification of the StageName are done in the same update
        if(oOpty != null && oQuote != null){
            oOpty.StageName = 'Closed Won';
            update oOpty;
        }

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Dolead_CalloutMgr.callDoleadCustomerConversionsWS(oOpty.Id, null, oOpty.StageName);
        
        
        Test.stopTest();
    }

    static testMethod void testCalloutOptyLost() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"result":"success","details":{"success":[{"finder":{"lead_id":"Opty","customer_id":111},"setter":{"customer_sale":false,"customer_sale_fail_reason":"other"},"lead_id":"Opty"}],"failure":[]}}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);

        Opportunity oOpty = [SELECT Id, Account.Lead_ExternalID__c, StageName FROM Opportunity WHERE Name = 'TestOptyOwner' LIMIT 1];
        
        if(oOpty != null){
            oOpty.StageName = 'Closed Lost';
            update oOpty;
        }
        

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Dolead_CalloutMgr.callDoleadCustomerConversionsWS(oOpty.Id, null, oOpty.StageName);
        
        
        Test.stopTest();
    }

}