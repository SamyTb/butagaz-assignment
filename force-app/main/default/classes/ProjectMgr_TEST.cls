@isTest
private class ProjectMgr_TEST {
	
	@testSetup static void setupData(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        /*System.runAs(u) {*/
            
            
            // Custom settings
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            insert new List<Custom_Settings__c> { c8, c9, c10, c11, c12 };
            
            
            Activity_Domain__c AD_SVC = new Activity_Domain__c(name = 'SVC', ExternalID__c = 38);
            insert new List<Activity_Domain__c> { AD_SVC };
            
            RecordType rtLeadIso = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Isolation_Combles_Perdus' LIMIT 1];
            RecordType rtLeadCuve = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Recyclage_Cuve_Fioul' LIMIT 1];
            RecordType rtLeadSolaire = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Solaire' LIMIT 1];
            RecordType rtLeadChauffageInstallationMateriel = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Service_Chauffage_Installation_Materiel' LIMIT 1];
            
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            Canton__c Canton1 = new Canton__c(name = 'PMGR Canton', INSEE_Code__c = '-_-_', Department_Code__c = '29', Mandataire__c= mandataire1.id);
            insert Canton1;
            City__c City1 = new City__c (Name = 'Brest', Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '29200 - PMGR', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '29200', Code_Type__c = 'M', Postal_Code__c = '29200');
            insert cityCP;

            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            
            Lead l1 = new Lead(
            	LastName='LNameSVC1',
            	FirstName='FNameSVC1',
                LeadSource='Isolation Combles Perdus',
                Account_Country__c='FR', 
                Phone='0202020202',
                Account_Street_Type__c = 'Rue',
                Account_Street_Name__c = 'Brestoise',  
                Account_City_Postal_Code__c = cityCP.Id,
                Project_City_Postal_Code__c = cityCP.Id,
                Activity_Domain__c = AD_SVC.Id,
                RecordTypeId = rtLeadIso.Id,
                Assign__c = False
            );
            Lead l2 = new Lead(
            	LastName='LNameSVC2',
            	FirstName='FNameSVC2',
                LeadSource='Recyclage Cuve Fioul',
                Account_Country__c='FR', 
                Phone='0202020202',
                Account_Street_Type__c = 'Rue',
                Account_Street_Name__c = 'Brestoise',  
                Account_City_Postal_Code__c = cityCP.Id,
                Project_City_Postal_Code__c = cityCP.Id,
                Activity_Domain__c = AD_SVC.Id,
                RecordTypeId = rtLeadCuve.Id,
                Assign__c = False
            );
            Lead l3 = new Lead(
            	LastName='LNameSVC3',
            	FirstName='FNameSVC3',
                LeadSource='Solaire',
                Account_Country__c='FR', 
                Phone='0202020202',
                Account_Street_Type__c = 'Rue',
                Account_Street_Name__c = 'Brestoise',  
                Account_City_Postal_Code__c = cityCP.Id,
                Project_City_Postal_Code__c = cityCP.Id,
                Activity_Domain__c = AD_SVC.Id,
                RecordTypeId = rtLeadSolaire.Id,
                Assign__c = False
            );
            Lead l4 = new Lead(
            	LastName='LNameSVC4',
            	FirstName='FNameSVC4',
                LeadSource='Chauffage Installation Materiel',
                Account_Country__c='FR', 
                Phone='0202020202',
                Account_Street_Type__c = 'Rue',
                Account_Street_Name__c = 'Brestoise',  
                Account_City_Postal_Code__c = cityCP.Id,
                Project_City_Postal_Code__c = cityCP.Id,
                Activity_Domain__c = AD_SVC.Id,
                RecordTypeId = rtLeadChauffageInstallationMateriel.Id,
                Assign__c = False
            );
            insert new List<Lead> { l1, l2, l3, l4 };
            
            
            Project_Subcontractor__c sc1 = new Project_Subcontractor__c(
            	Name = 'sc1',
            	Project_Type__c = '',
            	Department__c = '01;02;03'
            );
            Project_Subcontractor__c sc2 = new Project_Subcontractor__c(
            	Name = 'sc2',
            	Project_Type__c = 'Isolation Combles Perdus',
            	Department__c = '22;29;56;35'
            );
            Project_Subcontractor__c sc3 = new Project_Subcontractor__c(
            	Name = 'sc3',
            	Project_Type__c = 'Recyclage cuve fioul',
            	Department__c = '22;29;56;35'
            );
            insert new List<Project_Subcontractor__c> { sc1, sc2, sc3 };
            
            
            
        /*}*/
	}
	
	public static testmethod void testCreateProjectFromLeadIsolation(){
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadIsolation <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        
        Lead oLead = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Lead WHERE LastName = 'LNameSVC1' LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(oLead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead not successfully converted');
		
        
        /* Stop Test */
        Test.stopTest();
        
        // Checking for project creation after Test.stopTest method so Salesforce processes the asynchronous method (ProjectMgr.createProjectFromLead is a future method)
        Project__c oProject = [SELECT Id, Name, Subcontractor__c FROM Project__c WHERE Customer_Account__r.LastName = 'LNameSVC1' LIMIT 1];
        System.assert(oProject != null, 'Project not successfully created');
        
        Project_Subcontractor__c oSC = [SELECT Id FROM Project_Subcontractor__c WHERE Name = 'sc2' LIMIT 1];
        System.assertEquals(oProject.Subcontractor__c, oSC.Id, 'Subcontractor mismatch');
        
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadIsolation END <<<<<');
        
    }
    
    public static testmethod void testCreateProjectFromLeadCuveFioul(){
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadCuveFioul <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        
        Lead oLead = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Lead WHERE LastName = 'LNameSVC2' LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(oLead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead not successfully converted');
		
        
        /* Stop Test */
        Test.stopTest();
        
        // Checking for project creation after Test.stopTest method so Salesforce processes the asynchronous method (ProjectMgr.createProjectFromLead is a future method)
        Project__c oProject = [SELECT Id, Name FROM Project__c WHERE Customer_Account__r.LastName = 'LNameSVC2' LIMIT 1];
        System.assert(oProject != null, 'Project not successfully created');
        
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadCuveFioul END <<<<<');
        
    }

    public static testmethod void testCreateProjectFromLeadSolaire(){
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadSolaire <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        
        Lead oLead = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Lead WHERE LastName = 'LNameSVC3' LIMIT 1];

        // Test lead auto conversion when status is set to 'To Convert'. This will trigger the AP04LeadAutoConvert.convertLeads method
        oLead.Status = 'To Convert';
        update oLead;
		
        Account oAccount = [SELECT Id FROM Account WHERE LastName = 'LNameSVC3' LIMIT 1];
        System.assert(oAccount != null, 'Lead not successfully converted');
        

        /* Stop Test */
        Test.stopTest();
        
        // Checking for project creation after Test.stopTest method so Salesforce processes the asynchronous method (ProjectMgr.createProjectFromLead is a future method)
        Project__c oProject = [SELECT Id, Name FROM Project__c WHERE Customer_Account__r.LastName = 'LNameSVC3' LIMIT 1];
        System.assert(oProject != null, 'Project not successfully created');
        
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadSolaire END <<<<<');
        
    }

    public static testmethod void testCreateProjectFromLeadChauffageInstallationMateriel(){
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadChauffageInstallationMateriel <<<<<');
        
        /* Start Test */
        Test.startTest();
        
        
        Lead oLead = [SELECT Id, Name, Activity_Domain__r.ExternalID__c FROM Lead WHERE LastName = 'LNameSVC4' LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(oLead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead not successfully converted');
		
        
        /* Stop Test */
        Test.stopTest();
        
        // Checking for project creation after Test.stopTest method so Salesforce processes the asynchronous method (ProjectMgr.createProjectFromLead is a future method)
        Project__c oProject = [SELECT Id, Name, Subcontractor__c FROM Project__c WHERE Customer_Account__r.LastName = 'LNameSVC4' LIMIT 1];
        System.assert(oProject != null, 'Project not successfully created');
        
        
        System.Debug('### >>>>> testing class ProjectMgr_TEST.testCreateProjectFromLeadChauffageInstallationMateriel END <<<<<');
        
    }
    
	
}