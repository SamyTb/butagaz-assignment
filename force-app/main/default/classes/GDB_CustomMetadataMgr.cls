public with sharing class GDB_CustomMetadataMgr {
    /**
     * The SINGLETON handle to the instance 
     */
    private static GDB_CustomMetadataMgr self;
    private GDB_Org_Settings__mdt cOrg;
    private Organization o;
    
    /**
     * Initialize the SINGLETON instance or return it if already exists
     *
     * @returns {SSCSiteCustomSettingHelper}
     */
    public static GDB_CustomMetadataMgr self() {
        if (self == null) {
            self = new GDB_CustomMetadataMgr();
        }
        
        return self;
    }
    
    private GDB_CustomMetadataMgr() {
        o = [SELECT Id, InstanceName, IsSandbox FROM Organization LIMIT 1];
        if(o != null && o.InstanceName != null) {
            String instanceName = o.InstanceName.indexOf('EU') == 0 ? 'EU' : o.InstanceName;
            cOrg = [SELECT DeveloperName,gdb_b2b_community_name__c,gdb_b2b_community_path_prefix__c,
                    gdb_b2b_domain_name__c,gdb_b2b_user_type__c,gdb_community_name__c,gdb_b2b_account_type_id__c,
                    gdb_community_path_prefix__c,gdb_domain_name__c,gdb_instance_name__c,gdb_bv_deployment_zone__c,
                    gdb_type_account_google_map__c, gdb_google_map_center_latitude__c, gdb_google_map_center_longitude__c
                     FROM GDB_Org_Settings__mdt 
                     WHERE gdb_instance_name__c = :instanceName 
                     LIMIT 1];
        }
    }
    
    /**
    * Return current instance name
    * @return {String}
    */
    public String getCurrentInstanceName() {
        return cOrg.DeveloperName;
    }
    
    /**
    * Return community name
    * @return {String}
    */
    public String getCommunityName() {
        return cOrg.gdb_community_name__c;
    }
    
    /**
    * Return B2B community name
    * @return {String}
    */
    public String getCommunityNameB2B() {
        return cOrg.gdb_b2b_community_name__c;
    }
    
    /**
    * Return domain name
    * @return {String}
    */
    public String getDomainName() {
        return cOrg.gdb_domain_name__c;
    }
    
    /**
    * Return B2B domain name
    * @return {String}
    */
    public String getDomainNameB2B() {
        return cOrg.gdb_b2b_domain_name__c;
    }
    
    /**
    * Return community path prefix
    * @return {String}
    */
    public String getCommunityPathPrefix() {
        return cOrg.gdb_community_path_prefix__c;
    }
    
    /**
    * Return b2b community path prefix
    * @return {String}
    */
    public String getCommunityPathPrefixB2B() {
        return cOrg.gdb_b2b_community_path_prefix__c;
    }
    
    /**
    * Return b2b user type
    * @return {String}
    */
    public String getB2BUserType(){
        return cOrg.gdb_b2b_user_type__c;
    }
    
    /**
    * Return B2B Account Type ID
    * @return {String}
    */
    public String getB2BAccountType(){
        return cOrg.gdb_b2b_account_type_id__c; 
    }
    
    /**
    * Return BV Deployment Zone
    * @return {String}
    */
    public String getBvDeploymentZone(){
        return cOrg.gdb_bv_deployment_zone__c;
    }

    /**
    * Return account type for google map
    * @return {String}
    */
    public String getAccountTypeGoogleMap(){
        return cOrg.gdb_type_account_google_map__c;
    }

    /**
    * Return google map center latitude
    * @return {String}
    */
    public String getGoogleMapCenterLatitude(){
        return cOrg.gdb_google_map_center_latitude__c;
    }

    /**
    * Return google map center longitude
    * @return {String}
    */
    public String getGoogleMapCenterLongitude(){
        return cOrg.gdb_google_map_center_longitude__c;
    }

    /**
     * Return is current org is a sandbox or not
     * @return   {Boolean}
     */ 
    public Boolean isSandbox() {
        return o.IsSandbox;
    }
}