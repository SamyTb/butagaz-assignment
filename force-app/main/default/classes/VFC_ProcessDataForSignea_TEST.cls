@isTest
public class VFC_ProcessDataForSignea_TEST {
    
    
    @testSetup static void setupUser(){
        
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
            
            // We need to have a default record in object Signea__Circuit_Template__c
            Signea__Circuit_Template__c signeaCT = new Signea__Circuit_Template__c(
                Name = 'DefaultTemplate',
                Signea__default_template__c = true,
                Signea__Active__c = true
            );
            insert signeaCT;
            
          
            // Custom settings
            // FolderId lookup on Document = polymorphic field (can lookup to a folder or a user). Docs will be added to the My Personal Documents folder
            Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
            Custom_Settings__c c2 = new Custom_Settings__c (name='MaxNumberEvidenceFilesForSignea', value__c = '3');
            
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
            Custom_Settings__c c13 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_DOM_IDEO',value__c = '012D00000003Epc');
            Custom_Settings__c c14 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_GrosVrac',value__c = '012D0000000374b');
            insert new List<Custom_Settings__c> { c1, c2, c8, c9, c10, c11, c12, c13,c14 };
            
            /*OrganizationSettings__c orgSett = new OrganizationSettings__c(
                M3_to_KWH__c = 26.500,
                Tons_To_KWH__c = 13835,
                Lead_FieldAddress_AccountCityPostalCode__c = 'Test', 
                Lead_FieldAddress_AccountCountry__c = 'Test', 
                Lead_FieldAddress_AccountPlaceCalled__c = 'Test', 
                Lead_FieldAddress_AccountPostalBox__c = 'Test', 
                Lead_FieldAddress_AccountStreetName__c = 'Test', 
                Lead_FieldAddress_AccountStreetNumberExt__c = 'Test', 
                Lead_FieldAddress_AccountStreetNumber__c = 'Test', 
                Lead_FieldAddress_AccountStreetType__c = 'Test', 
                Lead_FieldAddress_ActivityDomain__c = 'Test', 
                Lead_FieldAddress_MarketType__c = 'Test', 
                Lead_FieldAddress_ProjectCityPostalCode__c = 'Test', 
                Lead_FieldAddress_ProjectCountry__c = 'Test', 
                Lead_FieldAddress_ProjectPlaceCalled__c = 'Test', 
                Lead_FieldAddress_ProjectPostalBox__c = 'Test', 
                Lead_FieldAddress_ProjectStreetName__c = 'Test', 
                Lead_FieldAddress_ProjectStreetNumberExt__c = 'Test', 
                Lead_FieldAddress_ProjectStreetNumber__c = 'Test', 
                Lead_FieldAddress_ProjectStreetType__c = 'Test', 
                Lead_FieldId_ExistingPTL__c = 'Test', 
                Lead_FieldRecordTypeId__c = 'Test', 
                Lead_ObjectId__c = 'Test', 
                OptyPTL_FieldPTL__c = 'Test', 
                PTLConsumptionProfile_ObjectId__c = 'TTT', 
                PTLConsumptionProfile_OpportunityId__c = 'Test', 
                PTLConsumptionProfile_QuotePTLId__c = 'Test', 
                Quote_FieldId_Contract_Duration__c = 'Test', 
                Quote_FieldId_Contract_Duration_old__c = 'Test', 
                Quote_FieldId_DO_Payment_method_old__c = 'Test', 
                Quote_FieldId_Facturation_calendar_old__c = 'Test', 
                Quote_FieldId_Payment_spread_old__c = 'Test', 
                Quote_FieldId_Product_Scale_old__c = 'Test', 
                Quote_FieldId_Shipping_Condition_old__c = 'Test', 
                Quote_FieldId_VAT_Code_old__c = 'Test', 
                Quote_FieldId_scale_old__c = 'Test', 
                Quote_ObjectId__c = 'Test', 
                Lead_Field_ClientType__c = 'Test', 
                Lead_Field_Predecessor__c = 'Test', 
                Lead_Field_ProjectType__c = 'Test', 
                OptyPTL_FieldId_RecordType__c = 'Test', 
                OptyPTL_RecordTypeId_GEB__c = 'Test', 
                Opty_FieldId_Billed__c = 'Test', 
                Opty_FieldId_ClientType__c = 'Test', 
                Opty_FieldId_Payer__c = 'Test', 
                ReportId_GeC_GeR_Res_Com_compte_A_A_1__c = 'Test', 
                RecordTypeId_GEB_Challenge__c = 'Test', 
                ReportId_GeC_GeR_Res_com_Cpt_c_mois_A_1__c = 'Test', 
                ReportId_GeC_GeR_Res_Com_Cpt_cum_ch_A_1__c = 'Test'
            );
            insert orgSett;*/
            
            // Scale documents
            Document scaleDoc1 = new Document(
                Body = Blob.valueOf('Some Text'),
                ContentType = 'application/jpg',
                DeveloperName = 'scaleDoc1',
                IsPublic = true,
                Name = 'scaleDoc1',
                FolderId = c1.value__c
              );
            Document scaleDoc2 = new Document(
                Body = Blob.valueOf('Some Text'),
                ContentType = 'application/jpg',
                DeveloperName = 'scaleDoc2',
                IsPublic = true,
                Name = 'scaleDoc2',
                FolderId = c1.value__c
              );
            Document scaleDoc3 = new Document(
                Body = Blob.valueOf('Some Text'),
                ContentType = 'application/jpg',
                DeveloperName = 'scaleDoc3',
                IsPublic = true,
                Name = 'scaleDoc3',
                FolderId = c1.value__c
            );
            insert new List<Document> { scaleDoc1, scaleDoc2, scaleDoc3 };
            
            
            // ContentVersion
            //Id cvId_CGV_GEC_DOM_SE = createContent();
            //System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea_TEST.createContent] cvId_CGV_GEC_DOM_SE = ' + cvId_CGV_GEC_DOM_SE);
            List<Id> lCvIds = createNContent(10);
            
            // DocumentsIds__c Custom Setting
            DocumentsIds__c d1 = new DocumentsIds__c (name = 'BaremeCiternes', Label__c = 'BaremeCiternes', DocumentId__c = scaleDoc1.Id);
            DocumentsIds__c d2 = new DocumentsIds__c (name = 'CART1_1', Label__c = 'Gazpart1', DocumentId__c = scaleDoc2.Id);
            DocumentsIds__c d3 = new DocumentsIds__c (name = 'OC', Label__c = 'Services+', DocumentId__c = scaleDoc3.Id);
            DocumentsIds__c d4 = new DocumentsIds__c (name = 'CGV_GEC_DOM_SE', Label__c = 'CGV_GEC_DOM_SE', DocumentId__c = lCvIds[0]);
            DocumentsIds__c d5 = new DocumentsIds__c (name = 'CGV_GEB_PRO_CS', Label__c = 'CGV_GEB_PRO_CS', DocumentId__c = lCvIds[1]);
            DocumentsIds__c d6 = new DocumentsIds__c (name = 'CGV_GEB_PRO_RE', Label__c = 'CGV_GEB_PRO_RE', DocumentId__c = lCvIds[2]);
            DocumentsIds__c d7 = new DocumentsIds__c (name = 'TechniqueEtSecurite', Label__c = 'TechniqueEtSecurite', DocumentId__c = lCvIds[3]);
            DocumentsIds__c d8 = new DocumentsIds__c (name = 'FichesDeDonneesSecurite', Label__c = 'FichesDeDonneesSecurite', DocumentId__c = lCvIds[4]);
            DocumentsIds__c d9 = new DocumentsIds__c (name = 'BouteillesCarburation', Label__c = 'BouteillesCarburation', DocumentId__c = lCvIds[5]);
            DocumentsIds__c d10 = new DocumentsIds__c (name = 'BAREME', Label__c = 'BAREME', DocumentId__c = lCvIds[6]);
            DocumentsIds__c d11 = new DocumentsIds__c (name = 'TEST', Label__c = 'TEST', DocumentId__c = lCvIds[7]);
            DocumentsIds__c d12 = new DocumentsIds__c (name = 'ECOCFT', Label__c = 'Gazpart2', DocumentId__c = lCvIds[8]);
            DocumentsIds__c d13 = new DocumentsIds__c (name = 'EC', Label__c = 'Services+', DocumentId__c = lCvIds[9]);
            insert new List<DocumentsIds__c> { d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13 };
            
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c = 41);
            insert new List<Activity_Domain__c> { AD_GEC, AD_GEB };

            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
           // RecordType rt_optyGecDomIdeo = [SELECT Id, Name FROM RecordType WHERE SobjectType='opportunity' AND DeveloperName='GEC_DOM_IDEO' LIMIT 1];
            
            //Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFC06PS Mandataire',
                ExternalID__c = '999',
                Active__c = true,
                Electronic_Signature_Email__c = 'electronic.signature@butagaz.com'
            );
            insert mand1;
            
            Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());

        	Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
			insert attCom;      

            Account accMainOwner = new Account(
                FirstName = 'FName1', 
                LastName = 'LName1', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12345',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accMainRenter = new Account(
                FirstName = 'FName2', 
                LastName = 'LName2', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City', */
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'CH',
                Indicatif_Pays__c = '+41',
                channel__c = 'CD',
                accountNumber='12346',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accRentersOwner = new Account(
                FirstName = 'FName3', 
                LastName = 'LName3', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City', */
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12347',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            //Account accWithoutMobilePhone = new Account(
            //  FirstName = 'FName4', 
            //  LastName = 'LName4', 
            //  Market_Type__c = 'DOM', 
            //  Activity_Domain__c = AD_GEC.Id, 
            //    /*Postal_Code__c = '123', 
            //    City__c = 'VFCQLI01City', */
            //    City_Postal_Code__c = cityCP.Id,
            //    Email__c = 'VFCQLI01City@test.org', 
            //    Mobile_Phone_Number__c = '',
            //    channel__c = 'CD',
            //    accountNumber='12348'
            //);
            Account accToTriggerErrors = new Account(
                FirstName = 'FName5', 
                LastName = 'LName5', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City', */
                City_Postal_Code__c = cityCP.Id,
                Email__c = '', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                No_E_mail__c = true,
                channel__c = 'CD',
                accountNumber='12349',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accGEBRE = new Account(
                /*FirstName = 'FName6', 
                LastName = 'LName6', */
                Name = 'Name6',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12351',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            Account accGEBCS = new Account(
                /*FirstName = 'FName7', 
                LastName = 'LName7', */
                Name = 'Name7',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12352',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            
             Account accGECPRO = new Account(
                /*FirstName = 'FName7', 
                LastName = 'LName7', */
                Name = 'Name7',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12352',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            
            insert new List<Account> { accMainOwner, accMainRenter, accRentersOwner/*, accWithoutMobilePhone*/, accToTriggerErrors, accGEBRE, accGEBCS, accGECPRO };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (2) : ' + Limits.getQueries());
            
            /*Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = a.id);
            insert c;*/
            Contact cGEBRE = new Contact(Lastname='ContactGEBRE', AccountId = accGEBRE.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            Contact cGEBCS = new Contact(Lastname='ContactGEBCS', AccountId = accGEBCS.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            Contact cGECPROP = new Contact(Lastname='ContactGECPRO', AccountId = accGECPRO.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            insert new List<Contact> { cGEBRE, cGEBCS,cGECPROP };
            
            /*Contract ctr = new Contract(AccountId = a.Id, StartDate = Date.today() - 365,ContractTerm = 48);
            insert ctr; */
            
            
            //PTL
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainOwner.Id
            );
            
              PTL__c ptl2 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accGECPRO.Id
            );
            
            insert new List<PTL__c>{ ptl1, ptl2 };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (3) : ' + Limits.getQueries());
            
            /*// Actions Commerciales
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
            insert acm1;*/
            
            // Add an Opty
            Opportunity oOptyOwner = new Opportunity(
              Name = 'TestOptyOwner',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accMainOwner.Id, 
                DO_AccountNumber__c = accMainOwner.accountNumber,
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
                Avez_vous_votre_Kbis__c = 'Oui',
                recordtypeId= c13.value__c
                /*Contrat__c = ctr.Id*/
            );
            Opportunity oOptyRenter = new Opportunity(
              Name = 'TestOptyRenter',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accMainRenter.Id, 
                DO_AccountNumber__c = accMainRenter.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Renter',
                Account_Owner__c = accRentersOwner.Id,
                Existing_PTL__c = ptl1.Id,
                Project_market_type__c = 'DOM',
                Avez_vous_votre_Kbis__c = 'Oui',
                recordtypeId= c13.value__c
                /*Contrat__c = ctr.Id*/
            );
            Opportunity oOptySUCC = new Opportunity(
              Name = 'TestOptyRenter',
                Project_Type__c = 'SUCC', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accMainOwner.Id, 
                DO_AccountNumber__c = accMainOwner.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Owner',
                Existing_PTL__c = ptl1.Id,
                Predecessor__c = accMainOwner.Id,
                Project_market_type__c = 'DOM',
                Avez_vous_votre_Kbis__c = 'Oui',
                recordtypeId= c13.value__c
                /*Contrat__c = ctr.Id*/
            );
            Opportunity oOptyToTriggerErrors = new Opportunity(
              Name = 'TestOptyToTriggerErrors',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accToTriggerErrors.Id, 
                DO_AccountNumber__c = accToTriggerErrors.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO',
                Client_Type__c = 'Owner',
                Existing_PTL__c = ptl1.Id,
                Predecessor__c = accMainOwner.Id,
                Project_market_type__c = 'DOM',
                Avez_vous_votre_Kbis__c = 'Oui',
                recordtypeId= c13.value__c
                /*Contrat__c = ctr.Id*/
            );
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
                //Existing_PTL__c = ptl1.Id,
                //Predecessor__c = accMainOwner.Id,
                Project_market_type__c = 'PRO',
                Avez_vous_votre_Kbis__c = 'Oui'
                /*Contrat__c = ctr.Id*/
            );
            Opportunity oOptyGEBCS = new Opportunity(
              Name = 'TestOptyGEBCS',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEB.Id,
                StageName = 'Open', 
                AccountId = accGEBCS.Id, 
                DO_AccountNumber__c = accGEBCS.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = '',
                Client_Type__c = 'CS',
                //Existing_PTL__c = ptl1.Id,
                //Predecessor__c = accMainOwner.Id,
                Project_market_type__c = 'PRO',
                Avez_vous_votre_Kbis__c = 'Oui'
                /*Contrat__c = ctr.Id*/
            );
            Opportunity oOptyOwnerECOCFT = new Opportunity(
                Name = 'TestOptyOwnerECOCFT',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accMainOwner.Id, 
                DO_AccountNumber__c = accMainOwner.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'ECOCFT',
                Client_Type__c = 'Owner',
                Energy_Source__c = 'TestEnergy',
                Project_market_type__c = 'DOM',
                Avez_vous_votre_Kbis__c = 'Oui',
                recordtypeId= c13.value__c
                /*Contrat__c = ctr.Id*/
            );
            
              Opportunity oOptyGECPRO = new Opportunity(
              Name = 'TestOptyRenter',
                Project_Type__c = 'CREA', 
                DO_Activity_Domain__c = AD_GEC.Id,
                StageName = 'Open', 
                AccountId = accGECPRO.Id, 
                DO_AccountNumber__c = accGECPRO.accountNumber,
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c = false, 
                OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = '',
                Client_Type__c = 'Owner',
                Existing_PTL__c = ptl2.Id,
                Project_market_type__c = 'PRO',
                Avez_vous_votre_Kbis__c = 'Oui'
               
            );
            insert new List<Opportunity> { oOptyOwner, oOptyRenter, oOptySUCC, oOptyToTriggerErrors, oOptyGEBRE, oOptyGEBCS, oOptyOwnerECOCFT,oOptyGECPRO };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (4) : ' + Limits.getQueries());
            
            List <Opportunity_PTL__c > optlList = new List < Opportunity_PTL__c > ();
            // Add Opty PTLs
            Opportunity_PTL__c optyPTLOwner1 = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwner.Id, 
                PTL_Name__c = 'VFC06PS1',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLOwner1);
            
            Opportunity_PTL__c optyPTLOwner2 = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwner.Id, 
                PTL_Name__c = 'VFC06PS2',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLOwner2);
            
            Opportunity_PTL__c optyPTLRenter1 = new Opportunity_PTL__c(
                Opportunity__c = oOptyRenter.Id, 
                PTL_Name__c = 'VFC06PS3',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLRenter1);
            
            Opportunity_PTL__c optyPTLSUCC1 = new Opportunity_PTL__c(
                Opportunity__c = oOptySUCC.Id, 
                PTL_Name__c = 'VFC06PS4',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLSUCC1);
            
            Opportunity_PTL__c optyPTLToTriggerErrors = new Opportunity_PTL__c(
                Opportunity__c = oOptyToTriggerErrors.Id, 
                PTL_Name__c = 'VFC06PS4',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLToTriggerErrors);
            Opportunity_PTL__c optyPTLGEBRE = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwner.Id, 
                PTL_Name__c = 'VFC06PS6',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLGEBRE);
            Opportunity_PTL__c optyPTLGEBCS = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwner.Id, 
                PTL_Name__c = 'VFC06PS7',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLGEBCS);
            Opportunity_PTL__c optyPTLOwnerECOCFT = new Opportunity_PTL__c(
                Opportunity__c = oOptyOwnerECOCFT.Id, 
                PTL_Name__c = 'VFC06PS8',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLOwnerECOCFT);
            
            Opportunity_PTL__c optyPTLGECPRO = new Opportunity_PTL__c(
                Opportunity__c = oOptyGECPRO.Id, 
                PTL_Name__c = 'VFC06PS8',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                Code_AC_administrator_New__c = attCom.Id
            );
            optlList.add(optyPTLGECPRO);
            
            
            //insert new List<Opportunity_PTL__c> { optyPTLOwner1, optyPTLOwner2, optyPTLRenter1, optyPTLSUCC1, optyPTLToTriggerErrors };
            if(optlList.size() > 0){
                insert optlList;
            }
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (5) : ' + Limits.getQueries());
            
            // Attachments on OPTLs (PlanImplantation)
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            
            Attachment attachoptyPTLOwner1 = new Attachment(    
                Name = 'Unit Test Attachment1',
                body = bodyBlob,
                parentId = optyPTLOwner1.id
            );
            Attachment attachoptyPTLOwner2 = new Attachment(    
                Name = 'Unit Test Attachment2',
                body = bodyBlob,
                parentId = optyPTLOwner2.id
            );
            Attachment attachoptyPTLRenter1 = new Attachment(    
                Name = 'Unit Test Attachment3',
                body = bodyBlob,
                parentId = optyPTLRenter1.id
            );
            Attachment attachoptyPTLSUCC1 = new Attachment(    
                Name = 'Unit Test Attachment4',
                body = bodyBlob,
                parentId = optyPTLSUCC1.id
            );
            Attachment attachoptyPTLOwnerECOCFT = new Attachment(    
                Name = 'Unit Test Attachment5',
                body = bodyBlob,
                parentId = optyPTLOwnerECOCFT.id
            );
            Attachment attachoptyPTLGECPRO = new Attachment(    
                Name = 'Unit Test Attachment6',
                body = bodyBlob,
                parentId = optyPTLGECPRO.id
            );
            insert new List<Attachment> { attachoptyPTLOwner1, attachoptyPTLOwner2, attachoptyPTLRenter1, attachoptyPTLSUCC1, attachoptyPTLOwnerECOCFT,attachoptyPTLGECPRO };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (6) : ' + Limits.getQueries());
            
            // PriceBooks & Products
            /*List<Pricebook2> pbkList = [select id, name from Pricebook2];
            for (Pricebook2 pbk: pbkList) {
                System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
            }*/
            
            //List<Product2> prdList = new List<Product2>();
            List<Product2> prdList1 = new List<Product2>();
            
            Product2 oProduct1 = new Product2(Name = 'p1',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12345', is_crea__c = true, Tank_Type__c = 'A'); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive = true,Family = 'Produit', Sub_Type__c = 'Citerne', ProductCode = '12346', is_crea__c = true, Tank_Type__c = 'A');
            //Product2 oProduct3 = new Product2(Name = 'SPPABOTS10',external_ID__c = 'SPPABOTS10',isactive = true,Family='Redevance', ProductCode = 'SPPABOTS10', is_crea__c = true, Auto_Add__c = true);
            //Product2 oProduct4 = new Product2(Name = 'SPPABOTS11',external_ID__c = 'SPPABOTS11',isactive = true,Family = 'Redevance', ProductCode = 'SPPABOTS11', is_crea__c = true, Auto_Add__c = true);
            Product2 oProduct5 = new Product2(Name = '904P0001',external_ID__c = '904P0001',isactive = true,Family = 'Produit', ProductCode = '904P0001', is_crea__c = true);
            Product2 oProduct6 = new Product2(Name = '000000000000000440',external_ID__c = '000000000000000440',isactive = true,Family = 'Produit', ProductCode = '000000000000000440', is_crea__c = true);
            //prdList.add(oProduct1);
            prdList1.add(oProduct1);
            //prdList.add(oProduct2);
            prdList1.add(oProduct2);
            
            //prdList.add(oProduct3);
            //prdList.add(oProduct4);
            //prdList.add(oProduct5);
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
            
            /*// PricebookEntry
            List<PricebookEntry> pbeList2 = new List<PricebookEntry>();
            PricebookEntry pbe3 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe4 = new PricebookEntry (Product2ID=oProduct3.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            PricebookEntry pbe5 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
            PricebookEntry pbe6 = new PricebookEntry (Product2ID=oProduct4.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
            pbeList2.add(pbe3);
            pbeList2.add(pbe4);
            pbeList2.add(pbe5);
            pbeList2.add(pbe6);
            insert pbeList2;*/
            
            //acm1.Articles__c = 'SPPABOTS10;SPPABOTS11';
            /*acm1.Offered_Redevance__c = 'SPPABOTS10';*/
            //update acm1;
            
            
            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            
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
                VAT_code__c = '1'
            );
            quoteList.add(QuoteOwner);
        
            Quote QuoteRenter = new Quote(
                OpportunityId = oOptyRenter.Id, 
                Name='QuoteRenter', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'CART1',
                Scale__c='OC',
                Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                VAT_code__c = '1'
            );
            quoteList.add(QuoteRenter);
        
            Quote QuoteSUCC = new Quote(
                OpportunityId = oOptySUCC.Id,
                Name='QuoteSUCC', 
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
                VAT_code__c = '1'
            );
            //Quote2.RecordTypeId = AP_PricingUtilities.getQuoteRecordTypeValue('GEB CONS');
            quoteList.add(QuoteSUCC);
        
            Quote QuoteToTriggerErrors = new Quote(
                OpportunityId = oOptyToTriggerErrors.Id, 
                Name='QuoteToTriggerErrors', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'CART1',
                Scale__c='OC',
                Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = false,
                Shipping_Condition__c = '01',
                Signea_Date_Signature__c = Date.today(),
                VAT_code__c = '1'
            );
            quoteList.add(QuoteToTriggerErrors);

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
                //Scale__c = '',
                //Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                ContactId = cGEBRE.Id,
                VAT_code__c = '1'
            );
            quoteList.add(QuoteGEBRE);

            Quote QuoteGEBCS = new Quote(
                OpportunityId = oOptyGEBCS.Id,
                Name='QuoteGEBCS', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'T0',
                //Scale__c = '',
                //Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                ContactId = cGEBCS.Id,
                VAT_code__c = '1'
            );
            quoteList.add(QuoteGEBCS);
            
            Quote QuoteOwnerECOCFT = new Quote(
                OpportunityId = oOptyOwnerECOCFT.Id,
                Name='QuoteOwnerECOCFT', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'ZN12',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'ECOCFT',
                Scale__c = 'EC',
                Ger_Consumption__c='B4',
                //ContactId = c.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                VAT_code__c = '1'
            );
            quoteList.add(QuoteOwnerECOCFT);
            
            
             Quote QuoteGECPRO = new Quote(
                OpportunityId = oOptyGECPRO.Id, 
                Name='QuoteGECPRO', 
                DO_Payment_method__c = 'P',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '1',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Product_Scale__c = 'V1PRO',
                Scale__c='V2',
                Ger_Consumption__c='B4',
                ContactId = cGECPROP.id,
                Client_Reenlistment__c = 'Contract',
                T_LAT_Approved__c = true,
                Shipping_Condition__c = '01',
                VAT_code__c = '1'
            );
              quoteList.add(QuoteGECPRO);
            
            //insert new List<Quote> { QuoteOwner, QuoteRenter, QuoteSUCC, QuoteToTriggerErrors };
            if(quoteList.size() > 0){
                insert quoteList;
            }
            System.debug(logginglevel.WARN,'### QuoteOwnerId : ' + QuoteOwner.Id + ' - ' + QuoteOwner.Name);
            System.debug(logginglevel.WARN,'### QuoteRenterId : ' + QuoteRenter.Id + ' - ' + QuoteRenter.Name);
            System.debug(logginglevel.WARN,'### QuoteSUCCId : ' + QuoteSUCC.Id + ' - ' + QuoteSUCC.Name);
            System.debug(logginglevel.WARN,'### QuoteToTriggerErrorsId : ' + QuoteToTriggerErrors.Id + ' - ' + QuoteToTriggerErrors.Name);
            System.debug(logginglevel.WARN,'### QuoteGEBREId : ' + QuoteGEBRE.Id + ' - ' + QuoteGEBRE.Name);
            System.debug(logginglevel.WARN,'### QuoteGEBCSId : ' + QuoteGEBCS.Id + ' - ' + QuoteGEBCS.Name);
            System.debug(logginglevel.WARN,'### QuoteOwnerECOCFTId : ' + QuoteOwnerECOCFT.Id + ' - ' + QuoteOwnerECOCFT.Name);
            System.debug(logginglevel.WARN,'### QuoteGECPRO : ' + QuoteGECPRO.Id + ' - ' + QuoteGECPRO.Name);
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (8) : ' + Limits.getQueries());
          
            /*
            Quote_PTL__c oQPTLOwner1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteOwner.Id AND Opportunity_PTL__c = :optyPTLOwner1.Id];
            Quote_PTL__c oQPTLOwner2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteOwner.Id AND Opportunity_PTL__c = :optyPTLOwner2.Id];
            Quote_PTL__c oQPTLRenter1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteRenter.Id AND Opportunity_PTL__c = :optyPTLRenter1.Id];
            Quote_PTL__c oQPTLSUCC1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteSUCC.Id AND Opportunity_PTL__c = :optyPTLSUCC1.Id];
            Quote_PTL__c oQPTLToTriggerErrors1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :QuoteToTriggerErrors.Id AND Opportunity_PTL__c = :optyPTLToTriggerErrors.Id];
            */
            
            Quote_PTL__c oQPTLOwner1 = new Quote_PTL__c();
            Quote_PTL__c oQPTLOwner2 = new Quote_PTL__c();
            Quote_PTL__c oQPTLRenter1 = new Quote_PTL__c();
            Quote_PTL__c oQPTLSUCC1 = new Quote_PTL__c();
            Quote_PTL__c oQPTLToTriggerErrors1 = new Quote_PTL__c();
            Quote_PTL__c oQPTLOwnerECOCFT = new Quote_PTL__c();
            Quote_PTL__c oQPTLGECPRO = new Quote_PTL__c();
            
            List<Quote_PTL__c> qptlList = [SELECT Id, Name, Quote__c, Opportunity_PTL__c FROM Quote_PTL__c WHERE Quote__c = :quoteList AND Opportunity_PTL__c = :optlList];
            for (Quote_PTL__c oqptl: qptlList) {
                if(oqptl.Quote__c == QuoteOwner.Id && oqptl.Opportunity_PTL__c == optyPTLOwner1.Id){
                  oQPTLOwner1 = oqptl;
                }else if(oqptl.Quote__c == QuoteOwner.Id && oqptl.Opportunity_PTL__c == optyPTLOwner2.Id){
                  oQPTLOwner2 = oqptl;
                }else if(oqptl.Quote__c == QuoteRenter.Id && oqptl.Opportunity_PTL__c == optyPTLRenter1.Id){
                  oQPTLRenter1 = oqptl;
                }else if(oqptl.Quote__c == QuoteSUCC.Id && oqptl.Opportunity_PTL__c == optyPTLSUCC1.Id){
                  oQPTLSUCC1 = oqptl;
                }else if(oqptl.Quote__c == QuoteToTriggerErrors.Id && oqptl.Opportunity_PTL__c == optyPTLToTriggerErrors.Id){
                  oQPTLToTriggerErrors1 = oqptl;
                }else if(oqptl.Quote__c == QuoteOwnerECOCFT.Id && oqptl.Opportunity_PTL__c == optyPTLOwnerECOCFT.Id){
                  oQPTLOwnerECOCFT = oqptl;
                }else if(oqptl.Quote__c == QuoteGECPRO.Id && oqptl.Opportunity_PTL__c == optyPTLGECPRO.Id){
                  oQPTLGECPRO = oqptl;
                }
            }
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (9) : ' + Limits.getQueries());
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
              // QLI QuoteOwner
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, IsTank__c = true,
                    Quote_PTL__c = oQPTLOwner1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].Id, IsTank__c = true,
                    Quote_PTL__c = oQPTLOwner2.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteOwner.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[2].id, Cyclical_Rebate_Months__c=12,Cyclical_Rebate_TTC__c=150,
                    Quote_PTL__c = oQPTLOwner1.Id,Got_From_SAP__c=true
                ),
                
                // QLI QuoteRenter
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteRenter.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].id, IsTank__c = true,
                    Quote_PTL__c = oQPTLRenter1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                
                // QLI QuoteSUCC
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteSUCC.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].id, IsTank__c = true,
                    Quote_PTL__c = oQPTLSUCC1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                
                // QLI QuoteToTriggerErrors
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = QuoteToTriggerErrors.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].id, IsTank__c = true,
                    Quote_PTL__c = oQPTLToTriggerErrors1.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),

                // QLI QuoteGEBCS
                new QuoteLineItem(QuoteId = QuoteGEBCS.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[3].id, IsTank__c = false
                ),
                
                // QLI QuoteOwnerECOCFT
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteOwnerECOCFT.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, IsTank__c = true,
                    Quote_PTL__c = oQPTLOwnerECOCFT.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                ),
                
                // QLI QuoteGECPRO
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = QuoteGECPRO.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, IsTank__c = true,
                    Quote_PTL__c = oQPTLGECPRO.Id, Mis_Disposition__c = 'Butagaz Owned Tank', Tank_Placing_Options__c = 'MEP'
                )
            }; 
            insert lQLI; 
          
            /*for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }*/
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (10) : ' + Limits.getQueries());
            

            // Articles
            list<Item__c> lArticlesToInsert = new list<Item__c>();
            Item__c oBouteille = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000001515', Type__c ='Bouteille');
            Item__c oCasier = new Item__c(Name = 'Casier', ExternalID__c='000000000000001516', Type__c ='Casier');
            Item__c oAutreMateriel = new Item__c(Name = 'Autre Matériel', ExternalID__c='000000000000001517', Type__c ='Autre Matériel');
            insert new List<Item__c> { oBouteille, oCasier, oAutreMateriel };
            
            //Prise en Charge
            PEC__c oPECGEBRE = new PEC__c(Account__c=accGEBRE.Id,PEC_Date__c = datetime.now(), Status__c = 'Attente de signature');
            PEC__c oPECGEBCS = new PEC__c(Account__c=accGEBCS.Id,PEC_Date__c = datetime.now().addDays(-1), Status__c = 'Attente de signature');
            insert new List<PEC__c> { oPECGEBRE, oPECGEBCS };

            PEC_Article__c oPECBouteille = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=10,Stock_PEC_consigne__c=5);
            PEC_Article__c oPECBouteille2 = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=null,Stock_PEC_consigne__c=null);
            PEC_Article__c oPECBouteille3 = new PEC_Article__c(Prise_en_Charge__c=oPECGEBCS.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=10,Stock_PEC_consigne__c=5);
            PEC_Article__c oPECCasier = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oCasier.Id, Article__r=oCasier,Unit_Cost__c=29,Stock_PEC_pret__c=4,Stock_PEC_consigne__c=2);
            PEC_Article__c oPECAutreMateriel = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Unit_Cost__c=15,Stock_PEC_pret__c=6,Stock_PEC_consigne__c=3);
            insert new List<PEC_Article__c> { oPECBouteille, oPECBouteille2, oPECBouteille3, oPECCasier, oPECAutreMateriel };

            //CDS
            /*CDS__c oCDSGEBRE = new CDS__c(Account__c=accGEBRE.Id,CDS_Date__c = datetime.now(), Status__c = 'Attente de signature');
            CDS__c oCDSGEBCS = new CDS__c(Account__c=accGEBRE.Id,CDS_Date__c = datetime.now(), Status__c = 'Attente de signature');
            insert new List<CDS__c> { oCDSGEBRE, oCDSGEBCS };

            list<CDS_Article__c> lCDSArticleToInsert = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteille = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Consignation__c=true,Valeur_Consignation__c=5);
            CDS_Article__c oCDSBouteille2 = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Deconsignation__c=true,Valeur_Deconsignation__c=3);
            CDS_Article__c oCDSBouteille3 = new CDS_Article__c(CDS__c=oCDSGEBCS.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Deconsignation__c=true,Valeur_Deconsignation__c=3);
            CDS_Article__c oCDSCasier = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oCasier.Id, Article__r=oCasier,Stock_effectif__c=29,Stock_PEC__c=4);
            CDS_Article__c oCDSAutreMateriel = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Stock_effectif__c=null);
            insert new List<CDS_Article__c> { oCDSBouteille, oCDSBouteille2, oCDSBouteille3, oCDSCasier, oCDSAutreMateriel };*/
            
            
            /* Too many SOQL queries, need to find another way to test this part
            System.debug(logginglevel.WARN,'### oOptyOwnerECOCFT.T_Pack__c : ' + oOptyOwnerECOCFT.T_Pack__c);
            System.debug(logginglevel.WARN,'### oQPTLOwnerECOCFT.Estimated_Consumption__c : ' + oQPTLOwnerECOCFT.Estimated_Consumption__c);
            
            oQPTLOwnerECOCFT.Estimated_Consumption__c = 0.95;
            oQPTLOwnerECOCFT.RPTL_Purposes__c = 'Heating';
            update oQPTLOwnerECOCFT;
            
            //PTL Consumption Profile
            PTL_Consumption_Profile__c oPCPECOCFT = new PTL_Consumption_Profile__c(
                Name = 'PCPECOCFT1', 
                Opportunity__c = oOptyOwnerECOCFT.Id, 
                Quote_PTL_del__c = oQPTLOwnerECOCFT.Id, 
                Temperature__c = 18,
                consumption_fixed_jan__c = 0.030, 
                consumption_fixed_feb__c = 0.029, 
                consumption_fixed_mar__c = 0.025, 
                consumption_fixed_apr__c = 0.000, 
                consumption_fixed_may__c = 0.000, 
                consumption_fixed_jun__c = 0.000, 
                consumption_fixed_jul__c = 0.000, 
                consumption_fixed_aug__c = 0.000, 
                consumption_fixed_sep__c = 0.000, 
                consumption_fixed_oct__c = 0.015, 
                consumption_fixed_nov__c = 0.023, 
                consumption_fixed_dec__c = 0.028, 
                consumption_variable_jan__c = 0.006, 
                consumption_variable_feb__c = 0.006, 
                consumption_variable_mar__c = 0.006, 
                consumption_variable_apr__c = 0.006, 
                consumption_variable_may__c = 0.006, 
                consumption_variable_jun__c = 0.006, 
                consumption_variable_jul__c = 0.006, 
                consumption_variable_aug__c = 0.006, 
                consumption_variable_sep__c = 0.006, 
                consumption_variable_oct__c = 0.006, 
                consumption_variable_nov__c = 0.006, 
                consumption_variable_dec__c = 0.006
            );
            insert new List<PTL_Consumption_Profile__c> {oPCPECOCFT};
            
            // Attachments on PCPs (ProfilConso)
            Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body2');
            
            Attachment attachPCPECOCFT = new Attachment(    
                Name = 'Unit Test Attachment2',
                body = bodyBlob2,
                parentId = oQPTLOwnerECOCFT.id
            );
            insert new List<Attachment> { attachPCPECOCFT };
            */

            // Create Document_A_Signer__c to cover data delete method
            Document_A_Signer__c docASigner = new Document_A_Signer__c(
                    Id_SF_Document__c = 'idsfdoc',
                    Devis__c = QuoteOwner.Id
            );
            insert new List<Document_A_Signer__c> { docASigner };
          
          
          
            // Update opty with synced quote
            oOptyOwner.SyncedQuoteId = QuoteOwner.Id;
          
            oOptyRenter.SyncedQuoteId = QuoteRenter.Id;
          
            oOptySUCC.SyncedQuoteId = QuoteSUCC.Id;
            oOptySUCC.DO_City_Postal_Code__c = null;
            oOptySUCC.DO_Postal_Code__c = '01000';
            oOptySUCC.DO_City__c = 'TestCity';

            oOptyGEBRE.SyncedQuoteId = QuoteGEBRE.Id;
            oOptyGEBCS.SyncedQuoteId = QuoteGEBCS.Id;
            oOptyGECPRO.SyncedQuoteId = QuoteGECPRO.Id;
            
            /*oOptyOwnerECOCFT.SyncedQuoteId = QuoteOwnerECOCFT.Id;*/
          
                    update new List<Opportunity> { oOptyOwner, oOptyRenter, oOptySUCC, oOptyGEBRE, oOptyGEBCS, oOptyGECPRO/*, oOptyOwnerECOCFT*/ };
          
            System.debug(logginglevel.WARN,'### SOQL Queries used (11) : ' + Limits.getQueries());
            
        /*}*/
    
    }
    
    
    
    @isTest static void testVFC_ProcessDataForSignea_QuoteOwner(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteOwner <<<<<');
    
        /*User u = [SELECT Id FROM User WHERE Alias = 'VFC06PS' LIMIT 1];
        System.runAs(u) {*/
        
        //createRecords();
        
        
        //Quote oQuoteOwner = [SELECT Id FROM Quote WHERE Name = 'QuoteOwner' LIMIT 1];
        
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteOwner = [SELECT Id, Name, Product_Scale__c, Scale__c, Account.Activity_Domain_Simple__c, Opportunity.Client_Type__c, VAT_code__c, Market_type__c, Opportunity.T_Pack__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteOwner.Id, false, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Test Scale PDF 
        PageReference pageRef = Page.VFP_ScalePDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oQuoteOwner.id);
        ApexPages.currentPage().getParameters().put('isSE', 'true');
        ApexPages.StandardController sc = new ApexPages.standardController(oQuoteOwner);
        VFC_ProcessDataForSignea vpdfs = new VFC_ProcessDataForSignea (sc);
        List<Document> tmpScalesDocsList = vpdfs.getScales();
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        /*}*/
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteOwner END <<<<<');
    }
    
    
    @isTest static void testVFC_ProcessDataForSignea_QuoteRenter(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteRenter <<<<<');
        
        
        //createRecords();
        
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteRenter = [SELECT Id, Name FROM Quote WHERE Name like 'QuoteRenter%' LIMIT 1];
        
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteRenter.Id, false, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (13) : ' + Limits.getQueries());
        
        /* Stop Test */
        Test.stopTest();
            
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteRenter END <<<<<');
    }
    
    
    public static testmethod void testVFC_ProcessDataForSignea_QuoteSUCC(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteSUCC <<<<<');
    
            
        //createRecords();
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteSUCC = [SELECT Id FROM Quote WHERE Name like 'QuoteSUCC%' LIMIT 1];
        
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteSUCC.Id, false, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (14) : ' + Limits.getQueries());
        
        /* Stop Test */
        Test.stopTest();
        
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteSUCC END <<<<<');
    }
    
    
    public static testmethod void testVFC_ProcessDataForSignea_QuoteOther(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteOther <<<<<');
        
        
        //createRecords();
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteToTriggerErrors = [SELECT Id FROM Quote WHERE Name like 'QuoteToTriggerErrors%' LIMIT 1];
        Opportunity oOptyToTriggerErrors = [SELECT Id FROM Opportunity WHERE Name = 'TestOptyToTriggerErrors' LIMIT 1];
        
        // Non-existing quote
        VFC_ProcessDataForSignea.ProcessDataForSignea(null, false, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (15) : ' + Limits.getQueries());
        
        // Quote to trigger errors
          // Not synced
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteToTriggerErrors.Id, false, 1);
          // Synced
        oOptyToTriggerErrors.SyncedQuoteId = oQuoteToTriggerErrors.Id;
        update oOptyToTriggerErrors;
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteToTriggerErrors.Id, false, 1);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (16) : ' + Limits.getQueries());
        
        
        /* Stop Test */
        Test.stopTest();
            
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteOther END <<<<<');
    }

    public static testmethod void testVFC_ProcessDataForSignea_QuoteGEBRE(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteGEBRE <<<<<');
        
        
        //createRecords();
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteGEBRE = [SELECT Id FROM Quote WHERE Name like 'QuoteGEBRE%' LIMIT 1];
        
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteGEBRE.Id, true, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (17) : ' + Limits.getQueries());
        
        /* Stop Test */
        Test.stopTest();
            
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteGEBRE END <<<<<');
    }

    public static testmethod void testVFC_ProcessDataForSignea_QuoteGEBCS(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteGEBCS <<<<<');
        
        
        //createRecords();
        
        /* Start Test */
        Test.startTest();
        
        Quote oQuoteGEBCS = [SELECT Id FROM Quote WHERE Name like 'QuoteGEBCS%' LIMIT 1];
        
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteGEBCS.Id, true, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (18) : ' + Limits.getQueries());
        
        /* Stop Test */
        Test.stopTest();
            
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteGEBCS END <<<<<');
    }
    
    /*public static testmethod void testVFC_ProcessDataForSignea_QuoteECOCFT(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteECOCFT <<<<<');
        
        //createRecords();
        
        // Start Test 
        Test.startTest();
        
        Quote oQuoteECOCFT = [SELECT Id, Name, OpportunityId FROM Quote WHERE Name like 'QuoteECOCFT%' LIMIT 1];
        
        
        VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteECOCFT.Id, false, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (19) : ' + Limits.getQueries());
        
        // Stop Test 
        Test.stopTest();
        
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSignea_QuoteECOCFT END <<<<<');
    }*/
    
    
    public static testmethod void testSigneaTriggerMethodsCompleted(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Quote oQuoteOwner = [SELECT Id, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];
            
            
            // Quotes to run different parts of controller's code
            VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteOwner.Id, false, 1);
            
            
            // Simulate creation of the circuit and update quote with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oQuoteOwner.Signea_Circuit__c = SC1.Id;
            oQuoteOwner.Signea_Date_Signature__c = null;
            oQuoteOwner.Statut_circuit_de_signature__c = '';
            update oQuoteOwner;
            
            SC1.signea__status__c = 'completed';
            update SC1;
            
            // Test trigger methods
            /*List<Quote> tQuotes = new List<Quote>();
            tQuotes.add(QuoteOwner);
            Signea_CustumTriggerHelper.updateQuotesOnSignedCircuit(tQuotes);
            Signea_CustumTriggerHelper.updateQuotesOnRefusedCircuit(tQuotes);
            Signea_CustumTriggerHelper.updateQuotesOnExpiredCircuit(tQuotes);
            Signea_CustumTriggerHelper.updateQuotesOnInProgressCircuits(tQuotes);*/
            
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods END <<<<<');
    }
    
    public static testmethod void testSigneaTriggerMethodsRefused(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Quote oQuoteOwner = [SELECT Id, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];
            
            
            // Quotes to run different parts of controller's code
            VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteOwner.Id, false, 1);
            
            
            // Simulate creation of the circuit and update quote with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oQuoteOwner.Signea_Circuit__c = SC1.Id;
            oQuoteOwner.Signea_Date_Signature__c = null;
            oQuoteOwner.Statut_circuit_de_signature__c = '';
            update oQuoteOwner;
            
            SC1.signea__status__c = 'refused';
            SC1.Signea__Reject_Reason__c = 'client';
            update SC1;
            
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods END <<<<<');
    }

    public static testmethod void testSigneaTriggerMethodsExpired(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Quote oQuoteOwner = [SELECT Id, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];
            
            
            // Quotes to run different parts of controller's code
            VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteOwner.Id, false, 1);
            
            
            // Simulate creation of the circuit and update quote with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oQuoteOwner.Signea_Circuit__c = SC1.Id;
            oQuoteOwner.Signea_Date_Signature__c = null;
            oQuoteOwner.Statut_circuit_de_signature__c = '';
            update oQuoteOwner;
            
            SC1.signea__status__c = 'expired';
            update SC1;
            
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods END <<<<<');
    }

    public static testmethod void testSigneaTriggerMethodsOngoing(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Quote oQuoteOwner = [SELECT Id, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Quote WHERE Name like 'QuoteOwner%' LIMIT 1];
            
            
            // Quotes to run different parts of controller's code
            VFC_ProcessDataForSignea.ProcessDataForSignea(oQuoteOwner.Id, false, 1);
            
            
            // Simulate creation of the circuit and update quote with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oQuoteOwner.Signea_Circuit__c = SC1.Id;
            oQuoteOwner.Signea_Date_Signature__c = null;
            oQuoteOwner.Statut_circuit_de_signature__c = '';
            update oQuoteOwner;
            
            SC1.signea__status__c = 'ongoing';
            update SC1;
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods END <<<<<');
    }
    
    private static ID createContent(){ 
        //RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Category'];
        
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL='http://www.google.com/';
        testContentInsert.Title = 'Google.com';
        //testContentInsert.RecordTypeId = ContentRT.Id;
        
        insert testContentInsert;
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea_TEST.createContent] testContentInsert.Id = ' + testContentInsert.Id);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea_TEST.createContent] testContentInsert.IsLatest = ' + testContentInsert.IsLatest);
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];
        
        //ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = 'Général'];
        //ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace LIMIT 1];
        /*ContentWorkspace testWorkspace = new ContentWorkspace();
        insert testWorkspace;
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();
        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;*/
        
        
        return testContentInsert.Id;
    }

    private static List<ID> createNContent(Integer nbDocs){ 
        
        List<ContentVersion> cvToInsert = new List<ContentVersion>();
        for (Integer i = 0; i < nbDocs; i++) {

            ContentVersion testContentInsert = new ContentVersion();
            testContentInsert.ContentURL='http://www.google.com/';
            testContentInsert.Title = 'Google.com';
            //testContentInsert.RecordTypeId = ContentRT.Id;

            cvToInsert.add(testContentInsert);
        }
        insert cvToInsert;
        
        List<id> lTestContent=new List<id>();
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion where Id = :cvToInsert]){
            lTestContent.add(cv.ContentDocumentId);
        }

        return lTestContent;
    }
        
}