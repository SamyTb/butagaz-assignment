@isTest
public class VFC_NewOpportunity_Test{

    /*
     * Test of the method : VFC_NewOpportunity.redirectToNewOpty()
     */
    public static testmethod void testRedirectToNewOpty(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        /** DATA SET **********/
        City_Postal_Code__c cityPostalCode = getMockCityPostalCode();

        Activity_Domain__c ad = new Activity_Domain__c(Name = 'GEB', ExternalID__c = 41); 
        insert ad;

        Account oAcct = new Account(Name = 'MAH', 
        Postal_Code__c = '123', 
        City__c = 'APCTRCity',         
        Market_Type__c = 'PRO', 
        Activity_Domain__c = ad.Id,Country__c='FR', 
        Phone='0202020202',Email__c='toto@titit.com'); 
        insert oAcct;
        
         // New Contact
         Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
         accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
         Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
         Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
         insert c;
         
       
         
        /***********************/


        VFC_NewOpportunity controller = new VFC_NewOpportunity(new ApexPages.Standardcontroller(oAcct));
        PageReference ref = controller.redirectFromAccountToNewOpty();

        //System.assert(ref != null);
        //System.assertEquals('/006/e/accid=' + oAcct.Id + , ref.getUrl()); //TODO: FixMe!
    }
    
     /*
     * Test of the method : VFC_NewOpportunity.redirectToNewOpty()
     */
    public static testmethod void testRedirectFromContractToNewOpty(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        /** DATA SET **********/
        City_Postal_Code__c cityPostalCode = getMockCityPostalCode();

        Activity_Domain__c ad = new Activity_Domain__c(Name = 'GEB', ExternalID__c = 41); 
        insert ad;

        Account oAcct = new Account(Name = 'MAH', 
        Postal_Code__c = '123', 
        City__c = 'APCTRCity',         
        Market_Type__c = 'PRO', 
        Activity_Domain__c = ad.Id,Country__c='FR', 
        Phone='0202020202',Email__c='toto@titit.com'); 
        insert oAcct;

        
         // New Contact
         Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
         accountId = oAcct.Id,Street_Number__c = oAcct.Street_Number__c,Postal_Box__c = oAcct.Postal_Box__c,
         Postal_Code__c = oAcct.Postal_Code__c,City__c = oAcct.City__c,Email = oAcct.Email__c,Email_2__c = oAcct.Email_2__c,
         Fax = oAcct.Fax,Place_Called__c = oAcct.Place_Called__c,Country__c = oAcct.Country__c,Phone = oAcct.Phone);
         insert c;
        
        Contract contract = new Contract(AccountId = oAcct.Id);
        insert contract;
        
        RecordTypes_OpportunityToQuote__c setting = new RecordTypes_OpportunityToQuote__c(Name = 'Test', OpportunityRecordType__c = '012D0000000374U', QuotePriceBookId__c='01sD00000007cgO', QuoteRecordType__c='012D0000000374g', OptyPTLRecordTypeId__c='012D0000000374g');
        insert setting;
        
        /***********************/


        VFC_NewOpportunity controller = new VFC_NewOpportunity(new ApexPages.Standardcontroller(contract));
        PageReference ref = controller.redirectFromContractToNewOpty();

        //System.assert(ref != null);
        //System.assertEquals('/006/e/accid=' + oAcct.Id + , ref.getUrl()); //TODO: FixMe!
    }
    

    /*
     * Insert and return a City_Postal_Code__c instance for test
     */
    private static City_Postal_Code__c getMockCityPostalCode(){

        Canton__c canton = new Canton__c(INSEE_Code__c = '123', Name = 'ABC'); 
        insert canton;

        City__c city = new City__c(INSEE_Code__c = '456', Name = 'DEF', Canton__c = canton.Id); 
        insert city;

        City_Postal_Code__c oCPC = new City_Postal_Code__c(HEXAPOSTE_Code__c = '____', Name = 'GHI', City__c = city.Id, Code_Type__c = 'M'); 
        insert oCPC;

        return oCPC;
    }
}