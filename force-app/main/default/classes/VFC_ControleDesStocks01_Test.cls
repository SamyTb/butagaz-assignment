@isTest
public class VFC_ControleDesStocks01_Test {
    public static testmethod void testControleDesStocks(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCCDS',Alias='VFCCDS',
            Email='VFCCDS@shell.com',Username='VFCCDS@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyCDSStatus', value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1, c2 };
        
        System.runAs(u) {
        
            // Data Model
            
            // Account
            Account oAccount = new Account(name='CDSaccount', AccountNumber='C65',Country__c='FR', Phone='0202020202',Email__c='totot@tata.com',
                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
            insert oAccount; 
            
             // New Contact
             Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
             accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
             Postal_Code__c = oAccount.Postal_Code__c,City__c =oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
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
    		//FLA calcul compensation
            Item__c oBouteilleBD = new Item__c(Name = 'BUTANE 13KG', ExternalID__c='000000000000001518', Type__c ='Bouteille'); 
            Item__c oBouteilleG = new Item__c(Name = 'PROPANE 13KG', ExternalID__c='000000000000001519', Type__c ='Bouteille'); 
            Item__c oBouteilleCB = new Item__c(Name = 'BUTANE CUBE 6KG', ExternalID__c='000000000000001520', Type__c ='Bouteille'); 
            Item__c oBouteilleCP = new Item__c(Name = 'PROPANE CUBE 5KG', ExternalID__c='000000000000001521', Type__c ='Bouteille'); 

            lArticlesToInsert.add(oBouteille);
    		//FLA calcul compensation
            lArticlesToInsert.add(oBouteilleBD);
            lArticlesToInsert.add(oBouteilleG);
            lArticlesToInsert.add(oBouteilleCB);
            lArticlesToInsert.add(oBouteilleCP);

            lArticlesToInsert.add(oCasier);
            lArticlesToInsert.add(oAutreMateriel);
    
            insert lArticlesToInsert;        
    
            // Butagaz Stock Installed
            Butagaz_Stock_Installed__c oStockInstalled = new Butagaz_Stock_Installed__c(
                PTL__c = oPTL.Id,
                Article__c=oBouteille.Id,
                Stock_pret_materiel__c=12
            );
            insert oStockInstalled;
            
            
            //CDS
            CDS__c oCDS = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());
            
			//FLA DEBUT AUTRE CAS COMPENSATION
            // Articles
            list<Item__c> lArticlesToInsert1 = new list<Item__c>();
    		//FLA calcul compensation
            Item__c oBouteilleBD1 = new Item__c(Name = 'BUTANE 13KG', ExternalID__c='000000000000001522', Type__c ='Bouteille'); 
            Item__c oBouteilleG1 = new Item__c(Name = 'PROPANE 13KG', ExternalID__c='000000000000001523', Type__c ='Bouteille'); 
            Item__c oBouteilleCB1 = new Item__c(Name = 'BUTANE CUBE 6KG', ExternalID__c='000000000000001524', Type__c ='Bouteille'); 
            Item__c oBouteilleCP1 = new Item__c(Name = 'PROPANE CUBE 5KG', ExternalID__c='000000000000001525', Type__c ='Bouteille'); 
            lArticlesToInsert1.add(oBouteilleBD1);
            lArticlesToInsert1.add(oBouteilleG1);
            lArticlesToInsert1.add(oBouteilleCB1);
            lArticlesToInsert1.add(oBouteilleCP1);

            //FLA FIN AUTRE CAS COMPENSATION            
            
            
            // Start test
            test.starttest();
                            
            // "New" mode       
            VFC_ControleDesStocks01 oControlNew = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS));
            
            oControlNew.calcResultBtn(); 
            oControlNew.saveBtn();
    
            // "Edit" mode
    
            //CDS
            CDS__c oCDS2 = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());        
            insert oCDS2;
            
            list<CDS_Article__c> lCDSArticleToInsert = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteille = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Consignation__c=true,Valeur_Consignation__c=5);                
            CDS_Article__c oCDSBouteille2 = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteille.Id, Article__r=oBouteille,Stock_effectif__c=19,Deconsignation__c=true,Valeur_Deconsignation__c=3);                
            CDS_Article__c oCDSCasier = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oCasier.Id, Article__r=oCasier,Stock_effectif__c=29,Stock_PEC__c=4);                
            CDS_Article__c oCDSAutreMateriel = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oAutreMateriel.Id, Article__r=oAutreMateriel,Stock_effectif__c=null);                
    		//FLA calcul compensation
            CDS_Article__c oCDSBouteilleBD = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteilleBD.Id, Article__r=oBouteilleBD,Stock_PEC__c=15, Stock_effectif__c=19);                
            CDS_Article__c oCDSBouteilleG = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteilleG.Id, Article__r=oBouteilleG,Stock_PEC__c=11, Stock_effectif__c=9);                
            CDS_Article__c oCDSBouteilleCB = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteilleCB.Id, Article__r=oBouteilleCB,Stock_PEC__c=15, Stock_effectif__c=19);                
            CDS_Article__c oCDSBouteilleCP = new CDS_Article__c(CDS__c=oCDS2.Id,Article__c=oBouteilleCP.Id, Article__r=oBouteilleCP,Stock_PEC__c=11, Stock_effectif__c=9);                
            
            lCDSArticleToInsert.add(oCDSBouteille);
            lCDSArticleToInsert.add(oCDSBouteille2);        
            lCDSArticleToInsert.add(oCDSBouteilleBD);
            lCDSArticleToInsert.add(oCDSBouteilleG);        
            lCDSArticleToInsert.add(oCDSBouteilleCB);
            lCDSArticleToInsert.add(oCDSBouteilleCP);        
            lCDSArticleToInsert.add(oCDSCasier);
            lCDSArticleToInsert.add(oCDSAutreMateriel);
     
            insert   lCDSArticleToInsert;       
            
    
            VFC_ControleDesStocks01 oControlEdit = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS2));        
    
            oControlEdit.calcResultBtn(); 
            oControlEdit.saveBtn();
       
    
            List<CDS_Article__c> ListBouteillesInstalles = oControlEdit.getListBouteillesInstalles();   
            List<CDS_Article__c> ListCasiersInstalles = oControlEdit.getListCasiersInstalles();     
            boolean RenderBouteilles=  oControlEdit.getRenderBouteilles();           
            boolean getRenderCasiers=  oControlEdit.getRenderCasiers();                                                     
            boolean RenderBouteillesInstalles=  oControlEdit.getRenderBouteillesInstalles(); 
            boolean RenderCasiersInstalles=  oControlEdit.getRenderCasiersInstalles();                                                                          
            String TodayDate = oControlEdit.getTodayDate(); 
    
            // Test of Class VFC_PECArticles01 
            VFC_CDSArticles01 oControlEditCDSArticle = new VFC_CDSArticles01(new ApexPages.standardcontroller(oCDSBouteille));
            PageReference pCDSpage = oControlEditCDSArticle.getCDSPage();
            
            //Case of Editing Canceled CDS
            //Prise en Charge
            CDS__c oCDS3 = new CDS__c(Account__c=oAccount.Id,Status__c='Annulé', CDS_Date__c = datetime.now());        
            insert oCDS3;       
            VFC_ControleDesStocks01 oControlEditCanceled = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS3));                  
    
            //Case of CDS without Account
            CDS__c oCDS4 = new CDS__c(Account__c=null, CDS_Date__c = datetime.now());        
            VFC_ControleDesStocks01 oControlEditWithoutAccount = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS4));                
    
            //FLA DEBUT SUITE COMPENSATION
            CDS__c oCDS5 = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());        
            insert oCDS5;
            
            list<CDS_Article__c> lCDSArticleToInsert5 = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteilleBD5 = new CDS_Article__c(CDS__c=oCDS5.Id,Article__c=oBouteilleBD.Id, Article__r=oBouteilleBD,Stock_PEC__c=15, Stock_effectif__c=11);                
            CDS_Article__c oCDSBouteilleG5 = new CDS_Article__c(CDS__c=oCDS5.Id,Article__c=oBouteilleG.Id, Article__r=oBouteilleG,Stock_PEC__c=11, Stock_effectif__c=13);                
            CDS_Article__c oCDSBouteilleCB5 = new CDS_Article__c(CDS__c=oCDS5.Id,Article__c=oBouteilleCB.Id, Article__r=oBouteilleCB,Stock_PEC__c=15, Stock_effectif__c=11);                
            CDS_Article__c oCDSBouteilleCP5 = new CDS_Article__c(CDS__c=oCDS5.Id,Article__c=oBouteilleCP.Id, Article__r=oBouteilleCP,Stock_PEC__c=11, Stock_effectif__c=13);                
            
            lCDSArticleToInsert5.add(oCDSBouteilleBD5);
            lCDSArticleToInsert5.add(oCDSBouteilleG5);        
            lCDSArticleToInsert5.add(oCDSBouteilleCB5);
            lCDSArticleToInsert5.add(oCDSBouteilleCP5);        
     
            insert   lCDSArticleToInsert5;       
    
            VFC_ControleDesStocks01 oControlEdit5 = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS5));        
    
            oControlEdit5.calcResultBtn(); 
            oControlEdit5.saveBtn();
			
            CDS__c oCDS6 = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());        
            insert oCDS6;
            
            list<CDS_Article__c> lCDSArticleToInsert6 = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteilleBD6 = new CDS_Article__c(CDS__c=oCDS6.Id,Article__c=oBouteilleBD.Id, Article__r=oBouteilleBD,Stock_PEC__c=15, Stock_effectif__c=16);                
            CDS_Article__c oCDSBouteilleG6 = new CDS_Article__c(CDS__c=oCDS6.Id,Article__c=oBouteilleG.Id, Article__r=oBouteilleG,Stock_PEC__c=11, Stock_effectif__c=9);                
            CDS_Article__c oCDSBouteilleCB6 = new CDS_Article__c(CDS__c=oCDS6.Id,Article__c=oBouteilleCB.Id, Article__r=oBouteilleCB,Stock_PEC__c=15, Stock_effectif__c=16);                
            CDS_Article__c oCDSBouteilleCP6 = new CDS_Article__c(CDS__c=oCDS6.Id,Article__c=oBouteilleCP.Id, Article__r=oBouteilleCP,Stock_PEC__c=11, Stock_effectif__c=9);                
            
            lCDSArticleToInsert6.add(oCDSBouteilleBD6);
            lCDSArticleToInsert6.add(oCDSBouteilleG6);        
            lCDSArticleToInsert6.add(oCDSBouteilleCB6);
            lCDSArticleToInsert6.add(oCDSBouteilleCP6);        
     
            insert   lCDSArticleToInsert6;       
    
            VFC_ControleDesStocks01 oControlEdit6 = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS6));        
    
            oControlEdit6.calcResultBtn(); 
            oControlEdit6.saveBtn();

            CDS__c oCDS7 = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());        
            insert oCDS7;
            
            list<CDS_Article__c> lCDSArticleToInsert7 = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteilleBD7 = new CDS_Article__c(CDS__c=oCDS7.Id,Article__c=oBouteilleBD.Id, Article__r=oBouteilleBD,Stock_PEC__c=15, Stock_effectif__c=16);                
            CDS_Article__c oCDSBouteilleG7 = new CDS_Article__c(CDS__c=oCDS7.Id,Article__c=oBouteilleG.Id, Article__r=oBouteilleG,Stock_PEC__c=11, Stock_effectif__c=10);                
            CDS_Article__c oCDSBouteilleCB7 = new CDS_Article__c(CDS__c=oCDS7.Id,Article__c=oBouteilleCB.Id, Article__r=oBouteilleCB,Stock_PEC__c=15, Stock_effectif__c=16);                
            CDS_Article__c oCDSBouteilleCP7 = new CDS_Article__c(CDS__c=oCDS7.Id,Article__c=oBouteilleCP.Id, Article__r=oBouteilleCP,Stock_PEC__c=11, Stock_effectif__c=10);                
            
            lCDSArticleToInsert7.add(oCDSBouteilleBD7);
            lCDSArticleToInsert7.add(oCDSBouteilleG7);        
            lCDSArticleToInsert7.add(oCDSBouteilleCB7);
            lCDSArticleToInsert7.add(oCDSBouteilleCP7);        
     
            insert   lCDSArticleToInsert7;       
    
            VFC_ControleDesStocks01 oControlEdit7 = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS7));        
    
            oControlEdit7.calcResultBtn(); 
            oControlEdit7.saveBtn();

            CDS__c oCDS8 = new CDS__c(Account__c=oAccount.Id,CDS_Date__c = datetime.now());        
            insert oCDS8;
            
            list<CDS_Article__c> lCDSArticleToInsert8 = new list<CDS_Article__c>();
            CDS_Article__c oCDSBouteilleBD8 = new CDS_Article__c(CDS__c=oCDS8.Id,Article__c=oBouteilleBD.Id, Article__r=oBouteilleBD,Stock_PEC__c=15, Stock_effectif__c=14);                
            CDS_Article__c oCDSBouteilleG8 = new CDS_Article__c(CDS__c=oCDS8.Id,Article__c=oBouteilleG.Id, Article__r=oBouteilleG,Stock_PEC__c=11, Stock_effectif__c=12);                
            CDS_Article__c oCDSBouteilleCB8 = new CDS_Article__c(CDS__c=oCDS8.Id,Article__c=oBouteilleCB.Id, Article__r=oBouteilleCB,Stock_PEC__c=15, Stock_effectif__c=14);                
            CDS_Article__c oCDSBouteilleCP8 = new CDS_Article__c(CDS__c=oCDS8.Id,Article__c=oBouteilleCP.Id, Article__r=oBouteilleCP,Stock_PEC__c=11, Stock_effectif__c=12);                
            
            lCDSArticleToInsert8.add(oCDSBouteilleBD8);
            lCDSArticleToInsert8.add(oCDSBouteilleG8);        
            lCDSArticleToInsert8.add(oCDSBouteilleCB8);
            lCDSArticleToInsert8.add(oCDSBouteilleCP8);        
     
            insert   lCDSArticleToInsert8;       
    
            VFC_ControleDesStocks01 oControlEdit8 = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS8));        
    
            oControlEdit8.calcResultBtn(); 
            oControlEdit8.saveBtn();
            //FLA FIN SUITE COMPENSATION
            
            /*//Case of blocked Account  
            oAccount.General_Deletion_Flag__c =true; 
            update oAccount;
            CDS__c oCDS5 = new CDS__c(Account__c=oAccount.Id, CDS_Date__c = datetime.now());        
            VFC_ControleDesStocks01 oControlEditBlockedAccount = new VFC_ControleDesStocks01(new ApexPages.standardcontroller(oCDS5));                
            */
            // Stop test        
            test.stoptest();                 

            //FLA DEBUT SUITE COMPENSATION
            CDS_Article__c oCDSBouteilleG66 = [select Id, Compensation_Excedents__c, Consignation_Manquants__c, Non_Facture_Excedents__c, Compensation_Manquants__c 
                             from CDS_Article__c where Id=: oCDSBouteilleG6.Id]; 
            system.debug('oCDSBouteilleG6:'+oCDSBouteilleG6);
            system.assertEquals(1, oCDSBouteilleG66.Compensation_Manquants__c);
			system.assertEquals(1, oCDSBouteilleG66.Consignation_Manquants__c);
            
            
        }
    }
}