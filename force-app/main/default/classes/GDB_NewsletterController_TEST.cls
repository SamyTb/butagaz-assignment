/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GDB_NewsletterController_TEST { 

	@isTest
    static void testSaveMailNewsletterWithoutParam() {
        Map<String, String> detailsForm = new Map<String, String>();
        Map<String, String> ret = GDB_NewsletterController.saveMailNewsletter(detailsForm);
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertNotEquals(0, ret.size(), 'Return value should not be null');
    }
        
    @isTest
    static void testSaveMailNewsletterWithParamInvalide() {
        Map<String, String> detailsForm = new Map<String, String>();
        detailsForm.put('email', 'mailNonValide');
        Map<String, String> ret = GDB_NewsletterController.saveMailNewsletter(detailsForm);
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertNotEquals(0, ret.size(), 'Return value should not be null');
    }
            
    @isTest
    static void testSaveMailNewsletterWithParamValide() {
        Map<String, String> detailsForm = new Map<String, String>();
        detailsForm.put('email', 'mail@valide.fr');
        Map<String, String> ret = GDB_NewsletterController.saveMailNewsletter(detailsForm);
        System.assertNotEquals(null, ret, 'Return value should not be null');
        System.assertEquals('Inscription à la newsletter avec succès.', ret.get('message'), 'Return value should be true');
    } 
    @isTest
    static void testSaveMailNewsletterWithMailAlreadySave() {
        Map<String, String> detailsForm = new Map<String, String>();
        detailsForm.put('email', 'mail@valide.fr');
        Map<String, String> ret2 = GDB_NewsletterController.saveMailNewsletter(detailsForm);
        Map<String, String> ret = GDB_NewsletterController.saveMailNewsletter(detailsForm);
        Newsletter_Subscription__c souscription = [SELECT OwnerId, Name, Email__c FROM Newsletter_Subscription__c WHERE Email__c = 'mail@valide.fr'];
        System.assertEquals('mail@valide.fr', souscription.Email__c, 'Return value should be true');
        System.assertEquals('Vous étes déjà inscrit à la newsletter.', ret.get('message'), 'Return value should be true');
    }
}