@isTest
private class VFC_SyncQuote_TEST2 {

    public static testmethod void testQuoteSync() {
        
        System.Debug('### >>>>> testing class VFC_SyncQuote_TEST.testQuoteSync <<<<<');
   
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCSQ1',Alias='VFCSQ1',
            Email='VFCSQ1@shell.com',Username='VFCSQ1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        
        
        System.runAs(u) {
        
            //Mandataire
              Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
              insert mandataire1;
            
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123',Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            Opportunity oOpty = new Opportunity(
                name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id
            );
            insert oOpty;
            
            // ORO - Test update - Add Line Items
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
            pbeList = [select id, UnitPrice, Product2.id, Pricebook2Id from PricebookEntry where Pricebook2Id =: pbk1.id];
            
            // Quote
            Quote initialQuote = new Quote(
                T_LAT_ApprovalRequested__c=true,
                OpportunityId = oOpty.Id, 
                Name='C',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c = 'C',
                Contract_Duration__c = '5',
                Pricebook2Id = pbk1.id
            );
            insert initialQuote;
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>{
                new QuoteLineItem(
                    QuoteId = initialQuote.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[0].Id
                ),
                new QuoteLineItem( 
                    QuoteId = initialQuote.Id, 
                    Quantity = 1, 
                    UnitPrice = 1, 
                    PricebookEntryId = pbeList[1].Id
                )
            };
            insert qliList;
            
            // Check that we have one quote
            List<Quote> lQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :oOpty.Id];
            System.assertEquals(1, lQuotes.size());
            
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(initialQuote);
            VFC_SyncQuote  controller = new VFC_SyncQuote(stdController);
            controller.launchSyncQuote();
            PageReference pf=controller.back();
        
            initialQuote.T_LAT_ApprovalRequested__c=false;
            update initialQuote;
            stdController = new ApexPages.StandardController(initialQuote);
            controller = new VFC_SyncQuote(stdController);
            controller.launchSyncQuote();
            Test.stopTest();

            // Test that we did clone
            oOpty =[select SyncedQuoteId from Opportunity where id =:oOpty.Id];
            System.assertEquals(oOpty.SyncedQuoteId  , initialQuote.Id);
            
        }
        System.Debug('### >>>>> testing class VFC_SyncQuote_TEST.testQuoteSync END<<<<<');    
    }
}