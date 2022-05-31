public class AP_WrapperForSOAPCallOrder {

    public Boolean statusContinueProcess;
    //public BAPITracker__c oBapiTracker {get;set;}
    public list<BAPITracker__c> loBapiTracker {get;set;}
    public String sStoreTracker {get;set;}

    
    public AP_WrapperForSOAPCallOrder() {
    }

    public Map<String, list<QuoteLineItem>> Send_Order_TO_SAP(String IdQuote, matriceSAP currentMatriceSAP)
    {
        system.debug('Send_Order_TO_SAP');
        //this.oBapiTracker = new BAPITracker__c();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');
        this.statusContinueProcess = true;
        this.loBapiTracker = new list<BAPITracker__c>(); 
        Map<String, responseSAP> lIdQuoteLineItem = new Map<String, responseSAP>();
        list<QuoteLineItem> lQuoteLineItem = new list<QuoteLineItem>();
        list<Quote> q = new list<Quote>();
        list<Quote_PTL__c> lQPTL = new list<Quote_PTL__c>();
        Boolean IsException = false;
        Boolean originalBypassVRvalue;
        Boolean originalBypassWFvalue;
        Boolean originalBypassEmailNoEmailvalue;
        String errorMessage = '';
        list<String> lQPTLId = new list<String>();
        microsoftLobservicesSapCOMMANDES.RfcEndpoint callBAPI = new microsoftLobservicesSapCOMMANDES.RfcEndpoint();
        microsoftLobservicesSapCOMMANDESRfc.ZBAPI_CRM_COMMANDEResponse_element response = new microsoftLobservicesSapCOMMANDESRfc.ZBAPI_CRM_COMMANDEResponse_element();
        Map<String, list<QuoteLineItem>> mapQLI = new Map<String, list<QuoteLineItem>>(); 
        
        try 
        {
           
            //DEVIS (bareme produit, type de marché)
            q = [select Id, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
                            Client_Type__c, Account.name, account.salutation, Market_type__c, opportunity.Account.Activity_Domain__r.ExternalID__c,
                            Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, Product_Scale_Code__c, 
                            Shipping_Condition__c, Facturation_calendar__c, DO_Payment_method__c, 
                            Opportunity.DO_Accounting_Manager__r.Code__c, Opportunity.Account_Payer__r.accountnumber, 
                            Opportunity.Contract_Start_Date__c, Opportunity.Account_Billed__r.accountnumber, Opportunity.PA_DO__c, Opportunity.FA_DO__c, Opportunity.DO_Name__c, 
                            Opportunity.DO_Recovery_procedures__c, Payment_spread__c, DO_Groupement__r.accountnumber, Scale__c, account.Salutation__c, Scale_Code__c, 
                            Opportunity.Project_Sub_Type__c, Opportunity.Account.name from Quote where Id= :IdQuote limit 1];

            system.debug('q:'+q);

            if(q.size()>0)
            {
                String action = 'CREA';

                //definition du type de projet
                String typeProjet = (q[0].Project_Type__c  + q[0].Client_Type__c).toUpperCase();
                system.debug('typeProjet:'+typeProjet);

                //DEBUT liste des QPTL associés au devis
                lQPTL = [select Id, name, PTL_Name__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, 
                State_Synchro_To_SAP__c, Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                Opportunity_PTL__r.PTL_MEP_Earliest_Tank_moving_Date__c, Opportunity_PTL__r.PTL_MEP_Latest_Tank_moving_Date_MEP__c 
                from Quote_PTL__c where Quote__c= :q[0].Id];

                //System.debug('lQPTL: '+lQPTL);
                //System.debug('lQPTL.size(): '+lQPTL.size());

                //pour chaque QPTL, on récupère le numero de contrat (ContractSynchroSAP__c) et on créé la commande 
                for(Quote_PTL__c qptl:lQPTL)
                {
                    lQPTLId.clear();
                    lQPTLId.add(qptl.Id);
                    lQuoteLineItem.clear();
                    lQuoteLineItem = [select Id, F_Product_Code__c, Product_Description__c, Sub_Type__c, Tank_Placing_Options__c, State_Synchro_To_SAP__c, 
                                        Error_Synchro_To_SAP__c, OrderSynchroSAP__c from QuoteLineItem where Quote_PTL__c IN :lQPTLId 
                                        AND Sub_Type__c = 'Citerne' AND Tank_Placing_Options__c IN ('MEP', 'DDS') AND Quantity>0];

                    for(QuoteLineItem qli:lQuoteLineItem) 
                    {
                        microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2();
                        microsoftLobservicesSapCOMMANDESTypes.ZBAPI_CRM_COMMANDE_ENTETE IS_COMMANDE = new microsoftLobservicesSapCOMMANDESTypes.ZBAPI_CRM_COMMANDE_ENTETE();
                        system.debug('qli:'+qli);
                        
                        String typeCommande = currentMatriceSAP.cdeMvtCiterne;
                        IS_COMMANDE.DOC_TYPE = typeCommande;

                        system.debug('typeCommande:'+typeCommande);

                        String raisonCdeMvt = currentMatriceSAP.raisonCdeMvt;
                        system.debug('raisonCdeMvt:'+raisonCdeMvt);

                        if(raisonCdeMvt != null)
                            IS_COMMANDE.ORD_REASON = raisonCdeMvt;

                        if(qptl.Opportunity_PTL__r.PTL_MEP_Earliest_Tank_moving_Date__c != null)
                            IS_COMMANDE.REQ_DATE_H = qptl.Opportunity_PTL__r.PTL_MEP_Earliest_Tank_moving_Date__c;
                        else    
                            IS_COMMANDE.REQ_DATE_H = Date.newInstance(1900, 01,01);
    
                        if(qptl.Opportunity_PTL__r.PTL_MEP_Latest_Tank_moving_Date_MEP__c != null)
                            IS_COMMANDE.REQ_DATE = qptl.Opportunity_PTL__r.PTL_MEP_Latest_Tank_moving_Date_MEP__c;
                        else    
                            IS_COMMANDE.REQ_DATE = Date.newInstance(9999, 12, 31);

                        system.debug('IS_COMMANDE.REQ_DATE_H:'+IS_COMMANDE.REQ_DATE_H); 
                        system.debug('IS_COMMANDE.REQ_DATE:'+IS_COMMANDE.REQ_DATE); 
                        /*
                        String oldEndPoint =  callBAPI.endpoint_x;
                        system.debug('Account oldEndPoint:'+oldEndPoint);
                        //appel endpoint trace
                        callBAPI.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
        
                        response = callBAPI.ZBAPI_CRM_COMMANDE(
                            action,
                            null, //String IM_COMMANDE
                            qptl.ContractSynchroSAP__c,//String IM_CONTRAT,
                            typeProjet, //String IM_PROJET,
                            IS_COMMANDE,//microsoftLobservicesSapCOMMANDESTypes.ZBAPI_CRM_COMMANDE_ENTETE IS_COMMANDE,
                            ET_RETURN);//microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2 ET_RETURN)
        
                        //appel SAP
                        callBAPI.endpoint_x = oldEndPoint;
                        */
                        response = callBAPI.ZBAPI_CRM_COMMANDE(
                            action,
                            null, //String IM_COMMANDE
                            qptl.ContractSynchroSAP__c,//String IM_CONTRAT,
                            typeProjet, //String IM_PROJET,
                            IS_COMMANDE,//microsoftLobservicesSapCOMMANDESTypes.ZBAPI_CRM_COMMANDE_ENTETE IS_COMMANDE,
                            ET_RETURN);//microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2 ET_RETURN)
    
                        system.debug('response:'+response);                    
                        errorMessage = '';
                        microsoftLobservicesSapCOMMANDESTypes.ArrayOfBAPIRET2 ET_RETURNSAP = response.ET_RETURN;
                        list<microsoftLobservicesSapCOMMANDESTypes.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;
                        for(microsoftLobservicesSapCOMMANDESTypes.BAPIRET2 b:BAPIRET2)
                            errorMessage = errorMessage +'#'+b.MESSAGE;
                        system.debug('errorMessage:'+errorMessage); 

                        //oBapiTracker
                        BAPITracker__c oBapiTracker = new BAPITracker__c();
                        oBapiTracker.Response1__c = JSON.serialize((response));
                        oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
                        oBapiTracker.Message__c = errorMessage;
                        oBapiTracker.Request__c = callBAPI.request;
                        oBapiTracker.User__c = UserInfo.getUserId() ;
                        this.loBapiTracker.add(oBapiTracker);
    
                        if((this.statusContinueProcess==true)&&(response.EX_CONTROL=='KO'))                        
                            this.statusContinueProcess = false;
    
                        lIdQuoteLineItem.put(qli.Id, new responseSAP(response.EX_CONTROL, response.EX_COMMANDE, errorMessage));
                    }//fin boucle for qli
                }//fin boucle for qptl
                //trace all bapitracker
                if (this.sStoreTracker.toLowercase() == 'true') upsert this.loBapiTracker;

                System.debug('lIdQuoteLineItem:'+lIdQuoteLineItem);

                lQuoteLineItem = [select Id, F_Product_Code__c, Product_Description__c, Sub_Type__c, Tank_Placing_Options__c, State_Synchro_To_SAP__c, 
                Error_Synchro_To_SAP__c, OrderSynchroSAP__c from QuoteLineItem where Id IN :lIdQuoteLineItem.keyset()];
                
                System.debug('lQuoteLineItem 1:'+lQuoteLineItem);
                
                if(lQuoteLineItem.size()>0)
                {
                    //flag bypass VR for true for the user        
                    User userCurrent = [select Id, Bypass_Validation_Rules__c, Bypass_Workflow__c, Bypass_Email_No_Email_Check__c from User where Id= :UserInfo.getUserId()];
                    // Save Bypass fields original values
                    originalBypassVRvalue = userCurrent.Bypass_Validation_Rules__c;
                    originalBypassWFvalue = userCurrent.Bypass_Workflow__c;
                    originalBypassEmailNoEmailvalue = userCurrent.Bypass_Email_No_Email_Check__c;
                    // Set Bypass fields to True
                    userCurrent.Bypass_Validation_Rules__c = true;
                    userCurrent.Bypass_Workflow__c = true;
                    userCurrent.Bypass_Email_No_Email_Check__c = true;
                    update userCurrent;
    
                    //DEBUT MAJ QLI
                    for(QuoteLineItem qli:lQuoteLineItem)
                    {
                        qli.State_Synchro_To_SAP__c = lIdQuoteLineItem.get(qli.Id).EX_CONTROL;
                        if(lIdQuoteLineItem.get(qli.Id).lERROR.length()>255)
                            qli.Error_Synchro_To_SAP__c = lIdQuoteLineItem.get(qli.Id).lERROR.substring(0, 255);
                        else qli.Error_Synchro_To_SAP__c = lIdQuoteLineItem.get(qli.Id).lERROR;
                        qli.OrderSynchroSAP__c = lIdQuoteLineItem.get(qli.Id).EX_COMMANDE;
                    }
                    update lQuoteLineItem;
    
                    // Reset Bypass fields to their original value
                    //userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
                    userCurrent.Bypass_Validation_Rules__c = originalBypassVRvalue;
                    userCurrent.Bypass_Workflow__c = originalBypassWFvalue;
                    userCurrent.Bypass_Email_No_Email_Check__c = originalBypassEmailNoEmailvalue;
                    update userCurrent;
                    
                }   
                else
                {
		            QuoteLineItem qli = new QuoteLineItem();
                    lQuoteLineItem.add(qli);
                }
                
                mapQLI.put('ListQLI', lQuoteLineItem);

            }
            system.debug('mapQLI:'+mapQLI);
            return mapQLI;
        }
        catch (Exception e) {
            this.statusContinueProcess = false;
            system.debug('>>>class AP_WrapperForSOAPCallOrder:'+e.getMessage());
            system.debug('>>>response:'+response);
            //flag bypass VR for true for the user        
            User userCurrent = [select Id, Bypass_Validation_Rules__c, Bypass_Workflow__c, Bypass_Email_No_Email_Check__c from User where Id= :UserInfo.getUserId()];
            // Save Bypass fields original values
            originalBypassVRvalue = userCurrent.Bypass_Validation_Rules__c;
            originalBypassWFvalue = userCurrent.Bypass_Workflow__c;
            originalBypassEmailNoEmailvalue = userCurrent.Bypass_Email_No_Email_Check__c;
            // Set Bypass fields to True
            userCurrent.Bypass_Validation_Rules__c = true;
            userCurrent.Bypass_Workflow__c = true;
            userCurrent.Bypass_Email_No_Email_Check__c = true;
            update userCurrent;

            //DEBUT MAJ QLI
            list<QuoteLineItem> lQuoteLineItem1 = [select Id, F_Product_Code__c, Product_Description__c, Sub_Type__c, Tank_Placing_Options__c, State_Synchro_To_SAP__c, 
                                                    Error_Synchro_To_SAP__c, OrderSynchroSAP__c from QuoteLineItem where Id IN :lIdQuoteLineItem.keyset()];
            system.debug('>>>lQuoteLineItem1:'+lQuoteLineItem1);
            system.debug('>>>lQuoteLineItem1.size():'+lQuoteLineItem1.size());

            if(lQuoteLineItem1.size()!=0)
            {    
                for(QuoteLineItem qli:lQuoteLineItem1)
                {
                    qli.State_Synchro_To_SAP__c = 'KO';
                    qli.Error_Synchro_To_SAP__c = e.getMessage();
                }    
                update lQuoteLineItem1;
            }
            else
            {
                list<String> lQPTLId1 = new list<String>();

                list<Quote_PTL__c> lQPTL1 = [select Id, name, PTL_Name__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, 
                State_Synchro_To_SAP__c, Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                Opportunity_PTL__r.PTL_MEP_Earliest_Tank_moving_Date__c, Opportunity_PTL__r.PTL_MEP_Latest_Tank_moving_Date_MEP__c 
                from Quote_PTL__c where Quote__c= :q[0].Id];

                system.debug('>>>lQuoteLineItem2:'+lQPTL1);
                system.debug('>>>lQuoteLineItem2.size():'+lQPTL1.size());

                
                for(Quote_PTL__c qptl:lQPTL1)
                {
	                system.debug('>>>lQuoteLineItem3:'+qptl);
                    lQPTLId1.add(qptl.Id);
				}
                
                lQuoteLineItem = [select Id, F_Product_Code__c, Product_Description__c, Sub_Type__c, Tank_Placing_Options__c, State_Synchro_To_SAP__c, 
                                        Error_Synchro_To_SAP__c, OrderSynchroSAP__c from QuoteLineItem where Quote_PTL__c IN :lQPTLId1 
                                        AND Sub_Type__c = 'Citerne' AND Tank_Placing_Options__c = 'MEP' AND Quantity>0];

                system.debug('>>>lQuoteLineItem4:'+lQuoteLineItem);

                
                for(QuoteLineItem qli:lQuoteLineItem)
                {
                    qli.State_Synchro_To_SAP__c = 'KO';
                    qli.Error_Synchro_To_SAP__c = e.getMessage();
                }    
                update lQuoteLineItem;
            }
            // Reset Bypass fields to their original value
            //userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
            userCurrent.Bypass_Validation_Rules__c = originalBypassVRvalue;
            userCurrent.Bypass_Workflow__c = originalBypassWFvalue;
            userCurrent.Bypass_Email_No_Email_Check__c = originalBypassEmailNoEmailvalue;
            update userCurrent;

            //oBapiTracker
            BAPITracker__c oBapiTracker = new BAPITracker__c();
            oBapiTracker.Response1__c = JSON.serialize((response));
            oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
            oBapiTracker.Message__c = e.getMessage();
            oBapiTracker.Request__c = callBAPI.request;
            oBapiTracker.User__c = UserInfo.getUserId() ;
            if (this.sStoreTracker.toLowercase() == 'true') upsert oBapiTracker;


            Map<String, list<QuoteLineItem>> mapQLI1 = new Map<String, list<QuoteLineItem>>(); 
            mapQLI1.put('ListQLI', lQuoteLineItem);

            return mapQLI1;
        }

    }

    public class responseSAP
    {
        public String EX_CONTROL;
        public String EX_COMMANDE;
        public String lERROR;
        
        public responseSAP(String EX_CONTROL, String EX_COMMANDE, String lERROR)
        {
                this.EX_CONTROL = EX_CONTROL;
                this.EX_COMMANDE = EX_COMMANDE;
                this.lERROR = lERROR;
        }
    }


}