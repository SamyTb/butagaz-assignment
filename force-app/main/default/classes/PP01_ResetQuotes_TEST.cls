@isTest
private class PP01_ResetQuotes_TEST {

    static testMethod void testResetQuotes() {
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='PP01',Alias='PP01',
            Email='PP01@shell.com',Username='PP01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            PP01_ResetQuotes plugin = new PP01_ResetQuotes();
            Map<String, Object> inputParameters1 = new Map<String, Object>{
                'batchName' => 'Test'
            };
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
            
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            Canton__c Canton1 = new Canton__c(name = 'PP01 Canton', INSEE_Code__c = '-_-_', Mandataire__c =  mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'PP01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - PP01', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='PP01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'PP01City', Email__c = 'PP01@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202');
            insert a;
            
            //Contact c = new Contact(Lastname='PP01 Contact', AccountId = a.id);
            //insert c;
            
            
         
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
        
            Quote initialQuote = new Quote( 
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
            insert initialQuote;
        
            Process.PluginRequest request = new Process.PluginRequest(inputParameters1); 
            Process.PluginResult result   = plugin.invoke(request);
        
            plugin.describe();
        }
    }
}