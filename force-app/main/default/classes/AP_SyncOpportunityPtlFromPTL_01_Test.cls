@isTest
public class AP_SyncOpportunityPtlFromPTL_01_Test {
    public static testmethod void createOpportunityPtlWithPtl() {
        
        System.Debug('### >>>>> testing class AP_SyncOpportunityPtlFromPTL_01_Test.createOpportunityPtlWithPtl <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='SOPFP1',Alias='SOPFP1',
            Email='SOPFP1@shell.com',Username='SOPFP1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
            
             //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
         
   
            Canton__c Canton1 = new Canton__c(name = 'SOPFP1 Canton', INSEE_Code__c = '-_-_',  Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'SOPFP1 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - SOPFP1', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='SOPFP1 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'SOPFP1City', Email__c = 'SOPFP1@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert a;
            
           // Contact c = new Contact(Lastname='SOPFP1 Contact', AccountId = a.id);
           // insert c;
           
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            
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
 
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
            insert attCom50;   
            
            Test.startTest();
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
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
            
            
            Map<Id, Opportunity_PTL__c> mOldOpportunity_PTL_cs = new Map<Id, Opportunity_PTL__c>();
            mOldOpportunity_PTL_cs.put(optyPTL1.id, optyPTL1);
            Map<Id, Opportunity_PTL__c> mNewOpportunity_PTL_cs = new Map<Id, Opportunity_PTL__c>();
            mNewOpportunity_PTL_cs.put(optyPTL2.id, optyPTL2);
            AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromOpportunity_PTL_c(mOldOpportunity_PTL_cs,mNewOpportunity_PTL_cs);
            
            
            
            Test.stopTest();
        }
        
        
    }
    
    public static testmethod void updatePtlInOpportunityPtl() {
        
        System.Debug('### >>>>> testing class AP_SyncOpportunityPtlFromPTL_01_Test.createOpportunityPtlWithPtl <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='SOPFP2',Alias='SOPFP2',
            Email='SOPFP2@shell.com',Username='SOPFP2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            //insert AD_GEC;
            Activity_Domain__c AD_OTH = new Activity_Domain__c(name = 'OTH', ExternalID__c=98);
            //insert AD_OTH;
            insert new List<Activity_Domain__c> { AD_GEC, AD_OTH };
            
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
         
        
            
            
            Code_NAF__c naf1 = new Code_NAF__c(name='NAF1', ExternalID__c = '99', 
                Market_Type__c = 'PRO', Market_Sub_Type__c = 'Domestique');
            //insert naf1;
            Code_NAF__c naf2 = new Code_NAF__c(name='NAF2', ExternalID__c = '98',
                Market_Type__c = 'DOM', Market_Sub_Type__c = 'Collectif');
            //insert naf2;
            insert new List<Code_NAF__c> { naf1, naf2 };
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'SOPFP2 Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'SOPFP2 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - SOPFP2', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            //insert cityCP;
            City_Postal_Code__c cityCP2 = new City_Postal_Code__c(Name = '01002 - SOPFP3', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01002', Code_Type__c = 'M');
            //insert cityCP2;
            insert new List<City_Postal_Code__c> { cityCP, cityCP2 };
            
            
            Account a = new Account(Name='SOPFP2 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'SOPFP2City', Email__c = 'SOPFP2@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert a;
            
            Account a2 = new Account(Name='SOPFP2 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_OTH.Id, 
                Postal_Code__c = '123', City__c = 'SOPFP1City', Email__c = 'SOPFP1@test.org', channel__c='CD',
                accountNumber='12346',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert a2;
            
            Account a3 = new Account(Name='SOPFP3 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_OTH.Id, 
                Postal_Code__c = '123', City__c = 'SOPFP1City', Email__c = 'SOPFP1@test.org', channel__c='CD',
                accountNumber='12347',Country__c='FR', Phone='0202020202',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert a3;
            //insert new List<Account> { a, a2, a3 };
            
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
             // New Contact
            Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a2.Id,Street_Number__c = a2.Street_Number__c,Postal_Box__c = a2.Postal_Box__c,
            Postal_Code__c = a2.Postal_Code__c,City__c = a2.City__c,Email = a2.Email__c,Email_2__c = a2.Email_2__c,
            Fax = a2.Fax,Place_Called__c = a2.Place_Called__c,Country__c = a2.Country__c,Phone = a2.Phone);
            insert c2;
            
            
             // New Contact
            Contact c3  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a3.Id,Street_Number__c = a3.Street_Number__c,Postal_Box__c = a3.Postal_Box__c,
            Postal_Code__c = a3.Postal_Code__c,City__c = a3.City__c,Email = a3.Email__c,Email_2__c = a3.Email_2__c,
            Fax = a3.Fax,Place_Called__c = a3.Place_Called__c,Country__c = a3.Country__c,Phone = a3.Phone);
            insert c3;
            
            //insert new List<Contact> { c, c2, c3 };
            
            
            
            
           // Contact c = new Contact(Lastname='SOPFP2 Contact', AccountId = a.id);
           // insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'SOPFP2 Mandataire',
                ExternalID__c = 'VPS01',
                Active__c = true
            );
            //insert mand1;
            
            Mandataire__c mand2 = new Mandataire__c(
                name = 'SOPFP3 Mandataire',
                ExternalID__c = 'VPS02',
                Active__c = true
            );
            //insert mand2;
            insert new List<Mandataire__c> { mand1, mand2 };
            
            // Attache_Commercial__c
            Attache_Commercial__c AttacheCommercial1 = new Attache_Commercial__c(Name = 'AC1 - AC1', Code_Groupe_Vendeur__c = 'AC1', Libelle_Groupe_Vendeur__c = 'AC1');
            Attache_Commercial__c AttacheCommercial2 = new Attache_Commercial__c(Name = 'AC2 - AC2', Code_Groupe_Vendeur__c = 'AC2', Libelle_Groupe_Vendeur__c = 'AC2');
            insert new List<Attache_Commercial__c> { AttacheCommercial1, AttacheCommercial2 };
            
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'SOPFP2 City 1',
                Postal_Code__c = '09876',
                Account_Groupement__c = a2.id,
                Address__c = 'Address 1',
                Blocking_Commands_ADV__c = '00',
                Blocking_Commands_General__c ='00' ,
                Blocking_Delivery_ADV__c = '00',
                Blocking_Delivery_General__c = '00',
                City_Postal_Code__c = cityCP.id,
                City_code__c = '01001',
                /*Code_AC_administrator__c = 'CAC1',
                Code_AC_administrator_value__c = 'CAC1',*/
                Code_AC_administrator_New__c = AttacheCommercial1.Id,
                Code_NACE__c = naf1.id,
                Code_NAF__c = naf1.id,
                Code_branche__c = 'branche1',
                Code_branche_value__c = 'branche1',
                Code_division__c = 'division1',
                Code_division_value__c = 'division1',
                Country__c = 'Bretagne ;-)',
                Customer_presence__c = false,
                Date_Connecting__c = Date.today(),
                Date_at_the_End_of_Dispensation__c = Date.today(),
                Seasonal_Date_of_Period_End__c = Date.today(),
                Seasonal_Date_of_Period_Start__c = Date.today(),
                Delivery_possible_in_absence_of_client__c = true,
                Department__c = '29',
                E_mail__c = 'test1@test.com',
                Estimated_or_Real_Capacity__c = 1,
                Etimated_or_Real_Consumption__c = 1,
                Fax_Number__c = '0102030405',
                First_and_Last_Name__c = 'Test 1',
                Gal_deletion_flag__c = true,
                Gasdeliverymode__c = 'Planned',
                Label__c = 'label1',
                Limitation_of_Tonnage__c = true,
                Limitation_of_Vehicle__c = 'A',
                Market_Sub_Type__c = 'Domestique',
                Market_type__c = 'PRO',
                Mobile_Phone_Number__c = '0601020304',
                Number_extention__c = 'C',
                Payment_Delay__c = 2,
                Period_Frequency__c = 2,
                Permanent_dispensation__c = true,
                Phone__c = '0102030405',
                Place_Called__c = 'Le Point 1',
                Postal_Box__c = '29',
                Scale__c = 'MSCL1A',
                Shipping_Condition__c = '01',
                Street_name__c = 'Rue du Test 1',
                Street_number__c =  '1',
                Street_type__c = 'RTE',
                Temporary_dispensation__c = true,
                Title__c = 'Title1',
                Value_added_tax_within_the_Community__c = 'Value1',
                Work_Phone_Number__c = '0504030201',
                Name = 'ptl1',
                PDF_Hours_of_delivery_not_possible__c = '08.00-09.00',
                Precheck_Truck_needed__c = false,
                Days_no_Delivery_possible__c = 'Tuesday'
            );
            //insert ptl1;
            
            PTL__c ptl2 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'SSOPFP2 City 1',
                Postal_Code__c = '09876'
            );
            //insert ptl2;
            
            PTL__c ptl3 = new PTL__c(
                Activity_Domain__c = AD_OTH.id,
                Mandataire__c = mand2.id,
                City__c = 'SOPFP2 City 2',
                Postal_Code__c = '09877',
                ADV_deletion_flag__c = true,
                Account_Groupement__c = a3.id,
                Address__c = 'Address 3',
                Blocking_Commands_ADV__c = '01',
                Blocking_Commands_General__c = '01',
                Blocking_Delivery_ADV__c = '01',
                Blocking_Delivery_General__c = '01',
                City_Postal_Code__c = cityCP2.id,
                City_code__c = '01002',
                /*Code_AC_administrator__c = 'CAC2',
                Code_AC_administrator_value__c = 'CAC2',*/
                Code_AC_administrator_New__c = AttacheCommercial2.Id,
                Code_NACE__c = naf2.id,
                Code_NAF__c = naf2.id,
                Code_branche__c = 'branche2',
                Code_branche_value__c = 'branche2',
                Code_division__c = 'division2',
                Code_division_value__c = 'division2',
                Country__c = 'France',
                Customer_presence__c = true,
                Date_Connecting__c = Date.today() -1,
                Date_at_the_End_of_Dispensation__c = Date.today() -1,
                Seasonal_Date_of_Period_End__c = Date.today() -1,
                Seasonal_Date_of_Period_Start__c = Date.today() -1,
                Delivery_possible_in_absence_of_client__c = false,
                Department__c = '06',
                E_mail__c = 'test2@test.com',
                Estimated_or_Real_Capacity__c = 2,
                Etimated_or_Real_Consumption__c = 2,
                Fax_Number__c = '0203040506',
                First_and_Last_Name__c = 'Test 2',
                Gal_deletion_flag__c = false,
                Gasdeliverymode__c = 'Routine',
                Label__c = 'label2',
                Limitation_of_Tonnage__c = false,
                Limitation_of_Vehicle__c = 'B',
                Market_Sub_Type__c = 'Collectif',
                Market_type__c = 'DOM',
                Mobile_Phone_Number__c = '0602020304',
                Number_extention__c = 'B',
                Payment_Delay__c = 3,
                Period_Frequency__c = 3,
                Permanent_dispensation__c = false,
                Phone__c = '0203040506',
                Place_Called__c = 'Le Point 2',
                Postal_Box__c = '39',
                Scale__c = 'MSCL1B',
                Shipping_Condition__c = '02',
                Street_name__c = 'Rue du Test 2',
                Street_number__c = '2',
                Street_type__c = 'RUE',
                Temporary_dispensation__c = false,
                Title__c = 'Title2',
                Value_added_tax_within_the_Community__c = 'Value2',
                Work_Phone_Number__c = '0403020100',
                Name = 'ptl3',
                PDF_Hours_of_delivery_not_possible__c = '07.00-08.00',
                Precheck_Truck_needed__c = true,
                Days_no_Delivery_possible__c = 'Monday'
            );
            //insert ptl3;
            insert new List<PTL__c> { ptl1, ptl2, ptl3 };
            
            
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
 
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
            insert attCom50;   
            
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS21',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL1;
            
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS22',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                PTL__c = ptl2.id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL2;
            
            Opportunity_PTL__c optyPTL3 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFC06PS23',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                PTL__c = ptl3.id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            //insert optyPTL3;
            insert new List<Opportunity_PTL__c> { optyPTL1, optyPTL2, optyPTL3 };
            
            
            optyPTL1.PTL__c = ptl1.id;
            
            Test.startTest();
            update optyPTL1;
            
            Map<Id, PTL__c> mOldPTL_cs = new Map<Id, PTL__c>();
            mOldPTL_cs.put(ptl1.id, ptl1);
            mOldPTL_cs.put(ptl2.id, ptl2);
            Map<Id, PTL__c> mNewPTL_cs = new Map<Id, PTL__c>();
            mNewPTL_cs.put(ptl1.id, ptl1);
            mNewPTL_cs.put(ptl2.id, ptl2);
            AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_cToOpportunity_PTL_c(mOldPTL_cs,mNewPTL_cs);
            mNewPTL_cs.clear();
            mOldPTL_cs.clear();
            mNewPTL_cs.put(ptl3.id, ptl1);
            mOldPTL_cs.put(ptl3.id, ptl3);
            AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_cToOpportunity_PTL_c(mOldPTL_cs,mNewPTL_cs);
            //AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields(optyPTL3,mOldPTL_cs,mNewPTL_cs);
            
            Test.stopTest();
            
            
        }
    }
}