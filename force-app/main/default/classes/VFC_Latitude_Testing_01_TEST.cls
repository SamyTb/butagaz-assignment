@isTest
private class VFC_Latitude_Testing_01_TEST {

    static testMethod void myUnitTest() {
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCLT',Alias='VFCLT',
            Email='VFCLT@shell.com',Username='VFCLT@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
            insert mandataire1;
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'VFCLT Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCLT City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCLT', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='PP01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCLTCity', Email__c = 'VFCLT@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
           // Contact c = new Contact(Lastname='VFCLT Contact', AccountId = a.id);
           // insert c;
           
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
             insert c;
        
            // Add an Oppty
            Opportunity oOpty = new Opportunity(Name = 'TestOpty',
                Project_Type__c='CREA', 
                DO_Activity_Domain__c= AD_GEC.Id,
                DO_AccountNumber__c='12345',
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Installation_date__c = Date.today() + 15,
                T_Pack__c = 'IDEO'
                );
            insert oOpty;
        
            Quote q1 = new Quote( 
                OpportunityId = oOpty.Id,
                Name='testResetQuotes Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                T_LAT_IS_TEST__c = 1,
                T_LAT_Test_Batch__c = 'Test'
                );
            insert q1;
            
            Quote q2 = new Quote( 
                OpportunityId = oOpty.Id,
                Name='testResetQuotes Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z010',
                Contract_Duration__c = '5',
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Scale__c='F',
                Ger_Consumption__c='B4',
                T_LAT_IS_TEST__c = 1,
                T_LAT_Test_Batch__c = 'Test',
                T_LAT_Test_Calculation__c = 'Test',
                T_LAT_Test_Status__c = 'Failed'
                );
            insert q2;
            
            test.starttest();
            // create an instance of the controller
            VFC_Latitude_Testing_01 myPageCon = new VFC_Latitude_Testing_01();
            
            List<String> sList = myPageCon.getLBatchIds();
            List<VFC_Latitude_Testing_01.DataObj> dObjList = myPageCon.getFailureSuccessChartData();
            dObjList = myPageCon.getCalculationTypeChartData();
            dObjList = myPageCon.getCalculationExpectedType();
            List<Quote> qList = myPageCon.getFailedQuotes();
            
            PageReference pg=myPageCon.startLatest();
            pg=myPageCon.startActive();
            
            myPageCon.setRequestedBatchIdCurrent('Test 2');
            myPageCon.setRequestedBatchIdActive('Test 2');

            test.stoptest();
        }
    }
}