@isTest
public class  AP_CampaignMember_01_Test {
    

     static testMethod void AP_CampaignMember_01_Test() {

        System.Debug('### >>>>> testing class AP_CampaignMember_01_Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCampaignMember01',Alias='APCM01',
        Email='APCampaignMember01@shell.com',Username='APCampaignMember01@shell.com',TimeZoneSidKey='Europe/Paris',
        LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,Can_add_campaign_member__c=true,
        UserPermissionsMarketingUser=true,LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
          
          Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
          insert AD_GEC;
          Canton__c Canton1 = new Canton__c(name = 'APCampaignMember01 Canton', INSEE_Code__c = '-_-_');
          insert Canton1;
          City__c City1  = new City__c (Name = 'APCampaignMember01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
          insert City1;
          City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCampaignMember01City', 
          City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
          insert cityCP;
          
          Account a = new Account(Name='APCampaignMember01', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
          Postal_Code__c = '123', City__c = 'APCampaignMember01City', Email__c = 'APCampaignMember01City@test.org',Country__c='FR', Phone='0202020202');
          insert a;
               
          Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
          Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
          Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
          insert c;
          
          Campaign cc = new Campaign (Name='APCampaignMember01');
          insert cc;
          
          CampaignMember cm = new CampaignMember(CampaignId=cc.Id, ContactId=c.Id);
          insert cm;
          
          
          // Start test
         test.starttest();

        // Test delete Campaign Member (OK)
        delete cm;
        cm = new CampaignMember(CampaignId=cc.Id, ContactId=c.Id);
        insert cm; 
        u.UserPermissionsMarketingUser = false;
        update u;
        // Test delete Campaign Member (KO)
        try {
            delete cm;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.cannot_Delete_CampaignMember) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }  
            
        // Stop test
        test.stoptest();
        
        System.Debug('### >>>>> testing class AP_CampaignMember_01 END <<<<<');
            
        }
     }

}