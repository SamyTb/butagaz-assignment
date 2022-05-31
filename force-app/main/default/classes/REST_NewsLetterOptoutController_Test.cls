@isTest
public class REST_NewsLetterOptoutController_Test {
    
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
          Email_2__c = 'testaccount@createaccountrecord.com',
          Mobile_Phone_Number__c = '0601010101',
          channel__c = 'CD',
          accountNumber='12345',
          ExternalID__c='12345',
          Espace_Client_Login_Count__c=0,
          Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
          Demat1_chorus__c = False,
          Demat2_chorus__c = False,
          Indicatif_Pays__c = '+33',
          Country__c='FR'
      );
      insert new List<Account> { accMainOwner };
      
      
        // New Contact
            Contact contact1   = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = accMainOwner.Id,Street_Number__c = accMainOwner.Street_Number__c,Postal_Box__c = accMainOwner.Postal_Box__c,
            Postal_Code__c = accMainOwner.Postal_Code__c,City__c = accMainOwner.City__c,Email = accMainOwner.Email__c,Email_2__c = accMainOwner.Email_2__c,
            Fax = accMainOwner.Fax,Place_Called__c = accMainOwner.Place_Called__c,Country__c = accMainOwner.Country__c,Phone = accMainOwner.Phone, Abonne_newsletter__c = true,Indicatif_Pays_c__c= '+33');
            insert contact1 ;
            
            Contact contact2 = new Contact(FirstName = 'OtherLastName8', LastName = 'OtherLastName8', accountid = accMainOwner.id, Abonne_newsletter__c = true);
            insert contact2;
        
      
      
      Test.startTest();
      
       // Test when email is found
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();
  
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/NewsLetterOptout/' + contact1.Email;
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      //req.addParameter('ConnectionType', '0');
      RestContext.request = req;
      RestContext.response = res;
    
      REST_NewsLetterOptoutController.Result results = REST_NewsLetterOptoutController.doPatch();
    
    System.assertEquals('optoutOK', results.response);
      //System.assertEquals('Data saved.', results.message);
      //System.assertEquals(True, accMainOwner.Optin_1__c);
      
      
      // Test connection when email is blank
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/NewsLetterOptout/';
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      RestContext.request = req;
      RestContext.response = res;
    
      results = REST_NewsLetterOptoutController.doPatch();
    
    System.assertEquals('optoutNOEMAIL', results.response);
      
      
      // Test when no record is found
      req.requestURI = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/v.1/NewsLetterOptout/' + contact1.Email + 'UNKNOWN';
      req.httpMethod = 'PATCH';
      req.addHeader('Content-Type', 'application/json');
        req.addParameter('TestParam', 'TestParam1');
      RestContext.request = req;
      RestContext.response = res;
    
      results = REST_NewsLetterOptoutController.doPatch();
    
    System.assertEquals('optoutNOTFOUND', results.response);
      
      
    Test.stopTest();
    
  }
    
}