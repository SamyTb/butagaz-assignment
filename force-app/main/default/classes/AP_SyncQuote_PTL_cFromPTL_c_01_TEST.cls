@isTest
private class AP_SyncQuote_PTL_cFromPTL_c_01_TEST {

    static testMethod void myUnitTest() {
        System.Debug('### >>>>> testing class AP_SyncQuote_PTL_cFromPTL_c_01_TEST.myUnitTest <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APSQPP',Alias='APSQPP',
            Email='APSQPP@shell.com',Username='APSQPP@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c1, c9, c10, c11, c12 };   

    	System.runAs(u) {
        
            //Mandataire
             Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
             insert mandataire1;
         
         
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APSQPP Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APSQPP City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APSQPP', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APSQPP ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APSQPPCity', Email__c = 'APSQPP@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='APSQPP Contact', AccountId = a.id);
            //insert c;
            
                  
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
                City__c = 'APSQPP City 1',
                Postal_Code__c = '09876',
                Code_AC_administrator_New__c = attCom50.Id
            );
            insert ptl1;
            
            PTL__c ptl2 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'APSQPP City 2',
                Postal_Code__c = '09876',
                Code_AC_administrator_New__c = attCom50.Id
            );
            insert ptl2;
            
            
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
                PTL_Name__c = 'APSQPP1',
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
                PTL_Name__c = 'APSQPP2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                PTL__c = ptl2.id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'

            );
            insert optyPTL2;
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='VFC06PS Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = c.id
                );
            insert initialQuote;
        
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name, T_PTL_Id__c FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name, T_PTL_Id__c FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            
            List<Quote_PTL__c> ptlList = new List<Quote_PTL__c>();
            ptlList.add(oQPTL1);
            ptlList.add(oQPTL2);
            
                        
            Map<Id, Quote_PTL__c> mQuote_PTL_csBeforeUpdate = new Map<Id, Quote_PTL__c>();
            Map<Id, Quote_PTL__c> mQuote_PTL_csAfterUpdate = new Map<Id, Quote_PTL__c>();
            mQuote_PTL_csBeforeUpdate.put(oQPTL1.id, oQPTL1);
            mQuote_PTL_csAfterUpdate.put(oQPTL1.id, oQPTL1);
            Map<Id, PTL__c> mOldQuote_PTL_cs = new Map<Id, PTL__c>();
            Map<Id, PTL__c> mNewQuote_PTL_cs = new Map<Id, PTL__c>();
            mOldQuote_PTL_cs.put(ptl1.id, ptl1);
            mNewQuote_PTL_cs.put(ptl2.id, ptl2);
            
            
            
            Test.startTest();
            
            
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c(ptlList);
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c(mQuote_PTL_csBeforeUpdate,mQuote_PTL_csAfterUpdate);
            
            AP_SyncQuote_PTL_cFromPTL_c_01.propagatePTL_cToQuote_PTL_c(mOldQuote_PTL_cs, mNewQuote_PTL_cs);
            AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromQuote_PTL_c(mQuote_PTL_csBeforeUpdate,mQuote_PTL_csAfterUpdate);          
            
            Test.stopTest();
        }
        
        
        
        System.Debug('### >>>>> testing class AP_SyncQuote_PTL_cFromPTL_c_01_TEST.myUnitTest END <<<<<');
    }
}