@isTest
public class VFC_Quotelineitem_01_Test{
    
     @testSetup 
    public static void setup() {
       
         Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        insert new List<Custom_Settings__c> { c1, c9, c10, c11, c12,c13 };

}
     @isTest
   public static  void VFC_Quotelineitem_01_Test() {
        
        System.Debug('### >>>>> testing class VFC_Quotelineitem_01 <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
       
        
        System.runAs(u) {
            
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
			insert attCom;      
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            Account a = new Account(Name='VFCQLI01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            // PriceBooks & Products
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFCQLI01',Description='Test Pricebook VFCQLI01', isActive=true);
            insert pbk1;
            
            List<Pricebook2> pbkList = [select id, name from Pricebook2];
            for (Pricebook2 pbk: pbkList) {
                System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
            }
            
            List<Product2> prdList = new List<Product2>();
            
            for(Integer i=0;i<10;i++) {
                Product2 prd = new  Product2 (Name='Test Produit ' + i,Description='Produit ' + i,
                    productCode = 'PP-0' + i, isActive = true);
                prdList.add(prd);
            }
            //FLA
            Product2 p = new Product2(name = 'Test product FLA', CEM__c=true, ProductCode = 'SPPABO0017', 
                                      UseConsumerTarget__c=false, Family='Redevance', Sub_Type__c='Butabox');
            prdList.add(p);
            Product2 p1 = new Product2(name = 'Test product FLA 1', CEM__c=true, ProductCode = 'SPPABO0010', 
                                      UseConsumerTarget__c=false, Family='Redevance', Sub_Type__c='Butabox');
            prdList.add(p1);
            
            // VFCQLI01 specific
            prdList[0].UseConsumerTarget__c = true;
            prdList[1].CEM__c = true;
            prdList[1].VAPO__c = true;
			//FLA demande 37
            prdList[2].ProductCode = 'SPPABO0017';
            prdList[2].Family = 'Redevance';
            prdList[0].ProductCode = 'SPPABO0010';
            prdList[1].UseConsumerTarget__c=false;
            prdList[2].UseConsumerTarget__c=false;
            prdList[3].UseConsumerTarget__c=false;
            prdList[4].UseConsumerTarget__c=false;
            prdList[0].Family = 'Produit';
            prdList[1].Family = 'Redevance';
            prdList[3].Family = 'Redevance';
            prdList[4].Family = 'Redevance';
            prdList[3].ProductCode = 'SPPABO0010';
            prdList[4].ProductCode = 'SPPABO0010';
            insert prdList;
            prdList = [select id from Product2];
           
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            for (Product2 prd: prdList) {
                PricebookEntry pbe = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pb2StandardId,UnitPrice=1, isActive=true);
                PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pbk1.id,UnitPrice=1, isActive=true);
                pbeList.add(pbe);
                pbeList.add(pbe2);
            }
            insert pbeList;
            System.debug('### PbeList1:' + pbeList);
            System.debug('### PbeList1 size:' + pbeList.size());
            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            System.debug('### PbeList2:' + pbeList);
            System.debug('### PbeList2 size:' + pbeList.size());
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'VFCQLI01 Mandataire',
                ExternalID__c = 'VQL01',
                Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
                Activity_Domain__c = AD_GEC.id,
                Mandataire__c = mand1.id,
                City__c = 'VFCQLI01 City 2',
                Postal_Code__c = '09876'
            );
            insert ptl1;
            
            // Actions Commerciales
            Action_Commerciale__c acmIdeo = new Action_Commerciale__c(
                Cible_Not_Needed__c = true,
                Contract_Duration__c = '5',
                DPE_Not_Needed__c = true,
                End_Date__c = Date.today() + 15,
                Libelle__c = 'ACTEST1',
                Locked_Price__c = true,
                Offered_Months__c = 3,
                Opportunity_Reason_Not_Needed__c = true,
                Project_Type__c = 'CREA',
                RCE__c = 10,
                Start_Date__c = Date.today() - 15,
                T_Pack__c = 'IDEO',
                Tank_Property__c = 'Butagaz Owned Tank',
                Tank_Type__c = 'A',
                Locked_Price_2_Years__c = true,
                Fixed_Price__c = true
            );
            insert acmIdeo;
            system.debug('acmIdeo.Locked_Price_2_Years__c:'+acmIdeo.Locked_Price_2_Years__c);
            system.debug('acmIdeo.Fixed_Price__c:'+acmIdeo.Fixed_Price__c);
            
            // Add an opportunity and opptyPTL
            Opportunity opp1 = new Opportunity(Name = 'TestOpty', 
                StageName='Open', 
                AccountId = a.Id, 
                CloseDate = Date.today(), 
                Project_City_Postal_Code__c = cityCP.Id, 
                DO_City_Postal_Code__c = cityCP.Id, 
                Assign__c=false, OwnerId = u.id,
                DO_Payment_method__c = 'V', 
                Pricebook2Id = pbk1.id,
                //Installation_date__c = Date.today() + 15,
                Existing_PTL__c = ptl1.id,
                Opportunity_Reason__c = 'Modif de stockage – enfoui vers enfoui',
                Project_Type__c = 'FIDE',
                Project_market_type__c = 'PRO',
                Project_market_subtype__c = 'Domestique'
                );
            insert opp1;
            system.debug('opp1.Opportunity_Reason__c:'+opp1.Opportunity_Reason__c);
                
            Code_NAF__c codeNAF1 = new Code_NAF__c(
            	Name = 'CodeNAF1',
            	ExternalID__c = '01A'
            );
            insert codeNAF1;
            
            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = opp1.Id, 
                PTL_Name__c = 'VFCQLI01',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = cityCP.Id,
                PTL_Code_NACE__c = codeNAF1.Id,
                Code_AC_administrator_New__c = attCom.Id,
                Code_marche__c = 'P100'
            );
            insert optyPTL1;
            
            // Quote & Line items
            Quote q11 = new Quote(OpportunityId = opp1.Id, Name='VFCQLI01City Quote', 
                DO_Payment_method__c = 'V',
                Payment_spread__c = 'Z000',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id,
                ExpirationDate = Date.today() + 10,
                Date_de_cotation__c = Date.today(),
                Date_debut_offre__c = Date.today(),
                Action_Commerciale__c = acmIdeo.Id,
                Call_SAP_Display_Mode_Done__c = true
                );
            insert q11;
            Quote q1 = [select Id,Action_Commerciale__c, OpportunityId,Opportunity.Project_Type__c,Opportunity.Opportunity_Reason__c,
                        Action_Commerciale__r.Fixed_Price__c, F_Activity_Domain_ExternalID__c, Market_type__c,
                        ExpirationDate, Date_de_cotation__c,Opportunity.Installation_date__c,Date_debut_offre__c,
                        Date_fin_offre__c, Opportunity.Existing_PTL__c, Opportunity.Project_market_subtype__c from Quote where Id= :q11.Id];
            system.debug('q1.Id:'+q1.Id);

            system.debug('q1.Action_Commerciale__c:'+q1.Action_Commerciale__c);
            system.debug('q1.OpportunityId:'+q1.OpportunityId);
             
            system.debug('q1.Opportunity.Project_Type__c:'+q1.Opportunity.Project_Type__c);
            system.debug('q1.Opportunity.Opportunity_Reason__c:'+q1.Opportunity.Opportunity_Reason__c);
            system.debug('q1.Action_Commerciale__r.Fixed_Price__c:'+q1.Action_Commerciale__r.Fixed_Price__c);
            
            List<Quote_PTL__c> qptlList = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :q1.Id];
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>{
                new QuoteLineItem(
                    QuoteId = q1.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = qptlList[0].Id,
                    Deconsignation__c = false,
                    Commercial_Rebate_TTC__c = 0.1,
                    Consignation_Grpt_one_shot_HT__c = 0.1,
                    Cyclical_Rebate_TTC__c = 0.1,
                    Cyclical_Rebate_Months__c = 3,
                    Group_Commercial_Rebate_TTC__c = 0.1,
                    Group_Cyclical_Rebate_TTC__c = 0.1,
                    Group_RCE_Rebate_HT__c = 0.1,
                    RCE_Rebate_TTC__c = 0.1,
                    Remise_Exceptional_for_Tank_CN_AB__c = 0.1,
                    Remise_Grpt_one_shot_HT__c = 0.1,
                    Discount = 1.0,
                    Mis_Disposition__c = 'Customer Owned Tank'
                ),
                new QuoteLineItem( 
                    QuoteId = q1.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[1].Id, 
                    Quote_PTL__c = qptlList[0].Id,
                    Commercial_Rebate_TTC__c = 0.1,
                    Consignation_Grpt_one_shot_HT__c = 0.1,
                    Cyclical_Rebate_TTC__c = 0.1,
                    Cyclical_Rebate_Months__c = 3,
                    Group_Commercial_Rebate_TTC__c = 0.1,
                    Group_Cyclical_Rebate_TTC__c = 0.1,
                    Group_RCE_Rebate_HT__c = 0.1,
                    RCE_Rebate_TTC__c = 0.1,
                    Remise_Exceptional_for_Tank_CN_AB__c = 0.1,
                    Remise_Grpt_one_shot_HT__c = 0.1,
                    Discount = 1.0,
                    Mis_Disposition__c = 'Customer Owned Tank'
                ),
                new QuoteLineItem(//FLA 37 Case
                    QuoteId = q1.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[2].Id, 
                    Quote_PTL__c = qptlList[0].Id,
                    Deconsignation__c = false,
                    Commercial_Rebate_TTC__c = 0.1,
                    Consignation_Grpt_one_shot_HT__c = 0.1,
                    Cyclical_Rebate_TTC__c = 0.1,
                    Cyclical_Rebate_Months__c = 3,
                    Group_Commercial_Rebate_TTC__c = 0.1,
                    Group_Cyclical_Rebate_TTC__c = 0.1,
                    Group_RCE_Rebate_HT__c = 0.1,
                    RCE_Rebate_TTC__c = 0.1,
                    Remise_Exceptional_for_Tank_CN_AB__c = 0.1,
                    Remise_Grpt_one_shot_HT__c = 0.1,
                    Discount = 1.0
                 ),
                new QuoteLineItem(//FLA 37 Case
                    QuoteId = q1.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[3].Id, 
                    Quote_PTL__c = qptlList[0].Id,
                    Deconsignation__c = false,
                    Commercial_Rebate_TTC__c = 0.1,
                    Consignation_Grpt_one_shot_HT__c = 0.1,
                    Cyclical_Rebate_TTC__c = 0.1,
                    Cyclical_Rebate_Months__c = 3,
                    Group_Commercial_Rebate_TTC__c = 0.1,
                    Group_Cyclical_Rebate_TTC__c = 0.1,
                    Group_RCE_Rebate_HT__c = 0.1,
                    RCE_Rebate_TTC__c = 0.1,
                    Remise_Exceptional_for_Tank_CN_AB__c = 0.1,
                    Remise_Grpt_one_shot_HT__c = 0.1,
                    Discount = 1.0
                 ),
                new QuoteLineItem(//FLA 37 Case
                    QuoteId = q1.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[4].Id, 
                    Quote_PTL__c = qptlList[0].Id,
                    Deconsignation__c = false,
                    Commercial_Rebate_TTC__c = 0.1,
                    Consignation_Grpt_one_shot_HT__c = 0.1,
                    Cyclical_Rebate_TTC__c = 0.1,
                    Cyclical_Rebate_Months__c = 3,
                    Group_Commercial_Rebate_TTC__c = 0.1,
                    Group_Cyclical_Rebate_TTC__c = 0.1,
                    Group_RCE_Rebate_HT__c = 0.1,
                    RCE_Rebate_TTC__c = 0.1,
                    Remise_Exceptional_for_Tank_CN_AB__c = 0.1,
                    Remise_Grpt_one_shot_HT__c = 0.1,
                    Discount = 1.0
                 )
            };
            insert qliList;
            list<quotelineitem> lquotelineitem = [select Id, Product_Family__c, Deconsignation__c, PricebookEntry.Product2.name,
                                                  PricebookEntry.Product2.UseConsumerTarget__c, PricebookEntry.Product2.ProductCode  from quotelineitem 
                                                  where QuoteId = :q1.Id];      
    
            system.debug('lquotelineitem:'+lquotelineitem);
            for(quotelineitem qli:lquotelineitem){
                system.debug('freddy qli:'+qli);
                system.debug('freddy qli product :'+qli.PricebookEntry.Product2.ProductCode);
            
            }
            
            Test.startTest();
            
            ApexPages.currentPage().getParameters().put('id',q1.id);
            ApexPages.StandardController sc = new ApexPages.standardController(q1);
            VFC_Quotelineitem_01 vqli01 = new VFC_Quotelineitem_01(sc);
            
            // Methods
            String s = vqli01.getDateFinOffre(); 
            Decimal d = vqli01.getPriceListTTC();

			Boolean b = vqli01.getCommercialRebateMessage();

			Decimal d1 = vqli01.getRebateRconj();

			Decimal d2 = vqli01.getOfferedMonths();

			map<String,Decimal> mapSD = vqli01.getMapQPTLNameTotalRCEHTAmount();

            String returnValue = vqli01.getPrettyDate();
            system.assertEquals(Date.today().format(), returnValue);
            returnValue = vqli01.getPrettyExpirationDate();
            system.assertEquals((Date.today()+10).format(), returnValue);
            returnValue = vqli01.getPrettyCotationDate();
            system.assertEquals(Date.today().format(), returnValue);
            returnValue = vqli01.getPrettyInstallationDate();
            system.assertEquals('', returnValue);
            returnValue = vqli01.getDateAddMonth();
            system.assertEquals(Date.today().addMonths(2).format(), returnValue);
            returnValue = vqli01.getDateDebutOffre();
            system.assertEquals(Date.today().format(), returnValue);
            //returnValue = vqli01.getDateFinOffre();
            //system.assertEquals('', returnValue);
            
            List<QuoteLineItem> qliCList = vqli01.getExistingCiterne();
            system.assertEquals(0, qliCList.size());
            List<QuoteLineItem> qliRList = vqli01.getRedevence();
            system.assertEquals(4, qliRList.size());
            List<QuoteLineItem> qliOEList = vqli01.getOtherEquipment();
            system.assertEquals(0, qliOEList.size());
            List<QuoteLineItem> qliGERList = vqli01.getTarificationLinesForGerProprietaire();
            system.assertEquals(5, qliGERList.size());
            List<QuoteLineItem> qliPList = vqli01.getProduits();
            system.assertEquals(0, qliPList.size());
            
            List<Quote_PTL__c> qptlAList = vqli01.getQUOTEPTLS();
            system.assertEquals(1, qptlAList.size());
            
            List<QuoteLineItem> qli2List = vqli01.getQuoteLineItems2();
            system.assertEquals(0, qli2List.size());
            
            qliCList = vqli01.getExistingCiterne2();
            system.assertEquals(0, qliCList.size());
            List<QuoteLineItem> qliS2List = vqli01.getService2();
            system.assertEquals(0, qliS2List.size());
            qliRList = vqli01.getRedevence2();
            system.assertEquals(0, qliRList.size());
            qliPList = vqli01.getProduits2();
            system.assertEquals(1, qliPList.size());
            
            List<Equipement__c> equList = vqli01.getPTLEQUIPEMENTS();
            system.assertEquals(0, equList.size());
            
            Quote_PTL__c qptlR = vqli01.getQuotePTLFromOptyExistingPTL();
            system.assertEquals(null, qptlR);
            
            
            Decimal tppb = vqli01.getTotalPriceProductsBaremeHT();
            system.assertEquals(0.0, tppb);
            
            Opportunity opp = [select Id,Project_market_type__c from Opportunity where Id= :opp1.Id];
            if(opp != null)
            {
                opp.Project_market_type__c = 'DOM';
				update opp;                
	            Quote q2 = [select Id,Action_Commerciale__c, OpportunityId,Opportunity.Project_Type__c,Opportunity.Opportunity_Reason__c,
                        Action_Commerciale__r.Fixed_Price__c, F_Activity_Domain_ExternalID__c, Market_type__c,
                        ExpirationDate, Date_de_cotation__c,Opportunity.Installation_date__c,Date_debut_offre__c,
                        Date_fin_offre__c, Opportunity.Existing_PTL__c, Opportunity.Project_market_subtype__c, Opportunity.T_Pack__c from Quote where Id= :q11.Id];

                ApexPages.currentPage().getParameters().put('id',q2.id);
                ApexPages.StandardController sc1 = new ApexPages.standardController(q2);
                VFC_Quotelineitem_01 vqli011 = new VFC_Quotelineitem_01(sc1);

            }
            
            Test.stopTest();
            System.Debug('### >>>>> testing class VFC_Quotelineitem_01 END <<<<<');
            
        }   
    }
 
}