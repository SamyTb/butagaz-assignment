@isTest 
private class AP03Contact_Test { 

    private static Integer TEST_FACTOR = 200;

    static testMethod void myUnitTest() {
        
        System.Debug('### >>>>> testing class AP03Contact_Test.myUnitTest <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='AP03C',Alias='AP03C',
            Email='AP03C@shell.com',Username='AP03C@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
            RecordType rt2 = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='External_Contact' LIMIT 1];
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
            insert AD_GEC;
   
            Canton__c Canton1 = new Canton__c(name = 'AP03C Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'AP03C City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - AP03C', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name = 'AP03C', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'AP03CCity', Email__c = 'AP03C@test.org', channel__c='CD',
                accountNumber='12345', recordtypeId = rt.id,Country__c='FR', Phone='0202020202');
            insert a;
            
            List<Contact> lContactToInsert=new List<Contact>();

            List<Case> lCaseToInsert=new List<Case>();
            
            for(Integer i=0;i<10 * TEST_FACTOR;i++){
                Contact c =  new Contact(FirstName='testFirstName',LastName = 'TestContact',AccountID=a.id,CT_ContactRole__c='', Contact_Marketing__c  = true,Country__c = a.Country__c,Phone = a.Phone,Email = a.Email__c);
                c.lastName = 'Contact ' + i;
                lContactToInsert.add(c); 
            }
            insert lContactToInsert;
            
            for(Contact oContact:lContactToInsert){
                oContact.A_Convertir__c=true;
            }
            
            Test.startTest();
            update lContactToInsert;
            
            Integer i=0;
            for(Contact oContact: [select Id,Account.ispersonAccount from Contact where id in:lContactToInsert]){
                System.assertEquals(false,oContact.Account.isPersonAccount);
                i++;
            }
            System.assertEquals(TEST_FACTOR*10,i);
            
            Test.stopTest();
        }     
    }
}