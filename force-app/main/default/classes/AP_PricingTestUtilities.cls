@isTest(seeAllData=true)
public class AP_PricingTestUtilities{
    
    public static String USER_PROFILE = 'Butagaz Sales Standard User';

    public Canton__c oCanton;
    public City__c   oCity;
    public City_Postal_Code__c oPostalCode;
    
    public AP_PricingTestUtilities(){
        this.oCanton = new Canton__c(INSEE_Code__c = '123');
        insert this.oCanton;
        this.oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
        insert this.oCity;
        this.oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', City__c = oCity.Id, Code_Type__c = 'M');
        insert this.oPostalCode;
    }

    public User getUser(){
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :AP_PricingTestUtilities.USER_PROFILE];
        String uname = 'Pricing-'  + String.valueOf(Crypto.getRandomInteger()) + '@test.fr'; // Get Random name
        User user = new User();
        user.username  = uname;
        user.email     = uname;
        user.firstName = 'F';
        user.lastName  = 'L';
        user.alias     = 'LF';
        user.IsActive  = true;
        user.communityNickname = 'LF';
        user.timeZoneSidKey = 'Europe/Paris';
        user.localeSidKey = 'fr_FR_EURO';
        user.languageLocaleKey = 'fr';
        user.emailEncodingKey = 'ISO-8859-1';
        user.profileId = p.Id;
        //user.mandataire__c = 'ABC';
        // Gestion multi-plaques
        user.User_Mandataires__c = 'ABC';

        System.runAs(new User(Id = UserInfo.getUserId())){ insert user; } // Avoid mixed DML.

        return user;
    }
    
    //Get a Basic Quote
    public Quote getBasicQuote(){
        Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        ad.active__c=true;
        update ad;
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        //Contact oContact = getContact();
        
        //Mandataire
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '859',Active__c = true,MatriculeEnCours__c=3 );
        insert mandataire1;
        //canton
        Canton__c Canton1 = new Canton__c(name = 'APPU Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
        insert Canton1;
        //city
        City__c City1  = new City__c (Name = 'APPU City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        //city CP
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
        City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        
        Account a=Utils.createAccountBA(1,rt.Id);
        a.Activity_Domain__c =ad.Id;
        a.Channel__c = 'CS';
        a.customer_group__c='CD';
        a.accountNumber='12345';
        insert a;
       // oContact.Accountid = a.id;
       // update oContact;
        Contact oContact = new Contact();
        oContact.Accountid = a.id;
        oContact.LastName = 'L';
        oContact.Contact_Marketing__c  = true;
        oContact.Email='toto@tata.com';
        oContact.Country__c = 'FR';
        oContact.Phone = '0202020202';
        
        insert oContact;
            
        Opportunity oOpty = getOpportunity();
        oOpty.Project_Type__c='AAA';
        oOpty.AccountId=a.id;
        oOpty.DO_Activity_Domain__c=ad.Id;
        oOpty.DO_AccountNumber__c='12345';
        oOpty.Project_City_Postal_Code__c=cityCP.id;
        insert oOpty;

        Quote initialQuote = getQuote(oOpty);
        initialQuote.Contactid = oContact.id;
        initialQuote.Scale__c='F';
        initialQuote.Ger_Consumption__c='B4';
        initialQuote.VAT_code__c='1';
        initialQuote.Payment_Spread__c = 'Z000';
        initialQuote.DO_Payment_method__c= 'P';        
        initialQuote.Contract_Duration__c ='4';
        initialQuote.Product_Scale__c = 'CART1';
        insert initialQuote;

        return initialQuote;
    }
    
    //Get a Quote with Some Opty_PTL, Quote_PTL, Pricebook2, Product2, PricebookEntry, QuoteLineItem
    public Quote getFullQuote(){
        Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 limit 1];
        ad.active__c=true;
        update ad;
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
       // Contact oContact = getContact();
        
        //Mandataire
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '598',Active__c = true,MatriculeEnCours__c=3 );
        insert mandataire1;
        //canton
        Canton__c Canton1 = new Canton__c(name = 'APPU Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
        insert Canton1;
        //city
        City__c City1  = new City__c (Name = 'APPU City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        //city CP
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
        City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;     
        
        
        Account a=Utils.createAccountBA(1,rt.Id);
        a.Activity_Domain__c =ad.Id;
        a.customer_group__c='CD';
        a.accountNumber='12345';
        a.Channel__c= 'CS';
        insert a;
        // oContact.Accountid = a.id;
       // update oContact;
        Contact oContact = new Contact();
        oContact.Accountid = a.id;
        oContact.LastName = 'L';
        oContact.Contact_Marketing__c  = true;
        oContact.Email='toto@tata.com';
        oContact.Country__c = 'FR';
        oContact.Phone = '0202020202';
        
        insert oContact;

        
        Opportunity oOpty = getOpportunity();
        oOpty.Project_Type__c='AAA';
        oOpty.AccountId=a.id;
        oOpty.DO_Activity_Domain__c=ad.Id;
        oOpty.DO_AccountNumber__c='12345';
        oOpty.DO_Customer_Group__c='CS Consommateur';
        oOpty.Client_Type__c = 'CS';
        oOpty.Project_City_Postal_Code__c=cityCP.id;
        insert oOpty;
        
        // Add an Opty PTL
        PTL__c ptl1 = new PTL__c(
            City_Postal_Code__c = oPostalCode.Id,
            Name = 'PTLCODE1',
            Propane_13__c = true
        );
        insert ptl1;
                
        Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
            Opportunity__c = oOpty.id,
            PTL_Name__c = 'PTLCODE1',
            PTL__c = ptl1.Id,
            PTL__r = ptl1   
        );
        insert optyPTL1;
        
        
        PTL__c ptl2 = new PTL__c(
            City_Postal_Code__c = oPostalCode.Id,
            Name = 'PTLCODE2',
            Propane_13__c = true
        );
        insert ptl2;
        
        
        Opportunity_PTL__c optyPTL2 = getOpportunityPTL(oOpty);
        optyPTL2.PTL_Name__c = 'PTLCODE2';
        optyPTL2.PTL__c = ptl2.Id;
        optyPTL1.PTL__r = ptl2;
        insert optyPTL2; 
        
        Quote initialQuote = getQuote(oOpty);
        initialQuote.Contactid = oContact.id;
        initialQuote.Scale__c='F';
        initialQuote.Ger_Consumption__c='B4';
        initialQuote.VAT_code__c='1';
        initialQuote.Payment_Spread__c = 'Z000';
        initialQuote.DO_Payment_method__c= 'P';
        initialQuote.Contract_Duration__c ='4';
        initialQuote.Product_Scale__c = 'CART1';
        insert initialQuote;
        
        Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
        Quote_PTL__c oQPTL2 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];
        
        update oQPTL1;
        update oQPTL2;
        
        // Add some QLI!
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        initialQuote.Pricebook2Id = pb.Id;
        update initialQuote;
        
        Product2 oProduct1 = new Product2(Name='TESTMATCODE1', ProductCode = 'TESTMATCODE1', Family='Equipement', Sub_Type__c='Citerne', IsActive=true); 
        Product2 oProduct2 = new Product2(Name='TESTMATCODE2', ProductCode = 'TESTMATCODE2', Family='Equiepement', Sub_Type__c='Citerne', IsActive=true); 
        insert new List<Product2> {oProduct1, oProduct2};
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = oProduct1.Id, IsActive = true,  UnitPrice = 1); 
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = oProduct2.Id, IsActive = true,  UnitPrice = 1); 
        insert new List<PricebookEntry> {pbe1, pbe2};
        
        //update pb;
        
        List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
            new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe1.Id, Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Tank sold By BTZ'),
            new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe2.Id, Quote_PTL__c = oQPTL2.Id, Mis_Disposition__c = 'Tank sold By BTZ')
        };
 
        insert lQLI; 
        
        /**for(QuoteLineItem QLI : lQLI){
            QLI.PricebookEntry = [SELECT Id, Product2.Family, Product2.Sub_Type__c FROM PricebookEntry WHERE Id = :QLI.PricebookEntryId];
        }
        update lQLI;**/
        
        lQLI[0].PricebookEntry = [SELECT Id, Product2.Family, Product2.Sub_Type__c FROM PricebookEntry WHERE Id = :pbe1.Id];
        lQLI[1].PricebookEntry = [SELECT Id, Product2.Family, Product2.Sub_Type__c FROM PricebookEntry WHERE Id = :pbe2.Id];
        
        return initialQuote;
    }
    
    
    public Opportunity getOpportunity(){
        City_Postal_Code__c oPostalCode =  this.oPostalCode;       
        Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
        insert oDomain;
        Opportunity oOpty = new Opportunity(
            name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', 
            DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oPostalCode.Id, 
            Project_City_Postal_Code__c = oPostalCode.Id, DO_Activity_Domain__c = oDomain.Id
        );
        return oOpty;
    }

    public Opportunity_PTL__c getOpportunityPTL(Opportunity oOpty){
        City_Postal_Code__c oPostalCode =  this.oPostalCode;         
        Opportunity_PTL__c oOptyPTL = new Opportunity_PTL__c(
            Opportunity__c = oOpty.Id, 
            PTL_Name__c = '123',
            PTL_Street_Type__c = '456',
            PTL_Street_Name__c = '789',
            PTL_City_Postal_Code__c = oPostalCode.Id
        );
        return oOptyPTL;
    }
    
    public Quote getQuote(Opportunity oOpty){
        Quote oQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
        return oQuote;
    }
    
    public Contact getContact(){
        Contact oContact = new Contact();
       // oContact.Accountid = a.id;
        oContact.LastName = 'L';
        oContact.Contact_Marketing__c  = true;
        oContact.Email='toto@tata.com';
        oContact.Country__c = 'FR';
        oContact.Phone = '0202020202';
        
        insert oContact;
        return oContact;
    }
}