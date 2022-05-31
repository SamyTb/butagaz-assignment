@isTest(SeeAllData=true)
public class AP_CustomSettings_01_Test {
    public static testmethod void getCustomSettingFailure() {
        String value = AP_CustomSettings_01.getCustomSetting('Bla');
    }
    
    public static testmethod void getCustomSettingSuccess() {
        String value = AP_CustomSettings_01.getCustomSetting('Case_RecordTypeId_Claim');
    }
}