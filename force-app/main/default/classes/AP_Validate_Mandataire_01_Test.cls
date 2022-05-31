@isTest
private class AP_Validate_Mandataire_01_Test {
    static testMethod void execute() {
    
        System.Debug('### >>>>> testing class AP_Validate_Mandataire_01_Test.execute <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APVM1',Alias='APVM1',
            Email='APVM1@shell.com',Username='APVM1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            List<Opportunity> lOpportunities = new List<Opportunity>();
            
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APVM1 Mandataire',
                ExternalID__c = '444',
                Active__c = true,
                MatriculeEnCours__c=3 
            );
            insert mand1;
            
            Canton__c oCanton = new Canton__c();
            oCanton.Name = 'COGNAC-SUD';
            oCanton.INSEE_Code__c = '1633';
            oCanton.Mandataire__c= mand1.id;
            insert oCanton;
            
            City__c oCity = new City__c();
            oCity.Name = 'LOUZAC-SAINT-ANDRE';
            oCity.Canton__c = oCanton.Id;
            insert oCity;
            
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c();
            oPostalCode.City__c = oCity.Id;
            oPostalCode.Code_Type__c = 'M';
            oPostalCode.HEXAPOSTE_Code__c = '1234';
            oPostalCode.Postal_Code__c = '16100';
            insert oPostalCode;
            
            Account oAccount = new Account();
            oAccount.Name = 'AP_Validate_Mandataire';
            oAccount.Email__c = 'AP_Validate_Mandataire@test.org';
            oAccount.Country__c='FR';
            oAccount.Phone='0202020202';
            insert oAccount;
    
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
            Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
            Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
            insert c;
    
    
            Opportunity oOpportunity = new Opportunity();
            oOpportunity.Assign__c = false;
            oOpportunity.Name = 'Test Opportunity';
            oOpportunity.AccountId = oAccount.Id;
            oOpportunity.Account_Payer__c = oAccount.Id;
            oOpportunity.Account_Billed__c = oAccount.Id;
            oOpportunity.Project_market_subtype__c = 'Agriculture';
            oOpportunity.Client_Type__c = 'Owner';
            oOpportunity.Project_Type__c = 'CREA';
            oOpportunity.Channel__c = 'Incoming call';
            oOpportunity.LeadSource = 'Commercial';
            oOpportunity.Project_City_Postal_Code__c = oPostalCode.Id;
            oOpportunity.StageName = 'Prospecting';
            oOpportunity.CloseDate = date.newinstance(2112, 12, 12);
            oOpportunity.OwnerId = UserInfo.getUserId();
            insert oOpportunity;
            
            lOpportunities.add(oOpportunity);
            
            
            Test.startTest();
            AP_Validate_Mandataire_01.validateOpportunities(lOpportunities);
            u.User_Mandataires__c = mand1.id;
            update u;
            AP_Validate_Mandataire_01.validateOpportunities(lOpportunities);
            oCanton.Mandataire__c = mand1.id;
            update oCanton;
            AP_Validate_Mandataire_01.validateOpportunities(lOpportunities);
            oOpportunity.Name = 'Test Opportunitymodif';
            update oOpportunity;
            lOpportunities.clear();
            lOpportunities.add(oOpportunity);
            AP_Validate_Mandataire_01.validateOpportunities(lOpportunities);
            Test.stopTest();
        }    
    }
}