public class VFC_CloneQuote_01{
    private ApexPages.Standardcontroller stdController;
    private Quote oldQuote;
    private Quote newQuote;
    private User  currentUser;
    private String userBypassTriggers;
    private Boolean userBypassRules;
    private Map<Id, Quote_PTL__c> mQPTLOldToNew;

    public VFC_CloneQuote_01(ApexPages.StandardController stdController){
        this.stdController = stdController;
    }

    /* Clone Quote */

    private String getSOQLQueryForQuote(Quote oQuote){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        
        /***to be tested***/
        Map<String, Schema.SObjectField>    mQuotefields = Schema.SObjectType.Quote.fields.getMap();
        for (String fieldName : mQuotefields.keySet()){
            //exclude formula fields from the SELECT
            if(mQuotefields.get(fieldName).getDescribe().calculated == false){
                fieldNames.add(fieldName);  
            }
        }        
        /***to be tested***/
        
        /*
        for (String fieldName : Schema.SObjectType.Quote.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        */
        SOQLQuery += String.join(fieldNames, ',');
        // ORO 140923 - Beta fields - remove those Addresses from the query
        SOQLQuery = SOQLQuery.replace('shippingaddress,', '');
        SOQLQuery = SOQLQuery.replace('additionaladdress,', '');
        SOQLQuery = SOQLQuery.replace('billingaddress,', '');
        SOQLQuery = SOQLQuery.replace('quotetoaddress,', '');
        // End
        SOQLQuery += ' FROM Quote WHERE Id = \'';
        SOQLQuery += oQuote.Id;
        SOQLQuery += '\'';
        return SOQLQuery;
    }

    private Quote getOldQuote(){
        if (this.oldQuote == null){
            String SOQLQuery = this.getSOQLQueryForQuote((Quote) this.stdController.getRecord());
            this.oldQuote    = Database.query(SOQLQuery);
        }
        return this.oldQuote;
    }

    private void doCloneQuote(){
        // Insert the new Quote.
        
        opportunity o=[select id from opportunity where id=:this.getOldQuote().opportunityId];
        o.SyncedQuoteId=null;
        update o;
        
        
        this.newQuote = this.getOldQuote().clone();
        this.newQuote.T_BypassPTLCopy__c = true;
        this.newQuote.T_LAT_ApprovalRequested__c = false;
        this.newQuote.T_LAT_Approved__c = false;
        this.newQuote.Latitude_Level__c = null;
        this.newQuote.Latitude_Message__c = '';
        this.newQuote.Latitude__c = null;
        this.newQuote.Action_Commerciale__c = null;  // Erwan 20171128 : clear Action_Commerciale__c for we don't know if the new quote will be eligible
        // Erwan 20180405 : clear Signea fields because the clone is not being signed yet
        this.newQuote.Signea_Circuit__c = null;
        this.newQuote.Statut_circuit_de_signature__c = '';
        this.newQuote.Signea_Date_Signature__c = null;
        this.newQuote.Signea_Raison_Refus_Signature__c = '';
        insert this.newQuote;
        // The following is not stricly required. But we're in a VFP,
        // so we don't really mind limits, and let's waste one SOQL query.
        this.newQuote.T_BypassPTLCopy__c = false;
        update this.newQuote;
    }

    /* Clone PTLS */

    private String getSOQLQueryForQPTL(){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.Quote_PTL__c.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        System.debug('List of fields '+ fieldNames);
        SOQLQuery += String.join(fieldNames, ',');
        SOQLQuery += ', ('+getSubQueryForPTLConsumptionProfiles()+')';
        SOQLQuery += ' FROM Quote_PTL__c WHERE Quote__c = \'';
        SOQLQuery += this.getOldQuote().Id;
        SOQLQuery += '\'';
        return SOQLQuery;
    }

     private String getSubQueryForPTLConsumptionProfiles(){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.PTL_Consumption_Profile__c.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        SOQLQuery += String.join(fieldNames, ',');
        SOQLQuery += ' FROM PTL_Consumption_Profiles_del__r';
       
        return SOQLQuery;
    }
    
    private void doCloneQuotePTLs(){
        
        if (this.mQPTLOldToNew == null){
            this.mQPTLOldToNew = new Map<Id, Quote_PTL__c>();

            // Start with PTLs that already exist
            Set<Id> sOptyPTLIds = new Set<Id>();
            List<Quote_PTL__c> newQPTLS = new List<Quote_PTL__c>();
            
            for (Quote_PTL__c oOldQPTL : Database.query(this.getSOQLQueryForQPTL())){
                Quote_PTL__c oNewQPTL = oOldQPTL.clone();
                oNewQPTL.UniqueQuotePTL_Field__c = ''; // Or the validation rule would trigger BEFORE the trigger
                oNewQPTL.Quote__c = this.newQuote.Id;
                this.mQPTLOldToNew.put(oOldQPTL.Id, oNewQPTL);
                sOptyPTLIds.add(oNewQPTL.Opportunity_PTL__c);
            }

            // Add new PTLs that may have been added to the Opportunity since the Quote was locked
            for (Quote_PTL__c oQPTL : AP_CopyOptyPTLsToQuote_01.getOptyPTLsAfterQuoteInsert(new List<Quote>{this.newQuote})){
                if (!sOptyPTLIds.contains(oQPTL.Opportunity_PTL__c)){
                    newQPTLS.add(oQPTL); // No need to add it to the mapping, QLI can't be linked to those!
                }
            }

            // Insert the PTLs.
            newQPTLS.addAll(mQPTLOldToNew.values());
            
            insert newQPTLS;
            
            savePTLConsumptionProfiles(newQPTLS);
        }
    }

    /*
     * Save all the PTL Consumption Profiles by Quote PTLs
     */
    private void savePTLConsumptionProfiles(List<Quote_PTL__c> quotePTLs){
        
        List<PTL_Consumption_Profile__c> PTLConsProfilesToSave = new List<PTL_Consumption_Profile__c>();
        
        for(Quote_PTL__c quotePTL : quotePTLs){
           
           for(PTL_Consumption_Profile__c oldPtlConsProfile:quotePTL.PTL_Consumption_Profiles_del__r){
               PTL_Consumption_Profile__c newPtlConsProfile = oldPtlConsProfile.clone();
               newPtlConsProfile.Quote_PTL_del__c = quotePTL.Id;
               PTLConsProfilesToSave.add(newPtlConsProfile);
           }
        }
        
        insert PTLConsProfilesToSave;
    }
         
    /* Clone Quote Line Items */
    private String getSOQLQueryForQuoteLineItems(){
        String SOQLQuery = 'SELECT ';
        
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.QuoteLineItem.fields.getMap().keySet()){
            fieldNames.add(fieldName);
        }
        SOQLQuery += String.join(fieldNames, ',');
        SOQLQuery += ' FROM QuoteLineItem WHERE QuoteId = \'';
        SOQLQuery += this.getOldQuote().Id;
        SOQLQuery += '\'';
        return SOQLQuery;
    }

    private void doCloneQuoteLineItems(){
        // Clone the Quote Line Items and remap them to the new PTLs
        List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();
        for (QuoteLineItem oOldQLI : Database.query(this.getSOQLQueryForQuoteLineItems())){
            QuoteLineItem oNewQLI = oOldQLI.clone();
            if (oNewQLI.Quote_PTL__c != null){
                oNewQLI.Quote_PTL__c = this.mQPTLOldToNew.get(oNewQLI.Quote_PTL__c).Id;
            }
            oNewQLI.QuoteId = this.newQuote.Id;
            qliToInsert.add(oNewQLI);
        }
        insert qliToInsert;
    }

    public Quote getNewQuote(){
        // Especially for testing.
        return this.newQuote;
    }

    /* Call the clone methods */

    public PageReference CloneQuote(){
        
        try{
            if (this.newQuote == null){
                // Bypass triggers that we want to deactivate
                this.doCloneQuote();
                this.doCloneQuotePTLs();
                this.doCloneQuoteLineItems();
            }
            return new PageReference('/' + this.newQuote.Id);
            
        }catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.addMessages(e);
         }
         
         return null;
    }
    
    /*
     * Action back from Error Page
     */
    public PageReference back(){  
        return new PageReference('/'+ oldQuote.Id);
    }
}