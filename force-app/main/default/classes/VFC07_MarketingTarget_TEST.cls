@isTest
private class VFC07_MarketingTarget_TEST {

    static testMethod void myUnitTest() {
        System.Debug('### >>>>> testing class VFC07_MarketingTarget_TEST.myUnitTest <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC07',Alias='VFC07',
            Email='VFC07@shell.com',Username='VFC07@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'VFC07 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFC07 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='VFC07 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFC07City', Email__c = 'VFC07@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            Campaign oCamp = new Campaign(Name = 'VFC07 Test');
            insert oCamp;
            
            
            Test.startTest();
            // Starting Controller part
            ApexPages.StandardController sc = new ApexPages.standardController(oCamp);
            // create an instance of the controller
            VFC07_MarketingTarget myPageCon = new VFC07_MarketingTarget(sc);
            myPageCon.setSearchText('Unknown');
            myPageCon.search();
            myPageCon.setSearchText('VFC07');
            myPageCon.search();
            String sSearchText = myPageCon.getSearchText();
            System.assertEquals('VFC07',sSearchText);
            PageReference pr = myPageCon.saveForm();
            System.assertEquals(null,pr);
            Test.stopTest();
        }
    }
}