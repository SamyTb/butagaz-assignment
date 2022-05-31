@isTest
private class AP_Assignment_Filter_01_TEST {

    public static testmethod void testSuccessiveInsertDuplicates(){
        // Here we test that inserting two duplicates one after the other fails.
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAF1',Alias='APAF1',
            Email='APAF1@shell.com',Username='APAF1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
			Group grp = new Group(Name = 'SomeGroup');
            insert grp;
            
            Rep_For_Filter__c RFF = new Rep_For_Filter__c(Target__c = 'Queue', QueueId__c = grp.Id, 
            	Assignment_Managed_Id__c = '1');
			insert RFF;

			Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');  
			Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
			//this.MT_DOM = 'DOM';                                 this.MT_PRO = 'PRO';

			Canton__c Some_Canton  = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '0101');   
			Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '0102');
			insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };

			City__c Some_City  = new City__c(Name = 'SomeCity', INSEE_Code__c = '01001', Canton__c = Some_Canton.Id);
			City__c Other_City = new City__c(Name = 'OtherCity', INSEE_Code__c = '01002', Canton__c = Other_Canton.Id);
			insert new List<Sobject>{Some_City, Other_City};

			City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
				HEXAPOSTE_Code__c = '01001');
			City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
				HEXAPOSTE_Code__c = '01002');

			Assignment_Filter__c AF1_1 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '2');
			Assignment_Filter__c AF1_2 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '3');
			Assignment_Filter__c AF2_1 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '4');
			Assignment_Filter__c AF2_2 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '5');
			Assignment_Filter__c AF3_1 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '6');
			Assignment_Filter__c AF3_2 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '7');
				
			Boolean hasErrored1 = false;
        	Boolean hasErrored2 = false;
        	Boolean hasErrored3 = false;
        	
        	Test.startTest();

        	insert AF1_1;
        	insert AF2_1;
        	insert AF3_1;

        	try { insert AF1_2; }
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored1 = true;
        	}
        	try { insert AF2_2; }
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored2 = true;
			}
        	try { insert AF3_2; }
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored3 = true;
        	}
        	System.assert(hasErrored1);
        	System.assert(hasErrored2);
        	System.assert(hasErrored3);

        	Test.stopTest();    
        }       
    }

    public static testmethod void testSimultaneousInsertDuplicates(){
        // Here we test that inserting two duplicates at the same time raises an error.
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAF2',Alias='APAF2',
            Email='APAF2@shell.com',Username='APAF2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
			Group grp = new Group(Name = 'SomeGroup');
            insert grp;
            
            Rep_For_Filter__c RFF = new Rep_For_Filter__c(Target__c = 'Queue', QueueId__c = grp.Id, 
            	Assignment_Managed_Id__c = '1');
			insert RFF;

			Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');  
			Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
			//this.MT_DOM = 'DOM';                                 this.MT_PRO = 'PRO';

			Canton__c Some_Canton  = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '0101');   
			Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '0102');
			insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };

			City__c Some_City  = new City__c(Name = 'SomeCity', INSEE_Code__c = '01001', Canton__c = Some_Canton.Id);
			City__c Other_City = new City__c(Name = 'OtherCity', INSEE_Code__c = '01002', Canton__c = Other_Canton.Id);
			insert new List<Sobject>{Some_City, Other_City};

			City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
				HEXAPOSTE_Code__c = '01001');
			City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
				HEXAPOSTE_Code__c = '01002');

			Assignment_Filter__c AF1_1 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '2');
			Assignment_Filter__c AF1_2 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '3');
			Assignment_Filter__c AF2_1 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '4');
			Assignment_Filter__c AF2_2 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '5');
			Assignment_Filter__c AF3_1 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '6');
			Assignment_Filter__c AF3_2 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '7');
				
			
			Boolean hasErrored1 = false;
        	Boolean hasErrored2 = false;
        	Boolean hasErrored3 = false;

        	Test.startTest();

        	try { insert new List<SObject>{AF1_1, AF1_2};}
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored1 = true;
        	}
        	try { insert new List<SObject>{AF2_1, AF2_2};}
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored2 = true;
        	}
        	try { insert new List<SObject>{AF3_1, AF3_2};}
        	catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored3 = true;
        	}
        	System.assert(hasErrored1);
        	System.assert(hasErrored2);
        	System.assert(hasErrored3);

        	Test.stopTest();
				
        }
        
        
    }

    public static testmethod void testUpdateDuplicates(){
        // Here we test that inserting two duplicates at the same time raises an error.
                
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APAF2',Alias='APAF2',
            Email='APAF2@shell.com',Username='APAF2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
			Group grp = new Group(Name = 'SomeGroup');
            insert grp;
            
            Rep_For_Filter__c RFF = new Rep_For_Filter__c(Target__c = 'Queue', QueueId__c = grp.Id, 
            	Assignment_Managed_Id__c = '1');
			insert RFF;

			Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');  
			Activity_Domain__c AD_GER = new Activity_Domain__c(name = 'GER');
			//this.MT_DOM = 'DOM';                                 this.MT_PRO = 'PRO';

			Canton__c Some_Canton  = new Canton__c(name = 'SomeCanton', INSEE_Code__c = '0101');   
			Canton__c Other_Canton = new Canton__c(name = 'OtherCanton', INSEE_Code__c = '0102');
			insert new List<Sobject>{ AD_GEC, AD_GER, Some_Canton, Other_Canton };

			City__c Some_City  = new City__c(Name = 'SomeCity', INSEE_Code__c = '01001', Canton__c = Some_Canton.Id);
			City__c Other_City = new City__c(Name = 'OtherCity', INSEE_Code__c = '01002', Canton__c = Other_Canton.Id);
			insert new List<Sobject>{Some_City, Other_City};

			City_Postal_Code__c Some_Code = new City_Postal_Code__c(Name = '01001 - SomeCity', City__c = Some_City.Id, 
				HEXAPOSTE_Code__c = '01001');
			City_Postal_Code__c Other_Code = new City_Postal_Code__c(Name = '01002 - OtherCity', City__c = Other_City.Id, 
				HEXAPOSTE_Code__c = '01002');

			Assignment_Filter__c AF1_1 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '2');
			Assignment_Filter__c AF1_2 = new Assignment_Filter__c( Activity_Domain__c = AD_GEC.Id, 
				Market_Type__c = 'PRO', Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '3');
			Assignment_Filter__c AF2_1 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '4');
			Assignment_Filter__c AF2_2 = new Assignment_Filter__c( Market_Type__c = 'PRO', 
				Canton__c = Some_Canton.Id, Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '5');
			Assignment_Filter__c AF3_1 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '6');
			Assignment_Filter__c AF3_2 = new Assignment_Filter__c( Canton__c = Some_Canton.Id, 
				Rep_For_Filter__c = RFF.Id, Assignment_Managed_Id__c = '7');
        
        	Boolean hasErrored1 = false;
        	Boolean hasErrored2 = false;
        	Boolean hasErrored3 = false;

        	insert AF1_1;
        	insert AF2_1;
        	insert AF3_1;

        	Test.startTest();
        	AF1_2.Activity_Domain__c = AD_GER.Id;
        	AF2_2.Canton__c = Other_Canton.Id;
        	AF3_2.Market_Type__c = 'DOM';

        	insert AF1_2;
        	insert AF2_2;
        	insert AF3_2;

        	try { 
            	AF1_2.Activity_Domain__c = AD_GEC.Id;
            	update AF1_2; 
        	} catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored1 = true;
        	}
        	try { 
            	AF2_2.Canton__c = Some_Canton.Id;
            	update AF2_2; 
        	} catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored2 = true;
        	}
        	try { 
            	AF3_2.Market_Type__c = 'PRO';
            	update AF3_2; 
        	} catch (System.DmlException e){
            	System.assert(e.getmessage().contains(System.Label.Error_DuplicateAssignmentFilters));
            	hasErrored3 = true;
        	}

        	System.assert(hasErrored1);
        	System.assert(hasErrored2);
        	System.assert(hasErrored3);

        	Test.stopTest();
        }    
    }
}