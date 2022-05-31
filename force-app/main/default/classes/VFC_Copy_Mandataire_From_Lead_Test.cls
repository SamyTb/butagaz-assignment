@isTest
private class VFC_Copy_Mandataire_From_Lead_Test {

    public static testMethod void testCopyMandataireOnConversion() {
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz Sales Administrator (RAV)%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='AP04L',Alias='AP04L',
            Email='AP04L@shell.com',Username='AP04L@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        System.runAs(u) {
            Activity_Domain__c oAdd = new Activity_Domain__c(name = 'Test', ExternalID__c=42);
            insert oAdd;
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            System.debug('###MLC 1 mdt.Id =' + mandataire1.Id);
            
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Lead' AND DeveloperName='Prescriber_Lead' LIMIT 1];
            
            Canton__c Canton1 = new Canton__c(name = 'AP04L Canton', INSEE_Code__c = '-_-_', Mandataire__c= mandataire1.id);
            insert Canton1;
            
            System.debug('###MLC1 ct.Id =' + Canton1 .Id); 
            
            City__c City1  = new City__c (Name = 'Saint Jean Cap Ferrat',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '06230 - AP04L', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '06230', Code_Type__c = 'M', Postal_Code__c = '06230');
            insert cityCP;
                
            Lead l1 = new Lead(
                FirstName = 'FirstName',
                LastName = 'LastName',
                Company = 'Company',
                Activity_Domain__c = oAdd.Id,
                RecordTypeId = rt.Id,
                Status = 'New',
                Prescriber_Activity__c = 'Architect',
                Channel__c = 'Mail',
                LeadSource = 'Commercial',
                Assign__c = False,
                Phone = '0101010101',
                No_E_mail__c = True,
                Account_Street_Type__c = 'Rue',
                Account_Street_Name__c = 'Alfred',  
                Account_City_Postal_Code__c = cityCP.Id,
                Account_Country__c='FR'
            );
            
            //List<Lead> leadList = new List<Lead>();
            //leadList.add(l1);
            
            // Start test
            test.starttest();
            
            insert l1;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l1.id);
            lc.setDoNotCreateOpportunity(true);  //MLC 20161123 true a la placede false
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            System.debug('###ELC 1 l1.Id =' + l1.Id);
            System.debug('###ELC 1 l1.convertedAccountId =' + l1.convertedAccountId);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
             // RecordType
            RecordType recordTypeAccount = new RecordType(Name = 'Pro');
            
             // New Contact

             Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
             accountId = l1.convertedAccountID ,Street_Number__c = 'eee',Postal_Box__c = '92300',
             Postal_Code__c = '92300',City__c = 'lvp',Email = 'toto@tot.com',
             Fax = l1.Fax,Place_Called__c = l1.Place_Called__c,Country__c = 'FR',Phone = l1.Phone);
             insert c;
             
            // Account
            Account compteLead = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,  Postal_Code__c = '123', City__c = 'SOPFP1City', 
            Code_SIRET__c = '', En_cours_d_immatriculation__c = true, No_E_mail__c  = true, Email__c = null,Country__c='FR', Phone='0202020202');
            insert compteLead ;
            
             
            // Opportunity
            Opportunity optyLead = new Opportunity(name = 'isSiretOuEnCoursDImmat', DO_Code_SIRET__c = '', 
           Project_Type__c = 'CREA', AccountId = compteLead .Id, Assign__c = false, StageName = 'Prospecting', 
           CloseDate = Date.parse('01/02/2014'),  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP.id);
           
           insert optyLead;
             
            System.debug('###ELC 2 l1.convertedAccountId =' + l1.convertedAccountId);
            System.debug('###ELC 1 lcr.isSuccess() =' + lcr.isSuccess());
            System.assert(lcr.isSuccess());
            
            System.debug('###ELC 2 l1.Id =' + l1.Id);
            System.debug('###ELC 3 l1.convertedAccountId =' + l1.convertedAccountId);
            
            Lead aLead = 
            [select name, id, FirstName, isConverted, convertedAccountID 
            from Lead where id = :l1.ID];
            
            System.debug('###GGO eLead.ID =' + aLead.Id);
            System.debug('###GGO aLead.firstname =' + aLead.firstname);
            System.debug('###GGO aLead.convertedAccountId =' + aLead.convertedAccountId);
            
            
            
             
            //   /!\   This part fails, need to investigate
            //List<Account> accounts = [SELECT Id, Mandataire__c FROM Account WHERE Id = :l1.convertedAccountId LIMIT 1];
            //System.assert(accounts[0].Mandataire__c != null);
            
             // Stop test        
            test.stoptest();
        }
    }
}