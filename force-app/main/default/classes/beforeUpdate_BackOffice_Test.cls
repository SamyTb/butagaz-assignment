@isTest
public class beforeUpdate_BackOffice_Test 
{
	@isTest static void updateStatut() 
    {
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Group grp = [select Id, DeveloperName from Group where DeveloperName='BackOffice'];
        system.debug('grp:'+grp);
            
        GroupMember gm = new GroupMember(GroupId = grp.Id, UserOrGroupId = u.Id);
    	insert gm;
        system.debug('gm:'+gm);

        System.runAs(u) {
                
	        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
    	    insert new List<Custom_Settings__c> { c1 };
        
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;

            Account a = new Account(Name='VFCQLI01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;

            CDS__c  cds = new CDS__c();      
            cds.Account__c = a.Id;
            cds.CDS_Date__c = system.today();
            cds.Status__c = 'Attente de signature';
            insert cds;

            Test.startTest();
			
            cds.Status__c = 'Validé par BO';
            update cds;
            
            Test.stopTest();
            
        }    
    }
}