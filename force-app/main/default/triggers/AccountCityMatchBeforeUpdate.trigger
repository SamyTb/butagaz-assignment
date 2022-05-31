trigger AccountCityMatchBeforeUpdate on Account (before update) {

    List<Account> lAccountToUpdate = new List<Account>();
    
    Custom_Settings__c RT_GDB_PA = Custom_Settings__c.getValues('Account_RecordTypeId_GDBPA');
    Id sRT_GDB_PA;
    if(RT_GDB_PA!=null){
        sRT_GDB_PA = RT_GDB_PA.value__c;
    }
    
    
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> AccountCityMatchFromCode.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        
        for(Account acc : Trigger.new){
            if(acc.RecordTypeId != sRT_GDB_PA){
                lAccountToUpdate.add(acc);
            }
        }

        if (PAD.canTrigger('AccountCityMatchFromCode.matchCities')) {
            new AP_CityMatchingEngine_01(
                'City_Code__c', 'Postal_Code__c', 'City__c', 
                'SAP_City_Code__c', 'SAP_Postal_Code__c', 'SAP_City_Name__c', 
                'City_Postal_Code__c', true
            ).match(Trigger.new);
        } else {
            System.Debug('##>>> AccountCityMatchFromCode.BeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> AccountCityMatchFromCode.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> AccountCityMatchFromCode.BeforeUpdate : FALSE TRIGGER <<<');
    }
}