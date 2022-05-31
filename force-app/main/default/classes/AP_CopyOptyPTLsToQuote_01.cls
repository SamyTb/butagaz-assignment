public class AP_CopyOptyPTLsToQuote_01{
    public static integer RECORDS_PER_DML_STATEMENT = 400;
    
    public static void addOptyPTLsInfoBeforeQuoteInsert(List<Quote> lQuotes){
        /* When a new Quote is created, add the Opportunity PTLs */

        // Retrieve the Opportunity IDs to be able to find the Opportunity PTLs we want
        Set<Id> sOptyIds = new Set<Id>();
        for (Quote oQuote : lQuotes){
            if (!oQuote.T_BypassPTLCopy__c){
                sOptyIds.add(oQuote.opportunityId);
            }
        }

        // Retrieve the actual Opportunity PTLs (their ID) to add them to the Quotes
        List<Opportunity_PTL__c> lOptyPTLs = [
            SELECT Id, Opportunity__c, PTL__c, PTL_VAT_Code__c, PTL_Shipping_Condition__c, PTL_Scale__c, PTL_Account_Groupement__c
            FROM Opportunity_PTL__c 
            WHERE Opportunity__c IN :sOptyIds
        ];

        // Make an Opty per Opty list of the PTLs that go with it, so we know which ones we should add
        Map<Id, Set<Opportunity_PTL__c>> mOptiesToPTLs = new Map<Id, Set<Opportunity_PTL__c>>();
        
        for (Opportunity_PTL__c oOptyPTL : lOptyPTLs){
            if (mOptiesToPTLs.get(oOptyPTL.Opportunity__c) == null){
                mOptiesToPTLs.put(oOptyPTL.Opportunity__c, new Set<Opportunity_PTL__c>());
            }
            mOptiesToPTLs.get(oOptyPTL.Opportunity__c).add(oOptyPTL);
        }
        
        // For each Quote, add the PTLs Info that go with its Opportunity
        for (Quote oQuote : lQuotes){
            if (mOptiesToPTLs.containsKey(oQuote.opportunityId)){
                for (Opportunity_PTL__c oOptyPTL : mOptiesToPTLs.get(oQuote.opportunityId)){
                    //Prefill some fields on the Quote thanks to the Opty PTL having a PTL__c (for on Opty we will have one Opty PTL having a master PTL : workflow rule)
                    if(oOptyPTL.PTL__c != null){
                        System.debug('updating Quote');
                        oQuote.Old_VAT_code__c = oOptyPTL.PTL_VAT_Code__c;
                        oQuote.Old_Shipping_Condition__c = oOptyPTL.PTL_Shipping_Condition__c;
                        oQuote.Old_Product_Scale__c = oOptyPTL.PTL_Scale__c;
                       // oQuote.DO_Groupement__c = oOptyPTL.PTL_Account_Groupement__c;
                    }
                }
            }
        }
    }
    
    public static List<Quote_PTL__c> getOptyPTLsAfterQuoteInsert(List<Quote> lQuotes){
        /* When a new Quote is created, add the Opportunity PTLs */

        // Retrieve the Opportunity IDs to be able to find the Opportunity PTLs we want
        Set<Id> sOptyIds = new Set<Id>();
        for (Quote oQuote : lQuotes){
            if (!oQuote.T_BypassPTLCopy__c){
                sOptyIds.add(oQuote.opportunityId);
            }
        }

        // Retrieve the actual Opportunity PTLs (their ID) to add them to the Quotes
        List<Opportunity_PTL__c> lOptyPTLs = [
            SELECT Id, Opportunity__c, PTL__c
            FROM Opportunity_PTL__c 
            WHERE Opportunity__c IN :sOptyIds
        ];

        // Make an Opty per Opty list of the PTLs that go with it, so we know which ones we should add
        Map<Id, Set<Opportunity_PTL__c>> mOptiesToPTLs = new Map<Id, Set<Opportunity_PTL__c>>();
        
        for (Opportunity_PTL__c oOptyPTL : lOptyPTLs){
            if (mOptiesToPTLs.get(oOptyPTL.Opportunity__c) == null){
                mOptiesToPTLs.put(oOptyPTL.Opportunity__c, new Set<Opportunity_PTL__c>());
            }
            mOptiesToPTLs.get(oOptyPTL.Opportunity__c).add(oOptyPTL);
        }

        // Find the Mapping of QuoteRecordTypeID => QuotePTLRecordTypeId 
        Map<Id, Id> quoteRTIdToPTLRTId = new Map<Id, Id>();
        for (RecordTypes_OpportunityToQuote__c oRTAssociation : RecordTypes_OpportunityToQuote__c.getAll().values()){
            quoteRTIdToPTLRTId.put(oRTAssociation.QuoteRecordType__c, oRTAssociation.QuotePTLRecordType__c);
        }

        // For each Quote, add the PTLs that go with its Opportunity
        Quote_PTL__c loopPTL;
        List<Quote_PTL__c> lPTLsToAdd = new List<Quote_PTL__c>();
        for (Quote oQuote : lQuotes){
            if (mOptiesToPTLs.containsKey(oQuote.opportunityId)){
                for (Opportunity_PTL__c oOptyPTL : mOptiesToPTLs.get(oQuote.opportunityId)){
                    loopPTL = new Quote_PTL__c( // Need to add the __r fields to prepare for other triggers
                        Opportunity_PTL__c = oOptyPTL.Id, Opportunity_PTL__r = oOptyPTL,
                        Quote__c = oQuote.Id, Quote__r = oQuote
                    );
                    if (quoteRTIdToPTLRTId.containsKey(oQuote.RecordTypeId)){
                        loopPTL.RecordTypeId = quoteRTIdToPTLRTId.get(oQuote.RecordTypeId);
                    }
                    lPTLsToAdd.add(loopPTL);
                    if (lPTLsToAdd.size() >= AP_CopyOptyPTLsToQuote_01.RECORDS_PER_DML_STATEMENT){
                        insert lPTLsToAdd;
                        lPTLsToAdd.clear();
                    }
                }
            }
        }
        return lPTLsToAdd;
    }

    public static void addOptyPTLsAfterQuoteInsert(List<Quote> lQuotes){
        insert AP_CopyOptyPTLsToQuote_01.getOptyPTLsAfterQuoteInsert(lQuotes);
    }

    public static List<Quote_PTL__c> getOptyPTLsAfterPTLInsert(List<Opportunity_PTL__c> lOptyPTLs){
        /* When a new Opportunity PTL is created, add it to the Quotes for the Opportunity. */

        // Get the Ids of the Opportunities
        Set<Id> sOptyIds = new Set<Id>();
        for (Opportunity_PTL__c oOptyPTL : lOptyPTLs){
            sOptyIds.add(oOptyPTL.Opportunity__c);
        }

        // Query the Quotes
        List<Quote> lQuotes = [
            SELECT Id, OpportunityId, RecordTypeId
            FROM Quote
            WHERE 
                OpportunityId IN :sOptyIds
            AND T_LAT_ApprovalRequested__c = false 
        ]; // Do not edit Quotes whose approval had been required before.

        // Make a List of the Quotes for each Opportunity.
        Map<Id, Set<Quote>> mOptiesToQuotes = new Map<Id, Set<Quote>>();
        
        for (Quote oQuote : lQuotes){
            if (mOptiesToQuotes.get(oQuote.OpportunityId) == null){
                mOptiesToQuotes.put(oQuote.OpportunityId, new Set<Quote>());
            }
            mOptiesToQuotes.get(oQuote.OpportunityId).add(oQuote);
        }

        // Find the Mapping of QuoteRecordTypeID => QuotePTLRecordTypeId 
        Map<Id, Id> quoteRTIdToPTLRTId = new Map<Id, Id>();
        for (RecordTypes_OpportunityToQuote__c oRTAssociation : RecordTypes_OpportunityToQuote__c.getAll().values()){
            quoteRTIdToPTLRTId.put(oRTAssociation.QuoteRecordType__c, oRTAssociation.QuotePTLRecordType__c);
        }

        // For each Opportunity PTL, add a Quote PTL for it.
        Quote_PTL__c loopPTL;
        List<Quote_PTL__c> lPTLsToAdd = new List<Quote_PTL__c>();
        for (Opportunity_PTL__c oOptyPTL : lOptyPTLs){
            if (mOptiesToQuotes.containsKey(oOptyPTL.Opportunity__c)){
                for (Quote oQuote : mOptiesToQuotes.get(oOptyPTL.Opportunity__c)){
                    //Prefill some fields on the Quote thanks to the Opty PTL having a PTL__c (for on Opty we will have one Opty PTL having a master PTL : workflow rule)
                    if(oOptyPTL.PTL__c != null){
                        oQuote.Old_VAT_code__c = oOptyPTL.PTL_VAT_Code__c;
                        oQuote.Old_Shipping_Condition__c = oOptyPTL.PTL_Shipping_Condition__c;
                        oQuote.Old_Product_Scale__c = oOptyPTL.PTL_Scale__c;
                        //oQuote.DO_Groupement__c = oOptyPTL.PTL_Account_Groupement__c;
                    }
                    loopPTL = new Quote_PTL__c( // Need to add the __r fields to prepare for other triggers
                        Opportunity_PTL__c = oOptyPTL.Id, Opportunity_PTL__r = oOptyPTL,
                        Quote__c = oQuote.Id, Quote__r = oQuote
                    );
                    if (quoteRTIdToPTLRTId.containsKey(oQuote.RecordTypeId)){
                        loopPTL.RecordTypeId = quoteRTIdToPTLRTId.get(oQuote.RecordTypeId);
                    }
                    lPTLsToAdd.add(loopPTL);
                    if (lPTLsToAdd.size() >= AP_CopyOptyPTLsToQuote_01.RECORDS_PER_DML_STATEMENT){
                        insert lPTLsToAdd;
                        lPTLsToAdd.clear();
                    }
                    update oQuote;
                }
            }
        }
        return lPTLsToAdd;
    }

    public static void addOptyPTLsAfterPTLInsert(List<Opportunity_PTL__c> lOptyPTLs){
        /* When a new Opportunity PTL is created, add it to the Quotes for the Opportunity. */
        insert AP_CopyOptyPTLsToQuote_01.getOptyPTLsAfterPTLInsert(lOptyPTLs);
    }
}