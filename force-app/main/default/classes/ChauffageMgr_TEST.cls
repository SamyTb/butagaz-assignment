@isTest
private class ChauffageMgr_TEST {
    
    @testSetup static void setupData(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        /*System.runAs(u) {*/
            
            
            // Custom settings
            Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c2 = new Custom_Settings__c(name='TrackRestAPICalls', value__c = 'true');
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            insert new List<Custom_Settings__c> { c1, c2, c9, c10, c11, c12 };
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            Activity_Domain__c AD_SVC = new Activity_Domain__c(name = 'SVC', ExternalID__c = 38);
            insert new List<Activity_Domain__c> { AD_GEC, AD_SVC };
            
            RecordType rtAccountGEC = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];

            //RecordType rtLeadIso = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Isolation_Combles_Perdus' LIMIT 1];
            //RecordType rtLeadCuve = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Recyclage_Cuve_Fioul' LIMIT 1];
            
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            Canton__c Canton1 = new Canton__c(name = 'PMGR Canton', INSEE_Code__c = '-_-_', Department_Code__c = '29', Mandataire__c = mandataire1.id);
            insert Canton1;
            City__c City1 = new City__c (Name = 'Brest', Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '22000 - PMGR', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '22000', Code_Type__c = 'M', Postal_Code__c = '22000');
            City_Postal_Code__c cityCP2 = new City_Postal_Code__c(Name = '01000 - PMGR', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01000', Code_Type__c = 'M', Postal_Code__c = '01000');
            insert new List<City_Postal_Code__c> { cityCP1, cityCP2 };

            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            
            // Create GEC Account
            Account accMainOwner = new Account(
                FirstName = 'FNameMainOwner', 
                LastName = 'LNameMainOwner', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP1.Id,
                Email__c = 'VFCQLI01City@test.org', 
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                FCC_Mobile_Phone_Number__c = '+33616060606',
                channel__c = 'CD',
                accountNumber='12345',
                Mandataire__c = mandataire1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Salutation = 'M',
                Street_N__c = '1',
                Street_type__c = 'RUE',
                Street_name__c = 'StreetName'
            );
            insert new List<Account> { accMainOwner };
            
            // Create Subcontractors
            Project_Subcontractor__c sc1 = new Project_Subcontractor__c(
                Name = 'GARANKA',
                Project_Type__c = 'Chauffage',
                Department__c = '01;02;03'
            );
            Project_Subcontractor__c sc2 = new Project_Subcontractor__c(
                Name = 'MENERGIES',
                Project_Type__c = 'Chauffage',
                Department__c = '22;29;35;56'
            );
            insert new List<Project_Subcontractor__c> { sc1, sc2 };
            
        /*}*/
    }
    
    
    static testMethod void testChauffageMgrGARANKA() {
        
        System.Debug('### >>>>> testing class ChauffageMgr_TEST.testChauffageMgrGARANKA <<<<<');

        Test.startTest();
        
        
        Account oAccMainOwner = [SELECT Id FROM Account WHERE FirstName like 'FNameMainOwner%' AND LastName like 'LNameMainOwner%' LIMIT 1];
        System.debug(logginglevel.WARN,'### oAccMainOwner : ' + oAccMainOwner.Id);
        
        // Call page
        PageReference pageRef = Page.Chauffage_Management;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oAccMainOwner);
        ChauffageMgr cha = new ChauffageMgr (sc);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
        
        cha.getProducts();
        cha.selectedPostalCode = '01000';
        cha.oProject.Product__c = '11';
        cha.oProject.Resident__c = true;
        cha.oProject.Type_of_Technology__c = '14';
        cha.oProject.Housing_Type__c = 'House';
        cha.oProject.Housing_Over_2_Years__c = false;
        cha.oProject.Device_Type__c = '84';
        cha.oProject.GARANKA_Device_Brand__c = '28';
        cha.oProject.Estimated_Age_Of_Device__c = '1';
        cha.validatePostalCode();
        cha.getPriceCode();
        
        cha.getAPIToken();
        cha.getEligibility();
        cha.getBookingTimeSlots();

        cha.validateData();
        cha.saveData();

        cha.postData();

        // Cover non-resident path
        cha.oProject.Sent_To_External_Partner__c = false;
        cha.oProject.Resident__c = false;
        cha.oProject.Renter_Salutation__c = 'M.';
        cha.oProject.Renter_Last_Name__c = 'LName';
        cha.oProject.Renter_First_Name__c = 'FName';
        cha.oProject.Renter_Email__c = 'test@test.com';
        cha.oProject.Renter_Phone__c = '0601010101';
        cha.postData();


        cha.navigateToAccount();
        cha.navigateToProject();
        //cha.getChauffageAPISettings();

        //String fccEndpoint = cha.fccApiEndpoint;
        Boolean err = cha.hasError;
        
        
        Test.stopTest();

        System.Debug('### >>>>> testing class ChauffageMgr_TEST.testChauffageMgrGARANKA END <<<<<');
    }

    static testMethod void testChauffageMgrMENERGIES() {
        
        System.Debug('### >>>>> testing class ChauffageMgr_TEST.testChauffageMgrMENERGIES <<<<<');

        Test.startTest();
        
        
        Account oAccMainOwner = [SELECT Id FROM Account WHERE FirstName like 'FNameMainOwner%' AND LastName like 'LNameMainOwner%' LIMIT 1];
        System.debug(logginglevel.WARN,'### oAccMainOwner : ' + oAccMainOwner.Id);
        
        // Call page
        PageReference pageRef = Page.Chauffage_Management;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oAccMainOwner.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oAccMainOwner);
        ChauffageMgr cha = new ChauffageMgr (sc);
        
        System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
        
        cha.getProducts();
        cha.selectedPostalCode = '22000';
        cha.oProject.Product__c = '11';
        cha.oProject.Resident__c = true;
        cha.oProject.Type_of_Technology__c = '14';
        cha.oProject.Housing_Type__c = 'House';
        cha.oProject.Housing_Over_2_Years__c = false;
        cha.oProject.Device_Type__c = '84';
        cha.oProject.GARANKA_Device_Brand__c = '28';
        cha.oProject.Estimated_Age_Of_Device__c = '1';
        cha.validatePostalCode();
        cha.getPriceCode();
        
        cha.getAPIToken();
        cha.getEligibility();
        cha.getBookingTimeSlots();

        cha.validateData();
        cha.saveData();

        cha.postData();

        // Cover non-resident path
        cha.oProject.Sent_To_External_Partner__c = false;
        cha.oProject.Resident__c = false;
        cha.oProject.Renter_Salutation__c = 'M.';
        cha.oProject.Renter_Last_Name__c = 'LName';
        cha.oProject.Renter_First_Name__c = 'FName';
        cha.oProject.Renter_Email__c = 'test@test.com';
        cha.oProject.Renter_Phone__c = '0601010101';
        cha.postData();


        cha.navigateToAccount();
        cha.navigateToProject();
        //cha.getChauffageAPISettings();

        //String fccEndpoint = cha.fccApiEndpoint;
        Boolean err = cha.hasError;
        
        
        Test.stopTest();

        System.Debug('### >>>>> testing class ChauffageMgr_TEST.testChauffageMgrMENERGIES END <<<<<');
    }
    
    
}