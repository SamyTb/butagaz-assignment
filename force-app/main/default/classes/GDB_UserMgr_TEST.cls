@isTest
private class GDB_UserMgr_TEST {

    @isTest
    static void testCreateExternalUserB2BWithNull() {
        GDB_UserMgr.CreateExternalUserB2B(null);
    }

    @isTest
    static void testCreateExternalUserB2BWithBadValue() {
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(
                                        Account = GDB_TestDataFactory.getGlobalAccount(),
                                        email = 'test@yopmail.com',
                                        Firstname = 'test',
                                        LastName = 'test',
                                        Street_Number__c = '14 route de briare',
                                        Postal_Code__c = '45250',
                                        City__c = 'Ousson sur Loire',
                                        Country__c = 'FR'
                                      );
        insert contact;

        contacts.add(contact);

        GDB_UserMgr.createExternalUserB2B(contacts);
    }

    @isTest
    static void testCreateExternalUserB2BWithGoodValue(){
        GDB_TestDataFactory.createCustomSettings();
        List<Contact> contacts = new List<Contact>();

        Account account = new Account(
                                        RecordTypeId = GDB_Constants_B2B.accountRecordTypeId,
                                        Name = 'test',
                                        Email__c = 'test@yopmail.com',
                                        Mobile_Phone_Number__c = '0606060606'
                                      );
        insert account;

        Contact contact = new Contact(
                                        Account = account,
                                        email = 'test@yopmail.com',
                                        Firstname = 'test',
                                        LastName = 'test',
                                        Street_Number__c = '14 route de briare',
                                        Postal_Code__c = '45250',
                                        City__c = 'Ousson sur Loire',
                                        Country__c = 'FR'
                                      );
        
        insert contact;

        contacts.add(contact);

        GDB_UserMgr.createExternalUserB2B(contacts);
    }
}