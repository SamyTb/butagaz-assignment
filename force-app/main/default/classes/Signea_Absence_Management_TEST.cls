@isTest
public class Signea_Absence_Management_TEST {
    
    @testSetup static void setupUser(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', User_Mandataires__c='BTZ');
            
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
            
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            insert new List<Activity_Domain__c> { AD_GEC };
            
            //RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
            
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
            
            Account accMainGECDOM = new Account(
                FirstName = 'FName1', 
                LastName = 'accGECDOM', 
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
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Payment_method__c = 'P'
            );
            Account accMainGECPRO = new Account(
                /*FirstName = 'FName2', 
                LastName = 'LName2', */
                Name = 'accGECPRO',
                Market_Type__c = 'PRO', 
                Activity_Domain__c = AD_GEC.Id, 
                /*Postal_Code__c = '123', 
                City__c = 'VFCQLI01City', */
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12346',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Payment_method__c = 'P'
            );
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
            insert new List<Account> { accMainGECDOM, accMainGECPRO, accToTriggerErrors };
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (2) : ' + Limits.getQueries());
            
            Contact conGECPRO = new Contact(Lastname='ContactGECPRO', AccountId = accMainGECPRO.id, MobilePhone = '0616060606', Email = 'VFCQLI01City@test.org');
            insert new List<Contact> { conGECPRO };
            
            
            System.debug(logginglevel.WARN,'### SOQL Queries used (7) : ' + Limits.getQueries());
            

            // Create Document_A_Signer__c to cover data delete method
            /*Document_A_Signer__c docASigner = new Document_A_Signer__c(
                Id_SF_Document__c = 'idsfdoc',
                Bank_Detail__c = oPECGEBRE.Id
            );
            insert new List<Document_A_Signer__c> { docASigner };*/
          
            System.debug(logginglevel.WARN,'### SOQL Queries used (11) : ' + Limits.getQueries());
            
        /*}*/
    
    }
    
    
    @isTest static void testVFC_ProcessDataForSigneaFromBankDetail_AccountGECDOM(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testVFC_ProcessDataForSigneaFromBankDetail_AccountGECDOM <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        Account oAccGECDOM = [SELECT Id, Name FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAccGECDOM.Id, null, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        
        // Test Signea Absence Management
        //ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        Signea_Absence_Management  testSAM = new Signea_Absence_Management();
        //testSAM.getCurrentUserMandataires();
        testSAM.getUserOptions();
        testSAM.getCircuitsList();
        
        testSAM.selectedUserId = UserInfo.getUserId();
        testSAM.getCircuitsList();
        
        
        //System.assertEquals(1, oPTL.Tanks_Count__c, 'Tank Count mismatch'); 
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testVFC_ProcessDataForSigneaFromBankDetail_AccountGECDOM END <<<<<');
    }
    
}