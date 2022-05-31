public with sharing class GDB_Google_MapController {

    /**
     * getAccountType Get all type account for Google Map
     * @return {map<String,String>}
     */
    @AuraEnabled
    public static map<String,String> getAccountType() {
        return GDB_MapMgr.getAccountType();
    }

    /**
     * getAllLocations Get all location for the google map
     * @param {List<String> } filter
     * @return {Map<String, List<GDB_LocationVM.Location>>}
     */
    @AuraEnabled
    public static Map<String, List<GDB_LocationVM.Location>> getAllLocations(List<String> filter) {
        return GDB_MapMgr.getAllLocations(filter);
    }
}