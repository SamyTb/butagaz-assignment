public class AP_Latitude_Aggregations_01{
    public class LatitudeAggregation{
        // Aggregate fields from a list onto another object (with conditions)
        private String sourceField;  // Aggregate this field
        private String targetField;  // Store the aggregation in this field
        private String controlField; // Aggregate only if this field equals 1 (Condition Formula!)

        public LatitudeAggregation(String sourceField, String targetField, String controlField){
            // Store the input
            this.sourceField = sourceField;
            this.targetField = targetField;
            this.controlField = controlField;
        }

        public LatitudeAggregation(String sourceField, String targetField){
            this(sourceField, targetField, null);
        }

        public String getTargetField(){ return this.targetField; }

        public String getSourceField(){ return this.sourceField; }

        public String getControlField(){ return this.controlField; }

        public Boolean hasControlField(){ return this.controlField != null; }

        public void process(SObject targetObject, List<SObject> sourceObjects){
            this.store(targetObject, this.aggregate(sourceObjects));
        }

        private Decimal aggregate(List<SObject> sourceObjects){
            // Process a list of SObjects and return the aggregated result
            System.debug('[LatitudeAggregator.aggregate] Aggregating: [' + this.sourceField + ']');
            System.debug('[LatitudeAggregator.aggregate] Controlled By: [' + this.controlField + ']');
            Decimal result = 0;
            for (SObject oSObject : sourceObjects){
                if ( (this.controlField == null) || ((Decimal) oSObject.get(controlField) == 1) ){
                    if (oSObject.get(this.sourceField) != null){
                        // Only aggregate if the field is not blank, assume 0 otherwise.
                        result += (Decimal) oSObject.get(this.sourceField);
                    }
                }
            }
            return result;
        }

        private void store(SObject targetObject, Decimal aggregate){
            // Record the aggregate
            targetObject.put(this.targetField, aggregate);
        }
    }
    
    public class LatitudeAggregator {
        List<LatitudeAggregation> lAggregations;
        String masterObject;
        String detailObject;
        String lookupField; // The lookup field on the detail object to the master object

        public LatitudeAggregator(
                String masterObject, String detailObject, String lookupField, 
                List<LatitudeAggregation> lAggregations
        ){
            this.masterObject = masterObject;
            this.detailObject = detailObject;
            this.lookupField = lookupField;
            this.lAggregations = lAggregations;
        }
        
        private Set<String> getDetailFields() {
            // We need the aggregated fields, the control fields from the Detail Objects.
            // We also need the lookup field to associate a Detail and a Master
            // We also take the IDs to make sure using Sets would work
            Set<String> detailFields = new Set<String>();
            for (LatitudeAggregation oAggregation : lAggregations){
                detailFields.add(oAggregation.getSourceField());
                if (oAggregation.hasControlField()){
                    detailFields.add(oAggregation.getControlField());
                }
            }
            detailFields.add('Id');
            detailFields.add(this.lookupField);
            return detailFields;
        }

        private Set<String> getMasterFields() {
            // We need the "Bucket fields" and the IDs from the Master Objects.
            // We also need the IDs, as we will be updating the these.
            Set<String> masterFields = new Set<String>();
            for (LatitudeAggregation oAggregation : lAggregations){
                masterFields.add((String) oAggregation.getTargetField());
            }
            masterFields.add('Id');
            return masterFields;
        }

        private List<SObject> getMasterObjects(List<SObject> lDetailObjects){
            // Query the Master objects associated to this list of details
            Set<Id> masterIds = new Set<Id>();
            for (SObject oDetailObject : lDetailObjects){
                masterIds.add((Id) oDetailObject.get(this.lookupField));  // Adapt when we change!
            }

            List<AP_Query_01.QuerySetClause> queryClauses = new List<AP_Query_01.QuerySetClause>{
                new AP_Query_01.QuerySetInClause('Id', masterIds)
            };
            return new AP_Query_01.QuerySet(this.masterObject, this.getMasterFields(), queryClauses).getRecords();
        }

        private Set<Id> getIds(List<SObject> lSObjects){
            Set<Id> sIds = new Set<Id>();
            for (SObject oSObject : lSObjects){
                sIds.add(oSObject.Id);
            }
            return sIds;
        }

        private List<SObject> getExtraDetailObjects(List<SObject> lMasterObjects, List<SObject> lCurrentDetailObjects){
            // When using a Trigger, you might not get all the records, so you should query the extra ones
            Set<Id> sMasterIds = this.getIds(lMasterObjects);
            Set<Id> sCurrentDetailIds = this.getIds(lCurrentDetailObjects);

            List<AP_Query_01.QuerySetClause> queryClauses = new List<AP_Query_01.QuerySetClause>{
                new AP_Query_01.QuerySetInClause(this.lookupField, sMasterIds),
                new AP_Query_01.QuerySetNotClause(new AP_Query_01.QuerySetInClause('Id', sCurrentDetailIds))
            };

            return new AP_Query_01.QuerySet(this.detailObject, this.getDetailFields(), queryClauses).getRecords();
        }

        public List<SObject> aggregate(List<SObject> lCurrentDetailObjects){
            // Do the actual aggregation, calling the utility methods defined above
            List<SObject> lMasterObjects = this.getMasterObjects(lCurrentDetailObjects);
            List<SObject> lAllDetailObjects = new List<SObject>();
            lAllDetailObjects.addAll(lCurrentDetailObjects);
            lAllDetailObjects.addAll(this.getExtraDetailObjects(lMasterObjects, lCurrentDetailObjects));

            // Construct an association: ParentId -> ListOfDetails
            Map<Id, List<SObject>> mAssociations = new Map<Id, List<SObject>>();
            for (SObject oDetailObject : lAllDetailObjects){
                if (!mAssociations.containsKey((Id) oDetailObject.get(this.lookupField))){
                    mAssociations.put((Id) oDetailObject.get(this.lookupField), new List<SObject>());
                }
                mAssociations.get((Id) oDetailObject.get(this.lookupField)).add(oDetailObject); 
            }

            // Now, do the actual aggregations.
            // Due to the construction we're using, we will be ignoring details that are associated to a 
            // master we couldn't find. However, that would mean that the Master doesn't exist.
            // This is practical to implement, useful in case the relationship is not required, and works as 
            // expected if it is.

            // We're sure to get a List when we do "mAssociations.get(oMasterObject.Id)", because if don't get
            // a list, that means that we have a master object with no related records. But given that we looked
            // up the masters from the detail, that can't happen.
            for (SObject oMasterObject : lMasterObjects){
                for (LatitudeAggregation oAggregation : this.lAggregations){
                    oAggregation.process(oMasterObject, mAssociations.get(oMasterObject.Id));
                }
            }
            
            return lMasterObjects;
        }
    }

    public static List<Quote_PTL__c> aggregate_QLIToPTL(List<QuoteLineItem> lQLI, List<LatitudeAggregation> lAggregations){
        LatitudeAggregator oAggregator = new LatitudeAggregator('Quote_PTL__c', 'QuoteLineItem', 'Quote_PTL__c', lAggregations);
        return oAggregator.aggregate(lQLI);
    }

    public static void aggregate_QLIToPTL(List<QuoteLineItem> lQLI){
        // This could eventually come from a Custom Setting
        List<LatitudeAggregation> lAggregations = new List<LatitudeAggregation>{
            new LatitudeAggregation('All_RCE_Rebates_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c'),
            new LatitudeAggregation('All_RCE_Rebates_HT__c', 'T_LAT_ALL_ALL_ALL_RCE_HT_REAL__c'),
            new LatitudeAggregation('Cyclical_Rebate_TTC__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRConj_TTC_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Cyclical_Rebate_HT__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRConj_HT_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Commercial_Rebate_TTC__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRCom_TTC_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Commercial_Rebate_HT__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRCom_HT_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Tank_Capacity__c', 
                    'T_LAT_GEC_ALL_ALL_TankSize_REAL__c', 'T_LAT_Is_Tank__c'),
            new LatitudeAggregation('Commercial_Rebate_HT_Old__c', 
                    'T_LAT_GEC_PRO_FIDE_ProductCurrRCom_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('New_Price_HT__c', 
                    'T_LAT_GER_ALL_CREA_TarifProduit_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('New_Price_HT__c', 
                    'T_LAT_GER_PRECI_CREA_EnergySubscrpt_REAL__c', 'T_LAT_Is_EnergyAccessFee__c'),
            new LatitudeAggregation('New_Price_HT__c', 
                    'T_LAT_GER_PRECI_CREA_MeterDeposit_REAL__c', 'T_LAT_Is_Deposit__c'),
            new LatitudeAggregation('New_Price_HT__c', 
                    'T_LAT_GER_PRECI_CREA_MeterInstFee_REAL__c', 'T_LAT_Is_MeterInstFee__c'),
            new LatitudeAggregation('New_Price_HT__c', 
                    'T_LAT_GER_PRECI_CREA_MeterSubscrpt_REAL__c', 'T_LAT_Is_MeterSubscription__c'),
            new LatitudeAggregation('T_LAT_ALL_ALL_ALL_NewRCom__c', 
                    'T_LAT_GER_PRECI_FIDE_AddedRComSubsc_REAL__c', 'T_LAT_Is_MeterSubscription__c'),
            new LatitudeAggregation('RCE_Rebate_HT__c', 
                    'T_LAT_GER_PRECI_FIDE_RCEUsagers_REAL__c', 'T_LAT_Is_ProductConsumption__c'),
            new LatitudeAggregation('All_Rebates_HT__c', 
                    'T_LAT_GER_PRECI_FIDE_RemiseAccEnerg_REAL__c', 'T_LAT_Is_EnergyAccessFee__c'),
            new LatitudeAggregation('TotalPrice', 
                    'T_LAT_GER_PRECI_FIDE_NewMeterSubscr_REAL__c', 'T_LAT_Is_ProductConsumption__c'),
           new LatitudeAggregation('T_LAT_GEC_PRO_FIDE_ModifStockage__c', 
                    'T_LAT_GEC_PRO_FIDE_ModifStockage_Rollup__c', 'T_LAT_GEC_PRO_FIDE_ModifStockage__c'),
           new LatitudeAggregation('T_LAT_GEC_PRO_FIDE_SupprRedevance__c', 
                    'T_LAT_GEC_PRO_FIDE_SupprRedevance_Rollup__c', 'T_LAT_GEC_PRO_FIDE_SupprRedevance__c'),
           new LatitudeAggregation('T_LAT_GEC_DOM_FIDE_TankBaremePrice__c', 
                   'T_LAT_GEC_ALL_FIDE_TankBaremPrice_Rollup__c', 'T_LAT_Is_Tank__c'),
           new LatitudeAggregation('T_LAT_GER_PRECI_ALL_LentTank__c', 
                   'T_LAT_GER_PRECI_ALL_LentTank_Rollup__c', 'T_LAT_GER_PRECI_ALL_LentTank__c'),
           new LatitudeAggregation('T_LAT_Is_Retrait__c', 
                   'T_LAT_ALL_ALL_ALL_HasRetrait_Rollup__c', 'T_LAT_Is_Retrait__c') ,
           new LatitudeAggregation('Cyclical_Rebate_Months__c',  'T_LAT_ALL_ALL_ALL_Month_RConj__c')         
             
        };

        update AP_Latitude_Aggregations_01.aggregate_QLIToPTL(lQLI, lAggregations);
    }

    public static List<Quote> aggregate_QLIToQuote(List<QuoteLineItem> lQLI, List<LatitudeAggregation> lAggregations){
        LatitudeAggregator oAggregator = new LatitudeAggregator('Quote', 'QuoteLineItem', 'QuoteId', lAggregations);
        return oAggregator.aggregate(lQLI);
    }

    public static void aggregate_QLIToQuote(List<QuoteLineItem> lQLI){
        List<LatitudeAggregation> lAggregations = new List<LatitudeAggregation>{
            new LatitudeAggregation('RCE_Rebate_TTC__c', 'T_LAT_ALL_ALL_ALL_RCE_TTC_REAL__c'),
            new LatitudeAggregation('RCE_Rebate_HT__c', 'T_LAT_ALL_ALL_ALL_RCE_HT_REAL__c'),
            new LatitudeAggregation('Cyclical_Rebate_TTC__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRConj_TTC_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Cyclical_Rebate_HT__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRConj_HT_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Commercial_Rebate_TTC__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRCom_TTC_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('Commercial_Rebate_HT__c', 
                    'T_LAT_ALL_ALL_ALL_ProductRCom_HT_REAL__c', 'T_LAT_Is_Product__c'),
            new LatitudeAggregation('T_est_PMN_Abonnement__c', 
                    'T_number_PMN_Abonnement__c', 'T_est_PMN_Abonnement__c') ,
            new LatitudeAggregation('Cyclical_Rebate_Months__c',  'T_LAT_ALL_ALL_ALL_Month_RConj__c')                                       
        };
        //bypass validation rules for current User if the user does not already bypass them
        User oUser = [select id, Bypass_Validation_Rules__c from User where id = :UserInfo.getUserId()];
       
        if(oUser.Bypass_Validation_Rules__c==true){//The user does already bypass the VR                
            update AP_Latitude_Aggregations_01.aggregate_QLIToQuote(lQLI, lAggregations);
        }
        else {
           //set the user Bypass_Validation_Rules__c to true
            oUser.Bypass_Validation_Rules__c = true;
            update oUser;
        
            update AP_Latitude_Aggregations_01.aggregate_QLIToQuote(lQLI, lAggregations);
            
            //reset the user Bypass_Validation_Rules__c to false
            oUser.Bypass_Validation_Rules__c = false;
            update oUser;
      
        }       

    }
    
     public static List<Quote> aggregate_PTLToQuote(List<Quote_PTL__c> lPTL, List<LatitudeAggregation> lAggregations){
        LatitudeAggregator oAggregator = new LatitudeAggregator('Quote', 'Quote_PTL__c', 'Quote__c', lAggregations);
        return oAggregator.aggregate(lPTL);
    }
    
     public static void aggregate_PTLToQuote(List<Quote_PTL__c> lPTL){
        List<LatitudeAggregation> lAggregations = new List<LatitudeAggregation>{
            new LatitudeAggregation('T_Rollup_condition_Carbu__c', 'T_Rollup_QPTL_Carbu__c')
        };

        //update AP_Latitude_Aggregations_01.aggregate_PTLToQuote(lPTL, lAggregations);
    }
}