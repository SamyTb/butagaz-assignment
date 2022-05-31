public class GDB_UserMgr {

    /**
     * createExternalUserB2B create a external user after a new Account B2B
     *
     * @param Contact
     *
     * @return Boolean
     */
    public static void createExternalUserB2B(List<Contact> contacts) {
        List<User> externalUsers = new List<User>();

        if (contacts == null) {
            return;
        }

        try {
            for (Contact c: contacts) {
                //Create user
                User newUser = new User(
                    contactId = c.Id,
                    username = c.Email,
                    firstname = (c.FirstName != null ? c.FirstName : c.LastName),
                    lastname = c.LastName,
                    email = c.Email,
                    communityNickname = c.LastName + '_' + Math.random(),
                    profileId = GDB_Constants_B2B.B2BUserTypeId,
                    alias = string.valueof((c.FirstName != null ? c.FirstName : c.LastName).substring(
                        0, 1) + c.LastName.substring(0, 1)),
                    emailencodingkey = 'UTF-8',
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    Bypass_Validation_Rules__c = true
                );

                externalUsers.add(newUser);
            }
            insert externalUsers;
    } catch (Exception e) {
        System.debug(System.LoggingLevel.ERROR, e.getMessage());
    }
}
}