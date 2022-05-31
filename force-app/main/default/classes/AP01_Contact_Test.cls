@IsTest(SeeAllData=true)
private class AP01_Contact_Test {
    /*static testMethod void myUnitTest() {
        //Custom Settings of the environment
        String sRoleValue = Utils.getCustomSetting('Contact_Main_Role');
        
        Account a = new Account(Name='Test Account',City__c='Test City',Postal_Code__c='0000');
        insert a;
        
        Contact c = new Contact(LastName='Test Contact',FirstName='Test Contact',AccountId=a.Id);
        insert c;
        
        List<Contact_in_Account__c> lca = [SELECT Id, Contact__c, Account__c, Role__c FROM Contact_in_Account__c WHERE Contact__c = :c.Id AND Account__c = :a.Id];
        
        System.assertEquals(lca[0].Contact__c, c.Id);
        System.assertEquals(lca[0].Account__c, a.Id);
        System.assertEquals(lca[0].Role__c, sRoleValue);
        
        //ContactBeforeInsert test
        Contact d = new Contact(LastName='Test Contact',FirstName='Test Contact');
        insert d;
        
        List<Contact_in_Account__c> lca2=new List<Contact_in_Account__c>();
        lca2 = [SELECT Id FROM Contact_in_Account__c WHERE Contact__c = :d.Id];
        System.assertEquals(lca2.size(), 0);
    }*/
}