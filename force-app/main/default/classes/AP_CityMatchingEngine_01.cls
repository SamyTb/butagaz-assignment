public class AP_CityMatchingEngine_01 {
    /*
        This object is used to convert a CityCode (INSEE) + PostalCode (La Poste) couple to a 
        City_Postal_Code__c object that offers an appropriate match.

        An appropriate match is defined as follows:
            + INSEE  Code matches
            + Postal Code matches (preferably), or is the "closest" to the one input (Levenshtein distance)

        Behavior in case absolutely no matching object is found is not defined at the moment, so this method will
        leave the object untouched in that case.
    */

    String cityCodeField; // Find the City
    String postalCodeField; // Choose the best postal code
    String cityNameField; // Passed by SAP, backup and clear if we find a match
    String cityPostalCodeField; // Fill in the new city
    String sapCityCodeField; // Back up the City Code from SAP
    String sapPostalCodeField; // Back up the Postal Code from SAP
    String sapCityNameField; // Back up the City Name from SAP
    Boolean allowCEDEX; // Allow CEDEX?
    Integer MAX_MATCH_DISTANCE = 10000; // Infinity? Something. It's just a huge number.

    public AP_CityMatchingEngine_01(
        String cityCodeField,    String postalCodeField,    String cityNameField, 
        String sapCityCodeField, String sapPostalCodeField, String sapCityNameField,
        String cityPostalCodeField,
        Boolean allowCEDEX
    ){
        this.cityCodeField        = cityCodeField;
        this.postalCodeField      = postalCodeField;
        this.cityNameField        = cityNameField;
        this.cityPostalCodeField  = cityPostalCodeField;
        this.sapCityCodeField     = sapCityCodeField;
        this.sapPostalCodeField   = sapPostalCodeField;
        this.sapCityNameField     = sapCityNameField;
        this.allowCEDEX           = allowCEDEX;
    }

    private Set<String> getCityCodes(List<SOBject> lSObjects){
        // Return the City Codes used in the Objects being assigned

        Set<String> sCityCodes = new Set<String>();
        for (SOBject oSObject : lSObjects){
            sCityCodes.add(String.valueOf(oSObject.get(this.cityCodeField)));
        }
        return sCityCodes;
    }

    private Map<String, Map<String, City_Postal_Code__c>> getLookupMap(Set<String> sCityCodes){
        /*
            Provide a lookup Map CityINSEECode => PostalCode => MatchingObject
        */

        // Query the needed objects
        List<City_Postal_Code__c> lMatchingCodes;

        if (this.allowCEDEX){
            lMatchingCodes= [
                SELECT Id, Postal_Code__c, City__r.INSEE_Code__c 
                FROM City_Postal_Code__c
                WHERE City__r.INSEE_Code__c IN :sCityCodes
            ]; 
        } else {
            lMatchingCodes= [
                SELECT Id, Postal_Code__c, City__r.INSEE_Code__c 
                FROM City_Postal_Code__c
                WHERE (City__r.INSEE_Code__c IN :sCityCodes) AND (Code_Type__c = 'M')
            ]; 
        }
        System.debug('[CityMatchingEngine.getLookupMap] Matching Composite Objects: ' + lMatchingCodes);

        // Arrange them into a practical Map
        Map<String, Map<String, City_Postal_Code__c>> mLookupMap = new Map<String, Map<String, City_Postal_Code__c>>();
        for (City_Postal_Code__c oMatchingCode : lMatchingCodes){
            if (!mLookupMap.containsKey(oMatchingCode.City__r.INSEE_Code__c)){
                mLookupMap.put(oMatchingCode.City__r.INSEE_Code__c, new Map<String, City_Postal_Code__c>());
            }
            mLookupMap.get(oMatchingCode.City__r.INSEE_Code__c).put(oMatchingCode.Postal_Code__c, oMatchingCode);
        }
        System.debug('[CityMatchingEngine.matchCitiesFromCode] Search Table: ' + mLookupMap);

        return mLookupMap;
    }

    private void matchSObject(SOBject oSObject, Map<String, Map<String, City_Postal_Code__c>> mLookupMap){
        /* 
            Map a SObject to the appropriate City Postal Code lookup 
        */

        // Loop vars
        Integer currentMatchDistance;
        City_Postal_Code__c bestMatchObject;

        // Intialization
        Integer bestMatchDistance  = this.MAX_MATCH_DISTANCE;
        String searchedINSEECode  = String.valueOf(oSObject.get(this.cityCodeField));
        String searchedPostalCode = String.valueOf(oSObject.get(this.postalCodeField));
        Map<String, City_Postal_Code__c> mCandidates        = mLookupMap.get(searchedINSEECode);

        System.debug('[CityMatchingEngine.matchSObject] ID:[' + oSObject.Id + ']');
        System.debug('[CityMatchingEngine.matchSObject] OBJ:[' + oSObject + ']');
        System.debug('[CityMatchingEngine.matchSObject] CC:[' + searchedINSEECode  + ']');
        System.debug('[CityMatchingEngine.matchSObject] PC:[' + searchedPostalCode + ']');

        // Handle unexpected conditions
        if (searchedPostalCode == null){
            System.debug('[CityMatchingEngine.matchSObject] No postal code submitted!'); 
            searchedPostalCode = ''; // We don't really care, just match one!
        }

        if (mCandidates == null){
            System.debug('[CityMatchingEngine.matchSObject] No postal code matched the City Code!'); 
            mCandidates = new Map<String, City_Postal_Code__c>(); 
            // We still want to pretend to process the records so that the clean up actions are taken.
        }
        
        if (searchedINSEECode == null){
            System.debug('[CityMatchingEngine.matchSObject] No INSEE code was provided!'); 
            // In that case, we'll just not touch anything!
        } else {
            System.debug('[CityMatchingEngine.matchSObject] Candidates:[' + mCandidates.keySet() + ']');
            for (String candidatePostalCode : mCandidates.keySet()){
                currentMatchDistance = searchedPostalCode.getLevenshteinDistance(candidatePostalCode);
                if (currentMatchDistance < bestMatchDistance){
                    System.debug('[CityMatchingEngine.matchSObject] Accepted Candidate: [' + candidatePostalCode + ']');
                    System.debug('[CityMatchingEngine.matchSObject] Accepted Distance: [' + currentMatchDistance + ']');
                    System.debug('[CityMatchingEngine.matchSObject] Former Candidate: [' + oSObject.get(this.cityCodeField) + ']');
                    System.debug('[CityMatchingEngine.matchSObject] Former Distance: [' + bestMatchDistance + ']');

                    oSObject.put(this.cityPostalCodeField, mCandidates.get(candidatePostalCode).Id);
                    bestMatchDistance = currentMatchDistance;
                } else {
                    System.debug('[CityMatchingEngine.matchSObject] Rejected Candidate: [' + candidatePostalCode + ']');
                    System.debug('[CityMatchingEngine.matchSObject] Rejected Distance: [' + currentMatchDistance + ']');
                }
            }

            // We're in the case where a lookup replacement was tried, clean up after us!

            if (bestMatchDistance < this.MAX_MATCH_DISTANCE){
                // We did find a match!
                // Copy the data to the SAP fields
                oSObject.put(this.sapCityCodeField,   oSObject.get(this.cityCodeField));
                oSObject.put(this.sapCityNameField,   oSObject.get(this.cityNameField));
                oSObject.put(this.sapPostalCodeField, oSObject.get(this.postalCodeField));
                // Clear the fields
                oSObject.put(this.cityCodeField,   '');
                oSObject.put(this.cityNameField,   '');
                oSObject.put(this.postalCodeField, '');
            } else {
                // We didn't find a match, ensure the field is empty, you can never know.
                oSObject.put(this.cityPostalCodeField, null);
            }
        }
    }

    public void match(List<SOBject> lSObjects){
        /*  
            Entry point, call the engine with a list of objects to be matched
        */

        // Find the CityPostalCode objects and try to match them
        Set<String> sCityCodes = this.getCityCodes(lSObjects);
        System.debug('[CityMatchingEngine.matchCitiesFromCode] City codes: ' + sCityCodes);

        // This will map INSEE CityCode => Postal Code => MatchingObject
        Map<String, Map<String, City_Postal_Code__c>> mLookupMap = this.getLookupMap(sCityCodes);
        System.debug('[CityMatchingEngine.matchCitiesFromCode] Search Table: ' + mLookupMap);

        // Do the mapping for real
        for (SOBject oSObject : lSObjects){
            this.matchSObject(oSObject, mLookupMap);
        }

        // Output some status
        System.debug('[CityMatchingEngine.matchCitiesFromCode] Execution finished.');
        System.debug('[CityMatchingEngine.matchCitiesFromCode] Number of records: [' + lSObjects.size()  + ']');
        System.debug('[CityMatchingEngine.matchCitiesFromCode] Script statements: [' + Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements() + ']');
    }
}