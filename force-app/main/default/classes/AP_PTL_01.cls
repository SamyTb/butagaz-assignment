public class AP_PTL_01 {
    
    private static boolean alreadyUpdatedPTL = false;
    
    // manage MKT Contact
    public static void manageMKTContact(list<PTL__c> lPTL){
        map<string,id> mapPTLAccountDO = new map<string,id>();
        String sKeyAccountDO = '';
        Set<String> setAccountDO = new Set<String>();
        List<Id> listUniqueAccountDOId = new list<Id>();
        map<id,id> mAccDOContactMkt = new map<id,id>();
        string sAccountDOId = null; 
     
       // //System.debug('START method AP_PTL_01.manageMKTContact');
        
        // Recover all "Account DO id"
        for(PTL__c oPTL:lPTL){
            //System.debug('oPTL ID>>> : ' + oPTL.Name);        
            sKeyAccountDO = oPTL.Account_DO__c;
            //System.debug('[AP_PTL_01.manageMKTContact] sKeyAccountDO: ' + sKeyAccountDO);

            if(sKeyAccountDO != null){
                // Recover the list of "Account DO id"
                if(setAccountDO.add(sKeyAccountDO))
                    listUniqueAccountDOId.add(sKeyAccountDO);
                
                // Recover the link "PTL / Account DO"
                mapPTLAccountDO.put(oPTL.Name, sKeyAccountDO);
                //System.debug('Bulding list oPTL.ID >>: ' + oPTL.Name + ' - sKeyAccountDO >>: ' + sKeyAccountDO);
            }
        } 
        
        // Recover all "MKT Contacts" linked to each Account DO
        if(listUniqueAccountDOId.size() > 0){
            //System.debug('[AP_PTL_01.manageMKTContact] listUniqueAccountDOId Counts: ' + listUniqueAccountDOId.size());
            
            for(Contact oCont:[Select Id, Name, AccountId, Account.IsPersonAccount, Account.PersonContactId, Contact_Marketing__c from Contact where AccountId =: listUniqueAccountDOId and Contact_Marketing__c = true]){
                //System.debug('Contact ID For: ' + oCont.Id + ' - Name - ' + oCont.Name);
                if(oCont.Account.IsPersonAccount) {
                    mAccDOContactMkt.put(oCont.AccountId, oCont.Account.PersonContactId);
                    //System.debug('Person Account IN: ' + oCont.AccountId + ' - Contact ID: ' + oCont.Account.PersonContactId);
                    }
                else {
                    mAccDOContactMkt.put(oCont.AccountId, oCont.Id);
                    //System.debug('Business Account IN: ' + oCont.AccountId + ' - Contact ID: ' + oCont.Id);
                    }
            }  
        }             
        
        // Create the link "Marketing contact" on PTL
        //System.debug('BEFORE LOOP size Contact List: ' + mAccDOContactMkt.size());
        //System.debug('BEFORE LOOP size lPTL List: ' + lPTL.size());
        for(PTL__c oPTL : lPTL){
            //System.debug('oPTL Name: ' + oPTL.Name + ' YES?: ' + mapPTLAccountDO.containsKey(oPTL.Id));
            if(mapPTLAccountDO.containsKey(oPTL.Name)){
            //System.debug('I m here!');
                sAccountDOId = mapPTLAccountDO.get(oPTL.Name);
                //System.debug('sAccountDOId: ' + sAccountDOId);
                //System.debug('[AP_PTL_01.manageMKTContact] sAccountDOId Id: ' + mapPTLAccountDO.get(oPTL.Name));
                if(mAccDOContactMkt.containsKey(sAccountDOId) && oPTL.Contact_Marketing__c != mAccDOContactMkt.get(sAccountDOId)){
                //if(mAccDOContactMkt.containsKey(sAccountDOId) && oPTL.Contact_Marketing__c == null){
//                if(mAccDOContactMkt.containsKey(sAccountDOId)){
                    //System.debug('[AP_PTL_01.manageMKTContact] Contact_Marketing__c Id: ' + mAccDOContactMkt.get(sAccountDOId));
                    oPTL.Contact_Marketing__c = mAccDOContactMkt.get(sAccountDOId);
                }
            }
        }
        
        //System.debug('END method AP_PTL_01.manageMKTContact');      
    }      
    
    public static void putACCodeInAccount(list<PTL__c> lPTL){
        
        List<Id> lPTLID = new list<Id>();
        map<id, PTL__c> mPTLAccountDO = new map<id, PTL__c>();              
        List<Account> lAccountToUpdate = new List<Account>();
                
        
        //System.debug('[AP_PTL_01.putACCodeInAccount] lPTL Counts: ' + lPTL.size()); 
            
        //Recover the list PTL iD
        for(PTL__c oPTL:lPTL){
                lPTLID.add(oPTL.id); 
        }
        
        //System.debug('[AP_PTL_01.putACCodeInAccount] lPTLID Counts: ' + lPTLID.size()); 
        
        //Recover the AC Code and AC Value from the PTL
        //List<PTL__c> lPTLChanged = [SELECT id, Account_DO__c,Code_AC_administrator__c, 
        //Code_AC_administrator_value__c from PTL__c where id in:lPTLID]; 
        
        List<PTL__c> lPTLChanged = [SELECT id, Account_DO__c,/*Code_AC_administrator__c,Code_AC_administrator_value__c,*/
        Code_AC_administrator_New__r.Libelle_Groupe_Vendeur__c,
        Code_AC_administrator_New__r.Code_Groupe_Vendeur__c from PTL__c where id in:lPTLID]; 
                                                        
        
        //System.debug('[AP_PTL_01.putACCodeInAccount] lPTLChanged Counts: ' + lPTLChanged.size());   
        
        for(PTL__c PTLChanged:lPTLChanged){
            if(PTLChanged.Account_DO__c != null){
                mPTLAccountDO.put(PTLChanged.Account_DO__c,PTLChanged);
            }           
        }

        //System.debug('[AP_PTL_01.putACCodeInAccount] mPTLAccountDO Counts: ' + mPTLAccountDO.size());   
        
        // Recover information to Update
        for (id AccountDO : mPTLAccountDO.keySet() ){
            lAccountToUpdate.add(new Account(
                    Id=AccountDO,
                    //Code_AC_administrator__c= mPTLAccountDO.get(AccountDO).Code_AC_administrator,
                    //Code_AC_administrator_value__c=mPTLAccountDO.get(AccountDO).Code_AC_administrator_value__c
                    Code_AC_administrator__c= mPTLAccountDO.get(AccountDO).Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,                    
                    Code_AC_administrator_value__c=mPTLAccountDO.get(AccountDO).Code_AC_administrator_New__r.Libelle_Groupe_Vendeur__c
                    
                    )
                    );  
        }
        
        //System.debug('[AP_PTL_01.putACCodeInAccount] lAccountToUpdate Counts: ' + lAccountToUpdate.size());     
        
        // Update database      
        if(lAccountToUpdate.size()>0){
            try{
                update lAccountToUpdate;
            } 
            catch(DmlException e){
            }           
         }      
         
         //System.debug('END method AP_PTL_01.putACCodeInAccount');            
        
                                                       
                                         
                             
                                   
             
                    
    }
    
    // Deactivate PTL from Predecessor
    public static void deactivatPTLFromPredecessor(List<PTL__c> lPTL){
        map<id,id> mapPTLPredecessor = new map<id,id>();
        String sKeyPredecessor = '';
        Set<String> setPredecessor = new Set<String>();
        List<Id> listUniquePredecessorId = new list<Id>();
        List<PTL__c> listPTLToUpdate = new list<PTL__c>();
                
        //System.debug('START method AP_PTL_01.deactivatPTLFromPredecessor');        
        
        // Recover "Predecessor" of the corresponding "Account DO"
        // Remark : only on "GEB" account       
        for(PTL__c oPTL:[Select Id, Account_DO__r.Predecessor__c from PTL__c where Id in :lPTL and Account_DO__r.Predecessor__c != null and Account_DO__r.Activity_Domain__r.ExternalID__c=41]){
            sKeyPredecessor = oPTL.Account_DO__r.Predecessor__c;
            
            //System.debug('[AP_PTL_01.deactivatPTLFromPredecessor] sKeyPredecessor: ' + sKeyPredecessor);
            
            // Recover the list of "Predecessors"
            if(setPredecessor.add(sKeyPredecessor))
                listUniquePredecessorId.add(sKeyPredecessor);
            
            // Recover the link "PTL / Predecessor"
            mapPTLPredecessor.put(oPTL.Id, sKeyPredecessor);    
        }
    
        // Recover all "PTLs" linked to "Predecessors"
        if(listUniquePredecessorId.size() > 0){
            //System.debug('[AP_PTL_01.deactivatPTLFromPredecessor] listUniquePredecessorId Counts: ' + listUniquePredecessorId.size());
        
            // Recover all "PTLs"
            for(PTL__c oPTL:[Select Id, PTL_succession__c from PTL__c where Account_DO__c in :listUniquePredecessorId]){
                
                // Deactivate the PTL
                oPTL.PTL_succession__c = true;
                listPTLToUpdate.add(oPTL);  
            }
            
            // Update all "PTL"
            if(listPTLToUpdate.size()>0){
                //System.debug('[AP_PTL_01.deactivatPTLFromPredecessor] listPTLToUpdate Counts: ' + listPTLToUpdate.size());          
                
                try{
                    update listPTLToUpdate;
                }
                catch(DmlException ex){
                }               
            }
        }
    
        //System.debug('END method AP_PTL_01.deactivatPTLFromPredecessor');            
    }    

    // Copy Inventory Pricing from Predecessor
    public static void copyIPFromPredecessor(List<PTL__c> lPTL){
        map<id,id> mapPTLPredecessor = new map<id,id>();
        String sKeyPredecessor = '';
        Set<String> setPredecessor = new Set<String>();
        List<Id> listUniquePredecessorId = new list<Id>();
        List<Inventory_Pricing__c> listIPToInsert = new list<Inventory_Pricing__c>();
                
        //System.debug('START method AP_PTL_01.copyIPFromPredecessor');        
        
        // Recover "Predecessor" of the corresponding "Account DO"
        // Remark : only on "GEB" account
        for(PTL__c oPTL:[Select Id, Account_DO__r.Predecessor__c from PTL__c where Id in :lPTL and Account_DO__r.Predecessor__c != null and Account_DO__r.Activity_Domain__r.ExternalID__c=41]){
            if(oPTL.Account_DO__r.Predecessor__c != null){
                sKeyPredecessor = oPTL.Account_DO__r.Predecessor__c;
                
                //System.debug('[AP_PTL_01.copyIPFromPredecessor] sKeyPredecessor: ' + sKeyPredecessor);
                
                // Recover the list of "Predecessors"
                if(setPredecessor.add(sKeyPredecessor))
                    listUniquePredecessorId.add(sKeyPredecessor);
                
                // Recover the link "PTL / Predecessor"
                mapPTLPredecessor.put(oPTL.Id, sKeyPredecessor);    
            }
        }
    
        // Recover all "Inventory Pricing" linked to "Predecessors"
        if(listUniquePredecessorId.size() > 0){
            //System.debug('[AP_PTL_01.copyIPFromPredecessor] listUniquePredecessorId Counts: ' + listUniquePredecessorId.size());
        
            // Recover all "Inventory Pricing"
            Inventory_Pricing__c oIPCloned;
            for(Inventory_Pricing__c oIP:[Select Id, PTL__c, Inventory_Date__c, Prix_BD_Ref__c, PTL__r.Account_DO__c from Inventory_Pricing__c where PTL__r.Account_DO__c in :listUniquePredecessorId]){
                oIPCloned = oIP.clone(false);
                
                // Filled the "Source" technical field
                oIPCloned.T_IP_Source_Id__c = oIP.Id;
                
                // Link the "Inventory Pricing" to the new PTL
                for (String sPTLId : mapPTLPredecessor.keySet()){
                    if(mapPTLPredecessor.get(sPTLId) == oIP.PTL__r.Account_DO__c){
                        oIPCloned.PTL__c = sPTLId;
                        break;
                    }
                }
                listIPToInsert.add(oIPCloned);  
            }
            
            // Insert all "Inventory Pricing"
            if(listIPToInsert.size()>0){
                //System.debug('[AP_PTL_01.copyIPFromPredecessor] listIPToInsert Counts: ' + listIPToInsert.size());          
                
                try{
                    insert listIPToInsert;
                }
                catch(DmlException ex){
                }               
            }
            
            // Remark: the corresponding "Inventory Pricing Brand" will be copied by the "InventoryPricingAfterInsert" trigger                  
        }
    
        //System.debug('END method AP_PTL_01.copyIPFromPredecessor');            
    }
    
    // Copy Inventory Pricing Brand from Predecessor
    public static void copyIPBFromPredecessor(List<Inventory_Pricing__c> lIP){
        map<id,id> mapIPIPSourceId = new map<id,id>();
        String sKeyIP = '';
        Set<String> setIP = new Set<String>();
        List<Id> listUniqueIPId = new list<Id>();
        List<Inventory_Pricing_Brand__c> listIPBToInsert = new list<Inventory_Pricing_Brand__c>();
                
        //System.debug('START method AP_PTL_01.copyIPBFromPredecessor');        
        
        // Recover "Inventory Pricing source" of the corresponding "Inventory Pricing"
        for(Inventory_Pricing__c oIP:[Select Id, T_IP_Source_Id__c from Inventory_Pricing__c where Id in :lIP and T_IP_Source_Id__c != null]){
            if(oIP.T_IP_Source_Id__c != null){
                sKeyIP = oIP.T_IP_Source_Id__c;
                
                //System.debug('[AP_PTL_01.copyIPBFromPredecessor] sKeyIP: ' + sKeyIP);
                
                // Recover the list of "Inventory Pricing"
                if(setIP.add(sKeyIP))
                    listUniqueIPId.add(sKeyIP);
                
                // Recover the link "IP / IP Source Id"
                mapIPIPSourceId.put(oIP.Id, sKeyIP);    
            }
        }
    
        // Recover all "Inventory Pricing Brand" linked to "IP Source Id"
        if(listUniqueIPId.size() > 0){
            //System.debug('[AP_PTL_01.copyIPBFromPredecessor] listUniqueIPId Counts: ' + listUniqueIPId.size());
        
            // Recover all "Inventory Pricing Brand"
            Inventory_Pricing_Brand__c oIPBCloned;
            for(Inventory_Pricing_Brand__c oIPB:[Select Id, Inventory_pricing__c, Brand__c, Delivery_Frequency__c, Presence__c, Prix_indiferencie__c, Release_Date__c from Inventory_Pricing_Brand__c where Inventory_pricing__c in :listUniqueIPId]){
                oIPBCloned = oIPB.clone(false);
                
                // Filled the "Source" technical field
                oIPBCloned.T_IPB_Source_Id__c = oIPB.Id;
                
                // Link the "Inventory Pricing Brand" to the new "Inventory Pricing"
                for (String sIPId : mapIPIPSourceId.keySet()){
                    if(mapIPIPSourceId.get(sIPId) == oIPB.Inventory_pricing__c){
                        oIPBCloned.Inventory_pricing__c = sIPId;
                        break;
                    }
                }
                listIPBToInsert.add(oIPBCloned);    
            }
            
            // Insert all "Inventory Pricing Brand"
            if(listIPBToInsert.size()>0){
                //System.debug('[AP_PTL_01.copyIPBFromPredecessor] listIPBToInsert Counts: ' + listIPBToInsert.size());           
                
                try{
                    insert listIPBToInsert;
                }
                catch(DmlException ex){
                }               
            }
            
            // Remark: the corresponding "Inventory Pricing Article" will be copied by the "InventoryPricingBrandAfterInsert" trigger                   
        }
    
        //System.debug('END method AP_PTL_01.copyIPBFromPredecessor');            
    }  
    
    // Copy Inventory Pricing Article from Predecessor
    public static void copyIPAFromPredecessor(List<Inventory_Pricing_Brand__c> lIPB){
        map<id,id> mapIPBIPBSourceId = new map<id,id>();
        String sKeyIPB = '';
        Set<String> setIPB = new Set<String>();
        List<Id> listUniqueIPBId = new list<Id>();
        List<Inventory_Pricing_Article__c> listIPAToInsert = new list<Inventory_Pricing_Article__c>();
                
        //System.debug('START method AP_PTL_01.copyIPAFromPredecessor');        
        
        // Recover "Inventory Pricing Brand source" of the corresponding "Inventory Pricing Brand"
        for(Inventory_Pricing_Brand__c oIPB:[Select Id, T_IPB_Source_Id__c from Inventory_Pricing_Brand__c where Id in :lIPB and T_IPB_Source_Id__c != null]){
            if(oIPB.T_IPB_Source_Id__c != null){
                sKeyIPB = oIPB.T_IPB_Source_Id__c;
                
                //System.debug('[AP_PTL_01.copyIPAFromPredecessor] sKeyIPB: ' + sKeyIPB);
                
                // Recover the list of "Inventory Pricing Brand"
                if(setIPB.add(sKeyIPB))
                    listUniqueIPBId.add(sKeyIPB);
                
                // Recover the link "IPB / IPB Source Id"
                mapIPBIPBSourceId.put(oIPB.Id, sKeyIPB);    
            }
        }
    
        // Recover all "Inventory Pricing Article" linked to "IPB Source Id"
        if(listUniqueIPBId.size() > 0){
            //System.debug('[AP_PTL_01.copyIPAFromPredecessor] listUniqueIPBId Counts: ' + listUniqueIPBId.size());
        
            // Recover all "Inventory Pricing Article"
            Inventory_Pricing_Article__c oIPACloned;
            for(Inventory_Pricing_Article__c oIPA:[Select Id, Inventory_Pricing_Brand__c, Article__c, Bottle_Number__c, BTZ_Charging_Price__c, BTZ_Price_Differential__c, Charging_Price__c, Presence__c, Prix_indiferencie__c, Promotion__c, Promotion_End_Date__c, Promotion_Start_Date__c, Release_Date__c from Inventory_Pricing_Article__c where Inventory_Pricing_Brand__c in :listUniqueIPBId]){
                oIPACloned = oIPA.clone(false);
                
                // Link the "Inventory Pricing Article" to the new "Inventory Pricing Brand"
                for (String sIPBId : mapIPBIPBSourceId.keySet()){
                    if(mapIPBIPBSourceId.get(sIPBId) == oIPA.Inventory_Pricing_Brand__c){
                        oIPACloned.Inventory_Pricing_Brand__c = sIPBId;
                        break;
                    }
                }
                listIPAToInsert.add(oIPACloned);    
            }
            
            // Insert all "Inventory Pricing Article"
            if(listIPAToInsert.size()>0){
                //System.debug('[AP_PTL_01.copyIPAFromPredecessor] listIPAToInsert Counts: ' + listIPAToInsert.size());           
                
                try{
                    insert listIPAToInsert;
                }
                catch(DmlException ex){
                }               
            }
        }
    
        //System.debug('END method AP_PTL_01.copyIPAFromPredecessor');            
    }     
    
    
    public static void updatePTLFromDO(list<PTL__c> lPTL){
        
                    
        List<id> lAccountDOID = new List<id>();
        
        for(PTL__c oPTL:lPTL){
            lAccountDOID.add(oPTL.Account_DO__c);
        }
        
        //List<PTL__c> lPTLChanged = [SELECT id, Account_DO__c, Account_DO__r.Channel__c, Account_DO__r.Sub_Channel__c, Account_DO__r.Predecessor__r.Name from PTL__c where id in:lPTL];
        //Recover values from the Account 
        map<id, Account> mPTLIDToAccountDO = new map<id, Account>([SELECT id, Channel__c, Sub_Channel__c, Predecessor__r.Name, Predecessor__r.AccountNumber, Segmentation__c, Group_Code_Value__c, Adherent_Central_Number__c,Street_N__c,Number_extention__c,Street_type__c,Street_name__c from Account where id in:lAccountDOID and Activity_Domain__r.ExternalID__c=41]);
        /*
        for(Account oAccount:lAccountDO){
            mPTLIDToAccountDO.put(oAccount.id, oAccount);
        }
        */
        //System.debug('[AP_PTL_01.updatePTLFromDO] mPTLIDToAccountDO Counts: ' + mPTLIDToAccountDO.size());   
        
        for(PTL__c PTLChanged:lPTL){
            if (PTLChanged.Account_DO__c != null && mPTLIDToAccountDO.containsKey(PTLChanged.Account_DO__c))
                {
                PTLChanged.Code_Canal__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Channel__c;
                PTLChanged.Sous_canal__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Sub_Channel__c;
                PTLChanged.Nom_de_predecesseur__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Predecessor__r.Name;
                PTLChanged.Matricule_du_predecesseur__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Predecessor__r.AccountNumber;
                PTLChanged.Segmentation__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Segmentation__c;
                PTLChanged.Enseigne__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Group_Code_Value__c;
                PTLChanged.Code_magasin__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Adherent_Central_Number__c;
                PTLChanged.Street_number__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Street_N__c;
                PTLChanged.Number_extention__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Number_extention__c;
                PTLChanged.Street_type__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Street_type__c;
                PTLChanged.Street_name__c = mPTLIDToAccountDO.get(PTLChanged.Account_DO__c).Street_name__c;
              
               
                }
        }
         
         //System.debug('END method AP_PTL_01.updatePTLFromDO');            
                  
    }
    
    /*
    public static void updatePTLACAdministratorValue(list<PTL__c> lPTL){
        
        map<id, User> mPTLIDToUser = new map<id, User>();              
        List<id> lUserID = new List<id>();
        
        
        //System.debug('[AP_PTL_01.updatePTLACAdministratorValue] lPTL Counts: ' + lPTL.size()); 
        
        for(PTL__c oPTL:lPTL){
            lUserID.add(oPTL.AC_administrator__c);
        }
        
        //Recover values from the User 
        List<User> lUser = [SELECT id, AC_Code__c, AC_value__c from User where id in:lUserID];
        
        for(User oUser:lUser){
            mPTLIDToUser.put(oUser.id, oUser);
        }
        
        //System.debug('[AP_PTL_01.updatePTLACAdministratorValue] mPTLIDToUser Counts: ' + mPTLIDToUser.size());   
        
        for(PTL__c PTLChanged:lPTL){
            if (PTLChanged.AC_administrator__c != null && mPTLIDToUser.containsKey(PTLChanged.AC_administrator__c))
                {
                PTLChanged.Code_AC_administrator_value__c = mPTLIDToUser.get(PTLChanged.AC_administrator__c).AC_value__c;
                PTLChanged.Code_AC_administrator__c = mPTLIDToUser.get(PTLChanged.AC_administrator__c).AC_Code__c;
                }
        }
        
        //System.debug('END method AP_PTL_01.updatePTLACAdministratorValue');            
                  
    }
    */
    
    // manage MKT Contact Spot ELC
    public static void managePTLMKTContactELC(list<PTL__c> lPTL){
        map<id,id> mapPTLAccountDO = new map<id,id>();
        String sKeyAccountDO = '';
        Set<String> setAccountDO = new Set<String>();
        List<Id> listUniqueAccountDOId = new list<Id>();
        map<id,id> mAccDOContactMkt = new map<id,id>();
        string sAccountDOId = null; 
     
        //System.debug('START method AP_PTL_01.managePTLMKTContactELC');
        
        // Recover all "Account DO id"
        for(PTL__c oPTL:lPTL){        
            sKeyAccountDO = oPTL.Account_DO__c;
            
            //System.debug('[AP_PTL_01.managePTLMKTContactELC] oPTL.Id: ' + oPTL.Id);
            //System.debug('[AP_PTL_01.managePTLMKTContactELC] sKeyAccountDO: ' + sKeyAccountDO);
                
            if(sKeyAccountDO != null){
                // Recover the list of "Account DO id"
                if(setAccountDO.add(sKeyAccountDO))
                    listUniqueAccountDOId.add(sKeyAccountDO);
                
                // Recover the link "PTL / Account DO"
                mapPTLAccountDO.put(oPTL.Id, sKeyAccountDO);
            }
        } 
        
        // Recover all "MKT Contacts" linked to each Account DO
        if(listUniqueAccountDOId.size() > 0){
            //System.debug('[AP_PTL_01.managePTLMKTContactELC] listUniqueAccountDOId Counts: ' + listUniqueAccountDOId.size());
            
            for(Contact oCont:[Select Id, Name, AccountId, Account.IsPersonAccount, Account.PersonContactId, Contact_Marketing__c from Contact where AccountId =: listUniqueAccountDOId and Contact_Marketing__c = true]){
                if(oCont.Account.IsPersonAccount)
                    mAccDOContactMkt.put(oCont.AccountId, oCont.Account.PersonContactId);
                else
                    mAccDOContactMkt.put(oCont.AccountId, oCont.Id);
            }  
        }             
        
        // Create the link "Marketing contact" on PTL
        for(PTL__c oPTL : lPTL){
            if(mapPTLAccountDO.containsKey(oPTL.Id)){
                sAccountDOId = mapPTLAccountDO.get(oPTL.Id);
                //System.debug('[AP_PTL_01.managePTLMKTContactELC] oPTL.Id: ' + oPTL.Id);
                //System.debug('[AP_PTL_01.managePTLMKTContactELC] sAccountDOId Id: ' + mapPTLAccountDO.get(oPTL.Id));
                if(mAccDOContactMkt.containsKey(sAccountDOId)){
                    //System.debug('[AP_PTL_01.managePTLMKTContactELC] Contact_Marketing__c Id: ' + mAccDOContactMkt.get(sAccountDOId));
                    
                    oPTL.Contact_Marketing__c = mAccDOContactMkt.get(sAccountDOId); 
                }
            }
        }
        update lPTL;
        
        //System.debug('END method AP_PTL_01.managePTLMKTContactELC');      
    }
    
    
    // Erwan 20150810 Update newly created PTL with data from its corresponding OPTL
    public static void updatePTLFromOPTL(list<PTL__c> lPTL){
        
        map<String, Opportunity_PTL__c> mPTLIDToOPTL = new map<String, Opportunity_PTL__c>();              
        List<String> lPTLExternalID = new List<String>();
        
        
        for(PTL__c oPTL:lPTL){
            //System.debug('[AP_PTL_01.updatePTLFromOPTL] oPTL.Account_DO__c: ' + oPTL.ExternalID__c); 
            lPTLExternalID.add(oPTL.ExternalID__c);
        }
        //System.debug('[AP_PTL_01.updatePTLFromOPTL] lPTL Counts: ' + lPTL.size()); 
        
        //Recover values from the OPTL
        List<Opportunity_PTL__c> lOPTL = [select Id, Opportunity__r.DO_AccountNumber__c, Client_ouvert_toute_l_annee__c, Periode_de_fermeture_2_semaines__c, Periode_similaire_tous_les_ans__c, Debut_periode__c, Fin_periode__c, Client_avec_sous_depot__c, Necessaire_de_prevenir_le_client__c, La_presence_systemathique__c, PTL_Customer_presence__c, Emballage_Pivot__c, Consommation_estimee_Butane_10__c, Consommation_estimee_Butane_13__c, Consommation_estimee_Cube_But__c, Consommation_estimee_Cube_Prop__c, Consommation_estimee_propane_13__c, Consommation_estimee_Propane_35__c, Consommation_estimee_Prop_Carb__c, PTL_Shipping_Condition__c, Commande_generer_a_partir_du__c, Frequence_des_premieres_commandes__c, 
            Frequence_semaine_quinzaine_mois__c, Indication_supplementaire__c, Indication_supplementaire_depot__c, Accessible_par_tout_type_de_vehicule__c, Ensemble_semi__c, Porteurs__c, Vehicules_utilitaires__c, Chargement__c, Acces_clients__c, Stationnement__c, Consignes_specifiques__c, Aire_de_livraison__c, Documents__c, Reglement__c, Acces_difficile__c, Acces_reglemente__c, Acces_particulier__c, Reimplantation_date__c, Type_d_implantation__c, Enclos__c, Enclos_sur__c, Presence_pompiste__c, Si_pas_pompiste_ou_partielle__c, Nombre_de_pompes_essence_sur_le_PTL__c, PTL_Drive__c, Preciser_l_emplacement_du_depot_Drive__c, Type_de_Drive__c, Livraison_domicile__c, Distributeur_automatique_bouteilles__c, Marques_distributeurs_aut_bouteilles__c, Presence_distributeur_automatique_cles__c, Marques_distributeurs_cles__c,
            Texte_Chauffeur_2__c, Apporter_le_bon_de_commande__c, Particularites_acces__c, Particularites_HSE__c, Particularites_revendeur__c, Type_de_presentoir_1__c, Type_de_presentoir_2__c, Type_de_presentoir_3__c, Type_de_presentoir_4__c, Type_de_presentoir_5__c, Nombre_type_de_presentoir_1__c, Nombre_type_de_presentoir_2__c, Nombre_type_de_presentoir_3__c, Nombre_type_de_presentoir_4__c, Nombre_type_de_presentoir_5__c, Nombre_de_bandeaux__c, Nombre_de_surmontoirs__c, Presence_porte_affiche_Butagaz__c, Si_oui_sur_quel_presentoir__c, Information_prix__c, Lourde_Legere__c, Presentoirs_autres_marques_presents_30__c, Tete_de_gondole__c, Gribouille__c, Prix_BD_Ref__c, Concurrent_1__c, Concurrent_2__c, Concurrent_3__c, Zone_stockage__c, Bassin_de_vie__c, Depot_de_livraison_PLV__c, 
            Memes_horaires_toute_la_semaine__c, Lundi__c, Mardi__c, Mercredi__c, Jeudi__c, Vendredi__c, Samedi__c, Horaires_preferees_Lundi__c, Horaires_preferees_Mardi__c, Horaires_preferees_Mercredi__c, Horaires_preferees_Jeudi__c, Horaires_preferees_Vendredi__c, Horaires_preferees_Samedi__c, Service_de_Drive__c, Vente_de_Gaz_dans_ce_Drive__c, Marques_de_Gaz_vendues__c, Canal_d_achat_de_la_Bouteille_Butagaz__c, Informations_sur_le_Drive__c, Segmentation__c, Description__c, Nombre_bouteilles_distributeur_cles__c, Prise_de_RDV__c, Texte_Chauffeur__c, PTL_Days_no_Delivery_possible__c, PTL_PDF_Hours_of_delivery_not_possible__c,Nombre_de_bandeaux_courts__c,  Nombre_de_bandeaux_longs__c
            from Opportunity_PTL__c
            where Opportunity__r.Project_Type__c in ('CREA', 'SUCC')
            and Opportunity__r.StageName = 'Closed Won'
            and Opportunity__r.Opportunity_Won_Substage__c = 'Data validated by BO' 
            and Activity_Domain__c = 'GEB - Gaz en bouteille'
            and Opportunity__r.Account.ExternalID__c != null
            and Opportunity__r.Account.ExternalID__c in:lPTLExternalID];
            
            //and Opportunity__r.DO_AccountNumber__c in:lPTLExternalID];
        
        
        for(Opportunity_PTL__c oOPTL:lOPTL){
            //System.debug('[AP_PTL_01.updatePTLFromOPTL] oOPTL.Opportunity__r.DO_AccountNumber__c: ' + oOPTL.Opportunity__r.DO_AccountNumber__c); 
            mPTLIDToOPTL.put(oOPTL.Opportunity__r.DO_AccountNumber__c, oOPTL);
        }
        
        
        //System.debug('[AP_PTL_01.updatePTLFromOPTL] mPTLIDToOPTL Counts: ' + mPTLIDToOPTL.size());
        
        for(PTL__c PTLChanged:lPTL){
            if (PTLChanged.ExternalID__c != null && mPTLIDToOPTL.containsKey(PTLChanged.ExternalID__c))
                {
                PTLChanged.Client_ouvert_toute_l_annee__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Client_ouvert_toute_l_annee__c;
                PTLChanged.Periode_de_fermeture_2_semaines__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Periode_de_fermeture_2_semaines__c;
                PTLChanged.Periode_similaire_tous_les_ans__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Periode_similaire_tous_les_ans__c;
                PTLChanged.Debut_periode__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Debut_periode__c;
                PTLChanged.Fin_periode__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Fin_periode__c;
                PTLChanged.Client_avec_sous_depot__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Client_avec_sous_depot__c;
                PTLChanged.Necessaire_de_prevenir_le_client__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Necessaire_de_prevenir_le_client__c;
                PTLChanged.La_presence_systemathique__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).La_presence_systemathique__c;
                PTLChanged.Customer_presence__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).PTL_Customer_presence__c;
                PTLChanged.Emballage_Pivot__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Emballage_Pivot__c;
                PTLChanged.Consommation_estimee_Butane_10__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Butane_10__c;
                PTLChanged.Consommation_estimee_Butane_13__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Butane_13__c;
                PTLChanged.Consommation_estimee_Cube_But__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Cube_But__c;
                PTLChanged.Consommation_estimee_Cube_Prop__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Cube_Prop__c;
                PTLChanged.Consommation_estimee_propane_13__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_propane_13__c;
                PTLChanged.Consommation_estimee_Propane_35__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Propane_35__c;
                PTLChanged.Consommation_estimee_Prop_Carb__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consommation_estimee_Prop_Carb__c;
                PTLChanged.Shipping_Condition__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).PTL_Shipping_Condition__c;
                PTLChanged.Commande_generer_a_partir_du__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Commande_generer_a_partir_du__c;
                PTLChanged.Frequence_des_premieres_commandes__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Frequence_des_premieres_commandes__c;
                PTLChanged.Frequence_semaine_quinzaine_mois__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Frequence_semaine_quinzaine_mois__c;
                PTLChanged.Indication_supplementaire__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Indication_supplementaire__c;
                PTLChanged.Indication_supplementaire_depot__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Indication_supplementaire_depot__c;
                PTLChanged.Accessible_par_tout_type_de_vehicule__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Accessible_par_tout_type_de_vehicule__c;
                PTLChanged.Ensemble_semi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Ensemble_semi__c;
                PTLChanged.Porteurs__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Porteurs__c;
                PTLChanged.Vehicules_utilitaires__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Vehicules_utilitaires__c;
                PTLChanged.Chargement__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Chargement__c;
                PTLChanged.Acces_clients__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Acces_clients__c;
                PTLChanged.Stationnement__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Stationnement__c;
                PTLChanged.Consignes_specifiques__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Consignes_specifiques__c;
                PTLChanged.Aire_de_livraison__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Aire_de_livraison__c;
                PTLChanged.Documents__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Documents__c;
                PTLChanged.Reglement__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Reglement__c;
                PTLChanged.Acces_difficile__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Acces_difficile__c;
                PTLChanged.Acces_reglemente__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Acces_reglemente__c;
                PTLChanged.Acces_particulier__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Acces_particulier__c;
                PTLChanged.Reimplantation_date__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Reimplantation_date__c;
                PTLChanged.Type_d_implantation__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_d_implantation__c;
                PTLChanged.Enclos__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Enclos__c;
                PTLChanged.Enclos_sur__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Enclos_sur__c;
                PTLChanged.Presence_pompiste__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Presence_pompiste__c;
                PTLChanged.Si_pas_pompiste_ou_partielle__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Si_pas_pompiste_ou_partielle__c;
                PTLChanged.Nombre_de_pompes_essence_sur_le_PTL__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_de_pompes_essence_sur_le_PTL__c;
                PTLChanged.PTL_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).PTL_Drive__c;
                PTLChanged.Preciser_l_emplacement_du_depot_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Preciser_l_emplacement_du_depot_Drive__c;
                PTLChanged.Type_de_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_Drive__c;
                PTLChanged.Livraison_domicile__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Livraison_domicile__c;
                PTLChanged.Distributeur_automatique_bouteilles__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Distributeur_automatique_bouteilles__c;
                PTLChanged.Marques_distributeurs_aut_bouteilles__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Marques_distributeurs_aut_bouteilles__c;
                PTLChanged.Presence_distributeur_automatique_cles__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Presence_distributeur_automatique_cles__c;
                PTLChanged.Marques_distributeurs_cles__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Marques_distributeurs_cles__c;
                PTLChanged.Texte_Chauffeur_2__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Texte_Chauffeur_2__c;
                PTLChanged.Apporter_le_bon_de_commande__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Apporter_le_bon_de_commande__c;
                PTLChanged.Particularites_acces__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Particularites_acces__c;
                PTLChanged.Particularites_HSE__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Particularites_HSE__c;
                PTLChanged.Particularites_revendeur__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Particularites_revendeur__c;
                PTLChanged.Type_de_presentoir_1__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_presentoir_1__c;
                PTLChanged.Type_de_presentoir_2__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_presentoir_2__c;
                PTLChanged.Type_de_presentoir_3__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_presentoir_3__c;
                PTLChanged.Type_de_presentoir_4__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_presentoir_4__c;
                PTLChanged.Type_de_presentoir_5__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Type_de_presentoir_5__c;
                PTLChanged.Nombre_type_de_presentoir_1__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_type_de_presentoir_1__c;
                PTLChanged.Nombre_type_de_presentoir_2__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_type_de_presentoir_2__c;
                PTLChanged.Nombre_type_de_presentoir_3__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_type_de_presentoir_3__c;
                PTLChanged.Nombre_type_de_presentoir_4__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_type_de_presentoir_4__c;
                PTLChanged.Nombre_type_de_presentoir_5__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_type_de_presentoir_5__c;
                PTLChanged.Nombre_de_bandeaux__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_de_bandeaux__c;
                PTLChanged.Nombre_de_surmontoirs__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_de_surmontoirs__c;
                PTLChanged.Presence_porte_affiche_Butagaz__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Presence_porte_affiche_Butagaz__c;
                PTLChanged.Si_oui_sur_quel_presentoir__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Si_oui_sur_quel_presentoir__c;
                PTLChanged.Information_prix__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Information_prix__c;
                PTLChanged.Lourde_Legere__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Lourde_Legere__c;
                PTLChanged.Presentoirs_autres_marques_presents_30__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Presentoirs_autres_marques_presents_30__c;
                PTLChanged.Tete_de_gondole__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Tete_de_gondole__c;
                PTLChanged.Gribouille__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Gribouille__c;
                PTLChanged.Prix_BD_Ref__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Prix_BD_Ref__c;
                PTLChanged.Concurrent_1__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Concurrent_1__c;
                PTLChanged.Concurrent_2__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Concurrent_2__c;
                PTLChanged.Concurrent_3__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Concurrent_3__c;
                PTLChanged.Zone_stockage__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Zone_stockage__c;
                PTLChanged.Bassin_de_vie__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Bassin_de_vie__c;
                PTLChanged.Depot_de_livraison_PLV__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Depot_de_livraison_PLV__c;
                
                // ELC Ajout 15/01/2016
                PTLChanged.Memes_horaires_toute_la_semaine__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Memes_horaires_toute_la_semaine__c;
                PTLChanged.Horaires_possible_Lundi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Lundi__c;
                PTLChanged.Horaires_possible_Mardi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Mardi__c;
                PTLChanged.Horaires_possible_Mercredi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Mercredi__c;
                PTLChanged.Horaires_possible_Jeudi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Jeudi__c;
                PTLChanged.Horaires_possible_Vendredi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Vendredi__c;
                PTLChanged.Horaires_possible_Samedi__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Samedi__c;
                PTLChanged.Horaires_preferees_Lundi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Lundi__c;
                PTLChanged.Horaires_preferees_Mardi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Mardi__c;
                PTLChanged.Horaires_preferees_Mercredi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Mercredi__c;
                PTLChanged.Horaires_preferees_Jeudi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Jeudi__c;
                PTLChanged.Horaires_preferees_Vendredi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Vendredi__c;
                PTLChanged.Horaires_preferees_Samedi_txt__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Horaires_preferees_Samedi__c;
                PTLChanged.Service_de_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Service_de_Drive__c;
                PTLChanged.Vente_de_Gaz_dans_ce_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Vente_de_Gaz_dans_ce_Drive__c;
                PTLChanged.Marques_de_Gaz_vendues__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Marques_de_Gaz_vendues__c;
                PTLChanged.Canal_d_achat_de_la_Bouteille_Butagaz__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Canal_d_achat_de_la_Bouteille_Butagaz__c;
                PTLChanged.Informations_sur_le_Drive__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Informations_sur_le_Drive__c;
                PTLChanged.Segmentation__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Segmentation__c;
                PTLChanged.Description__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Description__c;
                PTLChanged.Nombre_bouteilles_distributeur_cles__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_bouteilles_distributeur_cles__c;
                
                PTLChanged.Prise_de_RDV__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Prise_de_RDV__c;
                PTLChanged.Texte_Chauffeur__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Texte_Chauffeur__c;
                PTLChanged.Days_no_Delivery_possible__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).PTL_Days_no_Delivery_possible__c;
                PTLChanged.PDF_Hours_of_delivery_not_possible__c = mPTLIDToOPTL.get(PTLChanged.ExternalID__c).PTL_PDF_Hours_of_delivery_not_possible__c;
                
               //MLC ajout 20201217
                PTLChanged.Nombre_de_bandeaux_courts__c= mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_de_bandeaux_courts__c;
                PTLChanged.Nombre_de_bandeaux_longs__c= mPTLIDToOPTL.get(PTLChanged.ExternalID__c).Nombre_de_bandeaux_longs__c;        
                
                                                                                                                                  
                                                                                                                                
                }
        }
        
        //System.debug('END method AP_PTL_01.updatePTLFromOPTL');            
                  
    }
    
    
    /*
    // Erwan 20160120 Update newly created PTL Prix_BD_Ref__c with BTZ_Charging_Price__c 
    // from Predecessor last inventory price for Butagaz brand
    public static void updatePTLPrixBDRefOnSuccession(list<PTL__c> lPTL){
        
        //map<String, Inventory_Pricing_Brand__c> mPTLIDToIPB = new map<String, Inventory_Pricing_Brand__c>();              
        map<String, Inventory_Pricing_Article__c> mPTLIDToIPA = new map<String, Inventory_Pricing_Article__c>();
        List<String> lPTLExternalID = new List<String>();
        List<String> lPTLPredExternalID = new List<String>();
        List<PTL__c> listPTLToUpdate = new list<PTL__c>();
        
        
        for(PTL__c oPTL:lPTL){
            //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] oPTL.ExternalID__c: ' + oPTL.ExternalID__c);
            //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] oPTL.Matricule_du_predecesseur__c: ' + oPTL.Matricule_du_predecesseur__c);
            lPTLExternalID.add(oPTL.ExternalID__c);
            lPTLPredExternalID.add(oPTL.Matricule_du_predecesseur__c);
        }
        //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] lPTL Counts: ' + lPTL.size()); 
        
        //Recover values from the OPTL
        List<Inventory_Pricing_Brand__c> lIPB = [
            SELECT Inventory_pricing__r.PTL__r.ExternalID__c, Brand_Name__c, 
                ( SELECT BTZ_Charging_Price__c 
                FROM Inventory_Pricing_Articles__r 
                WHERE Article__r.ExternalID__c = '000000000000000100' ) Article
            FROM Inventory_Pricing_Brand__c 
            WHERE Presence__c = True AND Release_Date__c = Null AND Brand_Name__c = 'Butagaz'
            AND Inventory_pricing__r.T_IsPTLLastIPDate__c = True
            AND Inventory_pricing__r.PTL__r.ExternalID__c in:lPTLPredExternalID];
        
        
        for(Inventory_Pricing_Brand__c oIPB:lIPB){
            //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] oIPB.Inventory_pricing__r.PTL__r.ExternalID__c: ' + oIPB.Inventory_pricing__r.PTL__r.ExternalID__c);
            for(Inventory_Pricing_Article__c oIPA:oIPB.getSObjects('Inventory_Pricing_Article__c')){
                //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] oIPA: ' + oIPA);
                //mPTLIDToIPB.put(oIPB.Inventory_pricing__r.PTL__r.ExternalID__c, oIPB);
                mPTLIDToIPA.put(oIPB.Inventory_pricing__r.PTL__r.ExternalID__c, oIPA);
            }
        }
        
        
        //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] mPTLIDToIPA Counts: ' + mPTLIDToIPA.size());
        
        for(PTL__c PTLChanged:lPTL){
            if (PTLChanged.ExternalID__c != null && mPTLIDToIPA.containsKey(PTLChanged.ExternalID__c))
                {
                    //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] PTLChanged.ExternalID__c: ' + PTLChanged.ExternalID__c);
                    //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] mPTLIDToIPA.get(PTLChanged.ExternalID__c).BTZ_Charging_Price__c: ' + mPTLIDToIPA.get(PTLChanged.ExternalID__c).BTZ_Charging_Price__c);
                    PTLChanged.Prix_BD_Ref__c = mPTLIDToIPA.get(PTLChanged.ExternalID__c).BTZ_Charging_Price__c;
                    //listPTLToUpdate.add(PTLChanged);
                }
        }
        
        // Update all "PTL"
        //if(listPTLToUpdate.size()>0){
        //    //System.debug('[AP_PTL_01.updatePTLPrixBDRefOnSuccession] listPTLToUpdate Counts: ' + listPTLToUpdate.size());          
        //    
        //    try{
        //        update listPTLToUpdate;
        //    }
        //    catch(DmlException ex){
        //    }
        //}
        
        //System.debug('END method AP_PTL_01.updatePTLPrixBDRefOnSuccession');            
                  
    }
    */
    
    public static boolean hasAlreadyUpdatedPTL() {
        return alreadyUpdatedPTL;
    }
        
    public static void setAlreadyUpdatedPTL(boolean b) {
        alreadyUpdatedPTL = b;
    }
    
    
     //MLC 20170131 |si pas renseigne mise a jour tel portable du compte avec celui du ptl.
   /*  public static void updateTelPTLToAccount(List<PTL__c> PTLToValidate) { 

           //System.debug('[AP_PTL.updateTelPTLToAccount] START');
           //System.debug('[AP_PTL.updateTelPTLToAccount] PTL' + PTLToValidate );
              
           Set<string> sAccountId = new Set<string>();
           Set<string> sPTLId = new Set<string>(); 
           Set<string> sContratId = new Set<string>();
           List<Account> lAccountLocataire= new List<Account> ();
           
           for(PTL__c PTLTeltoAccount:PTLToValidate)
           {
                 if(!sPTLId.contains(PTLTeltoAccount.id))sPTLId.add(PTLTeltoAccount.id);
                 
           }
           
           //System.debug('[AP_PTL.updateTelPTLToAccount] Avant la liste');
           //System.debug('[AP_PTL.updateTelPTLToAccount] sPTLId ' + sPTLId );
           
           
           List<Account> lAccountPtl=([ SELECT id,Mobile_Phone_Number__c,Bailleur__c  FROM Account WHERE Id  in ( select Account_DO__c from PTL__c where id =:  sPTLId )]);

                               
           for(PTL__c ptl:PTLToValidate) 
           {
           
                for(Account accountptl:lAccountPtl)
                {
                    if (accountptl.Mobile_Phone_Number__c == null && accountptl.Bailleur__c == false)
                    
                    {
                        //System.debug('[AP_PTL.updateTelPTLToAccount] pas bailleur tel vide '  );
                       
                        accountptl.Mobile_Phone_Number__c = ptl.Mobile_Phone_Number__c;
                    }
                    
                    else
                    {
                        if ( accountptl.Bailleur__c == true)
                        {
                             
                             //System.debug('[AP_PTL.updateTelPTLToAccount] PTL - Bailleur ok' );  
                      
                             List<Account_in_Contract__c> lAccountContrat = ([ SELECT Id, Account__c, Contract__r.Contract_Type__c, Contract__r.T_Contract_end_calcualtion__c ,Role__c,Contract__c
                                                                                FROM Account_in_Contract__c 
                                                                                WHERE Account__c =: accountptl.id AND Role__c =:'ZP']);
                               
                              for ( Account_in_Contract__c AccountContrat : lAccountContrat) 
                              {
                              
                                    //System.debug('[AP_PTL.updateTelPTLToAccount] PTL - bailleur contrat' +  lAccountContrat);                                     
                                                                    
                                    List<Account_in_Contract__c> lAccountContratLocataire = ([ SELECT Id, Account__c, Contract__r.Contract_Type__c, Contract__r.T_Contract_end_calcualtion__c ,Role__c,Contract__c
                                                                    FROM Account_in_Contract__c 
                                                                    WHERE Contract__c =: AccountContrat.Contract__c AND Role__c =:'ZO' ])   ; 
                                                                    
                                
                                 
                                    for ( Account_in_Contract__c  AccountContratLocataire : lAccountContratLocataire)
                                    {

                                      //System.debug('[AP_PTL.updateTelPTLToAccount] liste locataire ' +  AccountContratLocataire.Account__c  );
                                      
                                        lAccountLocataire=([ SELECT id,Mobile_Phone_Number__c,Bailleur__c FROM Account WHERE Id =: AccountContratLocataire.Account__c ]); 
                                        
                                        for (Account   AccountLocataire :  lAccountLocataire ) 
                                        
                                        {
                                                  //System.debug('[AP_PTL.updateTelPTLToAccount] liste locataire tel vide '  );
                                                
                                                if (AccountLocataire.Mobile_Phone_Number__c == null)
                                                
                                                {
                                                     //System.debug('[AP_PTL.updateTelPTLToAccount] liste locataire tel vide ' + AccountLocataire.Mobile_Phone_Number__c  );
                                                    AccountLocataire.Mobile_Phone_Number__c =  ptl.Mobile_Phone_Number__c;
                                                
                                                }
                                        
                                        }
                                        

                                    }

                              }
                                                        
                        }
                    
                    }
                  
                }
 
           }

                if (lAccountLocataire.size()>0) update lAccountLocataire;
                if (lAccountPtl.size()>0) update lAccountPtl;
    
                
} */

                                                 
   //MLC 2017 MAJ des conditions d'expédition du ptl vers le compte
  //Erwan 20200313 : Method modified to fix bug
    public static void updateShippingConditionAccount(List<PTL__c> PTLToValidate) {
        //System.debug('[AP_PTL.updateShippingConditionAccount] START');
        //System.debug('[AP_PTL.updateShippingConditionAccount] PTL' + PTLToValidate );
           
        Set<string> sAccountId = new Set<string>();
        Set<string> sPTLId = new Set<string>(); 
        Set<string> sShippingCondition = new Set<string>();
        
        for(PTL__c PTLSCtoAccount:PTLToValidate)
        {
              if(!sPTLId.contains(PTLSCtoAccount.id))sPTLId.add(PTLSCtoAccount.id);
              
        }
        
        //System.debug('[AP_PTL.updateShippingConditionAccount] Avant la liste');
        //System.debug('[AP_PTL.updateShippingConditionAccount] sPTLId ' + sPTLId );
        
        List<Account> lAccountPtl=([ SELECT id,Shipping_Condition__c  FROM Account WHERE  Activity_Domain_Simple__c ='geb' AND Id  in ( select Account_DO__c from PTL__c where id =:  sPTLId )]);
                            
        for(PTL__c ptl:PTLToValidate) 
        {
             for(Account accountptl:lAccountPtl)
             {
                 if (accountptl.Shipping_Condition__c == null )
                 {
                     //System.debug('[AP_PTL.updateShippingConditionAccount] Shipping Condition tel vide '  );
                    
                     accountptl.Shipping_Condition__c = ptl.Shipping_Condition__c;
                 }
             }
          
        }

        if (lAccountPtl.size()>0) update lAccountPtl;

/*     
    Set<string> accIdSet = new Set<string>();
    for(PTL__c ptl : PTLToValidate){
      if(ptl.Account_DO__c != null && !accIdSet.contains(ptl.Account_DO__c)) accIdSet.add(ptl.Account_DO__c);
    }
    
    Map<Id, Account> parentAccounts = new Map<Id, Account>();
    parentAccounts = new Map<Id, Account>([SELECT Id, Shipping_Condition__c FROM Account WHERE Activity_Domain_Simple__c ='geb' AND Id IN :accIdSet]);
    
    for (PTL__c ptl: PTLToValidate) {
      if(ptl.Account_DO__c != null){
        Account parentAcc = parentAccounts.get(ptl.Account_DO__c);
        if (parentAcc.Shipping_Condition__c == null) {
          parentAcc.Shipping_Condition__c = ptl.Shipping_Condition__c;
        }
      }
    }
    update parentAccounts.values();
 */   
  } 
  
    @future
    public static void updatePredecessorwithSuccessor_Async(Set<id> listPTL){
        
        Map<id,PTL__c> mapPTLNew = New Map<id,PTL__c> ([Select Id, Name,T_SuccesseurIdPTL__c,PTL_succession__c,T_PredecesseurId__c,Matricule_du_predecesseur__c,Account_DO__c from PTL__c where id in: listPTL]);
        updatePredecessorwithSuccessor(mapPTLNew);
    }
    
    public static void updatePredecessorwithSuccessor(Map<id,PTL__c> mapPTLNew){
        
        // parcour de la liste de PTL pour récupérer le compte DO
        List<id> listIdAccDOPltNew = new List<Id>();
        for( PTL__c lePTL : mapPTLNew.values()){
            if(lePTl.T_SuccesseurIdPTL__c ==null){
                listIdAccDOPltNew.add(lePTL.Account_DO__c);
            }
            
        }
        // éviter la recursivite lors de la mise à jour des prédécessor
        if (!listIdAccDOPltNew.isEmpty()){
            
            // récupération map des compte do du successor
            Map<id,Account> mapAccountDoSucc = new Map<Id,Account> ([Select Id, Predecessor__c from Account where Id in :listIdAccDOPltNew and Predecessor__c != null and Activity_Domain__r.ExternalID__c=41]);
            
            // construire la liste des Id Account Prédecessor
            map<id,id> mapIdAccSuccAccPred = new   map<id,id>();
            List<id> listIdAccPred =New List<id>();
            for( Account accSucc : mapAccountDoSucc.values()){
                mapIdAccSuccAccPred.put(accSucc.id,accSucc.Predecessor__c);
                listIdAccPred.add(accSucc.Predecessor__c);
            }
            
            if(!listIdAccPred.isEmpty()){
                // récupéré les PTL Predecessor
                Map< Id, PTL__c> mapIdPTLPred = new Map< Id, PTL__c>([Select Id, Name,PTL_succession__c,T_PredecesseurId__c,Matricule_du_predecesseur__c,Account_DO__c from PTL__c where Account_DO__c in :mapIdAccSuccAccPred.values()  and PTL_succession__c = true]);
                
                // construire une map des compte do du prédecessor
                Map<id,id> mapIdAccPredIdPTLPred =new  Map<id,id>();
                for( PTL__c oPTLPred : mapIdPTLPred.values()){
                    mapIdAccPredIdPTLPred.put( oPTLPred.Account_DO__c,oPTLPred.Id);
                }
                
                // mise à jour des PTL successor 
                list<id> listIdPtlPred =new list<id>();
                list<PTL__c> listPTLPredAMettreAJour =New list<PTL__c> ();
                for( PTL__c oPTLSucc : mapPTLNew.values()){
                    if(mapAccountDoSucc.containsKey(oPTLSucc.Account_DO__c)){
                        Account monDO=mapAccountDoSucc.get(oPTLSucc.Account_DO__c);
                        if(mapIdAccPredIdPTLPred.containsKey(monDO.Predecessor__c)){
                            id idPTLPred=mapIdAccPredIdPTLPred.get(monDO.Predecessor__c);
                            if(mapIdPTLPred.containsKey(idPTLPred)){
                                PTL__c oPTLPred = mapIdPTLPred.get(idPTLPred);
                                oPTLPred.T_SuccesseurIdPTL__c=oPTLSucc.Id;
                                oPTLPred.T_SuccesseurNamePTL__c=oPTLSucc.Name;
                                oPTLPred.T_SuccesseurIdAccount__c= oPTLSucc.Account_DO__c;
                                listPTLPredAMettreAJour.add(oPTLPred);
                                listIdPtlPred.add(idPTLPred);
                            }
                        }
                    }
                }             
                update listPTLPredAMettreAJour;
                transfertEventToPTLSuccessor(listIdPtlPred);
            }
            
        }
        
        
    }

    //@future
     public static void transfertEventToPTLSuccessor(List<id> listeIdPtlPred){ 
        List<Event> listEvent = new List<Event>([SELECT Id, WhatId, Subject FROM Event where WhatId in:listeIdPtlPred]); 
        Map<id,PTL__c> mapPTL = new  Map<id,PTL__c> ([Select Id, Name,PTL_succession__c,T_SuccesseurIdPTL__c,T_PredecesseurId__c,Matricule_du_predecesseur__c,Account_DO__c from PTL__c where id in :listeIdPtlPred  and PTL_succession__c = true]);
         for(Event evt: listEvent){
           PTL__c ptlPred= mapPTL.get(evt.WhatId);
             evt.WhatId=ptlPred.T_SuccesseurIdPTL__c;
             evt.T_PredecesseurRef__c=ptlPred.Name;
         }
      update listEvent;
    }

    public static void recupererVisitePredecessor(Map<id,PTL__c> mapPtlNew){
        for(PTL__c lePTL :mapPtlNew.values()){
            
        }
    }
      
}