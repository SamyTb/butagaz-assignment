@isTest
public class REST_ConcentementController_Test { 
    
    static testMethod void testDoPost() {
      
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
        
        
        
        Lead Lead1 = new Lead(
            FirstName='aName', LastName='SomeName', Company='SomeCompany',
            Activity_Domain__c = AD_GEC.Id, Market_Type__c = 'PRO', Project_City_Postal_Code__c = cityCP.Id,
            Assign__c = false, Project_Street_Number__c = '123', Project_Street_Name__c = 'ABC', 
            Account_City_Postal_Code__c = cityCP.Id,Market_Sub_Type__c='Domestique',
            email='testlead@createleadrecord.com',Account_Country__c='FR', Phone='0202020202', MobilePhone='0603030303',Optin_1__c=false, OptinGroupeBtz__c=true
        );
       
         insert new List<Lead> { Lead1 };
        
        Account accMainOwner = new Account(
            Name = 'Name1',
            Market_Type__c = 'PRO', 
            Activity_Domain__c = AD_GEC.Id, 
        City_Postal_Code__c = cityCP.Id,
          Email__c = 'testaccount@createaccountrecord.com', 
          Email_2__c = 'testaccount@createaccountrecord.com',
          Mobile_Phone_Number__c = '0601010101',
          channel__c = 'CD',
          accountNumber='12345',
          ExternalID__c='12345',
          Espace_Client_Login_Count__c=0,
          Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
          Optin_1__c = False,
          Optin_2__c = False,
          Optin_Partenaires__c = True,
          Market_Sub_Type__c='Domestique'
      );
      insert new List<Account> { accMainOwner };
        
      
      
      Test.startTest();
      
       // Test when email is found lead
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
        
        REST_ConcentementController.Result results = new REST_ConcentementController.Result();
  
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/Concentement/' + Lead1.email;
      req.httpMethod = 'POST';
      req.addHeader('Content-Type', 'application/json');  
      RestContext.request = req;
      RestContext.response = res;
      Lead oLead = [SELECT Id, email , Optin_1__c, OptinGroupeBtz__c  FROM Lead LIMIT 1];
   //   REST_ConcentementController.Result results = REST_ConcentementController.doPost(oLead.email , true,false);  
      results = REST_ConcentementController.doPost(oLead.email , true,false);
  //    System.assertEquals('optoutOK', results.response);
    

      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/Concentement/' + accMainOwner.Email__c;
      req.httpMethod = 'POST';
      req.addHeader('Content-Type', 'application/json');
      RestContext.request = req;
      RestContext.response = res;
      Account oAccount = [SELECT Id, Email__c , Email_2__c, Optin_1__c , Optin_2__c, Optin_Partenaires__c  FROM Account LIMIT 1];
        
    //  REST_ConcentementController.Result results = REST_ConcentementController.doPost(oAccount.Email__c , true,false);
        
      results = REST_ConcentementController.doPost(oAccount.Email__c , true,false);
      System.assertEquals('optoutOK', results.response);

      
      // Test connection when email is blank
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/Concentement/';
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      RestContext.request = req;
      RestContext.response = res;
    
      results = REST_ConcentementController.doPost(oAccount.Email__c , true, false);
    
      
      
      // Test when no record is found
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/Concentement/' + accMainOwner.Email__c + 'UNKNOWN';
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      RestContext.request = req;
      RestContext.response = res;
    
      results = REST_ConcentementController.doPost(oAccount.Email__c , true,false);
      
      
      
      // Test when no record is found lead
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/Concentement/' + Lead1.email + 'UNKNOWN';
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      RestContext.request = req;
      RestContext.response = res;
    
      results = REST_ConcentementController.doPost(oLead.email , true,false);
    

      
      
    Test.stopTest();
    
  }
    
}