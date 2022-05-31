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
public class AP02_Account_Test { 
    
    private static Integer TEST_FACTOR = 1;

    static testMethod void myUnitTest() {
    	
    	/* Erwan 20170922 : To uncomment once Salesforce resolves the conversion bug
    	 // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId()); 
        insert new List<Custom_Settings__c> { c1 };
    	
        Mandataire__c oMandataire = new Mandataire__c();
        oMandataire.name = 'Logigaz';
        oMandataire.ExternalID__c = 'LGZ';
        oMandataire.Active__c = true;
        insert oMandataire;
        
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        RecordType rt2 = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        
        Integer iNumberAccountBA= 0;
        Integer iNumberAccountPA= 0;
        Integer iNumberContact= 0;
        Integer iNumberCase= 0;
       
        List<Account> lAccountToInsert=new List<Account>();
        List<Contact> lContactToInsert=new List<Contact>();

        List<Case> lCaseToInsert=new List<Case>();

        for(Integer i=0;i<9 * TEST_FACTOR;i++){
            lAccountToInsert.add(Utils.createAccountBA(i,rt.Id)); 
        }
         
        insert lAccountToInsert;
        
        System.assertEquals(9 * TEST_FACTOR,lAccountToInsert.size());
 
        for(Integer i=0;i<9 * TEST_FACTOR;i++){
            if(math.mod(i, 3)==0){
                // No contact Created                          
            }
            else if(math.mod(i,3)==1){
                // 1 contact Created 
                lContactToInsert.add(Utils.createContact(lAccountToInsert[i].Id,'Contact Unique'));  
            }
            else if(math.mod(i,3)==2){
                // 3 contact Created 
                lContactToInsert.add(Utils.createContact(lAccountToInsert[i].Id,'Contact Principal'));
                lContactToInsert.add(Utils.createContact(lAccountToInsert[i].Id,'Contact Vantive'));
                lContactToInsert.add(Utils.createContact(lAccountToInsert[i].Id,'Autre'));
            }
        } 
        insert lContactToInsert;
        
        for(Contact oContact: [select Id,CT_ContactRole__c,Account.Id from Contact where id in:lContactToInsert]){
                lCaseToInsert.add(new Case(Mandataire__c=oMandataire.Id,recordtypeID='012D000000032qt',subject='subject',contactId=oContact.Id));
        }
        insert lCaseToInsert;

        Integer k=0;

        for(Account oAccount: lAccountToInsert){
            oAccount.A_convertir__c = true;
            oAccount.Business_Account__c = false;
        }
        
        
        system.debug('Start TROUBLE');
        Test.startTest();
        update lAccountToInsert;
        Test.stopTest();
        system.debug('End TROUBLE');
   
        Integer iNumberAccountPAAfter= [select count() from Account where recordtypeid =:rt2.id];
        Integer iNumberAccountBAAfter= [select count() from Account where recordtypeid =:rt.id];
        //Integer iNumberContactAfter= [select count() from Contact];
        Integer iNumberCaseAfter= [select count() from Case];
        
        System.assertEquals(9 * TEST_FACTOR ,iNumberAccountPAAfter);
        System.assertEquals(0 ,iNumberAccountBAAfter);
        //System.assertEquals(15 * TEST_FACTOR ,iNumberContactAfter);
        System.assertEquals(12 * TEST_FACTOR ,iNumberCaseAfter);
 
        
       for(Contact oContact: [select Id,Account.ispersonAccount,CT_ContactRole__c,AccountId, (select Id from Cases)  from Contact where id in:lContactToInsert]){
                if(oContact.CT_ContactRole__c==''){
                    System.assertEquals(0,oContact.cases.size());
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Contact Vantive'){
                    System.assertEquals(0,oContact.cases.size());
                    System.assertEquals(null,oContact.AccountId);
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Autre'){
                    System.assertEquals(0,oContact.cases.size());
                    System.assertEquals(null,oContact.AccountId);
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Contact Principal'){
                    System.assertEquals(3,oContact.cases.size());
                    System.assertEquals(true,oContact.Account.ispersonAccount);
                }
                //else if(oContact.CT_ContactRole__c=='Contact Unique'){
                //    System.assertEquals(1,oContact.cases.size());
                //    System.assertEquals(true,oContact.Account.ispersonAccount);
                //}
         }
         
         List<Account> lAccountToBA=[select id from Account where id in:lAccountToInsert]; 
         
         for(Account oAccount: lAccountToBA){
            oAccount.A_convertir__c = true;
            oAccount.Business_Account__c = true;
        } 
        update lAccountToBA;
        
        
        Integer iNumberAccountPAAfterRollback= [select count() from Account where recordtypeid =:rt2.id];
        Integer iNumberAccountBAAfterRollback= [select count() from Account where recordtypeid =:rt.id];
        //Integer iNumberContactAfterRollback= [select count() from Contact];
        Integer iNumberCaseAfterRollback= [select count() from Case];
        
        System.assertEquals(0 ,iNumberAccountPAAfterRollback);
        System.assertEquals(9 * TEST_FACTOR ,iNumberAccountBAAfterRollback);
        //System.assertEquals(12 * TEST_FACTOR ,iNumberContactAfterRollback);
        System.assertEquals(12 * TEST_FACTOR ,iNumberCaseAfterRollback);
        
        for(Contact oContact: [select Id,Account.ispersonAccount,CT_ContactRole__c,AccountId, (select Id from Cases)  from Contact where id in:lContactToInsert]){
                
                if(oContact.CT_ContactRole__c=='Contact Vantive'){
                    System.assertEquals(1,oContact.cases.size());
                    System.assertNotEquals(null,oContact.AccountId);
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Autre'){
                    System.assertEquals(1,oContact.cases.size());
                    System.assertNotEquals(null,oContact.AccountId);
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Contact Principal'){
                    System.assertEquals(1,oContact.cases.size());
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
                else if(oContact.CT_ContactRole__c=='Contact Unique'){
                    System.assertEquals(1,oContact.cases.size());
                    System.assertEquals(false,oContact.Account.ispersonAccount);
                }
         }
         */
    }
}