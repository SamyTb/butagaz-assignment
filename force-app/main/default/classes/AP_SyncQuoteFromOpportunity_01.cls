public class AP_SyncQuoteFromOpportunity_01{
    public static Map<Id, Opportunity> getOpportunitys(List<Quote> lQuotes){
        // Sync the created Quotes with their Opportunities
        Set<Id> sOpportunityIds = new Set<Id>();
        for (Quote oQuote : lQuotes){
            sOpportunityIds.add(oQuote.OpportunityId);
                System.debug('[AP_SyncQuoteFromOpportunity_01.getOpportunitys] Adding ID from [oQuote.OpportunityId( ' + Quote.Id + ')] : [' +oQuote.OpportunityId + ']');         
        }

        System.debug('[AP_SyncQuoteFromOpportunity_01.getOpportunitys] Ids of Queried Objects: [' + sOpportunityIds + ']');

        return new Map<Id, Opportunity>([
            SELECT
                Id,
                // BEGIN_AUTO_OPPORTUNITY_FIELDS
                DO_Price_Group__c, //barème redevance du compte
                //DO_Scale__c,
                DO_Payment_Time_Code__c,
                DO_Payment_method__c, // mode de paiment du compte
                DO_Invoicing_Frequency__c,
                Existing_PTL__c,
                Existing_PTL__r.VAT_Code__c,
                Existing_PTL__r.Shipping_Condition__c,
                Existing_PTL__r.Scale__c,
                Existing_PTL__r.Account_Groupement__c,
                Contrat__c,
                Contrat__r.Condition_for_Payment_Package_Code__c // condition de paiement du contrat
                    
                // END_AUTO_Account_FIELDS
            FROM  Opportunity
            WHERE Id IN :sOpportunityIds 
        ]);
    }

    public static void syncQuoteFromOpportunity(Map<Id, Quote> mQuotesBeforeUpdate, Map<Id, Quote> mQuotesAfterUpdate){
        // If we change an Opportunity to the Quote, its fields should be synced
        // with the Actual Opportunitys themselves.

        Map<Id, Opportunity> mOpportunitys = AP_SyncQuoteFromOpportunity_01.getOpportunitys(mQuotesAfterUpdate.values());

        for (Quote oQuote : mQuotesAfterUpdate.values()){
            if (mQuotesBeforeUpdate.get(oQuote.Id).OpportunityId != oQuote.OpportunityId){
                    AP_SyncQuoteFromOpportunity_01.syncFields(oQuote, mOpportunitys);
            }        
        }
    }

    public static void syncQuoteFromOpportunity(List<Quote> lQuotes){
        // When we create a Quote, we should add some fields form the Opportunity to
        // the Opportunity Fields on the Quote.
        Map<Id, Opportunity> mOpportunitys = AP_SyncQuoteFromOpportunity_01.getOpportunitys(lQuotes);
        System.debug('[AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity]: lQuotes:' + lQuotes);
        System.debug('[AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity]: SIZE(lQuotes):' + lQuotes.size());
        System.debug('[AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity]: mOpportunitys:' + mOpportunitys);
        System.debug('[AP_SyncQuoteFromOpportunity_01.syncQuoteFromOpportunity]: SIZE(mOpportunitys):' + mOpportunitys.keySet().size());

        for (Quote oQuote : lQuotes){
            AP_SyncQuoteFromOpportunity_01.syncFields(oQuote, mOpportunitys);
        }
    }

    public static void syncFields(Quote oQuote, Map<Id, Opportunity> mOpportunitys){
        System.debug('SYNC FIELD');
        System.debug('oQuote.OpportunityId'+oQuote.OpportunityId);
        System.debug('Opty'+mOpportunitys.values().get(0));
        Opportunity oOpty = [SELECT Project_Type__c FROM Opportunity WHERE Id = :oQuote.OpportunityId LIMIT 1];
        String projectType = (oOpty != null) ? oOpty.Project_Type__c : null;
        System.debug('projectType '+ projectType );
        if (oQuote.OpportunityId != null && projectType  != null && projectType .equals('FIDE')){
            System.debug('SYNC OPTY FIELD');
            Opportunity oOpportunity = mOpportunitys.get(oQuote.OpportunityId); // This can't be null. If the Opportunity is not null then it's an Opportunity AND we queried it!
            // BEGIN_AUTO_SYNC_Opportunity
            oQuote.Facturation_calendar__c = oOpportunity.DO_Invoicing_Frequency__c;
            System.debug('Facturation calendar'+ oQuote.Facturation_calendar__c);
            oQuote.DO_Payment_method__c = oOpportunity.DO_Payment_method__c;
            System.debug('DO_Payment_method__c'+ oOpportunity.DO_Payment_method__c);
            //oQuote.scale__c = oOpportunity.DO_Scale__c;
            oQuote.scale__c = oOpportunity.DO_Price_Group__c;
            if(oOpportunity.Existing_PTL__c != null){
                System.debug('SYNC PTL FIELD');
                oQuote.VAT_Code__c = oOpportunity.Existing_PTL__r.VAT_Code__c;
                System.debug('VAT_Code__c'+oOpportunity.Existing_PTL__r.VAT_Code__c);
                
                oQuote.Shipping_Condition__c = oOpportunity.Existing_PTL__r.Shipping_Condition__c;
                System.debug('Shipping_Condition__c'+oOpportunity.Existing_PTL__r.Shipping_Condition__c);
                
                oQuote.Product_Scale__c = oOpportunity.Existing_PTL__r.Scale__c;
                System.debug('Product_Scale__c'+oOpportunity.Existing_PTL__r.Scale__c);
                oQuote.DO_Groupement__c = oOpportunity.Existing_PTL__r.Account_Groupement__c;
                System.debug('DO_Groupement__c'+oOpportunity.Existing_PTL__r.Account_Groupement__c);
            } 
            if(oOpportunity.Contrat__c != null && oOpportunity.Contrat__r.Condition_for_Payment_Package_Code__c != null){
                System.debug('SYNC CONTRACT FIEDS');
                oQuote.Payment_spread__c = oOpportunity.Contrat__r.Condition_for_Payment_Package_Code__c;
                System.debug('Payment_spread__c on Contract'+oOpportunity.Contrat__r.Condition_for_Payment_Package_Code__c);
            }else{
                oQuote.Payment_spread__c = oOpportunity.DO_Payment_Time_Code__c;
                System.debug('Payment_spread__c on DO'+oOpportunity.DO_Payment_Time_Code__c);
            }  
            // END_AUTO_SYNC_Opportunity
        }
    }
}