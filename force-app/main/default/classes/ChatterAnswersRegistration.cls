/**
 * This class has been generated to allow customization of Account creation for Chatter Answers Portal Users.
 * Chatter Answers requires that this class exist and implement ChatterAnswers.AccountCreator, renaming the class
 *   or removing the interface implementation is prohibited. */
public class ChatterAnswersRegistration implements ChatterAnswers.AccountCreator {
    public String createAccount(String firstname, String lastname, Id siteAdminId) {
         // Erwan 20170922 : Hardcoded data to remove if functionality is used in the future
         Account a = new Account(name = firstname + ' ' + lastname, ownerId = siteAdminId, Mobile_Phone_Number__c = '0616060606', Email__c = 'test.email@test.org');
         insert a;
         return a.Id;
    }
}