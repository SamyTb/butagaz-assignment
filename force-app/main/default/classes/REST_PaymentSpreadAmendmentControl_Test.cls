@isTest
private class REST_PaymentSpreadAmendmentControl_Test {
    
    // Used to cover both classes : REST_PaymentSpreadAmendmentController & VFC_ProcessDataForSigneaFromCampaign

    @testSetup static void setupUser(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='MaxNumberEvidenceFilesForSignea', value__c = '3');
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='TrackRestAPICalls',value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c2, c8, c9, c10, c11, c12, c13 };
        
        // We need to have a default record in object Signea__Circuit_Template__c
        Signea__Circuit_Template__c signeaCT = new Signea__Circuit_Template__c(
            Name = 'DefaultTemplate',
            Signea__default_template__c = true,
            Signea__Active__c = true
        );
        insert signeaCT;

        // Scale documents
        /*Document scaleDoc1 = new Document(
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
        insert new List<Document> { scaleDoc1, scaleDoc2, scaleDoc3 };*/


        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert AD_GEC;
        RecordType rtAccount = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' and IsPersonType = true LIMIT 1];
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = '999',
            Active__c = true,
            Headquarters_Phone__c = '0601010101'
        );
        insert mand1;
        
        Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_', Mandataire__c = mand1.Id);
        insert Canton1;
        City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        Account accMainOwner = new Account(
            FirstName = 'FirstName1',
            LastName = 'LastName1',
            Market_Type__c = 'DOM', 
            Activity_Domain__c = AD_GEC.Id, 
            /*Postal_Code__c = '123', 
            City__c = 'VFCQLI01City',*/ 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountrecord.com', 
            Mobile_Phone_Number__c = '0601010101',
            channel__c = 'CD',
            accountNumber = '12345',
            ExternalID__c = '12345',
            Espace_Client_Login_Count__c = 0,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
            RecordType = rtAccount,
            Mandataire__c = mand1.Id
        );
        Account accMandContact = new Account(
            FirstName = 'FirstName2',
            LastName = 'LastName2',
            Market_Type__c = 'DOM', 
            Activity_Domain__c = AD_GEC.Id, 
            /*Postal_Code__c = '123', 
            City__c = 'VFCQLI01City',*/ 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountrecord2.com', 
            Mobile_Phone_Number__c = '0601010102',
            channel__c = 'CD',
            accountNumber = '12346',
            ExternalID__c = '12346',
            Espace_Client_Login_Count__c = 0,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
            RecordType = rtAccount,
            Mandataire__c = mand1.Id
        );
        insert new List<Account> { accMainOwner, accMandContact };

        Account accMandContactDetail = [SELECT Id, isPersonAccount, PersonContactId FROM Account WHERE Id =: accMandContact.Id LIMIT 1];
        mand1.Contact_Signature_Electronique__c = accMandContactDetail.PersonContactId;
        update mand1;
        
        Account acc = [SELECT Id, isPersonAccount, PersonContactId FROM Account WHERE Id =: accMainOwner.Id LIMIT 1];

        Campaign campParent = new Campaign(
            Name = 'CampaignParent'
        );
        insert new List<Campaign> { campParent };
        Campaign camp = new Campaign(
            Name = 'Campaign1',
            ParentId = campParent.Id
        );
        insert new List<Campaign> { camp };

        
        System.Debug('REST_PaymentSpreadAmendmentControl_Test accMainOwner.Id = ' + acc.Id);
        System.Debug('REST_PaymentSpreadAmendmentControl_Test accMainOwner.isPersonAccount = ' + acc.isPersonAccount);
        System.Debug('REST_PaymentSpreadAmendmentControl_Test accMainOwner.PersonContactId = ' + acc.PersonContactId);
        System.Debug('REST_PaymentSpreadAmendmentControl_Test camp.Id = ' + camp.Id);

        CampaignMember member = new CampaignMember(
            ContactId = acc.PersonContactId,
            Status = 'Sent',
            CampaignId = camp.Id
        );
        insert new List<CampaignMember> { member };

        // Create Document_A_Signer__c to cover data delete method
        Document_A_Signer__c docASigner = new Document_A_Signer__c(
          Id_SF_Document__c = 'idsfdoc',
          CampaignMemberId__c = member.Id,
          Account__c = accMainOwner.Id
        );
        insert new List<Document_A_Signer__c> { docASigner };

        
    }

    static testMethod void testDoPatch() {

        Test.startTest();
        
        // Test when campaign member is found
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/paymentSpreadAmendment/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        //req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        CampaignMember oCampMember = [SELECT Id, Contact.Account.Mobile_Phone_Number__c FROM CampaignMember WHERE FirstName like 'FirstName1%' AND LastName like 'LastName1%' LIMIT 1];

        REST_PaymentSpreadAmendmentController.Result results = REST_PaymentSpreadAmendmentController.doPost(''+oCampMember.Id, '3', oCampMember.Contact.Account.Mobile_Phone_Number__c, 'Y');
        
//        System.assertEquals('OK', results.response);
//        System.assertEquals('Processing circuit.', results.message);
        //System.assertEquals(1, accMainOwner.Espace_Client_Login_Count__c);
        
        // Test when payment spread out of bound
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/paymentSpreadAmendment/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        //req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_PaymentSpreadAmendmentController.doPost(''+oCampMember.Id, '-1', oCampMember.Contact.Account.Mobile_Phone_Number__c, 'Y');
        
//        System.assertEquals('paymentSpreadOutOfBound', results.response);
//        System.assertEquals('Payment spread out of bound.', results.message);
        
        
        // Test when no record is found
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/paymentSpreadAmendment/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        //req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_PaymentSpreadAmendmentController.doPost('UNKNOWN', '3', oCampMember.Contact.Account.Mobile_Phone_Number__c, 'Y');
        
//        System.assertEquals('NotFound', results.response);
//        System.assertEquals('Campaign member not found.', results.message);
        
        
        // Test Scale PDF 
        PageReference pageRef = Page.VFP_AvenantPDF_PaiementXFois_FromAccount;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oCampMember.id);
        ApexPages.currentPage().getParameters().put('isSE', 'true');
        ApexPages.currentPage().getParameters().put('paymentSpreadChosen', '3');


        Test.stopTest();

    }
    
}