@istest	
public class CustSatisfactionEmailTempCompTest {
    
    public static void initCustomSettting(){
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        Custom_Settings__c c24 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEB', Value__c = 'http://uat.client-bouteilles-pro.butagaz.fr/oneclickregistration/?code=');
        Custom_Settings__c c25 = new Custom_Settings__c ( name ='Espace_Client_Registration_URL_GEC', Value__c = 'http://uat.espace-client.butagaz.fr/oneclickregistration/?code=');
        Custom_Settings__c c26 = new Custom_Settings__c (name ='Espace_Client_Satisfaction_URL_GEB', Value__c = 'http://uat-client-bouteilles-pro.butagaz.fr/survey/answer?code=');
         Custom_Settings__c c27 = new Custom_Settings__c ( name ='Espace_Client_Satisfaction_URL_GEC', Value__c = 'http://uat-espace-client.butagaz.fr/survey/answer?code=');
        insert new List<Custom_Settings__c> { c1, c8, c9, c10, c13, C24, C25, C26, C27 };
            }
    
    public static void setDataUpForTest(){
                String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='APCT10',Alias='APCT10',
            Email='APCT10@shell.com',Username='APCT10@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
      initCustomSettting();
        
        System.runAs(u) {
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=41);
            insert AD_GEC;
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
   
            Canton__c Canton1 = new Canton__c(name = 'APCT10 Canton', INSEE_Code__c = '-_-_');
            insert Canton1;
            City__c City1  = new City__c (Name = 'APCT10 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCT10', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
            
            
            Account a = new Account(Name='APCT10 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'APCT10City', Email__c = 'APCT10@test.org', channel__c='CD',
                accountNumber='12345',Country__c='FR', Phone='0202020202', ExternalID__c ='APCT10 ');
            insert a;
            
           // Contact c = new Contact(Lastname='APCT10 Contact', AccountId = a.id);
           // insert c;
           
                    
           // New Contact
           Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
           accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
           Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
           Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
           insert c;
            
            //PTL & Mandataire
            Mandataire__c mand1 = new Mandataire__c(
                name = 'APCT10 Mandataire',
                ExternalID__c = 'MAP10',
                Active__c = true
            );
            insert mand1;
            
            PTL__c oPtl = new PTL__c();
            oPtl.Activity_Domain__c = AD_GEC.Id;
            oPtl.Mandataire__c = mand1.Id;
            oPTL.City__c = 'A City';
            oPTL.Postal_Code__c = '09877';
            insert oPtl;
            
            Equipement__c oEquipment = new Equipement__c();
            oEquipment.PTL__c = oPtl.Id;
            oEquipment.Activity_Domain__c = AD_GEC.Id;
            oEquipment.Mandataire__c = mand1.Id;
            insert oEquipment;
            
            Contract oContract = new Contract();
            oContract.AccountId = a.Id;
            oContract.PTL__c = oPtl.Id;
            oContract.Equipement__c = oEquipment.Id;
            oContract.Activity_Domain__c = AD_GEC.Id;
            oContract.Mandataire__c = mand1.Id;
            insert oContract;
            
            Order__c oOrder = new Order__c();
            oOrder.Account__c = a.Id;
            oOrder.Contract__c = oContract.Id;
            oOrder.Activity_Domain__c = AD_GEC.Id;
            oOrder.Mandataire__c = mand1.Id;
            insert oOrder;
        
            Case oCase = new Case();
            oCase.Mandataire__c = mand1.Id;
            oCase.Order__c = oOrder.Id;
            insert oCase;
                
            oOrder = [SELECT Id, Activity_Domain__c, Mandataire__c, Contract__c, Contract__r.Ptl__c, Contract__r.Equipement__c, Contract__r.AccountId FROM Order__c WHERE Id = :oOrder.Id];
            oCase = [SELECT Id, Activity_Domain__c, Mandataire__c, Order__c, Contract__c, Equipement__c, PTL__c, AccountId FROM Case WHERE Id = :oCase.Id];
            System.assertEquals(oOrder.Activity_Domain__c, oCase.Activity_Domain__c);
            System.assertEquals(oOrder.Mandataire__c, oCase.Mandataire__c);
            System.assertEquals(oOrder.Id, oCase.Order__c);
            System.assertEquals(oOrder.Contract__c, oCase.Contract__c);
            System.assertEquals(oOrder.Contract__r.Equipement__c, oCase.Equipement__c);
            System.assertEquals(oOrder.Contract__r.Ptl__c, oCase.PTL__c);
            System.assertEquals(oOrder.Contract__r.AccountId, oCase.AccountId);
            
        }
    }
    
    @istest
    public static void testprepareCustSatisfactionUrl (){
        setDataUpForTest();
        Order__c vOrder=    [SELECT Id, Order_Origin__c,Created_By_value__c,Name,Activity_Domain__r.ExternalID__c,Account__r.ExternalID__c  from Order__c limit 1];
        CustSatisfactionEmailTempComp ctrl = new CustSatisfactionEmailTempComp();
        ctrl.vOrderId =vOrder.id;
            System.assert(vOrder.Account__r.ExternalID__c!= null,'Order.Account__r.ExternalID__c ==null ');
          System.assert(vOrder.Account__r.ExternalID__c== 'APCT10','Order.Account__r.ExternalID__c !=APCT10 ');
        ctrl.prepareCustSatisfactionUrl();
        System.assert( null != ctrl.mapCryptageStatisfactionUrl, 'La map contenant les urls encripté de notation, de 1 à 10, est vide !!!');
        
    } 

}