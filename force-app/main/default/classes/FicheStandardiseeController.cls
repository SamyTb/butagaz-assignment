public class FicheStandardiseeController {
    
    public Quote oQuote {get; set;} // set by component assignTo
    
    public string modaliteVenteCiterne {get; set;}
    //public string tankProperty {get; set;}
    public string gplPricePerTon {get; set;}
    public string shippingAmount {get; set;}
    public string shippingCondition {get; set;}
    public string modaliteModifPrix {get; set;}
    public string tankInstallationPrice {get; set;}
    public string tankAnnualRentPrice {get; set;}
    //public string warrantyDepositPrice {get; set;}
    public string tankMaintenanceAndUpkeepPrice {get; set;}
    //public string tankRemovalOrMovingPrice {get; set;}
    public string tankNeutralizationPrice {get; set;}
    //public string pumpingPriceAtClient {get; set;}
    //public string pumpingPriceAtWorkshop {get; set;}
    public string penaltyBeforeInstallPrice {get; set;}
    public string penaltyAfterInstallPrice {get; set;}
    public string feesPrice {get; set;}
    public string butagazAssistancePrice {get; set;}
    public string paymentSpread {get; set;}
    public string lockedPrice {get; set;}
    public string connectedGaugeMonthlySubscription {get; set;}
    public string ecocftMonthlyPrice {get; set;}
    public decimal ecocftOfferedMonths {get; set;}
    
    public string estimatedConsumption {get; set;}
    public string sumOfFeesOverContractDuration {get; set;}
    public string annualCostEstimate {get; set;}
    
    public List<QuoteLineItem> quotelineitemList {get;set;}
    public List<String> qptlList {get;set;}
    
    //public Set<String> tankCharacteristicsSet {get; set;}
    public List<String> tankCharacteristicsList {get; set;}
    public List<String> tankInstallationPriceList {get; set;}
    public List<String> tankPropertyList {get; set;}
    public List<String> warrantyDepositPriceList {get; set;}
    public List<String> tankMaintenanceAndUpkeepPriceList {get; set;}
    public List<String> tankRemovalOrMovingAtContractStartPriceList {get; set;}
    public List<String> tankRemovalOrMovingAtContractEndPriceList {get; set;}
    public List<String> tankNeutralizationPriceList {get; set;}
    public List<String> pumpingPriceAtClientList {get; set;}
    public List<String> pumpingPriceAtWorkshopList {get; set;}
    public List<String> connectedGaugeSupplyAndInstallationList {get; set;}
    //public List<String> connectedGaugeMonthlySubscriptionList {get; set;}
    public List<String> annualCostEstimateList {get; set;}
    public List<String> finalAnnualCostEstimateList {get; set;}
    
    public boolean rebatesIncluded {get; set;}
    public integer rowspanPumpingPrice {get; set;}
    //public integer rowspanOptions {get; set;}
    public integer rowspanTankInstallation {get; set;}
    //public integer rowspanOffer {get; set;}
    public integer rowspanOptionsDOM {get; set;}
    public integer rowspanOptionsPRO {get; set;}
    public integer rowspanOfferCharacteristics {get; set;}
    
    
    
    
    public FicheStandardiseeController(){
        
    }
    
    /* The component's attributes are not available in the constructor so this method is used to query the data using the attribute.
     * This method is implicitly called by a field displayed on the component.
     * This method returns an empty string because we don't want anything to be printed in the outputtext.
     */
    public string getQuoteId(){
        //string toto = oQuote.Id;
        
        decimal amountofTankInstallationPrice = 0;
        decimal amountofTankMaintenanceAndUpkeepPrice = 0;
        decimal amountofFeesPrice = 0;
        decimal amountofWarrantyDepositPrice = 0;
        decimal amountofTankRemovalOrMovingAtContractStartPrice = 0;
        decimal amountofTankRemovalOrMovingAtContractEndPrice = 0;
        decimal amountofEcocftMonthlyPrice = 0;
        decimal amountofSumOfFeesOverContractDuration = 0;
        decimal amountofAnnualCostEstimate = 0;
        decimal amountofGplPricePerTon = 0;
        decimal amountofGplNormalPricePerTon = 0;
        decimal amountofLockedPrice = 0;
        decimal amountofconnectedGaugeMonthlySubscription = 0;
        decimal amountofGaugeSupplyAndInstallation = 0;
        
        decimal amountofRebatesOnGpl_RCE = 0;
        decimal amountofRebatesOnGpl_RCom = 0;
        decimal amountofRebatesOnGpl_RConj = 0;
        decimal rebatesOnGpl_RConjMonths = 0;
        decimal amountofRebatesOnAbonnement_RCom = 0;
        decimal amountofRebatePostOffre = 0;
        decimal amountRCOM_AbonnementAccesEnergie = 0;
        
        //double amountofTankNeutralizationPrice = 0;
        //double amountofPumpingPriceAtClient = 0;
        //double amountofPumpingPriceAtWorkshop = 0;
        //double amountofPenaltyAfterInstallPrice = 0;
        
        //tankCharacteristicsSet = new Set<String>();
        tankCharacteristicsList = new List<String>();
        tankInstallationPriceList = new List<String>();
        tankPropertyList = new List<String>();
        warrantyDepositPriceList = new List<String>();
        tankMaintenanceAndUpkeepPriceList = new List<String>();
        tankRemovalOrMovingAtContractStartPriceList = new List<String>();
        tankRemovalOrMovingAtContractEndPriceList = new List<String>();
        tankNeutralizationPriceList = new List<String>();
        pumpingPriceAtClientList = new List<String>();
        pumpingPriceAtWorkshopList = new List<String>();
        
        connectedGaugeSupplyAndInstallationList = new List<String>();
        //connectedGaugeMonthlySubscriptionList = new List<String>();
        annualCostEstimateList = new List<String>();
        finalAnnualCostEstimateList = new List<String>();
        
        string tankFeesPaymentType = '';
        
        integer fixedPriceNbYear = 0;
        integer cptProductLines = 0;
        
        rowspanOptionsDOM = 5;
        rowspanOptionsPRO = 2;
        // Add rows for Bio and CC options
        if( oQuote.Market_type__c=='DOM' ) {
            rowspanOptionsDOM += 1;
            rowspanOfferCharacteristics = 4;
        }else if( oQuote.Market_type__c=='PRO' ) {
            rowspanOptionsPRO += 2;
            rowspanOfferCharacteristics = 5;
        }
        
        // Get the RCOM_AbonnementAccesEnergie__c amount on the Action Co
        if(oQuote.Action_Commerciale__c != null && oQuote.Action_Commerciale__r.RCOM_AbonnementAccesEnergie__c != null){
            amountRCOM_AbonnementAccesEnergie = oQuote.Action_Commerciale__r.RCOM_AbonnementAccesEnergie__c;
        }
        
        
        this.quotelineitemList = new List<QuoteLineItem>();
        
        this.quotelineitemList = [
            SELECT 
                QuoteId,
                Quote.Opportunity.T_Pack__c,
                Quote.Shipping_Condition__c,
                Quote.Opportunity.Client_Type__c,
                Quote.Opportunity.Project_Type__c,
                F_Product_Code__c,
                Quantity,
                Price_List_HT__c,
                Price_List_TTC__c,
                /*New_Price_HT__c,*/
                New_Price_TTC__c,
                Sub_Type__c,
                Tank_Placing_Type__c,
                Tank_Capacity__c,
                Mis_Disposition__c,
                Tank_Placing_Options__c,
                Quote_PTL__r.Name, 
                Quote_PTL__r.Estimated_Consumption__c,
                Normal_Product_Scale_From_SAP__c,
                Product_Family__c,
                RCE_Rebate_TTC__c,
                RCE_Rebate_HT__c,
                Commercial_Rebate_TTC__c,
                Commercial_Rebate_HT__c,
                Cyclical_Rebate_TTC__c,
                Cyclical_Rebate_HT__c,
                Cyclical_Rebate_Months__c,
                Offered_Months__c,
                Product2.Payment_type__c,
                Deconsignation__c,
                PricebookEntry.Product2.Standardized_Form__c,
                Only_for_Standardized_Form__c,
                Remise_Post_Offre_HT__c,
                Remise_Post_Offre_TTC__c
                
                
                /*,
                UnitPrice,
                pricebookentry.Name,
                Discount,
                SortOrder,
                ListPrice,
                Got_From_SAP__c,
                F_Quantity_Unit__c,
                Group_Commercial_Rebate_HT__c,
                Group_Commercial_Rebate_TTC__c,
                Group_Cyclical_Rebate_HT__c,
                Group_Cyclical_Rebate_TTC__c,
                Linked_PTL__c,
                Quantity_Unit__c,
                Amount_Unit__c,
                Pricing_Unit__c,
                F_MonthlyPriceDisplay__c*/
            FROM quotelineitem 
            where QuoteId = :oQuote.Id
            order by Quote_PTL__r.Name
        ];
        
        
        qptlList = new List<String>();
        
        for(quotelineitem oqli:quotelineitemList){
            
            System.debug(logginglevel.WARN,'### oqli.F_Product_Code__c = ' + oqli.F_Product_Code__c);
            System.debug(logginglevel.WARN,'### oqli.Sub_Type__c = ' + oqli.Sub_Type__c);
            System.debug(logginglevel.WARN,'### oqli.Product_Family__c = ' + oqli.Product_Family__c);
            
            // Manage tanks
            if(oqli.Sub_Type__c == 'Citerne'){
                
                // Get the QPTL so we make sure we match the prices on the correct QPTL
                if(!qptlList.contains(oqli.Quote_PTL__r.Name)) qptlList.add(oqli.Quote_PTL__r.Name);
                
                // tankCharacteristicsList
                tankCharacteristicsList.add(oqli.Tank_Placing_Type__c + ' ' + oqli.Tank_Capacity__c + ' T');
            }
            
            if(oqli.Product_Family__c == 'Produit'){
                cptProductLines++;
                if(oQuote.Market_type__c == 'DOM'){
                    amountofGplPricePerTon = (oqli.Price_List_TTC__c == null ? 0 : oqli.Price_List_TTC__c.setScale(2));
                    amountofGplNormalPricePerTon = (oqli.Normal_Product_Scale_From_SAP__c == null ? 0 : oqli.Normal_Product_Scale_From_SAP__c.setScale(2));
                    amountofRebatesOnGpl_RCE += (oqli.RCE_Rebate_TTC__c == null ? 0 : oqli.RCE_Rebate_TTC__c);
                    amountofRebatesOnGpl_RCom += (oqli.Commercial_Rebate_TTC__c == null ? 0 : oqli.Commercial_Rebate_TTC__c);
                    amountofRebatesOnGpl_RConj += (oqli.Cyclical_Rebate_TTC__c == null ? 0 : oqli.Cyclical_Rebate_TTC__c);
                    amountofRebatePostOffre = (oqli.Remise_Post_Offre_TTC__c == null ? 0 : oqli.Remise_Post_Offre_TTC__c);
                }else if(oQuote.Market_type__c == 'PRO'){
                    amountofGplPricePerTon = (oqli.Price_List_HT__c == null ? 0 : oqli.Price_List_HT__c.setScale(2));   // ToDo : Manage HT
                    amountofGplNormalPricePerTon = (oqli.Normal_Product_Scale_From_SAP__c == null ? 0 : oqli.Normal_Product_Scale_From_SAP__c.setScale(2));   // ToDo : Manage HT
                    amountofRebatesOnGpl_RCE += (oqli.RCE_Rebate_HT__c == null ? 0 : oqli.RCE_Rebate_HT__c);
                    amountofRebatesOnGpl_RCom += (oqli.Commercial_Rebate_HT__c == null ? 0 : oqli.Commercial_Rebate_HT__c);
                    amountofRebatesOnGpl_RConj += (oqli.Cyclical_Rebate_HT__c == null ? 0 : oqli.Cyclical_Rebate_HT__c);
                    amountofRebatePostOffre = (oqli.Remise_Post_Offre_HT__c == null ? 0 : oqli.Remise_Post_Offre_HT__c);
                }
                rebatesOnGpl_RConjMonths = (oqli.Cyclical_Rebate_Months__c == null ? 0 : oqli.Cyclical_Rebate_Months__c);
            }
            
            if(!oqli.Deconsignation__c && oqli.Product_Family__c == 'Redevance' && oqli.Sub_Type__c == 'Redevance citerne' && oqli.Product2.Payment_type__c == 'Abonnement'){
                if(oQuote.Market_type__c == 'DOM'){
                    amountofRebatesOnAbonnement_RCom += (oqli.Commercial_Rebate_TTC__c == null ? 0 : oqli.Commercial_Rebate_TTC__c);
                }else if(oQuote.Market_type__c == 'PRO'){
                    amountofRebatesOnAbonnement_RCom += (oqli.Commercial_Rebate_HT__c == null ? 0 : oqli.Commercial_Rebate_HT__c);
                }
            }
            
            // Abonnement or Consignation
            //if(!oqli.Deconsignation__c && oqli.Product_Family__c == 'Redevance' && oqli.Sub_Type__c == 'Redevance citerne'){
            //  tankFeesPaymentType = oqli.Product2.Payment_type__c;
                /*if(oqli.Payment_type__c == 'Abonnement'){
                    tankFeesPaymentType = 'Abonnement';
                }else if(oqli.Payment_type__c == 'Consignation'){
                    tankFeesPaymentType = 'Consignation';
                }*/
            //}
            
        }
        
        // gplPricePerTon
        if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            gplPricePerTon = System.Label.FS_IncludedInMonthlyPayment;
        }else if(oQuote.Action_Commerciale__c != null && (oQuote.Action_Commerciale__r.Fixed_Price__c || oQuote.Action_Commerciale__r.Locked_Price_1_Year__c || oQuote.Action_Commerciale__r.Locked_Price_2_Years__c || oQuote.Action_Commerciale__r.Locked_Price_3_Years__c) ){
            if(oQuote.Action_Commerciale__r.Locked_Price_1_Year__c){
                fixedPriceNbYear = 1;
            }else if(oQuote.Action_Commerciale__r.Locked_Price_2_Years__c){
                fixedPriceNbYear = 2;
            }else if(oQuote.Action_Commerciale__r.Locked_Price_3_Years__c){
                fixedPriceNbYear = 3;
            }else{
                fixedPriceNbYear = Integer.valueOf(oQuote.Contract_Duration__c);
            }
            
            gplPricePerTon = String.valueOf(amountofGplPricePerTon) + ' ' + System.Label.FS_EuroPerTon ;
            //display all pack except OPTIMO
            if(oQuote.Opportunity.T_Pack__c != 'OPTIMO'){
            gplPricePerTon += System.Label.FS_GplPricePerTonFixedPrice1 + String.valueOf(fixedPriceNbYear) + System.Label.FS_GplPricePerTonFixedPrice3 + '<br/>';
            }
            // We don't want to display the normal product scale if the rebate duration equals the contract duration   
            if(fixedPriceNbYear != Decimal.valueOf(oQuote.Contract_Duration__c)){
                gplPricePerTon += String.valueOf(amountofGplNormalPricePerTon) + ' ' + System.Label.FS_EuroPerTon + System.Label.FS_GplPricePerTonFixedPrice2 + String.valueOf(Decimal.valueOf(oQuote.Contract_Duration__c) - fixedPriceNbYear) + System.Label.FS_GplPricePerTonFixedPrice3 + ' ' + System.Label.FS_GplPricePerTonFixedPrice4;
            }
            
        }else{
            gplPricePerTon = String.valueOf(amountofGplPricePerTon) + ' ' + System.Label.FS_EuroPerTon;
        }
        
        
        // shippingAmount
        if(oQuote.Market_type__c == 'DOM'){
            if(oQuote.Opportunity.T_Pack__c == 'OldContracts'){
                shippingAmount = System.Label.FS_NotAffected;
                if(oQuote.Shipping_Condition__c == '02'){  // Sur commande
                    shippingCondition = System.Label.FS_ShippingConditionCustomer;
                }else if(oQuote.Shipping_Condition__c == '04' || oQuote.Shipping_Condition__c == '05'){  // Previ or Telemetrie
                    shippingCondition = System.Label.FS_ShippingConditionBTZ;
                }
            }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                if(oQuote.Shipping_Condition__c == '02'){  // Sur commande
                    shippingAmount = System.Label.FS_ShippingAmountCommande;
                    shippingCondition = System.Label.FS_ShippingConditionCustomer;
                }else if(oQuote.Shipping_Condition__c == '04' || oQuote.Shipping_Condition__c == '05'){  // Previ or Telemetrie
                    shippingAmount = System.Label.FS_NotAffected;
                    shippingCondition = System.Label.FS_ShippingConditionBTZ;
                }
            }else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                shippingAmount = System.Label.FS_IncludedInMonthlyPayment;
                shippingCondition = System.Label.FS_ShippingConditionBTZ;
            }
        }else if(oQuote.Market_type__c == 'PRO'){
            shippingAmount = System.Label.FS_Offered;
            if(oQuote.Shipping_Condition__c == '02'){  // Sur commande
                shippingCondition = System.Label.FS_ShippingConditionCustomer;
            }else if(oQuote.Shipping_Condition__c == '04' || oQuote.Shipping_Condition__c == '05'){  // Previ or Telemetrie
                shippingCondition = System.Label.FS_ShippingConditionBTZ;
            }
        }
        
        // 20211026 : SP464 : Butagaz chose not to sell tanks to B2C customers anymore
        // modaliteVenteCiterne
        /*if(oQuote.Market_type__c == 'DOM'){
            if(oQuote.Opportunity.Client_Type__c == 'Renter'){
                modaliteVenteCiterne = System.Label.FS_NotAffected;
            }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'ECOCFT' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                modaliteVenteCiterne = System.Label.FS_ModaliteVenteCiterneDOM;
            }else if(oQuote.Opportunity.T_Pack__c == 'SOLO'){
                modaliteVenteCiterne = System.Label.FS_ModaliteVenteCiterneOwner;
            }
        }else*/ 
        if(oQuote.Market_type__c == 'PRO'){           
            for(quotelineitem oqli:quotelineitemList){
                if(oqli.Sub_Type__c == 'Citerne' && oqli.Mis_Disposition__c == 'Customer Owned Tank'){
                    modaliteVenteCiterne = System.Label.FS_NotAffected;
                    break;
                }else if(oqli.Sub_Type__c == 'Citerne' && oqli.Mis_Disposition__c == 'Butagaz Owned Tank'){
                    modaliteVenteCiterne = System.Label.FS_ModaliteVenteCiternePRO;
                    break;
                }
            }
        }
            
        // modaliteModifPrix
        if(oQuote.Market_type__c == 'DOM'){
            if(oQuote.Opportunity.Client_Type__c == 'Renter' && oQuote.Opportunity.T_Pack__c != 'IDEO' && oQuote.Opportunity.T_Pack__c != 'SOLO' && oQuote.Opportunity.T_Pack__c != 'OPTIMO' ){
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixRenterOldContracts;
            }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO'){
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixIDEOSOLO;
            }else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixECOCFT;
            }else if(oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixOPTIMO;
            }
        }else if(oQuote.Market_type__c == 'PRO'){
            if(oQuote.DO_groupement__c != null && oQuote.DO_groupement__r.AccountNumber.startsWithIgnoreCase('PROFT')){
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixPROPrixFixe;
            }else{
                modaliteModifPrix = System.Label.FS_ModaliteModifPrixPRO;
            }
        }
        
        // tankProperty
        if(oQuote.Market_type__c == 'DOM'){
            if(oQuote.Opportunity.Client_Type__c == 'Renter' && oQuote.Opportunity.T_Pack__c != 'IDEO' && oQuote.Opportunity.T_Pack__c != 'SOLO' && oQuote.Opportunity.T_Pack__c != 'OPTIMO'){
                //tankProperty = System.Label.FS_TankPropertyRenter;
                tankPropertyList.add(System.Label.FS_TankPropertyRenter);
            }else if(oQuote.Opportunity.Client_Type__c == 'Renter' && oQuote.Opportunity.T_Pack__c == 'SOLO'){
                //tankProperty = System.Label.FS_TankPropertyRenter;
                tankPropertyList.add(System.Label.FS_TankPropertyRenter);
            }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'ECOCFT' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                //tankProperty = System.Label.FS_TankPropertyBTZ;
                tankPropertyList.add(System.Label.FS_TankPropertyBTZ);
            }else if(oQuote.Opportunity.T_Pack__c == 'SOLO'){
                //tankProperty = System.Label.FS_TankPropertyCustomer;
                tankPropertyList.add(System.Label.FS_TankPropertyCustomer);
            }
        }else if(oQuote.Market_type__c == 'PRO'){
            for(quotelineitem oqli:quotelineitemList){
                if(oqli.Sub_Type__c == 'Citerne' && oqli.Mis_Disposition__c == 'Customer Owned Tank'){
                    tankPropertyList.add(System.Label.FS_TankPropertyCustomer);
                }else if(oqli.Sub_Type__c == 'Citerne' && oqli.Mis_Disposition__c == 'Butagaz Owned Tank'){
                    tankPropertyList.add(System.Label.FS_TankPropertyBTZ);
                }
            }
        }
        
        // tankInstallationPrice   /!\ ToDo : Manage Adaptation de stockage
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            tankInstallationPriceList.add(System.Label.FS_NotAffected);
        //}else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
        //  tankInstallationPriceList.add(System.Label.FS_IncludedInMonthlyPayment);
        }else if( (oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO' || oQuote.Opportunity.T_Pack__c == 'ECOCFT' || oQuote.Opportunity.T_Pack__c == 'OPTIMO' ) || oQuote.Market_type__c == 'PRO'  ){
            // Check Tank Placing Option
            boolean bCDP = false;
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.Sub_Type__c == 'Citerne' && oqli.Tank_Placing_Options__c == 'CDP'){
                    bCDP = true;
                    break;
                }
            }
            
            for(String qptl:qptlList){
                // Difference between free and non-free products
                for(quotelineitem oqli:quotelineitemList){
                    if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                        // No need to check for products in ECOCFT. It'll be either FS_NotAffected or FS_IncludedInMonthlyPayment
                    }else if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.F_Product_Code__c == 'S000000169' || oqli.F_Product_Code__c == 'S000000170')){
                        tankInstallationPriceList.add(System.Label.FS_Offered);
                    }else if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.F_Product_Code__c == 'S000000007' || oqli.F_Product_Code__c == 'S000000165' || oqli.F_Product_Code__c == 'S000000109' 
                            || oqli.F_Product_Code__c == 'S000000006' || oqli.F_Product_Code__c == 'S000000042' || oqli.F_Product_Code__c == 'S000000118' || oqli.F_Product_Code__c == 'S000000094')){
                        if(oQuote.Market_type__c == 'DOM'){
                            tankInstallationPriceList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                            amountofTankInstallationPrice += oqli.Price_List_TTC__c;
                        }else if(oQuote.Market_type__c == 'PRO'){
                            tankInstallationPriceList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                            amountofTankInstallationPrice += oqli.Price_List_HT__c;
                        }
                    }
                }
                if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                    tankInstallationPriceList.add(System.Label.FS_IncludedInMonthlyPayment);
                }else if(tankInstallationPriceList.size() == 0 /*&& bCDP*/){
                    tankInstallationPriceList.add(System.Label.FS_NotAffected);
                }
            }
        }
        
        // tankAnnualRentPrice
        tankAnnualRentPrice = System.Label.FS_TankAnnualRentPrice;
        
        // warrantyDepositPrice
        if(oQuote.Market_type__c == 'DOM'){
            //warrantyDepositPrice = System.Label.FS_WarrantyDepositPrice;
            warrantyDepositPriceList.add(System.Label.FS_WarrantyDepositPrice);
        }else if(oQuote.Market_type__c == 'PRO'){
            /*if(tankFeesPaymentType == 'Abonnement'){
                //warrantyDepositPrice = System.Label.FS_NotAffected;
                warrantyDepositPriceList.add(System.Label.FS_NotAffected);
            }else{*/
                for(String qptl:qptlList){
                    for(quotelineitem oqli:quotelineitemList){
                        if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.Product_Family__c == 'Redevance' && oqli.Sub_Type__c == 'Redevance citerne')){
                            if(oqli.Product2.Payment_type__c == 'Consignation') {
                                warrantyDepositPriceList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                                amountofWarrantyDepositPrice += oqli.Price_List_HT__c;
                            }
                        }
                    }
                }
            //}
        }
        if(warrantyDepositPriceList.size()==0){
            warrantyDepositPriceList.add(System.Label.FS_NotAffected);
        }
        
        // tankMaintenanceAndUpkeepPrice                
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            //tankMaintenanceAndUpkeepPriceList.add(System.Label.FS_NotAffected);
            tankMaintenanceAndUpkeepPrice = System.Label.FS_NotAffected;
        }else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            //tankMaintenanceAndUpkeepPriceList.add(System.Label.FS_IncludedInMonthlyPayment);
            tankMaintenanceAndUpkeepPrice = System.Label.FS_IncludedInMonthlyPayment;
        }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
            for(String qptl:qptlList){
                // If product code matches Maintenance and Upkeep products, we use them in the calculation 
                for(quotelineitem oqli:quotelineitemList){
                    if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c){
                        // sharepoint 475
                        if(oqli.F_Product_Code__c == 'SPPABO0011'){
                            amountofTankMaintenanceAndUpkeepPrice += oqli.Price_List_TTC__c  * 12;
                        }else if(oqli.F_Product_Code__c == 'SPPABO0010'){
                            amountofTankMaintenanceAndUpkeepPrice += (oqli.Price_List_TTC__c - amountRCOM_AbonnementAccesEnergie ) * 12;
                        }
                    }
                }
            }
            tankMaintenanceAndUpkeepPrice = String.valueOf(amountofTankMaintenanceAndUpkeepPrice.setScale(2)) + ' ' + System.Label.FS_Euro;
        }else if(oQuote.Opportunity.T_Pack__c == 'SOLO'){
            for(String qptl:qptlList){
                // If product code matches Maintenance and Upkeep products, we use them in the calculation 
                for(quotelineitem oqli:quotelineitemList){
                    if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c){
                        // sharepoint 475
                        if(oqli.F_Product_Code__c == 'SPPABO0009'){
                            amountofTankMaintenanceAndUpkeepPrice += oqli.Price_List_TTC__c  * 12;
                        }else if(oqli.F_Product_Code__c == 'SPPABO0008'){
                            amountofTankMaintenanceAndUpkeepPrice += (oqli.Price_List_TTC__c - amountRCOM_AbonnementAccesEnergie ) * 12;
                        }
                    }
                }
            }
            tankMaintenanceAndUpkeepPrice = String.valueOf(amountofTankMaintenanceAndUpkeepPrice.setScale(2)) + ' ' + System.Label.FS_Euro;
        }else if(oQuote.Market_type__c == 'PRO'){
            /*if(tankFeesPaymentType == 'Consignation'){
                tankMaintenanceAndUpkeepPrice = System.Label.FS_NotAffected;
            }else{*/
                for(String qptl:qptlList){
                    for(quotelineitem oqli:quotelineitemList){
                        if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.Product_Family__c == 'Redevance' && oqli.Sub_Type__c == 'Redevance citerne')){
                            if(oqli.Product2.Payment_type__c == 'Abonnement') {
                                amountofTankMaintenanceAndUpkeepPrice += oqli.Price_List_HT__c * 12;
                            }
                        }
                    }
                }
                tankMaintenanceAndUpkeepPrice = String.valueOf(amountofTankMaintenanceAndUpkeepPrice.setScale(2)) + ' ' + System.Label.FS_Euro;
            //}
        }
        
        // tankRemovalOrMovingPrice at contract start and end
        rowspanTankInstallation = 3;
        boolean bCustomerOwnedTank = false;
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            tankRemovalOrMovingAtContractEndPriceList.add(System.Label.FS_NotAffected);
        }else{
            
            // Check if customer owns the tanks
            /*for(quotelineitem oqli:quotelineitemList){
                if(oqli.Sub_Type__c == 'Citerne' && oqli.Mis_Disposition__c == 'Customer Owned Tank'){
                    bCustomerOwnedTank = true;
                    break;
                }
            }*/
            
            // If no MEP, then CDP so NotAffected
            /*if(bCustomerOwnedTank){
                tankRemovalOrMovingPriceList.add(System.Label.FS_NotAffected);
            }else{*/
                for(String qptl:qptlList){
                    for(quotelineitem oqli:quotelineitemList){
                        if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.F_Product_Code__c == 'S000000112' || oqli.F_Product_Code__c == 'S000000101'
                                || oqli.F_Product_Code__c == 'S000000111' || oqli.F_Product_Code__c == 'S000000015')){
                            
                            
                            if( oQuote.Opportunity.Storage_Modification_Reason__c == 'HSSE Raison Btz' && oqli.PricebookEntry.Product2.Standardized_Form__c == true && oqli.Only_for_Standardized_Form__c == false ){
                              // N/A
                            }else if( oQuote.Opportunity.Storage_Modification_Reason__c != 'HSSE Raison Btz' && oqli.PricebookEntry.Product2.Standardized_Form__c == true && oqli.Only_for_Standardized_Form__c == false ){
                              rowspanTankInstallation = 4; // We need to make a row visible in this case
                              
                              if(oQuote.Market_type__c == 'DOM'){
                                  tankRemovalOrMovingAtContractStartPriceList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                                  amountofTankRemovalOrMovingAtContractStartPrice += oqli.Price_List_TTC__c;
                              }else if(oQuote.Market_type__c == 'PRO'){
                                  tankRemovalOrMovingAtContractStartPriceList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                                  amountofTankRemovalOrMovingAtContractStartPrice += oqli.Price_List_HT__c;
                              }
                            }else{
                              if(oQuote.Market_type__c == 'DOM'){
                                  tankRemovalOrMovingAtContractEndPriceList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                                  amountofTankRemovalOrMovingAtContractEndPrice += oqli.Price_List_TTC__c;
                              }else if(oQuote.Market_type__c == 'PRO'){
                                  tankRemovalOrMovingAtContractEndPriceList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                                  amountofTankRemovalOrMovingAtContractEndPrice += oqli.Price_List_HT__c;
                              }
              }
                            
                        }
                    }
                }
            /*}*/
            
        }
        System.debug(logginglevel.WARN,'### amountofTankRemovalOrMovingAtContractStartPrice = ' + amountofTankRemovalOrMovingAtContractStartPrice);
        System.debug(logginglevel.WARN,'### amountofTankRemovalOrMovingAtContractEndPrice = ' + amountofTankRemovalOrMovingAtContractEndPrice);
        
        // tankNeutralizationPrice
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            tankNeutralizationPriceList.add(System.Label.FS_NotAffected);
        }else{
            for(String qptl:qptlList){
                for(quotelineitem oqli:quotelineitemList){
                    if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && (oqli.F_Product_Code__c == 'S000000097' || oqli.F_Product_Code__c == 'S000000147'
                            || oqli.F_Product_Code__c == 'S000000142' || oqli.F_Product_Code__c == 'S000000148')){
                        if(oQuote.Market_type__c == 'DOM'){
                            tankNeutralizationPriceList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                        }else if(oQuote.Market_type__c == 'PRO'){
                            tankNeutralizationPriceList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro);
                        }
                    }
                }
            }
        }
        
        // pumpingPrice
        rowspanPumpingPrice = (oQuote.Opportunity.Client_Type__c == 'Renter' || oQuote.Opportunity.T_Pack__c == 'ECOCFT') ? 1 : 2;
        System.debug(logginglevel.WARN,'### rowspanPumpingPrice = ' + rowspanPumpingPrice);
        
        if(oQuote.Opportunity.Client_Type__c == 'Renter' || oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            //pumpingPriceAtClient = System.Label.FS_NotAffected;
            pumpingPriceAtClientList.add(System.Label.FS_NotAffected);
        }else{
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000096' || oqli.F_Product_Code__c == 'S000000134'){   // pumpingPriceAtClient
                    if(oQuote.Market_type__c == 'DOM'){
                        //pumpingPriceAtClient = String.valueOf(oqli.Price_List_TTC__c) + ' ' + System.Label.FS_EuroPumpingAtClient;
                        pumpingPriceAtClientList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_EuroPumpingAtClient);
                    }else if(oQuote.Market_type__c == 'PRO'){
                        //pumpingPriceAtClient = String.valueOf(oqli.Price_List_HT__c) + ' ' + System.Label.FS_EuroPumpingAtClient;
                        pumpingPriceAtClientList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_EuroPumpingAtClient);
                    }
                }else if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000149' || oqli.F_Product_Code__c == 'S000000150'){   // pumpingPriceAtWorkshop
                    if(oQuote.Market_type__c == 'DOM'){
                        //pumpingPriceAtWorkshop = String.valueOf(oqli.Price_List_TTC__c) + ' ' + System.Label.FS_EuroPumpingAtWorkshop;
                        pumpingPriceAtWorkshopList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_EuroPumpingAtWorkshop);
                    }else if(oQuote.Market_type__c == 'PRO'){
                        //pumpingPriceAtWorkshop = String.valueOf(oqli.Price_List_HT__c) + ' ' + System.Label.FS_EuroPumpingAtWorkshop;
                        pumpingPriceAtWorkshopList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_EuroPumpingAtWorkshop);
                    }
                }
            }
        }
        
        // penaltyBeforeInstallPrice (ToDo : invisible product)
        boolean bMEP = false;
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            penaltyBeforeInstallPrice = System.Label.FS_NotAffected;
        }else{
            // Check if there is a MEP
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.Sub_Type__c == 'Citerne' && oqli.Tank_Placing_Options__c == 'MEP'){
                    bMEP = true;
                    break;
                }
            }
            
            // If no MEP, then CDP so NotAffected
            if(!bMEP){
                penaltyBeforeInstallPrice = System.Label.FS_NotAffected;
            }else{
                for(quotelineitem oqli:quotelineitemList){
                    if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000012'){
                        if(oQuote.Market_type__c == 'DOM'){
                            penaltyBeforeInstallPrice = String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro;
                        }else if(oQuote.Market_type__c == 'PRO'){
                            penaltyBeforeInstallPrice = String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro;
                        }
                        break;
                    }
                }
            }
        }
        
        //FLA DEBUT DEMANDE 265
        //VERIFIE SI ACTION COMMERCIALE PRIX FIXE
        Boolean bActionComFixedPrice = false;
        if(oQuote.Action_Commerciale__c != null)
        {
            if((oQuote.Action_Commerciale__r.Fixed_Price__c == true)||(oQuote.Action_Commerciale__r.Locked_Price_1_Year__c == true)||(oQuote.Action_Commerciale__r.Locked_Price_2_Years__c == true)||(oQuote.Action_Commerciale__r.Locked_Price_3_Years__c == true))
                bActionComFixedPrice = true;
        }
        //VERIFIE SI MODIFICATION DE STOCKAGE SUR OPP
        Boolean bModifStockage = false;
        
        if(oQuote.OpportunityId != null)
        {
            if((oQuote.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers enfoui')||
                (oQuote.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers apparent')||
                (oQuote.Opportunity.Opportunity_Reason__c == 'Modif de stockage – apparent vers enfoui ECOCFT')||
                (oQuote.Opportunity.Opportunity_Reason__c == 'Modif de stockage – enfoui vers apparent')||
                (oQuote.Opportunity.Opportunity_Reason__c == 'Modif de stockage – enfoui vers enfoui'))
                bModifStockage = true;
        }

        // penaltyAfterInstallPrice
        if(((oQuote.Market_type__c == 'DOM')||(oQuote.Market_type__c == 'PRO')) 
        && ((bModifStockage == true)||(bActionComFixedPrice == true)) && (oQuote.Opportunity.Project_Type__c == 'FIDE'))
        {
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000014'){
                    if(oQuote.Market_type__c == 'DOM'){
                        penaltyAfterInstallPrice = String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_EuroPenaltyAfterInstall;
                    }else if(oQuote.Market_type__c == 'PRO'){
                        penaltyAfterInstallPrice = String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_EuroPenaltyAfterInstall;
                    }
                }
            }
        }  
        //FLA FIN DEMANDE 265
        else if(oQuote.Opportunity.Project_Type__c == 'FIDE' && oQuote.Client_Reenlistment__c == 'Contract'){
            penaltyAfterInstallPrice = System.Label.FS_NotAffected;
        }else if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            penaltyAfterInstallPrice = System.Label.FS_NotAffected;
        }else{
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000014'){
                    if(oQuote.Market_type__c == 'DOM'){
                        penaltyAfterInstallPrice = String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_EuroPenaltyAfterInstall;
                    }else if(oQuote.Market_type__c == 'PRO'){
                        penaltyAfterInstallPrice = String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_EuroPenaltyAfterInstall;
                    }
                }
            }
        }
        
        // feesPrice
        if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            feesPrice = System.Label.FS_Offered;
        }else if( oQuote.Market_type__c == 'DOM' && (oQuote.Opportunity.Project_Type__c == 'CREA' || oQuote.Opportunity.Project_Type__c == 'FIDE') ){
            feesPrice = System.Label.FS_Offered;
        }else if( (oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.Project_Type__c == 'SUCC') || oQuote.Market_type__c == 'PRO'){
            feesPrice = System.Label.FS_Offered;  // 1st set the price to Offered in case there's no Fees product in the QuoteLineItems
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000132'){
                    if(oQuote.Market_type__c == 'DOM'){
                        feesPrice = String.valueOf(oqli.Price_List_TTC__c.setScale(2)) + ' ' + System.Label.FS_Euro;
                        amountofFeesPrice += oqli.Price_List_TTC__c;
                    }else if(oQuote.Market_type__c == 'PRO'){
                        feesPrice = String.valueOf(oqli.Price_List_HT__c.setScale(2)) + ' ' + System.Label.FS_Euro;
                        amountofFeesPrice += oqli.Price_List_HT__c;
                    }
                }
            }
        }
        
        // ecocftMonthlyPrice
        if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            for(quotelineitem oqli:quotelineitemList){
                if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'SPPABO0017'){
                    if(oqli.New_Price_TTC__c != null){
                        amountofEcocftMonthlyPrice = oqli.New_Price_TTC__c;  // Use New_Price_TTC__c field because we need to display the monthly price for this item
                        //ecocftMonthlyPrice = String.valueOf(oqli.Price_List_TTC__c) + ' ' + System.Label.FS_Euro;
                        ecocftOfferedMonths = oqli.Offered_Months__c == null ? 0 : oqli.Offered_Months__c;
                    }
                }
            }
            ecocftMonthlyPrice = String.valueOf(amountofEcocftMonthlyPrice.setScale(2)) + ' ' + System.Label.FS_Euro;
        }
        
        
        // Options
        // butagazAssistancePrice
        if(oQuote.Market_type__c == 'DOM') butagazAssistancePrice = System.Label.FS_ButagazAssistancePrice;
        
        // paymentSpread
        if(oQuote.Market_type__c == 'DOM'){
            if(oQuote.Opportunity.Client_Type__c == 'Renter' && oQuote.Opportunity.T_Pack__c != 'IDEO' && oQuote.Opportunity.T_Pack__c != 'SOLO' && oQuote.Opportunity.T_Pack__c != 'OPTIMO'){
                paymentSpread = System.Label.FS_PaymentSpreadRenterOldContracts;
            }else if( oQuote.Opportunity.Client_Type__c == 'Renter' && (oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO') ){
                paymentSpread = System.Label.FS_PaymentSpreadRenter;
            }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                paymentSpread = System.Label.FS_PaymentSpreadIDEOSOLO;
            }else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                paymentSpread = System.Label.FS_PaymentSpreadECOCFT;
            }
        }
        
        // lockedPrice
        if(oQuote.Market_type__c == 'DOM'){
            boolean bLockedPrice = false;
            if(oQuote.Opportunity.T_Pack__c == 'ECOCFT' || oQuote.Opportunity.Client_Type__c == 'Renter'){
                lockedPrice = System.Label.FS_NotAffected;
            }else{
                // Check if there is a Locked Price
                for(quotelineitem oqli:quotelineitemList){
                    if(!oqli.Deconsignation__c && oqli.F_Product_Code__c == 'SPPABO0012'){
                        amountofLockedPrice = oqli.Price_List_TTC__c * 12;
                        lockedPrice = String.valueOf(amountofLockedPrice.setScale(2)) + ' ' + System.Label.FS_Euro;
                        bLockedPrice = true;
                        break;
                    }
                }
                
                // If no Locked Price, then NotSubscribed
                if(!bLockedPrice){
                    lockedPrice = System.Label.FS_NotSubscribed;
                }
            }
        }
        
        // connectedGaugeSupplyAndInstallation
        boolean bConnectedGaugeSupplyAndInstallation = false;
        if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            connectedGaugeSupplyAndInstallationList.add(System.Label.FS_IncludedInMonthlyPayment);
        }else{
            // Check if there is the connectedGaugeSupplyAndInstallation product
            for(String qptl:qptlList){
                for(quotelineitem oqli:quotelineitemList){
                    if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && oqli.F_Product_Code__c == 'S000000174'){
                        if(oQuote.Market_type__c == 'DOM'){
                            connectedGaugeSupplyAndInstallationList.add(String.valueOf(oqli.Price_List_TTC__c.setScale(2))  + ' ' + System.Label.FS_Euro);
                            amountofGaugeSupplyAndInstallation += oqli.Price_List_TTC__c;
                        }else if(oQuote.Market_type__c == 'PRO'){
                            connectedGaugeSupplyAndInstallationList.add(String.valueOf(oqli.Price_List_HT__c.setScale(2))  + ' ' + System.Label.FS_Euro);
                            amountofGaugeSupplyAndInstallation += oqli.Price_List_HT__c;
                        }
                        bConnectedGaugeSupplyAndInstallation = true;
                    }
                }
            }
            
            // If no Locked Price, then NotSubscribed
            if(!bConnectedGaugeSupplyAndInstallation){
                connectedGaugeSupplyAndInstallationList.add(System.Label.FS_NotSubscribed);
            }
        }
        
        // connectedGaugeMonthlySubscription
        boolean bConnectedGaugeMonthlySubscription = false;
        if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            //connectedGaugeMonthlySubscriptionList.add(System.Label.FS_IncludedInMonthlyPayment);
            connectedGaugeMonthlySubscription = System.Label.FS_IncludedInMonthlyPayment;
        }else{
            // Check if there is the connectedGaugeSupplyAndInstallation product
            for(String qptl:qptlList){
                for(quotelineitem oqli:quotelineitemList){
                    if(oqli.Quote_PTL__r.Name == qptl && !oqli.Deconsignation__c && oqli.F_Product_Code__c == 'SPPABO0019'){
                        if(oQuote.Market_type__c == 'DOM'){
                            amountofconnectedGaugeMonthlySubscription += oqli.Price_List_TTC__c * 12;
                        }else if(oQuote.Market_type__c == 'PRO'){
                            amountofconnectedGaugeMonthlySubscription += oqli.Price_List_HT__c * 12;
                        }
                        //connectedGaugeMonthlySubscriptionList.add(String.valueOf(oqli.Price_List_TTC__c)  + ' ' + System.Label.FS_EuroPerMonth);
                        connectedGaugeMonthlySubscription = String.valueOf(amountofconnectedGaugeMonthlySubscription.setScale(2))  + ' ' + System.Label.FS_Euro;
                        bConnectedGaugeMonthlySubscription = true;
                    }
                }
            }
            
            // If no Locked Price, then NotSubscribed
            if(!bConnectedGaugeMonthlySubscription){
                //connectedGaugeMonthlySubscriptionList.add(System.Label.FS_NotSubscribed);
                connectedGaugeMonthlySubscription = System.Label.FS_NotSubscribed;
            }
        }
        
        
        //System.debug(logginglevel.WARN,'### tankMaintenanceAndUpkeepPrice = ' + tankMaintenanceAndUpkeepPrice);
        //if(String.isBlank(tankMaintenanceAndUpkeepPrice)) tankMaintenanceAndUpkeepPrice = String.valueOf(amountofTankMaintenanceAndUpkeepPrice) + ' ' + System.Label.FS_EuroPerMonth;
        //if(String.isBlank(tankRemovalOrMovingPrice)) tankRemovalOrMovingPrice = String.valueOf(amountofTankRemovalOrMovingPrice) + ' ' + System.Label.FS_Euro;
        //if(String.isBlank(tankNeutralizationPrice))   tankNeutralizationPrice = String.valueOf(amountofTankNeutralizationPrice) + ' ' + System.Label.FS_Euro;
        //if(String.isBlank(pumpingPriceAtClient)) pumpingPriceAtClient = String.valueOf(amountofPumpingPriceAtClient) + ' ' + System.Label.FS_EuroPumpingAtClient;
        //if(String.isBlank(pumpingPriceAtWorkshop)) pumpingPriceAtWorkshop = String.valueOf(amountofPumpingPriceAtWorkshop) + ' ' + System.Label.FS_EuroPumpingAtWorkshop;
        //if(String.isBlank(penaltyAfterInstallPrice)) penaltyAfterInstallPrice = String.valueOf(amountofPenaltyAfterInstallPrice) + ' ' + System.Label.FS_EuroPenaltyAfterInstall;
        
        
        feedTankListsWithTankNumber();
        
        
        // estimatedConsumption
        Set<String> qptlSet = new Set<String>();
        double sumEstimatedConsumption = 0;
        
        for(quotelineitem oqli:quotelineitemList){
            if(!qptlSet.Contains(oqli.Quote_PTL__r.Name)){  // We want to count each QPTL consumption only once
                sumEstimatedConsumption += oqli.Quote_PTL__r.Estimated_Consumption__c;
                qptlSet.add(oqli.Quote_PTL__r.Name);
            }
        }
        estimatedConsumption = String.valueOf(sumEstimatedConsumption) + (oQuote.Opportunity.T_Pack__c == 'ECOCFT' ? ' kWh' : ' T');
        
        
        // Sum of fees for the contract duration : sumOfFeesOverContractDuration
        if(oQuote.Opportunity.Client_Type__c == 'Renter'){
            sumOfFeesOverContractDuration = System.Label.FS_NotAffected;
        }else if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            // only tankRemovalOrMovingPrice
            amountofSumOfFeesOverContractDuration = amountofTankRemovalOrMovingAtContractStartPrice + amountofTankRemovalOrMovingAtContractEndPrice;
            sumOfFeesOverContractDuration = String.valueOf(amountofSumOfFeesOverContractDuration.setScale(2)) + ' ' + System.Label.FS_Euro;
        }else if( (oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO') || oQuote.Market_type__c == 'PRO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
            amountofSumOfFeesOverContractDuration = amountofTankInstallationPrice + ((amountofTankMaintenanceAndUpkeepPrice - (amountofRebatesOnAbonnement_RCom * 12)) * Decimal.valueOf(oQuote.Contract_Duration__c)) + amountofFeesPrice + ((amountofLockedPrice + amountofconnectedGaugeMonthlySubscription) * Decimal.valueOf(oQuote.Contract_Duration__c)) + amountofGaugeSupplyAndInstallation + amountofTankRemovalOrMovingAtContractStartPrice + (oQuote.Opportunity.T_Pack__c == 'SOLO' ? 0 : amountofTankRemovalOrMovingAtContractEndPrice);
            sumOfFeesOverContractDuration = String.valueOf(amountofSumOfFeesOverContractDuration.setScale(2)) + ' ' + System.Label.FS_Euro;
        }
        
        // Annual price estimate : annualCostEstimate
        /*if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            amountofAnnualCostEstimate = (amountofEcocftMonthlyPrice * (12 - ecocftOfferedMonths)) + (amountofSumOfFeesOverContractDuration / Double.valueOf(oQuote.Contract_Duration__c));
        }else if(oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO' || oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
            // ((Prix du produit – les remises éventuelles sur le gaz) x consommation estimée annuelle) + (somme des frais sur durée du contrat calculé au-dessus / durée du contrat)
            amountofAnnualCostEstimate = ((amountofGplPricePerTon - 1) * sumEstimatedConsumption) + (amountofSumOfFeesOverContractDuration / Double.valueOf(oQuote.Contract_Duration__c));
        }
        annualCostEstimate = String.valueOf(amountofAnnualCostEstimate);*/
        
        rebatesIncluded = false;
        if(amountofRebatesOnGpl_RCE > 0 || amountofRebatesOnGpl_RCom > 0 || amountofRebatesOnGpl_RConj > 0){
            rebatesIncluded = true;
        }
        
        // Split total for each year of contract
        decimal rceToSubstract = 0;
        decimal nbMonthsRConj = rebatesOnGpl_RConjMonths;
        decimal rconjRebateForThisYear = 0;
        decimal finalAmountofGplPricePerTon = 0;
        decimal nbEcocftOfferedMonths = ecocftOfferedMonths;
        decimal amountofTankMaintenanceAndUpkeepPriceToSubstract = 0;
        
        for(Integer i = 1; i <= Double.valueOf(oQuote.Contract_Duration__c); i++){
            
            // Manage different price in case of Prix Fixe
            if(fixedPriceNbYear != null && fixedPriceNbYear > 0){
                if(i <= fixedPriceNbYear){
                    finalAmountofGplPricePerTon = amountofGplPricePerTon;
                }else{
                    finalAmountofGplPricePerTon = amountofGplNormalPricePerTon - amountofRebatePostOffre;
                }
            }else{
                finalAmountofGplPricePerTon = amountofGplPricePerTon;
            }
            
            // Substract RCE on the 1st year
            if(i == 1){
                rceToSubstract = amountofRebatesOnGpl_RCE;
            }else{
                rceToSubstract = 0;
            }
            System.debug(logginglevel.WARN,'### rceToSubstract = ' + rceToSubstract);
            
            // Break down RConj on the different years
            // rconjRebateForThisYear = amountofRebatesOnGpl_RConj * (nbMonthsRConj / 12 > 1 ? 12 : nbMonthsRConj);  // To Do : Don't multiply by nbMonthsRConj
            rconjRebateForThisYear = (nbMonthsRConj > 0 ? amountofRebatesOnGpl_RConj : 0);
            nbMonthsRConj = nbMonthsRConj / 12 > 1 ? nbMonthsRConj - 12 : nbMonthsRConj - nbMonthsRConj;
            
            // Manage ecocftOfferedMonths for the 1st year
            if(i > 1){
                nbEcocftOfferedMonths = 0;
            }
            
            if(oQuote.Action_Commerciale__c != null && oQuote.Action_Commerciale__r.Offered_Months__c != null && oQuote.Action_Commerciale__r.Offered_Months__c != 0){
                if(i == 1){
                    amountofTankMaintenanceAndUpkeepPriceToSubstract =amountofTankMaintenanceAndUpkeepPrice  / 12 * oQuote.Action_Commerciale__r.Offered_Months__c  ;
                }else{
                    amountofTankMaintenanceAndUpkeepPriceToSubstract = 0;
                }
            }
            
            if(oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
                amountofAnnualCostEstimate = (amountofEcocftMonthlyPrice * (12 - nbEcocftOfferedMonths)) + (amountofSumOfFeesOverContractDuration / Double.valueOf(oQuote.Contract_Duration__c));
            }else if( (oQuote.Opportunity.T_Pack__c == 'IDEO' || oQuote.Opportunity.T_Pack__c == 'SOLO') || oQuote.Opportunity.Client_Type__c == 'Renter' || oQuote.Market_type__c == 'PRO'|| oQuote.Opportunity.T_Pack__c == 'OPTIMO'){
                // ((Prix du produit – les remises éventuelles sur le gaz) x consommation estimée annuelle) + (somme des frais sur durée du contrat calculé au-dessus / durée du contrat)
                System.debug(logginglevel.WARN,'### finalAmountofGplPricePerTon = ' + finalAmountofGplPricePerTon);
                System.debug(logginglevel.WARN,'### amountofRebatesOnGpl_RCom = ' + amountofRebatesOnGpl_RCom);
                System.debug(logginglevel.WARN,'### rconjRebateForThisYear = ' + rconjRebateForThisYear);
                System.debug(logginglevel.WARN,'### sumEstimatedConsumption = ' + sumEstimatedConsumption);
                System.debug(logginglevel.WARN,'### amountofSumOfFeesOverContractDuration = ' + amountofSumOfFeesOverContractDuration);
                System.debug(logginglevel.WARN,'### oQuote.Contract_Duration__c = ' + oQuote.Contract_Duration__c);
                amountofAnnualCostEstimate = ((finalAmountofGplPricePerTon - (amountofRebatesOnGpl_RCom / cptProductLines) - (rconjRebateForThisYear / cptProductLines)) * sumEstimatedConsumption) + (amountofSumOfFeesOverContractDuration / Double.valueOf(oQuote.Contract_Duration__c));
            }
            
            //annualCostEstimateList.add('Année ' + i + ' : ' + String.valueOf( (amountofAnnualCostEstimate / Decimal.valueOf(oQuote.Contract_Duration__c)).setScale(2) ) + ' ' + System.Label.FS_Euro + '<br/>');
            //annualCostEstimateList.add(String.valueOf( ( (amountofAnnualCostEstimate / Decimal.valueOf(oQuote.Contract_Duration__c)) - rceToSubstract ).setScale(2) ));
            annualCostEstimateList.add(String.valueOf( (amountofAnnualCostEstimate - rceToSubstract - amountofTankMaintenanceAndUpkeepPriceToSubstract).setScale(2) ));
        }
        
        integer indexStart = 0;
        for(Integer i = 0; i <= annualCostEstimateList.size() - 1; i++){
            if(i > 0 && annualCostEstimateList[i] != annualCostEstimateList[i - 1]){
                string strYears = '';
                for(Integer ii = indexStart; ii <= i - 1; ii++){
                    strYears += String.valueOf(ii + 1) + ',';
                }
                strYears = strYears.removeEnd(',');
                finalAnnualCostEstimateList.add(System.Label.FS_FinalAnnualCostEstimatePrefix + ' ' + strYears + ' : ' + String.valueOf(annualCostEstimateList[i - 1]) + ' ' + System.Label.FS_Euro + '<br/>');
                
                //finalAnnualCostEstimateList.add('Année ' + i + ' : ' + String.valueOf( (amountofAnnualCostEstimate / Decimal.valueOf(oQuote.Contract_Duration__c)).setScale(2) ) + ' ' + System.Label.FS_Euro + '<br/>');
                indexStart = i;
            }
        }
        if(indexStart == 0){  // if same amount for all years, we don't want to display any specific text
            finalAnnualCostEstimateList.add(String.valueOf(annualCostEstimateList[0]) + ' ' + System.Label.FS_Euro);
        }else{
            finalAnnualCostEstimateList.add(System.Label.FS_FinalAnnualCostEstimatePrefixLast + ' ' + String.valueOf(annualCostEstimateList[annualCostEstimateList.size() - 1]) + ' ' + System.Label.FS_Euro);
        }
        
        
        return '';
    }
    
    public string getDateOfValidityOfTheOffer(){
        String strdt = '';
        if(oQuote.Market_type__c == 'DOM'){
            /* Date of validity of the offer must be set to the last day of the current month */
            Date dtDOM = System.today().addMonths(1).toStartofMonth().addDays(-1);
            strdt = dtDOM.format();
        }else if(oQuote.Market_type__c == 'PRO'){
            /* Date of validity of the offer must be set to the ninth day of the next month */
            Date dtPRO = System.today().addMonths(1).toStartofMonth().addDays(8);
            strdt = dtPRO.format();
        }
        return strdt;
    }
    
    // Add tank number to each item of each list if more than 1 item in the list
    public void feedTankListsWithTankNumber(){
        
        integer cpt = 0;
        
        //tankCharacteristicsList = new List<String>(tankCharacteristicsSet);
        //tankCharacteristicsList.sort();
        
        if(tankCharacteristicsList.size()>1){
            for(String tank:tankCharacteristicsList){
                tankCharacteristicsList.set(cpt, tankCharacteristicsList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(tankPropertyList.size()>1){
            for(String tank:tankPropertyList){
                tankPropertyList.set(cpt, tankPropertyList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(tankInstallationPriceList.size()>1){
            for(String tank:tankInstallationPriceList){
                tankInstallationPriceList.set(cpt, tankInstallationPriceList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(warrantyDepositPriceList.size()>1){
            for(String tank:warrantyDepositPriceList){
                warrantyDepositPriceList.set(cpt, warrantyDepositPriceList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        /*cpt = 0;
        if(tankMaintenanceAndUpkeepPriceList.size()>1){
            for(String tank:tankMaintenanceAndUpkeepPriceList){
                tankMaintenanceAndUpkeepPriceList.set(cpt, tankMaintenanceAndUpkeepPriceList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }*/
        
        cpt = 0;
        if(tankRemovalOrMovingAtContractEndPriceList.size()>1){
            for(String tank:tankRemovalOrMovingAtContractEndPriceList){
                tankRemovalOrMovingAtContractEndPriceList.set(cpt, tankRemovalOrMovingAtContractEndPriceList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(tankNeutralizationPriceList.size()>1){
            for(String tank:tankNeutralizationPriceList){
                tankNeutralizationPriceList.set(cpt, tankNeutralizationPriceList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(pumpingPriceAtClientList.size()>1){
            for(String tank:pumpingPriceAtClientList){
                pumpingPriceAtClientList.set(cpt, pumpingPriceAtClientList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(pumpingPriceAtWorkshopList.size()>1){
            for(String tank:pumpingPriceAtWorkshopList){
                pumpingPriceAtWorkshopList.set(cpt, pumpingPriceAtWorkshopList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        cpt = 0;
        if(connectedGaugeSupplyAndInstallationList.size()>1){
            for(String tank:connectedGaugeSupplyAndInstallationList){
                connectedGaugeSupplyAndInstallationList.set(cpt, connectedGaugeSupplyAndInstallationList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }
        
        /*cpt = 0;
        if(connectedGaugeMonthlySubscriptionList.size()>1){
            for(String tank:connectedGaugeMonthlySubscriptionList){
                connectedGaugeMonthlySubscriptionList.set(cpt, connectedGaugeMonthlySubscriptionList[cpt] + ' (cit' + String.valueOf(cpt+1) + ')<br/>');
                cpt ++;
            }
        }*/
        
        
    }
    
}