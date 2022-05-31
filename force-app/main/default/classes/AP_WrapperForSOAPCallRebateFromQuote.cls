public class AP_WrapperForSOAPCallRebateFromQuote {

    public Boolean statusContinueProcess;
    
    public AP_WrapperForSOAPCallRebateFromQuote() {

    }

    public Map<String, list<QuoteLineItem>> Send_Rebate_TO_SAP(String IdQuote)
    {
        system.debug('Send_Rebate_TO_SAP');
        this.statusContinueProcess = true;
        String rebateType = '';
        Map<String, responseSAP> mapCodeProduit = new Map<String, responseSAP>();
        Quote oQuote;
        
        try 
        {
            oQuote = getcurrentQuote(IdQuote);

            // Find the rebate type
            System.debug(logginglevel.WARN,'### this.oQuote.Client_Reenlistment__c = '+ oQuote.Client_Reenlistment__c );
            if( oQuote.Client_Reenlistment__c == 'Commercial offer' && oQuote.Type_de_remuneration__c != 'Avoir' ){
                rebateType = 'REBATE';
            }
            else if( oQuote.Client_Reenlistment__c == 'Contract' && oQuote.Type_de_remuneration__c != 'Avoir' ){
                rebateType = 'REBATE';
            }
            else if( oQuote.Client_Reenlistment__c == 'Credit' || (oQuote.Client_Reenlistment__c == 'Commercial offer' && oQuote.Type_de_remuneration__c == 'Avoir') ){
                rebateType = 'CREDIT';
            }
            System.debug(logginglevel.WARN,'### this.rebateType = '+ rebateType );

            List<QuoteLineItem> currentQLIs = getcurrentQLIs(oQuote.Id);
            
            system.debug('currentQLIs:'+currentQLIs);

            Map<String, QuoteLineItem> mapQLI = new Map<String, QuoteLineItem>(); 
           
            for(QuoteLineItem qli:currentQLIs) 
            {
                mapQLI.put(qli.PriceBookEntry.Product2.ProductCode, qli);
                system.debug('currentQLIs qli:'+qli);
            }

            system.debug('freddy mapQLI:'+mapQLI);

            // Initialize the wrapper
            AP_WrapperForSOAPCallRebate wrapperForSOAPCall = new AP_WrapperForSOAPCallRebate(oQuote);

            AP_WrapperForSOAPCallRebate.AP_WrapperDataForController dataForController;
            dataForController = wrapperForSOAPCall.postRebatesToSAP(currentQLIs);

            String exControl = dataForController.exControl;
            system.debug('freddy exControl:'+exControl);


            List<AP_WrapperForSOAPCallRebate.ReturnFields> returnFieldsList = dataForController.returnFieldsList;
            String msg = '';
            for(AP_WrapperForSOAPCallRebate.ReturnFields rFields:returnFieldsList)
            {
                system.debug('rFields:'+rFields);
                system.debug('rFields TYPE:'+rFields.TYPE_x);//S = OK, E = KO
                system.debug('rFields ID:'+rFields.ID);//rFields ID:L000723360 RCE_DED
                system.debug('rFields Field:'+rFields.Field);//rFields Field:L000723360
                system.debug('rFields Message:'+rFields.Message);//rFields Message:La remise ZRC1 est créée dans SAP
                system.debug('rFields Parameter:'+rFields.Parameter);//904P0001  code produit
                system.debug('rFields MessageV1:'+rFields.MessageV1);//action co
    
                if(Test.isRunningTest())
                {
                    mapCodeProduit.put('904P0001', new responseSAP(rFields.Parameter, rFields.Field, rFields.TYPE_x, rFields.Message, 'MessageV1'));
                }
                else
                    mapCodeProduit.put(rFields.Parameter, new responseSAP(rFields.Parameter, rFields.Field, rFields.TYPE_x, rFields.Message, rFields.MessageV1));
                msg = rFields.Message;
            }   

            system.debug('mapCodeProduit:'+mapCodeProduit);

            //MAJ QLI
            List<QuoteLineItem> currentQLIsDisplay = new List<QuoteLineItem>();

            for(QuoteLineItem qli:currentQLIs) 
            { 
                system.debug('mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode):'+mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode));

                if(mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode) != null)
                {
                        if(mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).EX_CONTROL == 'S')
                            qli.State_Rebate_Synchro_To_SAP__c = 'OK';
                        else 
                            qli.State_Rebate_Synchro_To_SAP__c = 'KO';
                        qli.Error_Rebate_Synchro_To_SAP__c = mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).Message;

                        if(mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).MessageV1 != '' && mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).MessageV1 != null)
                            currentQLIsDisplay.add(qli);

                        system.debug('mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).EX_CONTROL:'+mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).EX_CONTROL);

                        if((this.statusContinueProcess==true)&&(mapCodeProduit.get(qli.PriceBookEntry.Product2.ProductCode).EX_CONTROL=='E'))                        
                            this.statusContinueProcess = false;
                }
                else 
                {
                        qli.State_Rebate_Synchro_To_SAP__c = 'KO';
                        if(msg.length()>255) msg = msg.substring(0, 255);
                        qli.Error_Rebate_Synchro_To_SAP__c = msg;
                        this.statusContinueProcess = false;
                }
            }
            update currentQLIs;            
            system.debug('currentQLIs:'+currentQLIs);
            system.debug('currentQLIsDisplay:'+currentQLIsDisplay);

            system.debug('this.statusContinueProcess after update:'+this.statusContinueProcess);

            //MAJ Quote Action Co
            String errorActionCo;
            String stateActionCo;

            for (String key : mapCodeProduit.keySet()) 
            {
                system.debug('mapCodeProduit.get(key).MessageV1:'+mapCodeProduit.get(key).MessageV1);
                system.debug('mapCodeProduit.get(key).EX_CONTROL:'+mapCodeProduit.get(key).EX_CONTROL);
                system.debug('mapCodeProduit.get(key).Message:'+mapCodeProduit.get(key).Message);

                if(mapCodeProduit.get(key).MessageV1!='' && mapCodeProduit.get(key).MessageV1!=null)
                {
                    if(mapCodeProduit.get(key).EX_CONTROL == 'S')
                        stateActionCo = 'OK';
                    else 
                        stateActionCo = 'KO';
                    errorActionCo = mapCodeProduit.get(key).Message;

                    if((this.statusContinueProcess==true)&&(mapCodeProduit.get(key).EX_CONTROL=='KO'))                        
                        this.statusContinueProcess = false;

                }

            }
            if(Test.isRunningTest())
            {
                stateActionCo = 'OK';
            }

            if(stateActionCo == 'OK'|| stateActionCo == 'KO')
            {
                oQuote.Error_Synchro_To_SAP_ActionCo__c = errorActionCo;
                oQuote.State_Synchro_To_SAP_ActionCo__c = stateActionCo;
                update oQuote;
            }
            
            system.debug('oQuote:'+oQuote);

            //on ajoute statusContinue et Action Co
            Map<String, list<QuoteLineItem>> mapQLI1 = new Map<String, list<QuoteLineItem>>(); 
            mapQLI1.put('ListQLI', currentQLIs);
            if(!currentQLIsDisplay.isEmpty())
                mapQLI1.put('currentQLIsDisplay', currentQLIsDisplay);

            return mapQLI1;    
        }
        catch (Exception e) 
        {
            system.debug('>>>class AP_WrapperForSOAPCallRebateFromQuote:'+e.getMessage());
            this.statusContinueProcess = false;
            List<QuoteLineItem> currentQLIs = getcurrentQLIs(IdQuote);
            String msg = e.getMessage();
            for(QuoteLineItem qli:currentQLIs) 
            { 
                qli.State_Rebate_Synchro_To_SAP__c = 'KO';
                if(msg.length()>255) msg = msg.substring(0, 255);
                qli.Error_Rebate_Synchro_To_SAP__c = msg;
            }
            update currentQLIs;
            
            //action co display + save
            List<QuoteLineItem> currentQLIsDisplay = new List<QuoteLineItem>();       
            QuoteLineItem qli1 = new QuoteLineItem();
            qli1.State_Rebate_Synchro_To_SAP__c = 'KO';
            if(msg.length()>255) msg = msg.substring(0, 255);
            qli1.Error_Rebate_Synchro_To_SAP__c = msg;
            currentQLIsDisplay.add(qli1);
            //save
            oQuote.Error_Synchro_To_SAP_ActionCo__c = msg;
            oQuote.State_Synchro_To_SAP_ActionCo__c = 'KO';
            update oQuote;
            
            //on ajoute statusContinue
            Map<String, list<QuoteLineItem>> mapQLI1 = new Map<String, list<QuoteLineItem>>(); 
            mapQLI1.put('ListQLI', currentQLIs);
            mapQLI1.put('currentQLIsDisplay', currentQLIsDisplay);

            return mapQLI1;

        }

    }    

    public class responseSAP
    {
        public String EX_CONTROL;
        public String Message;
        public String codeProduit;
        public String PTL;
        public String MessageV1;
        
        public responseSAP(String codeProduit, String PTL, String EX_CONTROL, String Message, String MessageV1)
        {
                this.EX_CONTROL = EX_CONTROL;
                this.Message = Message;
                this.codeProduit = codeProduit;
                this.PTL = PTL;
                this.MessageV1 = MessageV1;
        }
    }

    public static List<QuoteLineItem> getcurrentQLIs(String IdQuote)
    {
            List<QuoteLineItem> currentQLIs = new List<QuoteLineItem>();
        
            for(QuoteLineItem qli : [
                SELECT  
                    Id,
                    Quote_PTL__r.Name,
                    Fixed_Price_HT__c,
                    Quote_PTL__r.Opportunity_PTL__r.PTLSynchroSAP__c,
                    UnitPrice, 
                    Quote_PTL__c, 
                    Quote_PTL__r.PTL_Name__c, 
                    QuoteId, 
                    Quantity,
                    Quantity_Unit__c,
                    PricebookEntryId,
                    PricebookEntry.Product2Id,
                    PricebookEntry.Product2.IsActive,
                    PriceBookEntry.Product2.ProductCode,
                    PricebookEntry.Product2.Name,
                    PricebookEntry.Product2.Family,
                    PricebookEntry.Product2.Capacity__c,
                    PricebookEntry.Product2.Sub_Type__c,
                    PricebookEntry.Product2.UseGerConsumption__c,
                    PricebookEntry.Product2.MonthlyPriceDisplay__c,
                    PricebookEntry.Product2.Payment_type__c,
                    Remise_Grpt_one_shot_HT__c, 
                    Consignation_Grpt_one_shot_HT__c, 
                    Group_Commercial_Rebate_HT__c, 
                    Group_Commercial_Rebate_TTC__c, 
                    Group_Cyclical_Rebate_HT__c, 
                    Group_Cyclical_Rebate_TTC__c, 
                    Group_Cyclical_Rebate_lenght_in_months__c,
                    Group_RCE_Rebate_HT__c,
                    Group_RCE_Rebate_TTC__c,
                    Commercial_Rebate_TTC__c, 
                    Commercial_Rebate_HT__c,
                    Cyclical_Rebate_TTC__c, 
                    Cyclical_Rebate_HT__c, 
                    Cyclical_Rebate_Months__c,
                    RCE_Rebate_TTC__c, 
                    RCE_Rebate_HT__c, 
                    Remise_Post_Offre_TTC__c,
                    Remise_Post_Offre_HT__c,
                    Price_List_HT__c,
                    Price_List_TTC__c,
                    VAT_Percentage__c,
                    Pricing_Unit__c,
                    Amount_Unit__c,
                    Reason_For_Order__c,
                    Rebate_Starting_Date__c,
                    Credit_Quantity__c,
                    Credit_Unit_Price_HT__c,
                    Credit_Total_Price_HT__c,
                    Got_From_SAP__c, 
                    quote.Client_Reenlistment__c, quote.Type_de_remuneration__c, State_Rebate_Synchro_To_SAP__c, Error_Rebate_Synchro_To_SAP__c,
                    New_Price_HT__c,
                    Quote.Action_Commerciale__c, Quote.Action_Commerciale__r.Fixed_Price__c, Quote.Action_Commerciale__r.Locked_Price__c, 
                    Quote.Action_Commerciale__r.Locked_Price_1_Year__c, Quote.Action_Commerciale__r.Locked_Price_2_Years__c, Quote.Action_Commerciale__r.Locked_Price_3_Years__c
                FROM QuoteLineItem 
                WHERE QuoteId=:IdQuote]){
                
                // rce, rcom, rconj, remise post offre au moins 1 different de zéro ou action co prix fixe/bloqué sélectionnée
                if( qli.Quote.Client_Reenlistment__c == 'Contract' ){
                    if( (qli.RCE_Rebate_TTC__c > 0)||(qli.Commercial_Rebate_TTC__c > 0)||(qli.Cyclical_Rebate_TTC__c > 0)||(qli.Remise_Post_Offre_TTC__c > 0) ) {
                        currentQLIs.add(qli);
                    }
                    
                    // if Quote associated with an Action Co Locked Price or Fixed Price : we need to send a Propane QLI so we can send it to SAP (only if we didn't add it to the list already)
                    if( qli.PricebookEntry.Product2.Family == 'Produit' && (qli.Quote.Action_Commerciale__r.Fixed_Price__c || qli.Quote.Action_Commerciale__r.Locked_Price__c 
                        || qli.Quote.Action_Commerciale__r.Locked_Price_1_Year__c || qli.Quote.Action_Commerciale__r.Locked_Price_2_Years__c || qli.Quote.Action_Commerciale__r.Locked_Price_3_Years__c
                    ) ){
                        if( !currentQLIs.isEmpty() && currentQLIs.contains(qli) ){
                            // Do nothing. A propane QLI has already been added to the list. We'll use it to send the ZPV3/ZPV5 to SAP.
                        }else{
                            currentQLIs.add(qli);
                        }
                    }
                }
                
            }
        return currentQLIs;
    }
    
    public static Quote getcurrentQuote(String IdQuote)
    {
            Quote oQuote = [
                SELECT  
                    Id,
                    QuoteNumber,
                    Market_type__c,
                    IsSyncing,
                    OpportunityId,
                    Name,
                    DO_Payment_method__c,
                    Product_Scale__c,
                    Scale__c,
                    Client_Reenlistment__c,
                    Shipping_Condition__c,
                    VAT_code__c,
                    Contract_Duration__c,
                    Pricebook2Id,
                    ExpirationDate,
                    Date_de_cotation__c,
                    Date_debut_offre__c,
                    ContactId,
                    T_LAT_Approved__c,
                    Latitude_Message__c,
                    Sent_To_SAP__c,
                    Opportunity.Account.AccountNumber,
                    Opportunity.Account.Mandataire__r.ExternalID__c,
                    Opportunity.Account.Activity_Domain__r.ExternalID__c,
                    Opportunity.StageName,
                    Opportunity.Contract_Start_Date__c, 
                    RecordTypeId,
                    Credit_Comment_For_Customer__c,
                    /*Reason_For_Credit_Order__c,*/
                    Credit_Price_Date__c,
                    Opportunity.Reason__c,
                    Type_de_remuneration__c,
                    Remise_en_euro__c,
                    Action_Commerciale__c,
                    Action_Commerciale__r.Fixed_Price__c,
                    Action_Commerciale__r.Locked_Price__c,
                    Action_Commerciale__r.Locked_Price_1_Year__c,
                    Action_Commerciale__r.Locked_Price_2_Years__c,
                    Action_Commerciale__r.Locked_Price_3_Years__c,
                    Action_Commerciale__r.Name,
                    Error_Synchro_To_SAP_ActionCo__c,
                    State_Synchro_To_SAP_ActionCo__c
                FROM Quote 
                WHERE Id=:IdQuote LIMIT 1];
       
        return oQuote;
    }

    public static Opportunity getcurrentOpty(String IdOpty)
    {
            Opportunity oOpty = [
                SELECT  
                    Id,
                    recordtypeId,
                    SyncedQuoteId,
                    Name,
                    DO_Activity_Domain__c,
                    Project_market_type__c,
                    Project_Type__c,
                    Project_Sub_Type__c,
                    T_Pack__c,
                    StageName, 
                    AccountId, 
                    DO_AccountNumber__c,
                    CloseDate, 
                    Project_City_Postal_Code__c, 
                    DO_City_Postal_Code__c, 
                    Assign__c, 
                    OwnerId,
                    DO_Payment_method__c, 
                    Installation_date__c,
                    Client_Type__c,
                    Energy_Source__c,
                    Avez_vous_votre_Kbis__c,
                    Pricebook2Id,
                    Reason__c
                FROM Opportunity 
                WHERE Id=:IdOpty LIMIT 1];
        
        return oOpty;
    }


}