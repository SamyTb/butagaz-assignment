@isTest
private class TLV_LeadMgr_Test {
    
    @testSetup static void setupData(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        /*System.runAs(u) {*/
            
            // PriceBook
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
            insert pbk1;
            
            // Custom settings
            // FolderId lookup on Document = polymorphic field (can lookup to a folder or a user). Docs will be added to the My Personal Documents folder
            Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
            
            //Custom_Settings__c c2 = new Custom_Settings__c (name='Pricing_EndPointURL',value__c = 'http://www.google.fr'); 
            //Custom_Settings__c c3 = new Custom_Settings__c (name='Pricing_Username',value__c = 'username'); 
            //Custom_Settings__c c4 = new Custom_Settings__c (name='Pricing_Password',value__c = 'password');
            //Custom_Settings__c c5 = new Custom_Settings__c (name='AutoAdd_Allowed',value__c = 'S000000132'); 
            //Custom_Settings__c c6 = new Custom_Settings__c (name='ACOfferedMonthsApplies',value__c = 'SPPABO0010;SPPABO0008'); 
            //Custom_Settings__c c7 = new Custom_Settings__c (name='AC_Prevent_Duplication_on_Articles',value__c = 'S000000132');
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            insert new List<Custom_Settings__c> { c1, c8, c9, c10, c11, c12 };
            
            
            Activity_Domain__c AD_ELE = new Activity_Domain__c(name = 'ELE', ExternalID__c = 40);
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            Activity_Domain__c AD_ECOCARB = new Activity_Domain__c(name = 'GEC', ExternalID__c = 39);
            Activity_Domain__c AD_GDB = new Activity_Domain__c(name = 'GEC', ExternalID__c = 50);
            Activity_Domain__c AD_SVC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 38);
            insert new List<Activity_Domain__c> { AD_ELE, AD_GEC, AD_ECOCARB, AD_GDB, AD_SVC };
            
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName='Televente_Electricite' LIMIT 1];
            
            //Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = '999',
                Active__c = true
            );
            insert mand1;
            
            Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            
            Account accMainGECDOM = new Account(
                Market_Type__c = 'DOM', 
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber = '12345',
                ExternalID__c = 'EXTIDTLV',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Payment_method__c = 'P',
                Salutation = 'M.',
                FirstName = 'FName1', 
                LastName = 'accGECDOM', 
                Activity_Domain__c = AD_GEC.Id, 
                Email__c = 'VFCQLI01City@test.org', 
                No_E_mail__c = false,
                Phone = '0116060606',
                Mobile_Phone_Number__c = '0616060606',
                Street_N__c = '22',
                Number_extention__c = 'Bis', 
                Street_type__c = 'rue',
                Street_name__c = 'hasard',
                City_Postal_Code__c = cityCP.Id,
                Country__c = 'FR'
            );
            /*Account accToTriggerErrors = new Account(
                FirstName = 'FName5', 
                LastName = 'LName5', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                //Postal_Code__c = '123', 
                //City__c = 'VFCQLI01City', 
                City_Postal_Code__c = cityCP.Id,
                Email__c = '', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                No_E_mail__c = true,
                channel__c = 'CD',
                accountNumber='12349',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );*/
            insert new List<Account> { accMainGECDOM };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (2) : ' + Limits.getQueries());
            
            //PTL
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainGECDOM.Id
            );
            insert ptl1;
            
            // Add an Opty
            Opportunity oOptyOwner = new Opportunity(
                Name = 'TestOptyOwner',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'New', 
                AccountId = accMainGECDOM.Id, 
                DO_AccountNumber__c = accMainGECDOM.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Owner',
                Energy_Source__c = 'TestEnergy',
                Project_market_type__c = 'DOM',
                Avez_vous_votre_Kbis__c = 'Oui'
            );
            insert new List<Opportunity> { oOptyOwner };
            
            // Add Attache commercial
            Attache_Commercial__c oAC = new Attache_Commercial__c(
                Name = 'AC1',
                Code_Groupe_Vendeur__c = 'AC1',
                Libelle_Groupe_Vendeur__c = 'AC1'
            );
            insert new List<Attache_Commercial__c> { oAC };

            // Add Opty PTLs
            List <Opportunity_PTL__c > optlList = new List < Opportunity_PTL__c > ();
            
            Opportunity_PTL__c optyPTLOwner1 = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwner.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = oAC.Id
            );
            optlList.add(optyPTLOwner1);
            if(optlList.size() > 0) insert optlList;
            
            // Products
            List<Product2> prdList1 = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12345', is_crea__c = true, Tank_Type__c = 'A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12346', is_crea__c = true, Tank_Type__c = 'A');
            Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c = '904P0001',isactive = true,Family = 'Produit', ProductCode = '904P0001', is_crea__c = true);
            Product2 oProduct6 = new Product2(Name = '000000000000000440',external_ID__c = '000000000000000440',isactive = true,Family = 'Produit', ProductCode = '000000000000000440', is_crea__c = true);
            prdList1.add(oProduct1);
            prdList1.add(oProduct2);
            
            prdList1.add(oProduct5);
            prdList1.add(oProduct6);
            
            //insert prdList;
            insert prdList1;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList1) {                
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (7) : ' + Limits.getQueries());
            
            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            
            // Add Quote
            List<Quote> quoteList = new List<Quote>();
            
            Quote QuoteOwner = new Quote(
                OpportunityId = oOptyOwner.Id,
                Name='QuoteOwner', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'CART1',
                Scale__c = 'OC',
                Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                VAT_code__c = '1',
                Code_promo_contrat_electricite__c = 'CODEPROMO'
            );
            quoteList.add(QuoteOwner);
            if(quoteList.size() > 0) insert quoteList;
            
            // QPTL
            Quote_PTL__c oQPTLOwner1 = new Quote_PTL__c();
            
            List<Quote_PTL__c> qptlList = [SELECT Id, Name, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c WHERE Quote__c = :quoteList AND Opportunity_PTL__c = :optlList];
            for (Quote_PTL__c oqptl: qptlList) {
                if(oqptl.Quote__c == QuoteOwner.Id && oqptl.Opportunity_PTL__c == optyPTLOwner1.Id){
                  oQPTLOwner1 = oqptl;
                }
            }
            
            // QLI
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                // QLI QuoteOwner
                  new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteOwner.Id, Quantity = 1, 
                      UnitPrice = 1, PricebookEntryId = pbeList[0].Id, IsTank__c = true,
                      Quote_PTL__c = oQPTLOwner1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                  ),
                  new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteOwner.Id, Quantity = 1, 
                      UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                      Quote_PTL__c = oQPTLOwner1.Id,Got_From_SAP__c=true
                  )
            }; 
            insert lQLI; 
            
            
            
            
            
            // Update opty with synced quote
            oOptyOwner.SyncedQuoteId = QuoteOwner.Id;
            update new List<Opportunity> { oOptyOwner };
            
            oOptyOwner.Reason__c = 'Reason';
            //oOptyOwner.Validation_start_date__c = system.today();
	        oOptyOwner.Contract_Start_Date__c = system.today();
            oOptyOwner.StageName = 'Closed Won';
            oOptyOwner.Opportunity_Won_Substage__c = 'Data validated by BO';
            update new List<Opportunity> { oOptyOwner };
            
            
        /*}*/
    
    }
    

    public static testmethod void testCreateLeadElectricityFromAccount(){
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadElectricityFromAccount <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        Account oAccGECDOM = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
        
        //Date inputDate = Date.Today();
        //String dateStr =  inputDate.format('dd/MM/yyyy')
        
        //String inputDate = Date.Today().format('dd/MM/yyyy');
        //String inputDate = Date.Today().format('yyyy-MM-dd HH:mm:ss');
        //Date dateFromInput = Date.Parse(inputDate);
        
        TLV_LeadMgr.createLeadFromAccount(oAccGECDOM.Id, '40', '', 'CODEELEC', 'DESCRIPTION');
        System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadElectricityFromAccount END <<<<<');
        
    }

    public static testmethod void testCreateLeadEcocarburantFromAccount(){
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadEcocarburantFromAccount <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        Account oAccGECDOM = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
        
        TLV_LeadMgr.createLeadFromAccount(oAccGECDOM.Id, '39', '', '', 'DESCRIPTION');
        System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadEcocarburantFromAccount END <<<<<');
        
    }

    public static testmethod void testCreateLeadGranulesFromAccount(){
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadGranulesFromAccount <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        Account oAccGECDOM = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
        
        TLV_LeadMgr.createLeadFromAccount(oAccGECDOM.Id, '50', '', '', 'DESCRIPTION');
        System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadGranulesFromAccount END <<<<<');
        
    }

    public static testmethod void testCreateLeadChauffageInstallationMaterielFromAccount(){
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadChauffageInstallationMaterielFromAccount <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        Account oAccGECDOM = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
        
        TLV_LeadMgr.createLeadFromAccount(oAccGECDOM.Id, '38', '', '', 'DESCRIPTION');
        System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadChauffageInstallationMaterielFromAccount END <<<<<');
        
    }
    
    
    public static testmethod void testCreateLeadElectricityFromOpty(){
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadElectricityFromOpty <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        List<Opportunity> lOptyGECDOM = [SELECT Id FROM Opportunity WHERE Name like 'TestOptyOwner%' LIMIT 1];
        
        Set<Id> lOptiesIds = new Set<Id>();
        for(Opportunity oOpty : lOptyGECDOM){
            lOptiesIds.add(oOpty.Id);
        }
        
        TLV_LeadMgr.createLeadElectricityFromOpty(lOptiesIds);
        System.debug(logginglevel.WARN,'### SOQL Queries used (4) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class TLV_LeadMgr_Test.testCreateLeadElectricityFromOpty END <<<<<');
        
    }

}