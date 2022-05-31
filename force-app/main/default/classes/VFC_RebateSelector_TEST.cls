@isTest
public class VFC_RebateSelector_TEST {
    
    @testSetup static void setupUser(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        String BOGroupId = [select Id from Group WHERE DeveloperName = 'BackOffice' LIMIT 1].Id;

        // Avoid mixed DML using runAs
        //System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = BOGroupId, UserOrGroupId = UserInfo.getUserId());
            insert gm;
        //}
        
        System.runAs(u) {
            
            // PriceBook
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
            insert pbk1;
            
            
            // Custom settings
            // FolderId lookup on Document = polymorphic field (can lookup to a folder or a user). Docs will be added to the My Personal Documents folder
            Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
            
            Custom_Settings__c c2 = new Custom_Settings__c (name='Pricing_EndPointURL',value__c = 'http://www.google.fr'); 
            Custom_Settings__c c3 = new Custom_Settings__c (name='Pricing_Username',value__c = 'username'); 
            Custom_Settings__c c4 = new Custom_Settings__c (name='Pricing_Password',value__c = 'password');
            //Custom_Settings__c c5 = new Custom_Settings__c (name='AutoAdd_Allowed',value__c = 'S000000132'); 
            //Custom_Settings__c c6 = new Custom_Settings__c (name='ACOfferedMonthsApplies',value__c = 'SPPABO0010;SPPABO0008'); 
            //Custom_Settings__c c7 = new Custom_Settings__c (name='AC_Prevent_Duplication_on_Articles',value__c = 'S000000132');
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            Custom_Settings__c c13 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_DOM_IDEO',value__c = '012D00000003Epc');
            Custom_Settings__c c14 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_GrosVrac',value__c = '012D0000000374b');
            Custom_Settings__c c15 = new Custom_Settings__c (name='TrackBAPICalls', value__c = 'true');
            Custom_Settings__c c16 = new Custom_Settings__c (name='Rebate_EndPointURL', value__c = 'http://www.google.fr');
            Custom_Settings__c c17 = new Custom_Settings__c (name='Rebate_Username',value__c = 'username'); 
            Custom_Settings__c c18 = new Custom_Settings__c (name='Rebate_Password',value__c = 'password');
            insert new List<Custom_Settings__c> { c1, c2, c3, c4, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18 };
            
            
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
                QuoteRecordType__c = '012D00000003Epg',
                OpportunityRecordType__c = '012D00000003Epc',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM IDEO',
                QuotePTLRecordType__c ='012D00000003Epj'
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
            /*rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocP',
                OpportunityRecordType__c = '012e00000008ocK',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM ECOCFT',
                QuotePTLRecordType__c ='012e00000008oct'
            );*/
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D00000003Epf',
                OpportunityRecordType__c = '012D00000003Epb',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM ECOCFT',
                QuotePTLRecordType__c ='012D00000003Epm'
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
            
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0124E000000tLeq',
                OpportunityRecordType__c = '0124E000000tLR5',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM OPTIMO',
                QuotePTLRecordType__c ='012D00000003Epj'
            );
            rtList.add(rtotq);
            
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0127Z000001EiSX',
                OpportunityRecordType__c = '0127Z000001EiSS',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM LOC OPTIMO',
                QuotePTLRecordType__c ='012D00000003Epn'
            );
            rtList.add(rtotq);

            insert rtList;
            
                        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c = 41);
            insert new List<Activity_Domain__c> { AD_GEC, AD_GEB };

            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
            // RecordType rt_optyGecDomIdeo = [SELECT Id, Name FROM RecordType WHERE SobjectType='opportunity' AND DeveloperName='GEC_DOM_IDEO' LIMIT 1];
            
            //Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = '999',
                Active__c = true,
                MatriculeEnCours__c = 1
            );
            insert mand1;
            
            Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            
            Account accMainOwner = new Account(
                FirstName = 'FNameMainOwner', 
                LastName = 'LNameMainOwner', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12345',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Scale__c = 'GAZPART1'
            );
            /*Account accMainRenter = new Account(
                FirstName = 'FName2', 
                LastName = 'LName2', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'CH',
                Indicatif_Pays__c = '+41',
                channel__c = 'CD',
                accountNumber='12346',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accRentersOwner = new Account(
                FirstName = 'FName3', 
                LastName = 'LName3', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12347',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accToTriggerErrors = new Account(
                FirstName = 'FName5', 
                LastName = 'LName5', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = '', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                No_E_mail__c = true,
                channel__c = 'CD',
                accountNumber='12349',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accGEBRE = new Account(
                Name = 'Name6',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12351',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accGEBCS = new Account(
                Name = 'Name7',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12352',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            
             Account accGECPRO = new Account(
                Name = 'Name7',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12352',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );*/
            
            insert new List<Account> { accMainOwner/*, accMainRenter, accRentersOwner, accToTriggerErrors, accGEBRE, accGEBCS, accGECPRO*/ };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (2) : ' + Limits.getQueries());
            
            
            /*Contact cGEBRE = new Contact(Lastname='ContactGEBRE', AccountId = accGEBRE.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            Contact cGEBCS = new Contact(Lastname='ContactGEBCS', AccountId = accGEBCS.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            Contact cGECPROP = new Contact(Lastname='ContactGECPRO', AccountId = accGECPRO.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            insert new List<Contact> { cGEBRE, cGEBCS,cGECPROP };*/
            
            
            //PTL
            PTL__c ptl1 = new PTL__c(
                Name = 'PTLCODE1',
                ExternalID__c = 'PTLCODE1',
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainOwner.Id,
                Scale__c = 'CART1',
                Shipping_Condition__c = '01',
                Fiscal_class_PTL__c = '01'
            );
            PTL__c ptl2 = new PTL__c(
                Name = 'PTLCODE2',
                ExternalID__c = 'PTLCODE2',
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainOwner.Id,
                Scale__c = 'CART1',
                Shipping_Condition__c = '01',
                Fiscal_class_PTL__c = '01'
            );
            insert new List<PTL__c>{ ptl1, ptl2 };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
            
            // Equipment
            Equipement__c equipment1 = new Equipement__c(
                PTL__c = ptl1.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id
            );
            Equipement__c equipment2 = new Equipement__c(
                PTL__c = ptl2.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id
            );
            insert new List<Equipement__c>{ equipment1, equipment2 };
            
            // Contract
            Contract ctr1 = new Contract(
                AccountId = accMainOwner.id,
                PTL__c = ptl1.id,
                Equipement__c = equipment1.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Scale_c__c = 'GAZPART1',
                ExternalID__c = 'ExtId1'
            );
            Contract ctr2 = new Contract(
                AccountId = accMainOwner.id,
                PTL__c = ptl2.id,
                Equipement__c = equipment2.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Scale_c__c = 'GAZPART1',
                ExternalID__c = 'ExtId2'
            );
            insert new List<Contract>{ ctr1, ctr2 };
            
            
            // Product
            List<Product2> prdList1 = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = 'TESTMATCODE1', is_crea__c = true, Tank_Type__c = 'A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = 'TESTMATCODE2', is_crea__c = true, Tank_Type__c = 'A');
            Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c = '904P0001',isactive = true,Family = 'Produit', ProductCode = '904P0001', is_crea__c = true);
            Product2 oProduct6 = new Product2(Name = '000000000000000440',external_ID__c = '000000000000000440',isactive = true,Family = 'Produit', ProductCode = '000000000000000440', is_crea__c = true);
            Product2 oProduct7 = new Product2(Name = '000000000000000888',external_ID__c = '000000000000000888',isactive = true,Family = 'Redevance', ProductCode = '000000000000000888', is_crea__c = true);
            Product2 oProduct8 = new Product2(Name = '000000000000000999',external_ID__c = '000000000000000999',isactive = true,Family = 'Service', ProductCode = '000000000000000999', is_crea__c = true);
            prdList1.add(oProduct1);
            prdList1.add(oProduct2);
            
            prdList1.add(oProduct5);
            prdList1.add(oProduct6);
            prdList1.add(oProduct7);
            prdList1.add(oProduct8);
            
            //insert prdList;
            insert prdList1;
            
            // Pricebook
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList1) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (7) : ' + Limits.getQueries());
            
            // Reasons for Credit Order
            Reason_For_Credit_Order__c rfco1 = new Reason_For_Credit_Order__c(
                Name = 'Erreur de matricule',
                Activity_Domain__c = '41;42',
                ExternalID__c = '052',
                GEB_Product_Family__c = 'Produit; Coût logistique',
                GEC_Product_Family__c = 'Produit; Service; Redevance'
            );
            Reason_For_Credit_Order__c rfco2 = new Reason_For_Credit_Order__c(
                Name = 'Erreur de produit',
                Activity_Domain__c = '41;42',
                ExternalID__c = '053',
                GEB_Product_Family__c = 'Produit',
                GEC_Product_Family__c = 'Produit; Service; Redevance'
            );
            insert new List<Reason_For_Credit_Order__c>{ rfco1, rfco2 };

        }
    
    }
    
    
    
    @isTest static void testVFC_RebateSelector_AccountOwner_Rebate(){
        
        System.Debug('### >>>>> testing class VFC_RebateSelector_TEST.testVFC_RebateSelector_AccountOwner_Rebate <<<<<');
        
        // Start Test
        Test.startTest();
        
        
        // Account to run different parts of controller's code
        Account oAccMainOwner = [SELECT Id FROM Account WHERE FirstName like 'FNameMainOwner%' AND LastName like 'LNameMainOwner%' LIMIT 1];
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (8) : ' + Limits.getQueries());
        
        // Call page in writing mode
        PageReference pageRef = Page.VFP_RebateSelector;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.id);
        ApexPages.currentPage().getParameters().put('rebateType', 'REBATE');
        ApexPages.StandardController sc = new ApexPages.standardController(oAccMainOwner);
        VFC_RebateSelector vrs = new VFC_RebateSelector (sc);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (9) : ' + Limits.getQueries());
        
        vrs.initializePage();
        System.debug(logginglevel.WARN,'### SOQL Queries used (10) : ' + Limits.getQueries());
        vrs.getDurations();
        System.debug(logginglevel.WARN,'### SOQL Queries used (11) : ' + Limits.getQueries());
        vrs.getRCEReasons();
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        vrs.createRelatedRecords();
        System.debug(logginglevel.WARN,'### SOQL Queries used (13) : ' + Limits.getQueries());
        vrs.initRebatesFromSAP();
        System.debug(logginglevel.WARN,'### SOQL Queries used (14) : ' + Limits.getQueries());
        boolean bGECPack = vrs.GetisGECPack();
        
        vrs.inputNoteTitle = 'Title';
        vrs.inputNoteTextArea = 'Description';
        vrs.redirectToLAT_MAIN();
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (15) : ' + Limits.getQueries());
        
        // Retrieve the Quote and QLI to be sent to SAP
        Quote oQuoteMainOwner = [SELECT Id FROM Quote WHERE Account.Id =: oAccMainOwner.Id LIMIT 1];
        QuoteLineItem oQLIMainOwner = [SELECT Id, RCE_Rebate_TTC__c, Reason_For_Order__c, Cyclical_Rebate_TTC__c, Rebate_Starting_Date__c FROM QuoteLineItem WHERE PricebookEntry.Product2.Family = 'Produit' AND QuoteId =: oQuoteMainOwner.Id LIMIT 1];
        System.debug(logginglevel.WARN,'### SOQL Queries used (16) : ' + Limits.getQueries());
        
        // Set rebates
        oQLIMainOwner.RCE_Rebate_TTC__c = 10;
        oQLIMainOwner.Reason_For_Order__c = '000';
        oQLIMainOwner.Cyclical_Rebate_TTC__c = 150;
        oQLIMainOwner.Rebate_Starting_Date__c = Date.today();
        oQLIMainOwner.Cyclical_Rebate_Months__c = 18;
        update oQLIMainOwner;
        
        // Set approval flag
        oQuoteMainOwner.T_LAT_Approved__c = true;
        update oQuoteMainOwner;
        
        // Call the page in onlyShowMode to post the rebates to SAP
        PageReference pageRefShow = Page.VFP_RebateSelector;
        Test.setCurrentPage(pageRefShow);
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.Id);
        ApexPages.currentPage().getParameters().put('onlyShowMode', '1');
        ApexPages.currentPage().getParameters().put('quoteId', oQuoteMainOwner.Id);
        
        ApexPages.StandardController scShow = new ApexPages.standardController(oAccMainOwner);
        VFC_RebateSelector vrsShow = new VFC_RebateSelector (scShow);
        System.debug(logginglevel.WARN,'### SOQL Queries used (17) : ' + Limits.getQueries());
        vrsShow.initializePage();
        //vrsShow.postToSAP();
        
        vrsShow.redirectToQuoteDetail();
        System.debug(logginglevel.WARN,'### SOQL Queries used (18) : ' + Limits.getQueries());
        
        
        // Assertions
        
        
        // Stop Test
        Test.stopTest();
        
        
        System.Debug('### >>>>> testing class VFC_RebateSelector_TEST.testVFC_RebateSelector_AccountOwner_Rebate END <<<<<');
    }
    
    @isTest static void testVFC_RebateSelector_AccountOwner_Credit(){
        
        System.Debug('### >>>>> testing class VFC_RebateSelector_TEST.testVFC_RebateSelector_AccountOwner_Credit <<<<<');
        
        // Start Test
        Test.startTest();
        
        
        // Account to run different parts of controller's code
        Account oAccMainOwner = [SELECT Id FROM Account WHERE FirstName like 'FNameMainOwner%' AND LastName like 'LNameMainOwner%' LIMIT 1];
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (8) : ' + Limits.getQueries());
        
        // Call page in writing mode
        PageReference pageRef = Page.VFP_RebateSelector;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.id);
        ApexPages.currentPage().getParameters().put('rebateType', 'CREDIT');
        ApexPages.StandardController sc = new ApexPages.standardController(oAccMainOwner);
        VFC_RebateSelector vrs = new VFC_RebateSelector (sc);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (9) : ' + Limits.getQueries());
        
        vrs.initializePage();
        System.debug(logginglevel.WARN,'### SOQL Queries used (10) : ' + Limits.getQueries());
        vrs.getCreditReasons();
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        vrs.createRelatedRecords();
        System.debug(logginglevel.WARN,'### SOQL Queries used (13) : ' + Limits.getQueries());
        vrs.initRebatesFromSAP();
        System.debug(logginglevel.WARN,'### SOQL Queries used (14) : ' + Limits.getQueries());
        boolean bGECPack = vrs.GetisGECPack();
        boolean bGetisGECECOCFT = vrs.GetisGECECOCFT();
        boolean bGetisGECSansRCONJ = vrs.GetisGECSansRCONJ();
        //boolean bisBackOfficeUser = vrs.isBackOfficeUser();
        

        vrs.selectedCreditReason = '052';
        vrs.getQPTLOptions();
        vrs.getProductFamilyOptions();

        // Set rebates
        //vrs.targetQLIs[0].setTempSelectedProductFamily('Product');
        vrs.targetQLIs[0].tempCreditQuantity = 2;
        vrs.targetQLIs[0].tempCreditUnitPriceHT = 50;
        //vrs.targetQLIs[1].setTempSelectedProductFamily('Redevance');
        vrs.targetQLIs[1].tempCreditQuantity = 2;
        vrs.targetQLIs[1].tempCreditUnitPriceHT = 50;

        // CreditProductToAdd
        //vrs.wrappedCreditProductToAdd creditProductToAdd = new vrs.wrappedCreditProductToAdd(vrs);
        vrs.creditProductToAdd.setTempSelectedProductFamily('Produit');
        vrs.creditProductToAdd.selectedPTL = 'PTLCODE1';
        vrs.creditProductToAdd.selectedProduct = '904P0001';
        vrs.creditProductToAdd.tempCreditQuantity = 1;
        vrs.creditProductToAdd.tempCreditUnitPriceHT = 25;
        //vrs.creditProductToAdd.add();

        
        vrs.inputNoteTitle = 'Title';
        vrs.inputNoteTextArea = 'Description';
        
        vrs.redirectToLAT_MAIN();
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (15) : ' + Limits.getQueries());
        
        // Retrieve the Quote and QLI to be sent to SAP
        Quote oQuoteMainOwner = [SELECT Id FROM Quote WHERE Account.Id =: oAccMainOwner.Id LIMIT 1];
        QuoteLineItem oQLIMainOwner = [SELECT Id, RCE_Rebate_TTC__c, Reason_For_Order__c, Cyclical_Rebate_TTC__c, Rebate_Starting_Date__c FROM QuoteLineItem WHERE PricebookEntry.Product2.Family = 'Produit' AND QuoteId =: oQuoteMainOwner.Id LIMIT 1];
        System.debug(logginglevel.WARN,'### SOQL Queries used (16) : ' + Limits.getQueries());
        
        
        // Set approval flag
        oQuoteMainOwner.T_LAT_Approved__c = true;
        update oQuoteMainOwner;
        
        // Call the page in onlyShowMode to post the rebates to SAP
        PageReference pageRefShow = Page.VFP_RebateSelector;
        Test.setCurrentPage(pageRefShow);
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.Id);
        ApexPages.currentPage().getParameters().put('onlyShowMode', '1');
        ApexPages.currentPage().getParameters().put('quoteId', oQuoteMainOwner.Id);
        
        ApexPages.StandardController scShow = new ApexPages.standardController(oAccMainOwner);
        VFC_RebateSelector vrsShow = new VFC_RebateSelector (scShow);
        System.debug(logginglevel.WARN,'### SOQL Queries used (17) : ' + Limits.getQueries());
        vrsShow.initializePage();
        System.debug(logginglevel.WARN,'### SOQL Queries used (18) : ' + Limits.getQueries());
        //vrsShow.postToSAP(); // To uncomment
        
        vrsShow.redirectToQuoteDetail();
        System.debug(logginglevel.WARN,'### SOQL Queries used (19) : ' + Limits.getQueries());
        vrsShow.refresh();
        
        // Assertions
        
        
        // Stop Test
        Test.stopTest();
        
        
        System.Debug('### >>>>> testing class VFC_RebateSelector_TEST.testVFC_RebateSelector_AccountOwner_Credit END <<<<<');
    }

}