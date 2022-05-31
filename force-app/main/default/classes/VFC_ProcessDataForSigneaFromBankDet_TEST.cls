@isTest
private class VFC_ProcessDataForSigneaFromBankDet_TEST {

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
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testVFC_ProcessDataForSigneaFromBankDetail_AccountGECDOM END <<<<<');
    }

    @isTest static void testVFC_ProcessDataForSigneaFromBankDetail_AccountGECPRO(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testVFC_ProcessDataForSigneaFromBankDetail_AccountGECPRO <<<<<');
            
        /* Start Test */
        Test.startTest();
        
        Account oAccGECPRO = [SELECT Id, Name FROM Account WHERE Name like 'accGECPRO%' LIMIT 1];
        Contact oConGECPRO = [SELECT Id, LastName FROM Contact WHERE LastName like 'ContactGECPRO%' LIMIT 1];
        
        
        // Quotes to run different parts of controller's code
        VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAccGECPRO.Id, oConGECPRO.Id, 1);
        System.debug(logginglevel.WARN,'### SOQL Queries used (12) : ' + Limits.getQueries());
        
        // Assertions
        
        
        /* Stop Test */
        Test.stopTest();
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testVFC_ProcessDataForSigneaFromBankDetail_AccountGECPRO END <<<<<');
    }

    


    public static testmethod void testSigneaTriggerMethodsCompleted(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Account oAcc = [SELECT Id, Name FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAcc.Id, null, 1);
            
            Bank_Detail__c oBD = [SELECT Id, Account__c, Contact__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Bank_Detail__c LIMIT 1];
            
            // Simulate creation of the circuit and update related object with its Id
            String xml = '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://www.contralia.fr/metadata">';
            xml += '<participants>';
            xml += '<participant number="1" name="Participant1" clientRef=""/>';
            xml += '</participants>';
            xml += '<fields>';
            xml += '<field values="" description="Saisissez votre BIC" type="TEXT" required="true" regEx="([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)" regExTip="Le code BIC saisi n’est pas correct" participantNumber="1" width="183.0" x="75.0" name="SEPA_BIC" y="537.0" fontSize="10" page="1" group="" font="" height="16.0"/>';
            xml += '<field values="" description="Saisissez votre IBAN" type="TEXT" required="true" regEx="[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}" regExTip="Le code IBAN saisi n’est pas correct" participantNumber="1" width="246.0" x="75.0" name="SEPA_IBAN" y="510.0" fontSize="10" page="1" group="" font="" height="16.0"/>';
            xml += '<field values="" description="Nom du client" type="TEXT" required="true" regEx="" regExTip="" participantNumber="1" width="280.0" x="40.0" name="SEPA_NAME" y="433.0" fontSize="10" page="1" group="" font="" height="16.0"/>';
            xml += '<field values="" description="Adresse du client 1" type="TEXT" required="true" regEx="" regExTip="" participantNumber="1" width="280.0" x="40.0" name="SEPA_ADDR" y="415.0" fontSize="10" page="1" group="" font="" height="16.0"/>';
            xml += '<field values="" description="Adresse du client 2" type="TEXT" required="true" regEx="" regExTip="" participantNumber="1" width="280.0" x="40.0" name="SEPA_CITY" y="397.0" fontSize="10" page="1" group="" font="" height="16.0"/>';
            xml += '<field values="" description="" type="SIGNATURE" required="false" regEx="" regExTip="" participantNumber="1" width="153.0" x="432.0" name="SEPA_SIG" y="241.0" fontSize="10" page="1" group="" font="" height="80.0"/>';
            xml += '</fields>';
            xml += '<values>';
            xml += '<value fieldName="SEPA_BIC" value="ABNAFRPP"/>';
            xml += '<value fieldName="SEPA_IBAN" value="FR7630001007941234567890185"/>';
            xml += '<value fieldName="SEPA_NAME" value="FName LName"/>';
            xml += '<value fieldName="SEPA_ADDR" value="34 rue de Test"/>';
            xml += '<value fieldName="SEPA_CITY" value="29000 - QUIMPER"/>';
            xml += '<value fieldName="SEPA_SIG" value=""/>';
            xml += '</values>';
            xml += '</metadata>';
            
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = 'completed',
                AccountBTZ__c = oBD.Account__c
            );
            insert SC1;
            
            Signea__Document__c SD1 = new Signea__Document__c(
                Signea__Circuit__c = SC1.Id,
                Signea__status__c = 'Sent',
                Signea__Name__c = 'Mandat SEPA Test',
                Signea__Document_ID__c = 'XXXXX',
                Signea__metadata__c = xml
            );
            insert SD1;
            
            oBD.Signea_Circuit__c = SC1.Id;
            oBD.Signea_Date_Signature__c = null;
            oBD.Statut_circuit_de_signature__c = '';
            update oBD;
            
            SC1.signea__status__c = 'completed';
            update SC1;
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods END <<<<<');
    }
    
    public static testmethod void testSigneaTriggerMethodsRefused(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Account oAcc = [SELECT Id, Name FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAcc.Id, null, 1);
            
            Bank_Detail__c oBD = [SELECT Id, Account__c, Contact__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Bank_Detail__c LIMIT 1];
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oBD.Signea_Circuit__c = SC1.Id;
            oBD.Signea_Date_Signature__c = null;
            oBD.Statut_circuit_de_signature__c = '';
            update oBD;
            
            SC1.signea__status__c = 'refused';
            SC1.Signea__Reject_Reason__c = 'client';
            update SC1;
            
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods END <<<<<');
    }

    public static testmethod void testSigneaTriggerMethodsExpired(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Account oAcc = [SELECT Id, Name FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAcc.Id, null, 1);
            
            Bank_Detail__c oBD = [SELECT Id, Account__c, Contact__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Bank_Detail__c LIMIT 1];
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oBD.Signea_Circuit__c = SC1.Id;
            oBD.Signea_Date_Signature__c = null;
            oBD.Statut_circuit_de_signature__c = '';
            update oBD;
            
            SC1.signea__status__c = 'expired';
            update SC1;
            
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods END <<<<<');
    }

    public static testmethod void testSigneaTriggerMethodsOngoing(){
        
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test1', LastName='VFC06PS1',Alias='VFC06PS1',
            Email='VFC06PS@butagaz.com',Username='VFC06PS1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c=true);
            
        insert u;
        System.runAs(u) {
        
            /* Start Test */
            Test.startTest();
            
            Account oAcc = [SELECT Id, Name FROM Account WHERE LastName like 'accGECDOM%' LIMIT 1];
            
            // To run different parts of controller's code
            VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea(oAcc.Id, null, 1);
            
            Bank_Detail__c oBD = [SELECT Id, Account__c, Contact__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c FROM Bank_Detail__c LIMIT 1];
            
            // Simulate creation of the circuit and update related object with its Id
            Signea__Circuit__c SC1 = new Signea__Circuit__c(
                Name = 'SC1',
                signea__status__c = ''
            );
            insert SC1;
            
            oBD.Signea_Circuit__c = SC1.Id;
            oBD.Signea_Date_Signature__c = null;
            oBD.Statut_circuit_de_signature__c = '';
            update oBD;
            
            SC1.signea__status__c = 'ongoing';
            update SC1;
            
            /* Stop Test */
            Test.stopTest();
          
        }
        System.Debug('### >>>>> testing class VFC_ProcessDataForSigneaFromBankDet_TEST.testSigneaTriggerMethods END <<<<<');
    }
}