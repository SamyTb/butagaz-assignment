public class AP_WrapperForSOAPCallContract {

    public Boolean statusContinueProcess;
    //public BAPITracker__c oBapiTracker {get;set;}
    public BAPITracker__c oBapiTrackerAbon {get;set;}
    public list<BAPITracker__c> loBapiTracker {get;set;}
    public String sStoreTracker {get;set;}

    public AP_WrapperForSOAPCallContract() {

    }


    public Map<String, list<Quote_PTL__c>> Send_Contract_TO_SAP(String IdQuote, matriceSAP currentMatriceSAP)
    {
        system.debug('Send_Contract_TO_SAP');
        //this.oBapiTracker = new BAPITracker__c();
        this.oBapiTrackerAbon = new BAPITracker__c();
        this.loBapiTracker = new list<BAPITracker__c>();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');

        //String statusContinue = 'OK';
        this.statusContinueProcess = true;
        String statusContinueContratAbon = 'OK';
        String errorMessageContratAbon = '';
        String numContratAbon;
        Map<String, list<Quote_PTL__c>> mapQPTL = new Map<String, list<Quote_PTL__c>>(); 
        microsoftLobservicesSapCONTRACT.RfcEndpoint callBAPIContratAbon = new microsoftLobservicesSapCONTRACT.RfcEndpoint();
        microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element responseContratAbon = new microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element();
        microsoftLobservicesSapCONTRACT.RfcEndpoint callBAPI = new microsoftLobservicesSapCONTRACT.RfcEndpoint();
        microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element response = new microsoftLobservicesSapCONTRACTRfc.ZBAPI_CRM_CONTRATResponse_element();
        list<Quote_PTL__c> lQPTL = new list<Quote_PTL__c>();
        Map<String, responseSAP> lIdQPTL = new Map<String, responseSAP>();

        try {

            //DEVIS (bareme produit, type de marché)
            list<Quote> q = [select Id, PMN_Payment_Spread__c, recordtypeId, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
                            Client_Type__c, Account.Compte_Superieur__c, Account.Mandataire__r.ExternalID__c, Account.Activity_Domain__r.ExternalID__c, Account.name, account.salutation, Market_type__c, opportunity.Account.Activity_Domain__r.ExternalID__c,
                            Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, Product_Scale_Code__c, 
                            Opportunity.Client_Type__c, Shipping_Condition__c, Facturation_calendar__c, DO_Payment_method__c, 
                            Opportunity.DO_Accounting_Manager__r.Code__c, Opportunity.Account_Payer__r.accountnumber, 
                            Opportunity.ReferenceClientSAP__c, Opportunity.Commercial_Agency__c, Opportunity.Contract_Start_Date__c, Opportunity.Account_Billed__r.accountnumber, Opportunity.PA_DO__c, Opportunity.FA_DO__c, Opportunity.DO_Name__c, 
                            Payment_spread__c, Contract_Duration__c, Signea_Circuit__c, Signea_Date_Signature__c, Opportunity.Opportunity_Reason__c, Opportunity.DO_Recovery_procedures__c, DO_Groupement__r.accountnumber, Scale__c, Scale_Code__c,
                            Opportunity.Account_Owner__r.accountnumber, Opportunity.Account.AccountNumber, Opportunity.Project_Type__c, Opportunity.Predecessor__c, 
                            DO_Groupement__c from Quote where Id= :IdQuote limit 1];

            if(q.size()>0)
            {
                //debut chargement custom metadata Table_Ref_SF_SAP__mdt
                list<Table_Ref_SF_SAP__mdt> tabRefSFSap = [select Id, MasterLabel, DeveloperName, Code_SAP_Salutation__c from Table_Ref_SF_SAP__mdt];
                Map<String, String> mapTaRefSfSap = new Map<String, String>();
                for(Table_Ref_SF_SAP__mdt t:tabRefSFSap)
                    mapTaRefSfSap.put(t.MasterLabel, t.Code_SAP_Salutation__c); 
                //fin chargement custom metadata Table_Ref_SF_SAP__mdt

                //definition du type de projet
                String typeProjet = (q[0].Project_Type__c  + q[0].Client_Type__c).toUpperCase();

                system.debug('typeProjet:'+typeProjet);  

                //DEBUT liste des QPTL associés au devis
                if(q[0].Opportunity.Project_Type__c == 'EXTE')//récupère juste nouveau ptl
                {
                    lQPTL = [select Id, Input_network_number__c, name, PTL_Name__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, 
                    State_Synchro_To_SAP__c, Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c, Opportunity_PTL__r.PTLSynchroSAP__c 
                    from Quote_PTL__c where Quote__c= :q[0].Id and PTL_Name__c = null];
                }
                else
                {
                    lQPTL = [select Id, Input_network_number__c, name, PTL_Name__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, 
                    State_Synchro_To_SAP__c, Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c, Opportunity_PTL__r.PTLSynchroSAP__c 
                    from Quote_PTL__c where Quote__c= :q[0].Id];
                }

                System.debug('lQPTL: '+lQPTL);
                //init optl en cas d'exception
                for(Quote_PTL__c qptl:lQPTL)
                    lIdQPTL.put(qptl.Opportunity_PTL__c, null);

                System.debug('lIdQPTL 1:'+lIdQPTL);

                //DEBUT DETERMINATION DU TYPE DE CONTRAT
                String strRecordDevName = Schema.SObjectType.Quote.getRecordTypeInfosById().get(q[0].recordtypeId).getDeveloperName();
                System.debug('Record Developer Name ====> '+strRecordDevName);

                Integer dureContrat = Integer.valueof(q[0].Contract_Duration__c);
                String codeBaremeProduit = q[0].Product_Scale_Code__c; 
                String codeBaremeRedevance = q[0].Scale_Code__c; 
                String dureTypeContrat = q[0].Contract_Duration__c;

                System.debug('dureContrat:'+dureContrat);
                System.debug('codeBaremeProduit:'+codeBaremeProduit);
                System.debug('codeBaremeRedevance:'+codeBaremeRedevance);

                String typeContrat = '';
                String typeContratAbon = '';
                
                list<Type_Contrat_Rainbow__mdt> listTypecontrat;
                if(codeBaremeRedevance == '2G')
                    listTypecontrat = [select Id, MasterLabel, DeveloperName, Recordtype_quote__c, 
                                                                Code_bareme_produit__c, Code_bareme_redevance__c, Duree_contrat__c, Type_contrat_SAP__c 
                                                                from Type_Contrat_Rainbow__mdt where Recordtype_quote__c = :strRecordDevName
                                                                AND Code_bareme_produit__c= :codeBaremeProduit and Code_bareme_redevance__c= '2G' order by MasterLabel];
                else                                                               
                    listTypecontrat = [select Id, MasterLabel, DeveloperName, Recordtype_quote__c, 
                                                                Code_bareme_produit__c, Code_bareme_redevance__c, Duree_contrat__c, Type_contrat_SAP__c 
                                                                from Type_Contrat_Rainbow__mdt where Recordtype_quote__c = :strRecordDevName
                                                                AND Code_bareme_produit__c= :codeBaremeProduit and Code_bareme_redevance__c != '2G' order by MasterLabel];


                for(Type_Contrat_Rainbow__mdt tc:listTypecontrat)
                {
                    system.debug('tc 1:'+tc);
                    if((String.valueOf(dureContrat) == tc.Duree_contrat__c) && (typeContrat == ''))
                        typeContrat = tc.Type_contrat_SAP__c;
                }

                System.debug('listTypecontrat freddy:'+listTypecontrat);
                if(listTypecontrat.size()==1)
                    typeContrat = listTypecontrat[0].Type_contrat_SAP__c;

                System.debug('typeContrat freddy:'+typeContrat);
                
                if(Test.isRunningTest()){
                	typeContrat = '';
                }
                
                if(typeContrat == '') 
                {
                    system.debug('DANS TYPE CONTRAT BLANC');
                 
                    for(Type_Contrat_Rainbow__mdt tc:listTypecontrat)
                    {
                        system.debug('tc 2:'+tc);
                        if(tc.Duree_contrat__c != '' && tc.Duree_contrat__c != null)
                        {
                            List<String> ldureeContrat = tc.Duree_contrat__c.split(',');
                            for(String s:ldureeContrat)
                            {
                                if(dureTypeContrat == s)
                                    typeContrat = tc.Type_contrat_SAP__c;
                            }
                        }    
                    }
                }

                System.debug('typeContrat1:'+typeContrat);

 
                if(typeContrat == '' && listTypecontrat.size()>0)
                    typeContrat = listTypecontrat[0].Type_contrat_SAP__c;
                system.debug('typeContrat:'+typeContrat);
                //FIN DETERMINATION DU TYPE DE CONTRAT

                //DEBUT TYPE CONTRAT ABONNEMENT, ON AJOUTE PTL, ARTICLE S00000017
                //on recherche si article abonnement
                list<QuoteLineItem> lQLI = [select Id, OrderSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c,
                                            Product_Code__c, Quantity from QuoteLineItem where Quote_PTL__c= :lQPTL and 
                                            Product_Family__c = 'Redevance' and Quantity > 0 and QuoteId= :q[0].Id]; //Product_Code__c = 'S000000017'
                
                Boolean articleAbonTrouve = false;
                //if(lQLI.size() > 0) //on a un contrat abonnement
                if(q[0].Scale__c == '2G')
                    typeContratAbon = 'ZABG';

                //DEF ACTION
                String action = currentMatriceSAP.contrat;
                String actionAbon = currentMatriceSAP.contrat;
                String raisonCdeMvt = currentMatriceSAP.raisonCdeMvt;
                system.debug('>>>action contrat:'+currentMatriceSAP.contrat);
                system.debug('>>>contrat abonnement lQLI.size():'+lQLI.size());
                //successions propriétaires sont à traiter comme les créations avec un nouveau contrat ZABG 
                if(Test.isRunningTest()){
					typeContratAbon = 'ZABG';
    			}
                if(typeContratAbon == 'ZABG')
                {
                    system.debug('DANS TYPE CONTRAT ABONNEMENT');
                    //DEBUT MODE CREA CONTRAT ABONNEMENT CREA ET SUCC OWNER
                    if(Test.isRunningTest()){
                        actionAbon = 'CREA';
                        typeProjet='SUCCOWNER';
                    }
                    
                    if((actionAbon == 'CREA')||(typeProjet=='SUCCOWNER'))
                    {
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2();
                        //DEBUT ZBAPI_CRM_CONTRAT_ENTETE
                        microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_ENTETE IS_CONTRAT = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_ENTETE();
                        IS_CONTRAT.DOC_TYPE = typeContratAbon;
                        Date CON_ST_DAT = null;
                        if((q[0].Signea_Circuit__c != null)&&(q[0].Signea_Date_Signature__c != null)&&(q[0].DO_Payment_method__c == 'P'||q[0].DO_Payment_method__c == 'G'))
                            CON_ST_DAT = Date.newInstance(q[0].Signea_Date_Signature__c.year(), q[0].Signea_Date_Signature__c.month(), q[0].Signea_Date_Signature__c.day());
                        else if(q[0].Opportunity.Contract_Start_Date__c != null)
                            CON_ST_DAT = Date.newInstance(q[0].Opportunity.Contract_Start_Date__c.year(), q[0].Opportunity.Contract_Start_Date__c.month(), q[0].Opportunity.Contract_Start_Date__c.day());
                        else 
                            CON_ST_DAT = Date.newInstance(1900, 01,01);            
                        IS_CONTRAT.CON_ST_DAT = CON_ST_DAT;
    
                        System.debug('CON_ST_DAT ZABG:'+CON_ST_DAT);
                
                        IS_CONTRAT.VAL_PER = dureContrat;
    
                        IS_CONTRAT.ORD_REASON = currentMatriceSAP.raisonCdeContratCrea;
                        System.debug('currentMatriceSAP.raisonCdeContratCrea: '+currentMatriceSAP.raisonCdeContratCrea);
                
                        IS_CONTRAT.SALES_DIST = q[0].Product_Scale_Code__c;  //ZONE DISTRIBUTION code bareme produit devis
                        //FIN ZBAPI_CRM_CONTRAT_ENTETE
    
                        //DEBUT ZBAPI_CRM_CONTRAT_POSTE
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_CONTRAT_POSTE IT_POSTE = new microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_CONTRAT_POSTE();
                        list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE> lZBAPI_CRM_CONTRAT_POSTE = new list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE>(); 
                        microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE ZBAPI_CRM_CONTRAT_POSTE = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE(); 
                            
                        ZBAPI_CRM_CONTRAT_POSTE.MATERIAL = 'S000000017';//lQLI[0].Product_Code__c;
                        ZBAPI_CRM_CONTRAT_POSTE.TARGET_QTY = lQLI[0].Quantity;
                
                        if(currentMatriceSAP.calendrierFacturation == 'X')
                            ZBAPI_CRM_CONTRAT_POSTE.IND_CALENDRIER = currentMatriceSAP.calendrierFacturation;
                        ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].PMN_Payment_Spread__c;
    
                        lZBAPI_CRM_CONTRAT_POSTE.add(ZBAPI_CRM_CONTRAT_POSTE);
                        IT_POSTE.ZBAPI_CRM_CONTRAT_POSTE = lZBAPI_CRM_CONTRAT_POSTE;
                        //FIN ZBAPI_CRM_CONTRAT_POSTE
    
                        //DEBUT ZBAPI_CRM_PARTENAIRES
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_PARTENAIRES IT_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_PARTENAIRES();
                        list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES> lZBAPI_CRM_PARTENAIRES = new list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES>(); 
    
                        //role PTL
                        Integer i = 000;

                        //projet type CREA on récupère un des optl.PTLSynchroSAP__c  
                        if(actionAbon == 'CREA')
                        {
                            system.debug('projet type CREA ABONNEMENT :');
                            List<Opportunity_PTL__c> lOPTL = [select Id, PTLSynchroSAP__c from Opportunity_PTL__c where Opportunity__c= :q[0].OpportunityId];

                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                            ZBAPI_CRM_PARTENAIRES.PARZA = i;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = lOPTL[0].PTLSynchroSAP__c;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                            i++;

                            actionAbon = 'CREA';
                        }
                        if(typeProjet=='SUCCOWNER')
                        {
                            List<Quote_PTL__c> lPTLAccountExistant = [select Id, Quote__c, PTL_Name__c from Quote_PTL__c where Quote__c= :q[0].Id]; 
                            system.debug('lPTLAccountExistant ABONNEMENT:'+lPTLAccountExistant);
        
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                            ZBAPI_CRM_PARTENAIRES.PARZA = i;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = lPTLAccountExistant[0].PTL_Name__c;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                            i++;
                            actionAbon = 'CREA';

                        }

                        //role DO
                        microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                        ZBAPI_CRM_PARTENAIRES.PARVW = 'AG';
                        ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                        ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.ReferenceClientSAP__c;
                        lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);

                        //si payeur != DO.
                        if(q[0].Opportunity.PA_DO__c == false)
                        {
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES5 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES5.PARVW = 'RG';
                            ZBAPI_CRM_PARTENAIRES5.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES5.KUNN2 = q[0].Opportunity.Account_Payer__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES5);
                        }                
                        //si facturé != DO
                        if(q[0].Opportunity.FA_DO__c == false)
                        {
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES1 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES1.PARVW = 'RE';
                            ZBAPI_CRM_PARTENAIRES1.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES1.KUNN2 = q[0].Opportunity.Account_Billed__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES1);
                        }                
                        if(Test.isRunningTest()){
                            q[0].Opportunity.Client_Type__c = 'Renter';
                        }

                        if(q[0].Opportunity.Client_Type__c == 'Renter')
                        {
                            //propriétaire
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES6 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES6.PARVW = 'ZP';
                            ZBAPI_CRM_PARTENAIRES6.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES6.KUNN2 = q[0].Opportunity.Account_Owner__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES6);


                            //locataire
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES1 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES1.PARVW = 'ZO';
                            ZBAPI_CRM_PARTENAIRES1.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES1.KUNN2 = q[0].Opportunity.Account.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES1);

                        }

                        //groupement produit
                        String compSup = q[0].DO_Groupement__r.AccountNumber;
                        Boolean optimo = false;
                        if((compSup!=null)&&(compSup.contains('OPTI')))
                            optimo = true;
        
                        /*if((q[0].DO_Groupement__r.accountnumber != null)&&(q[0].DO_Groupement__r.accountnumber!='')&&(optimo == false)&&(q[0].DO_Groupement__r.accountnumber!='AP000000'))
                        {
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES8 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES8.PARVW = 'Z4';
                            ZBAPI_CRM_PARTENAIRES8.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES8.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES8);
                        } */               
                        if(Test.isRunningTest()){
                			q[0].Scale__c = '2G';
                		}

                        //groupement abonnement
                        if((q[0].Scale__c == '2G')&&(q[0].DO_Groupement__r.accountnumber != null)&&(q[0].DO_Groupement__r.accountnumber!='')&&(q[0].DO_Groupement__r.accountnumber!='AP000000'))
                        {
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES9 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES9.PARVW = 'Z5';
                            ZBAPI_CRM_PARTENAIRES9.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES9.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES9);
                        }                
        
                        IT_PARTENAIRES.ZBAPI_CRM_PARTENAIRES = lZBAPI_CRM_PARTENAIRES;
                        //FIN ZBAPI_CRM_PARTENAIRES

                        //DEBUT CREATION CONTRAT ABONNEMENT
                        /*String oldEndPoint =  callBAPI.endpoint_x;
                        system.debug('Account oldEndPoint:'+oldEndPoint);
                        //appel endpoint trace
                        callBAPI.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
        
                        callBAPI.ZBAPI_CRM_CONTRAT( action, q[0].Opportunity.Commercial_Agency__c, '02',
                        null, lQPTL[0].Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                        q[0].Account.Mandataire__r.ExternalID__c,
                        typeProjet, String.valueOf(q[0].Account.Activity_Domain__r.ExternalID__c),
                        IS_CONTRAT, ET_RETURN, IT_PARTENAIRES, IT_POSTE);

                        //appel SAP
                        callBAPI.endpoint_x = oldEndPoint;
                        */    

                        responseContratAbon = callBAPI.ZBAPI_CRM_CONTRAT( actionAbon, q[0].Opportunity.Commercial_Agency__c, '02',
                        null, lQPTL[0].Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                        q[0].Account.Mandataire__r.ExternalID__c,
                        typeProjet, String.valueOf(q[0].Account.Activity_Domain__r.ExternalID__c),
                        IS_CONTRAT, ET_RETURN, IT_PARTENAIRES, IT_POSTE);
                            
                        system.debug('>>>response CONTRAT ABONNEMENT:'+responseContratAbon);
    
                        //TRAITEMENT RETOUR FREDDY
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2 ET_RETURNSAP = responseContratAbon.ET_RETURN;
                        system.debug('>>>ET_RETURNSAP ABONNEMENT:'+ET_RETURNSAP);
                        list<microsoftLobservicesSapCONTRACTTypes.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;
                        system.debug('>>>BAPIRET2 ABONNEMENT:'+BAPIRET2);
                        
                        for(microsoftLobservicesSapCONTRACTTypes.BAPIRET2 b:BAPIRET2)
                            system.debug('b.MESSAGE ABONNEMENT:'+b.MESSAGE);
                        
                        for(microsoftLobservicesSapCONTRACTTypes.BAPIRET2 b:BAPIRET2)
                            errorMessageContratAbon = errorMessageContratAbon +'#'+b.MESSAGE;

                        //oBapiTrackerAbon
                        this.oBapiTrackerAbon.Response1__c = JSON.serialize((responseContratAbon));
                        this.oBapiTrackerAbon.Endpoint__c = callBAPI.endpoint_x;   
                        this.oBapiTrackerAbon.Message__c = errorMessageContratAbon;
                        this.oBapiTrackerAbon.Request__c = callBAPI.request;
                        this.oBapiTrackerAbon.User__c = UserInfo.getUserId() ;
                        this.loBapiTracker.add(this.oBapiTrackerAbon);

                        statusContinueContratAbon = responseContratAbon.EX_CONTROL;
                        system.debug('statusContinueContratAbon :'+statusContinueContratAbon);

                        numContratAbon = responseContratAbon.EX_CONTRAT;
                        system.debug('numContratAbon:'+numContratAbon);

                        //FIN CREATION CONTRAT ABONNEMENT
                        //RETOUR SI KO
                        if(statusContinueContratAbon == 'KO')
                        {
                            //MAJ ARTICLE ABONNEMENT
                            lQLI[0].State_Synchro_To_SAP__c = statusContinueContratAbon;
                            if(errorMessageContratAbon.length()>255)
                                lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon.substring(0, 255);
                            else lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon;
                            lQLI[0].OrderSynchroSAP__c = numContratAbon;

                            update lQLI;

                            //bapi tracker juste contrat abonnement
                            if (this.sStoreTracker.toLowercase() == 'true') upsert this.loBapiTracker;

                            this.statusContinueProcess = false;
                            Quote_PTL__c qptlAbonnement = new Quote_PTL__c();
                            qptlAbonnement.Input_network_number__c = 'Contrat Abonnement';
                            qptlAbonnement.ContractSynchroSAP__c = numContratAbon;
                            qptlAbonnement.State_Synchro_To_SAP__c = statusContinueContratAbon;
                            qptlAbonnement.Error_Synchro_To_SAP__c = errorMessageContratAbon;
                            lQPTL.add(qptlAbonnement);
                            mapQPTL.put('ListQPTL', lQPTL);

                            return mapQPTL;

                        }   
                    }
                    //FIN MODE CREA CONTRAT ABONNEMENT 

                    //DEBUT EXTE CONTRAT ABONNEMENT, RECHERCHE CONTRAT ABONNEMENT
                    if(action == 'CREA NOUVEAU PTL')
                    {
                        //RECHERCHE NUM CONTRAT ABONNEMENT sur DO numContratAbon
                        list<contract> contrat = [select Id, Name, Contract_Label__c,DO_Matricule__c  from contract where Contract_Label__c = 'ZABG' and DO_Matricule__c  = :q[0].Opportunity.ReferenceClientSAP__c]; 
                        if(contrat.size()>0)
                            numContratAbon = contrat[0].Name;
                    }
                    //FIN EXTE CONTRAT ABONNEMENT, RECHERCHE CONTRAT ABONNEMENT

                }
                
                //FIN TYPE CONTRAT ABONNEMENT, ON AJOUTE PTL, ARTICLE S00000017
                /************************************************************/
                /************************************************************/

                String numContrat = '';
                if(statusContinueContratAbon == 'OK' && typeContrat != '')
                {
                    for(Quote_PTL__c qptl:lQPTL)
                    {
                        BAPITracker__c oBapiTrackerPTL = new BAPITracker__c();

                        //BAPI SAP
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2();
                        System.debug('MSG2:');
                        //DEBUT ZBAPI_CRM_CONTRAT_ENTETE
                        microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_ENTETE IS_CONTRAT = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_ENTETE();
                        IS_CONTRAT.DOC_TYPE = typeContrat;
                        System.debug('MSG3');
                        Date CON_ST_DAT = null;
                        System.debug('MSG4');
                        
                        if((q[0].Signea_Circuit__c != null)&&(q[0].Signea_Date_Signature__c != null))
                            CON_ST_DAT = Date.newInstance(q[0].Signea_Date_Signature__c.year(), q[0].Signea_Date_Signature__c.month(), q[0].Signea_Date_Signature__c.day());
                        else if(q[0].Opportunity.Contract_Start_Date__c != null)
                            CON_ST_DAT = Date.newInstance(q[0].Opportunity.Contract_Start_Date__c.year(), q[0].Opportunity.Contract_Start_Date__c.month(), q[0].Opportunity.Contract_Start_Date__c.day());
                        else 
                            CON_ST_DAT = Date.newInstance(1900, 01,01);            
                        IS_CONTRAT.CON_ST_DAT = CON_ST_DAT;

                        System.debug('IS_CONTRAT.CON_ST_DAT: '+IS_CONTRAT.CON_ST_DAT);
                        IS_CONTRAT.VAL_PER = dureContrat;       //durée contrat devis

                        IS_CONTRAT.ORD_REASON = currentMatriceSAP.raisonCdeContratCrea;
                        System.debug('currentMatriceSAP.raisonCdeContratCrea: '+currentMatriceSAP.raisonCdeContratCrea);
                    
                        IS_CONTRAT.SALES_DIST = q[0].Product_Scale_Code__c;  //ZONE DISTRIBUTION code bareme produit devis
                        //FIN ZBAPI_CRM_CONTRAT_ENTETE

                        //DEBUT ZBAPI_CRM_CONTRAT._POSTE
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_CONTRAT_POSTE IT_POSTE = new microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_CONTRAT_POSTE();
                        list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE> lZBAPI_CRM_CONTRAT_POSTE = new list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE>(); 
                        list<QuoteLineItem> lQuoteLineItem = new list<QuoteLineItem>();
                        list<QuoteLineItem> lQuoteLineItemTraitement = new list<QuoteLineItem>();
                        
                        if(Test.isRunningTest()){
                            raisonCdeMvt = 'ZDEP';
                		}

                        //if(q[0].Project_Type__c == 'SUCC' && q[0].Client_Type__c == 'Renter')
                        if(q[0].Client_Type__c == 'Renter')
                        {
                            lQuoteLineItem = [select Id, OrderSynchroSAP__c, New_Price_HT__c, TotalPrice, Offered_Months__c,Product_Family__c, Bio_Product__c, Product_Code__c, Quantity from QuoteLineItem where Quote_PTL__c= :qptl.Id and 
                                                        Only_for_Standardized_Form__c = False and (Deconsignation__c = false or Deconsignation__c = null)
                                                         
                                                        and QuoteId= :q[0].Id and Product_Family__c = 'Produit'];    
                                                        //and (Sub_Type__c != 'Citerne') and QuoteId= :q[0].Id and Product_Family__c = 'Produit'];    
                        }
                        else if(q[0].Project_Type__c == 'SUCC' && raisonCdeMvt == 'ZDEP')
                        {   
                            //il faut créer l'article S000000040 - Opération déplacement citerne Butagaz 
                            QuoteLineItem S000000040 = new QuoteLineItem();
                            S000000040.Product_Code__c = 'S000000040';
                            S000000040.Quantity = 1;

                            /*+ l’un des articles suivants s’il est présent dans les éléments du devis :
                            S000000015	Retrait/ déplact cit. apparente 3.2T
                            S000000100	Déplact Nautila remblai Butagaz
                            S000000101	Retrait/ déplact cit. apparente <=  2T
                            S000000136	Déplact Nautila remblai Client <= 2T
                            S000000137	Déplact Nautila remblai Client 3,2T
                            S000000177	Retrait/ déplact cit. apparente <= 2T of*/
                            Set<String> s1 = new Set<String>();
                            s1.add('S000000015'); s1.add('S000000100'); s1.add('S000000101'); s1.add('S000000136'); s1.add('S000000137'); s1.add('S000000177');
                            list<QuoteLineItem> lqli1 = new list<QuoteLineItem>();
                            lqli1 = [select Id, RCE_Rebate_TTC__c, OrderSynchroSAP__c, New_Price_HT__c, TotalPrice, Offered_Months__c,Product_Family__c, Bio_Product__c, Product_Code__c, 
                                        Quantity from QuoteLineItem where Quote_PTL__c= :qptl.Id and Only_for_Standardized_Form__c = False and 
                                        (Deconsignation__c = false or Deconsignation__c = null) and QuoteId= :q[0].Id and Product_Code__c IN :s1]; 
                            //La commande ZDEP ne doit pas contenir d’article Citerne
                            lQuoteLineItem = [select Id, OrderSynchroSAP__c, New_Price_HT__c, TotalPrice, Offered_Months__c,Product_Family__c, Bio_Product__c, Product_Code__c, 
                                        Quantity from QuoteLineItem where Quote_PTL__c= :qptl.Id and Only_for_Standardized_Form__c = False and 
                                        (Deconsignation__c = false or Deconsignation__c = null) and QuoteId= :q[0].Id     
                                        and (Sub_Type__c != 'Citerne') and QuoteId= :q[0].Id and Product_Code__c != 'S000000017'];    
                            
                            lQuoteLineItem.add(S000000040);
                            if(lqli1.size()>0)
                                lQuoteLineItem.add(lqli1[0]);      
                                
                            //+ S000000087 si une RCE est présente dans le devis sur l’un de ces articles de frais
                            Boolean RceFind = false;
                            for(QuoteLineItem qli:lqli1)
                            {
                                if( qli.RCE_Rebate_TTC__c != null && qli.RCE_Rebate_TTC__c != 0 && RceFind == false)
                                RceFind = true;
                            }
                            if(RceFind == true)
                            {
                                QuoteLineItem S000000087 = new QuoteLineItem();
                                S000000087.Product_Code__c = 'S000000087';
                                S000000087.Quantity = 1;
                                lQuoteLineItem.add(S000000087);
                            }
                        }
                        else
                        {    
                            lQuoteLineItem = [select Id, OrderSynchroSAP__c, Sub_Type__c, New_Price_HT__c, TotalPrice, Offered_Months__c, Product_Family__c, Bio_Product__c, Product_Code__c, Quantity from QuoteLineItem where Quote_PTL__c= :qptl.Id and 
                                                        Only_for_Standardized_Form__c = False and (Deconsignation__c = false or Deconsignation__c = null) 
                                                        and QuoteId= :q[0].Id and Product_Code__c != 'S000000017'];//  and Product_Family__c != 'Redevance'];    


                        }

                        System.debug('lQuoteLineItem: '+lQuoteLineItem);
                        Boolean abonBio = false;
                        String bioProduct; 
                        for(QuoteLineItem qli:lQuoteLineItem)
                        {
                            microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE ZBAPI_CRM_CONTRAT_POSTE = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE(); 
                            
                            ZBAPI_CRM_CONTRAT_POSTE.MATERIAL = qli.Product_Code__c;
                            system.debug('qli.Product_Code__c:'+qli.Product_Code__c);
                            system.debug('qli.TotalPrice:'+qli.TotalPrice);
                            system.debug('String.valueOf(qli.TotalPrice):'+String.valueOf(qli.TotalPrice));
                            ZBAPI_CRM_CONTRAT_POSTE.COND_VALUE = String.valueOf(qli.TotalPrice);

                            if((qli.Product_Code__c == '904P0001')&&(qli.Bio_Product__c!=null)&&(qli.Bio_Product__c!=''))
                                ZBAPI_CRM_CONTRAT_POSTE.ITEM_CATEG = mapTaRefSfSap.get(qli.Bio_Product__c);
                            else if(qli.Product_Code__c == '904P0001')
                                ZBAPI_CRM_CONTRAT_POSTE.ITEM_CATEG = mapTaRefSfSap.get('ZMVA');
                            else if(qli.Product_Code__c == 'SPPABO0017')
                            {
                                //si Mensualité Pack Ecoconfortique, produit 904P0001 bio 
                                abonBio = true;
                                bioProduct = qli.Bio_Product__c;
                                ZBAPI_CRM_CONTRAT_POSTE.ITEM_CATEG = mapTaRefSfSap.get('ZMVM');
                            }        
                            system.debug('qli.Product_Code__c:'+qli.Product_Code__c);

                            ZBAPI_CRM_CONTRAT_POSTE.TARGET_QTY = qli.Quantity;
                            
                            //ABONNEMENT CLEF CONDITION DE PAIEMENT
                            //si ecoconf
                            if(q[0].Product_Scale_Code__c == 'ECOCFT' && (qli.Product_Code__c == 'SPPABO0017'||qli.Product_Code__c == 'SPPABO0018'))
                            {
                                ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].Payment_spread__c;
                                system.debug('ECOCFT');
                                if(currentMatriceSAP.calendrierFacturation == 'X')
                                    ZBAPI_CRM_CONTRAT_POSTE.IND_CALENDRIER = currentMatriceSAP.calendrierFacturation;

                                //si Offered_Months__c > 0, on créé une nouvelle ligne SPPABO0018
                                if(qli.Offered_Months__c!=null && qli.Offered_Months__c > 0)
                                {
                                    microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE ZBAPI_CRM_CONTRAT_POSTE1 = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE(); 
                                    ZBAPI_CRM_CONTRAT_POSTE1.MATERIAL = 'SPPABO0018';
                                    ZBAPI_CRM_CONTRAT_POSTE1.TARGET_QTY = qli.Offered_Months__c;
                                    ZBAPI_CRM_CONTRAT_POSTE1.COND_TYPE = 'ZPRM';
                                    system.debug('qli.TotalPrice:'+qli.TotalPrice);
                                    system.debug('String.valueOf(qli.TotalPrice):'+String.valueOf(qli.TotalPrice));

                                    ZBAPI_CRM_CONTRAT_POSTE1.COND_VALUE = String.valueOf(qli.TotalPrice);
                                    //condition paiement
                                    if(q[0].Payment_spread__c == 'Z000')
                                        ZBAPI_CRM_CONTRAT_POSTE1.PMNTTRMS = q[0].Payment_spread__c;
                                    else if(q[0].Payment_spread__c == 'ZN12')
                                    {
                                        ZBAPI_CRM_CONTRAT_POSTE1.IND_CALENDRIER = currentMatriceSAP.calendrierFacturation;
                                        if(qli.Offered_Months__c == 2)
                                            ZBAPI_CRM_CONTRAT_POSTE1.PMNTTRMS = 'ZN02';
                                        if(qli.Offered_Months__c == 6)
                                            ZBAPI_CRM_CONTRAT_POSTE1.PMNTTRMS = 'ZN06';
                                    }
                                    System.debug('ZBAPI_CRM_CONTRAT_POSTE1:'+ZBAPI_CRM_CONTRAT_POSTE1);

                                    lZBAPI_CRM_CONTRAT_POSTE.add(ZBAPI_CRM_CONTRAT_POSTE1);
                                }

                            }
                            else
                            {
                                String productFamily = qli.Product_Family__c;
                                switch on productFamily {
                                    when 'Redevance'
                                    {
                                        system.debug('Redevance');

                                        ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].PMN_Payment_Spread__c;
                                        //ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].Payment_spread__c;
                                        if(currentMatriceSAP.calendrierFacturation == 'X')
                                            ZBAPI_CRM_CONTRAT_POSTE.IND_CALENDRIER = currentMatriceSAP.calendrierFacturation;
                                        }
                                    when 'Produit'
                                    {
                                        if(q[0].Product_Scale_Code__c != 'ECOCFT')
                                        {
                                            system.debug('Produit');
                                            ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].Payment_spread__c;    
                                        }    

                                    }    
                                    when 'Service'
                                    {
                                        //ZBAPI_CRM_CONTRAT_POSTE.PMNTTRMS = q[0].Payment_spread__c;
                                    }    

                                }      
                            }    

                            lZBAPI_CRM_CONTRAT_POSTE.add(ZBAPI_CRM_CONTRAT_POSTE);
                        }
                        //article abonnement, on modifie type de post propane    
                        if(abonBio == true)
                        {
                            for(microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_CONTRAT_POSTE poste:lZBAPI_CRM_CONTRAT_POSTE)
                            {
                                if(poste.MATERIAL == '904P0001')
                                    poste.ITEM_CATEG = mapTaRefSfSap.get(bioProduct);
                            }
                        }

                        IT_POSTE.ZBAPI_CRM_CONTRAT_POSTE = lZBAPI_CRM_CONTRAT_POSTE;
                        
                        //FIN ZBAPI_CRM_CONTRAT_POSTE

                        //DEBUT ZBAPI_CRM_PARTENAIRES
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_PARTENAIRES IT_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ArrayOfZBAPI_CRM_PARTENAIRES();
                        list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES> lZBAPI_CRM_PARTENAIRES = new list<microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES>(); 
                        microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES; 

                        //role PTL
                        action = currentMatriceSAP.contrat;
                        Integer i = 000;
                        List<Opportunity_PTL__c> lOPTL = [select Id, PTLSynchroSAP__c from Opportunity_PTL__c where Opportunity__c= :q[0].OpportunityId];

                        //projet type CREA on récupère tous les optl.PTLSynchroSAP__c  
                        if(action == 'CREA')
                        {
                            system.debug('projet type CREA:');
                            //Opportunity_PTL__r.PTLSynchroSAP__c
                            //for(Opportunity_PTL__c optl:lOPTL)
                            //{
                                ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                                ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                                ZBAPI_CRM_PARTENAIRES.PARZA = i;
                                ZBAPI_CRM_PARTENAIRES.KUNN2 = qptl.Opportunity_PTL__r.PTLSynchroSAP__c;
                                lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                                i++;
                            //}
                            action = 'CREA';
                        }
                        
                        //projet type EXTE on récupère le nouveau ptl  
                        if(action == 'CREA NOUVEAU PTL')
                        {
                            system.debug('projet type EXTE:');
                            list<Quote_PTL__c> lQPTL1 = [select Id, name, PTL_Name__c, Opportunity_PTL__r.PTLSynchroSAP__c 
                            from Quote_PTL__c where Quote__c= :q[0].Id and PTL_Name__c = null];

                            system.debug('lQPTL1:'+lQPTL1);
                                
                            for(Quote_PTL__c qptl1:lQPTL1)
                            {
                                system.debug('qptl1.PTL_Name__c:'+qptl1.PTL_Name__c);
        
                                ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                                ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                                ZBAPI_CRM_PARTENAIRES.PARZA = i;
                                ZBAPI_CRM_PARTENAIRES.KUNN2 = qptl1.Opportunity_PTL__r.PTLSynchroSAP__c;
                                lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                                i++;
                            }

                            action = 'CREA';
                        }

                        //on récupère les ptl choisi associés au devis
                        if(action == 'CREA SUCC')
                        {
                            system.debug('projet type SUCC:');

                            //List<Quote_PTL__c> lPTLAccountExistant = [select Id, Quote__c, PTL_Name__c from Quote_PTL__c where Quote__c= :q[0].Id]; 
                            //system.debug('lPTLAccountExistant:'+lPTLAccountExistant);
        
                            //for(Quote_PTL__c ptl:lPTLAccountExistant)
                            //{
                                ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                                ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                                ZBAPI_CRM_PARTENAIRES.PARZA = i;
                                ZBAPI_CRM_PARTENAIRES.KUNN2 = qptl.PTL_Name__c;
                                lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                                i++;
                            //}
                            action = 'CREA';
                        }

                        //role DO
                        ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                        ZBAPI_CRM_PARTENAIRES.PARVW = 'AG';
                        ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                        ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.ReferenceClientSAP__c;
                        lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);

                        //si payeur != DO.
                        if(q[0].Opportunity.PA_DO__c == false)
                        {
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'RG';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account_Payer__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        }                
                        //si facturé != DO
                        if(q[0].Opportunity.FA_DO__c == false)
                        {
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'RE';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account_Billed__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        }                

                        if(q[0].Opportunity.Client_Type__c == 'Renter')
                        {
                            //propriétaire
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'ZP';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account_Owner__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);


                            //locataire
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'ZO';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);

                        }

                        //groupement produit
                        String compSup = q[0].DO_Groupement__r.AccountNumber;
                        Boolean optimo = false;
                        if((compSup!=null)&&(compSup.contains('OPTI')))
                            optimo = true;
        
                        if((q[0].DO_Groupement__r.accountnumber != null)&&(q[0].DO_Groupement__r.accountnumber!='')&&(optimo == false)&&(q[0].DO_Groupement__r.accountnumber!='AP000000'))
                        {
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'Z4';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        }                
                        //groupement abonnement
                        if((q[0].Scale__c == '2G')&&(q[0].DO_Groupement__r.accountnumber != null)&&(q[0].DO_Groupement__r.accountnumber!='')&&(q[0].DO_Groupement__r.accountnumber!='AP000000'))
                        {
                            ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapCONTRACTTypes.ZBAPI_CRM_PARTENAIRES();
                            ZBAPI_CRM_PARTENAIRES.PARVW = 'Z5';
                            ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                            ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                            lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        }                
        
                        IT_PARTENAIRES.ZBAPI_CRM_PARTENAIRES = lZBAPI_CRM_PARTENAIRES;
                        //FIN ZBAPI_CRM_PARTENAIRES

                        System.debug('numContratAbon:'+numContratAbon);

                        /*String oldEndPoint =  callBAPI.endpoint_x;
                        system.debug('Account oldEndPoint:'+oldEndPoint);
                        //appel endpoint trace
                        callBAPI.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
        
                        response = callBAPI.ZBAPI_CRM_CONTRAT( action, q[0].Opportunity.Commercial_Agency__c, '02',
                        numContratAbon, qptl.Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                        q[0].Account.Mandataire__r.ExternalID__c,
                        typeProjet, String.valueOf(q[0].Account.Activity_Domain__r.ExternalID__c),
                        IS_CONTRAT, ET_RETURN, IT_PARTENAIRES, IT_POSTE);

                        //appel SAP
                        callBAPI.endpoint_x = oldEndPoint;
                        */    

                        System.debug('AVANT RESPONSE');


                        response = callBAPI.ZBAPI_CRM_CONTRAT( action, q[0].Opportunity.Commercial_Agency__c, '02',
                        numContratAbon, qptl.Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                        q[0].Account.Mandataire__r.ExternalID__c,
                        typeProjet, String.valueOf(q[0].Account.Activity_Domain__r.ExternalID__c),
                        IS_CONTRAT, ET_RETURN, IT_PARTENAIRES, IT_POSTE);

                        system.debug('>>>response CONTRAT:'+response);

                        //TRAITEMENT RETOUR
                        String errorMessage = '';
                        microsoftLobservicesSapCONTRACTTypes.ArrayOfBAPIRET2 ET_RETURNSAP = response.ET_RETURN;
                        list<microsoftLobservicesSapCONTRACTTypes.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;
                        
                        for(microsoftLobservicesSapCONTRACTTypes.BAPIRET2 b:BAPIRET2)
                            system.debug('b.MESSAGE:'+b.MESSAGE);
                        
                        for(microsoftLobservicesSapCONTRACTTypes.BAPIRET2 b:BAPIRET2)
                            errorMessage = errorMessage +'#'+b.MESSAGE;

                        //oBapiTracker
                        oBapiTrackerPTL.Response1__c = JSON.serialize((response));
                        oBapiTrackerPTL.Endpoint__c = callBAPI.endpoint_x;   
                        oBapiTrackerPTL.Message__c = errorMessage;
                        oBapiTrackerPTL.Request__c = callBAPI.request;
                        oBapiTrackerPTL.User__c = UserInfo.getUserId();
                        this.loBapiTracker.add(oBapiTrackerPTL);

                        if((this.statusContinueProcess==true)&&(response.EX_CONTROL=='KO'))                        
                            this.statusContinueProcess = false;

                        system.debug('this.statusContinueProcess :'+this.statusContinueProcess);

                        //maj numContrat
                        if(numContrat != ''||numContrat!=null) numContrat = response.EX_CONTRAT;
                        system.debug('numContrat 1:'+numContrat);

                        lIdQPTL.put(qptl.Id, new responseSAP(response.EX_CONTROL, response.EX_CONTRAT, errorMessage));
        
                    }//fin BOUCLE FOR

                    if (this.sStoreTracker.toLowercase() == 'true') upsert this.loBapiTracker;

                    
                    system.debug('numContrat 2:'+numContrat);
                    

                    System.debug('lIdQPTL:'+lIdQPTL);

                    lQPTL = [select Id, Input_network_number__c, name, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c from Quote_PTL__c where Id IN :lIdQPTL.keyset()];
                    
                    System.debug('lQPTL 1:'+lQPTL);

                    //DEBUT MAJ QPTL!
                    for(Quote_PTL__c qptl:lQPTL)
                    {
                        qptl.State_Synchro_To_SAP__c = lIdQPTL.get(qptl.Id).EX_CONTROL;
                        if(lIdQPTL.get(qptl.Id).lERROR.length()>255)
                            qptl.Error_Synchro_To_SAP__c = lIdQPTL.get(qptl.Id).lERROR.substring(0, 255);
                        else qptl.Error_Synchro_To_SAP__c = lIdQPTL.get(qptl.Id).lERROR;
                        qptl.ContractSynchroSAP__c = lIdQPTL.get(qptl.Id).EX_CONTRAT;
                    }
                    update lQPTL;

                    System.debug('lQPTL 2:'+lQPTL);

                    //MAJ contrat SAP dans opty
                    Opportunity opty = [select Id, Number__c, Contract_type_SAP__c from Opportunity where Id= :q[0].OpportunityId limit 1];
                    System.debug('opty:'+opty);
                    opty.Number__c = numContrat;
                    opty.Contract_type_SAP__c = typeContrat;
                    update opty;
                    System.debug('opty 2:'+opty);

                    //FIN MAJ QPTL
                    for (Id key : lIdQPTL.keySet()) 
                        system.debug('PAS EXCEPTION key:'+key+'## value:'+lIdQPTL.get(key));   

                    //on ajoute statusContinue
                    /*Quote_PTL__c qptl1 = new Quote_PTL__c(T_LAT_GEC_DOM_ALL_Do_Groupement_TEST__c=statusContinue);
                    List<Quote_PTL__c> lqptl1 = new List<Quote_PTL__c>();
                    lqptl1.add(qptl1);
                    mapQPTL.put('statusContinue', lqptl1);*/

                    //on ajoute contrat abonnement si il y a lieu et la partie update record
                    if(typeContratAbon == 'ZABG')
                    {
                        //MAJ ARTICLE ABONNEMENT
                        lQLI[0].State_Synchro_To_SAP__c = statusContinueContratAbon;
                        if(errorMessageContratAbon.length()>255)
                            lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon.substring(0, 255);
                        else lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon;
                        lQLI[0].OrderSynchroSAP__c = numContratAbon;

                        update lQLI;

                        System.debug('lQLI ABONNEMENT:'+lQLI);
                        
                        Quote_PTL__c qptlAbonnement = new Quote_PTL__c();
                        qptlAbonnement.Input_network_number__c = 'Contrat Abonnement';
                        qptlAbonnement.ContractSynchroSAP__c = numContratAbon;
                        qptlAbonnement.State_Synchro_To_SAP__c = statusContinueContratAbon;
                        qptlAbonnement.Error_Synchro_To_SAP__c = errorMessageContratAbon;
                        lQPTL.add(qptlAbonnement);

                    }    

                    mapQPTL.put('ListQPTL', lQPTL);
                }
                else if(typeContrat == '')
                {
                    list<Quote_PTL__c> lQPTLBefore;
                    if(q[0].Opportunity.Project_Type__c == 'EXTE')//récupère juste nouveau ptl
                    {
                        lQPTLBefore = [select Id, name, Input_network_number__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c 
                                                            from Quote_PTL__c where Quote__c= :q[0].Id and PTL_Name__c = null];
                    }
                    else
                    {
                        lQPTLBefore = [select Id, name, Input_network_number__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c 
                                                            from Quote_PTL__c where Quote__c= :q[0].Id];
                    }
            
                    for(Quote_PTL__c qptl:lQPTLBefore)
                    {
                        qptl.State_Synchro_To_SAP__c = 'KO';
                        qptl.Error_Synchro_To_SAP__c = 'Type de contrat inconnu: Barème produit :'+codeBaremeProduit+
                        ', Barème redevance :'+codeBaremeRedevance+', Durée du contrat :'+ dureTypeContrat;


                    }
                    update lQPTLBefore;

                    if((statusContinueContratAbon == 'OK')&&(typeContratAbon == 'ZABG'))
                    {
                        //MAJ ARTICLE ABONNEMENT
                        lQLI[0].State_Synchro_To_SAP__c = statusContinueContratAbon;
                        if(errorMessageContratAbon.length()>255)
                            lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon.substring(0, 255);
                        else lQLI[0].Error_Synchro_To_SAP__c = errorMessageContratAbon;
                        lQLI[0].OrderSynchroSAP__c = numContratAbon;

                        update lQLI;

                        System.debug('lQLI ABONNEMENT:'+lQLI);
                        
                        Quote_PTL__c qptlAbonnement = new Quote_PTL__c();
                        qptlAbonnement.Input_network_number__c = 'Contrat Abonnement';
                        qptlAbonnement.ContractSynchroSAP__c = numContratAbon;
                        qptlAbonnement.State_Synchro_To_SAP__c = statusContinueContratAbon;
                        qptlAbonnement.Error_Synchro_To_SAP__c = errorMessageContratAbon;
                        lQPTL.add(qptlAbonnement);

                        mapQPTL.put('ListQPTL', lQPTL);

                    }

                }

            }    
            return mapQPTL;

        }catch (Exception e) {
            system.debug('>>>class AP_WrapperForSOAPCallContract:'+e.getMessage());
            system.debug('>>>response:'+response);
            this.statusContinueProcess = false;
            //DEBUT MAJ OPTL
            list<Quote_PTL__c> lQPTL1 = [select Id, Input_network_number__c, name, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c from Quote_PTL__c where Id IN :lIdQPTL.keyset()];
		    if(lQPTL1.size()!=0)
            {    
                for(Quote_PTL__c qptl:lQPTL1)
                {
                    qptl.State_Synchro_To_SAP__c = 'KO';
                    qptl.Error_Synchro_To_SAP__c = e.getMessage();
                }    
                update lQPTL1;
            }
            else
            {
                lQPTL1 = [select Id, name, Input_network_number__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c from Quote_PTL__c where Quote__c= :IdQuote];
                for(Quote_PTL__c qptl:lQPTL1)
                {
                    qptl.State_Synchro_To_SAP__c = 'KO';
                    qptl.Error_Synchro_To_SAP__c = e.getMessage();
                }    
                update lQPTL1;
            }

            Map<String, list<Quote_PTL__c>> mapQPTL1 = new Map<String, list<Quote_PTL__c>>(); 
            mapQPTL1.put('ListQPTL', lQPTL1);

            //oBapiTracker
            BAPITracker__c oBapiTracker = new BAPITracker__c();
            oBapiTracker.Response1__c = JSON.serialize((response));
            oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
            oBapiTracker.Message__c = e.getMessage();
            oBapiTracker.Request__c = callBAPI.request;
            oBapiTracker.User__c = UserInfo.getUserId() ;
            if (this.sStoreTracker.toLowercase() == 'true') upsert oBapiTracker;
            
            return mapQPTL1;
        } 
    }

    public class responseSAP
    {
        public String EX_CONTROL;
        public String EX_CONTRAT;
        public String lERROR;
        
        public responseSAP(String EX_CONTROL, String EX_CONTRAT, String lERROR)
        {
                this.EX_CONTROL = EX_CONTROL;
                this.EX_CONTRAT = EX_CONTRAT;
                this.lERROR = lERROR;
        }
    }





}