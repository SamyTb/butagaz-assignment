@isTest
public class AP_Account_in_Contract_Test {

    public static testMethod void testUpdateBailleurOnOwnerAccount() {
        
        System.Debug('### >>>>> testing method AP_Contract_Test.testUpdateBailleurOnOwnerAccount <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='APCTR',
            Email='APCTR@shell.com',Username='APCTR@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'APCTR Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCTR City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCTRCity', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='APCTR', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCTRCity', Email__c = 'APCTRCity@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
              // New Contact
                    Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
                    Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
                    Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
                    insert c;
            
            Account a2 = new Account(Name='APCTR2', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCTRCity', Email__c = 'APCTRCity@test.org',Country__c='FR', Phone='0202020202');
            insert a2;
            
            // New Contact
                    Contact c2  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                    accountId = a2.Id,Street_Number__c = a2.Street_Number__c,Postal_Box__c = a2.Postal_Box__c,
                    Postal_Code__c = a2.Postal_Code__c,City__c = a2.City__c,Email = a2.Email__c,Email_2__c = a2.Email_2__c,
                    Fax = a2.Fax,Place_Called__c = a2.Place_Called__c,Country__c = a2.Country__c,Phone = a2.Phone);
                    insert c2;
            
            
            // Items
            Item__c item1 = new  Item__c (Name='Test Item1', Activity_Domain__c=AD_GEC.Id,
                Code_Article__c = 'CA-01', ExternalID__c = 'EI-01');
            insert item1;
            
            
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCTR Mandataire',
                ExternalID__c = 'APCEI',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'APCTR City 2',
                Postal_Code__c = '09876',
                Name = 'APCPTLName'
            );
            insert ptl1;
            
            
            // Contracts and Account_in_Contract__c
            List<Contract> ctrList = new List<Contract>();
            
            for(Integer i=0;i<5;i++) {
                Contract ctr = new Contract(
                    PTL__c = ptl1.Id,
                    StartDate = Date.today(),
                    Scale_c__c = 'APCTRScale',
                    //Contract_Label__c = 'ZDP',
                    Name = 'APCTRName' + i,
                    ExternalID__c = 'APCEI' + i,
                    Activity_Domain__c = AD_GEC.Id,
                    ContractTerm = 5,
                    Mandataire__c = mand1.Id,
                    Commercial_Agency__c = 'APCTRAgC',
                    AccountId = a.Id,
                    Product__c = item1.Id,
                    EndDate = null
                );
                ctrList.add(ctr);
            }
            
            ctrList[0].Contract_Label__c = 'ZDK7';
            ctrList[1].Contract_Label__c = 'ZDKP';
            ctrList[2].Contract_Label__c = 'ZDK7';
            ctrList[3].Contract_Label__c = 'ZDK7';
            ctrList[4].Contract_Label__c = 'ZDK7';
            ctrList[4].AccountId = a2.Id;
            
            insert ctrList;
            //ctrList = [select id from Contract];
            system.assertEquals(5, ctrList.size());
            
            
            List<Account_in_Contract__c> accinctrList = new List<Account_in_Contract__c>();
            
            for(Integer i=0;i<5;i++) {
                Account_in_Contract__c accinctr = new Account_in_Contract__c(
                    Account__c = a.Id,
                    Contract__c = ctrList[i].Id
                );
                accinctrList.add(accinctr);
            }
            
            accinctrList[0].Role__c = 'ZP';
            accinctrList[1].Role__c = 'ZO';
            accinctrList[2].Role__c = 'ZO';
            accinctrList[3].Role__c = 'ZO';
            accinctrList[4].Role__c = 'ZP';
            accinctrList[4].Account__c = a2.Id;
            
            
            //////////////
            Test.startTest();
            
            
            //insert account_in_contract_trig;
            insert accinctrList;
            //accinctrList = [select id from Account_in_Contract__c];
            
             
            
            
            //////////////
            Test.stopTest();
            
            system.assertEquals(5, accinctrList.size());
            
            System.Debug('### >>>>> testing method AP_Contract_Test.testUpdateBailleurOnOwnerAccount END <<<<<');
            
        }
    }
}