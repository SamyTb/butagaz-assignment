public class AP_CustomSettings_01{
    public static String getCustomSetting(String key){
        Map<String, Custom_Settings__c> customSettings = Custom_Settings__c.getAll();
        if (customSettings.containsKey(key)) {
            return customSettings.get(key).value__c;
        } else { 
            return null;
        }
    }
}