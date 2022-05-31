/*
 * Test class of AP_CopyAddressFields_01
 */
@isTest
public class AP_CopyAddressFields_01_test{
   
    /*
     * Test of AP_CopyAddressFields_01.copyMappedFields method
     */
    static testmethod void testCopyMappedFields(){
       
        //init dataset
        //--------------------------------
       
        List<AP_CopyAddressFields_01.MappedField> fieldMapping = new List<AP_CopyAddressFields_01.MappedField>();
        //String field
        fieldMapping.add(new AP_CopyAddressFields_01.MappedField('Project_Street_name__c', 'Account_Street_Name__c'));
        //Picklist field
        fieldMapping.add(new AP_CopyAddressFields_01.MappedField('Project_Number_Extension__c', 'Account_Number_Extension__c'));
        
            
        List<Lead> lLeads = new List<Lead>();
        Lead leadA = new Lead();
        leadA.put('Project_Street_name__c', 'Street name');
        leadA.put('Project_Number_Extension__c', 'B');
        leadA.put('Same_Address__c', true);
        lLeads.add(leadA);
        
        //--------------------------------
        
      
        List<Lead> updatedLeadList = AP_CopyAddressFields_01.copyMappedFields(lLeads , fieldMapping);
        System.assertEquals(1,updatedLeadList .size());
    }
    
    
    
    /*
     * Test of AP_CopyAddressFields_01.copyAddressFields method
     */
    static testmethod void testCopyAddressFields(){
       
        //init dataset
        //--------------------------------
        
        //String field
        LeadAddressMapping__c mappingA = new LeadAddressMapping__c();
        mappingA.put('Name', 'mappingA');
        mappingA.put('ClientAddress__c', 'Project_Street_name__c');
        mappingA.put('ProjectAddress__c', 'Account_Street_Name__c');
        insert mappingA;
        
        //Picklist field
        LeadAddressMapping__c mappingB = new LeadAddressMapping__c();
        mappingB.put('Name', 'mappingB');
        mappingB.put('ClientAddress__c', 'Project_Number_Extension__c');
        mappingB.put('ProjectAddress__c', 'Account_Number_Extension__c');
        insert mappingB ;
        

        List<Lead> lLeads = new List<Lead>();
        Lead leadA = new Lead();
        leadA.put('Project_Street_name__c', 'Street name');
        leadA.put('Project_Number_Extension__c', 'B');
        leadA.put('Same_Address__c', true);
        lLeads.add(leadA);
        
        //--------------------------------
        
       
        AP_CopyAddressFields_01.copyAddressFields(lLeads);
    }
    
}