public with sharing class GDB_AddressMgr {
    /**
     * getCitiesForZipCode This method returns all matching cities based on the given zip code
     *
     * @param {String} zipCode
     *
     * @returns {List<String>}
     *
     **/
    public static List<String> getCitiesForZipCode(String zipCode) {
        //List<String> cities = new List<String>();

        if(zipCode == null || zipCode == '') {
            return new List<string>();
        }
        Map<string, String> avoidDuplicates = new Map<string, String>(); 

        List<City_Postal_Code__c> cityPostalCodes = [
            SELECT
            Postal_Code__c,
            City__r.Name
            FROM
            City_Postal_Code__c
            WHERE Postal_Code__c = :zipCode
        ];

        for(City_Postal_Code__c cpc : cityPostalCodes) {
            if(!avoidDuplicates.containsKey(cpc.City__r.Name)){
            	avoidDuplicates.put(cpc.City__r.Name, cpc.City__r.Name);
            }
        }

        return avoidDuplicates.values();
    }
}