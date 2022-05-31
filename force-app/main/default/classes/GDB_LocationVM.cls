public with sharing class GDB_LocationVM {
    /**
     * Location : Object for google map
     */
    public class Location{
        @AuraEnabled 
        public String icon{get;set;} 
        @AuraEnabled 
        public String title{get;set;} 
        @AuraEnabled
        public String description{get;set;} 
        @AuraEnabled 
        public GeoLocation location{get;set;} 
    }

    /**
     * GeoLocation : Object for location object
     */
    public class GeoLocation{
        @AuraEnabled 
        public String Street{get;set;}
        @AuraEnabled 
        public String PostalCode{get;set;}
        @AuraEnabled 
        public String City{get;set;}
        @AuraEnabled 
        public String Country{get;set;}
        @AuraEnabled 
        public String Latitude{get;set;} 
        @AuraEnabled 
        public String Longitude{get;set;} 
    }
}