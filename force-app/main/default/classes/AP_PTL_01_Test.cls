@isTest
public class AP_PTL_01_Test {
    
    public static void initCustomSettting(){
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        insert new List<Custom_Settings__c> { c1, c8, c9, c10, c11, c12,c13 };
            }
    
    public static testmethod void testPredecessorProcess(){
        
        
        initCustomSettting();
        // Data Model
        
        // Activity Domain
        //Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        Activity_Domain__c oAdd = new Activity_Domain__c(Name='GEB',ExternalID__c=41);
        insert oAdd;
        
        // Account Predecessor
        Account oAccPredecessor = new Account(name='AccPredecessor',
                                              Activity_Domain__c=oAdd.Id,AccountNumber='Z888888888',
                                              Postal_Code__c = '123', City__c = 'APCTRCity', 
                                              Market_Type__c = 'PRO',
                                              Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oAccPredecessor;
        
        // New Contact
        Contact cp  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                  accountId = oAccPredecessor.Id,Street_Number__c = oAccPredecessor.Street_Number__c,Postal_Box__c = oAccPredecessor.Postal_Box__c,
                                  Postal_Code__c = oAccPredecessor.Postal_Code__c,City__c = oAccPredecessor.City__c,Email = oAccPredecessor.Email__c,Email_2__c = oAccPredecessor.Email_2__c,
                                  Fax = oAccPredecessor.Fax,Place_Called__c = oAccPredecessor.Place_Called__c,Country__c = oAccPredecessor.Country__c,Phone = oAccPredecessor.Phone);
        insert cp;
        
        
        // New Account
        Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Predecessor__c=oAccPredecessor.Id,
                                      Channel__c='CS', Sub_Channel__c='GD', Segmentation__c='22', 
                                      Group_Code_Value__c='GRPCODE', Adherent_Central_Number__c='ADHNUM',Street_N__c='120',Number_extention__c='B',
                                      Street_type__c='RUE',Street_name__c='test', Phone='0302020202',Email__c='toto@titit.com',Country__c='FR');
        insert oNewAcc;  
        
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = oNewAcc.Id,Street_Number__c = oNewAcc.Street_Number__c,Postal_Box__c = oNewAcc.Postal_Box__c,
                                 Postal_Code__c = oNewAcc.Postal_Code__c,City__c = oNewAcc.City__c,Email = oNewAcc.Email__c,Email_2__c = oNewAcc.Email_2__c,
                                 Fax = oNewAcc.Fax,Place_Called__c = oNewAcc.Place_Called__c,Country__c = oNewAcc.Country__c,Phone = oNewAcc.Phone);
        insert c;
        
        // PTL Predecessor      
        PTL__c oPTLPredecessor = new PTL__c(Name = 'PTLPred', Account_DO__c=oAccPredecessor.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true,PTL_succession__c=true);
        insert oPTLPredecessor;
       
        
        // Brands
        Brand__c oBrand = new Brand__c(Name__c='Brand', Type__c='Nationale', Ordre_de_tri__c=1);
        insert oBrand;
        
        // Articles        
        Item__c oArticle = new Item__c(Name = 'Article', ExternalID__c='000000000000000100', No_BTZ__c=false); 
        insert oArticle;
        
        //Item__c oArticleBD = [Select Name,Id from item__c where ExternalID__c='000000000000000100'];
        
        // Inventory Pricing
        Inventory_Pricing__c oIP = new Inventory_Pricing__c(PTL__c=oPTLPredecessor.Id);
        insert oIP;
        
        // Inventory Pricing Brands
        Inventory_Pricing_Brand__c oIPB = new Inventory_Pricing_Brand__c(
            Brand__c=oBrand.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        insert oIPB;
        
        // Inventory Pricing Article
        Inventory_Pricing_Article__c oIPA = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPB.Id,
            Article__c=oArticle.Id,
            Bottle_Number__c=12,
            Charging_Price__c=10.0,
            Presence__c = true
        );
        insert oIPA;
        
        // Start test
        test.starttest();
        
        // New PTL      
        PTL__c oNewPTL = new PTL__c(Name = 'oNewPTL', Account_DO__c=oNewAcc.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oNewPTL;
            // Stop test        
        test.stoptest();
        // Check "Deactivate Flag" on PTL Predecessor
        PTL__c oPTLPredecessorToCheck = [select id, PTL_succession__c from PTL__c where Id = :oPTLPredecessor.Id];
        
        System.assertEquals(true, oPTLPredecessorToCheck.PTL_succession__c);
        
        // Check "Inventory Pricing" of New PTL
        list<Inventory_Pricing__c> lIPToCheck = new list<Inventory_Pricing__c>();
        for(Inventory_Pricing__c oIPToCheck:[select id from Inventory_Pricing__c where PTL__c = :oNewPTL.Id]){
            lIPToCheck.add(oIPToCheck);
        }
        
        System.assertEquals(1, lIPToCheck.size());
        
        // Test to feed PTL from DO
        PTL__c oUpdatedPTLFromDO = [select id,Code_Canal__c,Sous_canal__c,Nom_de_predecesseur__c,Matricule_du_predecesseur__c ,Segmentation__c ,Enseigne__c,Code_magasin__c, Street_number__c, Number_extention__c, Street_type__c, Street_name__c from PTL__c where id =:oNewPTL.id];
        System.assertEquals(oUpdatedPTLFromDO.Code_Canal__c, 'CS');  
        System.assertEquals(oUpdatedPTLFromDO.Sous_canal__c, 'GD');  
        System.assertEquals(oUpdatedPTLFromDO.Nom_de_predecesseur__c, 'AccPredecessor');  
        System.assertEquals(oUpdatedPTLFromDO.Matricule_du_predecesseur__c, 'Z888888888');  
        System.assertEquals(oUpdatedPTLFromDO.Segmentation__c, '22');  
        System.assertEquals(oUpdatedPTLFromDO.Enseigne__c, 'GRPCODE');  
        System.assertEquals(oUpdatedPTLFromDO.Code_magasin__c, 'ADHNUM');  
        System.assertEquals(oUpdatedPTLFromDO.Street_number__c, '120');  
        System.assertEquals(oUpdatedPTLFromDO.Street_name__c, 'test');
        
        //FRECA0 04/05/2015 : Commented because it doesn't work with the method ToLabel() used in AP_Account_01.updateConcatenatedAddressField(lAcc) 
        //System.assertEquals(oUpdatedPTLFromDO.Number_extention__c, 'B');
        //System.assertEquals(oUpdatedPTLFromDO.Street_type__c.toUpperCase(), 'RUE');
        
        
    
    }
    
    public static testmethod void testPTLMKTContact(){
        initCustomSettting();
        // Start test
       
            
            // Activity Domain
            //Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
            Activity_Domain__c oAdd = new Activity_Domain__c(Name='GEB',ExternalID__c=41);
        insert oAdd;
        
        // Account Predecessor
        Account oAccPredecessor = new Account(name='AccPredecessor', Activity_Domain__c=oAdd.Id,Market_Type__c = 'PRO',AccountNumber='Z888888888',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oAccPredecessor;
        
        // New Contact
        Contact cp  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                  accountId = oAccPredecessor.Id,Street_Number__c = oAccPredecessor.Street_Number__c,Postal_Box__c = oAccPredecessor.Postal_Box__c,
                                  Postal_Code__c = oAccPredecessor.Postal_Code__c,City__c = oAccPredecessor.City__c,Email = oAccPredecessor.Email__c,Email_2__c = oAccPredecessor.Email_2__c,
                                  Fax = oAccPredecessor.Fax,Place_Called__c = oAccPredecessor.Place_Called__c,Country__c = oAccPredecessor.Country__c,Phone = oAccPredecessor.Phone);
        insert cp;
        
        
        
        // New Account
        Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Market_Type__c = 'PRO',Predecessor__c=oAccPredecessor.Id,Channel__c='CS', Sub_Channel__c='GD', Segmentation__c='22', Group_Code_Value__c='GRPCODE', Adherent_Central_Number__c='ADHNUM',Street_N__c='120',Number_extention__c='B',Street_type__c='RUE',Street_name__c='test',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oNewAcc;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = oNewAcc.Id,Street_Number__c = oNewAcc.Street_Number__c,Postal_Box__c = oNewAcc.Postal_Box__c,
                                 Postal_Code__c = oNewAcc.Postal_Code__c,City__c = oNewAcc.City__c,Email = oNewAcc.Email__c,Email_2__c = oNewAcc.Email_2__c,
                                 Fax = oNewAcc.Fax,Place_Called__c = oNewAcc.Place_Called__c,Country__c = oNewAcc.Country__c,Phone = oNewAcc.Phone);
        insert c;
        
        
         test.starttest();
        // New PTL      
        PTL__c oNewPTL = new PTL__c(Contact_Marketing__c = NULL, Name = 'oNewPTL', Account_DO__c=oNewAcc.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oNewPTL;
        
        // Check New PTL
        list<PTL__c> lPTL = new list<PTL__c>();
        for(PTL__c oPTL:[SELECT Id, Account_DO__c, Contact_Marketing__c FROM PTL__c WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oNewPTL.Id]){
            lPTL.add(oPTL);
        }
        System.assertEquals(1, lPTL.size());
        
        // Call method
        AP_PTL_01.managePTLMKTContactELC(lPTL);
        
        PTL__c oPTLToTest = [select id, Contact_Marketing__c from PTL__c where id =:oNewPTL.id];
        System.assertNotEquals(oPTLToTest.Contact_Marketing__c, NULL);
        System.assertNotEquals(oPTLToTest.Contact_Marketing__c, '');
        
        // Stop test        
        test.stoptest();
        
    }
    
    public static testmethod void testUpdatePTLFromOPTL(){
        initCustomSettting();
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
                          Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
                          LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                          LanguageLocaleKey='fr');
        
        insert u;
        
        // PriceBook
        Id pb2StandardId = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
        insert pbk1;
        
        
        
        Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c = 41);
        insert new List<Activity_Domain__c> { AD_GEB };
            
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        
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
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                                                             City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        Account accGEBRE = new Account(
            Name = 'Name6',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GEB.Id, 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'VFCQLI01City@test.org', 
            //Mobile_Phone_Number__c = '+33616060606',
            Mobile_Phone_Number__c = '0616060606',
            Country__c = 'FR',
            Indicatif_Pays__c = '+33',
            channel__c = 'CD',
            accountNumber='12351',
            ExternalID__c='12351',
            Mandataire__c = mand1.Id,
            En_cours_d_immatriculation__c = true,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        insert new List<Account> { accGEBRE };
            
            
            Contact cGEBRE = new Contact(Lastname='ContactGEBRE', AccountId = accGEBRE.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
        insert new List<Contact> { cGEBRE };
            
            //PTL
            List <PTL__c> ptlList = new List <PTL__c> ();
        PTL__c ptl1 = new PTL__c(
            Activity_Domain__c = AD_GEB.id,
            Mandataire__c = mand1.id,
            City__c = 'VFC06PS City 2',
            Postal_Code__c = '09876',
            Account_DO__c = accGEBRE.Id,
            ExternalID__c=accGEBRE.ExternalID__c,
            Shipping_Condition__c=''
        );
        ptlList.add(ptl1);
        
        if(ptlList.size() > 0){
            insert ptlList;
        }
        
        // Add an Opty
        Opportunity oOptyGEBRE = new Opportunity(
            Name = 'TestOptyGEBRE',
            Project_Type__c = 'CREA', 
            DO_Activity_Domain__c = AD_GEB.Id,
            StageName = 'Open', 
            AccountId = accGEBRE.Id, 
            DO_AccountNumber__c = accGEBRE.accountNumber,
            CloseDate = Date.today(), 
            Project_City_Postal_Code__c = cityCP.Id, 
            DO_City_Postal_Code__c = cityCP.Id, 
            Assign__c = false, 
            OwnerId = u.id,
            DO_Payment_method__c = 'V', 
            Installation_date__c = Date.today() + 15,
            T_Pack__c = '',
            Client_Type__c = 'RE',
            Project_market_type__c = 'PRO',
            Validation_start_date__c = Date.today()
        );
        insert new List<Opportunity> { oOptyGEBRE };
            
            List <Opportunity_PTL__c > optlList = new List < Opportunity_PTL__c > ();
        // Add Opty PTL
        Opportunity_PTL__c optyPTLGEBRE = new Opportunity_PTL__c(
            Opportunity__c = oOptyGEBRE.Id, 
            PTL_Name__c = 'VFC06PS6',
            PTL_Street_Type__c = '456',
            PTL_Street_Name__c = '789',
            PTL_City_Postal_Code__c = cityCP.Id,
            PTL_Shipping_Condition__c='TT'
        );
        optlList.add(optyPTLGEBRE);
        
        if(optlList.size() > 0){
            insert optlList;
        }
        
        
        List<Quote> quoteList = new List<Quote>();
        Quote QuoteGEBRE = new Quote(
            OpportunityId = oOptyGEBRE.Id,
            Name='QuoteGEBRE', 
            DO_Payment_method__c = 'P',
            Payment_spread__c = 'Z010',
            Contract_Duration__c = '5',
            Pricebook2Id = pbk1.id,
            ExpirationDate = Date.today() + 10,
            Date_de_cotation__c = Date.today(),
            Date_debut_offre__c = Date.today(),
            Product_Scale__c = 'B0',
            Client_Reenlistment__c = 'Contract',
            T_LAT_Approved__c = true,
            Shipping_Condition__c = '01',
            ContactId = cGEBRE.Id
        );
        quoteList.add(QuoteGEBRE);
        
        if(quoteList.size() > 0){
            insert quoteList;
        }
        
        // Update opty with synced quote
        oOptyGEBRE.SyncedQuoteId = QuoteGEBRE.Id;
        update new List<Opportunity> { oOptyGEBRE };
            
            // Update opty again because it raises an error if the synchronisation and the modification of the StageName are done in the same update 
            oOptyGEBRE.StageName = 'Closed Won';
        oOptyGEBRE.Opportunity_Won_Substage__c = 'Data validated by BO';
        update new List<Opportunity> { oOptyGEBRE };     
            
            
            // Start test
            test.starttest();
        
        AP_PTL_01.updatePTLFromOPTL(ptlList);
        
        PTL__c oPTLToTest = [select id, Shipping_Condition__c from PTL__c where id =:ptl1.id];
        System.assertNotEquals(oPTLToTest.Shipping_Condition__c, optyPTLGEBRE.PTL_Shipping_Condition__c);
        
        // Stop test        
        test.stoptest();
        
    }
    
    public static testmethod void testupdateShippingConditionAccount(){
        
        // Start test
        test.starttest();
        initCustomSettting();
        
        // Activity Domain
        //Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        Activity_Domain__c oAdd = new Activity_Domain__c(Name='GEB',ExternalID__c=41);
        insert oAdd;
        
        // New Account
        Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Market_Type__c = 'PRO',Channel__c='CS', Sub_Channel__c='GD', Segmentation__c='22', Group_Code_Value__c='GRPCODE', Adherent_Central_Number__c='ADHNUM',Street_N__c='120',Number_extention__c='B',Street_type__c='RUE',Street_name__c='test',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oNewAcc;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = oNewAcc.Id,Street_Number__c = oNewAcc.Street_Number__c,Postal_Box__c = oNewAcc.Postal_Box__c,
                                 Postal_Code__c = oNewAcc.Postal_Code__c,City__c = oNewAcc.City__c,Email = oNewAcc.Email__c,Email_2__c = oNewAcc.Email_2__c,
                                 Fax = oNewAcc.Fax,Place_Called__c = oNewAcc.Place_Called__c,Country__c = oNewAcc.Country__c,Phone = oNewAcc.Phone);
        insert c;
        
        
        
        // New PTL      
        PTL__c oNewPTL = new PTL__c(Contact_Marketing__c = NULL, Name = 'oNewPTL', Account_DO__c=oNewAcc.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Shipping_Condition__c='02', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oNewPTL;
        
        // Check New PTL
        list<PTL__c> lPTL = new list<PTL__c>();
        for(PTL__c oPTL:[SELECT Id, Account_DO__c, Contact_Marketing__c FROM PTL__c WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oNewPTL.Id]){
            lPTL.add(oPTL);
        }
        System.assertEquals(1, lPTL.size());
        
        // Call method
        AP_PTL_01.updateShippingConditionAccount(lPTL);
        
        PTL__c oPTLToTest = [select id, Shipping_Condition__c from PTL__c where id =:oNewPTL.id];
        System.assertNotEquals(oPTLToTest.Shipping_Condition__c, NULL);
        System.assertNotEquals(oPTLToTest.Shipping_Condition__c, '');
        
        // Stop test        
        test.stoptest();
        
    }
    
    public static testmethod void testUpdateIdPredecessorInSucc(){
        
        // Start test
     
        
        initCustomSettting();
        
        // Activity Domain
        //Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        Activity_Domain__c oAdd = new Activity_Domain__c(Name='GEB',ExternalID__c=41);
        insert oAdd;
        
        
        // New Account
        Account oPredecesseurAcc  = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Market_Type__c = 'PRO',Channel__c='CS', Sub_Channel__c='GD', Segmentation__c='22', Group_Code_Value__c='GRPCODE', Adherent_Central_Number__c='ADHNUM',Street_N__c='120',Number_extention__c='B',Street_type__c='RUE',Street_name__c='test',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oPredecesseurAcc ;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = oPredecesseurAcc .Id,Street_Number__c = oPredecesseurAcc .Street_Number__c,Postal_Box__c = oPredecesseurAcc .Postal_Box__c,
                                 Postal_Code__c = oPredecesseurAcc .Postal_Code__c,City__c = oPredecesseurAcc .City__c,Email = oPredecesseurAcc .Email__c,Email_2__c = oPredecesseurAcc .Email_2__c,
                                 Fax = oPredecesseurAcc .Fax,Place_Called__c = oPredecesseurAcc .Place_Called__c,Country__c = oPredecesseurAcc .Country__c,Phone = oPredecesseurAcc .Phone);
        insert c;
        
        
        
        // New PTL      
        PTL__c oPredecesseurPTL = new PTL__c(Contact_Marketing__c = NULL, Name = 'oPredPTL', Account_DO__c=oPredecesseurAcc.Id, Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Shipping_Condition__c='02', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true,PTL_succession__c=true);
        insert oPredecesseurPTL;
        
        
        
         
        //test of putSegmentationScoringInEvent 
        RecordType rtGEB = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite GEB' LIMIT 1];
        
        Event oEventFromPTL = new Event(whatid=oPredecesseurPTL.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now(),Segmentation_Scoring__c=null);
        system.debug('oEventFromPTL: ->'+oEventFromPTL);
        insert oEventFromPTL;   
        
        
        // Check New PTL
        list<PTL__c> lPTL = new list<PTL__c>();
        for(PTL__c oPTL:[SELECT Id, Account_DO__c, Contact_Marketing__c FROM PTL__c WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oPredecesseurPTL.Id]){
            lPTL.add(oPTL);
        }
        
        
        System.assertEquals(1, lPTL.size());
        
        
        
        // New Account
        Account oSuccesseurAcc   = new Account(name='NewAcc', Activity_Domain__c=oAdd.Id, Market_Type__c = 'PRO',Channel__c='CS',Predecessor__c=oPredecesseurAcc.Id,Sub_Channel__c='GD', Segmentation__c='22', Group_Code_Value__c='GRPCODE', Adherent_Central_Number__c='ADHNUM',Street_N__c='120',Number_extention__c='B',Street_type__c='RUE',Street_name__c='test',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com');
        insert oSuccesseurAcc  ;
        
        // New Contact
        Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                  accountId = oSuccesseurAcc.Id,Street_Number__c = oSuccesseurAcc.Street_Number__c,Postal_Box__c = oSuccesseurAcc.Postal_Box__c,
                                  Postal_Code__c = oSuccesseurAcc.Postal_Code__c,City__c = oSuccesseurAcc.City__c,Email = oSuccesseurAcc.Email__c,Email_2__c = oSuccesseurAcc.Email_2__c,
                                  Fax = oSuccesseurAcc.Fax,Place_Called__c = oSuccesseurAcc.Place_Called__c,Country__c = oSuccesseurAcc.Country__c,Phone = oSuccesseurAcc.Phone);
        insert c2;
        List<Event> listEvtPred = New  List<Event> ([SELECT Id, WhatId, Subject FROM Event where Whatid =:oPredecesseurPTL.id]);
        
           test.starttest();
        // New PTL      
        PTL__c oSuccesseurPTL = new PTL__c(Contact_Marketing__c = NULL, Name = 'oSuccPTL', Account_DO__c=oSuccesseurAcc.Id,  Activity_Domain__c=oAdd.Id, City__c = 'City', Postal_Code__c = '12345', Shipping_Condition__c='02', 
                                           Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oSuccesseurPTL;
        
        // Check New PTL
        list<PTL__c> lPTL2 = new list<PTL__c>();
        for(PTL__c oPTL:[SELECT Id, Account_DO__c, Contact_Marketing__c FROM PTL__c WHERE Activity_Domain__r.ExternalID__c=41 AND Id = :oSuccesseurPTL.Id]){
            lPTL2.add(oPTL);
        }
        
        
        
         // Stop test        
        test.stoptest();
        List<Event> listEvtSucc = New  List<Event> ([SELECT Id, WhatId, Subject FROM Event where Whatid =:oSuccesseurPTL.id]);
        
        System.assert((listEvtPred.size()==listEvtSucc.size()), 'les évènements ne sont pas redescendu sur le successeur'); 
        
      //  update lPTL2;
        
        // Call method
        // AP_PTL_01.UpdateIdPredecessorInSucc(lPTL2);
        
       /* 
        PTL__c oPTLToTest = [select id, Shipping_Condition__c from PTL__c where id =:oSuccesseurPTL.id];
        System.assertNotEquals(oPTLToTest.Shipping_Condition__c, NULL);
        System.assertNotEquals(oPTLToTest.Shipping_Condition__c, '');
        */
       
       
        
    }
}