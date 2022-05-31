@isTest
private class AP_PTLComsumptionProfile_01_Test {
	
	static testMethod void AP_PTLComsumptionProfile_01_Test() {
	
		System.Debug('### >>>>> testing class AP_PTLComsumptionProfile_01_Test <<<<<');
   
		String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='PTLCP',Alias='PTLCP',
            Email='PTLCP@shell.com',Username='PTLCP@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        System.runAs(u) {
        	PTL_Consumption_Profile__c pcp = new PTL_Consumption_Profile__c();
        	
        	Test.startTest();
        	insert pcp;
        	
        	update pcp;
        	Test.stopTest();
        }
        
        System.Debug('### >>>>> testing class AP_PTLComsumptionProfile_01_Test END <<<<<');
	}
}