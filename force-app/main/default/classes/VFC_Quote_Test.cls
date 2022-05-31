@isTest
private class VFC_Quote_Test {

    static testMethod void testCalculateAndSaveSautDeTranche() {
        //Quote quote = [select Id from Quote where Id = '0Q0M0000000Hbjd'];
        System.Debug('### >>>>> testing class VFC_Quote_Test.testCalculateAndSaveSautDeTranche <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQT',Alias='VFCQT',
            Email='VFCQT@shell.com',Username='VFCQT@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            
        Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        
        Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
        
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
        Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
             
        insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };
        
        System.runAs(u) {
        
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
			insert attCom;      

            //Mandataire
              Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
              insert mandataire1;
              
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'VFCQT Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQT City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQT', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='VFCQT ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQTCity', Email__c = 'VFCQT@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='VFCQT Contact', AccountId = a.id);
           // insert c;
           
           
               
         // New Contact
         Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
         accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
         Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
         Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
         insert c;
            
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
                Postal_Code__c = '09876'
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
                Tank_Type__c = 'A'
            );
            insert acm1;
            
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
                PTL_Name__c = 'VFCQT1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL1;
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = 'VFCQT2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id,
                Code_marche__c =  'P100'
            );
            insert optyPTL2;
            

            // PriceBooks & Products
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFCQT',Description='Test Pricebook VFCQT', isActive=true);
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
            
            // Action Commerciale
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
            
            acm1.Articles__c = 'SPPABOTS10;SPPABOTS11';
            update acm1;
 
            

            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='VFCQT Quote', 
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
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL2.Id, Mis_Disposition__c = 'Tank sold by BTZ'
                )
            }; 
        
            insert lQLI; 
        
            for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }
            
            Test.startTest();
            // Starting Controller part
            ApexPages.StandardController sc = new ApexPages.standardController(initialQuote);
            // create an instance of the controller
            VFC_Quote myPageCon = new VFC_Quote(sc);
            myPageCon.calculateAndSaveSautDeTranche();
            optyPTL1.Emballage_Pivot__c = '0000000140';
            update optyPTL1;
            optyPTL2.Emballage_Pivot__c = '0000000140';
            update optyPTL2;
            myPageCon.calculateAndSaveSautDeTranche();
            Test.stopTest();
            
        }
        
        //VFC_Quote vfcQuote = new VFC_Quote(new ApexPages.standardController(quote));
        //vfcQuote.calculateAndSaveSautDeTranche();
    }
}