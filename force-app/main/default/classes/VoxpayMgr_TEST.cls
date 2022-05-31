@isTest
public class VoxpayMgr_TEST {
	
	@testSetup static void setupUser(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', FederationIdentifier = 'TestFedId');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c3 = new Custom_Settings__c(name='TrackRestAPICalls', value__c = 'true');
        insert new List<Custom_Settings__c> { c1, c3 };
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert new List<Activity_Domain__c> { AD_GEC };

        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        
        //Mandataire
        Mandataire__c mand1 = new Mandataire__c(
            name = 'VFC06PS Mandataire',
            ExternalID__c = 'BTZ',
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
            FirstName = 'FNameMainOwner', 
            LastName = 'LNameMainOwner', 
            Market_Type__c = 'DOM', 
            Activity_Domain__c = AD_GEC.Id, 
            City_Postal_Code__c = cityCP.Id,
            Email__c = 'VFCQLI01City@test.org', 
            Mobile_Phone_Number__c = '0616060606',
            Country__c = 'FR',
            Indicatif_Pays__c = '+33',
            FCC_Mobile_Phone_Number__c = '+33616060606',
            channel__c = 'CD',
            accountNumber='12345',
            Mandataire__c = mand1.Id,
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        );
        insert new List<Account> { accMainOwner };
        
    }
    
    
    static testMethod void testVoxpayPayment() {
        
        Test.startTest();
        
        
        Account oAccMainOwner = [SELECT Id FROM Account WHERE FirstName like 'FNameMainOwner%' AND LastName like 'LNameMainOwner%' LIMIT 1];
        System.debug(logginglevel.WARN,'### oAccMainOwner : ' + oAccMainOwner.Id);
        
        // Call page
        PageReference pageRef = Page.Voxpay_Management;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oAccMainOwner);
        VoxpayMgr vxp = new VoxpayMgr (sc);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
        
        vxp.getPaymentTypes();
        vxp.getIntervalTypes();
        vxp.selectedPaymentType = '1';
        vxp.validatePaymentType();
        String fccEndpoint = vxp.fccApiEndpoint;
        Boolean err = vxp.hasError;
        
        vxp.oPaymentInfo.cinematic_id = 1;
        vxp.oPaymentInfo.amount = 10;
        
        vxp.preparePayment();
        vxp.checkCallTransfer();
        vxp.postPayment();
        
        
        Test.stopTest();
    }
	
}