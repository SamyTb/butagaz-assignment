@isTest
public class VFC06_ProductSelector_TEST {
    
   // public static testmethod void testVFC06_ProductSelector(){
     @testSetup static void setupUser(){    
        System.Debug('### >>>>> testing class VFC06_ProductSelector_TEST.testVFC06_ProductSelector <<<<<');
        
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
            Custom_Settings__c c11 = new Custom_Settings__c (name='Tank_TVA_Sold_By_BTZ',value__c = '10');
            //insert c1; insert c2;  insert c3;  insert c4; insert c5; insert c6; insert c7;
            insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11 };
            
            
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
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0121l0000001Aho',
                OpportunityRecordType__c = '0121l0000001Ahn',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM OPTIMO',
                QuotePTLRecordType__c ='012D00000003Epj'
            );
            rtList.add(rtotq);
            
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0123N000002igBi',
                OpportunityRecordType__c = '0123N000002igBh',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM LOC OPTIMO',
                QuotePTLRecordType__c ='012D00000003Epn'
            );
            rtList.add(rtotq);
            insert rtList;
            
            /*//Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;*/
            
            // Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = 'VPS01',
                Active__c = true,
                MatriculeEnCours__c=3,
                Matricule_en_cours_GEB__c=4
            );
            insert mand1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
           // RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='VFC06PS ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', City__c = 'VFCQLI01City',*/ City_Postal_Code__c = cityCP.Id, Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202', Mandataire__c = mand1.id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', En_cours_d_immatriculation__c=true);
            insert a;
            
            
            Account g = new Account(Name='opti_horscorse ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', City__c = 'VFCQLI01City',*/ City_Postal_Code__c = cityCP.Id, Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202', Mandataire__c = mand1.id,is_groupement__c =TRUE,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', En_cours_d_immatriculation__c=true);
            insert g;
            
            // Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            // insert c;
            
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
        
            //Contract ctr = new Contract(AccountId = a.Id, StartDate = Date.today() - 365,ContractTerm = 12);
            //insert ctr;
            
            /* MLC Ajout contrat */
            
          		Account f = new Account(Name='fide ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', City__c = 'VFCQLI01City',*/ City_Postal_Code__c = cityCP.Id, Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202', Mandataire__c = mand1.id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', En_cours_d_immatriculation__c=true);
            	insert f;
            
          /*   Account pro = new Account(Name='pro', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', City__c = 'VFCQLI01City', City_Postal_Code__c = cityCP.Id, Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202', Mandataire__c = mand1.id,is_groupement__c =TRUE,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
       insert pro;*/
            
            
              // New Contact
        Contact Cc  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = f.Id,Street_Number__c = f.Street_Number__c,Postal_Box__c = f.Postal_Box__c,
                                 Postal_Code__c = f.Postal_Code__c,City__c = f.City__c,Email = f.Email__c,Email_2__c = f.Email_2__c,
                                 Fax = f.Fax,Place_Called__c = f.Place_Called__c,Country__c = f.Country__c,Phone = f.Phone);
        /*Contact Cpro  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = pro.Id,Street_Number__c = pro.Street_Number__c,Postal_Box__c = pro.Postal_Box__c,
                                 Postal_Code__c = pro.Postal_Code__c,City__c = pro.City__c,Email = pro.Email__c,Email_2__c = pro.Email_2__c,
                                 Fax = pro.Fax,Place_Called__c = pro.Place_Called__c,Country__c = pro.Country__c,Phone = pro.Phone);*/
            
            insert new list<Contact>{Cc,c} ;
        
      
        
        Contract contract = new Contract(AccountID=f.id,Status='Draft',Startdate=date.today(),ContractTerm=15);
        insert contract;
        Account_in_Contract__c ac1 = new Account_in_Contract__c(Account__c = f.id, Contract__c = contract.id, Role__c = 'AG');
        //insert  ac1;
        Account_in_Contract__c ac2 = new Account_in_Contract__c(Account__c = f.id, Contract__c = contract.id, Role__c = 'AG');
            insert new list<Account_in_Contract__c> {ac1,ac2} ;
        
        
        List<Contract> contracts = new List<Contract>();
        contracts.add(contract);
       
            
        /* fin ajout contrat */
            
            
            // PTL
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                //City__c = 'VFC06PS City 2',
                //Postal_Code__c = '09876',
                City_Postal_Code__c = cityCP.Id
            );
            insert ptl1;
            
            // Actions Commerciales
            Action_Commerciale__c acm1 = new Action_Commerciale__c(
                Cible_Not_Needed__c = true,
                Contract_Duration__c = '5',
                DPE_Not_Needed__c = true,
                End_Date__c = Date.today() + 15,
                Libelle__c = 'ACTEST1',
                Locked_Price__c = true,
                Offered_Months__c = 3,
                Opportunity_Reason_Not_Needed__c = true,
                Project_Type__c = 'CREA',
                //RCE__c = 10,
                Start_Date__c = Date.today() - 15,
                T_Pack__c = 'IDEO',
                Tank_Property__c = 'Butagaz Owned Tank',
                Tank_Type__c = 'A',
                Client_Type_Not_Needed__c = TRUE,
                Prescriber_Not_Needed__c = TRUE,
                Collaborator_Not_Needed__c = TRUE,
                Account_Owner_Market_subtype_Not_Needed__c = TRUE,
                Client_Reenlistment__c = 'Contract',
                VAT_code__c = '1;2',
                QuantiteRestanteNonRequis__c= TRUE,
                RCE__c=0
            );
           // insert acm1;
            
              Action_Commerciale__c acm2 = new Action_Commerciale__c(
                Cible_Not_Needed__c = true,
                Contract_Duration__c = '5',
                DPE_Not_Needed__c = true,
                End_Date__c = Date.today() + 15,
                Libelle__c = 'ACTEST1',
                Locked_Price__c = true,
                Offered_Months__c = 3,
                Opportunity_Reason_Not_Needed__c = true,
                Project_Type__c = 'CREA',
                //RCE__c = 10,
                Start_Date__c = Date.today() - 15,
                T_Pack__c = 'OPTIMO',
                Tank_Property__c = 'Butagaz Owned Tank',
                Tank_Type__c = 'A',
                Client_Type_Not_Needed__c = TRUE,
                Prescriber_Not_Needed__c = TRUE,
                Collaborator_Not_Needed__c = TRUE,
                Account_Owner_Market_subtype_Not_Needed__c = TRUE,
                Client_Reenlistment__c = 'Contract',
                VAT_code__c = '1;2',
                QuantiteRestante__c=0,
				QuantiteRestanteMax__c=1500,
                QuantiteRestanteNonRequis__c= FALSE,
                RCE__c=0
            );
            
               Action_Commerciale__c acm3 = new Action_Commerciale__c(
                Cible_Not_Needed__c = true,
                Contract_Duration__c = '5',
                DPE_Not_Needed__c = true,
                End_Date__c = Date.today() + 15,
                Libelle__c = 'ACTEST1',
                Locked_Price__c = true,
                Offered_Months__c = 3,
                Opportunity_Reason_Not_Needed__c = true,
                Project_Type__c = 'FIDE',
                //RCE__c = 10,
                Start_Date__c = Date.today() - 15,
                T_Pack__c = 'IDEO',
                Tank_Property__c = 'Butagaz Owned Tank',
                Tank_Type__c = 'A',
                Client_Type_Not_Needed__c = TRUE,
                Prescriber_Not_Needed__c = TRUE,
                Collaborator_Not_Needed__c = TRUE,
                Account_Owner_Market_subtype_Not_Needed__c = TRUE,
                Client_Reenlistment__c = 'Contract',
                VAT_code__c = '1;2',
                QuantiteRestanteNonRequis__c= TRUE,
                RCE__c=0                       
            );
            insert  new list<Action_Commerciale__c> {acm1,acm2,acm3};
            
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
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Renter',
                Project_market_type__c='DOM',
                Account_Owner__c = f.Id,
                Existing_PTL__c = ptl1.Id
                //Contrat__c = ctr.Id
                );
          //  insert oOpty;
            
              // Add an Oppty Piquage
            Opportunity oOptyPiquage = new Opportunity(Name = 'TestOptyPiquage',
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
                T_Pack__c = 'OPTIMO',
                Client_Type__c = 'Renter',
                Opportunity_Reason__c = 'Piquage client',
                Project_market_type__c='PRO',
                Account_Owner__c = f.Id,
                Existing_PTL__c = ptl1.Id
                //Contrat__c = ctr.Id
                );
           // insert oOptyPiquage;
            
            
             // Add an Oppty
            Opportunity oOptyFide = new Opportunity(Name = 'OptyFide',
                Project_Type__c='FIDE', 
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
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Renter',
                Project_market_type__c='DOM',
                Contrat__c = contract.Id,
                Account_Owner__c = f.Id,
                Existing_PTL__c = ptl1.Id
                //Contrat__c = ctr.Id
                );
            
            // Add an Oppty Piquage
          /*  Opportunity oOptyPRO = new Opportunity(Name = 'TestOptyPRO',
                Project_Type__c='CREA', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = pro.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'PRO',
                Client_Type__c = 'Owner',
                Opportunity_Reason__c = 'Piquage client',
                Project_market_type__c='PRO'
                /*Contrat__c = ctr.Id
                );*/
            insert  new list<Opportunity>{oOptyFide,oOptyPiquage,oOpty};
            
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
			insert attCom;      
             
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
				Code_marche__c =  'P100'
            );
            //insert optyPTL1;
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
				Code_marche__c =  'P100'
            );
            
             //insert optyPTL3;
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = oOptyPiquage.Id, 
                PTL_Name__c = 'VFC06PS2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
				Code_marche__c =  'P100'
            );
            
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTLFide = new Opportunity_PTL__c(
                Opportunity__c = oOptyFide.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
                Code_marche__c =  'P100'
             );
            
               // Add Oppty PTLs
         /*   Opportunity_PTL__c optyPTLPro = new Opportunity_PTL__c(
                Opportunity__c = oOptypRO.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );*/
            
            //insert optyPTL2;
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2,optyPTL3,optyPTLFide };
            

            // PriceBooks & Products
            
            List<Pricebook2> pbkList = [select id, name from Pricebook2];
            for (Pricebook2 pbk: pbkList) {
                System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
            }
            
            List<Product2> prdList = new List<Product2>();
            List<Product2> prdList1 = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A', Auto_Add__c = false,Capacity__c=1); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A', Auto_Add__c = false);
            Product2 oProduct3 = new Product2(Name = 'SPPABOTS10',external_ID__c= 'SPPABOTS10',isactive=true,Family='Redevance', ProductCode='SPPABOTS10', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct4 = new Product2(Name = 'SPPABOTS11',external_ID__c= 'SPPABOTS11',isactive=true,Family='Redevance', ProductCode='SPPABOTS11', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c= '904P0001',isactive=true,Family='Produit', ProductCode='904P0001', is_crea__c=true, Auto_Add__c = false);
            Product2 oProduct6 = new Product2(Name = 'FS1',external_ID__c= 'FS1',isactive=true,Family='Redevance', ProductCode='FS1', is_crea__c=true, Auto_Add__c = false, Standardized_Form__c=true,Capacity__c=1,CapacityMin__c=0,CapacityMax__c=5);
            Product2 oProduct7 = new Product2(Name = 'FS2',external_ID__c= 'FS2',isactive=true,Family='Redevance', ProductCode='FS2', is_crea__c=true, Auto_Add__c = false, Standardized_Form__c=true,Capacity__c=1,CapacityMin__c=0,CapacityMax__c=5,Tank_Type__c='A');
           
            /*prdList.add(oProduct1);
            prdList1.add(oProduct1);
            prdList.add(oProduct2);
            prdList1.add(oProduct2);
            
            prdList.add(oProduct3);
            //prdList.add(oProduct4);
            //prdList.add(oProduct5);

            insert prdList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;*/
            
            prdList.add(oProduct1);
            prdList1.add(oProduct1);
            prdList.add(oProduct2);
            prdList1.add(oProduct2);
          
            
            prdList.add(oProduct3);
            prdList.add(oProduct4);
            prdList.add(oProduct5);
            prdList.add(oProduct6);
            prdList.add(oProduct7);

            insert prdList;
            /*insert oProduct3;
            insert oProduct4;
            insert oProduct5;*/
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList1) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
               
                pbeList.add(pbe);
                pbeList.add(pbe2);
               
            }
            insert pbeList;
            
            // Action Commerciale
            List<PricebookEntry> pbeList2 = new List<PricebookEntry>();
            PricebookEntry pbe3 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe4 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe5 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe6 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe7 = new PricebookEntry (Product2ID=oProduct5.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe8 = new PricebookEntry (Product2ID=oProduct5.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe9 = new PricebookEntry (Product2ID=oProduct6.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe10 = new PricebookEntry (Product2ID=oProduct6.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe11 = new PricebookEntry (Product2ID=oProduct7.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe12 = new PricebookEntry (Product2ID=oProduct7.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
      
            pbeList2.add(pbe3);
            pbeList2.add(pbe4);
            pbeList2.add(pbe5);
            pbeList2.add(pbe6);
            pbeList2.add(pbe7);
            pbeList2.add(pbe8);
            pbeList2.add(pbe9);
            pbeList2.add(pbe10);
            pbeList2.add(pbe11);
            pbeList2.add(pbe12);
            insert pbeList2;
            
            acm1.Articles__c = 'SPPABOTS10;SPPABOTS11';
            /*acm1.Offered_Redevance__c = 'SPPABOTS10';*/
            update acm1;
            acm3.Articles__c = 'SPPABOTS10;SPPABOTS11';
            update acm1;
            
            

            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='InitQuote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'F',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2'//,
				//T_LAT_ApprovalRequested__c=true,
				//T_LAT_Approved__c=true
            );
            
            Quote otherTestQuote = new Quote(OpportunityId = oOpty.Id, Name='OtherQuote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'F',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2'
            );
            OtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS');
            //update otherTestQuote;
            
            Quote thirdTestQuote = new Quote(OpportunityId = oOpty.Id, Name='ThirdQuote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'F',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2'
            );
            
             Quote QuotePiquage = new Quote(OpportunityId = oOptyPiquage.Id, Name='QuotePiquage', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'F',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2',
                QuantiteRestante__c=250,
                DO_Groupement__c=g.id,
                Action_Commerciale__c = acm1.Id

                                            
            );
            
             Quote QuoteFide = new Quote(OpportunityId = oOptyFide.Id, Name='QuoteFID', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'CART1',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = Cc.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2',
               QuantiteRestante__c=250,
               Action_Commerciale__c = acm3.Id      
            );
            /*   Quote QuotePro = new Quote(OpportunityId = oOptyPro.Id, Name='QuotePro', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c = 'V1GR',
                Product_Scale__c = 'PS',
                Ger_Consumption__c = 'B4',
                ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                Shipping_Condition__c = '01',
                VAT_code__c = '1;2'
            );*/
            
           
            
            insert new List<Quote> { initialQuote, OtherTestQuote, thirdTestQuote,QuotePiquage,QuoteFide };
            
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            Quote_PTL__c oQPTL3 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuotePiquage.Id AND Opportunity_PTL__c = :optyPTL3.Id];
            Quote_PTL__c oQPTL4 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteFide.Id AND Opportunity_PTL__c = :optyPTLFide.Id];
  			//Quote_PTL__c oQPTL5 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuotePro.Id AND Opportunity_PTL__c = :optyPTLPro.Id];
 
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL2.Id, Mis_Disposition__c = 'Tank sold by BTZ', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTL2.Id,Got_From_SAP__c=true
                ),
                    
                    new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTL2.Id,Got_From_SAP__c=true
                )
                    
            }; 
        
            insert lQLI; 
            
            for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }
            
            
            List<QuoteLineItem> lQLI3 = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuotePiquage.Id, Quantity = 1,Cyclical_Rebate_TTC__c=150,Cyclical_Rebate_Months__c=12,
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, Got_From_SAP__c = true ,VAT_Percentage__c=10,
                    Quote_PTL__c = oQPTL3.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                    
                    new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[5].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTL3.Id,Got_From_SAP__c=true
                )
                    
                
            }; 
                
                 for(QuoteLineItem o:lQLI3){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }
        
            insert lQLI3; 
            
        }
     }  
    
         @isTest static void  testVFC06_ProductSelector(){
            
             List<Quote> listequote = new List<Quote>([SELECT Id,name,Scale__c FROM Quote]);
             Quote oInitialQuote;
             Quote oThirdTestQuote;
             Quote oQuoteFide;
             for(Quote  qte :listequote){
                 system.debug('####### quote name : '+qte.name);
                 if( qte.name.startsWith('InitQuote')){
                     oInitialQuote=qte;
                 }
                if( qte.name.startsWith('ThirdQuote')){
                     oThirdTestQuote=qte;
                 }
                 if( qte.name.startsWith('QuoteFID')){
                     oQuoteFide=qte;
                 }
                 
             }
                       
            Action_Commerciale__c acm1 = [ SELECT Id FROM Action_Commerciale__c  WHERE Libelle__c like 'ACTEST1%'  LIMIT 1 ];
            Account f =  [ SELECT Id FROM Account   WHERE Name like 'fide%'  LIMIT 1] ;

            Test.startTest();
            
            PageReference pageRef = Page.VFP06_ProductSelector_Step1;
            pageRef.getParameters().put('id', oInitialQuote.id);
            pageRef.getParameters().put('onlyShowMode', 'true');
            Test.setCurrentPage(pageRef);
            
            // Quote with no Pricebook - will redirect to pricebook selection
            ApexPages.standardController sc = new ApexPages.standardController(oThirdTestQuote);
            // create an instance of the controller
            VFC06_ProductSelector myPageCon = new VFC06_ProductSelector(sc);
            PageReference   pg=myPageCon.initializePage();
            
            // Initialize page error: T_LAT_ApprovalRequested__c is true
            oThirdTestQuote.T_LAT_ApprovalRequested__c = true;
            update oThirdTestQuote;
            Boolean hasErrored = false;
            sc = new ApexPages.standardController(oThirdTestQuote);
            myPageCon = new VFC06_ProductSelector(sc);
            pg=myPageCon.initializePage();
            System.assertEquals(null, pg);

            // Starting Controller part
            sc = new ApexPages.standardController(oInitialQuote);
            // create an instance of the controller
            myPageCon = new VFC06_ProductSelector(sc);
            pg=myPageCon.initializePage();
            List<QuoteLineItem> lqli2=myPageCon.selectQuoteLineItemsQuery();    
            Boolean b = myPageCon.getUsesQuantity();
            b = myPageCon.getUsesPTLs();
            b = myPageCon.getUsesGerConsumption();
            b = myPageCon.getUsesConnectionType();
            b = myPageCon.getPTLsOK();
            b = myPageCon.GetisGEBCONS();
            b = myPageCon.GetisGEC();
            b = myPageCon.GetisGrosVrac();
            b = myPageCon.GetisGPLc();
            b = myPageCon.GetisGEB();
            b = myPageCon.GetisGERProprietaire();
            b = myPageCon.GetisGERUsager();
            b = myPageCon.GetisGECProprietaire();
            b = myPageCon.GetisGECLocataire();
            b = myPageCon.GetisGECPack();
            b = myPageCon.GetisGECPackSansOptimo();
            b = myPageCon.GetisGECOPTIMO();
             
            myPageCon.calculateHT(10, 2);
        
             // Starting Controller part
            sc = new ApexPages.standardController(oQuoteFide);
            // create an instance of the controller
            myPageCon = new VFC06_ProductSelector(sc);
            pg=myPageCon.initializePage();
            myPageCon.getNumberOfMonthsRemainingOnContract();
           
            List<selectOption> lso=myPageCon.getPtls();
            Integer i=myPageCon.getPTLSize();
        
            //pg=myPageCon.saveForm();
            String s=myPageCon.getClientType();
            myPageCon.searchClause.isNotPack=false;
            pg=myPageCon.search();
            
            pg=myPageCon.refresh();

            b=AP_PricingUtilities.getQuoteIsNotPack(oInitialQuote);
        
            pg=myPageCon.lAvailableProducts[0].add();
            
            myPageCon.lSelectedProducts[0].setGerConsumption('aba');
            s=myPageCon.lSelectedProducts[0].getGerConsumption();
            myPageCon.lSelectedProducts[0].setMisADisposition('Butagaz Owned Tank');
            s=myPageCon.lSelectedProducts[0].getMisADisposition();
            myPageCon.lSelectedProducts[0].setSQuantity('1');
            s=myPageCon.lSelectedProducts[0].getSQuantity();
            myPageCon.lSelectedProducts[0].setTankPlacing('E');
            s=myPageCon.lSelectedProducts[0].getTankPlacing();
            b=myPageCon.lSelectedProducts[0].getReadyForSap();   
            myPageCon.lSelectedProducts[0].setTankPumpingRequired('Customer');
            s=myPageCon.lSelectedProducts[0].getTankPumpingRequired();
            myPageCon.lSelectedProducts[0].setBioProduct('CC');
            s=myPageCon.lSelectedProducts[0].getBioProduct();
 			b=myPageCon.getTankInfoOK();
            b=myPageCon.getScaleAndTanksOK();
            pg=myPageCon.lSelectedProducts[0].remove();
        
            pg=myPageCon.lAvailableProducts[0].add();
            QuoteLineItem qu=myPageCon.lSelectedProducts[0].getLineItem();
            
            pg=myPageCon.firstPage() ;
            //pg=myPageCon.previousPage() ;
            pg=myPageCon.NextPage() ;
            pg=myPageCon.lastPage() ;
            b=myPageCon.getHasPrevious() ;
            b=myPageCon.getHasNext();
            I=myPageCon.getDisplayPageIndex();
            I=myPageCon.getDisplayPageNumber();
            b=myPageCon.getHasSelectedProducts() ;
            b=myPageCon.getHasAvailableProducts();
            b=myPageCon.getAllSelectedProductsValid();
            b=myPageCon.GetShowAddStandardizedFormProductsBtn();
            myPageCon.manageStandardizedFormProducts();
            
            myPageCon.searchClause.setProductCode('Test');
            myPageCon.searchClause.setProductName('Test');
            myPageCon.searchClause.familyName = 'Produit';
            myPageCon.searchClause.subTypeName = 'Citerne';
            myPageCon.searchClause.capacity = 10;
            pg =  myPageCon.search();
            pg =  myPageCon.clearFilters();
            
            //
            myPageCon.searchClause.familyName = 'Equipement';
            pg =  myPageCon.search();
            myPageCon.searchClause.familyName = 'Redevance';
            pg =  myPageCon.search();
            pg =  myPageCon.clearFilters();
            
            
            myPageCon.SearchClause.setProductName('Test');
            myPageCon.SearchClause.setProductName(null);
            myPageCon.SearchClause.setProductCode('Test');
            myPageCon.SearchClause.setProductCode(null);
            pg =  myPageCon.clearFilters();
        
            pg=myPageCon.refresh();
            b=AP_PricingUtilities.getQuoteIsNotPack(oInitialQuote);
        
            for(VFC06_ProductSelector.SelectedProduct o:myPageCon.lSelectedProducts){
                o.remove();
            }
            pg=myPageCon.search();
        
            pg=myPageCon.lAvailableProducts[0].add();
            System.debug('*********lAvailableProducts'+myPageCon.lAvailableProducts.size());
            System.debug('*********'+myPageCon.lAvailableProducts);
            System.debug('*********lSelectedProducts'+myPageCon.lSelectedProducts.size());
            System.debug('*********'+myPageCon.lSelectedProducts);
            
            // Action Commerciales
            List<Action_Commerciale__c> lAllACM = myPageCon.getAllAcMs();
            myPageCon.AcMId2Chosen = acm1.id;
            System.debug('### SelectAcM: AcMId values: AcMId2Chosen:' + myPageCon.AcMId2Chosen + ' acm1.id' + acm1.id);
            String quoteAC = myPageCon.getQuoteAC();
            System.debug('### SelectAcM: quoteAC:' + quoteAC);
            List<Action_Commerciale__c> lSelectedACM = myPageCon.getselectedAcM();
            
        
            // Navigate to step 1Bis
            pg=myPageCon.navigateToStep1Bis();
            pg=myPageCon.navigateToStep2();
            
            pg=myPageCon.Calculate();
            lqli2=myPageCon.makeListPendingLineItems();
        
            //  myPageCon.QuoteLineItemView lqliv;
            // lqliv=myPageCon.makeListPendingLineItemsView();
        
            b=myPageCon.getRenderTabTank();
            b=myPageCon.getRenderTabTankClient();
            b=myPageCon.getRenderTabGotFromSAP();
        
            lqli2=myPageCon.getlPendingTankLineItems();
            lqli2=myPageCon.getlPendingGotFromSAPExceptEquipementLineItems();
            //myPageCon.SelectedProduct=myPageCon.makeListSelectedProducts();
            pg=myPageCon.navigateBackToStep1();
            pg=myPageCon.navigateToStep1Bis();
            pg=myPageCon.navigateToStep2();
            pg=myPageCon.navigateToStep1();
          
            
            b = myPageCon.lPendingLineItemsView[0].getRCEToDisable();
            b = myPageCon.lPendingLineItemsView[0].getRCOMToDisable();
            b = myPageCon.lPendingLineItemsView[0].getRCONJToDisable();
            b = myPageCon.lPendingLineItemsView[0].getHasFamilyOfTypeProduct();
        
            b = myPageCon.getHasPendingLineItems();
            
            
            // Save form
            pg=myPageCon.saveForm();
            
            // Second part, continuing testing get methods with another quote (GEB CONS)
         //   oOpty.Client_Type__c = 'Owner';
         //   oOpty.DO_Postal_Code__c = null;
        //    oOpty.DO_City__c = null;
        //    update oOpty;
           
            
            Test.stopTest();
            
        
        
        System.Debug('### >>>>> testing class VFC06_ProductSelector_TEST.testVFC06_ProductSelector END <<<<<');    
    }    
       
    public static testmethod void testRecordType() {

        // Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire 1',
            ExternalID__c = 'VPS09',
            Active__c = true,
            MatriculeEnCours__c=6,
            Matricule_en_cours_GEB__c=7
        );
        insert mand1;

        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC50', ExternalID__c=50);
        insert AD_GEC;

        Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton1', INSEE_Code__c = '-_-_-', Mandataire__c = mand1.id);
        insert Canton1;

        City__c City1  = new City__c (Name = 'VFC06PS City11',  Canton__c = Canton1.Id, INSEE_Code__c = '-8__-');
        insert City1;

        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '98541', 
                   City__c = City1.Id, HEXAPOSTE_Code__c = '555', Code_Type__c = 'C');
        insert cityCP;
        
/*        Account a = new Account(Name='VFC06PS1 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
        City_Postal_Code__c = cityCP.Id, Email__c = 'VFCQLI01City@test.org', channel__c='CD',
        accountNumber='12345',Country__c='FR', Phone='0202020202', Mandataire__c = mand1.id,
        Espace_Client_Registration_URL__c = 'https://test.com/XXXXX', En_cours_d_immatriculation__c=true);
        insert a;
*/        
        Quote oOtherTestQuote = [SELECT Id FROM Quote WHERE Name like 'OtherQuote%'  LIMIT 1];
        Opportunity oOpty = [SELECT Id FROM Opportunity WHERE Name like 'TestOpty%'  LIMIT 1 ];
       //  PTL__c ptl1 = [ SELECT Id FROM PTL__c    LIMIT 1 ]; 
       //  Account a =  [ SELECT Id FROM Account   WHERE Name like 'VFC06PS%'  LIMIT 1] ;
        Test.startTest();
       
        ApexPages.standardController sc = new ApexPages.standardController(oOtherTestQuote);
            VFC06_ProductSelector  myPageCon = new VFC06_ProductSelector(sc);
             Boolean  b = myPageCon.GetisGEBCONS();
            b = myPageCon.GetisGEC();
            b = myPageCon.GetisGEB();
            b = myPageCon.getUsesPTLs();
          System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            oOtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GrosVrac');
            update oOtherTestQuote;
            b = myPageCon.GetisGrosVrac();
            oOtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GPLc');
            update oOtherTestQuote;
            b = myPageCon.GetisGPLc();
            oOtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GER Proprietaire');
            update oOtherTestQuote;
            b = myPageCon.GetisGERProprietaire();
            oOtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GER Usager');
            update oOtherTestQuote;
            b = myPageCon.GetisGERUsager();
            b = myPageCon.GetisGECProprietaire();
            b = myPageCon.getUsesPTLs();
            oOtherTestQuote.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEC LOCATAIRE');
            oOtherTestQuote.Contract_Duration__c = '1';
            oOpty.Client_Type__c = 'Renter';
            oOpty.DO_Postal_Code__c = null;
            oOpty.DO_City__c = null;
         //   oOpty.Account_Owner__c = a.id;
         //   oOpty.Existing_PTL__c = ptl1.id;
            update oOpty;
            update oOtherTestQuote;
            b = myPageCon.GetisGECLocataire();
            b = myPageCon.GetisGECPack();
            b = myPageCon.GetisGECECOCFT();
            b = myPageCon.GetisGECDOM();
            String optyProjectType = myPageCon.GetOptyProjectType();
            //String nbMonthsRemaining = myPageCon.getNumberOfMonthsRemainingOnContract();

		
            
            String userLocale = myPageCon.getLocalCurrencyFormat();
        
        Test.stopTest();
        
    }
         
    public static testmethod void testIncrement() {
        Test.startTest();
        AP_WrapperForSOAPCallPricing.justIncrement();
        Test.stopTest();
    }
    
  
}