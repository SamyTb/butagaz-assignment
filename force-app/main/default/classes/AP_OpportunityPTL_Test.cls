@isTest
public class AP_OpportunityPTL_Test{
    public static testmethod void updateTest(){
        
        System.Debug('### >>>>> testing class AP_OpportunityPTL_Test.updateTest <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOPT1',Alias='APOPT1',
            Email='APOPT1@shell.com',Username='APOPT1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        	
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Canton__c Canton1 = new Canton__c(name = 'Test Canton', INSEE_Code__c = '-_-_',Mandataire__c =  mandataire1.id);
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
                Project_market_subtype__c = 'Agriculture',
                Client_Type__c = 'Owner',
                Project_Type__c = 'CREA',
                Channel__c = 'Incoming call',
                LeadSource = 'Commercial',
                Project_City_Postal_Code__c = oPostalCode.Id,
                StageName = 'Prospecting',
                CloseDate = date.today(),
                T_Pack__c = ''
            );
            insert oOpportunity;
        	
        	Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c op = new Opportunity_PTL__c(
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Opportunity__c = oOpportunity.id,
            	Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'
			);
            insert op;
        	
            Test.startTest();
            update op;
            Test.stopTest(); 
        }
        System.Debug('### >>>>> testing class AP_OpportunityPTL_Test.updateTest END<<<<<');
    }
}