@isTest
private class PTL_Termination_Mgr_TEST {
    
    /*
    //@testSetup static void setupData(){
    @isTest static void testPTLTerminated(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC06PS',Alias='VFC06PS',
            Email='VFC06PS@butagaz.com',Username='VFC06PS@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        //System.runAs(u) {
            
            // Custom settings
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            insert new List<Custom_Settings__c> { c8, c9, c10, c11, c12 };
            
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
            insert new List<Activity_Domain__c> { AD_GEC };
            
            RecordType rtAcc = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Dom' LIMIT 1];
            
            
            Mandataire__c mand1 = new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mand1;
            Canton__c Canton1 = new Canton__c(name = 'PMGR Canton', INSEE_Code__c = '-_-_', Department_Code__c = '29', Mandataire__c= mand1.id);
            insert Canton1;
            City__c City1 = new City__c (Name = 'Brest', Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '29200 - PMGR', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '29200', Code_Type__c = 'M', Postal_Code__c = '29200');
            insert cityCP;

            System.debug(logginglevel.WARN,'### SOQL Queries used (1) : ' + Limits.getQueries());
            
            // Account
            Account accMainOwner = new Account(
                FirstName = 'FNameMainOwner', 
                LastName = 'LNameMainOwner', 
                Market_Type__c = 'DOM', 
                Activity_Domain__c = AD_GEC.Id, 
                City_Postal_Code__c = cityCP.Id,
                Email__c = 'VFCQLI01City@test.org', 
                //Mobile_Phone_Number__c = '+33616060606',
                Mobile_Phone_Number__c = '0616060606',
                Country__c = 'FR',
                Indicatif_Pays__c = '+33',
                channel__c = 'CD',
                accountNumber='12345',
                Mandataire__c = mand1.Id,
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX',
                Scale__c = 'GAZPART1'
            );
            insert new List<Account> { accMainOwner };
            
            // PTL
            PTL__c ptl1 = new PTL__c(
                Name = 'PTLCODE1',
                ExternalID__c = 'PTLCODE1',
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainOwner.Id,
                Scale__c = 'CART1',
                Shipping_Condition__c = '01',
                Fiscal_class_PTL__c = '01',
                
                Tanks_Count__c = null,
                Last_Tank_Removal_Date__c = null,
                Open_Contracts_Count__c = null
            );
            PTL__c ptl2 = new PTL__c(
                Name = 'PTLCODE2',
                ExternalID__c = 'PTLCODE2',
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFC06PS City 2',
                Postal_Code__c = '09876',
                Account_DO__c = accMainOwner.Id,
                Scale__c = 'CART1',
                Shipping_Condition__c = '01',
                Fiscal_class_PTL__c = '01',
                
                Tanks_Count__c = null,
                Last_Tank_Removal_Date__c = null,
                Open_Contracts_Count__c = null
            );
            insert new List<PTL__c>{ ptl1, ptl2 };
            
            
            // Start Test 
            Test.startTest();
            
            
            // Articles        
            Item__c oArticle = new Item__c(Name = 'Article', ExternalID__c = 'COOOO1', No_BTZ__c = false); 
            insert oArticle;
            
            // Equipment
            Equipement__c equipment1 = new Equipement__c(
                PTL__c = ptl1.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Type__c = 'C',
                Article__c = oArticle.Id
            );
            Equipement__c equipment2 = new Equipement__c(
                PTL__c = ptl2.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Type__c = 'C',
                Article__c = oArticle.Id
            );
            insert new List<Equipement__c>{ equipment1, equipment2 };
            
            // Contract
            Contract ctr1 = new Contract(
                AccountId = accMainOwner.id,
                PTL__c = ptl1.id,
                Equipement__c = equipment1.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Scale_c__c = 'GAZPART1',
                EndDate = null
            );
            Contract ctr2 = new Contract(
                AccountId = accMainOwner.id,
                PTL__c = ptl2.id,
                Equipement__c = equipment2.id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Scale_c__c = 'GAZPART1',
                EndDate = null
            );
            insert new List<Contract>{ ctr1, ctr2 };
            
            // Order
            Order__c order1 = new Order__c(
                Account__c = accMainOwner.Id,
                PTL__c = ptl1.Id,
                Contract__c = ctr1.Id,
                Activity_Domain__c = AD_GEC.Id,
                Mandataire__c = mand1.Id,
                Order_Type__c = 'ZRTT',
                Actual_Delivery_Date__c = System.Today() - 1
            );
            insert new List<Order__c>{ order1 };
            
            
            
            // Stop Test 
            Test.stopTest();
            
            
            // Checking for indicators updated after Test.stopTest method so Salesforce processes the asynchronous methods
            PTL__c oPTL = [SELECT Id, Tanks_Count__c, Last_Tank_Removal_Date__c, Open_Contracts_Count__c FROM PTL__c WHERE ExternalID__c = 'PTLCODE1' LIMIT 1];
            
            System.debug('### oPTL.Tanks_Count__c : ' + oPTL.Tanks_Count__c);
            //System.debug('### System.Today() - 1 : ' + System.Today() - 1);
            System.debug('### oPTL.Last_Tank_Removal_Date__c : ' + oPTL.Last_Tank_Removal_Date__c);
            System.debug('### oPTL.Open_Contracts_Count__c : ' + oPTL.Open_Contracts_Count__c);
            
            System.assertEquals(1, oPTL.Tanks_Count__c, 'Tank Count mismatch');
            System.assertEquals(System.Today() - 1, oPTL.Last_Tank_Removal_Date__c, 'Last Tank Removal Date mismatch');
            System.assertEquals(1, oPTL.Open_Contracts_Count__c, 'Open Contracts Count mismatch');
            
            //System.assert(oProject != null, 'Project not successfully created');
            
            
        //}
    }
    */
    
}