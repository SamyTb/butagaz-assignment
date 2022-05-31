public class AP_CopyAddressFields_01{

    public class MappedField {
        public String frm; // from is reserved
        public String to;

        public MappedField(String frm, String to){
            this.frm = frm;
            this.to   = to;
        }
    }
    
    /*
     * For each leads on parameter : Copy all the mapped adress fields (based on LeadAddressMapping__c)
     * when the field "Same Address Checkbox" is checked
     */
    public static void copyAddressFields(List<Lead> lLeads){
        List<MappedField> fieldMapping = new List<MappedField>();

        //retrieve mapping on LeadAddressMapping__c and build mapping list
        for (LeadAddressMapping__c oMapped : LeadAddressMapping__c.getAll().values()){
            fieldMapping.add(new MappedField(oMapped.ClientAddress__c, oMapped.ProjectAddress__c));
        }
        
        //copy
        lLeads = copyMappedFields(lLeads, fieldMapping);
        
    }
    
    /*
     * Apply the field copy based on the mapping passed in parameter
     */
    public static List<Lead> copyMappedFields(List<Lead> lLeads, List<MappedField> fieldMapping){
       
       for (Lead oLead : lLeads){
            if (oLead.Same_Address__c) { // We should map
                for (MappedField oMappedField : fieldMapping){
                    
                    //copy
                    //oLead.put(oMappedField.frm, oLead.get(oMappedField.to));
                    oLead.put(oMappedField.to, oLead.get(oMappedField.frm));
                    
                    //log
                    System.debug('[AP_CopyAddressFields_01] Mapped [' + oMappedField.frm + '] to [' + oMappedField.to + ']');
                    System.debug('[AP_CopyAddressFields_01] Frm value: [' + oLead.get(oMappedField.frm) + ']');
                    System.debug('[AP_CopyAddressFields_01] To value: [' + oLead.get(oMappedField.to) + ']');
                }
            }
        }
        
        return lLeads;
    }
    
}