@isTest
public class AP_Announcements_Test {
    public static Integer userCount = 0;

    public static List<String> getUserProfiles() {
        List<String> output = new List<String>();
        output.add('Butagaz Chatter Only');
        output.add('Butagaz Sales Administrator (RAV)');
        output.add('Butagaz Standard User');
        output.add('Butagaz System Administrator');
        output.add('Butagaz Team Lead (TL)');
        return output;
    }
    
    public static List<Announcement__c> loadTestAnnouncements() {
        List<Announcement__c> testAnnouncements = new List<Announcement__c>();
        
        Announcement__c activeAnnouncement0 = new Announcement__c(
            Name = 'Active Announcement 0',
            Active__c = true,
            Body__c = 'Active Announcement 0, body'
        );
        insert activeAnnouncement0;
        Announcement__c activeAnnouncement1 = new Announcement__c(
            Name = 'Active Announcement 1',
            Active__c = true,
            Body__c = 'Active Announcement 1, body'
        );
        insert activeAnnouncement1;
        Announcement__c inactiveAnnouncement0 = new Announcement__c(
            Name = 'Inactive Announcement 0',
            Active__c = false,
            Body__c = 'Inactive Announcement 0, body'
        );
        insert inactiveAnnouncement0;
        
        testAnnouncements.add(activeAnnouncement0);
        testAnnouncements.add(activeAnnouncement1);
        testAnnouncements.add(inactiveAnnouncement0);
        
        System.debug('Oldest Active Announcement ID: ' + String.valueOf(activeAnnouncement0.Id));
        System.debug('Latest Active Announcement ID: ' + String.valueOf(activeAnnouncement1.Id));
        System.debug('Inactive Announcement ID: ' + String.valueOf(inactiveAnnouncement0.Id));

        return testAnnouncements;
    }
    
    private static List<Id> GetIdsFromList(List<sObject> lObjects) {
        List<Id> output = new List<Id>();
        for (sObject oObject : lObjects) {
            output.add(oObject.Id);
        }
        return output;
    }
    
    private static User CreateTestUser(String name, String profileName) {
        User user = new User();
        user.Username = 'userTest_' + name + '@test.fr';
        user.LastName = name;
        user.FirstName = name;
        user.Email = name + '@test.fr';
        user.Alias = name;
        user.CommunityNickname = name;
        user.IsActive = true;
        user.TimeZoneSidKey= 'Europe/Paris';
        user.LocaleSidKey = 'fr_FR_EURO';
        user.LanguageLocaleKey = 'fr';
        user.EmailEncodingKey = 'ISO-8859-1';
        Profile profile = [SELECT Id FROM Profile WHERE Name =:profileName  LIMIT 1];
        user.ProfileId = profile.Id;
        return user;
    }
    
    public static List<User> loadTestUsers(String profileName){
        List<User> testUsers = new List<User>();
        
        User user0 = AP_Announcements_Test.CreateTestUser(
            String.valueOf(AP_Announcements_Test.userCount), 
            profileName
        );
        AP_Announcements_Test.userCount ++;
        User user1 = AP_Announcements_Test.CreateTestUser(
            String.valueOf(AP_Announcements_Test.userCount), 
            profileName
        );
        AP_Announcements_Test.userCount ++;
        
        testUsers.add(user0);
        testUsers.add(user1);
        
        insert testUsers;
        
        return testUsers;
    }

    
    public static testmethod void  testRecordExists() {
        List<Announcement__c> testAnnouncements = AP_Announcements_Test.loadTestAnnouncements();
        Test.startTest();
        for (String profileName : AP_Announcements_Test.getUserProfiles()){
            System.Debug('Running for [testRecordExists] as profile [' + profileName + ']');
            AP_Announcements_Test.testRecordExists(
                profileName,
                testAnnouncements,
                AP_Announcements_Test.loadTestUsers(profileName)
            );
        }
        Test.stopTest();
    }

    public static void testRecordExists(
        String profileName, 
        List<Announcement__c> testAnnouncements,
        List<User> testUsers
    ) {

        User user0 = testUsers.get(0);
        Announcement__c announcement0 = testAnnouncements.get(0);
        Announcement__c announcement1 = testAnnouncements.get(1);
        
        
        Announcement_Seen__c announcementSeenTest = new Announcement_Seen__c (
            announcement__c = announcement0.Id,
            user__c = user0.Id
        );
        insert announcementSeenTest;
        
        //Test.startTest(); 
        System.runAs(user0) {
            System.assertEquals(AP_Announcements_Utilities.recordExists(announcement0.Id, user0.Id), true);
            System.assertEquals(AP_Announcements_Utilities.recordExists(announcement1.Id, user0.Id), false);
        }
        //Test.stopTest();
    }
    
    public static testmethod void  testSingleUserFull(){
        List<Announcement__c> testAnnouncements = AP_Announcements_Test.loadTestAnnouncements();
        Test.startTest();
        for (String profileName : AP_Announcements_Test.getUserProfiles()){
            System.Debug('Running for [testSingleUserFull] as profile [' + profileName + ']');
            AP_Announcements_Test.testSingleUserFull(
                profileName,
                testAnnouncements,
                AP_Announcements_Test.loadTestUsers(profileName)
            );
        }
        Test.stopTest();
    }
    
    public static void testSingleUserFull(
        String profileName,
        List<Announcement__c> testAnnouncements,
        List<User> testUsers
    ) {
        System.debug('Started testSingleUserFull');
        
        
        
        // Get the list of active announcements so we can check against it.
        // Ordered from latest to earliest (we're _reversing_ the order)
        List<Announcement__c> activeTestAnnouncements = new List<Announcement__c>();
        activeTestAnnouncements.add(testAnnouncements.get(1));
        activeTestAnnouncements.add(testAnnouncements.get(0));
        
        Announcement__c latestActiveAnnouncement = testAnnouncements.get(1);
        
        System.debug('Loaded Data for testSingleUserFull');
        System.debug('Latest Announcement ID: ' +  String.valueOf(latestActiveAnnouncement.Id));
        
        // Create the two "Latest announcements" pages we'll use. 
        VFC_Announcements_Latest testLAC0 = new VFC_Announcements_Latest();
        VFC_Announcements_Latest testLAC1 = new VFC_Announcements_Latest();
        
        // Let's initialize the announcement page
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(latestActiveAnnouncement); 
        VFC_Announcements_Detail testACE = new VFC_Announcements_Detail(stdController);
        
        // Set the users on the pages.
        User user0 = testUsers.get(0);
        /*testLAC0.setUserId(user0.Id);
        testLAC1.setUserId(user0.Id);
        testACE.setUserId(user0.Id);*/
        
       
        
        //Test.startTest(); // We're not really testing the limits here.
        System.runAs(user0) {
            // First, the user visits the latest announcements page
            // Do we get the active announcements on the page?
            System.assertEquals(
                AP_Announcements_Test.GetIdsFromList(activeTestAnnouncements),
                AP_Announcements_Test.GetIdsFromList(testLAC0.getLAnnouncements())
                
            ); 
            // Is the latest announcement the right one?
            System.assertEquals(latestActiveAnnouncement.Id, testLAC0.getLatestAnnouncement().Id);
            // Are we displaying the PopUp?
            System.assertEquals(true, testLAC0.evalDisplay());
            System.assertEquals(true, testLAC0.getDisplayPopUp());
            
            // Now, the user visits the announcement
            testACE.recordAnnouncementSeen();
            
            // Finally, let's visit the Latest Announcements Page again.
            // We saw the latest announcement, so we should get no display. 
            System.assertEquals(false, testLAC1.evalDisplay());
            System.assertEquals(false, testLAC1.getDisplayPopUp());
        }
        //Test.stopTest();
    }
    
    public static testmethod void  testAnnouncementExists(){
        List<Announcement__c> testAnnouncements = AP_Announcements_Test.loadTestAnnouncements();
        Test.startTest();
        for (String profileName : AP_Announcements_Test.getUserProfiles()){
            System.Debug('Running for [testAnnouncementExists] as profile [' + profileName + ']');
            AP_Announcements_Test.testAnnouncementExists(
                profileName,
                testAnnouncements,
                AP_Announcements_Test.loadTestUsers(profileName)
            );
        }
        Test.stopTest();
    }
    
    public static void testAnnouncementExists(
        String profileName,
        List<Announcement__c> testAnnouncements,
        List<User> testUsers
    ) {
        User user0 = testUsers.get(0);
        
        // Initialize the empty record & the page
        Announcement__c emptyAnnouncement = new Announcement__c(); //This is a record that does not exist.
        ApexPages.StandardController emptyStdController = new ApexPages.StandardController(emptyAnnouncement);
        VFC_Announcements_Detail testEmptyACE = new VFC_Announcements_Detail(emptyStdController);
        
        // Load an actual record and the page
        Announcement__c actualAnnouncement = testAnnouncements.get(0); //This is record0; it exists. 
        ApexPages.StandardController actualStdController = new ApexPages.StandardController(actualAnnouncement);
        VFC_Announcements_Detail testActualACE = new VFC_Announcements_Detail(actualStdController);
        
        /*testEmptyACE.setUserId(user0.Id);
        testActualACE.setUserId(user0.Id);*/
        
        //Test.startTest();
        // This page should have no record
        System.runAs(user0) {
            System.assertEquals(false, testEmptyACE.getAnnouncementExists());
            
            // This page should have a record
            System.assertEquals(true, testActualACE.getAnnouncementExists());
        }
        //Test.stopTest();
        
    }
    
    public static testmethod void testMultipleUserFull() {
        List<Announcement__c> testAnnouncements = AP_Announcements_Test.loadTestAnnouncements();
        Test.startTest();
        for (String profileName : AP_Announcements_Test.getUserProfiles()){
            System.Debug('Running for [testMultipleUserFull] as profile [' + profileName + ']');
            AP_Announcements_Test.testMultipleUserFull(
                profileName,
                testAnnouncements,
                AP_Announcements_Test.loadTestUsers(profileName)
            );
        }
        Test.stopTest();
    }
    
    public static void testMultipleUserFull(
        String profileName,
        List<Announcement__c> testAnnouncements,
        List<User> testUsers
        
    ) {
        Announcement__c latestAnnouncement = testAnnouncements.get(1); //The latest one. 
        
        VFC_Announcements_Latest testLAC0 = new VFC_Announcements_Latest();
        VFC_Announcements_Latest testLAC1 = new VFC_Announcements_Latest();
        
        User user0 = testUsers.get(0);
        User user1 = testUsers.get(1);
        
        /*testLAC0.setUserId(user0.Id);
        testLAC1.setUserId(user1.Id);*/
        
        Announcement_Seen__c announcementSeenTest = new Announcement_Seen__c (
            announcement__c = latestAnnouncement.Id,
            user__c = user0.Id
        );
        insert announcementSeenTest;
        
        //Test.startTest();
        System.runAs(user0) {
            System.assertEquals(false, testLAC0.evalDisplay());
        }
        System.runAs(user1) {
            System.assertEquals(true, testLAC1.evalDisplay());
        }
        //Test.stopTest();
    }
}