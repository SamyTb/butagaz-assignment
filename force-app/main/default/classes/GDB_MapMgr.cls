public with sharing class GDB_MapMgr {

    /**
     * getAccountType Get all type account for Google Map
     * @return {map<String,String>}
     */
    @AuraEnabled
    public static map<String,String> getAccountType() {
        return GDB_Constants.channelAccount;
    }

    /**
     * getAllLocations Get all location for the google map
     * @param {List<String> } filter
     * @return {Map<String, List<GDB_LocationVM.Location>>}
     */
    @AuraEnabled
    public static Map<String, List<GDB_LocationVM.Location>> getAllLocations(List<String> filter) {
        List<Account> allAccounts = new List<Account>();
        List<GDB_LocationVM.Location> allLocations = new List<GDB_LocationVM.Location>();
        Map<String, List<GDB_LocationVM.Location>> mapResult = new map<String, List<GDB_LocationVM.Location>>();
        List<City__c> allCities = new List<City__c>();

        // Get all account with type of RE only and available on map
        allAccounts = GDB_AccountMgr.getPointsOfSales(filter);

        // Get Cities Name for make location object
        Map<ID, City__c> mapCitiesName = new Map<ID, City__c>([SELECT Id, Name FROM City__c]);

        // Create Location object with Account information
        for(Account acc :allAccounts){
            // Make information geolocation
            GDB_LocationVM.GeoLocation geoInfo = new GDB_LocationVM.GeoLocation();
            geoInfo.Street = ((acc.Street_N__c != null ? acc.Street_N__c : '' ) + (acc.Street_type__c != null ? ' ' + acc.Street_type__c : '') + (acc.Street_name__c !=  null ? ' ' + acc.Street_name__c : '')).trim().toLowerCase();
            geoInfo.PostalCode = acc.City_Postal_Code__r.Postal_Code__c;
            geoInfo.City =  mapCitiesName.containsKey(acc.City_Postal_Code__r.City__c) ? geoInfo.PostalCode + ', ' + mapCitiesName.get(acc.City_Postal_Code__r.City__c).Name.toUpperCase() : null;
            geoInfo.Country = acc.Country__c ;

            // Make location object
            GDB_LocationVM.Location locDetail = new GDB_LocationVM.Location();
            if(acc.Channel__c == GDB_Constants.channelAccount.get('PR')) {
                locDetail.icon = 'standard:service_territory_member'; 
            }
            else {
                locDetail.icon = 'standard:address';
            }
            locDetail.title = acc.Name;
            locDetail.description = geoInfo.Street +' '+ geoInfo.City;
            locDetail.location = geoInfo;
            allLocations.add(locDetail);
        }

        // Make center of map
        List<GDB_LocationVM.Location> listCenter = new List<GDB_LocationVM.Location>();
        GDB_LocationVM.GeoLocation geoInfoCenter = new GDB_LocationVM.GeoLocation();
        GDB_LocationVM.Location locDetailcenter = new GDB_LocationVM.Location();
        geoInfoCenter.latitude = GDB_CustomMetadataMgr.self().getGoogleMapCenterLatitude();
        geoInfoCenter.longitude = GDB_CustomMetadataMgr.self().getGoogleMapCenterLongitude();
        locDetailcenter.location = geoInfoCenter;
        listCenter.add(locDetailcenter);

        mapResult.put('Center', listCenter);
        mapResult.put('Locations', allLocations);
        return mapResult;
    }
}