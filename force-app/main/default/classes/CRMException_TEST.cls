@isTest(seeAllData=false)
public class CRMException_TEST {
    public static testmethod void testCRMExceptionCreation(){
        Test.startTest();
        CRMException e = new CRMException();
        
        Test.stopTest();
    }
}