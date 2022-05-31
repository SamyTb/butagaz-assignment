@isTest
//@isTest(SeeAllData=true)
private class VFC_NewQuote_01_TEST {

    static testMethod void VFC_NewQuote_01Test() {
        System.Debug('### >>>>> testing class VFC_NewQuote_01_TEST.VFC_NewQuote_01Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCNQ',Alias='VFCNQ',
            Email='VFCNQ@shell.com',Username='VFCNQ@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c cs1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { cs1 };
        
        System.runAs(u) {
            
            // PriceBook
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFCNQ',Description='Test Pricebook VFCNQ', isActive=true);
            insert pbk1;
            
            
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
                QuoteRecordType__c = '012D000000038Q8',
                OpportunityRecordType__c = '012D000000038Q3',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB Challenge Commercial',
                QuotePTLRecordType__c ='012D0000000374o'
            );
            rtList.add(rtotq);
            insert rtList;
            
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            
            //Activity_Domain__c Ad2 = [select id, name from Activity_Domain__c where ExternalID__c = 41 limit 1];
            Activity_Domain__c Ad2 = new Activity_Domain__c(name = 'GEB', ExternalID__c=41);
            insert Ad2;
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
            //RecordType rt = new RecordType(Name = 'Pro');
            
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
             insert mandataire1;
       
   
            Canton__c Canton1 = new Canton__c(name = 'VFCQT Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQT City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQT', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            List<Account> accountList = new List<Account>();
            Account a = new Account(Name='VFCNQ 1', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQTCity', Email__c = 'VFCQT@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
           // accountList.add(a);
                    
             // New Contact
          List<Contact> contactList = new List<Contact>();
          Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
          Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
          Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
          insert c;
         // contactList.add(c); 
          
         Account a2 = new Account(Name='VFCNQ 2', Market_Type__c = 'DOM', Activity_Domain__c = ad2.Id, 
         Postal_Code__c = '123', City__c = 'VFCNQCity', Email__c = 'VFCNQ@test.org', channel__c='CD',
         accountNumber='12346',Country__c='FR', Phone='0202020202');
           insert a2;
            //accountList.add(a2);
            //insert accountList;
            
           // Contact c = new Contact(Lastname='VFCNQ Contact', AccountId = a.id);
           // insert c;
           
           
            
          // New Contact
          Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = a2.Id,Street_Number__c = a2.Street_Number__c,Postal_Box__c = a2.Postal_Box__c,
          Postal_Code__c = a2.Postal_Code__c,City__c = a2.City__c,Email = a2.Email__c,Email_2__c = a2.Email_2__c,
          Fax = a2.Fax,Place_Called__c = a2.Place_Called__c,Country__c = a2.Country__c,Phone = a2.Phone);
         insert c2;    
         //contactList.add(c2);
            
            
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFCQT Mandataire',
                ExternalID__c = 'VFCQT',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFCQT City 2',
                Postal_Code__c = '09876',
                Account_Groupement__c = a.id
            );
            insert ptl1;
            
            Contract c1 = new Contract (AccountId = a2.id, Name = 'c1', Condition_for_Payment_Package_Code__c = 'Test Condition');
            insert c1;
            
            // Add an Oppty
            List<Opportunity> optyList = new List<Opportunity>();
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
                Existing_PTL__c = ptl1.id
                );
            //insert oOpty;
            optyList.add(oOpty);
            
            Opportunity oOpty2 = new Opportunity(Name = 'TestOpty2',
                Project_Type__c='FIDE', 
                DO_Activity_Domain__c= ad2.Id,
                DO_AccountNumber__c='12346',
                StageName='Open', 
                AccountId = a2.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Contrat__c = c1.id
                );
            //insert oOpty2;
            optyList.add(oOpty2);
            insert optyList;
 
            // Add Oppty PTLs
            List<Opportunity_PTL__c> optlList = new List<Opportunity_PTL__c>();
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFCQT1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );
            //insert optyPTL1;
            optlList.add(optyPTL1);
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFCQT2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );
            //insert optyPTL2;
            optlList.add(optyPTL2);
            insert optlList;
            
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = oOpty2.Id, 
                PTL_Name__c = 'VFCQT3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id
            );
            
            Test.startTest();
            // Starting Controller part
            ApexPages.StandardController sc = new ApexPages.standardController(oOpty);
            // create an instance of the controller
            VFC_NewQuote_01 myPageCon = new VFC_NewQuote_01(sc);
            PageReference pr = myPageCon.newQuote();
            
            sc = new ApexPages.standardController(oOpty2);
            myPageCon = new VFC_NewQuote_01(sc);
            pr = myPageCon.newQuote();
            insert optyPTL3;
            pr = myPageCon.newQuote();
            
            Test.stopTest();
            
        }
        
        System.Debug('### >>>>> testing class VFC_NewQuote_01_TEST.VFC_NewQuote_01Test END <<<<<');
    }
}