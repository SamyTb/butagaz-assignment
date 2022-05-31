public class AP_PricingUtilities{
    /** Class Wrapping all Static methods used for Pricing **/
    
    private final static String TANK_PLACING_CODE_RETRAIT = 'RDS';
    
    //Check if the currentUser is the owner of the Quote (the one who create it)
    public static Boolean isQuoteOwner(Id ownerId){
        Id currentUserId = UserInfo.getUserId();// String ID of the currentUser
        System.debug('Id currentUserId' + currentUserId);
        System.debug('Id ownerId' + ownerId);
        return (ownerId == currentUserId);
    }
    
    public static Boolean getQuoteIsNotPack(Quote oQuote){
        return !(oQuote.Scale__c != null && oQuote.Scale__c.equals('P') && oQuote.Product_Scale__c != null &&
                    (oQuote.Product_Scale__c.equals('V1LIB') ||
                     oQuote.Product_Scale__c.equals('V1PK') ||
                     oQuote.Product_Scale__c.equals('V1PRP1') ||
                     oQuote.Product_Scale__c.equals('V1PRP2') ||
                     oQuote.Product_Scale__c.equals('V1GRP1') ||
                     oQuote.Product_Scale__c.equals('V1GRP2'))
                   );
    }
    
    public static Boolean getQuoteProductScalePack(Quote oQuote){
        return !(oQuote.Product_Scale__c != null &&
                    (oQuote.Product_Scale__c.equals('V1LIB') ||
                     oQuote.Product_Scale__c.equals('V1PK') ||
                     oQuote.Product_Scale__c.equals('V1PRP1') ||
                     oQuote.Product_Scale__c.equals('V1PRP2') ||
                     oQuote.Product_Scale__c.equals('V1GRP1') ||
                     oQuote.Product_Scale__c.equals('V1GRP2'))
                   );
    }
    
    /** Getting Custom Settings methods **/
    public static String getQuoteRecordTypeValue(String name){
        try{
            String res = RecordTypes_OpportunityToQuote__c.getInstance(name).QuoteRecordType__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
                throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'You specify a value for the CS named (' + name +').'});
            }            
        }catch(System.NullPointerException e){
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the RecordTypes_OpportunityToQuote named (' + name +'). [ '+ e.getMessage() + ' ]'});
        }
    }
    
     /** Getting Custom Settings methods **/
    public static String getOpportunityRecordTypeValue(String name){
        try{
            String res = RecordTypes_OpportunityToQuote__c.getInstance(name).OpportunityRecordType__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
                throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'You specify a value for the CS named (' + name +').'});
            }            
        }catch(System.NullPointerException e){
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the RecordTypes_OpportunityToQuote named (' + name +'). [ '+ e.getMessage() + ' ]'});
        }
    }
    
    public static String getCustomSettingValue(String name){
        try{
            String res = Custom_Settings__c.getInstance(name).value__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
                throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'You specify a value for the CS named (' + name +').'});
            }       
        }catch(System.NullPointerException e){
            throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the Custom Setting of named (' + name +'). [ '+ e.getMessage() + ' ]'});
        }
    }
    
    /** Display methods **/
    public static void showApexErrors(AP_CRMException e){
        for(String s : e.getMessages()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s, ''));
        }
    }
    
    /** Converting methods **/
    public static String convertDateToString(Date d){
        String s = null;
        if(d != null){
             s = AP_PricingUtilities.integerToPaddedString(d.year(), 4) + '-' +
                 + AP_PricingUtilities.integerToPaddedString(d.month(), 2) + '-' +
                 + AP_PricingUtilities.integerToPaddedString(d.day(), 2);       
        }
        return s;
    }

    public static String integerToPaddedString(Integer i, Integer minSize) {
        String s = String.valueOf(i);
        while (s.length() < minSize) {
            s = '0' + s;
        }
        return s;
    }
    
    public static String convertDecimalToString(Decimal d){
        if(d != null){
            return String.valueOf(d);
        }
        return null;
    }

    // purpose : (Carburation, Heating, Hot water, Cooking, Process) (multi picklist)
    public static String convertPurposesToFuelFlag(String purpose){
        System.debug('purpose :'+ purpose);
        if(purpose != null){
            if(purpose.contains('Caburation'))
                return 'X';  
        }    
        return '';
    }
    
    /** Getting capacities Quote_PTL methods **/
    public static Boolean isTank(QuoteLineItem QLI){
        System.debug('*****PB'+QLI.PricebookEntry);
        System.debug('*****PB.P2'+QLI.PricebookEntry.Product2);
        return (QLI.PricebookEntry.Product2.Family.toLowerCase().equals('equipement') && 
                QLI.PricebookEntry.Product2.Sub_Type__c.toLowerCase().equals('citerne'));
    }
    
     public static Boolean isQliRetrait(QuoteLineItem qli){
        return qli.Tank_Placing_Options__c == TANK_PLACING_CODE_RETRAIT ;
    }
    
   /*
     * Return a Map with all the Capacities by PTL
     */
    public static Map<String, Decimal> mapQuotePTLToCapacity(List< List<QuoteLineItem> > quoteLineItemsPacket){
        
        Map<String, Decimal> mapPTLsToCapacity = new Map<String, Decimal>();
        
        for(List<QuoteLineItem> quoteLineItemsList : quoteLineItemsPacket){
            
            for(QuoteLineItem lineItem: quoteLineItemsList){
                
                if(isTank(lineItem)&& lineItem.Quote_PTL__r != null){
                //If the current line is a Tank not in "Retrait" and have an attached PTL.
                    
                    Decimal lineCapacity = lineItem.PricebookEntry.Product2.Capacity__c;
                    
                    Decimal oldPtlCapacity = mapPTLsToCapacity.get(lineItem.Quote_PTL__r.Name);
                    Decimal oldPtlAllCapacity = mapPTLsToCapacity.get(lineItem.Quote_PTL__r.Name+'_all');      
                    
                    Decimal newPtlCapacity = oldPtlCapacity != null ? oldPtlCapacity + lineCapacity : lineCapacity;
                    Decimal newPtlAllCapacity = oldPtlAllCapacity != null ? oldPtlAllCapacity + lineCapacity : lineCapacity;
                    
                    //mapPTLsToCapacity.put(lineItem.Quote_PTL__r.Name+'_all', newPtlAllCapacity );
                    
                    if(!isQliRetrait(lineItem)){
                        mapPTLsToCapacity.put(lineItem.Quote_PTL__r.Name, newPtlCapacity);
                    }
                    
                    System.debug('mapPTLsToCapacity ==>  ' + mapPTLsToCapacity.get(lineItem.Quote_PTL__r.Name) + ' FOR ' + lineItem.Quote_PTL__r.Name);
                }
            }
        }    
        return mapPTLsToCapacity;
    }
    
    public static Decimal getTotalQuotePTLsCapacity(Map<String, Decimal> map_x){
        System.debug('MAP: '+map_x);
        Decimal totalCapacity = 0;
        if(map_x != null){
            List<Decimal> quotePTLsCapacity = map_x.values();
            System.debug('values: '+quotePTLsCapacity);
            if(!quotePTLsCapacity.isEmpty()){
                for(Decimal v : quotePTLsCapacity){
                    System.debug('value: '+v);
                    totalCapacity += v;
                }    
            }
        }    
        return totalCapacity;
    }
    
   public static Decimal getQuotePTLCapacity(Map<String, Decimal> map_x, String quotePTLName){
        if(quotePTLName != null){
            Decimal quotePTLCapacity = map_x.get(quotePTLName);
            if(quotePTLCapacity != null){
                return quotePTLCapacity;
            }
        }
        return 0;
    }
    
    public static Boolean isRCE(String rebateType){
        return rebateType.containsIgnoreCase('RCE_Rebate'); // Possible RCE rebate : RCE_Rebate_TTC__c, RCE_Rebate_HT__c 
    }
    
    public static Boolean isRCOM(String rebateType){
        return rebateType.containsIgnoreCase('Commercial_Rebate'); // Possible RCOM rebate : Commercial_Rebate_HT__c, Commercial_Rebate_HT__c, [Group_Commercial_Rebate_HT__c, Group_Commercial_Rebate_TTC__c -> DISABLE FOR ALL]
    }
    
    public static Boolean isRCONJ(String rebateType){
        return rebateType.containsIgnoreCase('Cyclical_Rebate'); // Possible RCONJ rebate : Group_Cyclical_Rebate_HT__c, [Group_Cyclical_Rebate_TTC__c , Cyclical_Rebate_HT__c, Cyclical_Rebate_TTC__c --> DISABLE FOR ALL]
    }
    
}