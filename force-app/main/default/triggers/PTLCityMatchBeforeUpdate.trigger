trigger PTLCityMatchBeforeUpdate on PTL__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> PTLCityMatchFromCode.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());

        if (PAD.canTrigger('PTLCityMatchFromCode.matchCities')) {
            new AP_CityMatchingEngine_01(
                'City_Code__c', 'Postal_Code__c', 'City__c', 
                'SAP_City_Code__c', 'SAP_Postal_Code__c', 'SAP_City_Name__c', 
                'City_Postal_Code__c', false
            ).match(Trigger.new);
        } else {
            System.Debug('##>>> PTLCityMatchFromCode.BeforeUpdate : BYPASS <<< run by ' + UserInfo.getName());
        }

        System.Debug('##>>> PTLCityMatchFromCode.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> PTLCityMatchFromCode.BeforeUpdate : FALSE TRIGGER <<<');
    }
}