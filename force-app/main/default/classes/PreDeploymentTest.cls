@isTest(SeeAllData=true)
public class PreDeploymentTest{
        /* This Test class ensures you did the Pre Deploy tasks and 
           provides helpful messages in case you didn't */

        public static final String ERROR_MESSAGE_LEADER;

        static {
                ERROR_MESSAGE_LEADER = 'Missing Pre Deployment Task: '; 
        }


        public static String getCustomSetting(String key){
                Map<String, Custom_Settings__c> customSettings = Custom_Settings__c.getAll();
                if (customSettings.containsKey(key)) {
                        return customSettings.get(key).value__c;
                } else { 
                        return null;
                }
        }

        public class PreDeployException extends Exception {}
        
        public class CustomSettingTestRecord{
                public String key {get;set;}
                public String value {get;set;}

                public CustomSettingTestRecord(String key, String value){
                        this.key = key;
                        this.value = value;
                }
        }

        public static testmethod void testKVCustomSettings(){
                List<CustomSettingTestRecord> lCustomSettingsKeys = new List<CustomSettingTestRecord>(); 
                // Fill with the required CS.

                //lCustomSettingsKeys.add(new CustomSettingTestRecord('Case_RecordTypeId_Claim', ''));
                //lCustomSettingsKeys.add(new CustomSettingTestRecord('Case_RecordTypeId_Standard_Edit','');
                lCustomSettingsKeys.add(new PreDeploymentTest.CustomSettingTestRecord('Case_Reopen_Task_Status','Completed'));
                lCustomSettingsKeys.add(new PreDeploymentTest.CustomSettingTestRecord('Contact_Main_Role','Contact Principal'));
                lCustomSettingsKeys.add(new PreDeploymentTest.CustomSettingTestRecord('Case_Reopen_Task_Subject','Reouverture de la demande'));
                lCustomSettingsKeys.add(new PreDeploymentTest.CustomSettingTestRecord('Case_Status_To_Do','To Do'));
                
                String tmpValue = null;
                for (CustomSettingTestRecord oCSRecord : lCustomSettingsKeys){
                        try {
                                tmpValue = PreDeploymentTest.getCustomSetting(oCSRecord.key);
                        } catch (System.NullPointerException e){
                                throw new PreDeployException(PreDeploymentTest.ERROR_MESSAGE_LEADER + 'Value for Custom Setting ' +oCSRecord.key +' is absent');
                        }
                        System.assertEquals(oCSRecord.value, tmpValue, PreDeploymentTest.ERROR_MESSAGE_LEADER + 'Value for Custom Setting ' + oCSRecord.key + ' is invalid'); 

                }
        }

        public class CustomSettingTestRecordType{
                public String settingName {get;set;}
                public String name {get;set;}
        
                public CustomSettingTestRecordType(String settingName, String name){
                        this.settingName = settingName;
                        this.name = name;
                }
        }

        public static testmethod void testRecordTypes(){
                List<CustomSettingTestRecordType> lRecordTypes = new List<CustomSettingTestRecordType>();
                lRecordTypes.add(new PreDeploymentTest.CustomSettingTestRecordType('Case_RecordTypeId_Claim', 'Claim'));
                lRecordTypes.add(new PreDeploymentTest.CustomSettingTestRecordType('Case_RecordTypeId_Standard_Edit', 'Standard Edit'));
                String tmpValue = null;
                for (CustomSettingTestRecordType oCSTestRecordType : lRecordTypes){
                        try {
                                tmpValue = PreDeploymentTest.getCustomSetting(oCSTestRecordType.settingName);
                                try {
                                        RecordType rt = [SELECT Id, name FROM RecordType Where Id = :tmpValue];
                                        System.assertEquals(oCSTestRecordType.name, rt.name, PreDeploymentTest.ERROR_MESSAGE_LEADER + 'Value for Custom Setting ' + oCSTestRecordType.settingName +  ' points to an invalid record type.');

                                } catch (System.QueryException e) {
                                throw new PreDeployException(PreDeploymentTest.ERROR_MESSAGE_LEADER + 'Value for Custom Setting ' + oCSTestRecordType.settingName +  ' points to no record type.');
                                }
                        } catch (System.NullPointerException e){
                                throw new PreDeployException(PreDeploymentTest.ERROR_MESSAGE_LEADER + 'Value for Custom Setting ' +oCSTestRecordType.settingName +' is absent');
                        }
                }

        }
}