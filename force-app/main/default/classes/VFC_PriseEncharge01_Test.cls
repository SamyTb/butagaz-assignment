@isTest
public class VFC_PriseEncharge01_Test {
    public static testmethod void testPriseEncharge(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        // Data Model
            
        // Account
        Account oAccount = new Account(name='PECaccount', AccountNumber='C65',Country__c='FR', Phone='0202020202',Email__c='titi.tata@gmail.com');
        insert oAccount;   
        
        
            
       // New Contact
       Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
       accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
       Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
       Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
       insert c;

        // PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', Account_DO__c=oAccount.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oPTL;
        
        // Articles
        list<Item__c> lArticlesToInsert = new list<Item__c>();
        
        Item__c oBouteille = new Item__c(Name = 'Bouteille', ExternalID__c='000000000000001515', Type__c ='Bouteille'); 
        Item__c oCasier = new Item__c(Name = 'Casier', ExternalID__c='000000000000001516', Type__c ='Casier'); 
        Item__c oAutreMateriel = new Item__c(Name = 'Autre Matériel', ExternalID__c='000000000000001517', Type__c ='Autre Matériel'); 

        lArticlesToInsert.add(oBouteille);
        lArticlesToInsert.add(oCasier);
        lArticlesToInsert.add(oAutreMateriel);

        insert lArticlesToInsert;        

        // Butagaz Stock Installed
        Butagaz_Stock_Installed__c oStockInstalled = new Butagaz_Stock_Installed__c(
            PTL__c = oPTL.Id,
            Article__c=oBouteille.Id,
            Stock_installe__c=12
        );
        insert oStockInstalled;
        
        
        //Prise en Charge
        PEC__c oPEC = new PEC__c(Account__c=oAccount.Id,PEC_Date__c = datetime.now());
        //Last Prise en Charge
        PEC__c oLastPEC = new PEC__c(Account__c=oAccount.Id,PEC_Date__c = datetime.now().addDays(-1));
        insert oLastPEC;
         
        // Start test
        test.starttest();
                        
        // "New" mode       
        VFC_PriseEnCharge01 oControlNew = new VFC_PriseEnCharge01(new ApexPages.standardcontroller(oPEC));
        
        oControlNew.calcCost(); 
        oControlNew.saveBtn();

        // "Edit" mode
        //Last Prise en Charge
        PEC__c oLastPEC2 = new PEC__c(Account__c=oAccount.Id,PEC_Date__c = datetime.now().addDays(-1));
        insert oLastPEC2;
        PEC_Article__c oLastPECBouteille = new PEC_Article__c(Prise_en_Charge__c=oLastPEC2.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=15,Stock_PEC_pret__c=4,Stock_PEC_consigne__c=1);                
        insert oLastPECBouteille;
        
        //Prise en Charge
        PEC__c oPEC2 = new PEC__c(Account__c=oAccount.Id,Last_PEC__c=oLastPEC2.id, PEC_Date__c = datetime.now());        
        insert oPEC2;
        
        list<PEC_Article__c> lPECArticleToInsert = new list<PEC_Article__c>();
        PEC_Article__c oPECBouteille = new PEC_Article__c(Prise_en_Charge__c=oPEC2.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=10,Stock_PEC_consigne__c=5);                
        PEC_Article__c oPECBouteille2 = new PEC_Article__c(Prise_en_Charge__c=oPEC2.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Unit_Cost__c=19,Stock_PEC_pret__c=null,Stock_PEC_consigne__c=null);                
        PEC_Article__c oPECCasier = new PEC_Article__c(Prise_en_Charge__c=oPEC2.Id,Article__c=oCasier.Id, Article__r=oCasier,Unit_Cost__c=29,Stock_PEC_pret__c=4,Stock_PEC_consigne__c=2);                
        PEC_Article__c oPECAutreMateriel = new PEC_Article__c(Prise_en_Charge__c=oPEC2.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Unit_Cost__c=15,Stock_PEC_pret__c=6,Stock_PEC_consigne__c=3);                
        
        lPECArticleToInsert.add(oPECBouteille);
        lPECArticleToInsert.add(oPECBouteille2);        
        lPECArticleToInsert.add(oPECCasier);
        lPECArticleToInsert.add(oPECAutreMateriel);
 
        insert   lPECArticleToInsert;       
        

        //CS Account
        oAccount.Channel__c = 'CS';
        update  oAccount;
        VFC_PriseEnCharge01 oControlEditCS = new VFC_PriseEnCharge01(new ApexPages.standardcontroller(oPEC2));      
        oControlEditCS.calcCost(); 
        oControlEditCS.saveBtn();
        
        //Re account
        oAccount.Channel__c = 'RE';
        update  oAccount;
        VFC_PriseEnCharge01 oControlEditRE = new VFC_PriseEnCharge01(new ApexPages.standardcontroller(oPEC2));              
        oControlEditRE.calcCost();
        oControlEditRE.saveBtn();    

        List<PEC_Article__c> ListBouteillesInstalles = oControlEditCS.getListBouteillesInstalles(); 
        List<PEC_Article__c> ListCasiersInstalles = oControlEditCS.getListCasiersInstalles();       
        List<PEC_Article__c> ListAMInstalles = oControlEditCS.getListAMInstalles();
        boolean RenderBouteilles=  oControlEditCS.getRenderBouteilles();           
        boolean getRenderCasiers=  oControlEditCS.getRenderCasiers();                                                       
        boolean RenderAutreMateriel=  oControlEditCS.getRenderAutreMateriel();                                              
        boolean RenderBouteillesInstalles=  oControlEditCS.getRenderBouteillesInstalles(); 
        boolean RenderCasiersInstalles=  oControlEditCS.getRenderCasiersInstalles();                                                                            
        boolean RenderAMInstalles=  oControlEditCS.getRenderAMInstalles();                              
        String LastPEcDate = oControlEditCS.getLastPecDate(); 
        String TodayDate = oControlEditCS.getTodayDate(); 
        
        // Test of Class VFC_PECArticles01 
        VFC_PECArticles01 oControlEditPECArticle = new VFC_PECArticles01(new ApexPages.standardcontroller(oPECBouteille));
        PageReference pPECpage = oControlEditPECArticle.getPECPage();
        
        //Case of Editing Canceled PEC
        //Prise en Charge
        PEC__c oPEC3 = new PEC__c(Account__c=oAccount.Id,Status__c='Annulée', PEC_Date__c = datetime.now());        
        insert oPEC3;       
        VFC_PriseEnCharge01 oControlEditCanceled = new VFC_PriseEnCharge01(new ApexPages.standardcontroller(oPEC3));                  

        //Case of PEC without Account
        PEC__c oPEC4 = new PEC__c(Account__c=null, PEC_Date__c = datetime.now());        
        VFC_PriseEnCharge01 oControlEditWithoutAccount = new VFC_PriseEnCharge01(new ApexPages.standardcontroller(oPEC4));                
                
        // Stop test        
        test.stoptest();                 
    }
}