@isTest
public class VFC_ObjectifCommerciauxGEB_01_Test {
	
  
	public static testmethod void testObjectifCommerciauxGEB(){
		// Data Model           

        // Articles
        list<Item__c> lArticlesToInsert = new list<Item__c>();
        
        Item__c oBouteille = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000000100', Type__c ='Bouteille'); 
        //Item__c oBouteille2 = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000000300', Type__c ='Bouteille'); 

        lArticlesToInsert.add(oBouteille);
       // lArticlesToInsert.add(oBouteille2);

        insert lArticlesToInsert; 
        
        //Commercial
		Id Userid = UserInfo.getUserId();
		                 
        // Start test
        test.starttest();
                        
        // "New" mode
        //Commercial Objective GEB         
        ObjCom_GEB__c oObjCom = new ObjCom_GEB__c(ObjCOm_date__c = date.today());        
        VFC_ObjectifCommecialGEB_01 oControlNew = new VFC_ObjectifCommecialGEB_01(new ApexPages.standardcontroller(oObjCom));
        
        oControlNew.calcTotal(); 
        oControlNew.saveBtn();

        // "Edit" mode
        //Commercial Objective GEB
        ObjCom_GEB__c oObjCom2 = new ObjCom_GEB__c(Commercial__c=Userid,ObjCOm_date__c = date.today());        
        insert oObjCom2;
        
        list<Objectif_Article_YearMonth__c> lObjArticleYearMonthToInsert = new list<Objectif_Article_YearMonth__c>();
        Objectif_Article_YearMonth__c oObjComArticle1 = new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom2.Id,Objective_Date__c=date.today(),Article__c=oBouteille.Id, Article__r=oBouteille,Tonnage_Global__c=19,Consignations_nettes_mandataire__c=5);                
//        Objectif_Article_YearMonth__c oObjComArticle2 = new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom2.Id,Objective_Date__c=date.today().addMonths(1),Article__c=oBouteille2.Id, Article__r=oBouteille2,Tonnage_Global__c=null,Consignations_nettes_mandataire__c=null);                
      	
      	lObjArticleYearMonthToInsert.add(oObjComArticle1);
//      	lObjArticleYearMonthToInsert.add(oObjComArticle2);      	
 
 		insert   lObjArticleYearMonthToInsert;   	
        

        VFC_ObjectifCommecialGEB_01 oControlEdit = new VFC_ObjectifCommecialGEB_01(new ApexPages.standardcontroller(oObjCom2));		

        oControlEdit.calcTotal(); 
        oControlEdit.saveBtn();
                          		                               		        

        // Stop test        
        test.stoptest();		         
	}	

}