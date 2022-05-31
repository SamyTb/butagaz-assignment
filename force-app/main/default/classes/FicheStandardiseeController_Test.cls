@isTest
private class FicheStandardiseeController_Test {

    static testMethod void testFicheStandardiseeController() {
        
        
        System.Debug('### >>>>> testing class FicheStandardiseeController_Test.testFicheStandardiseeController <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@shell.com',Username='VFC06PS@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            
            // PriceBook
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
            insert pbk1;
            
            // Custom settings
            Custom_Settings__c c1 = new Custom_Settings__c(name='TrackBAPICalls', value__c = 'true');
            Custom_Settings__c c2 = new Custom_Settings__c (name='Pricing_EndPointURL',value__c = 'http://www.google.fr'); 
            Custom_Settings__c c3 = new Custom_Settings__c (name='Pricing_Username',value__c = 'username'); 
            Custom_Settings__c c4 = new Custom_Settings__c (name='Pricing_Password',value__c = 'password');
            Custom_Settings__c c5 = new Custom_Settings__c (name='AutoAdd_Allowed',value__c = 'S000000132'); 
            Custom_Settings__c c6 = new Custom_Settings__c (name='ACOfferedMonthsApplies',value__c = 'SPPABO0010;SPPABO0008'); 
            Custom_Settings__c c7 = new Custom_Settings__c (name='AC_Prevent_Duplication_on_Articles',value__c = 'S000000132');
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='GER_Accessories_Metropole_VAT',value__c = '20');
            Custom_Settings__c c10 = new Custom_Settings__c (name='GER_Accessories_Corsica_VAT',value__c = '13');
            insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 };
            
            
            List<RecordTypes_OpportunityToQuote__c> rtList = new List<RecordTypes_OpportunityToQuote__c>();
            RecordTypes_OpportunityToQuote__c rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D000000038Q7',
                OpportunityRecordType__c = '012D000000038Q2',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB CONS',
                QuotePTLRecordType__c = '012D0000000374o'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374l',
                OpportunityRecordType__c = '012D0000000374Z',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GER Usager',
                QuotePTLRecordType__c ='012D0000000374u'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374k',
                OpportunityRecordType__c = '012D0000000374Y',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GER Proprietaire',
                QuotePTLRecordType__c ='012D0000000374t'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocU',
                OpportunityRecordType__c = '012e00000008ocA',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM IDEO',
                QuotePTLRecordType__c ='012e00000008oco'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocZ',
                OpportunityRecordType__c = '012e00000008ocF',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM SOLO',
                QuotePTLRecordType__c ='012e00000008ocu'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocP',
                OpportunityRecordType__c = '012e00000008ocK',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM ECOCFT',
                QuotePTLRecordType__c ='012e00000008oct'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374i',
                OpportunityRecordType__c = '012D0000000374W',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC LOCATAIRE',
                QuotePTLRecordType__c ='012D0000000374r'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374g',
                OpportunityRecordType__c = '012D0000000374U',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM',
                QuotePTLRecordType__c ='012D0000000374p'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374j',
                OpportunityRecordType__c = '012D0000000374X',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC PRO',
                QuotePTLRecordType__c ='012D0000000374s'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374n',
                OpportunityRecordType__c = '012D0000000374b',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GrosVrac',
                QuotePTLRecordType__c ='012D0000000374w'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374m',
                OpportunityRecordType__c = '012D0000000374a',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GPLc',
                QuotePTLRecordType__c ='012D0000000374v'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D000000038P4',
                OpportunityRecordType__c = '012D000000038Oz',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB RE',
                QuotePTLRecordType__c ='012D0000000374o'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374h',
                OpportunityRecordType__c = '012D0000000374V',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC energigaz',
                QuotePTLRecordType__c ='012D0000000374q'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008r20',
                OpportunityRecordType__c = '012e00000008r1q',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM LOC IDEO SOLO',
                QuotePTLRecordType__c ='012e00000008r25'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0129E000000Cqyx',
                OpportunityRecordType__c = '0129E000000Cjzm',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC PRO COLL',
                QuotePTLRecordType__c ='012e00000008r25'
            );
            rtList.add(rtotq);
            insert rtList;
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account accGecDOM = new Account(Name='VFC06PS ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            
            Account accGecPRO = new Account(Name='VFC06PS ', Market_Type__c = 'PRO', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12346',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            
            insert new List<Account> { accGecDOM, accGecPRO };
            
            // Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            // insert c;
            
            // New Contact
            Contact cGecDOM  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing1',lastName = 'Contact Marketing1',
                accountId = accGecDOM.Id,Street_Number__c = accGecDOM.Street_Number__c,Postal_Box__c = accGecDOM.Postal_Box__c,
                Postal_Code__c = accGecDOM.Postal_Code__c,City__c = accGecDOM.City__c,Email = accGecDOM.Email__c,Email_2__c = accGecDOM.Email_2__c,
                Fax = accGecDOM.Fax,Place_Called__c = accGecDOM.Place_Called__c,Country__c = accGecDOM.Country__c,Phone = accGecDOM.Phone);
            
            Contact cGecPRO  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing2',lastName = 'Contact Marketing2',
                accountId = accGecPRO.Id,Street_Number__c = accGecPRO.Street_Number__c,Postal_Box__c = accGecPRO.Postal_Box__c,
                Postal_Code__c = accGecPRO.Postal_Code__c,City__c = accGecPRO.City__c,Email = accGecPRO.Email__c,Email_2__c = accGecPRO.Email_2__c,
                Fax = accGecPRO.Fax,Place_Called__c = accGecPRO.Place_Called__c,Country__c = accGecPRO.Country__c,Phone = accGecPRO.Phone);
            
            insert new List<Contact> { cGecDOM, cGecPRO };
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = 'VPS01',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876'
            );
            insert ptl1;
            
            // Actions Commerciales
            Action_Commerciale__c acmIdeo = new Action_Commerciale__c(
                Cible_Not_Needed__c = true,
                Contract_Duration__c = '5',
                DPE_Not_Needed__c = true,
                End_Date__c = Date.today() + 15,
                Libelle__c = 'ACTEST1',
                Locked_Price__c = true,
                Offered_Months__c = 3,
                Opportunity_Reason_Not_Needed__c = true,
                Project_Type__c = 'CREA',
                RCE__c = 10,
                Start_Date__c = Date.today() - 15,
                T_Pack__c = 'IDEO',
                Tank_Property__c = 'Butagaz Owned Tank',
                Tank_Type__c = 'A',
                Locked_Price_2_Years__c = true
            );
            insert acmIdeo;
            
            // Add an Oppty
            Opportunity oOptyIdeo = new Opportunity(Name = 'TestOptyIdeo',
                Project_Type__c='CREA', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = accGecDOM.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                //DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Owner',
                Project_market_type__c = 'DOM',
                DO_Postal_Code__c = '01000',
                DO_City__c = 'TestCity',
                Opportunity_Reason__c = 'Modif de stockage – apparent vers enfoui'
            );
            
            Opportunity oOptyPRO = new Opportunity(Name = 'TestOptyPRO',
                Project_Type__c='CREA', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = accGecPRO.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                //DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = null,
                Client_Type__c = 'Owner',
                Project_market_type__c = 'PRO',
                DO_Postal_Code__c = '01000',
                DO_City__c = 'TestCity',
                Opportunity_Reason__c = 'Modif de stockage – apparent vers enfoui'
            );

            // Add an Oppty- FIDE PRO
            Opportunity oOptyIdeoFide = new Opportunity(Name = 'TestOptyIdeoPROFIDE',
                Project_Type__c='FIDE', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = accGecPRO.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                //DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'PRO',
                Client_Type__c = 'Owner',
                Project_market_type__c = 'PRO',
                DO_Postal_Code__c = '01000',
                DO_City__c = 'TestCity',
                Opportunity_Reason__c = 'Modif de stockage – apparent vers apparent'
            );

            insert new List<Opportunity> { oOptyIdeo, oOptyPRO, oOptyIdeoFide};
            
            // Add Attache commercial
            Attache_Commercial__c oAC = new Attache_Commercial__c(
                Name = 'AC1',
                Code_Groupe_Vendeur__c = 'AC1',
                Libelle_Groupe_Vendeur__c = 'AC1'
            );
            insert new List<Attache_Commercial__c> { oAC };

            // Add Oppty PTLs
            Opportunity_PTL__c optyPTLIdeo1 = new Opportunity_PTL__c(
                Opportunity__c = oOptyIdeo.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = oAC.Id
            );
            Opportunity_PTL__c optyPTLIdeo2 = new Opportunity_PTL__c(
                Opportunity__c = oOptyIdeo.Id, 
                PTL_Name__c = 'VFC06PS2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = oAC.Id
            );
            Opportunity_PTL__c optyPTLPRO = new Opportunity_PTL__c(
                Opportunity__c = oOptyPRO.Id, 
                PTL_Name__c = 'VFC06PS3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = oAC.Id
            );
            Opportunity_PTL__c optyPTLPROFIDE = new Opportunity_PTL__c(
                Opportunity__c = oOptyIdeoFide.Id, 
                PTL_Name__c = 'VFC06PS4',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = oAC.Id
            );
            insert new List<Opportunity_PTL__c> { optyPTLIdeo1, optyPTLIdeo2, optyPTLPRO, optyPTLPROFIDE };
            

            // PriceBooks & Products
            
            List<Pricebook2> pbkList = [select id, name from Pricebook2];
            for (Pricebook2 pbk: pbkList) {
                System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
            }
            
            List<Product2> prdList = new List<Product2>();
            List<Product2> prdList1 = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A');
            Product2 oProduct3 = new Product2(Name = 'SPPABOTS10',external_ID__c= 'SPPABOTS10',isactive=true,Family='Redevance', ProductCode='SPPABOTS10', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct4 = new Product2(Name = 'SPPABOTS11',external_ID__c= 'SPPABOTS11',isactive=true,Family='Redevance', ProductCode='SPPABOTS11', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c= '904P0001',isactive=true,Family='Produit', ProductCode='904P0001', is_crea__c=true);
            Product2 oProduct6 = new Product2(Name = 'p3',external_ID__c= 'p3',isactive=true,Family='Redevance', Sub_Type__c = 'Redevance citerne', ProductCode='p3', is_crea__c=true);
            Product2 oProduct7 = new Product2(Name = 'S000000007',external_ID__c= 'S000000007',isactive=true,Family='Service', Sub_Type__c = 'Autre service', ProductCode='S000000007', is_crea__c=true);
            Product2 oProduct8 = new Product2(Name = 'SPPABO0010',external_ID__c= 'SPPABO0010',isactive=true,Family='Redevance', ProductCode='SPPABO0010', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct9 = new Product2(Name = 'S000000112',external_ID__c= 'S000000112',isactive=true,Family='Service', ProductCode='S000000112', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct10 = new Product2(Name = 'S000000147',external_ID__c= 'S000000147',isactive=true,Family='Service', ProductCode='S000000147', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct11 = new Product2(Name = 'S000000096',external_ID__c= 'S000000096',isactive=true,Family='Service', ProductCode='S000000096', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct12 = new Product2(Name = 'S000000149',external_ID__c= 'S000000149',isactive=true,Family='Service', ProductCode='S000000149', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct13 = new Product2(Name = 'S000000012',external_ID__c= 'S000000012',isactive=true,Family='Service', ProductCode='S000000012', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct14 = new Product2(Name = 'S000000014',external_ID__c= 'S000000014',isactive=true,Family='Service', ProductCode='S000000014', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct15 = new Product2(Name = 'S000000132',external_ID__c= 'S000000132',isactive=true,Family='Service', ProductCode='S000000132', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct16 = new Product2(Name = 'SPPABO0012',external_ID__c= 'SPPABO0012',isactive=true,Family='Redevance', ProductCode='SPPABO0012', is_crea__c=true);
            Product2 oProduct17 = new Product2(Name = 'S000000174',external_ID__c= 'S000000174',isactive=true,Family='Service', ProductCode='S000000174', is_crea__c=true);
            Product2 oProduct18 = new Product2(Name = 'SPPABO0019',external_ID__c= 'SPPABO0019',isactive=true,Family='Redevance', ProductCode='SPPABO0019', is_crea__c=true);
            Product2 oProduct19 = new Product2(Name = 'p4',external_ID__c= 'p4',isactive=true,Family='Redevance', Sub_Type__c = 'Redevance citerne', Payment_type__c = 'Consignation', ProductCode='p4', is_crea__c=true);
            
            prdList.add(oProduct1);
            prdList1.add(oProduct1);
            prdList.add(oProduct2);
            prdList1.add(oProduct2);
            
            prdList.add(oProduct3);
            prdList.add(oProduct4);
            prdList.add(oProduct5);
            prdList.add(oProduct6);
            prdList.add(oProduct7);
            prdList.add(oProduct8);
            prdList.add(oProduct9);
            prdList.add(oProduct10);
            prdList.add(oProduct11);
            prdList.add(oProduct12);            
            prdList.add(oProduct13);
            prdList.add(oProduct14);
            prdList.add(oProduct15);
            prdList.add(oProduct16);
            prdList.add(oProduct17);
            prdList.add(oProduct18);
            prdList.add(oProduct19);

            insert prdList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
            
            /*// Action Commerciale
            List<PricebookEntry> pbeList2 = new List<PricebookEntry>();
            PricebookEntry pbe3 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe4 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe5 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe6 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            pbeList2.add(pbe3);
            pbeList2.add(pbe4);
            pbeList2.add(pbe5);
            pbeList2.add(pbe6);
            insert pbeList2;
            
            acmIdeo.Articles__c = 'SPPABOTS10;SPPABOTS11';*/
            /*acm1.Offered_Redevance__c = 'SPPABOTS10';*/
            /*update acmIdeo;*/
            
            

            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            Quote quoteIdeoOwner = new Quote(OpportunityId = oOptyIdeo.Id, Name='VFC06PS TestQuoteIdeo', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = cGecDOM.id,
                Client_Reenlistment__c = 'Contract',
                Action_Commerciale__c = acmIdeo.Id,
                Shipping_Condition__c = '02'
                );
            
            Quote quotePRO = new Quote(OpportunityId = oOptyPRO.Id, Name='VFC06PS TestQuotePRO', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = cGecPRO.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '04'
                );
            quotePRO.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO');
            
            Quote quotePROFIDE = new Quote(OpportunityId = oOptyIdeoFide.Id, Name='VFC06PS ThirdQuote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = cGecPRO.id,
                Client_Reenlistment__c = 'Contract'
                );
            quotePROFIDE.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEC PRO');

            insert new List<Quote> { quoteIdeoOwner, quotePRO, quotePROFIDE };
            
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :quoteIdeoOwner.Id AND Opportunity_PTL__c = :optyPTLIdeo1.Id];
            //Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :quoteIdeoOwner.Id AND Opportunity_PTL__c = :optyPTLIdeo2.Id];
            Quote_PTL__c oQPTLPRO = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :quotePRO.Id AND Opportunity_PTL__c = :optyPTLPRO.Id];
            Quote_PTL__c oQPTLPROFIDE = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :quotePROFIDE.Id AND Opportunity_PTL__c = :optyPTLPROFIDE.Id];
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                // Ideo
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTL1.Id,Got_From_SAP__c=true
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[3].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[4].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[5].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[6].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[7].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[9].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[10].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[11].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[12].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[13].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[14].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[15].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[16].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[17].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quoteIdeoOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[7].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                
                // PRO
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTL1.Id,Got_From_SAP__c=true
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[3].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[4].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[5].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[6].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[7].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[9].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[10].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[11].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[12].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[13].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[14].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[15].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[16].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[17].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[18].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                // PRO FIDE
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTLPROFIDE.Id,Got_From_SAP__c=true
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[3].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[4].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[5].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[6].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[7].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[9].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[10].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[11].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[12].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[13].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[14].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[15].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[16].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[17].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = quotePROFIDE.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[18].id, 
                    Quote_PTL__c = oQPTLPROFIDE.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                )
                    
            };
            insert lQLI; 
            
            /*for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }*/
                        // Update opty with synced quote
            /*oOpty.DO_City_Postal_Code__c = null;
            oOpty.DO_Postal_Code__c = '01000';
            oOpty.DO_City__c = 'TestCity';*/
            oOptyIdeo.SyncedQuoteId = quoteIdeoOwner.Id;
            update new List<Opportunity> { oOptyIdeo };
            
            
            Test.startTest();
            
            
            // Ideo
            Quote testQuoteIdeoOwner = [SELECT Id,
                                Shipping_Condition__c,
                                Market_type__c,
                                Contract_Duration__c, 
                                Opportunity.T_Pack__c,
                                Opportunity.Client_Type__c,
                                Opportunity.Project_Type__c,
                                Opportunity.Opportunity_Reason__c,
                                DO_groupement__c,
                                DO_groupement__r.AccountNumber,
                                Action_Commerciale__c,
                                Action_Commerciale__r.Fixed_Price__c,
                                Action_Commerciale__r.Locked_Price_1_Year__c,
                                Action_Commerciale__r.Locked_Price_2_Years__c,
                                Action_Commerciale__r.Locked_Price_3_Years__c,
                                Action_Commerciale__r.Offered_Months__c,
                                Action_Commerciale__r.RCOM_AbonnementAccesEnergie__c,
                                T_RollUp_BioPercentage__c,
                                T_RollUp_CompenseCarbone__c,
                                Opportunity.Storage_Modification_Reason__c
                                FROM Quote WHERE ID=: quoteIdeoOwner.id limit 1];
            
            FicheStandardiseeController contIdeo = new FicheStandardiseeController();
            contIdeo.oQuote = new Quote();   // simulate the assignTo operation on the apex:attribute
            contIdeo.oQuote = testQuoteIdeoOwner;
            string strIdeo = contIdeo.getQuoteId();
            
            string strDateDOM = contIdeo.getDateOfValidityOfTheOffer();
            
            
            // PRO
            Quote testQuotePRO = [SELECT Id,
                                Shipping_Condition__c,
                                Market_type__c,
                                Contract_Duration__c, 
                                Opportunity.T_Pack__c,
                                Opportunity.Client_Type__c,
                                Opportunity.Project_Type__c,
                                Opportunity.Opportunity_Reason__c,  
                                DO_groupement__c,
                                DO_groupement__r.AccountNumber,
                                Action_Commerciale__c,
                                Action_Commerciale__r.Fixed_Price__c,
                                Action_Commerciale__r.Locked_Price_1_Year__c,
                                Action_Commerciale__r.Locked_Price_2_Years__c,
                                Action_Commerciale__r.Locked_Price_3_Years__c,
                                Action_Commerciale__r.Offered_Months__c,
                                Action_Commerciale__r.RCOM_AbonnementAccesEnergie__c,
                                T_RollUp_BioPercentage__c,
                                T_RollUp_CompenseCarbone__c,
                                Opportunity.Storage_Modification_Reason__c
                                FROM Quote WHERE ID=: quotePRO.id limit 1];
            
            FicheStandardiseeController contPRO = new FicheStandardiseeController();
            contPRO.oQuote = new Quote();   // simulate the assignTo operation on the apex:attribute
            contPRO.oQuote = testQuotePRO;
            string strPRO = contPRO.getQuoteId();
            
            string strDatePRO = contPRO.getDateOfValidityOfTheOffer();
            
            // PRO FIDE
            Quote testQuotePROFIDE = [SELECT Id,
                                Shipping_Condition__c,
                                Market_type__c,
                                Contract_Duration__c, 
                                Opportunity.T_Pack__c,
                                Opportunity.Client_Type__c,
                                Opportunity.Project_Type__c,
                                Opportunity.Opportunity_Reason__c,  
                                DO_groupement__c,
                                DO_groupement__r.AccountNumber,
                                Action_Commerciale__c,
                                Action_Commerciale__r.Fixed_Price__c,
                                Action_Commerciale__r.Locked_Price_1_Year__c,
                                Action_Commerciale__r.Locked_Price_2_Years__c,
                                Action_Commerciale__r.Locked_Price_3_Years__c,
                                Action_Commerciale__r.Offered_Months__c,
                                Action_Commerciale__r.RCOM_AbonnementAccesEnergie__c,
                                T_RollUp_BioPercentage__c,
                                T_RollUp_CompenseCarbone__c,
                                Opportunity.Storage_Modification_Reason__c
                                FROM Quote WHERE ID=: quotePROFIDE.id limit 1];
            
            FicheStandardiseeController contPROFIDE = new FicheStandardiseeController();
            contPROFIDE.oQuote = new Quote();   // simulate the assignTo operation on the apex:attribute
            contPROFIDE.oQuote = testQuotePROFIDE;
            string strPROFIDE = contPROFIDE.getQuoteId();
            
            string strDatePROFIDE = contPROFIDE.getDateOfValidityOfTheOffer();
            
            Test.stopTest();
            
        }
        
        System.Debug('### >>>>> testing class FicheStandardiseeController_Test.testFicheStandardiseeController END <<<<<');  
        
    }
}