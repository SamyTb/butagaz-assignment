public class AP_SyncQuote_PTL_cFromPTL_c_01 {
    public static Map<Id, PTL__c> getPTL_cs(List<Quote_PTL__c> lQuote_PTL_cs){
        // Sync the created Quote_PTL__cs with their PTL__cs
        Set<Id> sPTL_cIds = new Set<Id>();
        for (Quote_PTL__c oQuote_PTL_c : lQuote_PTL_cs){
            sPTL_cIds.add(oQuote_PTL_c.T_PTL_Id__c);
                System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.getPTL_cs] Adding ID from [oQuote_PTL_c.T_PTL_Id__c( ' + oQuote_PTL_c.Id + ')] : [' + oQuote_PTL_c.T_PTL_Id__c + ']');
            
        }

        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.getPTL_cs] Ids of Queried Objects: [' + sPTL_cIds + ']');

        return new Map<Id, PTL__c>([
            SELECT
                Id
                // BEGIN_AUTO_PTL__c_FIELDS
                //Shipping_Condition__c,
                //Scale__c,
                //Purposes__c
                //VAT_code__c
                // END_AUTO_PTL__c_FIELDS
            FROM  PTL__c
            WHERE Id IN :sPTL_cIds
        ]);
    }

    public static void syncQuote_PTL_cFromPTL_c(Map<Id, Quote_PTL__c> mQuote_PTL_csBeforeUpdate, Map<Id, Quote_PTL__c> mQuote_PTL_csAfterUpdate){
        // If we change an PTL__c (DO, Payer of Billed) to the Quote_PTL__c, its fields should be synced
        // with the Actual PTL__cs themselves.

        Map<Id, PTL__c> mPTL_cs = AP_SyncQuote_PTL_cFromPTL_c_01.getPTL_cs(mQuote_PTL_csAfterUpdate.values());

        for (Quote_PTL__c oQuote_PTL_c : mQuote_PTL_csAfterUpdate.values()){
            if (mQuote_PTL_csBeforeUpdate.get(oQuote_PTL_c.Id).T_PTL_Id__c != oQuote_PTL_c.T_PTL_Id__c){
                    AP_SyncQuote_PTL_cFromPTL_c_01.syncRPTL_Fields(oQuote_PTL_c, mPTL_cs);
                }
            
        }
    }

    public static void syncQuote_PTL_cFromPTL_c(List<Quote_PTL__c> lQuote_PTL_cs){
        // When we create an Quote_PTL__c, we should add the fields form the PTL__cs (DO, Payer, Billed) to
        // the PTL__c Fields on the Quote_PTL__c.
        Map<Id, PTL__c> mPTL_cs = AP_SyncQuote_PTL_cFromPTL_c_01.getPTL_cs(lQuote_PTL_cs);
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c]: lQuote_PTL_cs:' + lQuote_PTL_cs);
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c]: SIZE(lQuote_PTL_cs):' + lQuote_PTL_cs.size());
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c]: mPTL_cs:' + mPTL_cs);
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.syncQuote_PTL_cFromPTL_c]: SIZE(mPTL_cs):' + mPTL_cs.keySet().size());

        for (Quote_PTL__c oQuote_PTL_c : lQuote_PTL_cs){
            AP_SyncQuote_PTL_cFromPTL_c_01.syncRPTL_Fields(oQuote_PTL_c, mPTL_cs);
            
        }
    }

    public static void syncRPTL_Fields(Quote_PTL__c oQuote_PTL_c, Map<Id, PTL__c> mPTL_cs){
        if (oQuote_PTL_c.T_PTL_Id__c != null){
            PTL__c oPTL_c = mPTL_cs.get(oQuote_PTL_c.T_PTL_Id__c); // This can't be null. If the PTL__c is not null then it's an PTL__c AND we queried it!
            // BEGIN_AUTO_SYNC_Opportunity_PTL__r.PTL__r
            //oQuote_PTL_c.RPTL_Purposes__c = oPTL_c.Purposes__c;
            //oQuote_PTL_c.RPTL_Scale__c = oPTL_c.Scale__c;
            //oQuote_PTL_c.RPTL_Shipping_Condition__c = oPTL_c.Shipping_Condition__c;
            //oQuote_PTL_c.RPTL_VAT_code__c = oPTL_c.VAT_code__c;
            // END_AUTO_SYNC_Opportunity_PTL__r.PTL__r
        }
    }
    

    public static void syncQuote_PTL_cFromQuote_PTL_c(Map<Id, Quote_PTL__c> mOldQuote_PTL_cs, Map<Id, Quote_PTL__c> mNewQuote_PTL_cs){
        Quote_PTL__c oOldQuote_PTL_c; // loop variable.
        for (Quote_PTL__c oNewQuote_PTL_c : mNewQuote_PTL_cs.values()){
            oOldQuote_PTL_c = mOldQuote_PTL_cs.get(oNewQuote_PTL_c.Id); // The API guarantees this key will be there.
            oNewQuote_PTL_c.T_PTL_cFieldsToChange__c = '___';
            
        }
    }

    public static void propagatePTL_cToQuote_PTL_c(Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        // Propagate changes to the PTL__c to the Quote_PTL__cs.
        List<Quote_PTL__c> lQuote_PTL_cs = [
            SELECT
                Id,
                T_PTL_Id__c
               // T_PTL_Id__c,
                // BEGIN_AUTO_Quote_PTL__c_FIELDS
                //RPTL_VAT_code__c,
                //RPTL_Scale__c,
                //RPTL_Shipping_Condition__c,
                //RPTL_Purposes__c
                // END_AUTO_Quote_PTL__c_FIELDS
            FROM Quote_PTL__c
            WHERE
                T_PTL_Id__c in :mNewPTL_cs.keySet()
                
        ];

        List<Quote_PTL__c> lUpdateQuote_PTL_cs = new List<Quote_PTL__c>();

        Boolean needsUpdate; // Loop variable.
        for (Quote_PTL__c oQuote_PTL_c : lQuote_PTL_cs){
            needsUpdate = false;
            // Do not use OR to block the first update from short-circuiting the others.
                if (AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields(oQuote_PTL_c, mOldPTL_cs, mNewPTL_cs)){
                    needsUpdate = true;
                }
            
            if (needsUpdate) {
                lUpdateQuote_PTL_cs.add(oQuote_PTL_c);
            }
        }
        update lUpdateQuote_PTL_cs;
    }

    public static Boolean propagateRPTL_Fields(Quote_PTL__c oQuote_PTL_c, Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        PTL__c oOldPTL_c = mOldPTL_cs.get(oQuote_PTL_c.T_PTL_Id__c);
        PTL__c oNewPTL_c = mNewPTL_cs.get(oQuote_PTL_c.T_PTL_Id__c);
        Boolean status    = false;
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Starting.');
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] oOldPTL_c:[' + oOldPTL_c + ']');
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] oNewPTL_c:[' + oNewPTL_c + ']');
        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] oQuote_PTL_c:[' + oQuote_PTL_c + ']');
        if ((oOldPTL_c != null) && (oNewPTL_c != null)) { // that's equivalent. We're just checking whether the Quote_PTL__c had this specific PTL__c, T_PTL_Id__c lookup updated
            // BEGIN_AUTO_PROPAGATE_Opportunity_PTL__r.PTL__r
            /**if ((oOldPTL_c.Purposes__c != oNewPTL_c.Purposes__c) && ((oQuote_PTL_c.RPTL_Purposes__c == oOldPTL_c.Purposes__c) || (oQuote_PTL_c.RPTL_Purposes__c == oNewPTL_c.Purposes__c))){
                    status = true;
                    oQuote_PTL_c.RPTL_Purposes__c = oNewPTL_c.Purposes__c;
                    oQuote_PTL_c.T_PTL_cFieldsToChange__c += '___RPTL_Purposes__c___';
                    System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Synced field [oQuote_PTL_c.RPTL_Purposes__c] to [' + String.valueOf(oNewPTL_c.Purposes__c) + ']');
                } else {
                    if (oOldPTL_c.Purposes__c == oNewPTL_c.Purposes__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Purposes__c] :: Field was not changed.');
                    }
                    if (oQuote_PTL_c.RPTL_Purposes__c != oOldPTL_c.Purposes__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Purposes__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Purposes__c) + '] != synced:[' + String.valueOf(oQuote_PTL_c.RPTL_Purposes__c) + '])');
                    }
            }
            if ((oOldPTL_c.Scale__c != oNewPTL_c.Scale__c) && ((oQuote_PTL_c.RPTL_Scale__c == oOldPTL_c.Scale__c) || (oQuote_PTL_c.RPTL_Scale__c == oNewPTL_c.Scale__c))){
                    status = true;
                    oQuote_PTL_c.RPTL_Scale__c = oNewPTL_c.Scale__c;
                    oQuote_PTL_c.T_PTL_cFieldsToChange__c += '___RPTL_Scale__c___';
                    System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Synced field [oQuote_PTL_c.RPTL_Scale__c] to [' + String.valueOf(oNewPTL_c.Scale__c) + ']');
                } else {
                    if (oOldPTL_c.Scale__c == oNewPTL_c.Scale__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Scale__c] :: Field was not changed.');
                    }
                    if (oQuote_PTL_c.RPTL_Scale__c != oOldPTL_c.Scale__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Scale__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Scale__c) + '] != synced:[' + String.valueOf(oQuote_PTL_c.RPTL_Scale__c) + '])');
                    }
            }
            if ((oOldPTL_c.Shipping_Condition__c != oNewPTL_c.Shipping_Condition__c) && ((oQuote_PTL_c.RPTL_Shipping_Condition__c == oOldPTL_c.Shipping_Condition__c) || (oQuote_PTL_c.RPTL_Shipping_Condition__c == oNewPTL_c.Shipping_Condition__c))){
                    status = true;
                    oQuote_PTL_c.RPTL_Shipping_Condition__c = oNewPTL_c.Shipping_Condition__c;
                    oQuote_PTL_c.T_PTL_cFieldsToChange__c += '___RPTL_Shipping_Condition__c___';
                    System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Synced field [oQuote_PTL_c.RPTL_Shipping_Condition__c] to [' + String.valueOf(oNewPTL_c.Shipping_Condition__c) + ']');
                } else {
                    if (oOldPTL_c.Shipping_Condition__c == oNewPTL_c.Shipping_Condition__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Shipping_Condition__c] :: Field was not changed.');
                    }
                    if (oQuote_PTL_c.RPTL_Shipping_Condition__c != oOldPTL_c.Shipping_Condition__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_Shipping_Condition__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Shipping_Condition__c) + '] != synced:[' + String.valueOf(oQuote_PTL_c.RPTL_Shipping_Condition__c) + '])');
                    }
            }
            if ((oOldPTL_c.VAT_code__c != oNewPTL_c.VAT_code__c) && ((oQuote_PTL_c.RPTL_VAT_code__c == oOldPTL_c.VAT_code__c) || (oQuote_PTL_c.RPTL_VAT_code__c == oNewPTL_c.VAT_code__c))){
                    status = true;
                    oQuote_PTL_c.RPTL_VAT_code__c = oNewPTL_c.VAT_code__c;
                    oQuote_PTL_c.T_PTL_cFieldsToChange__c += '___RPTL_VAT_code__c___';
                    System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Synced field [oQuote_PTL_c.RPTL_VAT_code__c] to [' + String.valueOf(oNewPTL_c.VAT_code__c) + ']');
                } else {
                    if (oOldPTL_c.VAT_code__c == oNewPTL_c.VAT_code__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_VAT_code__c] :: Field was not changed.');
                    }
                    if (oQuote_PTL_c.RPTL_VAT_code__c != oOldPTL_c.VAT_code__c) {
                        System.debug('[AP_SyncQuote_PTL_cFromPTL_c_01.propagateRPTL_Fields] Skipped field [oQuote_PTL_c.RPTL_VAT_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.VAT_code__c) + '] != synced:[' + String.valueOf(oQuote_PTL_c.RPTL_VAT_code__c) + '])');
                    }
            }**/
            // END_AUTO_PROPAGATE_Opportunity_PTL__r.PTL__r
        }
        return status;
    }
    
}