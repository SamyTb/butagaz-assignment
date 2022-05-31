@isTest
public class VFC_CommandesUsages_Test {
    public static testmethod void testCommandesUsages(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        // Data Model
            
        // Account
        Account oAccount = new Account(name='CDSaccount', AccountNumber='C65',Country__c='FR', Phone='0202020202');
        insert oAccount;   


        // Articles
        list<Item__c> lArticlesToInsert = new list<Item__c>();
        
        Item__c oUsage = new Item__c(Name = 'Usages', ExternalID__c='000000000000001515', Type__c ='Usages',Recommended_Price__c=10); 
        Item__c oServUsage = new Item__c(Name = 'Service Usages', ExternalID__c='000000000000001516', Type__c ='Services Usages',Recommended_Price__c=1); 
 
        lArticlesToInsert.add(oUsage);
        lArticlesToInsert.add(oServUsage);
        
        insert lArticlesToInsert;        
    
        //Commande Usage
        CUSAGE__c oCUSAGE = new CUSAGE__c(Account__c=oAccount.Id,Date_de_Commande__c = date.today());
         
        // Start test
        test.starttest();
                        
        // "New" mode       
        VFC_CommandesUsages oControlNew = new VFC_CommandesUsages(new ApexPages.standardcontroller(oCUSAGE));
        
        oControlNew.calcCost(); 
        oControlNew.saveBtn();

        // "Edit" mode

        //CUSAGE
        CUSAGE__c oCUSAGE2 = new CUSAGE__c(Account__c=oAccount.Id,Date_de_Commande__c = date.today());        
        insert oCUSAGE2;
        
        list<CUSAGE_Article__c> lCUSAGEArticleToInsert = new list<CUSAGE_Article__c>();
        CUSAGE_Article__c oCUSAGEArticle1 = new CUSAGE_Article__c(CUSAGES__c=oCUSAGE2.Id,Article__c=oUsage.Id, Article__r=oUsage,Quantite__c=19,Prix_unitaire__c=5);                
        CUSAGE_Article__c oCUSAGEArticle2 = new CUSAGE_Article__c(CUSAGES__c=oCUSAGE2.Id,Article__c=oUsage.Id, Article__r=oUsage,Quantite__c=null);                
        CUSAGE_Article__c oCUSAGEArticle3 = new CUSAGE_Article__c(CUSAGES__c=oCUSAGE2.Id,Article__c=oServUsage.Id, Article__r=oServUsage,Prix_unitaire__c=29);                
        
        lCUSAGEArticleToInsert.add(oCUSAGEArticle1);
        lCUSAGEArticleToInsert.add(oCUSAGEArticle2);        
        lCUSAGEArticleToInsert.add(oCUSAGEArticle3);
 
        insert   lCUSAGEArticleToInsert;    
        

        VFC_CommandesUsages oControlEdit = new VFC_CommandesUsages(new ApexPages.standardcontroller(oCUSAGE2));     

        oControlEdit.calcCost(); 
        oControlEdit.saveBtn();
   

        List<CUSAGE_Article__c> ListUsagesInstalles = oControlEdit.getListUsagesInstalles();    
                                                                        
        String TodayDate = oControlEdit.getTodayDate(); 

        // Test of Class VFC_CommandeUsagesArticle01 
        VFC_CommandeUsagesArticle01 oControlEditCUSAGEArticle = new VFC_CommandeUsagesArticle01(new ApexPages.standardcontroller(oCUSAGEArticle1));
        PageReference pCUSAGEpage = oControlEditCUSAGEArticle.getCUSAGESPage();
        
        //Case of CUSAGE without Account
        CUSAGE__c oCUSAGE4 = new CUSAGE__c(Account__c=null, Date_de_Commande__c = date.today());        
        VFC_CommandesUsages oControlEditWithoutAccount = new VFC_CommandesUsages(new ApexPages.standardcontroller(oCUSAGE4));                 
        
        // Stop test        
        test.stoptest();                 
    }
}