public class AP_QuoteLineItem_02 {
    
    private final static String HT = '_HT__c';
    private final static String TTC = '_TTC__c';
    
    /*
     * Calcul the field HT or TTC on Quote line items pricing fields
     *
     * Called by QLI Triggers
     */
    public static void calculateTaxes(List<QuoteLineItem> newQLIs, Map<Id, QuoteLineItem> oldQLIs) {
        
        for(QuoteLineItem newQli : newQLIs){
            
            QuoteLineItem oldQli = oldQLIs.get(newQli.Id);
            
            //CALCULS
            calculHTorTTC('Group_Commercial_Rebate', newQli, oldQli);
            
            calculHTorTTC('Commercial_Rebate', newQli, oldQli);
            
            calculHTorTTC('Group_Cyclical_Rebate', newQli, oldQli);
            
            calculHTorTTC('Cyclical_Rebate', newQli, oldQli);
            
            calculHTorTTC('RCE_Rebate', newQli, oldQli);
            
            calculHTorTTC('Group_RCE_Rebate', newQli, oldQli);
            
        }
        
    }
    
    /*
     * Update HT or TTC fields based on the context
     */
    private static void calculHTorTTC(String fieldName, QuoteLineItem newQli, QuoteLineItem oldQli){
            
            Decimal taxRate = 1 + ((newQli.VAT_Percentage__c != null ? newQli.VAT_Percentage__c : 0) / 100);          
            Decimal valueHT = newQli.get(fieldName+HT) != null ? ((Decimal) newQli.get(fieldName+HT)) : 0;
            Decimal valueTTC = newQli.get(fieldName+TTC) != null ? ((Decimal) newQli.get(fieldName+TTC)) : 0;
            
            if (oldQli != null) {               
                if (isChanged(fieldName+HT, newQli, oldQli)) {
                    //Calcul TTC based on HT
                    newQli.put(fieldName+TTC, (valueHT * taxRate));
                } 
                else if (isChanged(fieldName+TTC, newQli, oldQli)) {
                    //Calcul HT based on TTC
                    newQli.put(fieldName+HT, (valueTTC  / taxRate));
                }
            }
            else{
                if (valueHT != 0) {
                    //Calcul TTC based on HT
                    newQli.put(fieldName+TTC, (valueHT  * taxRate));
                } 
                else if (valueTTC != 0) {
                    //Calcul HT based on TTC
                    newQli.put(fieldName+HT, (valueTTC / taxRate));
                }
            }
            
    }
    
    private static Boolean isChanged(String fieldName, QuoteLineItem newQli, QuoteLineItem oldQli){
        return newQli.get(fieldName) != oldQli.get(fieldName);
    }
}