@isTest
public class Comparator_CalloutMgr_Test {
    
    @testSetup static void setupUser(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c(name='Comparator_Endpoint', value__c = 'http://example.com/example/test');
        Custom_Settings__c c3 = new Custom_Settings__c(name='TrackRestAPICalls', value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c2, c3 };
        
        Comparator_Status_Mapping__c csm1 = new Comparator_Status_Mapping__c(name='Status1', value__c = '1');
        Comparator_Status_Mapping__c csm2 = new Comparator_Status_Mapping__c(name='Status2', value__c = '2');
        Comparator_Status_Mapping__c csm3 = new Comparator_Status_Mapping__c(name='Status3', value__c = '3');
        insert new List<Comparator_Status_Mapping__c> { csm1, csm2, csm3 };
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert new List<Activity_Domain__c> { AD_GEC };

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
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
        
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
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
            Lead_ExternalID__c = 'CMP1234567'
        );
        insert new List<Account> { accMainOwner };
        
        // Add an Opty
        Opportunity oOptyOwner = new Opportunity(
            Name = 'TestOptyOwner',
            Project_Type__c = 'CREA', 
            DO_Activity_Domain__c = AD_GEC.Id,
            StageName = 'Status3', 
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
            Avez_vous_votre_Kbis__c = 'Oui'
            /*Contrat__c = ctr.Id*/
        );
        insert new List<Opportunity> { oOptyOwner };
        
        
    }
    
    static testMethod void testCallout() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"status":"200", "detail":"OK"}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Opportunity oOpty = [SELECT Id, Account.Lead_ExternalID__c, StageName FROM Opportunity WHERE Name like 'TestOptyOwner%' LIMIT 1];
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Comparator_CalloutMgr.callComparatorWS(oOpty.Id, '', oOpty.StageName);
        
        // Verify response received contains fake values
        /*String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());*/
        
        Test.stopTest();
    }
    
    static testMethod void testCalloutReturningError() {
        
        Test.startTest();
        
        // Set mock callout class
        MockHttpResponseGenerator mockInstance = new MockHttpResponseGenerator(200, 'OK', '{"status":"400", "detail":"NOK"}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockInstance);
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Opportunity oOpty = [SELECT Id, Account.Lead_ExternalID__c, StageName FROM Opportunity WHERE Name like 'TestOptyOwner%' LIMIT 1];
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Comparator_CalloutMgr.callComparatorWS(oOpty.Id, oOpty.Account.Lead_ExternalID__c, oOpty.StageName);
        
        Test.stopTest();
        
    }
    
}