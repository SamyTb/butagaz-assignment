@isTest(seeAllData=true)
public class AP_BusinessControls_Test
{
public static testmethod void testAP_BusinessControls(){
    
        System.Debug('### >>>>> testing class testAP_BusinessControls <<<<<');
   
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APBC',Alias='APBC',
            Email='APBC@shell.com',Username='APBC@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        
        
        System.runAs(u) {
        
           //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '333',Active__c = true,MatriculeEnCours__c=4565 );
            insert mandataire1;
            
            
            
            Activity_Domain__c ad = [select id from Activity_Domain__c where externalID__c=41 and active__c=true limit 1];
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
    
    
           
         
            Account a=Utils.createAccountBA(1,rt.Id);
            a.Activity_Domain__c =ad.Id;
            a.channel__c='CD';
            a.accountNumber='679789';
            a.Email__c = 'APBC@test.com';
            a.Country__c='FR';
            a.Phone='0202020202';
            insert a;
            
            //Contact c = new Contact(Lastname='APBC Contact', AccountId = a.id, );
            //insert c;
            
                
            // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
            
            Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123', Mandataire__c = mandataire1.id);
            insert oCanton;
            City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
            insert oCity;
            City_Postal_Code__c oPostalCode = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', 
                City__c = oCity.Id, Code_Type__c = 'M');
            insert oPostalCode;
            
            Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
            insert oDomain;
            
            Opportunity oOpty = new Opportunity(
                name='SomeName', 
                Assign__c=false, 
                StageName='A', 
                CloseDate=Date.today(), 
                DO_Street_Type__c = 'A', 
                DO_Street_Name__c = 'A', 
                DO_City_Postal_Code__c = oPostalCode.Id, 
                Project_City_Postal_Code__c = oPostalCode.Id, 
                DO_Activity_Domain__c = ad.Id,
                Project_Type__c='CREA',
                AccountId=a.id,
                DO_AccountNumber__c='NEWCUST',
                Client_Type__c = 'CD',
                T_Pack__c = ''
            );
            insert oOpty;
            
            Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
			insert attCom50;   

            Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'

            );
            insert optyPTL1;
            
            Opportunity_PTL__c optyPTL2 = new Opportunity_PTL__c(
                Opportunity__c = oOpty.Id, 
                PTL_Name__c = '123',
                PTL_Street_Type__c = '456',
                PTL_Street_Name__c = '789',
                PTL_City_Postal_Code__c = oPostalCode.Id,
                Code_AC_administrator_New__c = attCom50.Id,
				Code_marche__c =  'P100'

            );
            insert optyPTL2;
            
            Quote initialQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
            //ORO 140828 - Test Method update
            initialQuote.DO_Payment_method__c = 'C';
            initialQuote.Payment_spread__c = 'Z010';
            initialQuote.Contract_Duration__c = '5';
            initialQuote.Scale__c='F';
            initialQuote.Ger_Consumption__c='B4';
            initialQuote.VAT_code__c='1';
            initialQuote.Opportunity = oOpty;
            initialQuote.contactId = c.id;
            insert initialQuote;
        
            list<Quote_PTL__c> oQPTL1 = [SELECT Id, Name,Estimated_Capacity__c,Estimated_Consumption__c FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL1.Id];
            list<Quote_PTL__c> oQPTL2 = [SELECT Id, Name,Estimated_Capacity__c,Estimated_Consumption__c FROM Quote_PTL__c WHERE Quote__c = :initialQuote.Id AND Opportunity_PTL__c = :optyPTL2.Id];

            // Add some QLI!
            Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            initialQuote.Pricebook2Id = pb.Id;
     
            update initialQuote;
        
        
        
        
        
            Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true); 
            Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true);
         

        
            insert new List<Product2> {oProduct1, oProduct2};
            PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = oProduct1.Id, IsActive = true, UnitPrice = 1); 
            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = oProduct2.Id, IsActive = true, UnitPrice = 1); 
            insert new List<PricebookEntry> {pbe1, pbe2};
        
            
            List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe1.Id, Quote_PTL__c = oQPTL1[0].Id),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = initialQuote.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe2.Id, Quote_PTL__c = oQPTL2[0].Id)
            }; 
        
            insert lQLI; 
        
            for(QuoteLineItem o:lQLI){
                o.PricebookEntry=[select Id,Product2.Family,Product2.Sub_Type__c from PricebookEntry where id=:o.PricebookEntryId];
            }


        RecordTypes_OpportunityToQuote__c rtopty = new RecordTypes_OpportunityToQuote__c(
            Name='GEC DOM BUTABOX',
            OpportunityRecordType__c='012D0000000374U',
            OptyPTLRecordTypeId__c='012D0000000374p',
            QuotePriceBookId__c='01sD00000007cgO',
            QuotePTLRecordType__c='012D0000000374g',
            QuoteRecordType__c='012D0000000374g');
        insert rtopty;
      
        Custom_Settings__c cs = new Custom_Settings__c(Name='AAA',value__c='AAA');
        insert cs;
        
        Test.startTest();
         
         
        AP_BusinessControls p = new AP_BusinessControls(initialQuote , oQPTL1 );
        p.checkMandatoryOfInputCommonParameters('1');
        p.checkMandatoryFieldsOfInputDeliveryPointParameters(); 
        //    p.checkListErrors();
           
        string RecordTypeValue = AP_BusinessControls.getQuoteRecordTypeValue('GEC DOM BUTABOX');
        string CustomSettingValue = AP_BusinessControls.getCustomSettingValue('AAA');
        string DecimalToString = AP_BusinessControls.convertDecimalToString(1.5);
        p.toDisable('RCE_Rebate', 'Redevance', 'Butabox', 'IDEO');
            
        Test.stopTest();
            
        }
        
        System.Debug('### >>>>> testing class testAP_BusinessControls END<<<<<');
            
}
        
       
        


      


}