@isTest
private class AP_QuoteLineItem_02_Test {
    static testMethod void calculateTaxesInsertTest() {
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='QLI21',Alias='QLI21',
            Email='QLI21@shell.com',Username='QLI21@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'QLI21 Canton', INSEE_Code__c = '-_-_',Mandataire__c =  mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'QLI21 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - QLI21', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='QLI21 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'QLI21City', Email__c = 'QLI21@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='QLI21 Contact', AccountId = a.id);
            //insert c;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'QLI21 Mandataire',
                ExternalID__c = 'QLI01',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'QLI21 City 2',
                Postal_Code__c = '09876'
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

            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
            insert attCom50;   
            
            // Add Oppty PTLs
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'QLI211',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'QLI212',
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
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A');
            Product2 oProduct3 = new Product2(Name = 'SPPABOTS10',external_ID__c= 'SPPABOTS10',isactive=true,Family='Redevance', ProductCode='SPPABOTS10', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct4 = new Product2(Name = 'SPPABOTS11',external_ID__c= 'SPPABOTS11',isactive=true,Family='Redevance', ProductCode='SPPABOTS11', is_crea__c=true, Auto_Add__c = true);
            prdList.add(oProduct1);
            prdList.add(oProduct2);

            insert prdList;
            insert oProduct3;
            insert oProduct4;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
 
            

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
        
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            
            QuoteLineItem QLI = new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank',
                    VAT_Percentage__c = 10 
                ); 
        
            insert QLI; 
            
            Map<Id, QuoteLineItem> oldQLIs = new Map<Id, QuoteLineItem>();
            List<QuoteLineItem> newQLIs = new List<QuoteLineItem>();
        
        
            newQLIs.add(qli);
        
            Test.startTest();
            AP_QuoteLineItem_02.calculateTaxes(newQLIs, oldQLIs);
            Test.stopTest();    
        }
        
        
    }
    
    static testMethod void calculateTaxesUpdateTest() {
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='QLI22',Alias='QLI22',
            Email='QLI22@shell.com',Username='QLI22@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
        
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'QLI22 Canton', INSEE_Code__c = '-_-_',Mandataire__c =  mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'QLI22 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - QLI22', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='QLI22 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'QLI22City', Email__c = 'QLI22@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='QLI22 Contact', AccountId = a.id);
            //insert c;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'QLI22 Mandataire',
                ExternalID__c = 'QLI22',
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
                PTL_Name__c = 'QLI221',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom50.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'QLI222',
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
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A');
            Product2 oProduct3 = new Product2(Name = 'SPPABOTS10',external_ID__c= 'SPPABOTS10',isactive=true,Family='Redevance', ProductCode='SPPABOTS10', is_crea__c=true, Auto_Add__c = true);
            Product2 oProduct4 = new Product2(Name = 'SPPABOTS11',external_ID__c= 'SPPABOTS11',isactive=true,Family='Redevance', ProductCode='SPPABOTS11', is_crea__c=true, Auto_Add__c = true);
            prdList.add(oProduct1);
            prdList.add(oProduct2);

            insert prdList;
            insert oProduct3;
            insert oProduct4;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
 
            

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
        
        
            Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
            
            QuoteLineItem QLI = new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank',
                    VAT_Percentage__c = 10, Commercial_Rebate_HT__c = 100 
                ); 
        
            insert QLI; 
            
            Map<Id, QuoteLineItem> oldQLIs = new Map<Id, QuoteLineItem>();
            List<QuoteLineItem> newQLIs = new List<QuoteLineItem>();
        
        
            newQLIs.add(qli);
            
            QuoteLineItem qli2 = qli.clone();
            qli2.Commercial_Rebate_HT__c = 200;
            oldQLIs.put(qli.Id, qli2);
        
            Test.startTest();
            AP_QuoteLineItem_02.calculateTaxes(newQLIs, oldQLIs);
            Test.stopTest();
        }
    }
}