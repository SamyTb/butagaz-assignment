@isTest
private class AP_CityMatchingEngine_01_TEST2 {

    public static testmethod void testExactMatch(){
        
        Integer WORK_FACTOR = 5;
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCME1',Alias='APCME1',
            Email='APCME1@shell.com',Username='APCME1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            
            Canton__c canton = new Canton__c(INSEE_Code__c = '0101');
            insert canton;

            // Insert Cities
            List<City__c> lCities = new List<City__c>();
            for (Integer i = 0; i < 30 * WORK_FACTOR; i++){ // City creation loop
                lCities.add(new City__c(INSEE_Code__c = String.valueOf(i), Canton__c = canton.Id));
            }
            insert lCities;

            // Insert City Postal Codes
            List<City_Postal_Code__c> lPostalCodes = new List<City_Postal_Code__c>();
            for (City__c oCity : lCities){
                for (Integer j = 0; j < 1 * WORK_FACTOR; j++){
                    lPostalCodes.add(new City_Postal_Code__c(
                        HEXAPOSTE_Code__c = oCity.INSEE_Code__c + ' ' + String.valueOf(j),
                        Postal_Code__c = oCity.INSEE_Code__c + ' ' + String.valueOf(j),
                        City__c = oCity.Id,
                        City__r = oCity
                    ));
                }
            }
            insert lPostalCodes;
            
            List<Account> lAccts = new List<Account>();
            //List<TestCase> lTestCases = new List<TestCase>();

            Account loopAcct;
            for (City_Postal_Code__c oCPC : lPostalCodes){
                loopAcct = new Account(City_Code__c = oCPC.City__r.INSEE_Code__c, Postal_Code__c = oCPC.Postal_Code__c, Country__c='FR', Phone='0202020202');
                lAccts.add(loopAcct);
                //lTestCases.add(new TestCase(loopAcct, oCPC));
            }

            Test.startTest();
            new AP_CityMatchingEngine_01('City_Code__c', 'Postal_Code__c', 'City__c', 'SAP_City_Code__c', 'SAP_Postal_Code__c', 'SAP_City_Name__c', 'City_Postal_Code__c', true).match(lAccts);
            Test.stopTest();

            //for (TestCase oCase : lTestCases){
            //  oCase.check();
            //}
            
        }
    }

    public static testmethod void testFuzzyMatch(){
        
        Integer WORK_FACTOR = 5;
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCME1',Alias='APCME1',
            Email='APCME1@shell.com',Username='APCME1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            
            Canton__c canton = new Canton__c(INSEE_Code__c = '0101');
            insert canton;

            // Insert Cities
            List<City__c> lCities = new List<City__c>();
            for (Integer i = 0; i < 30 * WORK_FACTOR; i++){ // City creation loop
                lCities.add(new City__c(INSEE_Code__c = String.valueOf(i), Canton__c = canton.Id));
            }
            insert lCities;

            // Insert City Postal Codes
            List<City_Postal_Code__c> lPostalCodes = new List<City_Postal_Code__c>();
            for (City__c oCity : lCities){
                for (Integer j = 0; j < 1 * WORK_FACTOR; j++){
                    lPostalCodes.add(new City_Postal_Code__c(
                        HEXAPOSTE_Code__c = oCity.INSEE_Code__c + ' ' + String.valueOf(j),
                        Postal_Code__c = oCity.INSEE_Code__c + ' ' + String.valueOf(j),
                        City__c = oCity.Id,
                        City__r = oCity
                    ));
                }
            }
            insert lPostalCodes;
            
            List<Account> lAccts = new List<Account>();
            //List<TestCase> lTestCases = new List<TestCase>();

            Account loopAcct;
            for (City_Postal_Code__c oCPC : lPostalCodes) {
                loopAcct = new Account(
                    City_Code__c = oCPC.City__r.INSEE_Code__c, 
                    Postal_Code__c = String.valueOf(Crypto.getRandomInteger()).left(5),
                    City_Postal_Code__c = oCPC.Id,
                    City_Postal_Code__r = oCPC,                    
                    // Required, fields
                    Name = 'aName',Country__c='FR', Phone='0202020202',Email__c='titi.tata@gmail.com'
                );
                lAccts.add(loopAcct);
                //lTestCases.add(new TestCase(loopAcct, oCPC.City__r)); // Test the City, not the CPC
            }


            Test.startTest();
            insert lAccts;
            Test.stopTest();

            // Now, refresh the Accounts!
            Set<Id> sAcctIds = new Set<Id>();
            for (Account acct : lAccts){
                sAcctIds.add(acct.Id);
            }

            Map<Id, Account> mNewAccounts = new Map<Id, Account>([SELECT Id, City_Postal_Code__r.City__c FROM Account WHERE Id IN :sAcctIds]);



            /*for (TestCase oCase : lTestCases){
                oCase.acct = mNewAccounts.get(oCase.acct.Id);
                System.assert(oCase.acct != null);
                System.assert(oCase.acct.Id != null);
                oCase.check();
            }*/
        }
    }
}