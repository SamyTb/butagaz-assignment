@isTest
public class VFC_MEP_01_Test{

 static testMethod void VFC_MEP_01_Test() {
      
	System.Debug('### >>>>> testing class VFC_MEP_01 <<<<<');
	
	String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
	User u = new User(FirstName='Test', LastName='VFCMEP01',Alias='VFCMEP01',
            Email='VFCMEP01@shell.com',Username='VFCMEP01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
	insert u;
        
	Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
	insert new List<Custom_Settings__c> { c1 };
        
	System.runAs(u) {
          
		//Mandataire
		Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
		insert mandataire1;
                    
		Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
		insert AD_GEC;
		Canton__c Canton1 = new Canton__c(name = 'VFCMEP01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
		insert Canton1;
		City__c City1  = new City__c (Name = 'VFCMEP01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
		insert City1;
		City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCMEP01City', 
			City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
		insert cityCP;
          
		Account a = new Account(Name='VFCMEP01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
            Postal_Code__c = '123', City__c = 'VFCMEP01City', Email__c = 'VFCMEP01City@test.org',Country__c='FR', Phone='0202020202');
		insert a;
            
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
        accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
        Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
        Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
        insert c;          
            
        // PriceBooks & Products
        Id pb2StandardId = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFCMEP01',Description='Test Pricebook VFCMEP01', isActive=true);
        insert pbk1;
        
        List<Pricebook2> pbkList = [select id, name from Pricebook2];
        for (Pricebook2 pbk: pbkList) {
            System.Debug('### PriceBookId:' + pbk.id + 'PriceBookName:' + pbk.name);
        }
        
        List<Product2> prdList = new List<Product2>();
            
        Product2 oProduct1 = new Product2(Name = 'p1',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12345', is_crea__c=true, Tank_Type__c='A'); 
        Product2 oProduct2 = new Product2(Name = 'p2',isactive=true,Family='Produit' ,Sub_Type__c='Citerne' ,ProductCode='12346', is_crea__c=true, Tank_Type__c='A');
        prdList.add(oProduct1);
        prdList.add(oProduct2);

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
          name = 'VFCMEP01 Mandataire',
          ExternalID__c = 'VQL01',
          Active__c = true
        );
        insert mand1;
            
        PTL__c ptl1 = new PTL__c(
          Activity_Domain__c = AD_GEC.id,
          Mandataire__c = mand1.id,
          City__c = 'VFCMEP01 City 2',
          Postal_Code__c = '09876'
        );
        insert ptl1;
            
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
          Installation_date__c = Date.today() + 15,
          Existing_PTL__c = ptl1.id,
          T_Pack__c = ''
          );
        insert opp1;
              
        Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
		insert attCom50;   

		Opportunity_PTL__c optyPTL1 = new Opportunity_PTL__c(
            Opportunity__c = opp1.Id, 
            PTL_Name__c = 'VFCMEP01',
            PTL_Street_Type__c = '456',
            PTL_Street_Name__c = '789',
            PTL_City_Postal_Code__c = cityCP.Id,
            Code_AC_administrator_New__c = attCom50.Id,
			Code_marche__c =  'P100'

        );
		insert optyPTL1;
          
		// Quote & Line items
        Quote q1 = new Quote(OpportunityId = opp1.Id, Name='VFCMEP01City Quote', 
            DO_Payment_method__c = 'V',
            Payment_spread__c = 'Z000',
            Contract_Duration__c = '5',
            Pricebook2Id = pbk1.id,
            ExpirationDate = Date.today() + 10,
            Date_de_cotation__c = Date.today(),
            Date_debut_offre__c = Date.today()
            
        );
        insert q1;
          
        Quote_PTL__c oQPTL1 = [SELECT Id, Name FROM Quote_PTL__c WHERE Quote__c = :q1.Id];          
          
        List<QuoteLineItem> lQLI = new List<QuoteLineItem>{
                new QuoteLineItem(RCE_Rebate_TTC__c = 1, QuoteId = q1.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[0].Id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Butagaz Owned Tank'
                ),
                new QuoteLineItem(RCE_Rebate_TTC__c = 2, QuoteId = q1.Id, Quantity = 1, 
                    UnitPrice = 1, PricebookEntryId = pbeList[1].id, 
                    Quote_PTL__c = oQPTL1.Id, Mis_Disposition__c = 'Tank sold by BTZ'
                )
        }; 
        insert lQLI;
        
        //update optyPTL1;
		opp1.SyncedQuoteId = q1.Id;
		opp1.DO_Postal_Code__c = null;
		opp1.DO_City__c = null;       
		update opp1 ;
      
        //update q1;
          
        List<Quote_PTL__c> qptlList = [SELECT Id FROM Quote_PTL__c WHERE Quote__c = :q1.Id];
		
		
      	Test.startTest();

		ApexPages.currentPage().getParameters().put('id',optyPTL1.id);
		ApexPages.StandardController sc = new ApexPages.standardController(optyPTL1);
		VFC_MEP_01 vmep01 = new VFC_MEP_01 (sc);
		
		
	 	/*   public static testmethod void testGetQuoteLineItems(){ 
	        VFC_MEP_01 controller = new VFC_MEP_01(new ApexPages.Standardcontroller(new Opportunity_PTL__c()));
	        controller.getQuoteLineItems();
	    }
	    
	    public static testmethod void testGetQUOTEPTLS(){ 
	        VFC_MEP_01 controller = new VFC_MEP_01(new ApexPages.Standardcontroller(new Opportunity_PTL__c()));
	        controller.getQUOTEPTLS();
	    }
	    
	    public static testmethod void testGetPrettyDate(){       
	        VFC_MEP_01 controller = new VFC_MEP_01(new ApexPages.Standardcontroller(new Opportunity_PTL__c()));
	        controller.getPrettyDate();
	    }*/
		
		List<Equipement__c >eqpt01=new list <Equipement__c>();
		eqpt01 = vmep01.getPTLEQUIPEMENTS();
		List<QuoteLineItem> tmpQliList = vmep01.getCurrentTankQuoteLineItems();
		String prettyDate = vmep01.getPrettyDate();
		vmep01.getQuoteLineItems();
		vmep01.getQUOTEPTLS();
		
		
		Test.stopTest();
		System.Debug('### >>>>> testing class VFC_MEP_01 END <<<<<');
      
	}
            
 }
    
}