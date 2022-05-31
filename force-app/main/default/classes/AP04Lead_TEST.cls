@isTest
private class AP04Lead_TEST {

    static testMethod void myUnitTest() {
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Sales Administrator (RAV)%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='AP04L',Alias='AP04L',
            Email='AP04L@shell.com',Username='AP04L@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 99);
            insert AD_GEC;
            
            Canton__c Canton1 = new Canton__c(name = 'AP04L Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'Saint Jean Cap Ferrat',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '06230 - AP04L', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '06230', Code_Type__c = 'M', Postal_Code__c = '06230');
            insert cityCP; 
            Code_NAF__c CNAF1 = new Code_NAF__c(name = 'MyNACECode', ExternalID__c = '01A');
            insert CNAF1;
            
            Lead l1 = new Lead(
                W2L_Postal_Code__c = '06230',
                W2L_Project_Postal_Code__c = '06230',
                W2L_City__c = 'Saint Jean Cap Ferrat',
                W2L_Activity_Domain__c = 99,
                W2L_Project_City__c = 'Saint Jean Cap Ferrat',
                W2L_NACE_Code__c = '01A',
                Account_Country__c='FR', 
                Phone='0202020202'
            );
            
            List<Lead> leadList = new List<Lead>();
            leadList.add(l1);
            
            test.starttest();
            
            AP04Lead.MatchAdress(leadList);
            AP04Lead.fillActivityDomainId(leadList);
            AP04Lead.fillNACEId(leadList);
            AP04Lead.fillTPredecessor(leadList);
            test.stoptest();
        }
    }
}