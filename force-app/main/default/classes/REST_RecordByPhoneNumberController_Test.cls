@isTest
public class REST_RecordByPhoneNumberController_Test {
    
    static testMethod void testDoGet() {
        
        
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='TrackRestAPICalls',value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c8, c9 };
        
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert AD_GEC;
        RecordType rtAccount = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' and IsPersonType = false LIMIT 1];
        RecordType rtLead = [SELECT Id,Name FROM RecordType WHERE SobjectType='Lead' AND DeveloperName='Prescriber_Lead' LIMIT 1];
        
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
        
        Account accMainOwner = new Account(
            Name = 'Name1',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GEC.Id, 
            /*Postal_Code__c = '123', 
            City__c = 'VFCQLI01City',*/ 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountrecord.com', 
            Mobile_Phone_Number__c = '0601010101',
            Channel__c = 'CD',
            AccountNumber='12345',
            ExternalID__c='12345',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        insert new List<Account> { accMainOwner };
        
        Contact c = new Contact(Lastname='VFC06PS Contact', AccountId = accMainOwner.id, Email = 'testcontact@createcontactrecord.com', MobilePhone='0602020202');
        insert c;
        
        Lead oLead = new Lead(
            FirstName='aName', LastName='SomeName', Company='SomeCompany', RecordTypeId = rtLead.Id,
            Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = cityCP.Id,
            Assign__c = false, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
            Account_City_Postal_Code__c = cityCP.Id,
            email='testlead@createleadrecord.com',Account_Country__c='FR', Phone='0202020202', MobilePhone='0603030303'
        );
        insert oLead;
        
        PTL__c ptlGEC = new PTL__c(
            Activity_Domain__c = AD_GEC.id,
            Mandataire__c = mand1.id,
            City__c = 'APCTR City 2',
            Postal_Code__c = '09876',
            Name = 'PTLNameGEC',
            Account_DO__c = accMainOwner.Id,
            Mobile_Phone_Number__c = '0604040404'
        );
        insert new List<PTL__c> { ptlGEC };
        
        
        
        
        Test.startTest();
        
        // Test when account is found
        
        // SOSL doesn't return any data when called in a test class, so we need to tell it what to return
        /*Id accountRecordId = createTestAccountRecord();
        Id [] fixedSearchResults = new Id[]{accountRecordId};*/
        Id [] fixedSearchResults = new Id[]{accMainOwner.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/getRecordByPhoneNumber/0601010101';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        REST_RecordByPhoneNumberController.Result results = REST_RecordByPhoneNumberController.doGet();
        
        System.assertEquals('0601010101', results.MobilePhone);
        System.assertEquals('1', results.RecordCount);
        System.assertEquals('FoundAccount', results.response);
        
        
        // Test when contact is found
        Id [] fixedSearchResultsCon = new Id[]{c.Id};
        Test.setFixedSearchResults(fixedSearchResultsCon);
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/getRecordByPhoneNumber/0602020202';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_RecordByPhoneNumberController.doGet();
        
        System.assertEquals('0601010101', results.MobilePhone);  // If phone number found in contact object, we return the account linked to the contact
        System.assertEquals('1', results.RecordCount);
        System.assertEquals('FoundContact', results.response);
        
        // Test when lead is found
        Id [] fixedSearchResultsLead = new Id[]{oLead.Id};
        Test.setFixedSearchResults(fixedSearchResultsLead);
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/getRecordByPhoneNumber/0603030303';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_RecordByPhoneNumberController.doGet();
        
        System.assertEquals('0603030303', results.MobilePhone);
        System.assertEquals('1', results.RecordCount);
        System.assertEquals('FoundLead', results.response);
        
        // Test when PTL is found
        Id [] fixedSearchResultsPTL = new Id[]{ptlGEC.Id};
        Test.setFixedSearchResults(fixedSearchResultsPTL);
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/getRecordByPhoneNumber/0604040404';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_RecordByPhoneNumberController.doGet();
        
        System.assertEquals('0601010101', results.MobilePhone);
        System.assertEquals('1', results.RecordCount);
        System.assertEquals('FoundAccount', results.response);
        
        // Test when no record is found
        Id [] fixedSearchResultsNone = null;
        Test.setFixedSearchResults(fixedSearchResultsNone);
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/getRecordByPhoneNumber/0605050505';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_RecordByPhoneNumberController.doGet();
        
        System.assertEquals('', results.MobilePhone);
        System.assertEquals('NotFound', results.response);
        
        Test.stopTest();
        
    }
    
}