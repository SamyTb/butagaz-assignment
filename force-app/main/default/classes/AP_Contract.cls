/*
 * AP_Contract : Class used by Contract Triggers 
 */
public class AP_Contract {
    
    
    /*
     * Update Last_date_FIDE__c in all Account_in_Contract__c related to contracts list.
     * 11/05/2016 | Erwan | Also updates Depose_Date__c in all Account_in_Contract__c related to contracts list.
     */
    public static void updateLastDateFIDEOnRelatedAccountInContract(List<Contract> contracts){
    
        Map<Id, List<Account_in_Contract__c>> mapAccountsInContracts = fetchAllAccountsInContracts(contracts);
        
        List<Account_in_Contract__c> listAccountInContractsToUpdate = new List<Account_in_Contract__c>();
        
        for(Contract contract:contracts){
            List<Account_in_Contract__c> accountsInContract =  mapAccountsInContracts.get(contract.Id);
            
            if(accountsInContract != null){
                for(Account_in_Contract__c accountInContract:accountsInContract){
                    accountInContract.Last_date_FIDE__c = contract.Last_date_FIDE__c;
                    accountInContract.Depose_Date__c = contract.Depose_Date__c;
                    listAccountInContractsToUpdate.add(accountInContract);
                }
            }
        }
        
        update listAccountInContractsToUpdate;
    }
     
     
     /*
      * Fetch Account_in_Contract__c related to contracts list.
      * Return a map group by Contract Id
      */
    public static Map<Id, List<Account_in_Contract__c>> fetchAllAccountsInContracts(List<Contract> contracts){
    
        Map<Id, List<Account_in_Contract__c>> mapAccountsInContracts = new Map<Id, List<Account_in_Contract__c>>();
        
        List<Account_in_Contract__c> allAccountsInContracts = [SELECT Id, Contract__c FROM Account_in_Contract__c WHERE Contract__c IN :contracts AND Role__c = 'AG'];
        
        
        for(Account_in_Contract__c accountInContract:allAccountsInContracts){
            if(mapAccountsInContracts.get(accountInContract.Contract__c) == null){
                mapAccountsInContracts.put(accountInContract.Contract__c, new List<Account_in_Contract__c>());
            }
            mapAccountsInContracts.get(accountInContract.Contract__c).add(accountInContract);
        }
        
        return mapAccountsInContracts;
    }
    
   //MLC 21/06/2017 | 12/10/217
    
  public static void updatetypeRelationInAccount(List<Contract> Contracts) { 

       // First filter duplicate contracts
        
        Set<Id> relatedAccountSet = new Set<Id>();
        list<Account> Account_list_Update=new list<Account>();

        
        // Gather unique contract & account ids
        for (Contract lCTR: Contracts) {
         
            // Accounts
            if(!relatedAccountSet.contains(lCTR.accountId) ) {
                relatedAccountSet.add(lCTR.accountId);
            }
        }
        
        try {
        
        
                 List<Account>accToUpdate=new List<Account>([SELECT Id, 
                               (SELECT Id, CreatedDate, Contract_Type__c
                                FROM Contracts
                                WHERE T_Contract_end_calcualtion__c = 'Active'
                                AND Contract_Type__c <> 'ZGZM'
                                ORDER BY CreatedDate DESC
                                LIMIT 1
                               ),Type_de_relation__c
                                FROM Account
                                WHERE Id IN:relatedAccountSet FOR UPDATE
                                ]);
            
              for(Contract ctr:Contracts) 
               {                    
                    for(Account acc:accToUpdate)
                    {
                        if( ctr.AccountId==acc.Id)
                        {

                            if ((ctr.Contract_Type__c == 'ZP' || ctr.Contract_Type__c == 'ZDP' || ctr.Contract_Type__c == 'ZDKP' || ctr.Contract_Type__c == 'ZDCP' || ctr.Contract_Type__c == 'ZPKP'|| ctr.Contract_Type__c =='ZPP')  )
                            {
                                // Need to update account
                               System.debug('###MLC Propietaire');
                               acc.Type_de_relation__c = 'Locataire';
                               Account_list_Update.add(acc);
                            
                            } 
                        
                            else  
                            {
                                // Need to update account too
                                System.debug('###MLC Loctaire');
                                acc.Type_de_relation__c =  'Propriétaire';
                                Account_list_Update.add(acc);
                                      
                            }
                         }
                            
                    }
                }
                
                 // Finally update the selected accounts
                if (Account_list_Update.size() > 0) update Account_list_Update; 
            }
            catch(Exception e)
           {
               
               System.debug('Pouvez vous retenter la maj du contrat,svp ?');
               // object.addError(e.getMessage() + 'Texte Perso');
               

           }
}
        
        
      
}