public with sharing class Utils 
{

    // This method is used to check if the current code is running in production
    public static Boolean isProductionOrg()
    {
        return Utils.idsAreEqual(Userinfo.getOrganizationId(),Constants.PRODUCTION_ORG_ID);
    }
    
    public static Boolean isSandboxOrg()
    {
        return !(Utils.idsAreEqual(Userinfo.getOrganizationId(),Constants.PRODUCTION_ORG_ID));
    }
    
    public static Boolean isSystemAdminUser()
    {
        return Utils.idsAreEqual(Constants.SYSTEM_ADMIN_PROFILE_ID, UserInfo.getProfileId());
    }
    
    public static Boolean isUserId(String id)
    {
        return id.substring(0,3).equals('005');
    }
    
    public static Account createAccountBA(Integer i,Id iBA)
    {
        return new Account(Prescriber__c=false,Name = 'TestAccount'+i,RecordTypeId=iBA, Postal_Code__c = '123', City__c = 'Somewhere' , Email__c = 'acc'+i+'@test.com',Country__c='FR', Phone='0202020202');
    } 
    
    public static Account createAccountBA(){
        RecordType rtBA = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        return new Account(Prescriber__c=false,Name = 'TestAccount',RecordTypeId= rtBA.Id , Postal_Code__c = '123', City__c = 'Somewhere',
        Email__c = 'acc_ba@test.com',Country__c='FR', Phone='0202020202');
    }
    
   
    
    public static Contact createContact(Id IDAccount,String sRole)
    {
        return new Contact(FirstName='testFirstName',LastName = 'TestContact',AccountID=IDAccount,CT_ContactRole__c=sRole,Contact_Marketing__c  = true,Country__c='FR', Phone='0202020202');
    }

    public static Boolean idsAreEqual(String id1, String id2)
    {
        if ((id1 == null || id2 == null) && id1 != id2) {
            return false;
        }
        
        if (id1.length() < 15 || id2.length() < 15) {
            return false;
        }
        
        if (id1.subString(0, 15).equals(id2.subString(0, 15))) {
            return true;
        }
        
        return false;
    }
    
    public static Boolean valueIsNull(Object val)
    {
        if (val == null || String.valueOf(val).length() == 0) {
            return true;
        }
        
        return false;
    }
    
    public static String getCustomSetting(String key)
    {
        String value = null;
        
        Map<String, Custom_Settings__c> customSettings = Custom_Settings__c.getAll();
        if (customSettings.containsKey(key)) {
            value = customSettings.get(key).value__c;
        }
        
        return value;
    }
    
    public static TestMethod void testUtils()
    {
        Utils.isProductionOrg();
        Utils.isSandboxOrg();
        
        System.assert(Utils.valueIsNull(null), 'Should be NULL');
        System.assert(Utils.valueIsNull(''),'Should be NULL');
        System.assert(!Utils.valueIsNull('Not NULL'),'Should NOT be NULL');
        System.assert(Utils.isUserId(UserInfo.getUserId()),'Should be a User Id');
        Utils.isSystemAdminUser();
        Utils.idsAreEqual(Constants.PRODUCTION_ORG_ID,Constants.PRODUCTION_ORG_ID);
        Utils.idsAreEqual(Constants.PRODUCTION_ORG_ID,'00D20000000CNwZ');
        Utils.getCustomSetting('test');
    }
}