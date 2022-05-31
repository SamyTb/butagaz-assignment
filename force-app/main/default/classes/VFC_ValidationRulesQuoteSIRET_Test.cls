@isTest
public class VFC_ValidationRulesQuoteSIRET_Test {
    
    /* Cas de test : Siret vide et En cours d'immat cochée -> Redirection vers le vfp VFP_ContratPDF */
    public static testmethod void siretOkAndRedirectToContractPdf() {
        Boolean isSiret;
        pageReference launchVerif;
        ApexPages.Pagereference pageRef = Page.VFP_ContractPDF;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        //Mandataire
          Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
          insert mandataire1;
          
        //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
        
         //City
           City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
           insert City1;    
                
           City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                      City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                      insert cityCP1;      
        
        // RecordType
        RecordType recordType = new RecordType(Name = 'Pro');
                
        // Account
        Account compte = new Account(name = 'Test Account', RecordType = recordType, En_cours_d_immatriculation__c = true,
            Code_SIRET__c = null, Email__c = 'VFCVRQuoteSiret1@test.org',Country__c='FR', Phone='0202020202');
        insert compte;
        
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
        accountId = compte.Id,Street_Number__c = compte.Street_Number__c,Postal_Box__c = compte.Postal_Box__c,
        Postal_Code__c = compte.Postal_Code__c,City__c = compte.City__c,Email = compte.Email__c,Email_2__c = compte.Email_2__c,
        Fax = compte.Fax,Place_Called__c = compte.Place_Called__c,Country__c = compte.Country__c,Phone = compte.Phone);
        insert c;
        
        
        // Opportunity
        Opportunity opty = new Opportunity(name = 'Test Opty', DO_Code_SIRET__c = null, Project_Type__c = 'CREA',
                AccountId = compte.Id, Assign__c = false, StageName = 'Needs analysis', CloseDate = Date.parse('01/02/2014'),
                DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id);
        insert opty;
        
        Opportunity optySoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, Project_Type__c, Account.RecordType.Name
                                FROM Opportunity WHERE Id = :opty.Id];
            
        // Quote
        Quote devis = new Quote(Name = 'Test Devis', OpportunityID = opty.Id, DO_Payment_method__c = '2', 
                Payment_spread__c = 'Payment_spread_V1LIB_P', Contract_Duration__c = '1');
        insert devis;
                                
        Quote devisSoql = [Select Id from Quote where Id = :devis.Id];
        
        // Start test
        test.starttest();
        
        VFC_Validation_Rules_Quote_SIRET validation = new VFC_Validation_Rules_Quote_SIRET(new ApexPages.standardcontroller(devis));
        
        isSiret = validation.isSiretEnCoursDImmatOrFill(optySoql);
        launchVerif = validation.launchVerifSiretToCreateContractPdf();
        
        String launchReturnUrl;
        
        if(launchVerif == null) {
            launchReturnUrl = null;
        } else {
            launchReturnUrl = launchVerif.getUrl();
        }
        
        System.assertEquals(isSiret, true);
        System.assertEquals(launchReturnUrl, pageRef.getUrl() + '?id=' + devisSoql.Id);
        
        validation.back();
        
        // Stop test        
        test.stoptest();
    }
    
    /* Cas de test : Siret vide et En cours d'immat décochée -> Erreur (pas de redirection) */
    public static testmethod void siretKoAndNoRedirect() {
        Boolean isSiret;
        pageReference launchVerif;
        ApexPages.Pagereference pageRef = Page.VFP_ContractPDF;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        // RecordType
        RecordType recordType = new RecordType(Name = 'Pro');
        
        //Mandataire
          Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
          insert mandataire1;
          
           //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
                
         //City
           City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
           insert City1;    
                
           City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                      City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                      insert cityCP1;              
                
        // Account
        Account compte = new Account(name = 'Test Account', RecordType = recordType, Email__c = 'VFCVRQuoteSiret2@test.org',Country__c='FR', Phone='0202020202');
        insert compte;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
        accountId = compte.Id,Street_Number__c = compte.Street_Number__c,Postal_Box__c = compte.Postal_Box__c,
        Postal_Code__c = compte.Postal_Code__c,City__c = compte.City__c,Email = compte.Email__c,Email_2__c = compte.Email_2__c,
        Fax = compte.Fax,Place_Called__c = compte.Place_Called__c,Country__c = compte.Country__c,Phone = compte.Phone);
        insert c;
        
        // Opportunity
        Opportunity opty = new Opportunity(name = 'Test Opty', DO_Code_SIRET__c = null, Project_Type__c = 'CREA',
                AccountId = compte.Id, Assign__c = false, StageName = 'Needs analysis', CloseDate = Date.parse('01/02/2014'), 
                DO_En_cours_d_immatriculation__c = false,  Project_City_Postal_Code__c=cityCP1.id);
        insert opty;
        
        Opportunity optySoql = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, Project_Type__c, Account.RecordType.Name
                                FROM Opportunity WHERE Id = :opty.Id];
            
        // Quote
        Quote devis = new Quote(Name = 'Test Devis', OpportunityID = opty.Id, DO_Payment_method__c = '2', 
                Payment_spread__c = 'Payment_spread_V1LIB_P', Contract_Duration__c = '1');
        insert devis;
                                
        Quote devisSoql = [Select Id from Quote where Id = :devis.Id];
        
        // Start test
        test.starttest();
        
        VFC_Validation_Rules_Quote_SIRET validation = new VFC_Validation_Rules_Quote_SIRET(new ApexPages.standardcontroller(devis));
        
        isSiret = validation.isSiretEnCoursDImmatOrFill(optySoql);
        launchVerif = validation.launchVerifSiretToCreateContractPdf();
        
        String launchReturnUrl;
        
        if(launchVerif == null) {
            launchReturnUrl = null;
        } else {
            launchReturnUrl = launchVerif.getUrl();
        }
        
        System.assertEquals(isSiret, false);
        System.assertEquals(launchReturnUrl, null);
        
        // Stop test        
        test.stoptest();
    }
}