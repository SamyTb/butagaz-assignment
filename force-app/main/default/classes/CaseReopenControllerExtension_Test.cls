@isTest
private class CaseReopenControllerExtension_Test {
    static testMethod void myUnitTest() {
        Test.startTest();
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        Mandataire__c m = new Mandataire__c(
            Name = 'Test Mandataire', 
            Active__c = true
        );
        insert m;
        
        Account a = new Account(
            Name = 'Test Account',
            City__c = 'Test City',
            Postal_Code__c = '0000',
            Country__c='FR', 
            Phone='0202020202',
            Email__c='toto@tata.com'
            
        );
        insert a;
        
         // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
        
        Case FcaseTest = new Case(
            ContactId = c.id,
            subject = 'abcd',
            Mandataire__c = m.id
        );
        insert FcaseTest ;
        //Case FcaseTest = [SELECT id FROM Case LIMIT 1];
        //recuperation de la page VFP
        PageReference pageRef = Page.CaseReopen;
        //on signale que la page de référence est notre page de réouverture de case
        Test.setCurrentPageReference(pageRef);
        //on envoie les parametres à la page
        ApexPages.currentPage().getParameters().put('idCase',FCaseTest.Id);
        
        /* Now create the standard controller for the case  */
        ApexPages.StandardController stdCon = new ApexPages.StandardController(FcaseTest);
            
        /* Now construct the controller extension with the standardcontroller stdCon */
        CaseReopenControllerExtension ext = new CaseReopenControllerExtension(stdCon);

        /* Assert the controller returns the expected values*/ 
        PageReference pageSave = ext.SaveCase();

        /* Assert the controller returns the expected values*/ 
        PageReference pageCancel = ext.CancelCase();  
         
         
         FcaseTest.claim__c=true;
         FcaseTest.reopen_Number__c++;
         update FcaseTest;
         
         ext = new CaseReopenControllerExtension(stdCon);
         pageSave = ext.SaveCase();
         
        Test.stopTest();
        
    }
    
}