@isTest
public class AP_SyncOpportunityFromAccount_01_Test {
    
    
    @TestSetup
    public static void initest (){
        
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
        	Custom_Settings__c c12 = new Custom_Settings__c (name ='Espace_Client_AES_Iv',  value__c ='B8C90EBAD5941EA2BB0EFC');
        	Custom_Settings__c c13 = new Custom_Settings__c ( name ='Espace_Client_AES_Key', Value__c = 's4abEHNGXpOKCQkFmU6y+vSMZFPCa67FzjRrF7zA3Bc=');
        	Custom_Settings__c c14 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEB', Value__c = 'http://uat.client-bouteilles-pro.butagaz.fr/oneclickregistration/?code=');
        	Custom_Settings__c c15 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEC', Value__c = 'http://uat.espace-client.butagaz.fr/oneclickregistration/?code=');
        	Custom_Settings__c c16 = new Custom_Settings__c (name ='Espace_Client_Satisfaction_URL_GEB', Value__c = 'http://uat-client-bouteilles-pro.butagaz.fr/survey/answer?code=');
         	Custom_Settings__c c17 = new Custom_Settings__c ( name ='Espace_Client_Satisfaction_URL_GEC', Value__c = 'http://uat-espace-client.butagaz.fr/survey/answer?code=');
        
            //insert c1; insert c2;  insert c3;  insert c4; insert c5; insert c6; insert c7;
            insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11,c12,c13,c14,c15,c16,c17 };
        
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromAccountOnUpdate <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APSOA1',Alias='APSOA1',
            Email='APSOA1@shell.com',Username='APSOA1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        //Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert new List<Custom_Settings__c> { c1 };
                    
        System.runAs(u) {
        
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
        
            Canton__c Canton1 = new Canton__c(name = 'Test Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'Test City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(
                City__c = City1.Id,
                Code_Type__c = 'M',
                HEXAPOSTE_Code__c = '1234',
                Postal_Code__c = '16100'
            );
            insert oPostalCode;
        
            Account oAccount = new Account(
                Name = 'Test Account',
                Email__c = 'TestGenerator@test.org',Country__c='FR', Phone='0202020202'
            );
            insert oAccount;
            
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
            Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
            Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
            insert c;
        
            Opportunity oOpportunity = new Opportunity(
                Assign__c = false,
                Name = 'Test Opportunity',
                AccountId = oAccount.Id,
                Account_Billed__c = oAccount.Id,
              	Account_Payer__c = oAccount.Id ,
                Project_market_subtype__c = 'Agriculture',
                Client_Type__c = 'Owner',
                Project_Type__c = 'CREA',
                Channel__c = 'Incoming call',
                LeadSource = 'Commercial',
                Project_City_Postal_Code__c = oPostalCode.Id,
                StageName = 'Prospecting',
                CloseDate = date.today()
            );
            insert oOpportunity;
            
            Map<Id, Opportunity> mOpportunitysBeforeUpdate = new Map<Id, Opportunity>();
            mOpportunitysBeforeUpdate.put(oOpportunity.Id, oOpportunity);
        
            Map<Id, Opportunity> mOpportunitysAfterUpdate = new Map<Id, Opportunity>();
            mOpportunitysAfterUpdate.put(oOpportunity.Id, oOpportunity);
        }
            
            
    }
    
    
    public static testmethod void syncOpportunityFromAccountOnUpdate() {

        
         Map<Id, Opportunity> mOpportunitysBeforeUpdate = new Map<Id, Opportunity>([Select  Assign__c ,Name,AccountId,Account_Billed__c,Account_Payer__c,Project_market_subtype__c,Client_Type__c,Project_Type__c, Channel__c,LeadSource,Project_City_Postal_Code__c,StageName, CloseDate From Opportunity]);
           
         Map<Id, Opportunity> mOpportunitysAfterUpdate = new Map<Id, Opportunity>([Select  Assign__c ,Name,AccountId,Account_Billed__c,Account_Payer__c,Project_market_subtype__c,Client_Type__c,Project_Type__c, Channel__c,LeadSource,Project_City_Postal_Code__c,StageName, CloseDate From Opportunity]);
          
        
        
            Test.startTest();
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount(mOpportunitysBeforeUpdate, mOpportunitysAfterUpdate);
            Test.stopTest();
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromAccountOnUpdate END<<<<<');
    }
    
    public static testmethod void syncOpportunityFromAccountOnInsert() {
        
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromAccountOnInsert <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APSOA2',Alias='APSOA2',
            Email='APSOA2@shell.com',Username='APSOA2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
       // Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
       // insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        /*
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '884',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
        
            Canton__c Canton1 = new Canton__c(name = 'Test Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'Test City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            
            City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP1;      
        
             // Account
            Account Account1 = new Account(name = 'account1', RecordType = recordTypeAccount,
            Code_SIRET__c = '', En_cours_d_immatriculation__c = true, No_E_mail__c  = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert Account1 ;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = Account1.Id,Street_Number__c = Account1.Street_Number__c,Postal_Box__c = Account1.Postal_Box__c,
            Postal_Code__c = Account1.Postal_Code__c,City__c = Account1.City__c,Email = Account1.Email__c,Email_2__c = Account1.Email_2__c,
            Fax = Account1.Fax,Place_Called__c = Account1.Place_Called__c,Country__c = Account1.Country__c,Phone = Account1.Phone);
            insert c;
        
            Opportunity oOpportunity = new Opportunity(
                Assign__c = false,
                Name = 'Test Opportunity',
                AccountId = Account1.Id,
                Account_Billed__c = Account1.Id,
                Project_market_subtype__c = 'Agriculture',
                Client_Type__c = 'Owner',
                Project_Type__c = 'CREA',
                Channel__c = 'Incoming call',
                LeadSource = 'Commercial',
                Project_City_Postal_Code__c = cityCP1.Id,
                StageName = 'Prospecting',
                CloseDate = date.today()
                
            );
            insert oOpportunity;
            */
            List<Opportunity> lOpportunitys = new List<Opportunity>([Select  Assign__c ,Name,AccountId,Account_Billed__c,Account_Payer__c,Project_market_subtype__c,Client_Type__c,Project_Type__c, Channel__c,LeadSource,Project_City_Postal_Code__c,StageName, CloseDate From Opportunity]);
            
            //Opportunity opty = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, Project_Type__c, T_AccountRecordTypeName__c, StageName, RecordType.Name, AccountId,T_MandataireId__c FROM Opportunity WHERE Id = :oOpportunity .Id];
                                                        
                                                        
           // Mandataire__c mdt = [  SELECT id, MatriculeEnCours__c,ExternalID__c FROM Mandataire__c  WHERE id= :opty.T_MandataireId__c LIMIT 1];                 
            
            
            
            
            //lOpportunitys.add(oOpportunity);
        
            Test.startTest();
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount(lOpportunitys);
            Test.stopTest();
        }
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromAccountOnInsert END<<<<<');                
    }
    
    /*public static testmethod void syncOpportunityFromOpportunity() {
        
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromOpportunity <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APSOA3',Alias='APSOA3',
            Email='APSOA3@shell.com',Username='APSOA3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
       // Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
       // insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
           
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
        
            Canton__c Canton1 = new Canton__c(name = 'Test Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'Test City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(
                City__c = City1.Id,
                Code_Type__c = 'M',
                HEXAPOSTE_Code__c = '1234',
                Postal_Code__c = '16100'
            );
            insert oPostalCode;
        
            Account oAccount = new Account(
                Name = 'Test Account',
                Email__c = 'TestGenerator@test.org',Country__c='FR', Phone='0202020202'
            );
            insert oAccount;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
            Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
            Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
            insert c;
        
            Opportunity oOpportunity1 = new Opportunity(
                Assign__c = false,
                Name = 'Test Opportunity',
                AccountId = oAccount.Id,
                Account_Billed__c = oAccount.Id,
                Project_market_subtype__c = 'Agriculture',
                Client_Type__c = 'Owner',
                Project_Type__c = 'CREA',
                Channel__c = 'Incoming call',
                LeadSource = 'Commercial',
                Project_City_Postal_Code__c = oPostalCode.Id,
                StageName = 'Prospecting',
                CloseDate = date.today()
            );
            insert oOpportunity1;
            
            
            
            Map<Id, Opportunity> mOldOpportunitys = new Map<Id, Opportunity>([Select  Assign__c ,Name,AccountId,Account_Billed__c,Account_Payer__c,Project_market_subtype__c,Client_Type__c,Project_Type__c, Channel__c,LeadSource,Project_City_Postal_Code__c,StageName,DO_Payment_method__c, CloseDate From Opportunity]);
           // mOldOpportunitys.put(oOpportunity1.Id, oOpportunity1);
            List<Opportunity> listOppty = mOldOpportunitys.values();
            System.assert(!listOppty.isEmpty());
            Opportunity oOpportunity2 =((Opportunity) mOldOpportunitys.values().get(0)).clone(true);
           // Opportunity oOpportunity2 = oOpportunity1.clone(true);
            oOpportunity2.DO_AccountNumber__c = 'abcdefg123';
            oOpportunity2.DO_Salutation__c = 'Mr';
            oOpportunity2.DO_Name__c = 'Test';
            oOpportunity2.DO_Payment_method__c = '2';
            oOpportunity2.DO_Email__c = 'test@test.com';
            oOpportunity2.DO_Email_2__c = 'test@test.com';
            oOpportunity2.DO_No_E_mail__c = true;
            oOpportunity2.DO_Payment_Time_Code__c = 'time_code';
            oOpportunity2.DO_Payment_Time_Value__c = 'time_value';
            oOpportunity2.DO_Street_type__c = 'RUE';
            oOpportunity2.DO_Street_name__c = 'Street';
            oOpportunity2.DO_Street_N__c = '15';
            oOpportunity2.DO_City__c = 'City Name';
            oOpportunity2.DO_City_code__c = 'City Code';
            oOpportunity2.DO_City_Postal_Code__c = oOpportunity2.Project_City_Postal_Code__c;
            oOpportunity2.DO_Postal_Code__c = '1234';
            oOpportunity2.DO_Department__c = 'Paris';
            oOpportunity2.DO_Country__c = 'France';
            oOpportunity2.DO_Postal_Box__c = '1234';
            oOpportunity2.DO_Phone__c = '0123456789';
            oOpportunity2.DO_Mobile_Phone_Number__c = '0123456789';
            oOpportunity2.DO_Work_Phone_Number__c = '0123456789';
            oOpportunity2.DO_Phone_Restriction__c = 'O';
            oOpportunity2.DO_Number_extention__c = 'B';
            oOpportunity2.DO_Cedex__c = 'cedex';
            oOpportunity2.DO_Scale__c = 'R1';
            oOpportunity2.DO_Accounting_Manager_Value__c = 'AM Value';
            oOpportunity2.DO_Accounting_Manager_Code__c = 'AM Code';
            oOpportunity2.DO_Place_Called__c = 'Chateau';
            oOpportunity2.DO_Invoicing_Frequency__c = 'Monthly';
        
            Map<Id, Opportunity> mNewOpportunitys = new Map<Id, Opportunity>();
            mNewOpportunitys.put(oOpportunity2.Id, oOpportunity2);
        
            Test.startTest();
            AP_SyncOpportunityFromAccount_01.syncOpportunityFromOpportunity(mOldOpportunitys, mNewOpportunitys);
            Test.stopTest();
        }
        System.Debug('### >>>>> testing class AP_SyncOpportunityFromAccount_01_Test.syncOpportunityFromOpportunity END<<<<<');
    }*/
}