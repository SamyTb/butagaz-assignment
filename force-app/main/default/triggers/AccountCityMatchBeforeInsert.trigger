trigger AccountCityMatchBeforeInsert on Account (before insert) {

    List<Account> lAccountToInsert = new List<Account>();
    
    Custom_Settings__c RT_GDB_PA = Custom_Settings__c.getValues('Account_RecordTypeId_GDBPA');
    Id sRT_GDB_PA;
    if(RT_GDB_PA!=null){
        sRT_GDB_PA = RT_GDB_PA.value__c;
    }
    
    
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        
        for(Account acc : Trigger.new){
            //System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : acc.RecordTypeId : ' + acc.RecordTypeId);
            //System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : sRT_GDB_PA : ' + sRT_GDB_PA);
            if(acc.RecordTypeId != sRT_GDB_PA){
                //System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : Pas RT_GDBPA');
                lAccountToInsert.add(acc);
            }
        }
        
        if(lAccountToInsert.size()>0){
            if (PAD.canTrigger('AccountCityMatchFromCode.matchCities')) {
                new AP_CityMatchingEngine_01(
                    'City_Code__c', 'Postal_Code__c', 'City__c', 
                    'SAP_City_Code__c', 'SAP_Postal_Code__c', 'SAP_City_Name__c', 
                    'City_Postal_Code__c', true
                ).match(lAccountToInsert);
            } else {
                System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
            }
        }

        System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> AccountCityMatchFromCode.BeforeInsert : FALSE TRIGGER <<<');
    }
}