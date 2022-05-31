@isTest
private class Batch_Updating_PTL_ContactMKT_TEST {

    static testMethod void Batch_Updating_PTL_ContactMKT_ELC() {
    	
		String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='BUPTLC1',Alias='BUPTLC1',
            Email='BUPTLC1@shell.com',Username='BUPTLC1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        System.runAs(u) {
        	// Create some test PTLs
			Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=41);
			insert AD_GEC;
       
			Activity_Domain__c anotherAD = new Activity_Domain__c(name = 'TEST', ExternalID__c=99);
			insert anotherAD;
       
			Mandataire__c mand1 = new Mandataire__c(
				name = 'BUPTLC1 Mandataire',
				ExternalID__c = 'VPS01',
				Active__c = true
			);
			insert mand1;
		
			List<PTL__c> ptlList = new List<PTL__c>();
			for (Integer i = 0; i < 20; i++ ) {
				PTL__c ptl = new PTL__c(
					Activity_Domain__c = AD_GEC.id,
					Mandataire__c = mand1.id,
					City__c = 'BUPTLC1 City' + i,
					Postal_Code__c = '09876'
				);
				ptlList.add(ptl);
			}
			for (Integer i = 0; i < 20; i++ ) {
				PTL__c ptl = new PTL__c(
					Activity_Domain__c = anotherAD.id,
					Mandataire__c = mand1.id,
					City__c = 'BUPTLC2 City' + i,
					Postal_Code__c = '09875'
				);
				ptlList.add(ptl);
			}
			insert ptlList;

			Test.startTest();
			Batch_Updating_PTL_ContactMKT_ELC b = new Batch_Updating_PTL_ContactMKT_ELC();
			ID batchprocessid = Database.executeBatch(b);
			Test.stopTest();

			// Verify results 
			Integer i = [SELECT COUNT() FROM PTL__c WHERE Activity_Domain__c =: AD_GEC.id];
			System.assertEquals(20, i);
        }    
    }
    
    static testMethod void Batch_Updating_PTL_ContactMKT() {
    	
		String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='BUPTLC1',Alias='BUPTLC2',
            Email='BUPTLC2@shell.com',Username='BUPTLC2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        System.runAs(u) {
        	// Create some test PTLs
			Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=41);
			insert AD_GEC;
       
			Mandataire__c mand1 = new Mandataire__c(
				name = 'BUPTLC2 Mandataire',
				ExternalID__c = 'VPS02',
				Active__c = true
			);
			insert mand1;
		
			List<PTL__c> ptlList = new List<PTL__c>();
			for (Integer i = 0; i < 50; i++ ) {
				PTL__c ptl = new PTL__c(
					Activity_Domain__c = AD_GEC.id,
					Mandataire__c = mand1.id,
					City__c = 'BUPTLC2 City' + i,
					Postal_Code__c = '09876'
				);
				ptlList.add(ptl);
			}
			insert ptlList;

			Test.startTest();
			Batch_Updating_PTL_ContactMKT b = new Batch_Updating_PTL_ContactMKT();
			ID batchprocessid = Database.executeBatch(b);
			Test.stopTest();

			// Verify results 
			Integer i = [SELECT COUNT() FROM PTL__c WHERE Contact_Marketing__c =''];
			System.assertEquals(50, i);
        }    
    }
}