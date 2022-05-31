@isTest
public class  VFC_PageDetailCampaign_Test {
    

     static testMethod void getCamp_Test() {

        System.Debug('### >>>>> testing class VFC_PageDetailCampaign_Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VCFPageDetailCampaign',Alias='VFCPDC',
        Email='VCFPageDetailCampaign@shell.com',Username='VCFPageDetailCampaign@shell.com',TimeZoneSidKey='Europe/Paris',
        LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,Can_add_campaign_member__c=true,
        UserPermissionsMarketingUser=true,LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
          
          Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB');
          insert AD_GEB;
          Canton__c Canton1 = new Canton__c(name = 'VCFPageDetailCampaign Canton', INSEE_Code__c = '-_-_');
          insert Canton1;
          City__c City1  = new City__c (Name = 'VCFPageDetailCampaign City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
          insert City1;
          City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VCFPageDetailCampaign', 
          City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
          insert cityCP;
          
          Account a = new Account(Name='VCFPageDetailCampaign', Market_Type__c = 'RE', Activity_Domain__c = AD_GEB.Id, 
          Postal_Code__c = '123', City__c = 'VCFPageDetailCampaign', Email__c = 'VCFPageDetailCampaign@test.org',Country__c='FR', Phone='0202020202');
          insert a;
          
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
          accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
          Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
          Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
          insert c;  
          
          // PTL       
        PTL__c oPTL = new PTL__c(Name = 'PTLPred', Account_DO__c=a.Id, Activity_Domain__c=AD_GEB.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true,Contact_Marketing__c=c.Id);
        insert oPTL;
        
        // Brands
        Brand__c oBrand = new Brand__c(Name__c='Brand', Type__c='Nationale', Ordre_de_tri__c=1);
        insert oBrand;

        // Articles        
        Item__c oArticle = new Item__c(Name = 'Article', ExternalID__c='000000000000000100', No_BTZ__c=false); 
        insert oArticle;
        
        //Item__c oArticleBD = [Select Name,Id from item__c where ExternalID__c='000000000000000100'];
        
        // Inventory Pricing
        Inventory_Pricing__c oIP = new Inventory_Pricing__c(PTL__c=oPTL.Id);
        insert oIP;
        
        // Inventory Pricing Brands
        Inventory_Pricing_Brand__c oIPB = new Inventory_Pricing_Brand__c(
            Brand__c=oBrand.Id,
            Inventory_pricing__c=oIP.Id,
            Presence__c = true
        );
        insert oIPB;
        
        // Inventory Pricing Article
        Inventory_Pricing_Article__c oIPA = new Inventory_Pricing_Article__c(
            Inventory_Pricing_Brand__c=oIPB.Id,
            Article__c=oArticle.Id,
            Bottle_Number__c=12,
            Charging_Price__c=10.0,
            Presence__c = true
        );
        insert oIPA;
          
       
          
          Campaign cc = new Campaign (Name='VCFPageDetailCampaign',Status='In progress');
          insert cc;
          
          CampaignMember cm = new CampaignMember(CampaignId=cc.Id, ContactId=oPTL.Contact_Marketing__c);
          insert cm;
          
          
          // Start test
         test.starttest();
         
         
          ApexPages.StandardController ptl = new ApexPages.StandardController(oPTL);
          VFC_PageDetailCampaign selectPtlContactMarketing = new VFC_PageDetailCampaign(ptl);
          List<Campaign> camp = selectPtlContactMarketing.getCamp();
    //    selectPtlContactMarketing.getCamp();
         
         
         
         

        // Stop test
        test.stoptest();
        
       
            
        }
     }

}