@isTest
//@isTest(seealldata=true)
public class AP_PTLCommercialResults_Test {
  public static testmethod void testPTLCommercialResults(){
        
        // User
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APOT1',Alias='APOT1',
            Email='APOT1@shell.com',Username='APOT1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;
        
        // Articles
        list<Item__c> lArticlesToInsert = new list<Item__c>();
        Item__c oBouteille = new Item__c(Name = 'Bouteille', ExternalID__c='yyyyyyyyyyyyyyyyyy', Type__c ='Bouteille'); 
        //Item__c oBouteille2 = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000000300', Type__c ='Bouteille'); 
        lArticlesToInsert.add(oBouteille);
        // lArticlesToInsert.add(oBouteille2);
        insert lArticlesToInsert; 
    	
    	// ObjCom_GEB__c
    	list<ObjCom_GEB__c> lObjComGEB = new list<ObjCom_GEB__c>();
    	ObjCom_GEB__c oObjComGEB = new ObjCom_GEB__c(Code_AC__c='999', Commercial__c=u.Id, ObjCOm_date__c=Date.parse('01/01/2016'), 
    		External_Id__c='2016999');
    	lObjComGEB.add(oObjComGEB);
    	insert lObjComGEB;
    	
    	// Objectif_Article_YearMonth__c
    	list<Objectif_Article_YearMonth__c> lObjArtYearMonth = new list<Objectif_Article_YearMonth__c>();
    	Objectif_Article_YearMonth__c oObjArtYearMonth = new Objectif_Article_YearMonth__c(Article__c=oBouteille.Id, Consignations_nettes_mandataire__c=10,
    		Objective_Date__c=Date.parse('01/01/2016'), ObjCom_GEB__c=oObjComGEB.Id, Tonnage_Global__c=50);
    	lObjArtYearMonth.add(oObjArtYearMonth);
    	insert lObjArtYearMonth;
    	
    	// Attache_Commercial__c
    	Attache_Commercial__c oAttacheCommercial = new Attache_Commercial__c(Name = '999 - myGrpVdr', Code_Groupe_Vendeur__c = '999', Libelle_Groupe_Vendeur__c = 'myGrpVdr');
        insert oAttacheCommercial;
    	
    	// PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL',City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true, Code_AC_administrator_New__c=oAttacheCommercial.Id);
        insert oPTL;
    	
    	// Activity Domain
    	//Activity_Domain__c oAdd = [select id from Activity_Domain__c where externalID__c=41 limit 1];
    	Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c=41);
        insert AD_GEB;
    
    	// Start test
        test.starttest();

        // "New" mode
        //Commercial Objective GEB         
        PTL_Commercial_Results__c oPTLCommercialResult = new PTL_Commercial_Results__c(PTL__c=oPTL.id,Article__c=oBouteille.id,Article__r=oBouteille,Year_Month__c='201601',Activity_Domain__c=AD_GEB.id,File_Created_Date__c=date.today(),External_ID__c='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');        
        
        insert oPTLCommercialResult;
        
        update oPTLCommercialResult;

        // Stop test        
        test.stoptest();            
  }

}