@isTest
public class VFC_ProcessDataForSigneaFromPECCDS_TEST {
    
     @testSetup static void setupData(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        /*System.runAs(u) {*/
            
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
            insert new List<Custom_Settings__c> { c1, c2, c8, c9, c10, c11, c12 };
            
            
            Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c = 41);
            insert new List<Activity_Domain__c> { AD_GEB };
            
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
            
            // Account
            Account accGEBRE = new Account(
                Name = 'accGEBRE',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
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
                Name = 'accGEBCS',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEB.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City',*/ 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12352',
                Mandataire__c = mand1.Id,
                En_cours_d_immatriculation__c = true,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
            );
            insert new List<Account> { accGEBRE, accGEBCS };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (2) : ' + Limits.getQueries());
            
            Contact cGEBRE = new Contact(Lastname='ContactGEBRE', AccountId = accGEBRE.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            Contact cGEBCS = new Contact(Lastname='ContactGEBCS', AccountId = accGEBCS.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            insert new List<Contact> { cGEBRE, cGEBCS };
            
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (7) : ' + Limits.getQueries());
            

            // Articles
            list<Item__c> lArticlesToInsert = new list<Item__c>();
            Item__c oBouteille = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000001515', Type__c ='Bouteille');
            Item__c oCasier = new Item__c(Name = 'Casier', ExternalID__c='000000000000001516', Type__c ='Casier');
            Item__c oAutreMateriel = new Item__c(Name = 'Autre Matériel', ExternalID__c='000000000000001517', Type__c ='Autre Matériel');
            insert new List<Item__c> { oBouteille, oCasier, oAutreMateriel };
            
            //Prise en Charge
            PEC__c oPECGEBRE = new PEC__c(Account__c=accGEBRE.Id, Contact__c = cGEBRE.Id,PEC_Date__c = datetime.now(), Status__c = 'Attente de signature');
            PEC__c oPECGEBCS = new PEC__c(Account__c=accGEBCS.Id, Contact__c = cGEBCS.Id,PEC_Date__c = datetime.now().addDays(-1), Status__c = 'Attente de signature');
            insert new List<PEC__c> { oPECGEBRE, oPECGEBCS };

            PEC_Article__c oPECBouteille = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=10,Stock_PEC_consigne__c=5);
            PEC_Article__c oPECBouteille2 = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=null,Stock_PEC_consigne__c=null);
            PEC_Article__c oPECBouteille3 = new PEC_Article__c(Prise_en_Charge__c=oPECGEBCS.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=10,Stock_PEC_consigne__c=5);
            PEC_Article__c oPECCasier = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oCasier.Id, Article__r=oCasier,Unit_Cost__c=29,Stock_PEC_pret__c=4,Stock_PEC_consigne__c=2);
            PEC_Article__c oPECAutreMateriel = new PEC_Article__c(Prise_en_Charge__c=oPECGEBRE.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Unit_Cost__c=15,Stock_PEC_pret__c=6,Stock_PEC_consigne__c=3);
            insert new List<PEC_Article__c> { oPECBouteille, oPECBouteille2, oPECBouteille3, oPECCasier, oPECAutreMateriel };

            //CDS
            CDS__c oCDSGEBRE = new CDS__c(Account__c=accGEBRE.Id, Contact__c = cGEBRE.Id, CDS_Date__c = datetime.now(), Status__c = 'Attente de signature');
            CDS__c oCDSGEBCS = new CDS__c(Account__c=accGEBCS.Id, Contact__c = cGEBCS.Id, CDS_Date__c = datetime.now(), Status__c = 'Attente de signature');
            insert new List<CDS__c> { oCDSGEBRE, oCDSGEBCS };

            list<CDS_Article__c> lCDSArticleToInsert = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteille = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Consignation__c=true,Valeur_Consignation__c=5);
            CDS_Article__c oCDSBouteille2 = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Deconsignation__c=true,Valeur_Deconsignation__c=3);
            CDS_Article__c oCDSBouteille3 = new CDS_Article__c(CDS__c=oCDSGEBCS.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Deconsignation__c=true,Valeur_Deconsignation__c=3);
            CDS_Article__c oCDSCasier = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oCasier.Id, Article__r=oCasier,Stock_effectif__c=29,Stock_PEC__c=4);
            CDS_Article__c oCDSAutreMateriel = new CDS_Article__c(CDS__c=oCDSGEBRE.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Stock_effectif__c=null);
            insert new List<CDS_Article__c> { oCDSBouteille, oCDSBouteille2, oCDSBouteille3, oCDSCasier, oCDSAutreMateriel };


            // Create Document_A_Signer__c to cover data delete method
            Document_A_Signer__c docASigner = new Document_A_Signer__c(
                Id_SF_Document__c = 'idsfdoc',
                Prise_en_Charge__c = oPECGEBRE.Id
            );
            insert new List<Document_A_Signer__c> { docASigner };
          
            System.debug(logginglevel.WARN,'### SOQL Queries used (11) : ' + Limits.getQueries());
            
        /*}*/
    
    }

    @isTest static void testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBRE(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBRE <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        Account oAccGEBRE = [SELECT Id, Name FROM Account WHERE Name like 'accGEBRE%' LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oAccGEBRE.Id, null, null, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBRE END <<<<<');
    }

    @isTest static void testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBCS(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBCS <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        Account oAccGEBCS = [SELECT Id, Name FROM Account WHERE Name like 'accGEBCS%' LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oAccGEBCS.Id, null, null, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_AccountGEBCS END <<<<<');
    }

    @isTest static void testVFC_ProcessDataForSigneaFromPECCDS_PEC(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_PEC <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        PEC__c oPEC = [SELECT Id, Name FROM PEC__c LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(null, oPEC.Id, null, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_PEC END <<<<<');
    }

    @isTest static void testVFC_ProcessDataForSigneaFromPECCDS_CDS(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_PEC <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        CDS__c oCDS = [SELECT Id, Name FROM CDS__c LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(null, null, oCDS.Id, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testVFC_ProcessDataForSigneaFromPECCDS_PEC END <<<<<');
    }


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
            
            PEC__c oPEC = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM PEC__c LIMIT 1];
            CDS__c oCDS = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM CDS__c LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oPEC.Account__c, null, null, 1);
            
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oPEC.Signea_Circuit__c = SC1.Id;
            oPEC.Signea_Date_Signature__c = null;
            oPEC.Statut_circuit_de_signature__c = '';
            update oPEC;

            oCDS.Signea_Circuit__c = SC1.Id;
            oCDS.Signea_Date_Signature__c = null;
            oCDS.Statut_circuit_de_signature__c = '';
            update oCDS;
            
            SC1.signea__status__c = 'completed';
            update SC1;
            
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
            
            PEC__c oPEC = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM PEC__c LIMIT 1];
            CDS__c oCDS = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM CDS__c LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oPEC.Account__c, null, null, 1);
            
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oPEC.Signea_Circuit__c = SC1.Id;
            oPEC.Signea_Date_Signature__c = null;
            oPEC.Statut_circuit_de_signature__c = '';
            update oPEC;

            oCDS.Signea_Circuit__c = SC1.Id;
            oCDS.Signea_Date_Signature__c = null;
            oCDS.Statut_circuit_de_signature__c = '';
            update oCDS;
            
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
            
            PEC__c oPEC = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM PEC__c LIMIT 1];
            CDS__c oCDS = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM CDS__c LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oPEC.Account__c, null, null, 1);
            
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oPEC.Signea_Circuit__c = SC1.Id;
            oPEC.Signea_Date_Signature__c = null;
            oPEC.Statut_circuit_de_signature__c = '';
            update oPEC;

            oCDS.Signea_Circuit__c = SC1.Id;
            oCDS.Signea_Date_Signature__c = null;
            oCDS.Statut_circuit_de_signature__c = '';
            update oCDS;
            
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
            
            PEC__c oPEC = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM PEC__c LIMIT 1];
            CDS__c oCDS = [SELECT Id, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM CDS__c LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea(oPEC.Account__c, null, null, 1);
            
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oPEC.Signea_Circuit__c = SC1.Id;
            oPEC.Signea_Date_Signature__c = null;
            oPEC.Statut_circuit_de_signature__c = '';
            update oPEC;

            oCDS.Signea_Circuit__c = SC1.Id;
            oCDS.Signea_Date_Signature__c = null;
            oCDS.Statut_circuit_de_signature__c = '';
            update oCDS;
            
            SC1.signea__status__c = 'ongoing';
            update SC1;
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSignea_TEST.testSigneaTriggerMethods END <<<<<');
    }

}