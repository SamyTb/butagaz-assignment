@isTest(seeAllData=true)
public class VFC06_SelectPriceBook_TEST{
    
    public List<PriceBook2> listPriceBook;
    public Id pricebook2Id;
    
    public static testmethod void testAssignPriceBookToQuoteFAIL(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP1',Alias='VFC6SP1',
            Email='VFC6SP1@shell.com',Username='VFC6SP1@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '123',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
            
            Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;
            
             

                       
            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1'
            );
            insert currentQuote;
            
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?id=' + quoteID);

            Test.startTest();
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton();   
            
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            
            selectPriceBookController.assignPriceBookToQuote();
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.backToQuote();
            selectPriceBookController.goToCallingPage();
            
    
            System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.WARNING));
            Test.stopTest();
        }
    }
    
    public static testmethod void testAssignPriceBookToQuoteSUCCESS(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP2',Alias='VFC6SP2',
            Email='VFC6SP2@shell.com',Username='VFC6SP2@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '234',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
            
            Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;

            
            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1'
            );
            insert currentQuote;
            
            RecordType rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType='Quote' and DeveloperName like '%GEC_PRO%'  LIMIT 1]; //Pick up a RecordType
            currentQuote.RecordTypeId = rt2.Id;
        
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?parentPageURL=/apex/VFP06_ProductSelector_Step1?id='+ quoteID +'&id=' + quoteID);

            Test.startTest();
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton();  
            
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            
            selectPriceBookController.assignPriceBookToQuote();
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.backToQuote();
            selectPriceBookController.goToCallingPage();
            //System.assertEquals(true, selectPriceBookController.priceBookChoosed);
            Test.stopTest();            
        }
        
    }
    
    
     public static testmethod void testAssignPriceBookToQuoteDIFFERENT(){
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP3',Alias='VFC6SP3',
            Email='VFC6SP3@shell.com',Username='VFC6SP3@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '456',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
           
           Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;

      
            
            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            RecordType rt2 = [SELECT Id, Name FROM RecordType WHERE SobjectType='Quote' and DeveloperName like '%GEC_PRO%' LIMIT 1]; //Pick up a RecordType
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1',
                RecordTypeId = rt2.Id
            );
            insert currentQuote;

            Id pricebookTarget = null;
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?parentPageURL=/apex/VFP06_ProductSelector_Step1?id='+ quoteID +'&id=' + quoteID);

            Test.startTest();
            
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton();  
            
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            
            selectPriceBookController.assignPriceBookToQuote();
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.backToQuote();
            selectPriceBookController.goToCallingPage();
            //System.assertEquals(true, selectPriceBookController.priceBookChoosed);
            
            Test.stopTest();
        }       
    }
    
    
    
    
    public static testmethod void testGetAvailablePriceBooks(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP4',Alias='VFC6SP4',
            Email='VFC6SP4@shell.com',Username='VFC6SP4@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '789',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
           
           
           Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;
            
            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1'
            );
            insert currentQuote;
            
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?id=' + quoteID);

            Test.startTest();
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton(); 
             
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            
            List<SelectOption> listPricebooks = selectPriceBookController.getAvailablePriceBooks();
            
            System.assertEquals(false, listPricebooks.isEmpty());
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.backToQuote();
            selectPriceBookController.goToCallingPage();
               
        }
        Test.stopTest();
    }
    
    public static testmethod void testUpdatePriceBookFAIL(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP5',Alias='VFC6SP5',
            Email='VFC6SP5@shell.com',Username='VFC6SP5@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '963',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
            
            Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;

            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1'
            );
            insert currentQuote;
            
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?id=' + quoteID);

            Test.startTest();
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton();  
            
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            
            selectPriceBookController.updatePriceBook();
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.backToQuote();
            selectPriceBookController.goToCallingPage();
      
            
            System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR));
        }
        Test.stopTest();
    }
    
    public static testmethod void testUpdatePriceBookSUCCESS(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFC6SP6',Alias='VFC6SP6',
            Email='VFC6SP6@shell.com',Username='VFC6SP6@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '147',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
           // Contact oContact = new Contact();
           // oContact.LastName = 'L';
           // insert oContact;
        
            Account a= new Account(
                Prescriber__c=false,
                Name = 'TestAccount1',
                RecordTypeId=rt.id, 
                Postal_Code__c = '123', 
                City__c = 'Somewhere' , 
                Email__c = 'acc1@test.com',
                Activity_Domain__c =ad.Id,
                Channel__c = 'CS',
                customer_group__c='CD',
                accountNumber='12345',
                Country__c='FR', 
                Phone='0202020202'
            );
            insert a;
           
           Contact oContact = new Contact();
            oContact.LastName = 'L';
            oContact.Accountid = a.id;
            oContact.Contact_Marketing__c  = true;
            oContact.Email = a.Email__c;
            oContact.Country__c = a.Country__c;
            oContact.Phone = a.Phone;
            insert oContact;
            
            Canton__c oCanton = new Canton__c(INSEE_Code__c = '123', Mandataire__c=mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                AccountId=a.id,
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='AAA',
                DO_AccountNumber__c='12345'
            );
            insert oOpty;
            
            Quote currentQuote = new Quote(
                OpportunityId = oOpty.Id, 
                Name='C',
                Contactid = oContact.id,
                Scale__c='F',
                Ger_Consumption__c='B4',
                VAT_code__c='1',
                Payment_Spread__c = 'Z000',
                DO_Payment_method__c= 'P',
                Contract_Duration__c ='4',
                Product_Scale__c = 'CART1'
            );
            insert currentQuote;
            Id quoteID = currentQuote.Id;
            PageReference p = new PageReference('/apex/VFP06_SelectPriceBook?id=' + quoteID);

            Test.startTest();
            Test.setCurrentPage(p);
            ApexPages.StandardController std = new ApexPages.StandardController(currentQuote);
            VFC06_SelectPriceBook selectPriceBookController = new VFC06_SelectPriceBook(std);
            boolean RenderSuivantButton=  selectPriceBookController.getRenderSuivantButton();  
            
            System.assertEquals(false, selectPriceBookController.priceBookChoosed);
            List<SelectOption> listPricebooks = selectPriceBookController.getAvailablePriceBooks();
            System.assertEquals(false, listPricebooks.isEmpty());
            Id pricebookId = listPricebooks.get(0).getValue();
            currentQuote.priceBook2Id = pricebookId;
            
            selectPriceBookController.updatePriceBook();
         
            
            selectPriceBookController.autoAssignPricebook();
            selectPriceBookController.goToCallingPage();
            
             
            System.assertEquals(true, selectPriceBookController.priceBookChoosed);
            Test.stopTest();            
        }
        
    }
}