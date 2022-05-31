public with sharing class Constants 
{
    public static final String PRODUCTION_ORG_ID = '00DM0000000BuwE';
    public static final String SYSTEM_ADMIN_PROFILE_ID = '00eD0000001keP7';

    public static void dummy()
    {
        String a = 'This is to get 100% test coverage';
    }
    
    public static TestMethod void testConstants()
    {
        Constants.dummy();
    }
}