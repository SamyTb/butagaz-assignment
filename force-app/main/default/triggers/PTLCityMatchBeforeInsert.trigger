trigger PTLCityMatchBeforeInsert on PTL__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> PTLCityMatchFromCode.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('PTLCityMatchFromCode.matchCities')) {
            new AP_CityMatchingEngine_01(
                'City_Code__c', 'Postal_Code__c', 'City__c', 
                'SAP_City_Code__c', 'SAP_Postal_Code__c', 'SAP_City_Name__c', 
                'City_Postal_Code__c', false
            ).match(Trigger.new);
        } else {
            System.Debug('##>>> PTLCityMatchFromCode.BeforeInsert : BYPASS <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> PTLCityMatchFromCode.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> PTLCityMatchFromCode.BeforeInsert : FALSE TRIGGER <<<');
    }
}