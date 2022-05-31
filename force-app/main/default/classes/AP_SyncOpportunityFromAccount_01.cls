public class AP_SyncOpportunityFromAccount_01 {
    public static Map<Id, Account> getAccounts(List<Opportunity> lOpportunitys){
        // Sync the created Opportunitys with their Accounts
        Set<Id> sAccountIds = new Set<Id>();
        for (Opportunity oOpportunity : lOpportunitys){
            sAccountIds.add(oOpportunity.AccountId);
                System.debug('[AP_SyncOpportunityFromAccount_01.getAccounts] Adding ID from [oOpportunity.AccountId( ' + oOpportunity.Id + ')] : [' + oOpportunity.AccountId + ']');
            sAccountIds.add(oOpportunity.Account_Payer__c);
                System.debug('[AP_SyncOpportunityFromAccount_01.getAccounts] Adding ID from [oOpportunity.Account_Payer__c( ' + oOpportunity.Id + ')] : [' + oOpportunity.Account_Payer__c + ']');
            sAccountIds.add(oOpportunity.Account_Billed__c);
                System.debug('[AP_SyncOpportunityFromAccount_01.getAccounts] Adding ID from [oOpportunity.Account_Billed__c( ' + oOpportunity.Id + ')] : [' + oOpportunity.Account_Billed__c + ']');
            
        }

        System.debug('[AP_SyncOpportunityFromAccount_01.getAccounts] Ids of Queried Objects: [' + sAccountIds + ']');

        return new Map<Id, Account>([
            SELECT
                Id,
                // BEGIN_AUTO_Account_FIELDS
                Accounting_Manager_Value__c,
                Department__c,
                Scale__c,
                Group_Code_Value__c,
                Payment_Time_Value__c,
                Activity_Domain__c,
                Affiliate_Networks__c,
                Accounting_Manager_Code__c,
                Name,
                Adherent_Central_Number__c,
                City_code__c,
                //No_E_mail__c,
                Place_Called__c,
                Fax,
                Mobile_Phone_Number__c,
                //Optin_1__c,
                Postal_Code__c,
                Work_Phone_Number__c,
                Street_N__c,
                Street_name__c,
                Phone,
                Number_extention__c,
                Price_Group__c,
                Sub_Channel__c,
                Mandataire__c,
                Bymail__c,
                Payment_method__c,
                Street_Number__c,
                Invoicing_Frequency__c,
                Street_type__c,
                Market_Type__c,
                R_C_S_or_R_C_M_Number__c,
                Segmentation__c,
                //Optin_2__c,
                Hierarchy_Level__c,
                ParentId,
                Active__c,
                Market_Sub_Type__c,
                Group_Code__c,
                Salutation__c,
                Bysms__c,
                //Email__c,
                Postal_Box__c,
                Phone_Restriction__c,
                City__c,
                Type__c,
                City_Postal_Code__c,
                AccountNumber,
                Payment_Time_Code__c,
                Code_NAF__c,
                Country__c,
                Cedex__c,
                Price_information__c,
                //Email_2__c,
                Code_SIRET__c,
                TVA__c,
                En_cours_d_immatriculation__c,
                Indicatif_Pays__c,
                Chorus_Souscrit__c,
                EngagementJuridique_Chorus__c,
                ServiceExecutant_Chorus__c,
                Compte_Superieur__c
                // END_AUTO_Account_FIELDS
            FROM  Account
            WHERE Id IN :sAccountIds
        ]);
    }

    public static void syncOpportunityFromAccount(Map<Id, Opportunity> mOpportunitysBeforeUpdate, Map<Id, Opportunity> mOpportunitysAfterUpdate){
        // If we change an Account (DO, Payer of Billed) to the Opportunity, its fields should be synced
        // with the Actual Accounts themselves.

        Map<Id, Account> mAccounts = AP_SyncOpportunityFromAccount_01.getAccounts(mOpportunitysAfterUpdate.values());

        for (Opportunity oOpportunity : mOpportunitysAfterUpdate.values()){
            if (mOpportunitysBeforeUpdate.get(oOpportunity.Id).AccountId != oOpportunity.AccountId){
                    AP_SyncOpportunityFromAccount_01.syncDO_Fields(oOpportunity, mAccounts);
                }
            if (mOpportunitysBeforeUpdate.get(oOpportunity.Id).Account_Payer__c != oOpportunity.Account_Payer__c){
                    AP_SyncOpportunityFromAccount_01.syncPayer_Fields(oOpportunity, mAccounts);
                }
            if (mOpportunitysBeforeUpdate.get(oOpportunity.Id).Account_Billed__c != oOpportunity.Account_Billed__c){
                    AP_SyncOpportunityFromAccount_01.syncBilled_Fields(oOpportunity, mAccounts);
                }
            
        }
    }

    public static void syncOpportunityFromAccount(List<Opportunity> lOpportunitys){
        // When we create an Opportunity, we should add the fields form the Accounts (DO, Payer, Billed) to
        // the Account Fields on the Opportunity.
        Map<Id, Account> mAccounts = AP_SyncOpportunityFromAccount_01.getAccounts(lOpportunitys);
        System.debug('[AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount]: lOpportunitys:' + lOpportunitys);
        System.debug('[AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount]: SIZE(lOpportunitys):' + lOpportunitys.size());
        System.debug('[AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount]: mAccounts:' + mAccounts);
        System.debug('[AP_SyncOpportunityFromAccount_01.syncOpportunityFromAccount]: SIZE(mAccounts):' + mAccounts.keySet().size());

        for (Opportunity oOpportunity : lOpportunitys){
            AP_SyncOpportunityFromAccount_01.syncDO_Fields(oOpportunity, mAccounts);
            AP_SyncOpportunityFromAccount_01.syncPayer_Fields(oOpportunity, mAccounts);
            AP_SyncOpportunityFromAccount_01.syncBilled_Fields(oOpportunity, mAccounts);
            
        }
    }

    public static void syncDO_Fields(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.AccountId != null){
            Account oAccount = mAccounts.get(oOpportunity.AccountId); // This can't be null. If the Account is not null then it's an Account AND we queried it!
            // BEGIN_AUTO_SYNC_Account
            oOpportunity.DO_Accounting_Manager_Code__c = oAccount.Accounting_Manager_Code__c;
            oOpportunity.DO_Accounting_Manager_Value__c = oAccount.Accounting_Manager_Value__c;
            oOpportunity.DO_Active__c = oAccount.Active__c;
            oOpportunity.DO_Activity_Domain__c = oAccount.Activity_Domain__c;
            oOpportunity.DO_Adherent_Central_Number__c = oAccount.Adherent_Central_Number__c;
            oOpportunity.DO_Affiliate_Networks__c = oAccount.Affiliate_Networks__c;
            oOpportunity.DO_Bymail__c = oAccount.Bymail__c;
            oOpportunity.DO_Bysms__c = oAccount.Bysms__c;
            oOpportunity.DO_Cedex__c = oAccount.Cedex__c;
            oOpportunity.DO_City_Postal_Code__c = oAccount.City_Postal_Code__c;
            oOpportunity.DO_City__c = oAccount.City__c;
            oOpportunity.DO_City_code__c = oAccount.City_code__c;
            oOpportunity.DO_Code_NAF__c = oAccount.Code_NAF__c;
            oOpportunity.DO_Code_SIRET__c = oAccount.Code_SIRET__c;
            oOpportunity.DO_Country__c = oAccount.Country__c;
            oOpportunity.DO_Department__c = oAccount.Department__c;
            //oOpportunity.DO_Email_2__c = oAccount.Email_2__c;
            //oOpportunity.DO_Email__c = oAccount.Email__c;
            oOpportunity.DO_En_cours_d_immatriculation__c = oAccount.En_cours_d_immatriculation__c;
            oOpportunity.DO_Group_Code_Value__c = oAccount.Group_Code_Value__c;
            oOpportunity.DO_Group_Code__c = oAccount.Group_Code__c;
            oOpportunity.DO_Hierarchy_Level__c = oAccount.Hierarchy_Level__c;
            oOpportunity.DO_Invoicing_Frequency__c = oAccount.Invoicing_Frequency__c;
            oOpportunity.DO_Mandataire__c = oAccount.Mandataire__c;
            oOpportunity.DO_Market_Sub_Type__c = oAccount.Market_Sub_Type__c;
            oOpportunity.DO_Market_Type__c = oAccount.Market_Type__c;
            oOpportunity.DO_Mobile_Phone_Number__c = oAccount.Mobile_Phone_Number__c;
            //oOpportunity.DO_No_E_mail__c = oAccount.No_E_mail__c;
            oOpportunity.DO_Number_extention__c = oAccount.Number_extention__c;
            //oOpportunity.DO_Optin_1__c = oAccount.Optin_1__c;
            //oOpportunity.DO_Optin_2__c = oAccount.Optin_2__c;
            oOpportunity.DO_Payment_Time_Code__c = oAccount.Payment_Time_Code__c;
            oOpportunity.DO_Payment_Time_Value__c = oAccount.Payment_Time_Value__c;
            oOpportunity.DO_Payment_method__c = oAccount.Payment_method__c;
            oOpportunity.DO_Phone_Restriction__c = oAccount.Phone_Restriction__c;
            oOpportunity.DO_Place_Called__c = oAccount.Place_Called__c;
            oOpportunity.DO_Postal_Box__c = oAccount.Postal_Box__c;
            oOpportunity.DO_Postal_Code__c = oAccount.Postal_Code__c;
            oOpportunity.DO_Price_Group__c = oAccount.Price_Group__c;
            oOpportunity.DO_Price_information__c = oAccount.Price_information__c;
            oOpportunity.DO_R_C_S_or_R_C_M_Number__c = oAccount.R_C_S_or_R_C_M_Number__c;
            oOpportunity.DO_Salutation__c = oAccount.Salutation__c;
            oOpportunity.DO_Scale__c = oAccount.Scale__c;
            oOpportunity.DO_Segmentation__c = oAccount.Segmentation__c;
            oOpportunity.DO_Street_N__c = oAccount.Street_N__c;
            oOpportunity.DO_Street_Number__c = oAccount.Street_Number__c;
            oOpportunity.DO_Street_name__c = oAccount.Street_name__c;
            oOpportunity.DO_Street_type__c = oAccount.Street_type__c;
            oOpportunity.DO_Sub_Channel__c = oAccount.Sub_Channel__c;
            oOpportunity.DO_Type__c = oAccount.Type__c;
            oOpportunity.DO_Work_Phone_Number__c = oAccount.Work_Phone_Number__c;
            oOpportunity.DO_Phone__c = oAccount.Phone;
            oOpportunity.DO_Name__c = String.isBlank(oAccount.Name) ? null : oAccount.Name.left(27);
            oOpportunity.DO_ParentId__c = oAccount.ParentId;
            oOpportunity.DO_AccountNumber__c = oAccount.AccountNumber;
            oOpportunity.DO_Indicatif_pays__c = oAccount.Indicatif_Pays__c;
            oOpportunity.Chorus_Souscrit__c = oAccount.Chorus_Souscrit__c;
            oOpportunity.EngagementJuridique_Chorus__c = oAccount.EngagementJuridique_Chorus__c;
            oOpportunity.ServiceExecutant_Chorus__c = oAccount.ServiceExecutant_Chorus__c;
            oOpportunity.Compte_Optimo__c = oAccount.Compte_Superieur__c;
            // END_AUTO_SYNC_Account
        }
    }
    public static void syncPayer_Fields(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Payer__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Payer__c); // This can't be null. If the Account is not null then it's an Account AND we queried it!
            // BEGIN_AUTO_SYNC_Account_Payer__r
            oOpportunity.Payer_Accounting_Manager_Code__c = oAccount.Accounting_Manager_Code__c;
            oOpportunity.Payer_Accounting_Manager_Value__c = oAccount.Accounting_Manager_Value__c;
            oOpportunity.Payer_Cedex__c = oAccount.Cedex__c;
            oOpportunity.Payer_City_Postal_Code__c = oAccount.City_Postal_Code__c;
            oOpportunity.Payer_City__c = oAccount.City__c;
            oOpportunity.Payer_City_code__c = oAccount.City_code__c;
            oOpportunity.Payer_Country__c = oAccount.Country__c;
            oOpportunity.Payer_Department__c = oAccount.Department__c;
            //oOpportunity.Payer_Email_2__c = oAccount.Email_2__c;
            //oOpportunity.Payer_Email__c = oAccount.Email__c;
            oOpportunity.Payer_Invoicing_Frequency__c = oAccount.Invoicing_Frequency__c;
            oOpportunity.Payer_Mobile_Phone_Number__c = oAccount.Mobile_Phone_Number__c;
            //oOpportunity.Payer_No_E_mail__c = oAccount.No_E_mail__c;
            oOpportunity.Payer_Number_extention__c = oAccount.Number_extention__c;
            oOpportunity.Payer_Payment_Time_Code__c = oAccount.Payment_Time_Code__c;
            oOpportunity.Payer_Payment_Time_Value__c = oAccount.Payment_Time_Value__c;
            oOpportunity.Payer_Payment_method__c = oAccount.Payment_method__c;
            oOpportunity.Payer_Phone_Restriction__c = oAccount.Phone_Restriction__c;
            oOpportunity.Payer_Place_Called__c = oAccount.Place_Called__c;
            oOpportunity.Payer_Postal_Box__c = oAccount.Postal_Box__c;
            oOpportunity.Payer_Postal_Code__c = oAccount.Postal_Code__c;
            oOpportunity.Payer_Salutation__c = oAccount.Salutation__c;
            oOpportunity.Payer_Scale__c = oAccount.Scale__c;
            oOpportunity.Payer_Street_N__c = oAccount.Street_N__c;
            oOpportunity.Payer_Street_name__c = oAccount.Street_name__c;
            oOpportunity.Payer_Street_type__c = oAccount.Street_type__c;
            oOpportunity.Payer_Work_Phone_Number__c = oAccount.Work_Phone_Number__c;
            oOpportunity.Payer_Fax__c = oAccount.Fax;
            oOpportunity.Payer_Phone__c = oAccount.Phone;
            oOpportunity.Payer_Name__c = oAccount.Name;
            oOpportunity.Payer_AccountNumber__c = oAccount.AccountNumber;
            oOpportunity.Payer_Siret__c = oAccount.Code_SIRET__c;
            oOpportunity.Payer_TVA__c = oAccount.TVA__c;
            
            // END_AUTO_SYNC_Account_Payer__r
        }
    }
    public static void syncBilled_Fields(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Billed__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Billed__c); // This can't be null. If the Account is not null then it's an Account AND we queried it!
            // BEGIN_AUTO_SYNC_Account_Billed__r
            oOpportunity.Billed_Accounting_Manager_Code__c = oAccount.Accounting_Manager_Code__c;
            oOpportunity.Billed_Accounting_Manager_Value__c = oAccount.Accounting_Manager_Value__c;
            oOpportunity.Billed_Cedex__c = oAccount.Cedex__c;
            oOpportunity.Billed_City_Postal_Code__c = oAccount.City_Postal_Code__c;
            oOpportunity.Billed_City__c = oAccount.City__c;
            oOpportunity.Billed_City_code__c = oAccount.City_code__c;
            oOpportunity.Billed_Country__c = oAccount.Country__c;
            oOpportunity.Billed_Department__c = oAccount.Department__c;
            //oOpportunity.Billed_Email_2__c = oAccount.Email_2__c;
            //oOpportunity.Billed_Email__c = oAccount.Email__c;
            oOpportunity.Billed_Invoicing_Frequency__c = oAccount.Invoicing_Frequency__c;
            oOpportunity.Billed_Mobile_Phone_Number__c = oAccount.Mobile_Phone_Number__c;
            //oOpportunity.Billed_No_E_mail__c = oAccount.No_E_mail__c;
            oOpportunity.Billed_Number_extention__c = oAccount.Number_extention__c;
            oOpportunity.Billed_Payment_Time_Code__c = oAccount.Payment_Time_Code__c;
            oOpportunity.Billed_Payment_Time_Value__c = oAccount.Payment_Time_Value__c;
            oOpportunity.Billed_Payment_method__c = oAccount.Payment_method__c;
            oOpportunity.Billed_Phone_Restriction__c = oAccount.Phone_Restriction__c;
            oOpportunity.Billed_Place_Called__c = oAccount.Place_Called__c;
            oOpportunity.Billed_Postal_Box__c = oAccount.Postal_Box__c;
            oOpportunity.Billed_Postal_Code__c = oAccount.Postal_Code__c;
            oOpportunity.Billed_Salutation__c = oAccount.Salutation__c;
            oOpportunity.Billed_Scale__c = oAccount.Scale__c;
            oOpportunity.Billed_Street_N__c = oAccount.Street_N__c;
            oOpportunity.Billed_Street_name__c = oAccount.Street_name__c;
            oOpportunity.Billed_Street_type__c = oAccount.Street_type__c;
            oOpportunity.Billed_Work_Phone_Number__c = oAccount.Work_Phone_Number__c;
            oOpportunity.Billed_Fax__c = oAccount.Fax;
            oOpportunity.Billed_Phone__c = oAccount.Phone;
            oOpportunity.Billed_Name__c = oAccount.Name;
            oOpportunity.Billed_SIRET__c  = oAccount.Code_SIRET__c;
            oOpportunity.Billed_AccountNumber__c = oAccount.AccountNumber;
            // END_AUTO_SYNC_Account_Billed__r
        }
    }
    
    
    //MLC 20210615| mise en commentaire ce cette méthode car elle est en commantaire dans le trigger

   /* public static void syncOpportunityFromOpportunity(Map<Id, Opportunity> mOldOpportunitys, Map<Id, Opportunity> mNewOpportunitys){
        Opportunity oOldOpportunity; // loop variable.
        for (Opportunity oNewOpportunity : mNewOpportunitys.values()){
            oOldOpportunity = mOldOpportunitys.get(oNewOpportunity.Id); // The API guarantees this key will be there.
            oNewOpportunity.T_AccountFieldsToChange__c = '___';
            if ((oOldOpportunity.DO_Payment_method__c != oNewOpportunity.DO_Payment_method__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Payment_method__c = oNewOpportunity.DO_Payment_method__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_method__c___';
            }
            if ((oOldOpportunity.DO_Email_2__c != oNewOpportunity.DO_Email_2__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Email_2__c = oNewOpportunity.DO_Email_2__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Email_2__c___';
            }
            if ((oOldOpportunity.DO_Payment_Time_Code__c != oNewOpportunity.DO_Payment_Time_Code__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Payment_Time_Code__c = oNewOpportunity.DO_Payment_Time_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_Time_Code__c___';
            }
            if ((oOldOpportunity.DO_Street_N__c != oNewOpportunity.DO_Street_N__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Street_N__c = oNewOpportunity.DO_Street_N__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_N__c___';
            }
            if ((oOldOpportunity.DO_City__c != oNewOpportunity.DO_City__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_City__c = oNewOpportunity.DO_City__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_City__c___';
            }
            if ((oOldOpportunity.DO_Mobile_Phone_Number__c != oNewOpportunity.DO_Mobile_Phone_Number__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Mobile_Phone_Number__c = oNewOpportunity.DO_Mobile_Phone_Number__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Mobile_Phone_Number__c___';
            }
            if ((oOldOpportunity.DO_Email__c != oNewOpportunity.DO_Email__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Email__c = oNewOpportunity.DO_Email__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Email__c___';
            }
            if ((oOldOpportunity.DO_AccountNumber__c != oNewOpportunity.DO_AccountNumber__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_AccountNumber__c = oNewOpportunity.DO_AccountNumber__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_AccountNumber__c___';
            }
            if ((oOldOpportunity.DO_Street_N__c != oNewOpportunity.DO_Street_N__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Street_N__c = oNewOpportunity.DO_Street_N__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_N__c___';
            }
            if ((oOldOpportunity.DO_Work_Phone_Number__c != oNewOpportunity.DO_Work_Phone_Number__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Work_Phone_Number__c = oNewOpportunity.DO_Work_Phone_Number__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Work_Phone_Number__c___';
            }
            if ((oOldOpportunity.DO_Postal_Box__c != oNewOpportunity.DO_Postal_Box__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Postal_Box__c = oNewOpportunity.DO_Postal_Box__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Postal_Box__c___';
            }
            if ((oOldOpportunity.DO_Street_type__c != oNewOpportunity.DO_Street_type__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Street_type__c = oNewOpportunity.DO_Street_type__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_type__c___';
            }
            if ((oOldOpportunity.DO_City_code__c != oNewOpportunity.DO_City_code__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_City_code__c = oNewOpportunity.DO_City_code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_City_code__c___';
            }
            if ((oOldOpportunity.DO_Street_name__c != oNewOpportunity.DO_Street_name__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Street_name__c = oNewOpportunity.DO_Street_name__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_name__c___';
            }
            if ((oOldOpportunity.DO_Number_extention__c != oNewOpportunity.DO_Number_extention__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Number_extention__c = oNewOpportunity.DO_Number_extention__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Number_extention__c___';
            }
            if ((oOldOpportunity.DO_Payment_Time_Value__c != oNewOpportunity.DO_Payment_Time_Value__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Payment_Time_Value__c = oNewOpportunity.DO_Payment_Time_Value__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_Time_Value__c___';
            }
            if ((oOldOpportunity.DO_City__c != oNewOpportunity.DO_City__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_City__c = oNewOpportunity.DO_City__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_City__c___';
            }
            if ((oOldOpportunity.DO_Payment_Time_Code__c != oNewOpportunity.DO_Payment_Time_Code__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Payment_Time_Code__c = oNewOpportunity.DO_Payment_Time_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_Time_Code__c___';
            }
            if ((oOldOpportunity.DO_Street_name__c != oNewOpportunity.DO_Street_name__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Street_name__c = oNewOpportunity.DO_Street_name__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_name__c___';
            }
            if ((oOldOpportunity.DO_Department__c != oNewOpportunity.DO_Department__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Department__c = oNewOpportunity.DO_Department__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Department__c___';
            }
            if ((oOldOpportunity.DO_Email__c != oNewOpportunity.DO_Email__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Email__c = oNewOpportunity.DO_Email__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Email__c___';
            }

            if ((oOldOpportunity.DO_Cedex__c != oNewOpportunity.DO_Cedex__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Cedex__c = oNewOpportunity.DO_Cedex__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Cedex__c___';
            }
            if ((oOldOpportunity.DO_Phone_Restriction__c != oNewOpportunity.DO_Phone_Restriction__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Phone_Restriction__c = oNewOpportunity.DO_Phone_Restriction__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Phone_Restriction__c___';
            }
            if ((oOldOpportunity.DO_City_Postal_Code__c != oNewOpportunity.DO_City_Postal_Code__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_City_Postal_Code__c = oNewOpportunity.DO_City_Postal_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_City_Postal_Code__c___';
            }
            if ((oOldOpportunity.DO_Scale__c != oNewOpportunity.DO_Scale__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Scale__c = oNewOpportunity.DO_Scale__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Scale__c___';
            }
            if ((oOldOpportunity.DO_Accounting_Manager_Value__c != oNewOpportunity.DO_Accounting_Manager_Value__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Accounting_Manager_Value__c = oNewOpportunity.DO_Accounting_Manager_Value__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Accounting_Manager_Value__c___';
            }
            if ((oOldOpportunity.DO_Accounting_Manager_Code__c != oNewOpportunity.DO_Accounting_Manager_Code__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Accounting_Manager_Code__c = oNewOpportunity.DO_Accounting_Manager_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Accounting_Manager_Code__c___';
            }
            if ((oOldOpportunity.DO_Email_2__c != oNewOpportunity.DO_Email_2__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Email_2__c = oNewOpportunity.DO_Email_2__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Email_2__c___';
            }
            if ((oOldOpportunity.DO_Mobile_Phone_Number__c != oNewOpportunity.DO_Mobile_Phone_Number__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Mobile_Phone_Number__c = oNewOpportunity.DO_Mobile_Phone_Number__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Mobile_Phone_Number__c___';
            }
            if ((oOldOpportunity.DO_Number_extention__c != oNewOpportunity.DO_Number_extention__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Number_extention__c = oNewOpportunity.DO_Number_extention__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Number_extention__c___';
            }
            if ((oOldOpportunity.DO_AccountNumber__c != oNewOpportunity.DO_AccountNumber__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_AccountNumber__c = oNewOpportunity.DO_AccountNumber__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_AccountNumber__c___';
            }
            if ((oOldOpportunity.DO_Street_type__c != oNewOpportunity.DO_Street_type__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Street_type__c = oNewOpportunity.DO_Street_type__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_type__c___';
            }
            if ((oOldOpportunity.DO_No_E_mail__c != oNewOpportunity.DO_No_E_mail__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_No_E_mail__c = oNewOpportunity.DO_No_E_mail__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_No_E_mail__c___';
            }
            if ((oOldOpportunity.DO_Salutation__c != oNewOpportunity.DO_Salutation__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Salutation__c = oNewOpportunity.DO_Salutation__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Salutation__c___';
            }
            if ((oOldOpportunity.DO_Accounting_Manager_Code__c != oNewOpportunity.DO_Accounting_Manager_Code__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Accounting_Manager_Code__c = oNewOpportunity.DO_Accounting_Manager_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Accounting_Manager_Code__c___';
            }
            if ((oOldOpportunity.DO_Accounting_Manager_Value__c != oNewOpportunity.DO_Accounting_Manager_Value__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Accounting_Manager_Value__c = oNewOpportunity.DO_Accounting_Manager_Value__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Accounting_Manager_Value__c___';
            }
            if ((oOldOpportunity.DO_Phone__c != oNewOpportunity.DO_Phone__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Phone__c = oNewOpportunity.DO_Phone__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Phone__c___';
            }
            if ((oOldOpportunity.DO_Payment_method__c != oNewOpportunity.DO_Payment_method__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Payment_method__c = oNewOpportunity.DO_Payment_method__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_method__c___';
            }
            if ((oOldOpportunity.DO_Department__c != oNewOpportunity.DO_Department__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Department__c = oNewOpportunity.DO_Department__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Department__c___';
            }
            if ((oOldOpportunity.DO_Place_Called__c != oNewOpportunity.DO_Place_Called__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Place_Called__c = oNewOpportunity.DO_Place_Called__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Place_Called__c___';
            }
            if ((oOldOpportunity.DO_City_code__c != oNewOpportunity.DO_City_code__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_City_code__c = oNewOpportunity.DO_City_code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_City_code__c___';
            }
            if ((oOldOpportunity.DO_Name__c != oNewOpportunity.DO_Name__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Name__c = oNewOpportunity.DO_Name__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Name__c___';
            }
            if ((oOldOpportunity.DO_Scale__c != oNewOpportunity.DO_Scale__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Scale__c = oNewOpportunity.DO_Scale__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Scale__c___';
            }
            if ((oOldOpportunity.DO_No_E_mail__c != oNewOpportunity.DO_No_E_mail__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_No_E_mail__c = oNewOpportunity.DO_No_E_mail__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_No_E_mail__c___';
            }
            if ((oOldOpportunity.DO_Phone_Restriction__c != oNewOpportunity.DO_Phone_Restriction__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Phone_Restriction__c = oNewOpportunity.DO_Phone_Restriction__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Phone_Restriction__c___';
            }
            if ((oOldOpportunity.DO_Phone__c != oNewOpportunity.DO_Phone__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Phone__c = oNewOpportunity.DO_Phone__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Phone__c___';
            }
            if ((oOldOpportunity.DO_Work_Phone_Number__c != oNewOpportunity.DO_Work_Phone_Number__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Work_Phone_Number__c = oNewOpportunity.DO_Work_Phone_Number__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Work_Phone_Number__c___';
            }
            if ((oOldOpportunity.DO_Cedex__c != oNewOpportunity.DO_Cedex__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Cedex__c = oNewOpportunity.DO_Cedex__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Cedex__c___';
            }
            if ((oOldOpportunity.DO_Name__c != oNewOpportunity.DO_Name__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Name__c = oNewOpportunity.DO_Name__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Name__c___';
            }
            if ((oOldOpportunity.DO_City_Postal_Code__c != oNewOpportunity.DO_City_Postal_Code__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_City_Postal_Code__c = oNewOpportunity.DO_City_Postal_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_City_Postal_Code__c___';
            }
            if ((oOldOpportunity.DO_Payment_Time_Value__c != oNewOpportunity.DO_Payment_Time_Value__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Payment_Time_Value__c = oNewOpportunity.DO_Payment_Time_Value__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_Time_Value__c___';
            }
            if ((oOldOpportunity.DO_Postal_Code__c != oNewOpportunity.DO_Postal_Code__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Postal_Code__c = oNewOpportunity.DO_Postal_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Postal_Code__c___';
            }
            if ((oOldOpportunity.DO_Postal_Box__c != oNewOpportunity.DO_Postal_Box__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Postal_Box__c = oNewOpportunity.DO_Postal_Box__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Postal_Box__c___';
            }
            if ((oOldOpportunity.DO_Invoicing_Frequency__c != oNewOpportunity.DO_Invoicing_Frequency__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Invoicing_Frequency__c = oNewOpportunity.DO_Invoicing_Frequency__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Invoicing_Frequency__c___';
            }
            if ((oOldOpportunity.DO_Postal_Code__c != oNewOpportunity.DO_Postal_Code__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Postal_Code__c = oNewOpportunity.DO_Postal_Code__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Postal_Code__c___';
            }
            if ((oOldOpportunity.DO_Salutation__c != oNewOpportunity.DO_Salutation__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Salutation__c = oNewOpportunity.DO_Salutation__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Salutation__c___';
            }
            if ((oOldOpportunity.DO_Invoicing_Frequency__c != oNewOpportunity.DO_Invoicing_Frequency__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Invoicing_Frequency__c = oNewOpportunity.DO_Invoicing_Frequency__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Invoicing_Frequency__c___';
            }
            if ((oOldOpportunity.DO_Place_Called__c != oNewOpportunity.DO_Place_Called__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Place_Called__c = oNewOpportunity.DO_Place_Called__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Place_Called__c___';
            }
            if ((oOldOpportunity.DO_Country__c != oNewOpportunity.DO_Country__c) && (oNewOpportunity.Account_Payer__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Payer_Country__c = oNewOpportunity.DO_Country__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Payer_Country__c___';
            }
            if ((oOldOpportunity.DO_Country__c != oNewOpportunity.DO_Country__c) && (oNewOpportunity.Account_Billed__c == oNewOpportunity.AccountId)){
                oNewOpportunity.Billed_Country__c = oNewOpportunity.DO_Country__c;
                oNewOpportunity.T_AccountFieldsToChange__c += '___Billed_Country__c___';
            }
            
            
            
            
        }
    }*/
/**
    public static void propagateAccountToOpportunity(Map<Id, Account> mOldAccounts, Map<Id, Account> mNewAccounts){
        // Propagate changes to the Account to the Opportunitys.
        List<Opportunity> lOpportunitys = [
            SELECT
                Id,
                AccountId,
                Account_Payer__c,
                Account_Billed__c,
                // BEGIN_AUTO_Opportunity_FIELDS
                Billed_Mobile_Phone_Number__c,
                Billed_City__c,
                Payer_No_E_mail__c,
                Billed_Payment_Time_Code__c,
                Payer_Fax__c,
                DO_Group_Code__c,
                DO_ParentId__c,
                DO_Salutation__c,
                DO_Type__c,
                Payer_Payment_Time_Code__c,
                DO_Place_Called__c,
                Payer_Country__c,
                Billed_Scale__c,
                DO_Invoicing_Frequency__c,
                Payer_Cedex__c,
                Payer_Payment_Time_Value__c,
                DO_Payment_Time_Value__c,
                Payer_Postal_Box__c,
                DO_No_E_mail__c,
                DO_Activity_Domain__c,
                DO_Payment_Time_Code__c,
                Billed_Work_Phone_Number__c,
                DO_Country__c,
                Payer_Accounting_Manager_Code__c,
                DO_Accounting_Manager_Value__c,
                DO_Price_Group__c,
                Billed_City_Postal_Code__c,
                DO_Market_Sub_Type__c,
                DO_Accounting_Manager_Code__c,
                DO_Cedex__c,
                Payer_City_code__c,
                DO_Active__c,
                DO_Number_extention__c,
                Payer_Postal_Code__c,
                Billed_Email__c,
                DO_Street_name__c,
                DO_Mandataire__c,
                DO_Code_NAF__c,
                DO_Adherent_Central_Number__c,
                Payer_Scale__c,
                Billed_Payment_Time_Value__c,
                Payer_Email__c,
                DO_City_code__c,
                Billed_Street_N__c,
                DO_Optin_2__c,
                DO_Affiliate_Networks__c,
                Billed_City_code__c,
                Billed_Fax__c,
                Payer_Work_Phone_Number__c,
                Payer_Place_Called__c,
                Payer_Street_N__c,
                Payer_City_Postal_Code__c,
                DO_Group_Code_Value__c,
                Billed_Cedex__c,
                Billed_Name__c,
                DO_Sub_Channel__c,
                DO_Optin_1__c,
                DO_Street_Number__c,
                DO_Scale__c,
                DO_Email__c,
                Payer_City__c,
                DO_Department__c,
                Payer_Street_name__c,
                DO_Email_2__c,
                DO_Phone_Restriction__c,
                Billed_Street_type__c,
                DO_Hierarchy_Level__c,
                DO_Work_Phone_Number__c,
                Payer_Street_type__c,
                Billed_Phone_Restriction__c,
                Billed_Accounting_Manager_Value__c,
                DO_Street_N__c,
                DO_Bymail__c,
                Payer_AccountNumber__c,
                DO_City_Postal_Code__c,
                DO_Name__c,
                Payer_Accounting_Manager_Value__c,
                Billed_Phone__c,
                Billed_Country__c,
                DO_City__c,
                Billed_Invoicing_Frequency__c,
                Payer_Phone__c,
                Billed_Email_2__c,
                DO_Street_type__c,
                Payer_Number_extention__c,
                Billed_Department__c,
                Payer_Email_2__c,
                DO_Code_SIRET__c,
                DO_Price_information__c,
                DO_AccountNumber__c,
                Billed_Accounting_Manager_Code__c,
                Billed_Postal_Code__c,
                DO_Phone__c,
                Payer_Payment_method__c,
                DO_Postal_Code__c,
                DO_Postal_Box__c,
                Billed_Number_extention__c,
                Billed_Place_Called__c,
                Payer_Mobile_Phone_Number__c,
                Billed_Salutation__c,
                Billed_No_E_mail__c,
                DO_R_C_S_or_R_C_M_Number__c,
                DO_Segmentation__c,
                Billed_Payment_method__c,
                Payer_Phone_Restriction__c,
                DO_Payment_method__c,
                DO_Bysms__c,
                Billed_Street_name__c,
                Payer_Salutation__c,
                Billed_AccountNumber__c,
                DO_Mobile_Phone_Number__c,
                Billed_Postal_Box__c,
                Payer_Department__c,
                Payer_Invoicing_Frequency__c,
                DO_Market_Type__c,
                Payer_Name__c,
                DO_Indicatif_pays__c
                // END_AUTO_Opportunity_FIELDS
            FROM Opportunity
            WHERE
                AccountId in :mNewAccounts.keySet()
                OR Account_Payer__c in :mNewAccounts.keySet()
                OR Account_Billed__c in :mNewAccounts.keySet()
                
        ];

        List<Opportunity> lUpdateOpportunitys = new List<Opportunity>();

        Boolean needsUpdate; // Loop variable.
        for (Opportunity oOpportunity : lOpportunitys){
            needsUpdate = false;
            // Do not use OR to block the first update from short-circuiting the others.
                if (AP_SyncOpportunityFromAccount_01.propagateDO_Fields(oOpportunity, mOldAccounts, mNewAccounts)){
                    needsUpdate = true;
                }
            // Do not use OR to block the first update from short-circuiting the others.
                if (AP_SyncOpportunityFromAccount_01.propagatePayer_Fields(oOpportunity, mOldAccounts, mNewAccounts)){
                    needsUpdate = true;
                }
            // Do not use OR to block the first update from short-circuiting the others.
                if (AP_SyncOpportunityFromAccount_01.propagateBilled_Fields(oOpportunity, mOldAccounts, mNewAccounts)){
                    needsUpdate = true;
                }
            
            if (needsUpdate) {
                lUpdateOpportunitys.add(oOpportunity);
            }
        }
        update lUpdateOpportunitys;
    }

    public static Boolean propagateDO_Fields(Opportunity oOpportunity, Map<Id, Account> mOldAccounts, Map<Id, Account> mNewAccounts){
        Account oOldAccount = mOldAccounts.get(oOpportunity.AccountId);
        Account oNewAccount = mNewAccounts.get(oOpportunity.AccountId);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Starting.');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] oOldAccount:[' + oOldAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] oNewAccount:[' + oNewAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] oOpportunity:[' + oOpportunity + ']');
        if ((oOldAccount != null) && (oNewAccount != null)) { // that's equivalent. We're just checking whether the Opportunity had this specific Account, AccountId lookup updated
            // BEGIN_AUTO_PROPAGATE_Account
            if ((oOldAccount.Accounting_Manager_Code__c != oNewAccount.Accounting_Manager_Code__c) && ((oOpportunity.DO_Accounting_Manager_Code__c == oOldAccount.Accounting_Manager_Code__c) || (oOpportunity.DO_Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c))){
                    status = true;
                    oOpportunity.DO_Accounting_Manager_Code__c = oNewAccount.Accounting_Manager_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Accounting_Manager_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Accounting_Manager_Code__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Code__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Accounting_Manager_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Accounting_Manager_Code__c != oOldAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Accounting_Manager_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Accounting_Manager_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Accounting_Manager_Value__c != oNewAccount.Accounting_Manager_Value__c) && ((oOpportunity.DO_Accounting_Manager_Value__c == oOldAccount.Accounting_Manager_Value__c) || (oOpportunity.DO_Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c))){
                    status = true;
                    oOpportunity.DO_Accounting_Manager_Value__c = oNewAccount.Accounting_Manager_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Accounting_Manager_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Accounting_Manager_Value__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Value__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Accounting_Manager_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Accounting_Manager_Value__c != oOldAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Accounting_Manager_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Accounting_Manager_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Active__c != oNewAccount.Active__c) && ((oOpportunity.DO_Active__c == oOldAccount.Active__c) || (oOpportunity.DO_Active__c == oNewAccount.Active__c))){
                    status = true;
                    oOpportunity.DO_Active__c = oNewAccount.Active__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Active__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Active__c] to [' + String.valueOf(oNewAccount.Active__c) + ']');
                } else {
                    if (oOldAccount.Active__c == oNewAccount.Active__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Active__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Active__c != oOldAccount.Active__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Active__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Active__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Active__c) + '])');
                    }
            }
            if ((oOldAccount.Activity_Domain__c != oNewAccount.Activity_Domain__c) && ((oOpportunity.DO_Activity_Domain__c == oOldAccount.Activity_Domain__c) || (oOpportunity.DO_Activity_Domain__c == oNewAccount.Activity_Domain__c))){
                    status = true;
                    oOpportunity.DO_Activity_Domain__c = oNewAccount.Activity_Domain__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Activity_Domain__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Activity_Domain__c] to [' + String.valueOf(oNewAccount.Activity_Domain__c) + ']');
                } else {
                    if (oOldAccount.Activity_Domain__c == oNewAccount.Activity_Domain__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Activity_Domain__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Activity_Domain__c != oOldAccount.Activity_Domain__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Activity_Domain__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Activity_Domain__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Activity_Domain__c) + '])');
                    }
            }
            if ((oOldAccount.Adherent_Central_Number__c != oNewAccount.Adherent_Central_Number__c) && ((oOpportunity.DO_Adherent_Central_Number__c == oOldAccount.Adherent_Central_Number__c) || (oOpportunity.DO_Adherent_Central_Number__c == oNewAccount.Adherent_Central_Number__c))){
                    status = true;
                    oOpportunity.DO_Adherent_Central_Number__c = oNewAccount.Adherent_Central_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Adherent_Central_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Adherent_Central_Number__c] to [' + String.valueOf(oNewAccount.Adherent_Central_Number__c) + ']');
                } else {
                    if (oOldAccount.Adherent_Central_Number__c == oNewAccount.Adherent_Central_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Adherent_Central_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Adherent_Central_Number__c != oOldAccount.Adherent_Central_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Adherent_Central_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Adherent_Central_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Adherent_Central_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Affiliate_Networks__c != oNewAccount.Affiliate_Networks__c) && ((oOpportunity.DO_Affiliate_Networks__c == oOldAccount.Affiliate_Networks__c) || (oOpportunity.DO_Affiliate_Networks__c == oNewAccount.Affiliate_Networks__c))){
                    status = true;
                    oOpportunity.DO_Affiliate_Networks__c = oNewAccount.Affiliate_Networks__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Affiliate_Networks__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Affiliate_Networks__c] to [' + String.valueOf(oNewAccount.Affiliate_Networks__c) + ']');
                } else {
                    if (oOldAccount.Affiliate_Networks__c == oNewAccount.Affiliate_Networks__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Affiliate_Networks__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Affiliate_Networks__c != oOldAccount.Affiliate_Networks__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Affiliate_Networks__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Affiliate_Networks__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Affiliate_Networks__c) + '])');
                    }
            }
            if ((oOldAccount.Bymail__c != oNewAccount.Bymail__c) && ((oOpportunity.DO_Bymail__c == oOldAccount.Bymail__c) || (oOpportunity.DO_Bymail__c == oNewAccount.Bymail__c))){
                    status = true;
                    oOpportunity.DO_Bymail__c = oNewAccount.Bymail__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Bymail__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Bymail__c] to [' + String.valueOf(oNewAccount.Bymail__c) + ']');
                } else {
                    if (oOldAccount.Bymail__c == oNewAccount.Bymail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Bymail__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Bymail__c != oOldAccount.Bymail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Bymail__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Bymail__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Bymail__c) + '])');
                    }
            }
            if ((oOldAccount.Bysms__c != oNewAccount.Bysms__c) && ((oOpportunity.DO_Bysms__c == oOldAccount.Bysms__c) || (oOpportunity.DO_Bysms__c == oNewAccount.Bysms__c))){
                    status = true;
                    oOpportunity.DO_Bysms__c = oNewAccount.Bysms__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Bysms__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Bysms__c] to [' + String.valueOf(oNewAccount.Bysms__c) + ']');
                } else {
                    if (oOldAccount.Bysms__c == oNewAccount.Bysms__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Bysms__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Bysms__c != oOldAccount.Bysms__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Bysms__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Bysms__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Bysms__c) + '])');
                    }
            }
            if ((oOldAccount.Cedex__c != oNewAccount.Cedex__c) && ((oOpportunity.DO_Cedex__c == oOldAccount.Cedex__c) || (oOpportunity.DO_Cedex__c == oNewAccount.Cedex__c))){
                    status = true;
                    oOpportunity.DO_Cedex__c = oNewAccount.Cedex__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Cedex__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Cedex__c] to [' + String.valueOf(oNewAccount.Cedex__c) + ']');
                } else {
                    if (oOldAccount.Cedex__c == oNewAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Cedex__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Cedex__c != oOldAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Cedex__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Cedex__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Cedex__c) + '])');
                    }
            }
            if ((oOldAccount.City_Postal_Code__c != oNewAccount.City_Postal_Code__c) && ((oOpportunity.DO_City_Postal_Code__c == oOldAccount.City_Postal_Code__c) || (oOpportunity.DO_City_Postal_Code__c == oNewAccount.City_Postal_Code__c))){
                    status = true;
                    oOpportunity.DO_City_Postal_Code__c = oNewAccount.City_Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_City_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_City_Postal_Code__c] to [' + String.valueOf(oNewAccount.City_Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.City_Postal_Code__c == oNewAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_City_Postal_Code__c != oOldAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_City_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.City__c != oNewAccount.City__c) && ((oOpportunity.DO_City__c == oOldAccount.City__c) || (oOpportunity.DO_City__c == oNewAccount.City__c))){
                    status = true;
                    oOpportunity.DO_City__c = oNewAccount.City__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_City__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_City__c] to [' + String.valueOf(oNewAccount.City__c) + ']');
                } else {
                    if (oOldAccount.City__c == oNewAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_City__c != oOldAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_City__c) + '])');
                    }
            }
            if ((oOldAccount.City_code__c != oNewAccount.City_code__c) && ((oOpportunity.DO_City_code__c == oOldAccount.City_code__c) || (oOpportunity.DO_City_code__c == oNewAccount.City_code__c))){
                    status = true;
                    oOpportunity.DO_City_code__c = oNewAccount.City_code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_City_code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_City_code__c] to [' + String.valueOf(oNewAccount.City_code__c) + ']');
                } else {
                    if (oOldAccount.City_code__c == oNewAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City_code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_City_code__c != oOldAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_City_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_City_code__c) + '])');
                    }
            }
            if ((oOldAccount.Code_NAF__c != oNewAccount.Code_NAF__c) && ((oOpportunity.DO_Code_NAF__c == oOldAccount.Code_NAF__c) || (oOpportunity.DO_Code_NAF__c == oNewAccount.Code_NAF__c))){
                    status = true;
                    oOpportunity.DO_Code_NAF__c = oNewAccount.Code_NAF__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Code_NAF__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Code_NAF__c] to [' + String.valueOf(oNewAccount.Code_NAF__c) + ']');
                } else {
                    if (oOldAccount.Code_NAF__c == oNewAccount.Code_NAF__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Code_NAF__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Code_NAF__c != oOldAccount.Code_NAF__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Code_NAF__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Code_NAF__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Code_NAF__c) + '])');
                    }
            }
            if ((oOldAccount.Code_SIRET__c != oNewAccount.Code_SIRET__c) && ((oOpportunity.DO_Code_SIRET__c == oOldAccount.Code_SIRET__c) || (oOpportunity.DO_Code_SIRET__c == oNewAccount.Code_SIRET__c))){
                    status = true;
                    oOpportunity.DO_Code_SIRET__c = oNewAccount.Code_SIRET__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Code_SIRET__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Code_SIRET__c] to [' + String.valueOf(oNewAccount.Code_SIRET__c) + ']');
                } else {
                    if (oOldAccount.Code_SIRET__c == oNewAccount.Code_SIRET__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Code_SIRET__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Code_SIRET__c != oOldAccount.Code_SIRET__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Code_SIRET__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Code_SIRET__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Code_SIRET__c) + '])');
                    }
            }
            if ((oOldAccount.Country__c != oNewAccount.Country__c) && ((oOpportunity.DO_Country__c == oOldAccount.Country__c) || (oOpportunity.DO_Country__c == oNewAccount.Country__c))){
                    status = true;
                    oOpportunity.DO_Country__c = oNewAccount.Country__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Country__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Country__c] to [' + String.valueOf(oNewAccount.Country__c) + ']');
                } else {
                    if (oOldAccount.Country__c == oNewAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Country__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Country__c != oOldAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Country__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Country__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Country__c) + '])');
                    }
            }
           // if ((oOldAccount.Customer_Group__c != oNewAccount.Customer_Group__c) && ((oOpportunity.DO_Customer_Group__c == oOldAccount.Customer_Group__c) || (oOpportunity.DO_Customer_Group__c == oNewAccount.Customer_Group__c))){
           //         status = true;
           //         oOpportunity.DO_Customer_Group__c = oNewAccount.Customer_Group__c;
           //         oOpportunity.T_AccountFieldsToChange__c += '___DO_Customer_Group__c___';
           //         System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Customer_Group__c] to [' + String.valueOf(oNewAccount.Customer_Group__c) + ']');
           //     } else {
           //         if (oOldAccount.Customer_Group__c == oNewAccount.Customer_Group__c) {
           //             System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Customer_Group__c] :: Field was not changed.');
           //         }
           //         if (oOpportunity.DO_Customer_Group__c != oOldAccount.Customer_Group__c) {
           //             System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Customer_Group__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Customer_Group__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Customer_Group__c) + '])');
           //         }
           // }
            if ((oOldAccount.Department__c != oNewAccount.Department__c) && ((oOpportunity.DO_Department__c == oOldAccount.Department__c) || (oOpportunity.DO_Department__c == oNewAccount.Department__c))){
                    status = true;
                    oOpportunity.DO_Department__c = oNewAccount.Department__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Department__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Department__c] to [' + String.valueOf(oNewAccount.Department__c) + ']');
                } else {
                    if (oOldAccount.Department__c == oNewAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Department__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Department__c != oOldAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Department__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Department__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Department__c) + '])');
                    }
            }
            if ((oOldAccount.Email_2__c != oNewAccount.Email_2__c) && ((oOpportunity.DO_Email_2__c == oOldAccount.Email_2__c) || (oOpportunity.DO_Email_2__c == oNewAccount.Email_2__c))){
                    status = true;
                    oOpportunity.DO_Email_2__c = oNewAccount.Email_2__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Email_2__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Email_2__c] to [' + String.valueOf(oNewAccount.Email_2__c) + ']');
                } else {
                    if (oOldAccount.Email_2__c == oNewAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Email_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Email_2__c != oOldAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Email_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email_2__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Email_2__c) + '])');
                    }
            }
            if ((oOldAccount.Email__c != oNewAccount.Email__c) && ((oOpportunity.DO_Email__c == oOldAccount.Email__c) || (oOpportunity.DO_Email__c == oNewAccount.Email__c))){
                    status = true;
                    oOpportunity.DO_Email__c = oNewAccount.Email__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Email__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Email__c] to [' + String.valueOf(oNewAccount.Email__c) + ']');
                } else {
                    if (oOldAccount.Email__c == oNewAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Email__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Email__c != oOldAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Email__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Email__c) + '])');
                    }
            }
            if ((oOldAccount.Group_Code_Value__c != oNewAccount.Group_Code_Value__c) && ((oOpportunity.DO_Group_Code_Value__c == oOldAccount.Group_Code_Value__c) || (oOpportunity.DO_Group_Code_Value__c == oNewAccount.Group_Code_Value__c))){
                    status = true;
                    oOpportunity.DO_Group_Code_Value__c = oNewAccount.Group_Code_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Group_Code_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Group_Code_Value__c] to [' + String.valueOf(oNewAccount.Group_Code_Value__c) + ']');
                } else {
                    if (oOldAccount.Group_Code_Value__c == oNewAccount.Group_Code_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Group_Code_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Group_Code_Value__c != oOldAccount.Group_Code_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Group_Code_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Group_Code_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Group_Code_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Group_Code__c != oNewAccount.Group_Code__c) && ((oOpportunity.DO_Group_Code__c == oOldAccount.Group_Code__c) || (oOpportunity.DO_Group_Code__c == oNewAccount.Group_Code__c))){
                    status = true;
                    oOpportunity.DO_Group_Code__c = oNewAccount.Group_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Group_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Group_Code__c] to [' + String.valueOf(oNewAccount.Group_Code__c) + ']');
                } else {
                    if (oOldAccount.Group_Code__c == oNewAccount.Group_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Group_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Group_Code__c != oOldAccount.Group_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Group_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Group_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Group_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Hierarchy_Level__c != oNewAccount.Hierarchy_Level__c) && ((oOpportunity.DO_Hierarchy_Level__c == oOldAccount.Hierarchy_Level__c) || (oOpportunity.DO_Hierarchy_Level__c == oNewAccount.Hierarchy_Level__c))){
                    status = true;
                    oOpportunity.DO_Hierarchy_Level__c = oNewAccount.Hierarchy_Level__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Hierarchy_Level__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Hierarchy_Level__c] to [' + String.valueOf(oNewAccount.Hierarchy_Level__c) + ']');
                } else {
                    if (oOldAccount.Hierarchy_Level__c == oNewAccount.Hierarchy_Level__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Hierarchy_Level__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Hierarchy_Level__c != oOldAccount.Hierarchy_Level__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Hierarchy_Level__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Hierarchy_Level__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Hierarchy_Level__c) + '])');
                    }
            }
            if ((oOldAccount.Invoicing_Frequency__c != oNewAccount.Invoicing_Frequency__c) && ((oOpportunity.DO_Invoicing_Frequency__c == oOldAccount.Invoicing_Frequency__c) || (oOpportunity.DO_Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c))){
                    status = true;
                    oOpportunity.DO_Invoicing_Frequency__c = oNewAccount.Invoicing_Frequency__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Invoicing_Frequency__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Invoicing_Frequency__c] to [' + String.valueOf(oNewAccount.Invoicing_Frequency__c) + ']');
                } else {
                    if (oOldAccount.Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Invoicing_Frequency__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Invoicing_Frequency__c != oOldAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Invoicing_Frequency__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Invoicing_Frequency__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Invoicing_Frequency__c) + '])');
                    }
            }
            if ((oOldAccount.Mandataire__c != oNewAccount.Mandataire__c) && ((oOpportunity.DO_Mandataire__c == oOldAccount.Mandataire__c) || (oOpportunity.DO_Mandataire__c == oNewAccount.Mandataire__c))){
                    status = true;
                    oOpportunity.DO_Mandataire__c = oNewAccount.Mandataire__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Mandataire__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Mandataire__c] to [' + String.valueOf(oNewAccount.Mandataire__c) + ']');
                } else {
                    if (oOldAccount.Mandataire__c == oNewAccount.Mandataire__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Mandataire__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Mandataire__c != oOldAccount.Mandataire__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Mandataire__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Mandataire__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Mandataire__c) + '])');
                    }
            }
            if ((oOldAccount.Market_Sub_Type__c != oNewAccount.Market_Sub_Type__c) && ((oOpportunity.DO_Market_Sub_Type__c == oOldAccount.Market_Sub_Type__c) || (oOpportunity.DO_Market_Sub_Type__c == oNewAccount.Market_Sub_Type__c))){
                    status = true;
                    oOpportunity.DO_Market_Sub_Type__c = oNewAccount.Market_Sub_Type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Market_Sub_Type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Market_Sub_Type__c] to [' + String.valueOf(oNewAccount.Market_Sub_Type__c) + ']');
                } else {
                    if (oOldAccount.Market_Sub_Type__c == oNewAccount.Market_Sub_Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Market_Sub_Type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Market_Sub_Type__c != oOldAccount.Market_Sub_Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Market_Sub_Type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Market_Sub_Type__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Market_Sub_Type__c) + '])');
                    }
            }
            if ((oOldAccount.Market_Type__c != oNewAccount.Market_Type__c) && ((oOpportunity.DO_Market_Type__c == oOldAccount.Market_Type__c) || (oOpportunity.DO_Market_Type__c == oNewAccount.Market_Type__c))){
                    status = true;
                    oOpportunity.DO_Market_Type__c = oNewAccount.Market_Type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Market_Type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Market_Type__c] to [' + String.valueOf(oNewAccount.Market_Type__c) + ']');
                } else {
                    if (oOldAccount.Market_Type__c == oNewAccount.Market_Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Market_Type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Market_Type__c != oOldAccount.Market_Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Market_Type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Market_Type__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Market_Type__c) + '])');
                    }
            }
            if ((oOldAccount.Mobile_Phone_Number__c != oNewAccount.Mobile_Phone_Number__c) && ((oOpportunity.DO_Mobile_Phone_Number__c == oOldAccount.Mobile_Phone_Number__c) || (oOpportunity.DO_Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c))){
                    status = true;
                    oOpportunity.DO_Mobile_Phone_Number__c = oNewAccount.Mobile_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Mobile_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Mobile_Phone_Number__c] to [' + String.valueOf(oNewAccount.Mobile_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Mobile_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Mobile_Phone_Number__c != oOldAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Mobile_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Mobile_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Mobile_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.No_E_mail__c != oNewAccount.No_E_mail__c) && ((oOpportunity.DO_No_E_mail__c == oOldAccount.No_E_mail__c) || (oOpportunity.DO_No_E_mail__c == oNewAccount.No_E_mail__c))){
                    status = true;
                    oOpportunity.DO_No_E_mail__c = oNewAccount.No_E_mail__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_No_E_mail__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_No_E_mail__c] to [' + String.valueOf(oNewAccount.No_E_mail__c) + ']');
                } else {
                    if (oOldAccount.No_E_mail__c == oNewAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_No_E_mail__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_No_E_mail__c != oOldAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_No_E_mail__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.No_E_mail__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_No_E_mail__c) + '])');
                    }
            }
            if ((oOldAccount.Number_extention__c != oNewAccount.Number_extention__c) && ((oOpportunity.DO_Number_extention__c == oOldAccount.Number_extention__c) || (oOpportunity.DO_Number_extention__c == oNewAccount.Number_extention__c))){
                    status = true;
                    oOpportunity.DO_Number_extention__c = oNewAccount.Number_extention__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Number_extention__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Number_extention__c] to [' + String.valueOf(oNewAccount.Number_extention__c) + ']');
                } else {
                    if (oOldAccount.Number_extention__c == oNewAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Number_extention__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Number_extention__c != oOldAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Number_extention__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Number_extention__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Number_extention__c) + '])');
                    }
            }
            if ((oOldAccount.Optin_1__c != oNewAccount.Optin_1__c) && ((oOpportunity.DO_Optin_1__c == oOldAccount.Optin_1__c) || (oOpportunity.DO_Optin_1__c == oNewAccount.Optin_1__c))){
                    status = true;
                    oOpportunity.DO_Optin_1__c = oNewAccount.Optin_1__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Optin_1__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Optin_1__c] to [' + String.valueOf(oNewAccount.Optin_1__c) + ']');
                } else {
                    if (oOldAccount.Optin_1__c == oNewAccount.Optin_1__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Optin_1__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Optin_1__c != oOldAccount.Optin_1__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Optin_1__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Optin_1__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Optin_1__c) + '])');
                    }
            }
            if ((oOldAccount.Optin_2__c != oNewAccount.Optin_2__c) && ((oOpportunity.DO_Optin_2__c == oOldAccount.Optin_2__c) || (oOpportunity.DO_Optin_2__c == oNewAccount.Optin_2__c))){
                    status = true;
                    oOpportunity.DO_Optin_2__c = oNewAccount.Optin_2__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Optin_2__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Optin_2__c] to [' + String.valueOf(oNewAccount.Optin_2__c) + ']');
                } else {
                    if (oOldAccount.Optin_2__c == oNewAccount.Optin_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Optin_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Optin_2__c != oOldAccount.Optin_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Optin_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Optin_2__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Optin_2__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Code__c != oNewAccount.Payment_Time_Code__c) && ((oOpportunity.DO_Payment_Time_Code__c == oOldAccount.Payment_Time_Code__c) || (oOpportunity.DO_Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c))){
                    status = true;
                    oOpportunity.DO_Payment_Time_Code__c = oNewAccount.Payment_Time_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Payment_Time_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Payment_Time_Code__c] to [' + String.valueOf(oNewAccount.Payment_Time_Code__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_Time_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Payment_Time_Code__c != oOldAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_Time_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Payment_Time_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Value__c != oNewAccount.Payment_Time_Value__c) && ((oOpportunity.DO_Payment_Time_Value__c == oOldAccount.Payment_Time_Value__c) || (oOpportunity.DO_Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c))){
                    status = true;
                    oOpportunity.DO_Payment_Time_Value__c = oNewAccount.Payment_Time_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Payment_Time_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Payment_Time_Value__c] to [' + String.valueOf(oNewAccount.Payment_Time_Value__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_Time_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Payment_Time_Value__c != oOldAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_Time_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Payment_Time_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_method__c != oNewAccount.Payment_method__c) && ((oOpportunity.DO_Payment_method__c == oOldAccount.Payment_method__c) || (oOpportunity.DO_Payment_method__c == oNewAccount.Payment_method__c))){
                    status = true;
                    oOpportunity.DO_Payment_method__c = oNewAccount.Payment_method__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Payment_method__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Payment_method__c] to [' + String.valueOf(oNewAccount.Payment_method__c) + ']');
                } else {
                    if (oOldAccount.Payment_method__c == oNewAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_method__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Payment_method__c != oOldAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Payment_method__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_method__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Payment_method__c) + '])');
                    }
            }
            if ((oOldAccount.Phone_Restriction__c != oNewAccount.Phone_Restriction__c) && ((oOpportunity.DO_Phone_Restriction__c == oOldAccount.Phone_Restriction__c) || (oOpportunity.DO_Phone_Restriction__c == oNewAccount.Phone_Restriction__c))){
                    status = true;
                    oOpportunity.DO_Phone_Restriction__c = oNewAccount.Phone_Restriction__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Phone_Restriction__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Phone_Restriction__c] to [' + String.valueOf(oNewAccount.Phone_Restriction__c) + ']');
                } else {
                    if (oOldAccount.Phone_Restriction__c == oNewAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Phone_Restriction__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Phone_Restriction__c != oOldAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Phone_Restriction__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone_Restriction__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Phone_Restriction__c) + '])');
                    }
            }
            if ((oOldAccount.Place_Called__c != oNewAccount.Place_Called__c) && ((oOpportunity.DO_Place_Called__c == oOldAccount.Place_Called__c) || (oOpportunity.DO_Place_Called__c == oNewAccount.Place_Called__c))){
                    status = true;
                    oOpportunity.DO_Place_Called__c = oNewAccount.Place_Called__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Place_Called__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Place_Called__c] to [' + String.valueOf(oNewAccount.Place_Called__c) + ']');
                } else {
                    if (oOldAccount.Place_Called__c == oNewAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Place_Called__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Place_Called__c != oOldAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Place_Called__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Place_Called__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Place_Called__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Box__c != oNewAccount.Postal_Box__c) && ((oOpportunity.DO_Postal_Box__c == oOldAccount.Postal_Box__c) || (oOpportunity.DO_Postal_Box__c == oNewAccount.Postal_Box__c))){
                    status = true;
                    oOpportunity.DO_Postal_Box__c = oNewAccount.Postal_Box__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Postal_Box__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Postal_Box__c] to [' + String.valueOf(oNewAccount.Postal_Box__c) + ']');
                } else {
                    if (oOldAccount.Postal_Box__c == oNewAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Postal_Box__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Postal_Box__c != oOldAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Postal_Box__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Box__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Postal_Box__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Code__c != oNewAccount.Postal_Code__c) && ((oOpportunity.DO_Postal_Code__c == oOldAccount.Postal_Code__c) || (oOpportunity.DO_Postal_Code__c == oNewAccount.Postal_Code__c))){
                    status = true;
                    oOpportunity.DO_Postal_Code__c = oNewAccount.Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Postal_Code__c] to [' + String.valueOf(oNewAccount.Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.Postal_Code__c == oNewAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Postal_Code__c != oOldAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Price_Group__c != oNewAccount.Price_Group__c) && ((oOpportunity.DO_Price_Group__c == oOldAccount.Price_Group__c) || (oOpportunity.DO_Price_Group__c == oNewAccount.Price_Group__c))){
                    status = true;
                    oOpportunity.DO_Price_Group__c = oNewAccount.Price_Group__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Price_Group__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Price_Group__c] to [' + String.valueOf(oNewAccount.Price_Group__c) + ']');
                } else {
                    if (oOldAccount.Price_Group__c == oNewAccount.Price_Group__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Price_Group__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Price_Group__c != oOldAccount.Price_Group__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Price_Group__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Price_Group__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Price_Group__c) + '])');
                    }
            }
            if ((oOldAccount.Price_information__c != oNewAccount.Price_information__c) && ((oOpportunity.DO_Price_information__c == oOldAccount.Price_information__c) || (oOpportunity.DO_Price_information__c == oNewAccount.Price_information__c))){
                    status = true;
                    oOpportunity.DO_Price_information__c = oNewAccount.Price_information__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Price_information__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Price_information__c] to [' + String.valueOf(oNewAccount.Price_information__c) + ']');
                } else {
                    if (oOldAccount.Price_information__c == oNewAccount.Price_information__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Price_information__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Price_information__c != oOldAccount.Price_information__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Price_information__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Price_information__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Price_information__c) + '])');
                    }
            }
            if ((oOldAccount.R_C_S_or_R_C_M_Number__c != oNewAccount.R_C_S_or_R_C_M_Number__c) && ((oOpportunity.DO_R_C_S_or_R_C_M_Number__c == oOldAccount.R_C_S_or_R_C_M_Number__c) || (oOpportunity.DO_R_C_S_or_R_C_M_Number__c == oNewAccount.R_C_S_or_R_C_M_Number__c))){
                    status = true;
                    oOpportunity.DO_R_C_S_or_R_C_M_Number__c = oNewAccount.R_C_S_or_R_C_M_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_R_C_S_or_R_C_M_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_R_C_S_or_R_C_M_Number__c] to [' + String.valueOf(oNewAccount.R_C_S_or_R_C_M_Number__c) + ']');
                } else {
                    if (oOldAccount.R_C_S_or_R_C_M_Number__c == oNewAccount.R_C_S_or_R_C_M_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_R_C_S_or_R_C_M_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_R_C_S_or_R_C_M_Number__c != oOldAccount.R_C_S_or_R_C_M_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_R_C_S_or_R_C_M_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.R_C_S_or_R_C_M_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_R_C_S_or_R_C_M_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Salutation__c != oNewAccount.Salutation__c) && ((oOpportunity.DO_Salutation__c == oOldAccount.Salutation__c) || (oOpportunity.DO_Salutation__c == oNewAccount.Salutation__c))){
                    status = true;
                    oOpportunity.DO_Salutation__c = oNewAccount.Salutation__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Salutation__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Salutation__c] to [' + String.valueOf(oNewAccount.Salutation__c) + ']');
                } else {
                    if (oOldAccount.Salutation__c == oNewAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Salutation__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Salutation__c != oOldAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Salutation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Salutation__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Salutation__c) + '])');
                    }
            }
            if ((oOldAccount.Scale__c != oNewAccount.Scale__c) && ((oOpportunity.DO_Scale__c == oOldAccount.Scale__c) || (oOpportunity.DO_Scale__c == oNewAccount.Scale__c))){
                    status = true;
                    oOpportunity.DO_Scale__c = oNewAccount.Scale__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Scale__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Scale__c] to [' + String.valueOf(oNewAccount.Scale__c) + ']');
                } else {
                    if (oOldAccount.Scale__c == oNewAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Scale__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Scale__c != oOldAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Scale__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Scale__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Scale__c) + '])');
                    }
            }
            if ((oOldAccount.Segmentation__c != oNewAccount.Segmentation__c) && ((oOpportunity.DO_Segmentation__c == oOldAccount.Segmentation__c) || (oOpportunity.DO_Segmentation__c == oNewAccount.Segmentation__c))){
                    status = true;
                    oOpportunity.DO_Segmentation__c = oNewAccount.Segmentation__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Segmentation__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Segmentation__c] to [' + String.valueOf(oNewAccount.Segmentation__c) + ']');
                } else {
                    if (oOldAccount.Segmentation__c == oNewAccount.Segmentation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Segmentation__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Segmentation__c != oOldAccount.Segmentation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Segmentation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Segmentation__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Segmentation__c) + '])');
                    }
            }
            if ((oOldAccount.Street_N__c != oNewAccount.Street_N__c) && ((oOpportunity.DO_Street_N__c == oOldAccount.Street_N__c) || (oOpportunity.DO_Street_N__c == oNewAccount.Street_N__c))){
                    status = true;
                    oOpportunity.DO_Street_N__c = oNewAccount.Street_N__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Street_N__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Street_N__c] to [' + String.valueOf(oNewAccount.Street_N__c) + ']');
                } else {
                    if (oOldAccount.Street_N__c == oNewAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_N__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Street_N__c != oOldAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_N__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_N__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Street_N__c) + '])');
                    }
            }
            if ((oOldAccount.Street_Number__c != oNewAccount.Street_Number__c) && ((oOpportunity.DO_Street_Number__c == oOldAccount.Street_Number__c) || (oOpportunity.DO_Street_Number__c == oNewAccount.Street_Number__c))){
                    status = true;
                    oOpportunity.DO_Street_Number__c = oNewAccount.Street_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Street_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Street_Number__c] to [' + String.valueOf(oNewAccount.Street_Number__c) + ']');
                } else {
                    if (oOldAccount.Street_Number__c == oNewAccount.Street_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Street_Number__c != oOldAccount.Street_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Street_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Street_name__c != oNewAccount.Street_name__c) && ((oOpportunity.DO_Street_name__c == oOldAccount.Street_name__c) || (oOpportunity.DO_Street_name__c == oNewAccount.Street_name__c))){
                    status = true;
                    oOpportunity.DO_Street_name__c = oNewAccount.Street_name__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Street_name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Street_name__c] to [' + String.valueOf(oNewAccount.Street_name__c) + ']');
                } else {
                    if (oOldAccount.Street_name__c == oNewAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Street_name__c != oOldAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_name__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Street_name__c) + '])');
                    }
            }
            if ((oOldAccount.Street_type__c != oNewAccount.Street_type__c) && ((oOpportunity.DO_Street_type__c == oOldAccount.Street_type__c) || (oOpportunity.DO_Street_type__c == oNewAccount.Street_type__c))){
                    status = true;
                    oOpportunity.DO_Street_type__c = oNewAccount.Street_type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Street_type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Street_type__c] to [' + String.valueOf(oNewAccount.Street_type__c) + ']');
                } else {
                    if (oOldAccount.Street_type__c == oNewAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Street_type__c != oOldAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Street_type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_type__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Street_type__c) + '])');
                    }
            }
            if ((oOldAccount.Sub_Channel__c != oNewAccount.Sub_Channel__c) && ((oOpportunity.DO_Sub_Channel__c == oOldAccount.Sub_Channel__c) || (oOpportunity.DO_Sub_Channel__c == oNewAccount.Sub_Channel__c))){
                    status = true;
                    oOpportunity.DO_Sub_Channel__c = oNewAccount.Sub_Channel__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Sub_Channel__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Sub_Channel__c] to [' + String.valueOf(oNewAccount.Sub_Channel__c) + ']');
                } else {
                    if (oOldAccount.Sub_Channel__c == oNewAccount.Sub_Channel__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Sub_Channel__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Sub_Channel__c != oOldAccount.Sub_Channel__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Sub_Channel__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Sub_Channel__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Sub_Channel__c) + '])');
                    }
            }
            if ((oOldAccount.Type__c != oNewAccount.Type__c) && ((oOpportunity.DO_Type__c == oOldAccount.Type__c) || (oOpportunity.DO_Type__c == oNewAccount.Type__c))){
                    status = true;
                    oOpportunity.DO_Type__c = oNewAccount.Type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Type__c] to [' + String.valueOf(oNewAccount.Type__c) + ']');
                } else {
                    if (oOldAccount.Type__c == oNewAccount.Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Type__c != oOldAccount.Type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Type__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Type__c) + '])');
                    }
            }
            if ((oOldAccount.Work_Phone_Number__c != oNewAccount.Work_Phone_Number__c) && ((oOpportunity.DO_Work_Phone_Number__c == oOldAccount.Work_Phone_Number__c) || (oOpportunity.DO_Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c))){
                    status = true;
                    oOpportunity.DO_Work_Phone_Number__c = oNewAccount.Work_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Work_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Work_Phone_Number__c] to [' + String.valueOf(oNewAccount.Work_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Work_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Work_Phone_Number__c != oOldAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Work_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Work_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Work_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Phone != oNewAccount.Phone) && ((oOpportunity.DO_Phone__c == oOldAccount.Phone) || (oOpportunity.DO_Phone__c == oNewAccount.Phone))){
                    status = true;
                    oOpportunity.DO_Phone__c = oNewAccount.Phone;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Phone__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Phone__c] to [' + String.valueOf(oNewAccount.Phone) + ']');
                } else {
                    if (oOldAccount.Phone == oNewAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Phone__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Phone__c != oOldAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Phone__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone) + '] != synced:[' + String.valueOf(oOpportunity.DO_Phone__c) + '])');
                    }
            }
            if ((oOldAccount.Name != oNewAccount.Name) && ((oOpportunity.DO_Name__c == oOldAccount.Name) || (oOpportunity.DO_Name__c == oNewAccount.Name))){
                    status = true;
                    oOpportunity.DO_Name__c = oNewAccount.Name;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Name__c] to [' + String.valueOf(oNewAccount.Name) + ']');
                } else {
                    if (oOldAccount.Name == oNewAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Name__c != oOldAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Name) + '] != synced:[' + String.valueOf(oOpportunity.DO_Name__c) + '])');
                    }
            }
            if ((oOldAccount.ParentId != oNewAccount.ParentId) && ((oOpportunity.DO_ParentId__c == oOldAccount.ParentId) || (oOpportunity.DO_ParentId__c == oNewAccount.ParentId))){
                    status = true;
                    oOpportunity.DO_ParentId__c = oNewAccount.ParentId;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_ParentId__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_ParentId__c] to [' + String.valueOf(oNewAccount.ParentId) + ']');
                } else {
                    if (oOldAccount.ParentId == oNewAccount.ParentId) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_ParentId__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_ParentId__c != oOldAccount.ParentId) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_ParentId__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.ParentId) + '] != synced:[' + String.valueOf(oOpportunity.DO_ParentId__c) + '])');
                    }
            }
            if ((oOldAccount.AccountNumber != oNewAccount.AccountNumber) && ((oOpportunity.DO_AccountNumber__c == oOldAccount.AccountNumber) || (oOpportunity.DO_AccountNumber__c == oNewAccount.AccountNumber))){
                    status = true;
                    oOpportunity.DO_AccountNumber__c = oNewAccount.AccountNumber;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_AccountNumber__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_AccountNumber__c] to [' + String.valueOf(oNewAccount.AccountNumber) + ']');
                } else {
                    if (oOldAccount.AccountNumber == oNewAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_AccountNumber__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_AccountNumber__c != oOldAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_AccountNumber__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.AccountNumber) + '] != synced:[' + String.valueOf(oOpportunity.DO_AccountNumber__c) + '])');
                    }
            }
            
            
            
             if ((oOldAccount.Indicatif_Pays__c != oNewAccount.Indicatif_Pays__c) && ((oOpportunity.DO_Indicatif_pays__c == oOldAccount.Indicatif_Pays__c) || (oOpportunity.DO_Indicatif_pays__c == oNewAccount.Indicatif_Pays__c))){
                    status = true;
                    oOpportunity.DO_Indicatif_pays__c = oNewAccount.Indicatif_Pays__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___DO_Indicatif_pays__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Synced field [oOpportunity.DO_Indicatif_pays__c] to [' + String.valueOf(oNewAccount.Indicatif_Pays__c) + ']');
                } else {
                    if (oOldAccount.Indicatif_Pays__c == oNewAccount.Indicatif_Pays__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Indicatif_pays__c] :: Field was not changed.');
                    }
                    if (oOpportunity.DO_Indicatif_pays__c != oOldAccount.Indicatif_Pays__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateDO_Fields] Skipped field [oOpportunity.DO_Indicatif_pays__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Indicatif_Pays__c) + '] != synced:[' + String.valueOf(oOpportunity.DO_Country__c) + '])');
                    }
            }
            
            
            
            
            // END_AUTO_PROPAGATE_Account
        }
        return status;
    }
    public static Boolean propagatePayer_Fields(Opportunity oOpportunity, Map<Id, Account> mOldAccounts, Map<Id, Account> mNewAccounts){
        Account oOldAccount = mOldAccounts.get(oOpportunity.Account_Payer__c);
        Account oNewAccount = mNewAccounts.get(oOpportunity.Account_Payer__c);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Starting.');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] oOldAccount:[' + oOldAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] oNewAccount:[' + oNewAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] oOpportunity:[' + oOpportunity + ']');
        if ((oOldAccount != null) && (oNewAccount != null)) { // that's equivalent. We're just checking whether the Opportunity had this specific Account, Account_Payer__c lookup updated
            // BEGIN_AUTO_PROPAGATE_Account_Payer__r
            if ((oOldAccount.Accounting_Manager_Code__c != oNewAccount.Accounting_Manager_Code__c) && ((oOpportunity.Payer_Accounting_Manager_Code__c == oOldAccount.Accounting_Manager_Code__c) || (oOpportunity.Payer_Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c))){
                    status = true;
                    oOpportunity.Payer_Accounting_Manager_Code__c = oNewAccount.Accounting_Manager_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Accounting_Manager_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Accounting_Manager_Code__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Code__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Accounting_Manager_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Accounting_Manager_Code__c != oOldAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Accounting_Manager_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Accounting_Manager_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Accounting_Manager_Value__c != oNewAccount.Accounting_Manager_Value__c) && ((oOpportunity.Payer_Accounting_Manager_Value__c == oOldAccount.Accounting_Manager_Value__c) || (oOpportunity.Payer_Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c))){
                    status = true;
                    oOpportunity.Payer_Accounting_Manager_Value__c = oNewAccount.Accounting_Manager_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Accounting_Manager_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Accounting_Manager_Value__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Value__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Accounting_Manager_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Accounting_Manager_Value__c != oOldAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Accounting_Manager_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Accounting_Manager_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Cedex__c != oNewAccount.Cedex__c) && ((oOpportunity.Payer_Cedex__c == oOldAccount.Cedex__c) || (oOpportunity.Payer_Cedex__c == oNewAccount.Cedex__c))){
                    status = true;
                    oOpportunity.Payer_Cedex__c = oNewAccount.Cedex__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Cedex__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Cedex__c] to [' + String.valueOf(oNewAccount.Cedex__c) + ']');
                } else {
                    if (oOldAccount.Cedex__c == oNewAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Cedex__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Cedex__c != oOldAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Cedex__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Cedex__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Cedex__c) + '])');
                    }
            }
            if ((oOldAccount.City_Postal_Code__c != oNewAccount.City_Postal_Code__c) && ((oOpportunity.Payer_City_Postal_Code__c == oOldAccount.City_Postal_Code__c) || (oOpportunity.Payer_City_Postal_Code__c == oNewAccount.City_Postal_Code__c))){
                    status = true;
                    oOpportunity.Payer_City_Postal_Code__c = oNewAccount.City_Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_City_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_City_Postal_Code__c] to [' + String.valueOf(oNewAccount.City_Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.City_Postal_Code__c == oNewAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_City_Postal_Code__c != oOldAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_City_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.City__c != oNewAccount.City__c) && ((oOpportunity.Payer_City__c == oOldAccount.City__c) || (oOpportunity.Payer_City__c == oNewAccount.City__c))){
                    status = true;
                    oOpportunity.Payer_City__c = oNewAccount.City__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_City__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_City__c] to [' + String.valueOf(oNewAccount.City__c) + ']');
                } else {
                    if (oOldAccount.City__c == oNewAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_City__c != oOldAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_City__c) + '])');
                    }
            }
            if ((oOldAccount.City_code__c != oNewAccount.City_code__c) && ((oOpportunity.Payer_City_code__c == oOldAccount.City_code__c) || (oOpportunity.Payer_City_code__c == oNewAccount.City_code__c))){
                    status = true;
                    oOpportunity.Payer_City_code__c = oNewAccount.City_code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_City_code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_City_code__c] to [' + String.valueOf(oNewAccount.City_code__c) + ']');
                } else {
                    if (oOldAccount.City_code__c == oNewAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City_code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_City_code__c != oOldAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_City_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_code__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_City_code__c) + '])');
                    }
            }
            if ((oOldAccount.Country__c != oNewAccount.Country__c) && ((oOpportunity.Payer_Country__c == oOldAccount.Country__c) || (oOpportunity.Payer_Country__c == oNewAccount.Country__c))){
                    status = true;
                    oOpportunity.Payer_Country__c = oNewAccount.Country__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Country__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Country__c] to [' + String.valueOf(oNewAccount.Country__c) + ']');
                } else {
                    if (oOldAccount.Country__c == oNewAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Country__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Country__c != oOldAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Country__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Country__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Country__c) + '])');
                    }
            }
            if ((oOldAccount.Department__c != oNewAccount.Department__c) && ((oOpportunity.Payer_Department__c == oOldAccount.Department__c) || (oOpportunity.Payer_Department__c == oNewAccount.Department__c))){
                    status = true;
                    oOpportunity.Payer_Department__c = oNewAccount.Department__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Department__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Department__c] to [' + String.valueOf(oNewAccount.Department__c) + ']');
                } else {
                    if (oOldAccount.Department__c == oNewAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Department__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Department__c != oOldAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Department__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Department__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Department__c) + '])');
                    }
            }
            if ((oOldAccount.Email_2__c != oNewAccount.Email_2__c) && ((oOpportunity.Payer_Email_2__c == oOldAccount.Email_2__c) || (oOpportunity.Payer_Email_2__c == oNewAccount.Email_2__c))){
                    status = true;
                    oOpportunity.Payer_Email_2__c = oNewAccount.Email_2__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Email_2__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Email_2__c] to [' + String.valueOf(oNewAccount.Email_2__c) + ']');
                } else {
                    if (oOldAccount.Email_2__c == oNewAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Email_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Email_2__c != oOldAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Email_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email_2__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Email_2__c) + '])');
                    }
            }
            if ((oOldAccount.Email__c != oNewAccount.Email__c) && ((oOpportunity.Payer_Email__c == oOldAccount.Email__c) || (oOpportunity.Payer_Email__c == oNewAccount.Email__c))){
                    status = true;
                    oOpportunity.Payer_Email__c = oNewAccount.Email__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Email__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Email__c] to [' + String.valueOf(oNewAccount.Email__c) + ']');
                } else {
                    if (oOldAccount.Email__c == oNewAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Email__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Email__c != oOldAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Email__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Email__c) + '])');
                    }
            }
            if ((oOldAccount.Invoicing_Frequency__c != oNewAccount.Invoicing_Frequency__c) && ((oOpportunity.Payer_Invoicing_Frequency__c == oOldAccount.Invoicing_Frequency__c) || (oOpportunity.Payer_Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c))){
                    status = true;
                    oOpportunity.Payer_Invoicing_Frequency__c = oNewAccount.Invoicing_Frequency__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Invoicing_Frequency__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Invoicing_Frequency__c] to [' + String.valueOf(oNewAccount.Invoicing_Frequency__c) + ']');
                } else {
                    if (oOldAccount.Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Invoicing_Frequency__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Invoicing_Frequency__c != oOldAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Invoicing_Frequency__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Invoicing_Frequency__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Invoicing_Frequency__c) + '])');
                    }
            }
            if ((oOldAccount.Mobile_Phone_Number__c != oNewAccount.Mobile_Phone_Number__c) && ((oOpportunity.Payer_Mobile_Phone_Number__c == oOldAccount.Mobile_Phone_Number__c) || (oOpportunity.Payer_Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c))){
                    status = true;
                    oOpportunity.Payer_Mobile_Phone_Number__c = oNewAccount.Mobile_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Mobile_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Mobile_Phone_Number__c] to [' + String.valueOf(oNewAccount.Mobile_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Mobile_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Mobile_Phone_Number__c != oOldAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Mobile_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Mobile_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Mobile_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.No_E_mail__c != oNewAccount.No_E_mail__c) && ((oOpportunity.Payer_No_E_mail__c == oOldAccount.No_E_mail__c) || (oOpportunity.Payer_No_E_mail__c == oNewAccount.No_E_mail__c))){
                    status = true;
                    oOpportunity.Payer_No_E_mail__c = oNewAccount.No_E_mail__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_No_E_mail__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_No_E_mail__c] to [' + String.valueOf(oNewAccount.No_E_mail__c) + ']');
                } else {
                    if (oOldAccount.No_E_mail__c == oNewAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_No_E_mail__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_No_E_mail__c != oOldAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_No_E_mail__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.No_E_mail__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_No_E_mail__c) + '])');
                    }
            }
            if ((oOldAccount.Number_extention__c != oNewAccount.Number_extention__c) && ((oOpportunity.Payer_Number_extention__c == oOldAccount.Number_extention__c) || (oOpportunity.Payer_Number_extention__c == oNewAccount.Number_extention__c))){
                    status = true;
                    oOpportunity.Payer_Number_extention__c = oNewAccount.Number_extention__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Number_extention__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Number_extention__c] to [' + String.valueOf(oNewAccount.Number_extention__c) + ']');
                } else {
                    if (oOldAccount.Number_extention__c == oNewAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Number_extention__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Number_extention__c != oOldAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Number_extention__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Number_extention__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Number_extention__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Code__c != oNewAccount.Payment_Time_Code__c) && ((oOpportunity.Payer_Payment_Time_Code__c == oOldAccount.Payment_Time_Code__c) || (oOpportunity.Payer_Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c))){
                    status = true;
                    oOpportunity.Payer_Payment_Time_Code__c = oNewAccount.Payment_Time_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_Time_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Payment_Time_Code__c] to [' + String.valueOf(oNewAccount.Payment_Time_Code__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_Time_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Payment_Time_Code__c != oOldAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_Time_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Payment_Time_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Value__c != oNewAccount.Payment_Time_Value__c) && ((oOpportunity.Payer_Payment_Time_Value__c == oOldAccount.Payment_Time_Value__c) || (oOpportunity.Payer_Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c))){
                    status = true;
                    oOpportunity.Payer_Payment_Time_Value__c = oNewAccount.Payment_Time_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_Time_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Payment_Time_Value__c] to [' + String.valueOf(oNewAccount.Payment_Time_Value__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_Time_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Payment_Time_Value__c != oOldAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_Time_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Payment_Time_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_method__c != oNewAccount.Payment_method__c) && ((oOpportunity.Payer_Payment_method__c == oOldAccount.Payment_method__c) || (oOpportunity.Payer_Payment_method__c == oNewAccount.Payment_method__c))){
                    status = true;
                    oOpportunity.Payer_Payment_method__c = oNewAccount.Payment_method__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Payment_method__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Payment_method__c] to [' + String.valueOf(oNewAccount.Payment_method__c) + ']');
                } else {
                    if (oOldAccount.Payment_method__c == oNewAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_method__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Payment_method__c != oOldAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Payment_method__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_method__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Payment_method__c) + '])');
                    }
            }
            if ((oOldAccount.Phone_Restriction__c != oNewAccount.Phone_Restriction__c) && ((oOpportunity.Payer_Phone_Restriction__c == oOldAccount.Phone_Restriction__c) || (oOpportunity.Payer_Phone_Restriction__c == oNewAccount.Phone_Restriction__c))){
                    status = true;
                    oOpportunity.Payer_Phone_Restriction__c = oNewAccount.Phone_Restriction__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Phone_Restriction__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Phone_Restriction__c] to [' + String.valueOf(oNewAccount.Phone_Restriction__c) + ']');
                } else {
                    if (oOldAccount.Phone_Restriction__c == oNewAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Phone_Restriction__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Phone_Restriction__c != oOldAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Phone_Restriction__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone_Restriction__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Phone_Restriction__c) + '])');
                    }
            }
            if ((oOldAccount.Place_Called__c != oNewAccount.Place_Called__c) && ((oOpportunity.Payer_Place_Called__c == oOldAccount.Place_Called__c) || (oOpportunity.Payer_Place_Called__c == oNewAccount.Place_Called__c))){
                    status = true;
                    oOpportunity.Payer_Place_Called__c = oNewAccount.Place_Called__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Place_Called__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Place_Called__c] to [' + String.valueOf(oNewAccount.Place_Called__c) + ']');
                } else {
                    if (oOldAccount.Place_Called__c == oNewAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Place_Called__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Place_Called__c != oOldAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Place_Called__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Place_Called__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Place_Called__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Box__c != oNewAccount.Postal_Box__c) && ((oOpportunity.Payer_Postal_Box__c == oOldAccount.Postal_Box__c) || (oOpportunity.Payer_Postal_Box__c == oNewAccount.Postal_Box__c))){
                    status = true;
                    oOpportunity.Payer_Postal_Box__c = oNewAccount.Postal_Box__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Postal_Box__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Postal_Box__c] to [' + String.valueOf(oNewAccount.Postal_Box__c) + ']');
                } else {
                    if (oOldAccount.Postal_Box__c == oNewAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Postal_Box__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Postal_Box__c != oOldAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Postal_Box__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Box__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Postal_Box__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Code__c != oNewAccount.Postal_Code__c) && ((oOpportunity.Payer_Postal_Code__c == oOldAccount.Postal_Code__c) || (oOpportunity.Payer_Postal_Code__c == oNewAccount.Postal_Code__c))){
                    status = true;
                    oOpportunity.Payer_Postal_Code__c = oNewAccount.Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Postal_Code__c] to [' + String.valueOf(oNewAccount.Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.Postal_Code__c == oNewAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Postal_Code__c != oOldAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Salutation__c != oNewAccount.Salutation__c) && ((oOpportunity.Payer_Salutation__c == oOldAccount.Salutation__c) || (oOpportunity.Payer_Salutation__c == oNewAccount.Salutation__c))){
                    status = true;
                    oOpportunity.Payer_Salutation__c = oNewAccount.Salutation__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Salutation__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Salutation__c] to [' + String.valueOf(oNewAccount.Salutation__c) + ']');
                } else {
                    if (oOldAccount.Salutation__c == oNewAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Salutation__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Salutation__c != oOldAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Salutation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Salutation__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Salutation__c) + '])');
                    }
            }
            if ((oOldAccount.Scale__c != oNewAccount.Scale__c) && ((oOpportunity.Payer_Scale__c == oOldAccount.Scale__c) || (oOpportunity.Payer_Scale__c == oNewAccount.Scale__c))){
                    status = true;
                    oOpportunity.Payer_Scale__c = oNewAccount.Scale__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Scale__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Scale__c] to [' + String.valueOf(oNewAccount.Scale__c) + ']');
                } else {
                    if (oOldAccount.Scale__c == oNewAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Scale__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Scale__c != oOldAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Scale__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Scale__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Scale__c) + '])');
                    }
            }
            if ((oOldAccount.Street_N__c != oNewAccount.Street_N__c) && ((oOpportunity.Payer_Street_N__c == oOldAccount.Street_N__c) || (oOpportunity.Payer_Street_N__c == oNewAccount.Street_N__c))){
                    status = true;
                    oOpportunity.Payer_Street_N__c = oNewAccount.Street_N__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_N__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Street_N__c] to [' + String.valueOf(oNewAccount.Street_N__c) + ']');
                } else {
                    if (oOldAccount.Street_N__c == oNewAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_N__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Street_N__c != oOldAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_N__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_N__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Street_N__c) + '])');
                    }
            }
            if ((oOldAccount.Street_name__c != oNewAccount.Street_name__c) && ((oOpportunity.Payer_Street_name__c == oOldAccount.Street_name__c) || (oOpportunity.Payer_Street_name__c == oNewAccount.Street_name__c))){
                    status = true;
                    oOpportunity.Payer_Street_name__c = oNewAccount.Street_name__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Street_name__c] to [' + String.valueOf(oNewAccount.Street_name__c) + ']');
                } else {
                    if (oOldAccount.Street_name__c == oNewAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Street_name__c != oOldAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_name__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Street_name__c) + '])');
                    }
            }
            if ((oOldAccount.Street_type__c != oNewAccount.Street_type__c) && ((oOpportunity.Payer_Street_type__c == oOldAccount.Street_type__c) || (oOpportunity.Payer_Street_type__c == oNewAccount.Street_type__c))){
                    status = true;
                    oOpportunity.Payer_Street_type__c = oNewAccount.Street_type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Street_type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Street_type__c] to [' + String.valueOf(oNewAccount.Street_type__c) + ']');
                } else {
                    if (oOldAccount.Street_type__c == oNewAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Street_type__c != oOldAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Street_type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_type__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Street_type__c) + '])');
                    }
            }
            if ((oOldAccount.Work_Phone_Number__c != oNewAccount.Work_Phone_Number__c) && ((oOpportunity.Payer_Work_Phone_Number__c == oOldAccount.Work_Phone_Number__c) || (oOpportunity.Payer_Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c))){
                    status = true;
                    oOpportunity.Payer_Work_Phone_Number__c = oNewAccount.Work_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Work_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Work_Phone_Number__c] to [' + String.valueOf(oNewAccount.Work_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Work_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Work_Phone_Number__c != oOldAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Work_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Work_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Work_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Fax != oNewAccount.Fax) && ((oOpportunity.Payer_Fax__c == oOldAccount.Fax) || (oOpportunity.Payer_Fax__c == oNewAccount.Fax))){
                    status = true;
                    oOpportunity.Payer_Fax__c = oNewAccount.Fax;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Fax__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Fax__c] to [' + String.valueOf(oNewAccount.Fax) + ']');
                } else {
                    if (oOldAccount.Fax == oNewAccount.Fax) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Fax__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Fax__c != oOldAccount.Fax) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Fax__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Fax) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Fax__c) + '])');
                    }
            }
            if ((oOldAccount.Phone != oNewAccount.Phone) && ((oOpportunity.Payer_Phone__c == oOldAccount.Phone) || (oOpportunity.Payer_Phone__c == oNewAccount.Phone))){
                    status = true;
                    oOpportunity.Payer_Phone__c = oNewAccount.Phone;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Phone__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Phone__c] to [' + String.valueOf(oNewAccount.Phone) + ']');
                } else {
                    if (oOldAccount.Phone == oNewAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Phone__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Phone__c != oOldAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Phone__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Phone__c) + '])');
                    }
            }
            if ((oOldAccount.Name != oNewAccount.Name) && ((oOpportunity.Payer_Name__c == oOldAccount.Name) || (oOpportunity.Payer_Name__c == oNewAccount.Name))){
                    status = true;
                    oOpportunity.Payer_Name__c = oNewAccount.Name;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_Name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_Name__c] to [' + String.valueOf(oNewAccount.Name) + ']');
                } else {
                    if (oOldAccount.Name == oNewAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_Name__c != oOldAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_Name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Name) + '] != synced:[' + String.valueOf(oOpportunity.Payer_Name__c) + '])');
                    }
            }
            if ((oOldAccount.AccountNumber != oNewAccount.AccountNumber) && ((oOpportunity.Payer_AccountNumber__c == oOldAccount.AccountNumber) || (oOpportunity.Payer_AccountNumber__c == oNewAccount.AccountNumber))){
                    status = true;
                    oOpportunity.Payer_AccountNumber__c = oNewAccount.AccountNumber;
                    oOpportunity.T_AccountFieldsToChange__c += '___Payer_AccountNumber__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Synced field [oOpportunity.Payer_AccountNumber__c] to [' + String.valueOf(oNewAccount.AccountNumber) + ']');
                } else {
                    if (oOldAccount.AccountNumber == oNewAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_AccountNumber__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Payer_AccountNumber__c != oOldAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagatePayer_Fields] Skipped field [oOpportunity.Payer_AccountNumber__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.AccountNumber) + '] != synced:[' + String.valueOf(oOpportunity.Payer_AccountNumber__c) + '])');
                    }
            }
            // END_AUTO_PROPAGATE_Account_Payer__r
        }
        return status;
    }
    public static Boolean propagateBilled_Fields(Opportunity oOpportunity, Map<Id, Account> mOldAccounts, Map<Id, Account> mNewAccounts){
        Account oOldAccount = mOldAccounts.get(oOpportunity.Account_Billed__c);
        Account oNewAccount = mNewAccounts.get(oOpportunity.Account_Billed__c);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Starting.');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] oOldAccount:[' + oOldAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] oNewAccount:[' + oNewAccount + ']');
        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] oOpportunity:[' + oOpportunity + ']');
        if ((oOldAccount != null) && (oNewAccount != null)) { // that's equivalent. We're just checking whether the Opportunity had this specific Account, Account_Billed__c lookup updated
            // BEGIN_AUTO_PROPAGATE_Account_Billed__r
            if ((oOldAccount.Accounting_Manager_Code__c != oNewAccount.Accounting_Manager_Code__c) && ((oOpportunity.Billed_Accounting_Manager_Code__c == oOldAccount.Accounting_Manager_Code__c) || (oOpportunity.Billed_Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c))){
                    status = true;
                    oOpportunity.Billed_Accounting_Manager_Code__c = oNewAccount.Accounting_Manager_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Accounting_Manager_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Accounting_Manager_Code__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Code__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Code__c == oNewAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Accounting_Manager_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Accounting_Manager_Code__c != oOldAccount.Accounting_Manager_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Accounting_Manager_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Accounting_Manager_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Accounting_Manager_Value__c != oNewAccount.Accounting_Manager_Value__c) && ((oOpportunity.Billed_Accounting_Manager_Value__c == oOldAccount.Accounting_Manager_Value__c) || (oOpportunity.Billed_Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c))){
                    status = true;
                    oOpportunity.Billed_Accounting_Manager_Value__c = oNewAccount.Accounting_Manager_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Accounting_Manager_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Accounting_Manager_Value__c] to [' + String.valueOf(oNewAccount.Accounting_Manager_Value__c) + ']');
                } else {
                    if (oOldAccount.Accounting_Manager_Value__c == oNewAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Accounting_Manager_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Accounting_Manager_Value__c != oOldAccount.Accounting_Manager_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Accounting_Manager_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Accounting_Manager_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Accounting_Manager_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Cedex__c != oNewAccount.Cedex__c) && ((oOpportunity.Billed_Cedex__c == oOldAccount.Cedex__c) || (oOpportunity.Billed_Cedex__c == oNewAccount.Cedex__c))){
                    status = true;
                    oOpportunity.Billed_Cedex__c = oNewAccount.Cedex__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Cedex__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Cedex__c] to [' + String.valueOf(oNewAccount.Cedex__c) + ']');
                } else {
                    if (oOldAccount.Cedex__c == oNewAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Cedex__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Cedex__c != oOldAccount.Cedex__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Cedex__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Cedex__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Cedex__c) + '])');
                    }
            }
            if ((oOldAccount.City_Postal_Code__c != oNewAccount.City_Postal_Code__c) && ((oOpportunity.Billed_City_Postal_Code__c == oOldAccount.City_Postal_Code__c) || (oOpportunity.Billed_City_Postal_Code__c == oNewAccount.City_Postal_Code__c))){
                    status = true;
                    oOpportunity.Billed_City_Postal_Code__c = oNewAccount.City_Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_City_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_City_Postal_Code__c] to [' + String.valueOf(oNewAccount.City_Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.City_Postal_Code__c == oNewAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_City_Postal_Code__c != oOldAccount.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_City_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.City__c != oNewAccount.City__c) && ((oOpportunity.Billed_City__c == oOldAccount.City__c) || (oOpportunity.Billed_City__c == oNewAccount.City__c))){
                    status = true;
                    oOpportunity.Billed_City__c = oNewAccount.City__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_City__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_City__c] to [' + String.valueOf(oNewAccount.City__c) + ']');
                } else {
                    if (oOldAccount.City__c == oNewAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_City__c != oOldAccount.City__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_City__c) + '])');
                    }
            }
            if ((oOldAccount.City_code__c != oNewAccount.City_code__c) && ((oOpportunity.Billed_City_code__c == oOldAccount.City_code__c) || (oOpportunity.Billed_City_code__c == oNewAccount.City_code__c))){
                    status = true;
                    oOpportunity.Billed_City_code__c = oNewAccount.City_code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_City_code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_City_code__c] to [' + String.valueOf(oNewAccount.City_code__c) + ']');
                } else {
                    if (oOldAccount.City_code__c == oNewAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City_code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_City_code__c != oOldAccount.City_code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_City_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.City_code__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_City_code__c) + '])');
                    }
            }
            if ((oOldAccount.Country__c != oNewAccount.Country__c) && ((oOpportunity.Billed_Country__c == oOldAccount.Country__c) || (oOpportunity.Billed_Country__c == oNewAccount.Country__c))){
                    status = true;
                    oOpportunity.Billed_Country__c = oNewAccount.Country__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Country__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Country__c] to [' + String.valueOf(oNewAccount.Country__c) + ']');
                } else {
                    if (oOldAccount.Country__c == oNewAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Country__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Country__c != oOldAccount.Country__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Country__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Country__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Country__c) + '])');
                    }
            }
            if ((oOldAccount.Department__c != oNewAccount.Department__c) && ((oOpportunity.Billed_Department__c == oOldAccount.Department__c) || (oOpportunity.Billed_Department__c == oNewAccount.Department__c))){
                    status = true;
                    oOpportunity.Billed_Department__c = oNewAccount.Department__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Department__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Department__c] to [' + String.valueOf(oNewAccount.Department__c) + ']');
                } else {
                    if (oOldAccount.Department__c == oNewAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Department__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Department__c != oOldAccount.Department__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Department__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Department__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Department__c) + '])');
                    }
            }
            if ((oOldAccount.Email_2__c != oNewAccount.Email_2__c) && ((oOpportunity.Billed_Email_2__c == oOldAccount.Email_2__c) || (oOpportunity.Billed_Email_2__c == oNewAccount.Email_2__c))){
                    status = true;
                    oOpportunity.Billed_Email_2__c = oNewAccount.Email_2__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Email_2__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Email_2__c] to [' + String.valueOf(oNewAccount.Email_2__c) + ']');
                } else {
                    if (oOldAccount.Email_2__c == oNewAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Email_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Email_2__c != oOldAccount.Email_2__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Email_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email_2__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Email_2__c) + '])');
                    }
            }
            if ((oOldAccount.Email__c != oNewAccount.Email__c) && ((oOpportunity.Billed_Email__c == oOldAccount.Email__c) || (oOpportunity.Billed_Email__c == oNewAccount.Email__c))){
                    status = true;
                    oOpportunity.Billed_Email__c = oNewAccount.Email__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Email__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Email__c] to [' + String.valueOf(oNewAccount.Email__c) + ']');
                } else {
                    if (oOldAccount.Email__c == oNewAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Email__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Email__c != oOldAccount.Email__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Email__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Email__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Email__c) + '])');
                    }
            }
            if ((oOldAccount.Invoicing_Frequency__c != oNewAccount.Invoicing_Frequency__c) && ((oOpportunity.Billed_Invoicing_Frequency__c == oOldAccount.Invoicing_Frequency__c) || (oOpportunity.Billed_Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c))){
                    status = true;
                    oOpportunity.Billed_Invoicing_Frequency__c = oNewAccount.Invoicing_Frequency__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Invoicing_Frequency__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Invoicing_Frequency__c] to [' + String.valueOf(oNewAccount.Invoicing_Frequency__c) + ']');
                } else {
                    if (oOldAccount.Invoicing_Frequency__c == oNewAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Invoicing_Frequency__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Invoicing_Frequency__c != oOldAccount.Invoicing_Frequency__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Invoicing_Frequency__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Invoicing_Frequency__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Invoicing_Frequency__c) + '])');
                    }
            }
            if ((oOldAccount.Mobile_Phone_Number__c != oNewAccount.Mobile_Phone_Number__c) && ((oOpportunity.Billed_Mobile_Phone_Number__c == oOldAccount.Mobile_Phone_Number__c) || (oOpportunity.Billed_Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c))){
                    status = true;
                    oOpportunity.Billed_Mobile_Phone_Number__c = oNewAccount.Mobile_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Mobile_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Mobile_Phone_Number__c] to [' + String.valueOf(oNewAccount.Mobile_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Mobile_Phone_Number__c == oNewAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Mobile_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Mobile_Phone_Number__c != oOldAccount.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Mobile_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Mobile_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Mobile_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.No_E_mail__c != oNewAccount.No_E_mail__c) && ((oOpportunity.Billed_No_E_mail__c == oOldAccount.No_E_mail__c) || (oOpportunity.Billed_No_E_mail__c == oNewAccount.No_E_mail__c))){
                    status = true;
                    oOpportunity.Billed_No_E_mail__c = oNewAccount.No_E_mail__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_No_E_mail__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_No_E_mail__c] to [' + String.valueOf(oNewAccount.No_E_mail__c) + ']');
                } else {
                    if (oOldAccount.No_E_mail__c == oNewAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_No_E_mail__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_No_E_mail__c != oOldAccount.No_E_mail__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_No_E_mail__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.No_E_mail__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_No_E_mail__c) + '])');
                    }
            }
            if ((oOldAccount.Number_extention__c != oNewAccount.Number_extention__c) && ((oOpportunity.Billed_Number_extention__c == oOldAccount.Number_extention__c) || (oOpportunity.Billed_Number_extention__c == oNewAccount.Number_extention__c))){
                    status = true;
                    oOpportunity.Billed_Number_extention__c = oNewAccount.Number_extention__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Number_extention__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Number_extention__c] to [' + String.valueOf(oNewAccount.Number_extention__c) + ']');
                } else {
                    if (oOldAccount.Number_extention__c == oNewAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Number_extention__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Number_extention__c != oOldAccount.Number_extention__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Number_extention__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Number_extention__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Number_extention__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Code__c != oNewAccount.Payment_Time_Code__c) && ((oOpportunity.Billed_Payment_Time_Code__c == oOldAccount.Payment_Time_Code__c) || (oOpportunity.Billed_Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c))){
                    status = true;
                    oOpportunity.Billed_Payment_Time_Code__c = oNewAccount.Payment_Time_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_Time_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Payment_Time_Code__c] to [' + String.valueOf(oNewAccount.Payment_Time_Code__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Code__c == oNewAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_Time_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Payment_Time_Code__c != oOldAccount.Payment_Time_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_Time_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Payment_Time_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_Time_Value__c != oNewAccount.Payment_Time_Value__c) && ((oOpportunity.Billed_Payment_Time_Value__c == oOldAccount.Payment_Time_Value__c) || (oOpportunity.Billed_Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c))){
                    status = true;
                    oOpportunity.Billed_Payment_Time_Value__c = oNewAccount.Payment_Time_Value__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_Time_Value__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Payment_Time_Value__c] to [' + String.valueOf(oNewAccount.Payment_Time_Value__c) + ']');
                } else {
                    if (oOldAccount.Payment_Time_Value__c == oNewAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_Time_Value__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Payment_Time_Value__c != oOldAccount.Payment_Time_Value__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_Time_Value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_Time_Value__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Payment_Time_Value__c) + '])');
                    }
            }
            if ((oOldAccount.Payment_method__c != oNewAccount.Payment_method__c) && ((oOpportunity.Billed_Payment_method__c == oOldAccount.Payment_method__c) || (oOpportunity.Billed_Payment_method__c == oNewAccount.Payment_method__c))){
                    status = true;
                    oOpportunity.Billed_Payment_method__c = oNewAccount.Payment_method__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Payment_method__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Payment_method__c] to [' + String.valueOf(oNewAccount.Payment_method__c) + ']');
                } else {
                    if (oOldAccount.Payment_method__c == oNewAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_method__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Payment_method__c != oOldAccount.Payment_method__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Payment_method__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Payment_method__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Payment_method__c) + '])');
                    }
            }
            if ((oOldAccount.Phone_Restriction__c != oNewAccount.Phone_Restriction__c) && ((oOpportunity.Billed_Phone_Restriction__c == oOldAccount.Phone_Restriction__c) || (oOpportunity.Billed_Phone_Restriction__c == oNewAccount.Phone_Restriction__c))){
                    status = true;
                    oOpportunity.Billed_Phone_Restriction__c = oNewAccount.Phone_Restriction__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Phone_Restriction__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Phone_Restriction__c] to [' + String.valueOf(oNewAccount.Phone_Restriction__c) + ']');
                } else {
                    if (oOldAccount.Phone_Restriction__c == oNewAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Phone_Restriction__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Phone_Restriction__c != oOldAccount.Phone_Restriction__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Phone_Restriction__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone_Restriction__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Phone_Restriction__c) + '])');
                    }
            }
            if ((oOldAccount.Place_Called__c != oNewAccount.Place_Called__c) && ((oOpportunity.Billed_Place_Called__c == oOldAccount.Place_Called__c) || (oOpportunity.Billed_Place_Called__c == oNewAccount.Place_Called__c))){
                    status = true;
                    oOpportunity.Billed_Place_Called__c = oNewAccount.Place_Called__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Place_Called__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Place_Called__c] to [' + String.valueOf(oNewAccount.Place_Called__c) + ']');
                } else {
                    if (oOldAccount.Place_Called__c == oNewAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Place_Called__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Place_Called__c != oOldAccount.Place_Called__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Place_Called__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Place_Called__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Place_Called__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Box__c != oNewAccount.Postal_Box__c) && ((oOpportunity.Billed_Postal_Box__c == oOldAccount.Postal_Box__c) || (oOpportunity.Billed_Postal_Box__c == oNewAccount.Postal_Box__c))){
                    status = true;
                    oOpportunity.Billed_Postal_Box__c = oNewAccount.Postal_Box__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Postal_Box__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Postal_Box__c] to [' + String.valueOf(oNewAccount.Postal_Box__c) + ']');
                } else {
                    if (oOldAccount.Postal_Box__c == oNewAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Postal_Box__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Postal_Box__c != oOldAccount.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Postal_Box__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Box__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Postal_Box__c) + '])');
                    }
            }
            if ((oOldAccount.Postal_Code__c != oNewAccount.Postal_Code__c) && ((oOpportunity.Billed_Postal_Code__c == oOldAccount.Postal_Code__c) || (oOpportunity.Billed_Postal_Code__c == oNewAccount.Postal_Code__c))){
                    status = true;
                    oOpportunity.Billed_Postal_Code__c = oNewAccount.Postal_Code__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Postal_Code__c] to [' + String.valueOf(oNewAccount.Postal_Code__c) + ']');
                } else {
                    if (oOldAccount.Postal_Code__c == oNewAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Postal_Code__c != oOldAccount.Postal_Code__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Postal_Code__c) + '])');
                    }
            }
            if ((oOldAccount.Salutation__c != oNewAccount.Salutation__c) && ((oOpportunity.Billed_Salutation__c == oOldAccount.Salutation__c) || (oOpportunity.Billed_Salutation__c == oNewAccount.Salutation__c))){
                    status = true;
                    oOpportunity.Billed_Salutation__c = oNewAccount.Salutation__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Salutation__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Salutation__c] to [' + String.valueOf(oNewAccount.Salutation__c) + ']');
                } else {
                    if (oOldAccount.Salutation__c == oNewAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Salutation__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Salutation__c != oOldAccount.Salutation__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Salutation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Salutation__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Salutation__c) + '])');
                    }
            }
            if ((oOldAccount.Scale__c != oNewAccount.Scale__c) && ((oOpportunity.Billed_Scale__c == oOldAccount.Scale__c) || (oOpportunity.Billed_Scale__c == oNewAccount.Scale__c))){
                    status = true;
                    oOpportunity.Billed_Scale__c = oNewAccount.Scale__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Scale__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Scale__c] to [' + String.valueOf(oNewAccount.Scale__c) + ']');
                } else {
                    if (oOldAccount.Scale__c == oNewAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Scale__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Scale__c != oOldAccount.Scale__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Scale__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Scale__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Scale__c) + '])');
                    }
            }
            if ((oOldAccount.Street_N__c != oNewAccount.Street_N__c) && ((oOpportunity.Billed_Street_N__c == oOldAccount.Street_N__c) || (oOpportunity.Billed_Street_N__c == oNewAccount.Street_N__c))){
                    status = true;
                    oOpportunity.Billed_Street_N__c = oNewAccount.Street_N__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_N__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Street_N__c] to [' + String.valueOf(oNewAccount.Street_N__c) + ']');
                } else {
                    if (oOldAccount.Street_N__c == oNewAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_N__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Street_N__c != oOldAccount.Street_N__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_N__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_N__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Street_N__c) + '])');
                    }
            }
            if ((oOldAccount.Street_name__c != oNewAccount.Street_name__c) && ((oOpportunity.Billed_Street_name__c == oOldAccount.Street_name__c) || (oOpportunity.Billed_Street_name__c == oNewAccount.Street_name__c))){
                    status = true;
                    oOpportunity.Billed_Street_name__c = oNewAccount.Street_name__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Street_name__c] to [' + String.valueOf(oNewAccount.Street_name__c) + ']');
                } else {
                    if (oOldAccount.Street_name__c == oNewAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Street_name__c != oOldAccount.Street_name__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_name__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Street_name__c) + '])');
                    }
            }
            if ((oOldAccount.Street_type__c != oNewAccount.Street_type__c) && ((oOpportunity.Billed_Street_type__c == oOldAccount.Street_type__c) || (oOpportunity.Billed_Street_type__c == oNewAccount.Street_type__c))){
                    status = true;
                    oOpportunity.Billed_Street_type__c = oNewAccount.Street_type__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Street_type__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Street_type__c] to [' + String.valueOf(oNewAccount.Street_type__c) + ']');
                } else {
                    if (oOldAccount.Street_type__c == oNewAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_type__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Street_type__c != oOldAccount.Street_type__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Street_type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Street_type__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Street_type__c) + '])');
                    }
            }
            if ((oOldAccount.Work_Phone_Number__c != oNewAccount.Work_Phone_Number__c) && ((oOpportunity.Billed_Work_Phone_Number__c == oOldAccount.Work_Phone_Number__c) || (oOpportunity.Billed_Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c))){
                    status = true;
                    oOpportunity.Billed_Work_Phone_Number__c = oNewAccount.Work_Phone_Number__c;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Work_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Work_Phone_Number__c] to [' + String.valueOf(oNewAccount.Work_Phone_Number__c) + ']');
                } else {
                    if (oOldAccount.Work_Phone_Number__c == oNewAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Work_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Work_Phone_Number__c != oOldAccount.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Work_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Work_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Work_Phone_Number__c) + '])');
                    }
            }
            if ((oOldAccount.Fax != oNewAccount.Fax) && ((oOpportunity.Billed_Fax__c == oOldAccount.Fax) || (oOpportunity.Billed_Fax__c == oNewAccount.Fax))){
                    status = true;
                    oOpportunity.Billed_Fax__c = oNewAccount.Fax;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Fax__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Fax__c] to [' + String.valueOf(oNewAccount.Fax) + ']');
                } else {
                    if (oOldAccount.Fax == oNewAccount.Fax) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Fax__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Fax__c != oOldAccount.Fax) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Fax__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Fax) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Fax__c) + '])');
                    }
            }
            if ((oOldAccount.Phone != oNewAccount.Phone) && ((oOpportunity.Billed_Phone__c == oOldAccount.Phone) || (oOpportunity.Billed_Phone__c == oNewAccount.Phone))){
                    status = true;
                    oOpportunity.Billed_Phone__c = oNewAccount.Phone;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Phone__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Phone__c] to [' + String.valueOf(oNewAccount.Phone) + ']');
                } else {
                    if (oOldAccount.Phone == oNewAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Phone__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Phone__c != oOldAccount.Phone) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Phone__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Phone) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Phone__c) + '])');
                    }
            }
            if ((oOldAccount.Name != oNewAccount.Name) && ((oOpportunity.Billed_Name__c == oOldAccount.Name) || (oOpportunity.Billed_Name__c == oNewAccount.Name))){
                    status = true;
                    oOpportunity.Billed_Name__c = oNewAccount.Name;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_Name__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_Name__c] to [' + String.valueOf(oNewAccount.Name) + ']');
                } else {
                    if (oOldAccount.Name == oNewAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Name__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_Name__c != oOldAccount.Name) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_Name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.Name) + '] != synced:[' + String.valueOf(oOpportunity.Billed_Name__c) + '])');
                    }
            }
            if ((oOldAccount.AccountNumber != oNewAccount.AccountNumber) && ((oOpportunity.Billed_AccountNumber__c == oOldAccount.AccountNumber) || (oOpportunity.Billed_AccountNumber__c == oNewAccount.AccountNumber))){
                    status = true;
                    oOpportunity.Billed_AccountNumber__c = oNewAccount.AccountNumber;
                    oOpportunity.T_AccountFieldsToChange__c += '___Billed_AccountNumber__c___';
                    System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Synced field [oOpportunity.Billed_AccountNumber__c] to [' + String.valueOf(oNewAccount.AccountNumber) + ']');
                } else {
                    if (oOldAccount.AccountNumber == oNewAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_AccountNumber__c] :: Field was not changed.');
                    }
                    if (oOpportunity.Billed_AccountNumber__c != oOldAccount.AccountNumber) {
                        System.debug('[AP_SyncOpportunityFromAccount_01.propagateBilled_Fields] Skipped field [oOpportunity.Billed_AccountNumber__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldAccount.AccountNumber) + '] != synced:[' + String.valueOf(oOpportunity.Billed_AccountNumber__c) + '])');
                    }
            }
            // END_AUTO_PROPAGATE_Account_Billed__r
        }
        return status;
    }**/
    
    
}