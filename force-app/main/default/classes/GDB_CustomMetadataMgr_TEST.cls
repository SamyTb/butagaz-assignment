@isTest
private class GDB_CustomMetadataMgr_TEST {
    
    @isTest
    static void testCustomMetadata(){
        GDB_CustomMetadataMgr customMetadata = GDB_CustomMetadataMgr.self();

        System.assertNotEquals(null, customMetadata.getCurrentInstanceName());
        System.assertNotEquals(null, customMetadata.getCommunityName());
        System.assertNotEquals(null, customMetadata.getCommunityNameB2B());
        System.assertNotEquals(null, customMetadata.getDomainName());
        System.assertNotEquals(null, customMetadata.getDomainNameB2B());
        String communityPathPrefix = customMetadata.getCommunityPathPrefix();
        String communityPathPrefixB2B = customMetadata.getCommunityPathPrefixB2B();
        System.assertNotEquals(null, customMetadata.getB2BUserType());
        System.assertNotEquals(null, customMetadata.getBvDeploymentZone());
        System.assertNotEquals(null, customMetadata.IsSandbox());
    }
}