@isTest
public class AP_InventoryPricing_01_Test{

 static testMethod void AP_InventoryPricing_01_Test() {
    
      System.Debug('### >>>>> testing class AP_InventoryPricing_01_Test <<<<<');
   
      String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APInventoryPricing01',Alias='VFCMEP01',
            Email='APInventoryPricing01@shell.com',Username='APInventoryPricing01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
          
          Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
          insert AD_GEC;
          Canton__c Canton1 = new Canton__c(name = 'APInventoryPricing01 Canton', INSEE_Code__c = '-_-_');
          insert Canton1;
          City__c City1  = new City__c (Name = 'APInventoryPricing01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
          insert City1;
          City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APInventoryPricing01City', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
          insert cityCP;
          
          Account a = new Account(Name='APInventoryPricing01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
            Postal_Code__c = '123', City__c = 'APInventoryPricing01City', Email__c = 'APInventoryPricing01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
            // PriceBooks & Products
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook APInventoryPricing01',Description='Test Pricebook APInventoryPricing01', isActive=true);
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
              name = 'APInventoryPricing01 Mandataire',
              ExternalID__c = 'VQL01',
              Active__c = true
            );
            insert mand1;
            
            PTL__c ptl1 = new PTL__c(
              Activity_Domain__c = AD_GEC.id,
              Mandataire__c = mand1.id,
              City__c = 'APInventoryPricing01 City 2',
              Postal_Code__c = '09876'
            );
            insert ptl1;
    
    
    
            Test.startTest();
                
                List<Inventory_Pricing__c> IntPri01 = new list<Inventory_Pricing__c>(); 
                AP_InventoryPricing_01.recoverLastIPDate(IntPri01);
                AP_InventoryPricing_01.recoverLastIPBDPrice(IntPri01);
                AP_InventoryPricing_01.copyIPBrandsToPTL(IntPri01);

            Test.stopTest();
            System.Debug('### >>>>> testing class AP_InventoryPricing_01 END <<<<<');
        }
        
 }
    
    
 }