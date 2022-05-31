@isTest
public class AP_VFMessage_TEST {
    
    public static testmethod void testgetSeverityFromType(){
        Test.startTest();
        AP_VFMessage ap1 = new AP_VFMessage('E', 'TESTSummary');
        AP_VFMessage ap2 = new AP_VFMessage('S', 'TESTSummary');
        AP_VFMessage ap3 = new AP_VFMessage('W', 'TESTSummary');
        AP_VFMessage ap4 = new AP_VFMessage('I', 'TESTSummary');
        AP_VFMessage ap5 = new AP_VFMessage('A', 'TESTSummary', 'TESTDetails');
        AP_VFMessage ap6 = new AP_VFMessage('K', 'TESTSummary', 'TESTDetails');
        System.assertEquals(ApexPages.Severity.ERROR, ap1.getSeverityFromType());
        System.assertEquals(ApexPages.Severity.CONFIRM, ap2.getSeverityFromType());
        System.assertEquals(ApexPages.Severity.WARNING, ap3.getSeverityFromType());
        System.assertEquals(ApexPages.Severity.INFO, ap4.getSeverityFromType());
        System.assertEquals(ApexPages.Severity.ERROR, ap5.getSeverityFromType());
        System.assertEquals(ApexPages.Severity.INFO, ap6.getSeverityFromType());
        Test.stopTest();
    
    }
}