public class AP_Conso_SObject_01{
    // Used to input the Consumption curve from Excel. The field should be in the order defined here.
    public static List<String> QUOTE_PTL_CONSUMPTION_FIELDS = new List<String>{
        'consumption_fixed_jan__c', 'consumption_fixed_feb__c', 'consumption_fixed_mar__c', 
        'consumption_fixed_apr__c', 'consumption_fixed_may__c', 'consumption_fixed_jun__c', 
        'consumption_fixed_jul__c', 'consumption_fixed_aug__c', 'consumption_fixed_sep__c', 
        'consumption_fixed_oct__c', 'consumption_fixed_nov__c', 'consumption_fixed_dec__c',
        'consumption_variable_jan__c', 'consumption_variable_feb__c', 'consumption_variable_mar__c',
        'consumption_variable_apr__c', 'consumption_variable_may__c', 'consumption_variable_jun__c',
        'consumption_variable_jul__c', 'consumption_variable_aug__c', 'consumption_variable_sep__c',
        'consumption_variable_oct__c', 'consumption_variable_nov__c', 'consumption_variable_dec__c',
        'Temperature__c'
    };
    
   public static List<String> PTL_CONSUMPTION_PROFILE_FIELDS = new List<String>{
        'consumption_fixed_jan__c', 'consumption_fixed_feb__c', 'consumption_fixed_mar__c', 
        'consumption_fixed_apr__c', 'consumption_fixed_may__c', 'consumption_fixed_jun__c', 
        'consumption_fixed_jul__c', 'consumption_fixed_aug__c', 'consumption_fixed_sep__c', 
        'consumption_fixed_oct__c', 'consumption_fixed_nov__c', 'consumption_fixed_dec__c',
        'consumption_variable_jan__c', 'consumption_variable_feb__c', 'consumption_variable_mar__c',
        'consumption_variable_apr__c', 'consumption_variable_may__c', 'consumption_variable_jun__c',
        'consumption_variable_jul__c', 'consumption_variable_aug__c', 'consumption_variable_sep__c',
        'consumption_variable_oct__c', 'consumption_variable_nov__c', 'consumption_variable_dec__c',
        'Temperature__c'
    };

    public static List<String> OPPORTUNITY_CONSUMPTION_FIELDS = new List<String>{
        'consumption_fixed_jan__c', 'consumption_fixed_feb__c', 'consumption_fixed_mar__c', 
        'consumption_fixed_apr__c', 'consumption_fixed_may__c', 'consumption_fixed_jun__c', 
        'consumption_fixed_jul__c', 'consumption_fixed_aug__c', 'consumption_fixed_sep__c', 
        'consumption_fixed_oct__c', 'consumption_fixed_nov__c', 'consumption_fixed_dec__c',
        'consumption_variable_jan__c', 'consumption_variable_feb__c', 'consumption_variable_mar__c',
        'consumption_variable_apr__c', 'consumption_variable_may__c', 'consumption_variable_jun__c',
        'consumption_variable_jul__c', 'consumption_variable_aug__c', 'consumption_variable_sep__c',
        'consumption_variable_oct__c', 'consumption_variable_nov__c', 'consumption_variable_dec__c',
        'Temperature__c'
    };

    public static String CONSUMPTION_REGEX = '(\\d*([.,]\\d+))|(\\d+)';
    public static Pattern CONSUMPTION_PATTERN = Pattern.compile(AP_Conso_SObject_01.CONSUMPTION_REGEX);

    public static void updateConso(SOBject oSObject, List<String> consumptionFields){
        System.debug('[AP_Conso_SObject_01.updateConso] Processing SObject [' + oSObject + '].');
        if (
               (String.valueOf(oSObject.get('Consumption_From_Excel__c')) != '') 
            && (String.valueOf(oSObject.get('Consumption_From_Excel__c')) != null)
        ){
            System.debug('[AP_Conso_SObject_01.updateConso] SObject consumption has to be updated.');
            Matcher consumptionMatcher = AP_Conso_SObject_01.CONSUMPTION_PATTERN.matcher(String.valueOf(oSObject.get('Consumption_From_Excel__c')));

            List<String> consumptionFieldsLeft = new List<String>();
            consumptionFieldsLeft.addAll(consumptionFields);
            String fieldName; Decimal fieldValue; // Looop variables.

            while (consumptionMatcher.find()){
                try {
                    fieldName = consumptionFieldsLeft.remove(0);
                    fieldValue = Decimal.valueOf(consumptionMatcher.group().replace(',','.'));
                    System.debug('[AP_Conso_SObject_01.updateConso] Updating [' + fieldName + '] to [' + fieldValue + '].');
                    oSObject.put(fieldName, fieldValue); 
                } catch (System.SObjectException e){
                    oSObject.addError(System.Label.SObject_Consumption_InvalidFieldName + '['+ fieldName + ']'); 
                } catch (System.ListException e){
                    oSObject.addError(System.Label.SObject_Consumption_InvalidInput);
                }
            }

            System.debug('[AP_Conso_SObject_01.updateConso] Done updating.');

            if (consumptionFieldsLeft.size() > 0){
                oSObject.addError(System.Label.SObject_Consumption_InvalidInput);
            }

            oSObject.put('Consumption_From_Excel__c', ''); // Clear it after we're done.
            System.debug('[AP_Conso_SObject_01.updateConso] Done cleaning.');
        } else {
            System.debug('[AP_Conso_SObject_01.updateConso] SObject consumption does not have to be updated.');
        }
    }

    public static void updateConso(List<Quote_PTL__c> lQuotePTLs){
        AP_Conso_SObject_01.updateConso(lQuotePTLs, QUOTE_PTL_CONSUMPTION_FIELDS);
    }
    
    public static void updateConso(List<PTL_Consumption_Profile__c> lQuotePTLs){
        AP_Conso_SObject_01.updateConso(lQuotePTLs, PTL_CONSUMPTION_PROFILE_FIELDS);
    }
    

    public static void updateConso(List<Opportunity> lOpties){
        AP_Conso_SObject_01.updateConso(lOpties, OPPORTUNITY_CONSUMPTION_FIELDS);
    }

    public static void updateConso(List<SObject> lSObjects, List<String> consumptionFields){
        for (SOBject oSObject : lSObjects){
            AP_Conso_SObject_01.updateConso(oSObject, consumptionFields);
        }
    }

}