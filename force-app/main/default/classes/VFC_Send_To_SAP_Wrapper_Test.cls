@isTest(seeAllData=true)
public class VFC_Send_To_SAP_Wrapper_Test {
    
    @isTest
    static void initTest1() 
    {
        System.Debug('### >>>>> testing class VFC_Send_To_SAP_Wrapper_Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Group grp = [select Id, DeveloperName from Group where DeveloperName='BackOffice'];
        system.debug('grp:'+grp);
            
        GroupMember gm = new GroupMember(GroupId = grp.Id, UserOrGroupId = u.Id);
    	insert gm;
        system.debug('gm:'+gm);

        System.runAs(u) {
            
            //Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            //insert new List<Custom_Settings__c> { c1 };

            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire594',ExternalID__c = '900',Active__c = true,MatriculeEnCours__c=4 );
            insert mandataire1;
            system.debug('mandataire1:'+mandataire1);
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='VFCQLI01freddy ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;

            CDS__c  cds = new CDS__c();      
            cds.Account__c = a.Id;
            cds.CDS_Date__c = system.today();
            cds.Status__c = 'Attente de signature';
            insert cds;
            
            CDS__c  cds1 = new CDS__c();      
            cds1.Account__c = a.Id;
            cds1.CDS_Date__c = system.today();
            cds1.Status__c = 'Signé';
            insert cds1;

            Test.setMock(WebServiceMock.class, new AP_WrapperForSOAPCallCDSMock1());

            Test.startTest();
            PageReference testPage = Page.VFP_Send_To_SAP_Wrapper; 
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('Id', String.valueOf(cds.Id));
            
            ApexPages.StandardController sc = new  ApexPages.StandardController(cds);     
            VFC_Send_To_SAP_Wrapper ext = new VFC_Send_To_SAP_Wrapper(sc);         
           
            PageReference pRef = ext.init();

			//cds1
            testPage.getParameters().put('Id', String.valueOf(cds1.Id));
            
            ApexPages.StandardController sc1 = new  ApexPages.StandardController(cds1);     
            VFC_Send_To_SAP_Wrapper ext1 = new VFC_Send_To_SAP_Wrapper(sc1);         
            
            PageReference pRef1 = ext1.init();

            Test.stopTest();
            System.Debug('### >>>>> testing class VFC_Send_To_SAP_Wrapper_Test END <<<<<');
            
        }   
             
    }

    @isTest
    static void initTest() 
    {
        System.Debug('### >>>>> testing class VFC_Send_To_SAP_Wrapper_Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        //Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        //insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            //Mandataire
            Mandataire__c mandataire12= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '901',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire12;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire12.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='VFCQLI01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing freddy',lastName = 'Contact Marketing freddy',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;

            CDS__c  cds = new CDS__c();      
            cds.Account__c = a.Id;
            cds.CDS_Date__c = system.today();
            cds.Status__c = 'Attente de signature';
            insert cds;
            
            CDS__c  cds1 = new CDS__c();      
            cds1.Account__c = a.Id;
            cds1.CDS_Date__c = system.today();
            cds1.Status__c = 'Signé';
            insert cds1;

            Test.setMock(WebServiceMock.class, new AP_WrapperForSOAPCallCDSMock());

            Test.startTest();
            PageReference testPage = Page.VFP_Send_To_SAP_Wrapper; 
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('Id', String.valueOf(cds.Id));
            
            ApexPages.StandardController sc = new  ApexPages.StandardController(cds);     
            VFC_Send_To_SAP_Wrapper ext = new VFC_Send_To_SAP_Wrapper(sc);         
           
            PageReference pRef = ext.init();

			//cds1
            testPage.getParameters().put('Id', String.valueOf(cds1.Id));
            
            ApexPages.StandardController sc1 = new  ApexPages.StandardController(cds1);     
            VFC_Send_To_SAP_Wrapper ext1 = new VFC_Send_To_SAP_Wrapper(sc1);         
            
            PageReference pRef1 = ext1.init();

            Test.stopTest();
            System.Debug('### >>>>> testing class VFC_Send_To_SAP_Wrapper_Test END <<<<<');
            
        }   
             
    }

}