//@isTest(seeAllData=true)
@isTest
public class VFC06_Quote_InitQuoteLineItems_TEST {
    
    @Testsetup
    public static void init(){
         String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Sales Administrator (RAV)%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APQL1',Alias='APQL1',
            Email='APQL1@shell.com',Username='APQL1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

         Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEB - Gaz en bouteille', ExternalID__c=41);
            insert AD_GEC; 
        Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (id=pb2StandardId, isActive=true);
            update pbk1;
          // Custom settings
            Custom_Settings__c c1 = new Custom_Settings__c(name='TrackBAPICalls', value__c = 'true');
            Custom_Settings__c c2 = new Custom_Settings__c (name='Pricing_EndPointURL',value__c = 'http://www.google.fr'); 
            Custom_Settings__c c3 = new Custom_Settings__c (name='Pricing_Username',value__c = 'username'); 
            Custom_Settings__c c4 = new Custom_Settings__c (name='Pricing_Password',value__c = 'password');
            Custom_Settings__c c5 = new Custom_Settings__c (name='AutoAdd_Allowed',value__c = 'S000000132'); 
            Custom_Settings__c c6 = new Custom_Settings__c (name='ACOfferedMonthsApplies',value__c = 'SPPABO0010;SPPABO0008'); 
            Custom_Settings__c c7 = new Custom_Settings__c (name='AC_Prevent_Duplication_on_Articles',value__c = 'S000000132');
            Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            Custom_Settings__c c9 = new Custom_Settings__c (name='GER_Accessories_Metropole_VAT',value__c = '20');
            Custom_Settings__c c10 = new Custom_Settings__c (name='GER_Accessories_Corsica_VAT',value__c = '13');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Tank_TVA_Sold_By_BTZ',value__c = '10');
        	Custom_Settings__c c12 = new Custom_Settings__c (name ='Espace_Client_AES_Iv',  value__c ='B8C90EBAD5941EA2BB0EFC');
        	Custom_Settings__c c13 = new Custom_Settings__c ( name ='Espace_Client_AES_Key', Value__c = 's4abEHNGXpOKCQkFmU6y+vSMZFPCa67FzjRrF7zA3Bc=');
        	Custom_Settings__c c14 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEB', Value__c = 'http://uat.client-bouteilles-pro.butagaz.fr/oneclickregistration/?code=');
        	Custom_Settings__c c15 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEC', Value__c = 'http://uat.espace-client.butagaz.fr/oneclickregistration/?code=');
        	Custom_Settings__c c16 = new Custom_Settings__c (name ='Espace_Client_Satisfaction_URL_GEB', Value__c = 'http://uat-client-bouteilles-pro.butagaz.fr/survey/answer?code=');
         	Custom_Settings__c c17 = new Custom_Settings__c ( name ='Espace_Client_Satisfaction_URL_GEC', Value__c = 'http://uat-espace-client.butagaz.fr/survey/answer?code=');
        
            //insert c1; insert c2;  insert c3;  insert c4; insert c5; insert c6; insert c7;
            insert new List<Custom_Settings__c> { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11,c12,c13,c14,c15,c16,c17 };
        
            List<RecordTypes_OpportunityToQuote__c> rtList = new List<RecordTypes_OpportunityToQuote__c>();
            RecordTypes_OpportunityToQuote__c rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D000000038Q7',
                OpportunityRecordType__c = '012D000000038Q2',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB CONS',
                QuotePTLRecordType__c = '012D0000000374o'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374l',
                OpportunityRecordType__c = '012D0000000374Z',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GER Usager',
                QuotePTLRecordType__c ='012D0000000374u'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374k',
                OpportunityRecordType__c = '012D0000000374Y',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GER Proprietaire',
                QuotePTLRecordType__c ='012D0000000374t'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocU',
                OpportunityRecordType__c = '012e00000008ocA',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM IDEO',
                QuotePTLRecordType__c ='012e00000008oco'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocZ',
                OpportunityRecordType__c = '012e00000008ocF',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM SOLO',
                QuotePTLRecordType__c ='012e00000008ocu'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008ocP',
                OpportunityRecordType__c = '012e00000008ocK',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM ECOCFT',
                QuotePTLRecordType__c ='012e00000008oct'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374i',
                OpportunityRecordType__c = '012D0000000374W',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC LOCATAIRE',
                QuotePTLRecordType__c ='012D0000000374r'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374g',
                OpportunityRecordType__c = '012D0000000374U',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM',
                QuotePTLRecordType__c ='012D0000000374p'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374j',
                OpportunityRecordType__c = '012D0000000374X',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC PRO',
                QuotePTLRecordType__c ='012D0000000374s'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374n',
                OpportunityRecordType__c = '012D0000000374b',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GrosVrac',
                QuotePTLRecordType__c ='012D0000000374w'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374m',
                OpportunityRecordType__c = '012D0000000374a',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GPLc',
                QuotePTLRecordType__c ='012D0000000374v'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D000000038P4',
                OpportunityRecordType__c = '012D000000038Oz',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D000000038Q4',
                name = 'GEB RE',
                QuotePTLRecordType__c ='012D0000000374o'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012D0000000374h',
                OpportunityRecordType__c = '012D0000000374V',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC energigaz',
                QuotePTLRecordType__c ='012D0000000374q'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008r20',
                OpportunityRecordType__c = '012e00000008r1q',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM LOC IDEO SOLO',
                QuotePTLRecordType__c ='012e00000008r25'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0129E000000Cqyx',
                OpportunityRecordType__c = '0129E000000Cjzm',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC PRO COLL',
                QuotePTLRecordType__c ='012e00000008r25'
            );
            rtList.add(rtotq);
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '0121l0000001Aho',
                OpportunityRecordType__c = '0121l0000001Ahn',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM OPTIMO',
                QuotePTLRecordType__c ='012D00000003Epj'
            );
            rtList.add(rtotq);
            
            rtotq = new RecordTypes_OpportunityToQuote__c(
                QuoteRecordType__c = '012e00000008r20',
                OpportunityRecordType__c = '012e00000008r1q',
                QuotePriceBookId__c = pbk1.id,
                OptyPTLRecordTypeId__c = '012D0000000374d',
                name = 'GEC DOM LOC OPTIMO',
                QuotePTLRecordType__c ='012e00000008r25'
            );
            rtList.add(rtotq);
            insert rtList;
    }
    
    public static testmethod void testInitQuoteLineItemsRedirectToSelectPriceBook(){
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote currentQuote = ap.getBasicQuote();

        Id quoteID = currentQuote.Id;
        PageReference p = new PageReference('/apex/VFP06_Quote_InitQuoteLineItems?id=' + quoteID);

        Test.startTest();
        System.runAs(ap.getUser()){
            Test.setCurrentPage(p);

            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_Quote_InitQuoteLineItems initQuoteLineItemsController = new VFC06_Quote_InitQuoteLineItems(std);
            
            System.assertEquals(null, initQuoteLineItemsController.getCurrentQuote().Pricebook2Id);
            PageReference redirect = initQuoteLineItemsController.initQuoteLineItems();
            System.assertEquals(null, initQuoteLineItemsController.lastException);
            System.assert(redirect.getUrl().containsIgnoreCase('VFP06_SelectPriceBook'), redirect.getUrl());
        }
        Test.stopTest();
    }
    
    public static testmethod void testInitQuoteLineItemsRedirectToSAPCall(){
      // init();       
        
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
        Quote currentQuote = ap.getFullQuote();
        List<QuoteLineItem> lQLIs = [SELECT Id, PricebookEntryId FROM QuoteLineItem WHERE QuoteId = :currentQuote.Id];
        
        Id quoteID = currentQuote.Id;
        PageReference p = new PageReference('/apex/VFP06_Quote_InitQuoteLineItems?id=' + quoteID);

        Test.startTest();
        System.runAs(ap.getUser()){
            Test.setCurrentPage(p);

            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_Quote_InitQuoteLineItems initQuoteLineItemsController = new VFC06_Quote_InitQuoteLineItems(std);
            
            System.assertNotEquals(null, initQuoteLineItemsController.getCurrentQuote().Pricebook2Id);
            PageReference redirect = initQuoteLineItemsController.initQuoteLineItems(); // will call initExistingQuoteLineItemsFromSAP() method
            
            System.assertEquals(null, initQuoteLineItemsController.lastException);
            System.assertEquals(false, initQuoteLineItemsController.getResponse_x().errorGotFromSAP);
            System.assertEquals(true, initQuoteLineItemsController.getResponse_x().listAPVFMessage.isEmpty(), initQuoteLineItemsController.getResponse_x().listAPVFMessage);
            //After the sap call, we redirect the user to the currentQuote
            System.assert(redirect.getUrl().containsIgnoreCase(''+quoteID), redirect.getUrl());
            
        }
        Test.stopTest();
    }
    
    public static testmethod void testRetryInitQuoteLineItemsRedirectToSAPCall(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='QIQLI2',Alias='QIQLI2',
            Email='QIQLI2@shell.com',Username='QIQLI2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
            
        insert u;

        System.runAs(u) {
            AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
            Quote currentQuote = ap.getFullQuote();

            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_Quote_InitQuoteLineItems?id=' + quoteID);
            
            Test.startTest();
            
            Test.setCurrentPage(p);

            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_Quote_InitQuoteLineItems initQuoteLineItemsController = new VFC06_Quote_InitQuoteLineItems(std);
            
            System.assertNotEquals(null, initQuoteLineItemsController.getCurrentQuote().Pricebook2Id);
            PageReference redirect = initQuoteLineItemsController.retry(); // will call initExistingQuoteLineItemsFromSAP() method
            
            System.assertEquals(null, initQuoteLineItemsController.lastException);
            System.assertEquals(false, initQuoteLineItemsController.getResponse_x().errorGotFromSAP);
            System.assertEquals(true, initQuoteLineItemsController.getResponse_x().listAPVFMessage.isEmpty(), initQuoteLineItemsController.getResponse_x().listAPVFMessage);
            //After the sap call, we redirect the user to the currentQuote
            System.assert(redirect.getUrl().containsIgnoreCase(''+quoteID), redirect.getUrl());
            
            Test.stopTest();
        }
        
    }
    
    public static testmethod void testInitQuoteLineItemsQuoteAlreadyApprovedByLatitude(){
        AP_PricingTestUtilities ap = new AP_PricingTestUtilities();
       // User user_x = ap.getUser();
        User user_x = [SELECT Id FROM User WHERE FirstName LIKE'Test'LIMIT 1];
        
        Quote currentQuote = ap.getFullQuote();
        currentQuote.T_LAT_ApprovalRequested__c = true;
        update currentQuote;
        
        Id quoteID = currentQuote.Id;
        PageReference p = new PageReference('/apex/VFP06_Quote_InitQuoteLineItems?id=' + quoteID);

        Test.startTest();
    //    System.runAs(user_x){
            Test.setCurrentPage(p);

            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_Quote_InitQuoteLineItems initQuoteLineItemsController = new VFC06_Quote_InitQuoteLineItems(std);
            
            System.assertEquals(true, initQuoteLineItemsController.getCurrentQuote().T_LAT_ApprovalRequested__c);
           // System.runAs(new User(Id = UserInfo.getUserId())){
                initQuoteLineItemsController.getCurrentQuote().CreatedBy = user_x;
                update initQuoteLineItemsController.getCurrentQuote();
           // }
         //   System.assertEquals(true, AP_PricingUtilities.isQuoteOwner(initQuoteLineItemsController.getCurrentQuote().CreatedBy.Id));
            PageReference redirect = initQuoteLineItemsController.initQuoteLineItems(); // will call initExistingQuoteLineItemsFromSAP() method
          //  System.assertEquals(currentQuote.CreatedBy.Id, UserInfo.getUserId(), currentQuote.CreatedBy + ' '+ UserInfo.getUserId());
          //  System.assertNotEquals(null, initQuoteLineItemsController.lastException);
          //  System.assert(initQuoteLineItemsController.lastException.getMessages()[0].containsIgnoreCase(System.Label.quote_locked), initQuoteLineItemsController.lastException.getMessages());
              
         currentQuote.Call_SAP_Display_Mode_Done__c = true;
        update currentQuote;
         std = new ApexPages.StandardController(currentQuote);
         initQuoteLineItemsController = new VFC06_Quote_InitQuoteLineItems(std);
         initQuoteLineItemsController.initQuoteLineItems();
        
       // }
        Test.stopTest();
    }
}