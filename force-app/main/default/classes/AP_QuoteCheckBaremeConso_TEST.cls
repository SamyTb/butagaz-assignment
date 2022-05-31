@isTest
//@isTest(seealldata=true)
private class AP_QuoteCheckBaremeConso_TEST {
    
    static List<Opportunity_PTL__c> optlList;
    
    static testMethod void AP_QuoteCheckBaremeConso_TEST() {
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APQCBC',Alias='APQCBC',
            Email='APQCBC@shell.com',Username='APQCBC@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c24 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEB', Value__c = 'http://uat.client-bouteilles-pro.butagaz.fr/oneclickregistration/?code=');
        Custom_Settings__c c25 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEC', Value__c = 'http://uat.espace-client.butagaz.fr/oneclickregistration/?code=');
        Custom_Settings__c c26 = new Custom_Settings__c (name ='Espace_Client_Satisfaction_URL_GEB', Value__c = 'http://uat-client-bouteilles-pro.butagaz.fr/survey/answer?code=');
         Custom_Settings__c c27 = new Custom_Settings__c ( name ='Espace_Client_Satisfaction_URL_GEC', Value__c = 'http://uat-espace-client.butagaz.fr/survey/answer?code=');
        insert new List<Custom_Settings__c> { c1, c8, c9, c10, c13, C24, C25, C26, C27 };
        
        System.runAs(u) {
            
            // Activity Domain
            Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c=41);
            insert AD_GEB;
            system.debug('AD_GEB freddy:'+AD_GEB);
            
            // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
            
           
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
   
            Canton__c Canton1 = new Canton__c(name = 'APQCBC Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'APQCBC City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APQCBC', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='APQCBC ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEB.Id, 
                Postal_Code__c = '123', City__c = 'APQCBCCity', Email__c = 'APQCBC@test.org', channel__c='CS',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
			Account a1 = [select Id, name, Activity_Domain__c, Activity_Domain__r.ExternalID__c, Activity_Domain__r.Name 
                          from Account where Id= :a.Id];
            
            Account PredecessorAccount = new Account(Name='APQCBCdd ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEB.Id, 
                Postal_Code__c = '123', City__c = 'APQCBCCity', Email__c = 'APQCBC@test.org', channel__c='CS',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert PredecessorAccount;
            
            //Contact c = new Contact(Lastname='APQCBC Contact', AccountId = a.id);
            //insert c;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            system.debug('Contact freddy:'+c);

            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APQCBC Mandataire',
                ExternalID__c = 'APC01',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEB.Id,
                Mandataire__c = mand1.id,
                City__c = 'APQCBC City 2',
                Postal_Code__c = '09876'
            );
            insert ptl1;
            
            Id OptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEB CONS').getRecordTypeId();
           
            // Add an Oppty
            Opportunity oOpty = new Opportunity(Name = 'TestOpty',
                Project_Type__c='SUCC', 
                DO_Activity_Domain__c= AD_GEB.Id,
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
                Client_Type__c = 'CS',
                Predecessor__c = PredecessorAccount.Id,
                recordtypeId = OptyRecordTypeId                                
                );
            insert oOpty;
            
            system.debug('oOpty.recordtypeId:'+oOpty.recordtypeId);
 
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
			insert attCom;      

            // Add Oppty PTLs
            optlList = new List<Opportunity_PTL__c>();
            
            //Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
            optlList.add(new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'QLI211',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
                Code_marche__c =  'P100'
            ));
            //insert optyPTL1;
            //Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
            optlList.add(new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'QLI212',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_marche__c =  'P100',
                Code_AC_administrator_New__c = attCom.Id
            ));
            //insert optyPTL2;
            
            insert optlList;
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='VFC06PS Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = c.id,
                //Estimated_consumption_CS_2__c = 10,
                Nb_Working_Weeks_Per_Year__c = 100,
                Consommation_estimee_Butane_13__c  = 200,
                Product_Scale__c = 'T6'
                );
            insert initialQuote;
            
            Quote initialQuote1 = new Quote(OpportunityId = oOpty.Id, Name='VFC06PS Quote 1', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                ContactId = c.id,
                //Estimated_consumption_CS_2__c = 10,
                Nb_Working_Weeks_Per_Year__c = 100,
                Consommation_estimee_Butane_13__c  = 200,
                Product_Scale__c = 'T5'
                );
            insert initialQuote1;

            List<Quote> testQuotesList = [select Id, OpportunityId, name, DO_Payment_method__c, Payment_spread__c, 
                Contract_Duration__c, ExpirationDate, Date_de_cotation__c, Date_debut_offre__c, 
                Scale__c, Ger_Consumption__c, ContactId, Estimated_consumption_CS_2__c, Product_Scale__c, 
                      Activity_Domain_ID__c, Client_Type__c, Nb_Working_Weeks_Per_Year__c, 
                      Consommation_calculee_Prop_Carb__c, Consommation_CP_per_Week__c, Consommation_CB_per_Week__c,
                       Consommation_G_per_Week__c, Consommation_BD_per_Week__c, Consommation_P_per_Week__c, DO_Groupement__c,
                       OptyRecordTypeId__c from Quote where Id IN (:initialQuote.Id, :initialQuote1.Id)];
            
            system.debug('testQuotesList 0 :'+testQuotesList[0].Estimated_consumption_CS_2__c);
            system.debug('testQuotesList 1 :'+testQuotesList[1].Estimated_consumption_CS_2__c);
            
            //List<Quote> testQuotesList = new List<Quote>();
            //testQuotesList.add(q);
        
            Test.startTest();
            AP_QuoteCheckBaremeConso.checkQuotesBaremeConso(testQuotesList, true);
            AP_QuoteCheckBaremeConso.checkQuotesBaremeConso(testQuotesList, false);
            Test.stopTest();    
        }
    }
}