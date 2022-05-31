@isTest
public class REST_UpdatePhoneNumberController_Test {
	
	static testMethod void testDoPatch() {
        
        
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='TrackRestAPICalls',value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c8, c9 };
        
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c = 41);
        Activity_Domain__c AD_GDB = new Activity_Domain__c(name = 'GDB', ExternalID__c = 45);
        insert new List<Activity_Domain__c> { AD_GEC, AD_GEB };
        //RecordType rtAccount = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' and IsPersonType = false LIMIT 1];
        
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
        
        Account accGEC = new Account(
            Name = 'NameGEC',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GEC.Id, 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountgec.com', 
            Mobile_Phone_Number__c = '0601010101',
            Channel__c = 'CD',
            AccountNumber='11111',
            ExternalID__c='11111',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        Account accGEB = new Account(
            Name = 'NameGEB',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GEB.Id, 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountgeb.com', 
            Mobile_Phone_Number__c = '0601010101',
            Channel__c = 'CD',
            AccountNumber='22222',
            ExternalID__c='22222',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        Account accGDB = new Account(
            Name = 'NameGDB',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GDB.Id, 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'testaccount@createaccountgdb.com', 
            Mobile_Phone_Number__c = '0601010101',
            Channel__c = 'CD',
            AccountNumber='33333',
            ExternalID__c='33333',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        insert new List<Account> { accGEC, accGEB, accGDB };
        
        PTL__c ptlGEC = new PTL__c(
            Activity_Domain__c = AD_GEC.id,
            Mandataire__c = mand1.id,
            City__c = 'APCTR City 2',
            Postal_Code__c = '09876',
            Name = 'PTLNameGEC',
            Account_DO__c = accGEC.Id
        );
        PTL__c ptlGEB = new PTL__c(
            Activity_Domain__c = AD_GEB.id,
            Mandataire__c = mand1.id,
            City__c = 'APCTR City 2',
            Postal_Code__c = '09876',
            Name = 'PTLNameGEB',
            Account_DO__c = accGEB.Id
        );
        PTL__c ptlGDB = new PTL__c(
            Activity_Domain__c = AD_GDB.id,
            Mandataire__c = mand1.id,
            City__c = 'APCTR City 2',
            Postal_Code__c = '09876',
            Name = 'PTLNameGDB',
            Account_DO__c = accGDB.Id
        );
        insert new List<PTL__c> { ptlGEC, ptlGEB, ptlGDB };
        
        
        
        Test.startTest();
        
        
        REST_UpdatePhoneNumberController.Result results = new REST_UpdatePhoneNumberController.Result();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        // Test when account is found
        // GEB Phone
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLNameGEB', '0111111111');
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        
        // GEB Mobile Phone
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLNameGEB', '0611111111');
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        
        // GEC Phone
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLNameGEC', '0122222222');
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        
        // GEC MobilePhone
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLNameGEC', '0622222222');
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        
    	// GDB
    	req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLNameGDB', '0633333333');
        
        System.assertEquals('actdomOutOfBound', results.response);
        System.assertEquals('Activity domain out of bound.', results.message);
        
        
        // Test when no record is found
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/updatePhoneNumber/';  
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_UpdatePhoneNumberController.doPatch('PTLUnknown', '0644444444');
        
        System.assertEquals('NotFound', results.response);
        System.assertEquals('PTL not found.', results.message);
        
        
        
        Test.stopTest();
        
    }
    	
}