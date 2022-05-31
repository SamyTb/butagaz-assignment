public class TestUtilitiesOrganization {
    public static Activity_Domain__c createActivityDomain(String name) {
        Activity_Domain__c newDomain = new Activity_Domain__c(
            Name = name
        );
        return newDomain;
    }
    
    public static Organization__c createOrganization(
        String name,
        String MarketType,
        String projectType,
        Activity_Domain__c activityDomain
        
    ) {
        Organization__c newOrg = new Organization__c(
            Name = name,
            Market_Type__c = MarketType,
            Activity_Domain__c = activityDomain.Id,
            Project_Type__c = projectType
        );
        return newOrg;
    }
    
    public static Organization_Node__c createNode(
        Integer approvalLevel, Integer latitudeLevel,
        Organization__c organization
    ) {
        // USER: NO
        // Manager Node: NO
        Organization_Node__c newNode = new Organization_Node__c(
            Approval_Level__c = approvalLevel, Latitude_Level__c = latitudeLevel,
            Organization__c = organization.Id
        );
        return newNode;
    }
    
    public static Organization_Node__c createNode(
        Integer approvalLevel, Integer latitudeLevel,
        Organization__c organization, User user
    ) {
        // USER: Yes,
        // Manager Node: NO
        Organization_Node__c newNode = new Organization_Node__c(
            Approval_Level__c = approvalLevel, Latitude_Level__c = latitudeLevel,
            Organization__c = organization.Id, User__c = user.Id
        );
        return newNode;
    }
    
    public static Organization_Node__c createNode(
        Integer approvalLevel, Integer latitudeLevel,
        Organization__c organization, Organization_Node__c managerNode
    ) {
        // User: NO
        // Manager Node: YES
        Organization_Node__c newNode = new Organization_Node__c(
            Approval_Level__c = approvalLevel, Latitude_Level__c = latitudeLevel,
            Organization__c = organization.Id, Manager_Organization_Node__c = managerNode.Id
        );
        return newNode;
    }
    
    public static Organization_Node__c createNode(
        Integer approvalLevel, Integer latitudeLevel,
        Organization__c organization, Organization_Node__c managerNode,
        User user
    ) {
        // User: YES
        // Manager Node: YES
        Organization_Node__c newNode = new Organization_Node__c(
            Approval_Level__c = approvalLevel, Latitude_Level__c = latitudeLevel,
            Organization__c = organization.Id, User__c = user.Id,
            Manager_Organization_Node__c = managerNode.Id
        );
        return newNode;
    }
    
    public static User CreateTestUser(String name) {
        return TestUtilitiesOrganization.CreateTestUser(name, 'Butagaz Standard User');
    }
    
    public static User CreateTestUser(String name, String profileName) {
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
        user.Bypass_Validation_Rules__c = true;
        Profile profile = [SELECT Id FROM Profile WHERE Name =:profileName  LIMIT 1];
        user.ProfileId = profile.Id;
        return user;
    }
    
    public static void bypassUserRules(){
        Id userId = UserInfo.getUserId();
        User user = [SELECT Id, Bypass_Apex_Triggers__c FROM User WHERE Id=:userId];
        String currentBypass = user.Bypass_Apex_Triggers__c;
        user.Bypass_Apex_Triggers__c = user.Bypass_Apex_Triggers__c + ';OrganizationNode.validateUniqueUser;';
        update user;
    }
}