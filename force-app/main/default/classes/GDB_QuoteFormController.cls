public with sharing class GDB_QuoteFormController {
    /**
     * getCurrentCustomer Return current Customer
     * @return   Object Account
     */ 
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    /**
     * getAvailableListValues return availables reasons for case
     * @return  Map<String, List<Map<String, String>>>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getAvailableListValues() {
        Map<String, String> reasons = GDB_CaseMgr.getCaseReasonsQuoteForm();

        List<Map<String, String>> reasonsList = new List<Map<String, String>>();

        for(String value : reasons.keySet()) {
            Map<String, String> reason = new Map<String, String> {
                'value' => value,
                'label' => reasons.get(value)
            };
            reasonsList.add(reason);
        }

        return new Map<String, List<Map<String, String>>>{
            'reasons' => reasonsList
        };
    }

    /**
     * submitContactForm submit form data for create quote
     * @param  detailsForm detailsForm description
     * @return             return created case
     */
    @AuraEnabled
    public static Map<String, String> submitQuoteForm(Map<String, String> detailsForm) {
        return GDB_CaseMgr.submitCase(detailsForm);
    }
    
    @AuraEnabled
    public static Boolean isZipCodeDeliverable(String zipCode)
    {
        if(!String.isEmpty(zipCode))
        {
        	String bulkDeliveredZipCodes = GDB_CustomSettingsMgr.self().getBulkDeliveredZipCodes();
            
            if(!String.isEmpty(bulkDeliveredZipCodes))
            {
                String[] departments = bulkDeliveredZipCodes.split(',');
                
                
                for(String department : departments)
                {
                    department = department.trim();
                    
                    if(zipCode.startsWith(department))
                    {
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
}