@isTest
public class Trigger_PTL_TEST {
    
    static testMethod void myUnitTest() {
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c = 42);
        insert new List<Activity_Domain__c> { AD_GEC };
        
        // New Account
        Account oNewAcc = new Account(name='NewAcc', Activity_Domain__c=AD_GEC.Id,Scale__c = 'ECOCFT',Street_N__c='120',Number_extention__c='B',Street_type__c='RUE',Street_name__c='test',Country__c='FR', Phone='0202020202',Email__c='test@test.com');
        insert oNewAcc;

        // New PTL      
        PTL__c oNewPTL = new PTL__c(Contact_Marketing__c = Null, Name = 'oNewPTL', Account_DO__c=oNewAcc.Id, Activity_Domain__c=AD_GEC.Id, City__c = 'City', Postal_Code__c = '12345', Shipping_Condition__c='02', Scale__c='ECOCFT');
        insert oNewPTL;
        
        PTL__c oPTLToTest = [select Id, Name from PTL__c where id = :oNewPTL.Id];
        
        oPTLToTest.Scale__c='ECOCFT';
        update oPTLToTest;
        
        System.assertEquals(oPTLToTest.Name, 'oNewPTL');
    }
    
}