public class AP_Account_in_Contract {
    // Updates Bailleur__c field on account if at least 1 active ZDP or ZDKP contract
    public static void updateBailleurOnOwnerAccount(List<Account_in_Contract__c> accountInContracts){
        /*integer cptBailleur;
        ID sAccount;
        List<String> lAccountOwner = new List<String>();
        List<Account> listAccountsToUpdate = new List<Account>();
        
        //System.debug('###ELC accountInContracts = ' + accountInContracts);
        List<Id> lContractIDs = new list<Id>();
        for(Account_in_Contract__c lAccInCTR:accountInContracts){
            //System.debug('###ELC lAccInCTR = ' + lAccInCTR);
            lContractIDs.add(lAccInCTR.Contract__c);
        }
        
        System.debug('###ELC lContractIDs.size() = ' + lContractIDs.size());
        System.debug('###ELC lContractIDs = ' + lContractIDs);
        
        // Find the owner (Role = ZP) in Account_in_Contract__c
        List<Account_in_Contract__c> lAccount_in_ContractOwners = new List<Account_in_Contract__c>([ SELECT Account__c FROM Account_in_Contract__c WHERE Role__c = 'ZP' AND Contract__r.Id IN :lContractIDs ]);
        // Add condition on Activity Domain ?
        
        System.debug('###ELC lAccount_in_ContractOwners.size() = ' + lAccount_in_ContractOwners.size());
        
        if(lAccount_in_ContractOwners.size() > 0){
            for (Integer i=0;i<lAccount_in_ContractOwners.size();i++) {
                lAccountOwner.add(lAccount_in_ContractOwners.get(i).Account__c); 
            }
            
            // Find the "Locataire" Contracts linked to the owner --- Contract_Type__c IN ('ZDP', 'ZDKP')
            List<Account_in_Contract__c> lallOwnerContracts = new List<Account_in_Contract__c>([
                SELECT Id, Account__c, Contract__r.Contract_Type__c, Contract__r.T_Contract_end_calcualtion__c 
                FROM Account_in_Contract__c 
                WHERE Account__c IN :lAccountOwner 
                AND IsDeleted = false 
                ORDER BY Account__c ]);
            
            System.debug('###ELC lallOwnerContracts.size() = ' + lallOwnerContracts.size());
            
            // Fill in list of Accounts to update
            if(lallOwnerContracts.size() > 0){
                cptBailleur = 0;
                sAccount = null;
                
                for(Account_in_Contract__c lOwner:lallOwnerContracts){
                    System.debug('###ELC lOwner = ' + lOwner);
                    System.debug('###ELC lOwner.Account__c = ' + lOwner.Account__c + ' | sAccount = ' + sAccount);
                    
                    System.debug('###ELC sAccount = ' + sAccount);
                    if(sAccount != lOwner.Account__c && sAccount != null){
                        System.debug('###ELC AAA ');
                        Account a = new Account(Id = lOwner.Account__c);
                        System.debug('###ELC a.Id = ' + a.Id);
                        if(cptBailleur > 0){
                            a.Bailleur__c = true;
                        }else{
                            a.Bailleur__c = false;
                        }
                        listAccountsToUpdate.add(a);
                        System.debug('###ELC listAccountsToUpdate AAA = ' + listAccountsToUpdate);
                        a.Id = null;
                        cptBailleur = 0;
                        sAccount = lOwner.Account__c;
                    }
                    System.debug('###ELC BBB ');
                    System.debug('###ELC lOwner.Contract__r.Contract_Type__c = ' + lOwner.Contract__r.Contract_Type__c);
                    System.debug('###ELC lOwner.Contract__r.T_Contract_end_calcualtion__c = ' + lOwner.Contract__r.T_Contract_end_calcualtion__c);
                    if((lOwner.Contract__r.Contract_Type__c == 'ZDP' || lOwner.Contract__r.Contract_Type__c == 'ZDKP') && lOwner.Contract__r.T_Contract_end_calcualtion__c == 'Active'){
                        cptBailleur++;
                        System.debug('###ELC cptBailleur = ' + cptBailleur);
                        if(sAccount == null) sAccount = lOwner.Account__c;
                        System.debug('###ELC sAccount = ' + sAccount);
                    }
                }
                // Adds last account found in the list
                if(sAccount != null){
                    Account a = new Account(Id = sAccount);
                    if(cptBailleur > 0){
                        a.Bailleur__c = true;
                    }else{
                        a.Bailleur__c = false;
                    }
                    listAccountsToUpdate.add(a);
                    System.debug('###ELC listAccountsToUpdate BBB = ' + listAccountsToUpdate);
                }
                
                System.debug('###ELC listAccountsToUpdate = ' + listAccountsToUpdate);
                update listAccountsToUpdate;
            }
            
        }*/
        // First filter duplicate contracts
        Set<Id> relatedContractSet = new Set<Id>();
        Set<Id> relatedAccountSet = new Set<Id>();
        
        
        // Gather unique contract & account ids
        for (Account_in_Contract__c lAccInCTR: accountInContracts) {
            // Contracts
            if(!relatedContractSet.contains(lAccInCTR.Contract__c)) {
                relatedContractSet.add(lAccInCTR.Contract__c);
            }
            // Accounts
            if(!relatedAccountSet.contains(lAccInCTR.Account__c) && lAccInCTR.Role__c == 'ZP') {
                relatedAccountSet.add(lAccInCTR.Account__c);
            }
        }
        
        // Get all AccountInContract records related to contracts and accounts
        Map<Id, List<Account_in_Contract__c>> aicAccMap = new Map<Id, List<Account_in_Contract__c>>();
        for (Account_in_Contract__c aic : [
                SELECT Id, Role__c, Account__c, Account__r.id, Account__r.Bailleur__c, Contract__c , Contract__r.Contract_Type__c, 
                    Contract__r.T_Contract_end_calcualtion__c
                FROM Account_in_Contract__c 
                WHERE Contract__c IN: relatedContractSet OR 
                Account__c IN: relatedAccountSet  
                LIMIT 50000
            ]) {
            // Accounts
            if (aic.Role__c == 'ZP'){
                if (aicAccMap.containsKey(aic.Account__c)) {
                    List<Account_in_Contract__c> accInContractsList = aicAccMap.get(aic.Account__c);
                    accInContractsList.add(aic);
                    aicAccMap.put(aic.Account__c, accInContractsList);
                } else {
                    aicAccMap.put(aic.Account__c, new List<Account_in_Contract__c>{aic});
                }
            }
        }
        
        // Parse accounts map / contract lists and update value if required
        List<Account> accToUpdate = new List<Account>();
        
        for (Id idAccount: aicAccMap.keySet()) {
            Boolean activeOwnerContract = false;
            Account bailleur = new account();
            bailleur.id = idAccount;
            bailleur.Bailleur__c = aicAccMap.get(idAccount)[0].Account__r.Bailleur__c;
            for (Account_in_Contract__c aic: aicAccMap.get(idAccount)) {
                if ((aic.Contract__r.Contract_Type__c == 'ZDP' || aic.Contract__r.Contract_Type__c == 'ZDKP' || aic.Contract__r.Contract_Type__c == 'ZDCP' || aic.Contract__r.Contract_Type__c == 'ZPKP'|| aic.Contract__r.Contract_Type__c =='ZPP') && aic.Contract__r.T_Contract_end_calcualtion__c == 'Active' ) {
                    activeOwnerContract = true;                 
                }
            }
            if (activeOwnerContract && !bailleur.Bailleur__c) {
                // Need to update account
                bailleur.Bailleur__c = true;
                accToUpdate.add(bailleur);
            } else if (!activeOwnerContract && bailleur.Bailleur__c) {
                // Need to update account too
                bailleur.Bailleur__c = false;
                accToUpdate.add(bailleur);
            }
        }
        
        // Finally update the selected accounts
        if (accToUpdate.size() > 0) update accToUpdate; 
    }
    
    
    
   
    
}