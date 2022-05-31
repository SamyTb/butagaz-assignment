@isTest
private class AP_RequestCategory_Test
{
    public static testmethod void insertAndUpdateRequestCategory()
    {
        Test.startTest();
        
        Request_Category__c parent = new Request_Category__c();
        parent.Name = 'To be replaced';
        parent.Name__c = 'Question';
        parent.Code__c = 'RQ';
        insert parent;
        
        parent = [SELECT Id, Name FROM Request_Category__c WHERE Id = :parent.Id];
        System.assertEquals('RQ | Question', parent.Name);
        
        Request_Category__c child = new Request_Category__c();
        child.Name = 'To be replaced';
        child.Name__c = 'Smart';
        child.Code__c = '01';
        child.Parent_Category__c = parent.Id;
        insert child;
        
        child = [SELECT Id, Name FROM Request_Category__c WHERE Id = :child.Id];
        System.assertEquals('RQ:01 | Question - Smart', child.Name);
        
        parent.Name__c = 'Answer';
        parent.Code__c = 'RA';
        update parent;
        
        child = [SELECT Id, Name FROM Request_Category__c WHERE Id = :child.Id];
        System.assertEquals('RA:01 | Answer - Smart', child.Name);
        
        Test.stopTest();
    }
}