@IsTest 
private class AP_Contract_Test{
    
    public static testmethod void testUpdateLastDateFide(){
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = '005D0000002Dx4R;005D0000002EgIr;005D0000002EgIw'); 
        insert new List<Custom_Settings__c> { c1 };
        
        /** CREATE DATASET **********/
        Account account = Utils.createAccountBA();
        insert account;
        
                 
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
        accountId = account.Id,Street_Number__c = account.Street_Number__c,Postal_Box__c = account.Postal_Box__c,
        Postal_Code__c = account.Postal_Code__c,City__c = account.City__c,Email = account.Email__c,Email_2__c = account.Email_2__c,
        Fax = account.Fax,Place_Called__c = account.Place_Called__c,Country__c = account.Country__c,Phone = account.Phone);
        insert c;
        
        Contract contract = new Contract(AccountID=account.id,Status='Draft');
        insert contract;
        Account_in_Contract__c ac1 = new Account_in_Contract__c(Account__c = account.id, Contract__c = contract.id, Role__c = 'AG');
        insert ac1;
        Account_in_Contract__c ac2 = new Account_in_Contract__c(Account__c = account.id, Contract__c = contract.id, Role__c = 'AG');
        insert ac2;
        Contract contract2 = new Contract(AccountID=account.id,Status='Draft');
        insert contract2;
        Account_in_Contract__c ac3 = new Account_in_Contract__c(Account__c = account.id, Contract__c = contract2.id, Role__c = 'AG');
        insert ac3;
        Account_in_Contract__c ac4 = new Account_in_Contract__c(Account__c = account.id, Contract__c = contract2.id, Role__c = 'AG');
        insert ac4;
        
        List<Contract> contracts = new List<Contract>();
        contracts.add(contract);
        contracts.add(contract2);
        /****************************/
        
        Map<Id, List<Account_in_Contract__c>> mapAccountsInContracts = AP_Contract.fetchAllAccountsInContracts(contracts);
        System.assertEquals(mapAccountsInContracts.get(contract.Id).size(), 2);
        System.assertEquals(mapAccountsInContracts.get(contract2.Id).size(), 2);
        AP_Contract.updateLastDateFIDEOnRelatedAccountInContract(contracts);
    }
    
    
    //MLC 20170619 | 20171012
    
      public static testmethod void updatetypeRelationInAccount() {
  
  
  // Start test
                 test.starttest();
  
  
  
      String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
      User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='APCTR',
      Email='APCTR@shell.com',Username='APCTR@shell.com',TimeZoneSidKey='Europe/Paris',
      LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
      LanguageLocaleKey='fr');
                
      insert u;
            
      Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = '005D0000002Dx4R;005D0000002EgIr;005D0000002EgIw'); 
      insert new List<Custom_Settings__c> { c1 };
            
      System.runAs(u) {
                
      Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
      insert AD_GEC;
                
      Canton__c Canton1 = new Canton__c(name = 'APCTR Canton', INSEE_Code__c = '-_-_');
      insert Canton1;
      
      City__c City1  = new City__c (Name = 'APCTR City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
      insert City1;
                
      City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - APCTRCity', 
      City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
      insert cityCP;
                
        
       Account bailleur = new Account(Name='bailleur', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
       Postal_Code__c = '123', City__c = 'APCTRCity', Email__c = 'APCTRCity@test.org',Country__c='FR', Phone='0202020202',Bailleur__c=true);
       insert bailleur;
       
       Account locataire = new Account(Name='locataire', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
       Postal_Code__c = '123', City__c = 'APCTRCity', Email__c = 'APCTRCity@test.org',Country__c='FR', Phone='0202020202',Bailleur__c=false);
       insert locataire;
       
       
      
       
       Item__c item1 = new  Item__c (Name='Test Item1', Activity_Domain__c=AD_GEC.Id,
       Code_Article__c = 'CA-01', ExternalID__c = 'EI-01');
       insert item1;
                
       Mandataire__c mand1 = new Mandataire__c(
       name = 'APCTR Mandataire',
       ExternalID__c = 'APCEI',
       Active__c = true
       );
       insert mand1;
       
                
       PTL__c PTLBailleur = new PTL__c(
       Activity_Domain__c = AD_GEC.id,
       Mandataire__c = mand1.id,
       City__c = 'APCTR City 2',
       Postal_Code__c = '09876',
       Account_DO__c = bailleur.id,
       Name = 'PTLB'
       );
       insert PTLBailleur;
       
       

       
        // Contracts and Account_in_Contract__c bailleur
                List<Contract> ctrListBailleur = new List<Contract>();
                
                for(Integer i=0;i<5;i++) {
                    Contract ctr = new Contract(
                        PTL__c = PTLBailleur.Id,
                        StartDate = Date.today(),
                        Scale_c__c = 'APCTRScale', 
                        Name = 'APCTRName' + i,
                        ExternalID__c = 'APCEI' + i,
                        Activity_Domain__c = AD_GEC.Id,
                        ContractTerm = 5,
                        Mandataire__c = mand1.Id,
                        Commercial_Agency__c = 'APCTRAgC',
                        AccountId = bailleur.Id,
                        Product__c = item1.Id,
                        EndDate = null
                    );
                    ctrListBailleur.add(ctr);
                }
                 
                ctrListBailleur[0].Contract_Label__c = 'ZP';
                ctrListBailleur[1].Contract_Label__c = 'ZDP';
                ctrListBailleur[2].Contract_Label__c = 'ZDKP';
                ctrListBailleur[3].Contract_Label__c = 'ZDCP';
                ctrListBailleur[4].Contract_Label__c = 'ZPP';
                ctrListBailleur[4].AccountId = bailleur.Id;
                
                insert ctrListBailleur;
                system.assertEquals(5, ctrListBailleur.size());
                
               
               List<Account_in_Contract__c> accinctrListBailleur = new List<Account_in_Contract__c>();
                
                for(Integer i=0;i<5;i++) {
                    Account_in_Contract__c accinctrBailleur = new Account_in_Contract__c(
                        Account__c = bailleur.Id,
                        Contract__c = ctrListBailleur[i].Id
                    );
                    accinctrListBailleur.add(accinctrBailleur);
                }
                
                accinctrListBailleur[0].Role__c = 'ZP';
                accinctrListBailleur[1].Role__c = 'ZO';
                accinctrListBailleur[2].Role__c = 'ZO';
                accinctrListBailleur[3].Role__c = 'ZO';
                accinctrListBailleur[4].Role__c = 'ZP';
                accinctrListBailleur[0].Account__c = bailleur.Id;
                
                insert accinctrListBailleur;
                system.assertEquals(5, accinctrListBailleur.size());
       
                List<Account_in_Contract__c> accinctrListLocataire = new List<Account_in_Contract__c>();
                
                for(Integer i=0;i<5;i++) {
                    Account_in_Contract__c accinctrLocataire = new Account_in_Contract__c(
                        Account__c = locataire.Id,
                        Contract__c = ctrListBailleur[i].Id
                    );
                    accinctrListLocataire.add(accinctrLocataire);
                }
                
             
                accinctrListBailleur[3].Account__c = locataire.Id;
       
                insert accinctrListLocataire;
                system.assertEquals(5, accinctrListLocataire.size());
                
                 
               
                    list<Account> lAccount = new list<Account>();
                    for(Account olaccount:[SELECT id,Type_de_relation__c FROM Account WHERE id =: bailleur.id] ) 
                    
                    {
                        lAccount.add(olaccount);
                    }
                    
                      System.assertEquals(1, lAccount.size());
                   
            
        
                      AP_Contract.updatetypeRelationInAccount(ctrListBailleur);
       
           
                     
                // Stop test
               test.stoptest();    

   }
   
  } 
    

    
}