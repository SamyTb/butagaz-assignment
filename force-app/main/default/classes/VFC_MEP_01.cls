global class VFC_MEP_01{
//public class VFC_MEP_01{
    
    private static Opportunity_PTL__c current;
    
    public Boolean COT{get; set;}  
    public static String isSE{get; set;} // Is the quote being electronically signed ?
    
    
    ApexPages.StandardController stdController;
    
    public VFC_MEP_01(ApexPages.StandardController controller) {
      	this.stdController = controller;
       	current = (Opportunity_PTL__c) stdController.getRecord() ;
        
        System.debug(logginglevel.WARN,'### current =' + current);
        
        System.debug(logginglevel.WARN,'### isSE =' + isSE);
        isSE = ApexPages.CurrentPage().getParameters().get('isSE');
        if(isSE == null){isSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        System.debug(logginglevel.WARN,'### isSE =' + isSE);
        
       	this.calculateCOT();
        
    }
    
    
    public string getPrettyDate() {
        Date today = Date.today();
        return today.format();
    }
   
   
    private void calculateCOT() {
         this.COT= false;
         if(current.Opportunity__r.SyncedQuoteId!= null)
         
         {
          List<QuoteLineItem> quoteLineItems = this.getQuoteLineItems();
             for (QuoteLineItem quoteLineItem : quoteLineItems) {
                 if (quoteLineItem.Mis_Disposition__c=='Customer Owned Tank') { this.COT = true; }
                 }
             }
         }
   
        
        

    
     public List<QuoteLineItem> getQuoteLineItems() {


         List<QuoteLineItem> quotelineitemList;
         
         IF(current.Opportunity__r.SyncedQuoteId <> null){
         
    quotelineitemList =  [
        SELECT 
        Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
        Linenumber,
        pricebookentry.Name,
        CreatedDate,
        New_Price_HT__c,
        CreatedById,
        Tank_Placing_Type__c,
        LastModifiedDate,
        LastModifiedById,
        SystemModstamp,
        QuoteId,
        PricebookEntryId,
        Quantity,
        UnitPrice,
        F_Product_Code__c,
        Discount,
        Description,
        ServiceDate,
        SortOrder,
        ListPrice,
        Got_From_SAP__c,
        F_Quantity_Unit__c,
        Subtotal,
        TotalPrice, 
        Price_List_HT__c,
        Price_List_TTC__c,
        Group_Commercial_Rebate_HT__c,
        Group_Commercial_Rebate_TTC__c,
        Commercial_Rebate_HT__c,
        Commercial_Rebate_TTC__c,
        Group_Cyclical_Rebate_HT__c,
        Group_Cyclical_Rebate_TTC__c,
        
        Cyclical_Rebate_HT__c,
        Cyclical_Rebate_TTC__c,
        RCE_Rebate_HT__c,
        RCE_Rebate_TTC__c,
        Transport_Increase_HT__c,
        Transport_Increase_TTC__c,
        Tank_Capacity__c,
        T_TANK_CAPACITY_NUMBER__c,
        Linked_PTL__c,
        T_PTL_InFormation__c,
        Mis_Disposition__c,
        
        Remise_Grpt_one_shot_HT__c,
        Consignation_Grpt_one_shot_HT__c,
        Cyclical_Rebate_Months__c,
       Quote_PTL__r.Opportunity_PTL__r.Opportunity__r.SyncedQuoteId,
        Usage__c,
        Tax__c,
        Product_Description__c,
        From_Date__c,
        To_Date__c,
        Remise_Exceptional_for_Tank_CN_AB__c,
        Product_Family__c, 
        Quantity_Unit__c,
        Amount_Unit__c,
        Pricing_Unit__c,
        Start_Date_remise_Exc_Subscription__c,
        End_Date_remise_Exc_Subscription__c,
        Quote_PTL__r.Opportunity_PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.Name,
        Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
        
        Quote_PTL__r.Opportunity_PTL__r.CreatedById,
        Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
        Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
        Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
        Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
        Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
        Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c,  Quote_PTL__r.Consumption_From_Excel__c, 
        Quote_PTL__r.Consumptioncurveprofile__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c,  Quote_PTL__r.RPTL_Purposes__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c,  Quote_PTL__r.Consumption_fixed_apr__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name,  Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
        Quote_PTL__r.Consumption_fixed_feb__c,  Quote_PTL__r.Consumption_fixed_jan__c,  Quote_PTL__r.Consumption_fixed_jul__c,  Quote_PTL__r.Consumption_fixed_jun__c,  Quote_PTL__r.Consumption_fixed_mar__c, 
        Quote_PTL__r.Consumption_fixed_may__c,  Quote_PTL__r.Consumption_fixed_nov__c,  Quote_PTL__r.Consumption_fixed_oct__c,  Quote_PTL__r.Consumption_fixed_sep__c,  
        Quote_PTL__r.Consumption_variable_apr__c,  Quote_PTL__r.Consumption_variable_aug__c,  Quote_PTL__r.Consumption_variable_dec__c,  Quote_PTL__r.Consumption_variable_feb__c, 
        Quote_PTL__r.Consumption_variable_jan__c,  Quote_PTL__r.Consumption_variable_jul__c,  Quote_PTL__r.Consumption_variable_jun__c,  Quote_PTL__r.Consumption_variable_mar__c, 
        Quote_PTL__r.Consumption_variable_may__c,  Quote_PTL__r.Consumption_variable_nov__c,  Quote_PTL__r.Consumption_variable_oct__c,  Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
        Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
        Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
        Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
        Customer_Owned_Tank_Name__c,
        Customer_Owned_Tank_ReApprBefore_Date__c,
        Customer_Owned_Tank_Serial_Number__c,
        Customer_Owned_Tank_Appr_Date__c,
        Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
        Cles_en_Main__c,
        Concrete__c,
        Connected_Tank__c,
        Concrete_Tile_Flooring__c,
        Detente_3_Bar__c,
        Drain__c,
        Earliest_Tank_moving_Date__c,
        Enhance_Jauge__c,
        Evacuation_of_Dirt_Rubble__c,
        Flooring_for_Burried_ballast_Tank__c,
        Insdustrial_Outflow__c,
        Intervention__c,
        Land_spreading_10_m__c,
        Latest_Tank_moving_Date_MEP__c,
        Mechanic_type__c,
        MEP_Tank_Placing_Type_Details__c,
        Modification_of_the_Installation_Needed__c,
        Mouvement_a_la_meme_adresse_pour_Butagaz__c,
        Percentage_Jauge_Competitor_Tank__c,
        Precheck_Tank_Connection__c,
        Preparation_trench__c,
        Pre_Visit__c,
        Supplementary_Filling__c,
        System_Cut_off_point_at_liquid_Channel__c,
        Simultaneous_MEP__c,
        TeleJauge__c,
        Three_point_attachement__c,
        MEP_Comments__c,
        Tank_Placing_Options__c,
        
        
        Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c
        
      
        
        
     
       
        

        FROM quotelineitem where QuoteId = :current.Opportunity__r.SyncedQuoteId and Sub_type__c='Citerne' ];
         }
         return quotelineitemList;
         
        
         
         
    
         
         }


public List<QuoteLineItem> getCurrentTankQuoteLineItems() {


         List<QuoteLineItem> quotelineitemList;
         
         IF(current.Opportunity__r.SyncedQuoteId <> null){
         
    quotelineitemList =  [
        SELECT 
        Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_code__c,
        Linenumber,
        pricebookentry.Name,
        CreatedDate,
        New_Price_HT__c,
        CreatedById,
        Tank_Placing_Type__c,
        LastModifiedDate,
        LastModifiedById,
        SystemModstamp,
        QuoteId,
        PricebookEntryId,
        Quantity,
        UnitPrice,
        F_Product_Code__c,
        Discount,
        Description,
        ServiceDate,
        SortOrder,
        ListPrice,
        Got_From_SAP__c,
        F_Quantity_Unit__c,
        Subtotal,
        TotalPrice, 
        Price_List_HT__c,
        Price_List_TTC__c,
        Group_Commercial_Rebate_HT__c,
        Group_Commercial_Rebate_TTC__c,
        Commercial_Rebate_HT__c,
        Commercial_Rebate_TTC__c,
        Group_Cyclical_Rebate_HT__c,
        Group_Cyclical_Rebate_TTC__c,
        
        Cyclical_Rebate_HT__c,
        Cyclical_Rebate_TTC__c,
        RCE_Rebate_HT__c,
        RCE_Rebate_TTC__c,
        Transport_Increase_HT__c,
        Transport_Increase_TTC__c,
        Tank_Capacity__c,
        T_TANK_CAPACITY_NUMBER__c,
        Linked_PTL__c,
        T_PTL_InFormation__c,
        Mis_Disposition__c,
        
        Remise_Grpt_one_shot_HT__c,
        Consignation_Grpt_one_shot_HT__c,
        Cyclical_Rebate_Months__c,
       Quote_PTL__r.Opportunity_PTL__r.Opportunity__r.SyncedQuoteId,
        Usage__c,
        Tax__c,
        Product_Description__c,
        From_Date__c,
        To_Date__c,
        Remise_Exceptional_for_Tank_CN_AB__c,
        Product_Family__c, 
        Quantity_Unit__c,
        Amount_Unit__c,
        Pricing_Unit__c,
        Start_Date_remise_Exc_Subscription__c,
        End_Date_remise_Exc_Subscription__c,
        Quote_PTL__r.Opportunity_PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.Name,
        Quote_PTL__r.Opportunity_PTL__r.CreatedDate,
        
        Quote_PTL__r.Opportunity_PTL__r.CreatedById,
        Quote_PTL__r.Opportunity_PTL__r.LastModifiedDate,  
        Quote_PTL__r.Opportunity_PTL__r.LastModifiedById,
        Quote_PTL__r.Opportunity_PTL__r.SystemModstamp,
        Quote_PTL__r.Opportunity_PTL__r.Opportunity__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Name__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_Number__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.Street_name__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
        Quote_PTL__r.Opportunity_PTL__r.T_PTL_cFieldsToChange__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_ADV_deletion_flag__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Account_Groupement__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Activity_Domain__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Address__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_ADV__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Commands_General__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_ADV__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Blocking_Delivery_General__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_City__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_City_code__c, /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_AC_administrator_value__c,*/ Quote_PTL__r.Opportunity_PTL__r.Code_AC_administrator_New__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE__c,  /*Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NACE_value__c,*/  
        Quote_PTL__r.Opportunity_PTL__r.PTL_Code_NAF__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_branche_value__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Code_division_value__c,  Quote_PTL__r.Consumption_From_Excel__c, 
        Quote_PTL__r.Consumptioncurveprofile__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Country__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Customer_presence__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_Connecting__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Date_at_the_End_of_Dispensation__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Department__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_E_mail__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Estimated_or_Real_Capacity__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_ExternalID__c, Quote_PTL__r.Opportunity_PTL__r.PTL_Fax_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_First_and_Last_Name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gal_deletion_flag__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Gasdeliverymode__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Linked_Quote__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Mandataire__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_Sub_Type__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Market_type__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Number_extention__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Payment_Delay__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Period_Frequency__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Permanent_dispensation__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Phone__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Place_Called__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_Box__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Postal_code__c,  Quote_PTL__r.RPTL_Purposes__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Street_name__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_number__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Street_type__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Temporary_dispensation__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Title__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_VAT_code_sap__c,  Quote_PTL__r.Opportunity_PTL__r.PTL_Value_added_tax_within_the_Community__c, 
        Quote_PTL__r.Opportunity_PTL__r.PTL_Work_Phone_Number__c,  Quote_PTL__r.Consumption_fixed_apr__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.Name,  Quote_PTL__r.Consumption_fixed_aug__c,  Quote_PTL__r.Consumption_fixed_dec__c,
        Quote_PTL__r.Consumption_fixed_feb__c,  Quote_PTL__r.Consumption_fixed_jan__c,  Quote_PTL__r.Consumption_fixed_jul__c,  Quote_PTL__r.Consumption_fixed_jun__c,  Quote_PTL__r.Consumption_fixed_mar__c, 
        Quote_PTL__r.Consumption_fixed_may__c,  Quote_PTL__r.Consumption_fixed_nov__c,  Quote_PTL__r.Consumption_fixed_oct__c,  Quote_PTL__r.Consumption_fixed_sep__c,  
        Quote_PTL__r.Consumption_variable_apr__c,  Quote_PTL__r.Consumption_variable_aug__c,  Quote_PTL__r.Consumption_variable_dec__c,  Quote_PTL__r.Consumption_variable_feb__c, 
        Quote_PTL__r.Consumption_variable_jan__c,  Quote_PTL__r.Consumption_variable_jul__c,  Quote_PTL__r.Consumption_variable_jun__c,  Quote_PTL__r.Consumption_variable_mar__c, 
        Quote_PTL__r.Consumption_variable_may__c,  Quote_PTL__r.Consumption_variable_nov__c,  Quote_PTL__r.Consumption_variable_oct__c,  Quote_PTL__r.Consumption_variable_sep__c, Quote_PTL__r.Opportunity_PTL__r.PTL__r.Name, 
        Quote_PTL__r.Opportunity_PTL__r.Commercial_Accounting_Manager__c,  Quote_PTL__r.Opportunity_PTL__r.AC_value__c,  Quote_PTL__r.Opportunity_PTL__r.Project_Type_PTL__c,  Quote_PTL__r.Opportunity_PTL__r.Fiscal_class_PTL__c,
        Quote_PTL__r.Consumption_fixed_Jan_kWh__c, Quote_PTL__r.Consumption_fixed_Feb_kWh__c,Quote_PTL__r.Consumption_fixed_Mar_kWh__c,Quote_PTL__r.Consumption_fixed_Apr_kWh__c,Quote_PTL__r.Consumption_fixed_May_kWh__c,Quote_PTL__r.Consumption_fixed_Jun_kWh__c,Quote_PTL__r.Consumption_fixed_Jul_kWh__c,
        Quote_PTL__r.Consumption_fixed_Aug_kWh__c,Quote_PTL__r.Consumption_fixed_Sep_kWh__c,Quote_PTL__r.Consumption_fixed_Oct_kWh__c,Quote_PTL__r.Consumption_fixed_Nov_kWh__c,Quote_PTL__r.Consumption_fixed_Dec_kWh__c,Quote_PTL__r.Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,Estimated_Consumption_FROMPTL__c,Customer_Owned_Tank_Capacity__c,
        Customer_Owned_Tank_Name__c,
        Customer_Owned_Tank_ReApprBefore_Date__c,
        Customer_Owned_Tank_Serial_Number__c,
        Customer_Owned_Tank_Appr_Date__c,
        Brand__c,Group_Cyclical_Rebate_lenght_in_months__c,Quote_PTL__r.PTL_Name__c, Quote_PTL__r.PTL_Label__c, Anchoring_Surface_Tank__c,
        Cles_en_Main__c,
        Concrete__c,
        Connected_Tank__c,
        Concrete_Tile_Flooring__c,
        Detente_3_Bar__c,
        Drain__c,
        Earliest_Tank_moving_Date__c,
        Enhance_Jauge__c,
        Evacuation_of_Dirt_Rubble__c,
        Flooring_for_Burried_ballast_Tank__c,
        Insdustrial_Outflow__c,
        Intervention__c,
        Land_spreading_10_m__c,
        Latest_Tank_moving_Date_MEP__c,
        Mechanic_type__c,
        MEP_Tank_Placing_Type_Details__c,
        Modification_of_the_Installation_Needed__c,
        Mouvement_a_la_meme_adresse_pour_Butagaz__c,
        Percentage_Jauge_Competitor_Tank__c,
        Precheck_Tank_Connection__c,
        Preparation_trench__c,
        Pre_Visit__c,
        Supplementary_Filling__c,
        System_Cut_off_point_at_liquid_Channel__c,
        Simultaneous_MEP__c,
        TeleJauge__c,
        Three_point_attachement__c,
        MEP_Comments__c,
        Tank_Placing_Options__c,
        
        
        Quote_PTL__r.Opportunity_PTL__r.PTL_Clayground__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Septic_Tank__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Size_3m__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_With_wall__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
        Quote_PTL__r.Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c
        

        FROM quotelineitem where QuoteId = :current.Opportunity__r.SyncedQuoteId and Sub_type__c='Citerne' and Quote_PTL__r.Opportunity_PTL__r.Id = :current.Id
        and Tank_Placing_Options__c in ('MEP', 'CDP')];
         }
         return quotelineitemList;

         
         }
     
        
    /*
     * Fetch all the Quote PTL related to the current Opportunity PTL
     */     
    public List<Quote_PTL__c> getQUOTEPTLS() {
             
        List<Quote_PTL__c> QuotePTLs = new List<Quote_PTL__c>();
        
        if(current.Opportunity__r.SyncedQuoteId <> null){
        
            QuotePTLs = [select Name,
             
            Opportunity_PTL__r.PTL__r.Account_DO__c,
            Opportunity_PTL__r.PTL__r.Account_Groupement__c,
            Opportunity_PTL__r.PTL__r.Activity_Domain__c,
            Opportunity_PTL__r.PTL__r.Address__c,
            Opportunity_PTL__r.PTL__r.ADV_deletion_flag__c,
            Opportunity_PTL__r.PTL__r.Anniversary_date__c,
            Opportunity_PTL__r.PTL__r.Blocking_Commands_ADV__c,
            Opportunity_PTL__r.PTL__r.Blocking_Commands_General__c,
            Opportunity_PTL__r.PTL__r.Blocking_Delivery_ADV__c,
            Opportunity_PTL__r.PTL__r.Blocking_Delivery_General__c,
            Opportunity_PTL__r.PTL__r.Call_client_before_delivery__c,
            Opportunity_PTL__r.PTL__r.City__c,
            Opportunity_PTL__r.PTL__r.City_code__c,
            Opportunity_PTL__r.PTL__r.City_Postal_Code__r.Name,
            /*Opportunity_PTL__r.PTL__r.Code_AC_administrator__c,
            Opportunity_PTL__r.PTL__r.Code_AC_administrator_value__c,*/
            Opportunity_PTL__r.PTL__r.Code_AC_administrator_New__c,
            Opportunity_PTL__r.PTL__r.Code_branche__c,
            Opportunity_PTL__r.PTL__r.Code_branche_value__c,
            Opportunity_PTL__r.PTL__r.Code_division__c,
            Opportunity_PTL__r.PTL__r.Code_division_value__c,
            Opportunity_PTL__r.PTL__r.Code_NACE__c,
            /*Opportunity_PTL__r.PTL__r.Code_NACE_value__c,*/
            Opportunity_PTL__r.PTL__r.Code_NAF__c,
            Opportunity_PTL__r.PTL__r.Country__c,
            Opportunity_PTL__r.PTL__r.Customer_presence__c,
            Opportunity_PTL__r.PTL__r.Date_at_the_End_of_Dispensation__c,
            Opportunity_PTL__r.PTL__r.Date_Connecting__c,
            Opportunity_PTL__r.PTL__r.Seasonal_Date_of_Period_End__c,
            Opportunity_PTL__r.PTL__r.Seasonal_Date_of_Period_Start__c,
            Opportunity_PTL__r.PTL__r.Days_no_Delivery_possible__c,
            Opportunity_PTL__r.PTL__r.Delivery_possible_in_absence_of_client__c,
            Opportunity_PTL__r.PTL__r.Department__c,
            Opportunity_PTL__r.PTL__r.E_mail__c,
            Opportunity_PTL__r.PTL__r.Estimated_or_Real_Capacity__c,
            Opportunity_PTL__r.PTL__r.Etimated_or_Real_Consumption__c,
            Opportunity_PTL__r.PTL__r.ExternalID__c,
            Opportunity_PTL__r.PTL__r.Fax_Number__c,
            Opportunity_PTL__r.PTL__r.First_and_Last_Name__c,
            Opportunity_PTL__r.PTL__r.Fiscal_class_PTL__c,
            Opportunity_PTL__r.PTL__r.Gal_deletion_flag__c,
            Opportunity_PTL__r.PTL__r.Gasdeliverymode__c,
            Opportunity_PTL__r.PTL__r.Label__c,
            Opportunity_PTL__r.PTL_City__c ,
            Opportunity_PTL__r.PTL_Postal_code__c ,
            Opportunity_PTL__r.PTL__r.Limitation_of_Tonnage__c,
            Opportunity_PTL__r.PTL__r.Limitation_of_Vehicle__c,
            Opportunity_PTL__r.PTL__r.Mandataire__c,
            Opportunity_PTL__r.PTL__r.Mandataire_Name__c,
            Opportunity_PTL__r.PTL__r.Market_Sub_Type__c,
            Opportunity_PTL__r.PTL__r.Market_type__c,
            Opportunity_PTL__r.PTL__r.Mobile_Phone_Number__c,
            Opportunity_PTL__r.PTL__r.Network__c,
            Opportunity_PTL__r.PTL__r.Number_extention__c,
            Opportunity_PTL__r.PTL__r.Opportunity_Number__c,
            Opportunity_PTL__r.PTL__r.Payment_Delay__c,
            Opportunity_PTL__r.PTL__r.PDV_Number__c,
            Opportunity_PTL__r.PTL__r.Period_Frequency__c,
            Opportunity_PTL__r.PTL__r.Periodic_delivery__c,
            Opportunity_PTL__r.PTL__r.Permanent_dispensation__c,
            Opportunity_PTL__r.PTL__r.Phone__c,
            Opportunity_PTL__r.PTL__r.Place_Called__c,
            Opportunity_PTL__r.PTL__r.Postal_Box__c,
            Opportunity_PTL__r.PTL__r.Postal_code__c,
            Opportunity_PTL__r.PTL__r.Precheck_Truck_needed__c,
            Opportunity_PTL__r.PTL__r.Purposes__c,
            Opportunity_PTL__r.PTL__r.Restriction_of_the_vehicule__c,
            Opportunity_PTL__r.PTL__r.SAP_City_Code__c,
            Opportunity_PTL__r.PTL__r.SAP_City_Name__c,
            Opportunity_PTL__r.PTL__r.SAP_Postal_Code__c,
            Opportunity_PTL__r.PTL__r.Scale__c,
            Opportunity_PTL__r.PTL__r.Scale_Code__c,
            Opportunity_PTL__r.PTL__r.Shipping_Condition__c,
            Opportunity_PTL__r.PTL__r.Status__c,
            Opportunity_PTL__r.PTL__r.Street_name__c,
            Opportunity_PTL__r.PTL__r.Street_number__c,
            Opportunity_PTL__r.PTL__r.Street_type__c,
            Opportunity_PTL__r.PTL__r.Temporary_dispensation__c,
            Opportunity_PTL__r.PTL__r.Title__c,
            Opportunity_PTL__r.PTL__r.Truck_delivery_condition_details__c,
            Opportunity_PTL__r.PTL__r.Value_added_tax_within_the_Community__c,
            Opportunity_PTL__r.PTL__r.Value_of_tonnage_limitation__c,
            Opportunity_PTL__r.PTL__r.VAT_code__c,
            Opportunity_PTL__r.PTL__r.VAT_code_sap__c,
            Opportunity_PTL__r.PTL__r.Work_Phone_Number__c,
            Opportunity_PTL__r.PTL__r.PDF_Hours_of_delivery_not_possible__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Name,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Street_Name__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Street_n__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.City_postal_code__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Postal_code__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.City__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.City_Postal_Code__r.Name,
            Opportunity_PTL__r.PTL__r.Account_DO__r.PersonOtherPhone,
            Opportunity_PTL__r.PTL__r.Account_DO__r.AccountNumber,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Street_type__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Country__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.PersonEmail,
            Opportunity_PTL__r.PTL__r.Account_DO__r.PersonHomePhone,
            Opportunity_PTL__r.PTL__r.Account_DO__r.PersonMobilePhone,
            Opportunity_PTL__r.PTL_VAT_code__c,           
            Opportunity_PTL__r.PTL_Street_name__c,  
            Opportunity_PTL__r.PTL_Street_number__c,    
            Opportunity_PTL__r.PTL_Street_type__c,
            Opportunity_PTL__r.PTL_City_Postal_Code__r.Name,
            Opportunity_PTL__r.PTL_Name__c,
            Opportunity_PTL__r.PTL_Label__c,
            Opportunity_PTL__r.PTL__r.Account_DO__r.Phone_Restriction__c,
            RPTL_Purposes__c,
            Opportunity_PTL__r.PTL_First_and_Last_Name__c,
            Opportunity_PTL__r.PTL_E_mail__c,
            Opportunity_PTL__r.PTL_Work_Phone_Number__c,
            Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,
            Opportunity_PTL__r.PTL_Phone__c,
            Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,
            Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,
            Opportunity_PTL__r.PTL_Delivery_possible_in_absence_of_clie__c,
            Opportunity_PTL__r.PTL_PDF_Hours_of_delivery_not_possible__c,
            Opportunity_PTL__r.PTL_Days_no_Delivery_possible__c,
            Opportunity_PTL__r.PTL_Precheck_Truck_needed__c, 
            Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,
            Opportunity_PTL__r.PTL_Shipping_Condition__c,
            Opportunity_PTL__r.PTL_Gasdeliverymode__c,
            Opportunity_PTL__r.PTL_Clayground__c,
            Opportunity_PTL__r.PTL_Electric_Cable_High_voltage__c,
            Opportunity_PTL__r.PTL_Excemption_of_Tonnage_estimated_at__c,
            Opportunity_PTL__r.PTL_Limitation_of_Height_if_3_5__c,
            Opportunity_PTL__r.PTL_Means_for_Handling_tank_to_from__c,
            Opportunity_PTL__r.PTL_Other_Cles_enMain_Conditions__c,
            Opportunity_PTL__r.PTL_Passage_electric_equipement__c,
            Opportunity_PTL__r.PTL_Passage_over_a_Wall_fence__c,
            Opportunity_PTL__r.PTL_Position_Tank_Heightend_Sunken__c,
            Opportunity_PTL__r.PTL_Septic_Tank__c,
            Opportunity_PTL__r.PTL_Existing_below_ground_channels__c,
            Opportunity_PTL__r.PTL_Size_3m__c,
            Opportunity_PTL__r.PTL_With_wall__c,
            Opportunity_PTL__r.PTL_Obslacle_at_access_point_PTL__c,
            Opportunity_PTL__r.PTL_Acces_via_lawn_or_vegetation__c,
            Opportunity_PTL__r.PTL_MEP_Anchoring_Surface_Tank__c,
            Opportunity_PTL__r.Call_client_before_delivery__c,
            Opportunity_PTL__r.PTL_MEP_Cles_en_Main_Y_N__c,
            Opportunity_PTL__r.PTL_MEP_Concrete__c,
            Opportunity_PTL__r.PTL_MEP_Concrete_Tile_Flooring__c,
            Opportunity_PTL__r.PTL_MEP_Connected_Tank__c,
            Opportunity_PTL__r.PTL_MEP_Connection_Type__c,
            Opportunity_PTL__r.PTL_MEP_Detente_3_Bar__c,
            Opportunity_PTL__r.PTL_MEP_Drain__c,
            Opportunity_PTL__r.PTL_MEP_Earliest_Tank_moving_Date__c,
            Opportunity_PTL__r.PTL_MEP_Enhance_Jauge__c,
            Opportunity_PTL__r.PTL_MEP_Evacuation_of_Dirt_Rubble__c,
            Opportunity_PTL__r.PTL_MEP_FlooringForBurriedBallastTank__c,
            Opportunity_PTL__r.PTL_MEP_Insdustrial_Outflow__c,
            Opportunity_PTL__r.MEP_Intervention__c,
            Opportunity_PTL__r.PTL_MEP_Land_spreading_10_m__c,
            Opportunity_PTL__r.PTL_MEP_Latest_Tank_moving_Date_MEP__c,
            Opportunity_PTL__r.PTL_MEP_Mechanic_type__c,
            Opportunity_PTL__r.PTL_MEP_Tank_Placing_Type_Details__c,
            Opportunity_PTL__r.PTL_MEP_Comments__c,
            Opportunity_PTL__r.PTL_MEP_ModificationOfInstallNeeded__c,
            Opportunity_PTL__r.PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c,
            Opportunity_PTL__r.PTL_MEP_Percentage_Jauge_Competitor_Tank__c,
            Opportunity_PTL__r.PTL_MEP_Precheck_Tank_Connection_Y_N__c,
            Opportunity_PTL__r.PTL_MEP_Preparation_trench__c,
            Opportunity_PTL__r.PTL_MEP_Pre_Visit__c,
            Opportunity_PTL__r.PTL_MEP_Supplementary_Filling__c,
            Opportunity_PTL__r.PTL_MEP_SysCutOffPtAtLiquidChannel__c,
            Opportunity_PTL__r.PTL_MEP_Simultaneous_MEP__c,
            Opportunity_PTL__r.PTL_MEP_TeleJauge__c,
            Opportunity_PTL__r.PTL_MEP_Three_point_attachement__c 
     
            from QUOTE_PTL__C where Opportunity_PTL__c = :current.Id];
        }
             
        return QuotePTLs;               
    }
     
     
     
     /*
      * Get All Equipement__c related to the current Opty PTL
      */
      public List<Equipement__c> getPTLEQUIPEMENTS() {
          
          List<Equipement__c> Equipementlist = new List<Equipement__c>();
            {
              if(current.PTL__c != null){
                  Equipementlist = [select Article__r.Name,Tank_Type__c,Capacity_Tank__c,Name,PTL__c,ExternalID__c,Designation__c from Equipement__C where PTL__c = :current.PTL__c];
              }
              
              return Equipementlist;
           }
       }
       
       
    
    public List<Attachment> getPlanImplantation() {
		
		//System.debug(logginglevel.WARN,'### getPlanImplantation Starting');
		//System.debug(logginglevel.WARN,'### current.Id =' + current.Id);
		
		List<Attachment> planImpList = [select Id from Attachment where ParentId =:current.Id order by Name];
		
		//System.debug(logginglevel.WARN,'### planImpList.size() =' + planImpList.size());
		
		return planImpList;
		
    }
    
    
    /*public List<Attachment> getPlanImplantation() {
		
		List<Attachment> planImpList = new List<Attachment>();
		
		System.debug(logginglevel.WARN,'### getPlanImplantation Starting');
		System.debug(logginglevel.WARN,'### current.Id =' + current.Id);
		
		List<OPTL_Attachment__c> lOPTL_Att = [select Id from OPTL_Attachment__c where Opportunity_PTL__c =:current.Id];
		
		if(lOPTL_Att.size() > 0){
			planImpList = [select Id from Attachment where ParentId =:lOPTL_Att order by Name];
		}
		
		System.debug(logginglevel.WARN,'### planImpList.size() =' + planImpList.size());
		
		return planImpList;
		
    }*/
    
    
    /** Generate and save Contract PDF file **/ 
	/*WebService static boolean generateMEPPDF(string optlId){
		
		boolean res = false;
		
		// Delete documents (for this OPTL) if already existing
        List<Document_A_Signer__c> lDocsSignea = new List<Document_A_Signer__c>();
        List<Document> lDocs = new List<Document>();
        List<String> lDocsId = new List<String>();
        
        isSE = 'true';  // electronic signature
        
		// Get OPTL
        List<Opportunity_PTL__c> lOPTL = [select Id, Opportunity__r.SyncedQuoteId, Name, PTL__c
        						from Opportunity_PTL__c where Id =:optlId limit 1];
        if(!lOPTL.isEmpty()){
            current = lOPTL[0];
        }else{
            return false;
        }
        System.debug(logginglevel.WARN,'### isSE =' + isSE);
        
        System.debug(logginglevel.WARN,'### current =' + current);
        System.debug(logginglevel.WARN,'### current.Opportunity__c =' + current.Opportunity__c);
        System.debug(logginglevel.WARN,'### current.Opportunity__r.SyncedQuoteId =' + current.Opportunity__r.SyncedQuoteId);
        
        if(current.Opportunity__r.SyncedQuoteId != null){
            lDocsSignea = [select Id, Id_SF_Document__c from Document_A_Signer__c where Devis__c = :current.Opportunity__r.SyncedQuoteId and Identifiant_OPTL__c = :current.Id];
            
            for (Document_A_Signer__c docSignea : lDocsSignea){
                lDocsId.add(docSignea.Id_SF_Document__c);
            }
            
            if (lDocsSignea.size() > 0){
                lDocs = [select Id from Document where Id = :lDocsId];
                if (lDocs.size() > 0) delete lDocs;
                delete lDocsSignea;
            }
            
        }
        
        PageReference pdfPage = Page.VFP_AvenantPDF_Dossiers;
		pdfPage.getParameters().put('id', current.Id);
		pdfPage.getParameters().put('isSE', isSE);
		Blob pdfBlob = pdfPage.getContent();
		//Attachment attach = new Attachment(parentId = oQuote.Id, Name = 'Contrat-' + oQuote.QuoteNumber + '.pdf', body = pdfBlob);
		//insert attach;
        
        // Insert new Document
        // Set FolderId in a Custom Setting ?
        Document doc = new Document(Name = 'Plan et dossier MEP-' + current.Name, Type = 'PDF', FolderId = '00lD0000001W5dI', Body = pdfBlob);
        System.debug('doc : ' + doc);
        insert doc;
        
        // Insert new Document_Signea__c
        Document_A_Signer__c docSignea = new Document_A_Signer__c(Name = 'Plan et dossier MEP-' + current.Name, Devis__c = current.Opportunity__r.SyncedQuoteId, Id_SF_Document__c = doc.Id, Type_de_document__c = 'Document', Identifiant_OPTL__c = current.Id);
        System.debug('docSignea : ' + docSignea);
        insert docSignea;
        
        
        res = true;
        return res;
        
        //PageReference pageWhereWeWantToGo = new PageReference('/'+ current.Id);
        //apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Document sauvegardé');
        //apexpages.addmessage(msg);
        //pageWhereWeWantToGo.setRedirect(true);
        //return pageWhereWeWantToGo;
        //return null;
	}*/
	
	
	
	
}