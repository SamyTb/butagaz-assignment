@isTest
public class AP_Assignment_RFF_01_Test{
    public static testmethod void testNaming(){
        Group grp = new Group(Name = 'SomeGroup');
        insert grp;

        Rep_For_Filter__c RFF = new Rep_For_Filter__c(Target__c = 'Queue', QueueId__c = grp.Id, Assignment_Managed_Id__c = '__01');

        Test.startTest();

        insert RFF;
        RFF = [SELECT TargetName__c FROM Rep_For_Filter__c WHERE Id = :RFF.Id]; //Refresh
        System.assertEquals('SomeGroup', RFF.TargetName__c);

        update RFF;

        Test.stopTest();
    }

    public static testmethod void testNoUser(){
        Rep_For_Filter__c RFF = new Rep_For_Filter__c(Target__c = 'User');
        Boolean hasErrored = false;

        Test.startTest();

        try { insert RFF; } 
        catch (System.DmlException e) { 
            System.assert(e.getMessage().contains(System.Label.Error_NoUser));
            hasErrored = true; 
        }
        System.assertEquals(true, hasErrored);

        Test.stopTest();
    }

    public static testmethod void testInvalidQueueId(){
        Rep_For_Filter__c RFF1 = new Rep_For_Filter__c(Target__c = 'Queue', QueueId__c = 'INVALID');
        Rep_For_Filter__c RFF2 = new Rep_For_Filter__c(Target__c = 'NONSENSE');
        Boolean hasErrored1 = false;
        Boolean hasErrored2 = false;

        Test.startTest();

        try { insert RFF1; }
        catch (System.DmlException e){
            System.assert(e.getMessage().contains(System.Label.Error_InvalidQueueId));
            hasErrored1 = true;
        }
        System.assertEquals(true, hasErrored1);

        try { insert RFF2; }
        catch (System.DmlException e){
            System.assert(e.getMessage().contains(System.Label.Error_InvalidTarget));
            hasErrored2 = true;
        }
        System.assertEquals(true, hasErrored2);

        Test.stopTest();
    }
}