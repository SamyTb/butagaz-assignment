public without sharing class GDB_ContactFormController {
    @AuraEnabled
    public static Account getCurrentCustomer() {
        return GDB_AccountMgr.getCurrentCustomer();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getAvailableListValues() {
        Map<String, String> reasons = GDB_CaseMgr.getCaseReasons();
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

    @AuraEnabled
    public static Map<String, String> submitContactForm(Map<String, String> detailsForm) {
        return GDB_CaseMgr.submitCase(detailsForm);
    }
}