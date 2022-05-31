@isTest
private class VFC_User_Test {
	
	@isTest static void revokePackageLicenseFromUser() {
		
		System.Debug('### >>>>> testing class VFC_User_Test.revokePackageLicenseFromUser <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;

        // Creating 2 different users because of MIXED_DML_OPERATION issue
        User u1 = new User(FirstName='Test1', LastName='VFCU1',Alias='VFCU1',
            Email='VFCU@butagaz.com',Username='VFCU1@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', IsActive=True);
            
        insert u1;
        
        System.runAs(u1) {
        	// Custom settings
	        Custom_Settings__c c1 = new Custom_Settings__c(name = 'PackageLicensesToRevokeOnInactiveUsers', value__c = 'TestPckg');
	        insert new List<Custom_Settings__c> { c1 };
        }


        User u2 = new User(FirstName='Test2', LastName='VFCU2',Alias='VFCU2',
            Email='VFCU@butagaz.com',Username='VFCU2@butagaz.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', IsActive=True);
            
        insert u2;

        System.runAs(u2) {
        
	        // Did not find a way to create a packaged license in test class
	        /*PackageLicense pckgLicense1 = new PackageLicense(NamespacePrefix = 'TestPckg');
	        insert new List<PackageLicense> { pckgLicense1 };

	        UserPackageLicense userPckgLicense1 = new UserPackageLicense(PackageLicenseId = pckgLicense1.Id, UserId = u.Id);
	        insert new List<UserPackageLicense> { userPckgLicense1 };*/


	        Test.startTest();

	        u1.IsActive = false;
	        update u1;

	        // See issue above
	        /*List<UserPackageLicense> userPckgLicenseForAssertionList = [SELECT Id FROM UserPackageLicense 
																									WHERE PackageLicenseId IN :pckgLicense1 
																									AND UserId IN :u];
	        System.assertEquals(0, userPckgLicenseForAssertionList.size());*/

	        Test.stopTest();

    	}
        System.Debug('### >>>>> testing class VFC_User_Test.revokePackageLicenseFromUser END <<<<<');
	}
	
}