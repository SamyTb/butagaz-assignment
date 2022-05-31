@isTest
public class REST_LogsEspaceClientController_Test {
    
    static testMethod void testDoPatch() {
        
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='TrackRestAPICalls',value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c8, c9 };
        
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert AD_GEC;
        RecordType rtAccount = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' and IsPersonType = false LIMIT 1];
        
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
            channel__c = 'CD',
            accountNumber='12345',
            ExternalID__c='12345',
            Espace_Client_Login_Count__c=0,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        insert new List<Account> { accMainOwner };
        
        
        
        Test.startTest();
        
        // Test registration when account is found
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/logsEspaceClient/';  
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        //req.addParameter('ConnectionType', '0');
        //req.addParameter('AccountNumber', accMainOwner.ExternalID__c);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LogsEspaceClientController.Result results = REST_LogsEspaceClientController.doPatch('0', accMainOwner.ExternalID__c);
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        //System.assertEquals(1, accMainOwner.Espace_Client_Login_Count__c);
        
        
        // Test connection when account is found
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/logsEspaceClient/';  
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_LogsEspaceClientController.doPatch('1', accMainOwner.accountNumber);
        
        System.assertEquals('OK', results.response);
        System.assertEquals('Data saved.', results.message);
        
        
        // Test when connection type out of bound
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/logsEspaceClient/';  
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_LogsEspaceClientController.doPatch('2', accMainOwner.accountNumber);
        
        System.assertEquals('cnxTypeOutOfBound', results.response);
        System.assertEquals('Connection type out of bound.', results.message);
        
        
        // Test when no record is found
        req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/logsEspaceClient/';  
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
        RestContext.request = req;
        RestContext.response = res;
        
        results = REST_LogsEspaceClientController.doPatch('1', accMainOwner.accountNumber + 'UNKNOWN');
        
        System.assertEquals('NotFound', results.response);
        System.assertEquals('Customer not found.', results.message);
        
        
        Test.stopTest();
        
    }
    
}