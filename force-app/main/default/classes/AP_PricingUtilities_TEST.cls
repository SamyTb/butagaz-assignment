@isTest
public class AP_PricingUtilities_TEST{
    
    public static testmethod void testGetQuoteOwner(){
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        Activity_Domain__c ad = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
        insert ad;
        
        
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getBasicQuote();
        Test.startTest();
        System.assertEquals(true, AP_PricingUtilities.isQuoteOwner(UserInfo.getUserId()));
        Test.stopTest(); 
    }
    
    public static testmethod void testGetQuoteProductScalePack(){
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        Activity_Domain__c ad = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
        insert ad;
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getBasicQuote();
        initialQuote.Product_Scale__c = 'V1LIB';
        update initialQuote;
        Test.startTest();
        System.assertEquals(false, AP_PricingUtilities.getQuoteProductScalePack(initialQuote));
        Test.stopTest(); 
    }
    
    
    public static testmethod void testgetQuoteIsNotPackTRUECASE(){
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        Activity_Domain__c ad = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
        insert ad;
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getBasicQuote();
        initialQuote.Scale__c = '2';
        initialQuote.Product_Scale__c = 'TEST';
        update initialQuote;
        Test.startTest();
        System.assertEquals(true, AP_PricingUtilities.getQuoteIsNotPack(initialQuote));
        Test.stopTest(); 
    }
    
    public static testmethod void testgetQuoteIsNotPackFALSECASE(){
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        Activity_Domain__c ad = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
        insert ad;
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getBasicQuote();
        initialQuote.Scale__c = 'P';
        initialQuote.Product_Scale__c = 'V1LIB';
        update initialQuote;
        Test.startTest();
        System.assertEquals(false, AP_PricingUtilities.getQuoteIsNotPack(initialQuote));
        Test.stopTest(); 
    }
    
    public static testmethod void testconvertDateToString(){
        Test.startTest();
        String date_x = AP_PricingUtilities.convertDateToString(date.newInstance(2008, 12, 1));
        System.assertEquals('2008-12-01', date_x);
        System.assertNotEquals('2008-12-1', date_x);
        date_x = AP_PricingUtilities.convertDateToString(null);
        System.assertEquals(null, date_x);
        Test.stopTest(); 
    }

    public static testmethod void testintegerToPaddedString(){
        Test.startTest();
        System.assertEquals('02', AP_PricingUtilities.integerToPaddedString(2, 2));
        System.assertEquals('2', AP_PricingUtilities.integerToPaddedString(2, 1));
        System.assertEquals('2', AP_PricingUtilities.integerToPaddedString(2, 0));
        System.assertEquals('002', AP_PricingUtilities.integerToPaddedString(2, 3));
        Test.stopTest();
    }
    
    public static testmethod void testconvertDecimalToString(){
        Test.startTest();
        String decimal_x = AP_PricingUtilities.convertDecimalToString(100);
        System.assertEquals('100', decimal_x);
        System.assertNotEquals('101', decimal_x);
        decimal_x = AP_PricingUtilities.convertDecimalToString(null);
        System.assertEquals(null, decimal_x);
        Test.stopTest(); 
    }
    
    public static testmethod void testconvertPurposesToFuelFlag(){
        Test.startTest();
        String flag = AP_PricingUtilities.convertPurposesToFuelFlag('Caburation;TEST');
        System.assertEquals('X', flag);
        flag = AP_PricingUtilities.convertPurposesToFuelFlag('TESTONLY');
        System.assertEquals('', flag);
        flag = AP_PricingUtilities.convertPurposesToFuelFlag(null);
        System.assertEquals('', flag);
        Test.stopTest(); 
    }
    
    public static testmethod void testIsTank(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        Activity_Domain__c ad = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
        insert ad;
        
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getBasicQuote();
        
        Id pbId = Test.getStandardPricebookId();
       
        initialQuote.Pricebook2Id = pbId;
        update initialQuote;
        
        Product2 oProduct1 = new Product2(Name='TESTMATCODE1', ProductCode = 'TESTMATCODE1', Family='Equipement', Sub_Type__c='Citerne', IsActive=true); 
        Product2 oProduct2 = new Product2(Name='TESTMATCODE2', ProductCode = 'TESTMATCODE2', Family='Produit', Sub_Type__c='Redevance', IsActive=true); 
           insert new List<Product2> {oProduct1, oProduct2};
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pbId, Product2Id = oProduct1.Id, UnitPrice = 1.0, IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pbId, Product2Id = oProduct2.Id, UnitPrice = 1.0, IsActive=true); 

        insert new List<PricebookEntry> {pbe1, pbe2};
        /**update pb;**/
        
        QuoteLineItem QLI1 = new QuoteLineItem(QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntry = pbe1, PricebookEntryId = pbe1.Id, Mis_Disposition__c = 'Tank sold By BTZ');
        
        QuoteLineItem QLI2 = new QuoteLineItem(QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntry = pbe2, PricebookEntryId = pbe2.Id);
        
        insert QLI1;
        insert QLI2;
        
        QLI1.PricebookEntry = [SELECT Id, Product2.Family, Product2.Sub_Type__c FROM PricebookEntry WHERE Id = :pbe1.Id];
        QLI2.PricebookEntry = [SELECT Id, Product2.Family, Product2.Sub_Type__c FROM PricebookEntry WHERE Id = :pbe2.Id];
        
        Test.startTest();
        
        System.assertEquals(true, AP_PricingUtilities.isTank(QLI1), QLI1);
        System.assertEquals(false, AP_PricingUtilities.isTank(QLI2), QLI2);
        Test.stopTest(); 
    }
    
    public static testmethod void testQuotePtlCapacity(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APPU',Alias='APPU',
            Email='APPU@shell.com',Username='APPU@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        Custom_Settings__c c1 = new Custom_Settings__c(name='Pricing_doCallOuts', value__c = '1');
        Custom_Settings__c c2 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1, c2 };
        
        System.runAs(u) {
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
            
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
   
            Canton__c Canton1 = new Canton__c(name = 'APPU Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APPU City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APPU ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APPUCity', Email__c = 'APPUCity@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APPU Contact', AccountId = a.id);
           // insert c;
            
            
           // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;          
            
            
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = 'VPS01',
                Active__c = true
            );
            insert mand1;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
            insert attCom50;  
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'APPU City 2',
                Postal_Code__c = '09876',
                Code_AC_administrator_New__c = attCom50.Id
            );
            insert ptl1;
            
            
            // Add an Oppty
            Opportunity oOpty = new Opportunity(Name = 'TestOpty',
                Project_Type__c='CREA', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO'
                );
            insert oOpty;
            
            
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                PTL__c = ptl1.id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;
            
            
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL2;
            

            // PriceBooks & Products
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
            insert pbk1;
            
            List<Pricebook2> pbkList = [select id, name from Pricebook2];
            for (Pricebook2 pbk: pbkList) {
                System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
            }
            
            List<Product2> prdList = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Equipement' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Equipement' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A');
            prdList.add(oProduct1);
            prdList.add(oProduct2);

            insert prdList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
            
            RecordTypes_OpportunityToQuote__c rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D000000038Q7',
                OpportunityRecordType__c = '012D000000038Q2',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB CONS',
                QuotePTLRecordType__c = '012D0000000374o'
            );
            insert rtotq;
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374g',
                OpportunityRecordType__c = '012D0000000374U',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM',
                QuotePTLRecordType__c ='012D0000000374p'
            );
            insert rtotq;

            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='VFC06PS Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = c.id
                );
            insert initialQuote;
            
            Quote otherTestQuote = new Quote(OpportunityId = oOpty.Id, Name='VFC06PS TestQuote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = c.id
                );
            insert OtherTestQuote;
            OtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS');
            update otherTestQuote;
        
            system.debug('optyPTL1.Id:'+optyPTL1.Id);
            system.debug('optyPTL2.Id:'+optyPTL2.Id);
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL2.Id, Mis_Disposition__c = 'Tank sold by BTZ'
                )
            }; 
        
            insert lQLI; 
        
            for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }
            
            List<List<QuoteLineItem>> quoteLineItemsPacket = new List<List<QuoteLineItem>>();
            quoteLineItemsPacket.add(lQLI);
            Map<String, Decimal> testResult = new Map<String, Decimal>();
            
            Test.startTest();
            testResult = AP_PricingUtilities.mapQuotePTLToCapacity(quoteLineItemsPacket);
            Boolean b = AP_PricingUtilities.isQliRetrait(lQLI[0]);
            String s = AP_PricingUtilities.getOpportunityRecordTypeValue('GEC DOM');
            try {
                s = AP_PricingUtilities.getOpportunityRecordTypeValue('GEC FAKE');
            } catch(Exception e) {}
            s = AP_PricingUtilities.getCustomSettingValue('Pricing_doCallOuts');
            try {
                s = AP_PricingUtilities.getCustomSettingValue('fake_value');
            } catch(Exception e) {}
            try {
                s = AP_PricingUtilities.getQuoteRecordTypeValue('fake_value');
            } catch(AP_CRMException e) {
                AP_PricingUtilities.showApexErrors(e);
            }
            
            Test.stopTest();
        }
        
        
    }
    
    public static testmethod void testisRCE(){
        Test.startTest();
        Boolean res = AP_PricingUtilities.isRCE('RCE_Rebate');
        System.assertEquals(true, res);
        res = AP_PricingUtilities.isRCE('TESTONLY');
        System.assertEquals(false, res);
        Test.stopTest(); 
    }
    
    public static testmethod void testisRCOM(){
        Test.startTest();
        Boolean res = AP_PricingUtilities.isRCOM('Commercial_Rebate');
        System.assertEquals(true, res);
        res = AP_PricingUtilities.isRCOM('TESTONLY');
        System.assertEquals(false, res);
        Test.stopTest(); 
    }
    
    public static testmethod void testisRCONJ(){
        Test.startTest();
        Boolean res = AP_PricingUtilities.isRCONJ('Cyclical_Rebate');
        System.assertEquals(true, res);
        res = AP_PricingUtilities.isRCONJ('TESTONLY');
        System.assertEquals(false, res);
        Test.stopTest(); 
    }
    
    public static testmethod void testgetQuotePTLCapacity(){
        Test.startTest();
        Map<String, Decimal> map_x = new Map<String, Decimal>();
        map_x.put('TESTPTL', 2);
        Decimal capa = AP_PricingUtilities.getQuotePTLCapacity(map_x , 'TESTPTL');
        System.assertEquals(2, capa);
        capa = AP_PricingUtilities.getQuotePTLCapacity(map_x , null);
        System.assertEquals(0, capa);
        map_x.put('TESTPTL', null);
        capa = AP_PricingUtilities.getQuotePTLCapacity(map_x , 'TESTPTL');
        System.assertEquals(0, capa);
        Test.stopTest(); 
    }
    
    public static testmethod void testgetTotalQuotePTLsCapacity(){
        Test.startTest();
        Map<String, Decimal> map_x = new Map<String, Decimal>();
        map_x.put('TESTPTL1', 2);
        map_x.put('TESTPTL2', 3);
        Decimal totalCapa = AP_PricingUtilities.getTotalQuotePTLsCapacity(map_x);
        System.assertEquals(5, totalCapa);
        map_x = new Map<String, Decimal>();
        totalCapa = AP_PricingUtilities.getTotalQuotePTLsCapacity(map_x);
        System.assertEquals(0, totalCapa);
        totalCapa = AP_PricingUtilities.getTotalQuotePTLsCapacity(null);
        System.assertEquals(0, totalCapa);
        Test.stopTest(); 
    }
    
    /**public static Map<String, Decimal> mapQuotePTLToCapacity(List< List<QuoteLineItem> > quoteLineItemsPacket){
        Map<String, Decimal> mapPTLsToCapacity = new Map<String, Decimal>();
        
        for(List<QuoteLineItem> quoteLineItemsList : quoteLineItemsPacket){
            for(QuoteLineItem lineItem: quoteLineItemsList){
                 //if the current ActivityDomain use PTLs (GEC, GPLC, GEROwner), when the product choosed is Equipement of type citerne, we have to update the capacity of the related Quote_PTL of the QLI)
                if(isTank(lineItem)&& lineItem.Quote_PTL__r != null
                   ){
                    Decimal v = mapPTLsToCapacity.get(lineItem.Quote_PTL__r.Name);
                    if(v != null){
                        mapPTLsToCapacity.put(lineItem.Quote_PTL__r.Name, (v + lineItem.PricebookEntry.Product2.Capacity__c));
                        System.debug('YYYYY ADDED ==>  ' + lineItem.PricebookEntry.Product2.Capacity__c + ' TO ' + lineItem.Quote_PTL__r.Name);

                    }else{
                        mapPTLsToCapacity.put(lineItem.Quote_PTL__r.Name, lineItem.PricebookEntry.Product2.Capacity__c); 
                        System.debug('YYYYY CREATED ==>  ' + lineItem.PricebookEntry.Product2.Capacity__c + ' TO ' + lineItem.Quote_PTL__r.Name);
                    }
                    System.debug('YYYYY VALUE NOW ==>  ' + mapPTLsToCapacity.get(lineItem.Quote_PTL__r.Name) + ' FOR ' + lineItem.Quote_PTL__r.Name);
                }
            }
        }    
        return mapPTLsToCapacity;
    }
    
    public static testmethod void testmapQuotePTLToCapacity(){
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote initialQuote = ap.getFullQuote();
        List<QuoteLineItem> listQLI = [SELECT Id FROM QuoteLineItem WHERE Id = :initialQuote.Id];
        
        Test.startTest();
        AP_PricingUtilities.mapQuotePTLToCapacity(new List<List<QuoteLineItem>>({listQLI}));
        
        Test.stopTest(); 
    }**/
}