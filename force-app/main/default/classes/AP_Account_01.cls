public class AP_Account_01 {
    
    private static boolean alreadyUpdatedAccount = false;
    private final static User oUser = [select id, Bypass_Validation_Rules__c, alias, Bypass_Email_No_Email_Check__c from User where id = :UserInfo.getUserId()];
    
    //20151103 ELC Commented because this map was not fed anywhere
    //private final static Map<Id, String> recordTypeIdToName = new Map<Id, String>();
    
    // manage MKT Contact
    public static void manageMKTContact(List<Account> lAcc){
        map<id,id> mapAccPredecessor = new map<id,id>();
        String sKeyPredecessor = '';
        Set<String> setPredecessor = new Set<String>();
        List<Id> listUniquePredecessorId = new list<Id>();        
        map<id,list<Contact>> mAccPredecessorContactMkt = new map<id,list<Contact>>();
        map<id,list<Contact>> mAccContactMkt = new map<id,list<Contact>>();
        list<Contact> lAccContactMktTemp = new list<Contact>();
        Contact oContactMktTemp = new Contact();
        List<Contact> lContactToUpdate = new List<Contact>();
        List<Contact> lContactToInsert = new List<Contact>();
        
        System.debug('START method AP_Account_01.manageMKTContact');
        
        // Recover "Predecessor" of the "Account DO"
        // Remark : only for "GEB" account
        for(Account oAcc:[Select Id, Predecessor__c from Account where Id in :lAcc and Predecessor__c != null and Activity_Domain__r.ExternalID__c=41]){        
            if(oAcc.Predecessor__c != null){
                sKeyPredecessor = oAcc.Predecessor__c;
                
                System.debug('[AP_Account_01.manageMKTContact] sKeyPredecessor: ' + sKeyPredecessor);
                
                // Recover the list of "Predecessors"
                if(setPredecessor.add(sKeyPredecessor))
                    listUniquePredecessorId.add(sKeyPredecessor);
                
                // Recover the link "Account / Predecessor"
                mapAccPredecessor.put(oAcc.Id, sKeyPredecessor);    
            }
        } 
        
        // Recover all "MKT Contacts" linked to each Predecessor Account
        if(listUniquePredecessorId.size() > 0){
            for(Contact oCont:[Select Id, Name, AccountId, Contact_Marketing__c from Contact where AccountId =: listUniquePredecessorId and Contact_Marketing__c = true]){
                if(mAccPredecessorContactMkt.containsKey(oCont.AccountId)){
                    mAccPredecessorContactMkt.get(oCont.AccountId).add(oCont);
                }
                else{
                    lAccContactMktTemp = new list<Contact>();
                    lAccContactMktTemp.add(oCont);
                    mAccPredecessorContactMkt.put(oCont.AccountId,lAccContactMktTemp);
                }           
            }  
        }             
        
        // Recover all "MKT Contacts" linked to each Account
        for(Contact oCont:[Select Id, Name, AccountId, Contact_Marketing__c from Contact where AccountId =: lAcc and Contact_Marketing__c = true]){
            if(mAccContactMkt.containsKey(oCont.AccountId)){
                mAccContactMkt.get(oCont.AccountId).add(oCont);
            }
            else{
                lAccContactMktTemp = new list<Contact>();
                lAccContactMktTemp.add(oCont);
                mAccContactMkt.put(oCont.AccountId,lAccContactMktTemp);
            }           
        }
        
        for(Account oAcc : lAcc){
            // Remark: Person Account are managed by the WF rule "Person_Account_Check_Marketing_Contact"
            
            // Business Account          
            if(!oAcc.IsPersonAccount && oAcc.Id!=Label.DummyAccountId && oAcc.CT_statutConversion__c != 'todelete' && !oAcc.A_convertir__c){
                System.debug('[AP02_Account.manageMKTContact] Business Account');
                
                // Change link from the contact of the predecessor
                if(mAccPredecessorContactMkt.containsKey(oAcc.Predecessor__c)){
                    System.debug('[AP02_Account.manageMKTContact] Change link from the contact of the predecessor');
                    
                    lAccContactMktTemp = mAccPredecessorContactMkt.get(oAcc.Predecessor__c);
                    
                    for(Contact oCont:lAccContactMktTemp){
                        oCont.AccountId = oAcc.Id;
                        oCont.Email = oAcc.Email__c;
                        oCont.MobilePhone= oAcc.Mobile_Phone_Number__c;
                        oCont.T_Apex_Context__c = True;  // Used to bypass validation rules
                        lContactToUpdate.add(oCont);
                    }
                }               
                
                // Need to create a "Shadow MKT contact" (if there is not yet one)
                if(!mAccContactMkt.containsKey(oAcc.Id) && !mAccPredecessorContactMkt.containsKey(oAcc.Predecessor__c)){
                    System.debug('[AP02_Account.manageMKTContact] Need to create a shadow MKT contact');
                    
                    oContactMktTemp = new Contact();
                    oContactMktTemp.Contact_Marketing__c  = true;
                    oContactMktTemp.firstName = 'Contact Marketing';
                    oContactMktTemp.lastName = 'Contact Marketing';
                    oContactMktTemp.accountId = oAcc.Id;
                    oContactMktTemp.LastName = oAcc.Name;
                    oContactMktTemp.Street_Number__c = oAcc.Street_Number__c;
                    oContactMktTemp.Postal_Box__c = oAcc.Postal_Box__c;
                    oContactMktTemp.Postal_Code__c = oAcc.Postal_Code__c;
                    oContactMktTemp.City__c = oAcc.City__c;
                    oContactMktTemp.Email = oAcc.Email__c;
                    oContactMktTemp.Email_2__c = oAcc.Email_2__c;
                    oContactMktTemp.Fax = oAcc.Fax;
                    oContactMktTemp.Place_Called__c = oAcc.Place_Called__c;
                    oContactMktTemp.Country__c = oAcc.Country__c;
                    oContactMktTemp.Indicatif_Pays_c__c=oAcc.Indicatif_Pays__c ;
                    oContactMktTemp.Phone = oAcc.Phone;
                    oContactMktTemp.MobilePhone = oAcc.Mobile_Phone_Number__c;
                    
                    lContactToInsert.add(oContactMktTemp);
                } 
            } 
        }
        
        // Insert all "MKT Contacts"
        if(lContactToInsert.size()>0 || lContactToUpdate.size()>0){
            System.debug('[AP_Account_01.manageMKTContact] lContactToInsert Counts: ' + lContactToInsert.size()); 
            System.debug('[AP_Account_01.manageMKTContact] lContactToUpdate Counts: ' + lContactToUpdate.size());          
            
            try{
                if(lContactToInsert.size()>0) insert lContactToInsert;
                if(lContactToUpdate.size()>0) update lContactToUpdate;
            }
            catch(DmlException ex){
            }               
        } 
        
        System.debug('END method AP_Account_01.manageMKTContact');
    }    
    
    // Copy "Remontée Concurrence GEB" from Predecessor
    public static void copyRemonteeConcurrenceGEB(List<Account> lAcc){
        map<id,id> mapAccPredecessor = new map<id,id>();
        String sKeyPredecessor = '';
        Set<String> setPredecessor = new Set<String>();
        List<Id> listUniquePredecessorId = new list<Id>();
        List<Remontee_concurrence_GEB__c> listRCToInsert = new list<Remontee_concurrence_GEB__c>();
        
        System.debug('START method AP_Account_01.copyRemonteeConcurrenceGEB');        
        
        // Recover "Predecessor" of the "Account DO"
        //for(Account oAcc:lAcc){
        // Remark : only for "GEB" account
        for(Account oAcc:[Select Id, Predecessor__c from Account where Id in :lAcc and Predecessor__c != null and Activity_Domain__r.ExternalID__c=41]){        
            if(oAcc.Predecessor__c != null){
                sKeyPredecessor = oAcc.Predecessor__c;
                
                System.debug('[AP_Account_01.copyRemonteeConcurrenceGEB] sKeyPredecessor: ' + sKeyPredecessor);
                
                // Recover the list of "Predecessors"
                if(setPredecessor.add(sKeyPredecessor))
                    listUniquePredecessorId.add(sKeyPredecessor);
                
                // Recover the link "PTL / Predecessor"
                mapAccPredecessor.put(oAcc.Id, sKeyPredecessor);    
            }
        }
        
        // Recover all "Remontée Concurrence GEB" linked to "Predecessors"
        if(listUniquePredecessorId.size() > 0){
            System.debug('[AP_Account_01.copyRemonteeConcurrenceGEB] listUniquePredecessorId Counts: ' + listUniquePredecessorId.size());
            
            // Recover all "Remontée Concurrence GEB"
            Remontee_concurrence_GEB__c oRCCloned;
            for(Remontee_concurrence_GEB__c oRC:[Select Id, Compte__c, Autre_magasins__c, Bouteilles__c, 
                                                 Cette_promotion_na_pas_ete_rapportee__c, Commentaires__c, Declaration_legale__c, Enseigne__c,
                                                 Intitule__c, La_dur_e_de_l_offre_au__c, La_duree_du__c, Le_perimetre_produit_concerne__c,
                                                 Marque_concurrente__c, Mecanique__c from Remontee_concurrence_GEB__c where Compte__c in :listUniquePredecessorId]){
                                                     oRCCloned = oRC.clone(false);
                                                     
                                                     // Link the "Remontée Concurrence GEB" to the new Account DO
                                                     for (String sAccId : mapAccPredecessor.keySet()){
                                                         if(mapAccPredecessor.get(sAccId) == oRC.Compte__c){
                                                             oRCCloned.Compte__c = sAccId;
                                                             break;
                                                         }
                                                     }
                                                     listRCToInsert.add(oRCCloned);  
                                                 }
            
            // Insert all "Remontée Concurrence GEB"
            if(listRCToInsert.size()>0){
                System.debug('[AP_Account_01.copyRemonteeConcurrenceGEB] listRCToInsert Counts: ' + listRCToInsert.size());          
                
                try{
                    insert listRCToInsert;
                }
                catch(DmlException ex){
                }               
            }
        }
        
        System.debug('END method AP_Account_01.copyRemonteeConcurrenceGEB');            
    }
    
    public static void updatePTLFromDO(list<Account> lAccount){
        System.debug('[AP_Account_01.updatePTLFromDO] lAccount Counts: ' + lAccount.size()); 
        
        // Recover only PTLs from GEB   
        List<PTL__c> lPTLToUpdate = [SELECT id, Account_DO__c from PTL__c where Account_DO__c in:lAccount and Activity_Domain__r.ExternalID__c=41];
        
        // Update database      
        if(lPTLToUpdate.size()>0){
            try{
                update lPTLToUpdate;
            } 
            catch(DmlException e){
            }           
        }   
        
        System.debug('END method AP_Account_01.updatePTLFromDO');            
        
    }
    
    public static boolean hasAlreadyUpdatedAccount() {
        return alreadyUpdatedAccount;
    }
    
    public static void setAlreadyUpdatedAccount(boolean b) {
        alreadyUpdatedAccount = b;
    }
    
    
    /*20151103 Ne plus utiliser cette règle*/
    /*
* Déclenche une erreur quand l'email ou la coche pas d'email ne sont pas renseignés au niveau du compte lorsqu'un lead
* est converti.
*/
    /*public static Boolean emailPasDEmailInsert(List<Account> accountToValidate, Boolean isTest){
for(Account acc: accountToValidate){
if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
if(isEmailPasDEmailAccount(acc)){
acc.addError('Le champ "Pas d’Email", au niveau du Suspect, doit être coché si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
}
}           
}

return true;
}*/
    
    /*
* Vérifie si les champs email ou pas d'email sont renseignés au niveau du compte
*/
    /*private static Boolean isEmailPasDEmailAccount(Account acc){
Boolean error;

String accRecordTypeName = recordTypeIdToName.get(acc.RecordTypeId);

if(
(((acc.No_E_mail__c && String.isNotBlank(acc.Email__c))
|| (acc.No_E_mail__c && String.isNotBlank(acc.Email_2__c))
|| (acc.No_E_mail__c == false 
&& String.isBlank(acc.Email__c) 
&& String.isBlank(acc.Email_2__c)
)
)
&&  
accRecordTypeName != 'GEB Challenge Commercial'  //20151103 This RT doesn't exist on Account object
)
// Partie qui permet à l'erreur de se déclencher uniquement lors de la conversion d'un suspect
&&
!acc.T_ByPassEmailPasDEmailEtSIRET__c 
&& 
acc.T_Is_Converted__c
) {
error = true;
} else {
error = false;
}

return error;
}*/
    
    
    /*
* Déclenche une erreur lorsqu'un compte est modifié s'il est modifié par un autre user que SAP.
*/
    public static Boolean preventClosedAccountToBeUpdated(List<Account> accountToValidate){
        // Erwan : 28/06/2016
        /*for(Account acc: accountToValidate){
if(acc.General_Deletion_Flag__c && oUser.alias != 'sap'){
acc.addError('Vous ne pouvez pas modifier un compte fermé.');
}
}*/
        
        List<Id> lUserIDsAllowedToModifyClosedAccounts = AP_PricingUtilities.getCustomSettingValue('UserIDsAllowedToModifyClosedAccounts').split(';');
        set<Id> UserIDsAllowedToModifyClosedAccountsSet = new set<Id>();
        UserIDsAllowedToModifyClosedAccountsSet.addAll(lUserIDsAllowedToModifyClosedAccounts);
        
        for(Account acc: accountToValidate){
            if(acc.General_Deletion_Flag__c && !UserIDsAllowedToModifyClosedAccountsSet.contains(oUser.Id)){
                acc.addError('Vous ne pouvez pas modifier un compte fermé.');
            }
        }
        
        return true;
    }
    
    /*
* Déclenche une erreur si incohérence entre Email et Pas d'email
*/
    public static Boolean emailPasDEmailInsertUpdate(List<Account> accountToValidate){
        //System.debug('ELC_20151103 accountToValidate.size(): ' + accountToValidate.size());
        
        List<Id> lUserIDsAllowedToModifyClosedAccounts = AP_PricingUtilities.getCustomSettingValue('UserIDsAllowedToModifyClosedAccounts').split(';');
        set<Id> UserIDsAllowedToModifyClosedAccountsSet = new set<Id>();
        UserIDsAllowedToModifyClosedAccountsSet.addAll(lUserIDsAllowedToModifyClosedAccounts);
        
        
        for(Account acc: accountToValidate){
            System.debug('MLC_20161130 acc.Lead_ExternalID__c: ' + acc.Lead_ExternalID__c);
            /*20151103 Don't test the user anymore, modification requested by Btz*/ 
            //if(oUser.alias == 'sap'){//Performs the test only for the sap user
            if(!oUser.Bypass_Email_No_Email_Check__c){
                if(acc.Activity_Domain__r.ExternalID__c!=45 && acc.is_groupement__c==false){  //Doesn't perform the test for ActDom 45 (GER)
                    if(isemailPasDEmailInsertUpdate(acc) && !UserIDsAllowedToModifyClosedAccountsSet.contains(oUser.Id)){
                        acc.addError('Le champ "Pas d’Email" doit être coché (au niveau du suspect / compte ) si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
                    }
                }
            }
        }
        
        return true;
    }
    
    /*
* Vérifie la cohérence des champs Email__c, Email_2__c et No_E_mail__c
*/
    private static Boolean isemailPasDEmailInsertUpdate(Account acc){
        Boolean error;
        
        if(
            (((acc.No_E_mail__c && String.isNotBlank(acc.Email__c))
              || (acc.No_E_mail__c && String.isNotBlank(acc.Email_2__c))
              || (acc.No_E_mail__c == false 
                  && String.isBlank(acc.Email__c) 
                  && String.isBlank(acc.Email_2__c)
                 )
             ))
        ) {
            error = true;
        } else {
            error = false;
        }
        
        return error;
    }
    
    
    
    // manage MKT Contact
    public static void manageMKTContactELC(List<Account> lAcc){
        map<id,id> mapAccPredecessor = new map<id,id>();
        String sKeyPredecessor = '';
        Set<String> setPredecessor = new Set<String>();
        List<Id> listUniquePredecessorId = new list<Id>();        
        map<id,list<Contact>> mAccPredecessorContactMkt = new map<id,list<Contact>>();
        map<id,list<Contact>> mAccContactMkt = new map<id,list<Contact>>();
        list<Contact> lAccContactMktTemp = new list<Contact>();
        Contact oContactMktTemp = new Contact();
        List<Contact> lContactToUpdate = new List<Contact>();
        List<Contact> lContactToInsert = new List<Contact>();
        
        /*
String TTT = '';

Set<String> setCheckAccounts = new Set<String>();

//for(Account tAcc:[Select Id, Predecessor__c from Account where Id in :lAcc and Activity_Domain__r.ExternalID__c=41]){
for(Account tAcc:[SELECT Id FROM Account WHERE Id!=null]){
setCheckAccounts.add(tAcc.Id);
System.debug('[AP_Account_01.manageMKTContactELC] Accounts : ' + tAcc.Id);
//TTT = tAcc.Id;
}


List<Account> lAccToUpdate = [SELECT Id FROM Account WHERE Predecessor__c = '' AND Activity_Domain__r.ExternalID__c=41 AND Id NOT IN (SELECT AccountId FROM Contact WHERE Contact_Marketing__c = true)];        
for(Account tAcc:lAccToUpdate){
setCheckAccounts.add(tAcc.Id);
System.debug('[AP_Account_01.manageMKTContactELC] Accounts : ' + tAcc.Id);
}
*/
        
        System.debug('START method AP_Account_01.manageMKTContactELC');
        //System.debug('[AP_Account_01.manageMKTContactELC] TTT : ' + TTT);
        //if (TTT.equals ('001D000000rvblnIAA')){
        //if (setCheckAccounts.contains(lAcc.Id)){
        //if (1==2){
        // Recover "Predecessor" of the "Account DO"
        // Remark : only for "GEB" account
        for(Account oAcc:[Select Id, Predecessor__c from Account where Id in :lAcc and Predecessor__c != null and Activity_Domain__r.ExternalID__c=41]){        
            if(oAcc.Predecessor__c != null){
                sKeyPredecessor = oAcc.Predecessor__c;
                
                System.debug('[AP_Account_01.manageMKTContactELC] oAcc: ' + oAcc.Id);
                System.debug('[AP_Account_01.manageMKTContactELC] sKeyPredecessor: ' + sKeyPredecessor);
                
                // Recover the list of "Predecessors"
                if(setPredecessor.add(sKeyPredecessor))
                    listUniquePredecessorId.add(sKeyPredecessor);
                
                // Recover the link "Account / Predecessor"
                mapAccPredecessor.put(oAcc.Id, sKeyPredecessor);    
            }
        } 
        
        // Recover all "MKT Contacts" linked to each Predecessor Account
        if(listUniquePredecessorId.size() > 0){
            for(Contact oCont:[Select Id, Name, AccountId, Contact_Marketing__c from Contact where AccountId =: listUniquePredecessorId and Contact_Marketing__c = true]){
                if(mAccPredecessorContactMkt.containsKey(oCont.AccountId)){
                    mAccPredecessorContactMkt.get(oCont.AccountId).add(oCont);
                }
                else{
                    lAccContactMktTemp = new list<Contact>();
                    lAccContactMktTemp.add(oCont);
                    mAccPredecessorContactMkt.put(oCont.AccountId,lAccContactMktTemp);
                    System.debug('[AP_Account_01.manageMKTContactELC] Pred trouvé');
                }         
            }  
        }             
        
        // Recover all "MKT Contacts" linked to each Account
        for(Contact oCont:[Select Id, Name, AccountId, Contact_Marketing__c from Contact where AccountId =: lAcc and Contact_Marketing__c = true]){
            if(mAccContactMkt.containsKey(oCont.AccountId)){
                mAccContactMkt.get(oCont.AccountId).add(oCont);
            }
            else{
                lAccContactMktTemp = new list<Contact>();
                lAccContactMktTemp.add(oCont);
                mAccContactMkt.put(oCont.AccountId,lAccContactMktTemp);
                System.debug('[AP_Account_01.manageMKTContactELC] Boucle Acc sans Pred');
            }           
        }
        
        for(Account oAcc : lAcc){
            System.debug('[AP_Account_01.manageMKTContactELC] Avant If : ' + oAcc.Id);
            //if (setCheckAccounts.contains(oAcc.Id)){
            
            System.debug('[AP_Account_01.manageMKTContactELC] Dans If : ' + oAcc.Id);
            // Remark: Person Account are managed by the WF rule "Person_Account_Check_Marketing_Contact"
            
            // Business Account          
            if(!oAcc.IsPersonAccount && oAcc.Id!=Label.DummyAccountId && oAcc.CT_statutConversion__c != 'todelete' && !oAcc.A_convertir__c){
                System.debug('[AP_Account_01.manageMKTContactELC] Business Account');
                
                // Change link from the contact of the predecessor
                if(mAccPredecessorContactMkt.containsKey(oAcc.Predecessor__c)){
                    System.debug('[AP_Account_01.manageMKTContactELC] Change link from the contact of the predecessor : ' + oAcc.Predecessor__c);
                    
                    lAccContactMktTemp = mAccPredecessorContactMkt.get(oAcc.Predecessor__c);
                    
                    for(Contact oCont:lAccContactMktTemp){
                        oCont.AccountId = oAcc.Id;
                        lContactToUpdate.add(oCont);
                        System.debug('[AP_Account_01.manageMKTContactELC] Account : ' + oAcc.Id + '  Contact : ' + oCont.Id);
                    }
                }               
                
                // Need to create a "Shadow MKT contact" (if there is not yet one)
                if(!mAccContactMkt.containsKey(oAcc.Id) && !mAccPredecessorContactMkt.containsKey(oAcc.Predecessor__c)){
                    System.debug('[AP_Account_01.manageMKTContactELC] Need to create a shadow MKT contact');
                    
                    oContactMktTemp = new Contact();
                    oContactMktTemp.Contact_Marketing__c  = true;
                    oContactMktTemp.firstName = 'Contact Marketing';
                    oContactMktTemp.lastName = 'Contact Marketing';
                    oContactMktTemp.accountId = oAcc.Id;
                    oContactMktTemp.LastName = oAcc.Name;
                    oContactMktTemp.Street_Number__c = oAcc.Street_Number__c;
                    oContactMktTemp.Postal_Box__c = oAcc.Postal_Box__c;
                    oContactMktTemp.Postal_Code__c = oAcc.Postal_Code__c;
                    oContactMktTemp.City__c = oAcc.City__c;
                    oContactMktTemp.Email = oAcc.Email__c;
                    oContactMktTemp.Email_2__c = oAcc.Email_2__c;
                    oContactMktTemp.Fax = oAcc.Fax;
                    oContactMktTemp.Place_Called__c = oAcc.Place_Called__c;
                    oContactMktTemp.Country__c = oAcc.Country__c;
                    oContactMktTemp.Phone = oAcc.Phone;
                    oContactMktTemp.MobilePhone = oAcc.Mobile_Phone_Number__c;
                    
                    lContactToInsert.add(oContactMktTemp);
                } 
            } 
            //}
        }
        
        // Insert all "MKT Contacts"
        if(lContactToInsert.size()>0 || lContactToUpdate.size()>0){
            System.debug('[AP_Account_01.manageMKTContactELC] lContactToInsert Counts: ' + lContactToInsert.size()); 
            System.debug('[AP_Account_01.manageMKTContactELC] lContactToUpdate Counts: ' + lContactToUpdate.size());          
            
            try{
                if(lContactToInsert.size()>0) insert lContactToInsert;
                if(lContactToUpdate.size()>0) update lContactToUpdate;
            }
            catch(DmlException ex){
            }               
        } 
        
        System.debug('END method AP_Account_01.manageMKTContactELC');
    }
    
    /*
// ELC 10/04/2015 : Updates the account address field with the concatenation of the split address fields
public static void updateConcatenatedAddressField(List<Account> lAcc){
List<Account> lAccountToUpdate = new List<Account>();

for(Account oAcc:[Select Id, Street_Number__c, Street_N__c, ToLabel(Number_extention__c), ToLabel(Street_type__c), Street_name__c from Account where Id in :lAcc ]){
//for(Account oAcc:[Select Id, Street_Number__c, Street_N__c, Number_extention__c, Street_type__c, Street_name__c from Account where Id in :lAcc ]){        
if( oAcc.Street_N__c != null || oAcc.Number_extention__c != null || oAcc.Street_type__c != null || oAcc.Street_name__c != null ){

System.debug('[AP_Account_01.updateConcatenatedAddressField] oAcc: ' + oAcc.Id);
System.debug('[AP_Account_01.updateConcatenatedAddressField] oAcc.Street_Number__c before: ' + oAcc.Street_Number__c);

//oAcc.Street_Number__c = oAcc.Street_N__c + ' ' + oAcc.Number_extention__c + ' ' + oAcc.Street_type__c + ' ' + oAcc.Street_name__c ;
oAcc.Street_Number__c = '';
if(oAcc.Street_N__c != null) oAcc.Street_Number__c += oAcc.Street_N__c  + ' ';
if(oAcc.Number_extention__c != null) oAcc.Street_Number__c += oAcc.Number_extention__c  + ' ';
if(oAcc.Street_type__c != null) oAcc.Street_Number__c += oAcc.Street_type__c  + ' ';
if(oAcc.Street_name__c != null) oAcc.Street_Number__c += oAcc.Street_name__c;

System.debug('[AP_Account_01.updateConcatenatedAddressField] oAcc.Street_Number__c after: ' + oAcc.Street_Number__c);

lAccountToUpdate.add(oAcc);

}
}
update lAccountToUpdate;

}*/
    
    // ELC 08/01/2016 : Updates the successor account with its predecessor's medal
    // used in conjunction with Workflow rule "Unset Apex Context" to uncheck the flag after this method updates the account
    public static void updateSuccessorAccountWithPredecessorMedal(List<Account> lAcc){
        List<Account> lAccountToUpdate = new List<Account>();
        
        for(Account oAcc:[Select Id, Predecessor__r.Segmentation_medailles__c, Segmentation_medailles__c from Account where Id in :lAcc ]){
            
            //System.debug('[AP_Account_01.updateSuccessorAccountWithPredecessorMedal] oAcc.Predecessor__r.Segmentation_medailles__c : ' + oAcc.Predecessor__r.Segmentation_medailles__c);
            //System.debug('[AP_Account_01.updateSuccessorAccountWithPredecessorMedal] oAcc.Segmentation_medailles__c before : ' + oAcc.Segmentation_medailles__c);
            if(oAcc.Predecessor__r.Segmentation_medailles__c != null){
                oAcc.Segmentation_medailles__c = oAcc.Predecessor__r.Segmentation_medailles__c;
                oAcc.T_Apex_Context__c = True;  // Used to bypass validation rules
            }
            //System.debug('[AP_Account_01.updateSuccessorAccountWithPredecessorMedal] oAcc.Segmentation_medailles__c after : ' + oAcc.Segmentation_medailles__c);
            
            lAccountToUpdate.add(oAcc);
        }
        update lAccountToUpdate;
        
    }
    
    /*
public static void updateTelEmailContactMKT(List<Account> accountToValidate) { 

System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] START');
System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] account' + accountToValidate );
Set<string> sAccountId = new Set<string>();

for(Account AccountContactMkt:accountToValidate)
{
if(!sAccountId.contains(AccountContactMkt.id))sAccountId.add(AccountContactMkt.id);

}


System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] Avant la liste');
List<Contact> lContactMkt=([ SELECT id,Country__c,Indicatif_Pays_c__c,Phone,MobilePhone,Email,T_Apex_Context__c,AccountId ,Has_No_Email__c
FROM contact 
WHERE AccountId 
in ( select id from account where id =:  sAccountId   and IsPersonAccount = false )
AND Contact_Marketing__c =: true
]);

System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] Apres la liste ');

for(Account acc:accountToValidate) 
{                    

if (acc.IsPersonAccount == false )
{

for(Contact contactmkt:lContactMkt)
{
System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] contactmkt.AccountId'  +  contactmkt.AccountId);
System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] acc.id ' + acc.id);
if(contactmkt.AccountId==acc.id)
{
contactmkt.Country__c=acc.Country__c;
contactmkt.T_Apex_Context__c = True ; 
contactmkt.Country__c=acc.Country__c;
contactmkt.Indicatif_Pays_c__c=acc.Indicatif_Pays__c ;
contactmkt.Phone=acc.Phone ;
contactmkt.MobilePhone=acc.Mobile_Phone_Number__c ;
contactmkt.Email=acc.Email__c ;
contactmkt.Has_No_Email__c = acc.No_E_mail__c;

}

update lContactMkt; 

}

}    
else
{
acc.PersonEmail=acc.Email__c;
acc.PersonMobilePhone=acc.Mobile_Phone_Number__c ;
}
}  

if (lContactMkt.size()>0) update lContactMkt;


}
*/
    
    // ELC 13/12/2016 : Encrypt Espace Client URL params and Updates field Espace_Client_Encrypted_Params__c with the encrypted value
    public static void updateEspaceClientEncryptedParams(List<Account> lAcc){
        
        string sEspaceClientEncryptKey = AP_PricingUtilities.getCustomSettingValue('Espace_Client_AES_Key');
        string sEspaceClientEncryptIv = AP_PricingUtilities.getCustomSettingValue('Espace_Client_AES_Iv');
        string sEspaceClientRegUrlGeb = AP_PricingUtilities.getCustomSettingValue('Espace_Client_Registration_URL_GEB');
        string sEspaceClientRegUrlGec = AP_PricingUtilities.getCustomSettingValue('Espace_Client_Registration_URL_GEC');
        string sPostalCode = '';
        string sUrl = '';
        string sParameters = '';
        string b64EncryptedData = '';
        string sFinalUrl = '';
        List<Account> lAccountToUpdate = new List<Account>();
        
        
        //Blob PrivateKey = Crypto.generateAesKey(256);
        blob key = EncodingUtil.base64Decode(sEspaceClientEncryptKey);
        blob iv = EncodingUtil.base64Decode(sEspaceClientEncryptIv);
        
        System.debug(logginglevel.WARN,'### sEspaceClientEncryptKey = ' + sEspaceClientEncryptKey);
        System.debug(logginglevel.WARN,'### sEspaceClientEncryptIv = ' + sEspaceClientEncryptIv);
        
        
        //for(Account acc: lAcc){
        for(Account acc:[Select Id, AccountNumber, Espace_Client_Registration_URL__c, City_Postal_Code__c, City_Postal_Code__r.Postal_Code__c, Postal_Code__c, Activity_Domain__r.ExternalID__c from Account where Id in :lAcc ]){   // Need a query to access relationship fields
            if(acc.Activity_Domain__c != null && (acc.Activity_Domain__r.ExternalID__c == 41 || acc.Activity_Domain__r.ExternalID__c == 42)){
                System.debug(logginglevel.WARN,'### acc.Espace_Client_Registration_URL__c = ' + acc.Espace_Client_Registration_URL__c);
                System.debug(logginglevel.WARN,'### acc.City_Postal_Code__c = ' + acc.City_Postal_Code__c);
                System.debug(logginglevel.WARN,'### acc.ExternalID__c = ' + acc.AccountNumber);
                
                sPostalCode = '';
                if(acc.City_Postal_Code__c != null){
                    System.debug(logginglevel.WARN,'### acc.City_Postal_Code__r.Postal_Code__c = ' + acc.City_Postal_Code__r.Postal_Code__c);
                    sPostalCode = acc.City_Postal_Code__r.Postal_Code__c;
                }else if (acc.Postal_Code__c != null){
                    sPostalCode = acc.Postal_Code__c;
                }
                
                System.debug(logginglevel.WARN,'### sPostalCode = ' + sPostalCode);
                if(acc.AccountNumber != null && sPostalCode != ''){
                    sUrl = acc.Activity_Domain__r.ExternalID__c == 41 ? sEspaceClientRegUrlGeb : sEspaceClientRegUrlGec;
                    sParameters = 'matricule=' + acc.AccountNumber + '&cp=' + sPostalCode;
                    
                    blob textBlob = blob.valueOf(sParameters);
                    blob encryptedData = Crypto.encrypt('AES256', key, iv, textBlob);
                    
                    System.debug(logginglevel.WARN,'### encryptedData = ' + encryptedData);
                    System.debug(logginglevel.WARN,'### EncodingUtil.base64Encode(encryptedData) = ' + EncodingUtil.base64Encode(encryptedData));
                    
                    
                    // To remove after debug
                    blob decryptedData = Crypto.decrypt('AES256', key, iv, encryptedData);
                    System.debug(logginglevel.WARN,'### decryptedData.toString() = ' + decryptedData.toString());
                    
                    b64EncryptedData = EncodingUtil.base64Encode(encryptedData);
                    sFinalUrl = sUrl + EncodingUtil.urlEncode(b64EncryptedData, 'UTF-8');
                    System.debug(logginglevel.WARN,'### sFinalUrl = ' + sFinalUrl);
                    acc.Espace_Client_Registration_URL__c = sFinalUrl;
                    
                    lAccountToUpdate.add(acc);
                }else{
                    acc.Espace_Client_Registration_URL__c = '';
                    System.debug(logginglevel.WARN,'### acc.Espace_Client_Registration_URL__c = ' + acc.Espace_Client_Registration_URL__c);
                    lAccountToUpdate.add(acc);
                }
            }
        }
        
        if(lAccountToUpdate.size()>0) update lAccountToUpdate;
        
    }
    
    //} 
    //numerotation auto compte prescripteur MLC 20180223
    public static void updateReferencePrecripteur(List<Account> lAcc)
    { 
        
        Custom_Settings__c refPrescripteur = Custom_Settings__c.getValues('ReferencePrescripteur');
        String sLatestNumber;
        Integer iLatestNumber;
        sLatestNumber = refPrescripteur.value__c;
        iLatestNumber = Integer.valueOf(sLatestNumber);
        
        
        Custom_Settings__c RT_PRESC = Custom_Settings__c.getValues('Account_RecordTypeId_Prescripteur');
        Id sRT_PRESC ;
        if(RT_PRESC !=null){
            sRT_PRESC = RT_PRESC.value__c;
            
        }
        
        try
        {
            
            
            
            
            for(Account acc:lAcc ) 
            {
                System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur  CLASS recoortype<<< run by ' + acc.RecordTypeId );
                System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur CLASS  AccountNumber<<< run by ' + acc.AccountNumber);
                System.Debug('##>>> Account.BeforeInsert : BYPASS updateReferencePrecripteur  CLASS<<< run by ' + acc.Id + ' ' + acc.AccountNumber);
                if(acc.RecordTypeId== sRT_PRESC && acc.AccountNumber == null ){
                    acc.AccountNumber=  'PRESC'+ ('00000' + String.valueOf(iLatestNumber )).right(5) ;
                    
                    
                    iLatestNumber  = iLatestNumber + 1;
                    refPrescripteur.value__c= String.valueOf(iLatestNumber);
                    update refPrescripteur;
                    
                }
                
            }
        }
        
        catch(Exception e)
        {
            System.debug('Pouvez vous retenter la convertion du suspect,svp ?');
            // object.addError(e.getMessage() + 'Texte Perso');
            
        }
        
    }
    
    
    // ELC 08/07/2021 : Copy GDB auto account number (gdb_accountNo__c) to AccountNumber and ExternalID__c fields
    public static void copyGDBAccountNumber(List<Account> lAcc){
        
        List<Account> lAccountToUpdate = new List<Account>();
        
        for(Account acc:[Select Id, AccountNumber, ExternalID__c, gdb_accountNo__c from Account where Id in :lAcc and Activity_Domain__r.ExternalID__c = 50 ]){   // Need a query to access relationship fields
            if( acc.AccountNumber != acc.gdb_accountNo__c || acc.ExternalID__c != acc.gdb_accountNo__c ){
                acc.AccountNumber = acc.gdb_accountNo__c;
                acc.ExternalID__c = acc.gdb_accountNo__c;
                lAccountToUpdate.add(acc);
            }
        }
        
        if(lAccountToUpdate.size()>0) update lAccountToUpdate;
        
    }
    
    public static void calculerPotentielPrescripteur(List<Account> lAcc){
        
        for( Account acc : lAcc){
            if( acc.Prescriber__c ){
                
                Decimal nbChaudInstalParAnGn= (null==acc.Nb_de_chaudieres_installees_par_an_GN__c)?0:Acc.Nb_de_chaudieres_installees_par_an_GN__c;
                Decimal nbChaudInstalParAnGEC=(null==acc.Nb_de_chaudieres_installees_par_an_GEC__c)?0:Acc.Nb_de_chaudieres_installees_par_an_GEC__c;
                Decimal nbChaudInstalParAnFioul=(null==acc.Nb_de_chaudieres_installees_par_an_FIOUL__c)?0:Acc.Nb_de_chaudieres_installees_par_an_FIOUL__c;
                Decimal nbChaudInstalParAnGDB=(null==acc.Nb_de_chaudieres_installees_par_an_GDB__c)?0:Acc.Nb_de_chaudieres_installees_par_an_GDB__c;
                
                Decimal nbPacAirEauParAn=(null==acc.Nb_de_PAC_air_eau_installees_par_an__c)?0:Acc.Nb_de_PAC_air_eau_installees_par_an__c;
                Decimal nbPacAirAirParAn=(null==acc.Nb_de_PAC_air_air_installees_par_an__c)?0:Acc.Nb_de_PAC_air_air_installees_par_an__c;
                
                Decimal nbConstructionMIParAnGEC=(null==acc.Nb_de_constructions_de_MI_par_an_GEC__c)?0:Acc.Nb_de_constructions_de_MI_par_an_GEC__c;
                Decimal nbConstructionMIParAnGN=(null==acc.Nb_de_constructions_de_MI_par_an_GN__c)?0:Acc.Nb_de_constructions_de_MI_par_an_GN__c;
                Decimal nbConstructionMIParAnGDB=(null==acc.Nb_de_constructions_de_MI_par_an_GDB__c)?0:Acc.Nb_de_constructions_de_MI_par_an_GDB__c;
                Decimal nbConstructionMIParAnELEC=(null==acc.Nb_de_constructions_de_MI_par_an_ELEC__c)?0:Acc.Nb_de_constructions_de_MI_par_an_ELEC__c;
                
                Decimal Nb_de_contrats_d_entretien_chaudiere_GN=(null==acc.Nb_de_contrats_d_entretien_chaudiere_GN__c)?0:Acc.Nb_de_contrats_d_entretien_chaudiere_GN__c;
                Decimal Nb_de_contrats_d_entretien_chaudiere_GEC=(null==acc.Nb_de_contrats_d_entretien_chaudiere_GEC__c)?0:Acc.Nb_de_contrats_d_entretien_chaudiere_GEC__c;
                Decimal Nb_de_contrats_entretien_chaudiere_GDB=(null==acc.Nb_de_contrats_entretien_chaudiere_GDB__c)?0:Acc.Nb_de_contrats_entretien_chaudiere_GDB__c;
                Decimal Nb_de_contrats_dentretien_chaudiereFIOUL=(null==acc.Nb_de_contrats_dentretien_chaudiereFIOUL__c)?0:Acc.Nb_de_contrats_dentretien_chaudiereFIOUL__c;
                Decimal Nb_de_contrats_dentretien_PAC_air_eau =(null==acc.Nb_de_contrats_dentretien_PAC_air_eau__c)?0:Acc.Nb_de_contrats_dentretien_PAC_air_eau__c;
                Decimal Nb_de_contrats_dentretien_PAC_air_air =(null==acc.Nb_de_contrats_dentretien_PAC_air_air__c)?0:Acc.Nb_de_contrats_dentretien_PAC_air_air__c;
                
                Decimal Nb_de_chaudieres_installees_par_an_GEC =(null==acc.Nb_de_chaudieres_installees_par_an_GEC__c)?0:Acc.Nb_de_chaudieres_installees_par_an_GEC__c;
                Decimal Nb_de_chaudieres_installees_par_an_GDB =(null==acc.Nb_de_chaudieres_installees_par_an_GDB__c)?0:Acc.Nb_de_chaudieres_installees_par_an_GDB__c;
                
                
                
                
                switch on acc.Prescriber_Activity__c {
                    when 'Individual House Builder' {		
                        // when block 1
                        // code block 1
                        
                        acc.Potentiel_GEC__c=(nbConstructionMIParAnELEC+nbConstructionMIParAnGDB)*0.05+nbConstructionMIParAnGEC;
                        acc.Potentiel_ELEC__c=nbConstructionMIParAnELEC + nbConstructionMIParAnGDB + nbConstructionMIParAnGN + nbConstructionMIParAnGEC ;
                        acc.Potentiel_GDB__c=nbConstructionMIParAnGDB ;
                        acc.Potentiel_GN__c=nbConstructionMIParAnGN;
                        acc.T_MedaillePotentielGec_MAJ__c=true;
                        
                        
                    }	
                    when 'Heating installer' {		
                        // when block 2
                        // code block 2
                        acc.Potentiel_ELEC__c=(nbChaudInstalParAnGn + nbChaudInstalParAnGEC + nbChaudInstalParAnFioul + nbPacAirEauParAn + nbPacAirAirParAn)*0.1;
                        acc.Potentiel_GDB__c=nbChaudInstalParAnGDB;
                        acc.Potentiel_GEC__c=(nbChaudInstalParAnGEC + nbChaudInstalParAnFioul)*0.1;
                        acc.Potentiel_GN__c=nbChaudInstalParAnGn +nbChaudInstalParAnFioul*0.2;
                        acc.T_MedaillePotentielGec_MAJ__c=true;
                        
                        
                    }
                    when 'Heating After sales service' {		// when block 3
                        // code block 3
                        acc.Potentiel_ELEC__c= ( Nb_de_contrats_d_entretien_chaudiere_GN  + Nb_de_contrats_d_entretien_chaudiere_GEC  + 
                                                Nb_de_contrats_dentretien_chaudiereFIOUL + Nb_de_contrats_dentretien_PAC_air_eau  + 
                                                Nb_de_contrats_dentretien_PAC_air_air ) *0.10;
                        
                        acc.Potentiel_GDB__c= (Nb_de_contrats_entretien_chaudiere_GDB ) * 0.10;
                        acc.Potentiel_GEC__c= ((Nb_de_contrats_d_entretien_chaudiere_GEC)*0.70  + Nb_de_contrats_dentretien_chaudiereFIOUL) *0.10;
                        acc.Potentiel_GN__c=  (Nb_de_contrats_d_entretien_chaudiere_GN + Nb_de_contrats_dentretien_chaudiereFIOUL)  *0.10;
                        acc.T_MedaillePotentielGec_MAJ__c=true;
                    }
                    when 'SAV chauffage & IC' {		
                        // when block 3
                        // code block 3
                        acc.Potentiel_ELEC__c = nbChaudInstalParAnGn + 
                            Nb_de_chaudieres_installees_par_an_GEC + nbChaudInstalParAnFioul+
                            Acc.Nb_de_PAC_air_eau_installees_par_an__c + nbPacAirAirParAn +
                            ( Nb_de_contrats_d_entretien_chaudiere_GN + 
                             Nb_de_contrats_d_entretien_chaudiere_GEC + 
                             Nb_de_contrats_dentretien_chaudiereFIOUL + 
                             Nb_de_contrats_dentretien_PAC_air_eau + 
                             Nb_de_contrats_dentretien_PAC_air_air) *0.10;
                        
                        acc.Potentiel_GDB__c = nbChaudInstalParAnGDB  + Nb_de_contrats_entretien_chaudiere_GDB*0.10;
                        acc.Potentiel_GEC__c = Nb_de_chaudieres_installees_par_an_GEC  + 
                            (nbChaudInstalParAnFioul + 
                             Nb_de_contrats_d_entretien_chaudiere_GEC*0.70 +
                             Nb_de_contrats_dentretien_chaudiereFIOUL)*0.10 ;
                        acc.Potentiel_GN__c =nbChaudInstalParAnGn  + 
                           nbChaudInstalParAnFioul*0.20 + 
                            Nb_de_contrats_d_entretien_chaudiere_GN  *0.10 + 
                            Nb_de_contrats_dentretien_chaudiereFIOUL*0.10;
                        acc.T_MedaillePotentielGec_MAJ__c=true;
                        
                        
                    }
                    when else {		  // default block, optional
                        // code block 4
                    }
                }
                
            }
        }
        
    }
    
}