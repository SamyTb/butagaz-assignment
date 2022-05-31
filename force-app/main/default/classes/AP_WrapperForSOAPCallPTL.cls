public class AP_WrapperForSOAPCallPTL {

    public Boolean statusContinueProcess;
    public BAPITracker__c oBapiTracker {get;set;}
    public list<BAPITracker__c> loBapiTracker {get;set;}
    public String sStoreTracker {get;set;}

    public AP_WrapperForSOAPCallPTL() {
    }

    //public static Map<String, list<Opportunity_PTL__c>> Send_PTL_TO_SAP(String IdQuote, matriceSAP currentMatriceSAP)
    public Map<String, list<Opportunity_PTL__c>> Send_PTL_TO_SAP(String IdQuote, matriceSAP currentMatriceSAP)
    {
        system.debug('Send_PTL_TO_SAP');
        this.oBapiTracker = new BAPITracker__c();
        this.loBapiTracker = new list<BAPITracker__c>();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');

        this.statusContinueProcess = true;
        microsoftLobservicesSapPTL200703.RfcEndpoint callBAPI = new microsoftLobservicesSapPTL200703.RfcEndpoint();
        microsoftLobservicesSapPTL200703Rfc.ZBAPI_CRM_PTLResponse_element response = new microsoftLobservicesSapPTL200703Rfc.ZBAPI_CRM_PTLResponse_element();

        list<Opportunity_PTL__c> loptl = new list<Opportunity_PTL__c>();
        Map<String, responseSAP> lIdOPTL = new Map<String, responseSAP>();
        
        try {
            
            Map<String, list<Opportunity_PTL__c>> mapOPTL = new Map<String, list<Opportunity_PTL__c>>(); 
            //DEVIS (bareme produit, type de marché)
            list<Quote> q = [select Id, Opportunity.Project_Type__c, VAT_code__c, Shipping_Condition__c, Opportunity.Activity_Domain__c, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
                            Client_Type__c, Account.name, account.salutation, account.Salutation__c, Market_type__c, opportunity.Account.Activity_Domain__r.ExternalID__c,
                            account.Mandataire__r.ExternalID__c, Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, 
                            Opportunity.DO_Phone__c, Opportunity.DO_Mobile_Phone_Number__c , Opportunity.DO_Work_Phone_Number__c , Opportunity.DO_Fax__c,
                            Opportunity.Street_name_project__c, Opportunity.Lieu_dit_Project__c   from Quote where Id= :IdQuote limit 1];

            if(q.size()>0)
            {
                //debut chargement custom metadata Table_Ref_SF_SAP__mdt
                list<Table_Ref_SF_SAP__mdt> tabRefSFSap = [select Id, MasterLabel, DeveloperName, Code_SAP_Salutation__c from Table_Ref_SF_SAP__mdt];
                Map<String, String> mapTaRefSfSap = new Map<String, String>();
                for(Table_Ref_SF_SAP__mdt t:tabRefSFSap)
                {
                    //system.debug(t.MasterLabel+'##'+t.DeveloperName);                    
                    mapTaRefSfSap.put(t.MasterLabel, t.Code_SAP_Salutation__c); 
                }
                //fin chargement custom metadata Table_Ref_SF_SAP__mdt
                system.debug('MSG1');

                //definition du type de projet
                String typeProjet = (q[0].Project_Type__c  + q[0].Client_Type__c).toUpperCase();

                //DEBUT si PRO, calcul mention complémentaire
                String mention_comp='';
                if(q[0].Market_type__c == 'PRO')
                {		
                    String civilite = q[0].Contact.salutation;
                    String prenom = q[0].Contact.firstname;
                    String nom = q[0].Contact.lastname;
                    
                    mention_comp = mapTaRefSfSap.get(civilite)+' '+nom+' '+prenom;
                    
                    if(mention_comp.length()>32)
                    {
                        mention_comp = civilite+' '+nom;
                        if(mention_comp.length()>32)
                        {
                            if(nom.length()>32)
                                mention_comp = nom.substring(0, 32);
                            else
                                mention_comp = nom;
                        
                        }    
                    }
                            
                }
                //FIN si PRO, calcul mention complémentaire
                system.debug('MSG2');


                //DEBUT liste des QPTL associés au devis
                list<Quote_PTL__c> lQPTL;
                if(q[0].Opportunity.Project_Type__c == 'EXTE')//récupère juste nouveau ptl
                {

                    lQPTL = [select Id, Opportunity_PTL__r.PTL__r.ExternalID__c,
                    Opportunity_PTL__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__c,
                    Opportunity_PTL__r.name,						
                    Opportunity_PTL__r.Mandataire__c, 
                    Opportunity_PTL__r.Activity_Domain__c, 
                    Opportunity_PTL__r.Opportunity__r.Project_Type__c,
                    Opportunity_PTL__r.Opportunity__r.DO_Name__c,
                    Opportunity_PTL__r.Opportunity__r.Client_Type__c,
                    Opportunity_PTL__r.Opportunity__r.DO_Market_Type__c,
                    Opportunity_PTL__r.PTL_Label__c,
                    Opportunity_PTL__r.PTL_Street_number__c,
                    Opportunity_PTL__r.PTL_Number_extention__c,
                    Opportunity_PTL__r.PTL_Street_type__c,
                    Opportunity_PTL__r.PTL_Street_name__c,
                    Opportunity_PTL__r.PTL_Place_Called__c,
                    Opportunity_PTL__r.PTL_Postal_Box__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__r.Postal_Code__c,
                    Opportunity_PTL__r.DepartmentFormula__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.INSEE_Code__c,
                    Opportunity_PTL__r.opportunity__r.DO_Language__c,
                    Opportunity_PTL__r.PTL_Phone__c,
                    Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,
                    Opportunity_PTL__r.PTL_Work_Phone_Number__c,
                    Opportunity_PTL__r.PTL_Fax_Number__c,
                    Opportunity_PTL__r.opportunity__r.account.Phone_Restriction__c,
                    Opportunity_PTL__r.Fiscal_class_PTL__c,
                    Opportunity_PTL__r.PTL_Code_NACE__r.ExternalID__c,
                    Opportunity_PTL__r.opportunity__r.account.Code_SIRET__c,
                    Opportunity_PTL__r.opportunity__r.ReferenceClientSAP__c,
                    Quote__r.Product_Scale_Code__c,
                    Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                    Opportunity_PTL__r.PTL_Shipping_Condition__c,
                    Opportunity_PTL__r.PTL_Shipping_Priority__c,
                    Opportunity_PTL__r.Call_client_before_delivery__c,
                    Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c,
                    Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c,
                    Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,
                    Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,
                    Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,
                    Opportunity_PTL__r.Opty_PTL_Geolocation__latitude__s,
                    Opportunity_PTL__r.Opty_PTL_Geolocation__longitude__s,
                    Opportunity_PTL__r.opportunity__r.Opportunity_Reason__c,
                    Opportunity_PTL__r.State_Synchro_To_SAP__c,
                    Opportunity_PTL__r.Opportunity__r.Account.Name,
                    Opportunity_PTL__r.PTL__r.Shipping_Condition__c,
                    Estimated_Consumption__c, Opportunity_PTL__r.Valeur_limitation_tonnage__c,
                    Opportunity_PTL__r.opportunity__r.T_Pack__c  
                    from Quote_PTL__c where Quote__c IN :q and PTL_Name__c = null];
                }
                else
                {
                    lQPTL = [select Id, Opportunity_PTL__r.PTL__r.ExternalID__c,
                    Opportunity_PTL__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__c,
                    Opportunity_PTL__r.name,						
                    Opportunity_PTL__r.Mandataire__c, 
                    Opportunity_PTL__r.Activity_Domain__c, 
                    Opportunity_PTL__r.Opportunity__r.Project_Type__c,
                    Opportunity_PTL__r.Opportunity__r.DO_Name__c,
                    Opportunity_PTL__r.Opportunity__r.Client_Type__c,
                    Opportunity_PTL__r.Opportunity__r.DO_Market_Type__c,
                    Opportunity_PTL__r.PTL_Label__c,
                    Opportunity_PTL__r.PTL_Street_number__c,
                    Opportunity_PTL__r.PTL_Number_extention__c,
                    Opportunity_PTL__r.PTL_Street_type__c,
                    Opportunity_PTL__r.PTL_Street_name__c,
                    Opportunity_PTL__r.PTL_Place_Called__c,
                    Opportunity_PTL__r.PTL_Postal_Box__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__r.Postal_Code__c,
                    Opportunity_PTL__r.DepartmentFormula__c,
                    Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.INSEE_Code__c,
                    Opportunity_PTL__r.opportunity__r.DO_Language__c,
                    Opportunity_PTL__r.PTL_Phone__c,
                    Opportunity_PTL__r.PTL_Mobile_Phone_Number__c,
                    Opportunity_PTL__r.PTL_Work_Phone_Number__c,
                    Opportunity_PTL__r.PTL_Fax_Number__c,
                    Opportunity_PTL__r.opportunity__r.account.Phone_Restriction__c,
                    Opportunity_PTL__r.Fiscal_class_PTL__c,
                    Opportunity_PTL__r.PTL_Code_NACE__r.ExternalID__c,
                    Opportunity_PTL__r.opportunity__r.account.Code_SIRET__c,
                    Opportunity_PTL__r.opportunity__r.ReferenceClientSAP__c,
                    Quote__r.Product_Scale_Code__c,
                    Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c,
                    Opportunity_PTL__r.PTL_Shipping_Condition__c,
                    Opportunity_PTL__r.PTL_Shipping_Priority__c,
                    Opportunity_PTL__r.Call_client_before_delivery__c,
                    Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c,
                    Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c,
                    Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c,
                    Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c,
                    Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c,
                    Opportunity_PTL__r.Opty_PTL_Geolocation__latitude__s,
                    Opportunity_PTL__r.Opty_PTL_Geolocation__longitude__s,
                    Opportunity_PTL__r.opportunity__r.Opportunity_Reason__c,
                    Opportunity_PTL__r.State_Synchro_To_SAP__c,
                    Opportunity_PTL__r.Opportunity__r.Account.Name,
                    Opportunity_PTL__r.PTL__r.Shipping_Condition__c,
                    Estimated_Consumption__c, Opportunity_PTL__r.Valeur_limitation_tonnage__c,
                    Opportunity_PTL__r.opportunity__r.T_Pack__c  
                    from Quote_PTL__c where Quote__c IN :q];
                }


                //FIN liste des QPTL associés au devis
                system.debug('lQPTL freddy:'+lQPTL);

                //init optl en cas d'exception
                for(Quote_PTL__c qptl:lQPTL)
                    lIdOPTL.put(qptl.Opportunity_PTL__c, null);
                system.debug('MSG4');
                
                for(Quote_PTL__c qptl:lQPTL)
                {
                    BAPITracker__c oBapiTrackerPTL = new BAPITracker__c();
                    microsoftLobservicesSapPTL200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapPTL200703Types.ArrayOfBAPIRET2();
                    //liste OPTL
                    microsoftLobservicesSapPTL200703Types.ArrayOfZBAPI_CRM_PTL IT_PTL = new microsoftLobservicesSapPTL200703Types.ArrayOfZBAPI_CRM_PTL();
                    list<microsoftLobservicesSapPTL200703Types.ZBAPI_CRM_PTL> lZBAPI_CRM_PTL = new list<microsoftLobservicesSapPTL200703Types.ZBAPI_CRM_PTL>(); 

                    microsoftLobservicesSapPTL200703Types.ZBAPI_CRM_PTL ZBAPI_CRM_PTL = new microsoftLobservicesSapPTL200703Types.ZBAPI_CRM_PTL();
                    system.debug('MSG5');
                
                    if(q[0].Market_type__c == 'PRO')
                        ZBAPI_CRM_PTL.NAME3 = mention_comp;
                    system.debug('MSG6');
                
                    if(q[0].Market_type__c == 'PRO')
                        ZBAPI_CRM_PTL.ZCOD_TIT = mapTaRefSfSap.get(q[0].account.Salutation__c);
                    if(q[0].Market_type__c == 'DOM')
                    {
                        if(q[0].account.Salutation == 'M. & Mrs')
                            ZBAPI_CRM_PTL.ZCOD_TIT = 'M';
                        else    
                            ZBAPI_CRM_PTL.ZCOD_TIT = mapTaRefSfSap.get(q[0].account.Salutation);
                    }

                    String name1 = qptl.Opportunity_PTL__r.Opportunity__r.DO_Name__c;  
                    if(q[0].Market_type__c == 'DOM')
                    {
                        if(q[0].account.Salutation == 'M. & Mrs')
                            name1 = 'ET MME '+name1;                   
                    }

                    system.debug('name1:'+name1);
                    
                    if(name1.length() > 30) name1 = name1.substring(0, 30);
                    ZBAPI_CRM_PTL.NAME1 = name1;
                    ZBAPI_CRM_PTL.NAME2 = '.';
                    system.debug('MSG33');

                    if((qptl.Opportunity_PTL__r.PTL_Street_number__c!='')&&(qptl.Opportunity_PTL__r.PTL_Street_number__c!=null))
                    {
                        if(qptl.Opportunity_PTL__r.PTL_Street_number__c.length()<5)
                            ZBAPI_CRM_PTL.ZNUM_VOIE = Integer.valueof(qptl.Opportunity_PTL__r.PTL_Street_number__c);
                        else
                        {
                            String numVoie = qptl.Opportunity_PTL__r.PTL_Street_number__c.substring(0,4);
                            ZBAPI_CRM_PTL.ZNUM_VOIE = Integer.valueof(qptl.Opportunity_PTL__r.PTL_Street_number__c);
                        }
                    }
                    system.debug('MSG34');

                    ZBAPI_CRM_PTL.ZCOD_COMP = qptl.Opportunity_PTL__r.PTL_Number_extention__c;
                    ZBAPI_CRM_PTL.ZCOD_VOIE = qptl.Opportunity_PTL__r.PTL_Street_type__c;
                    system.debug('MSG35');
                    //ZBAPI_CRM_PTL.ZNOM_VOIE = q[0].Opportunity.Street_name_project__c;
                    //ZBAPI_CRM_PTL.ORT02 = q[0].Opportunity.Lieu_dit_Project__c;
                                         
                    
                    String nomVoie = qptl.Opportunity_PTL__r.PTL_Street_name__c;
					if(nomVoie!=null)
                    {
                        if(nomVoie.length()>27) ZBAPI_CRM_PTL.ZNOM_VOIE = nomVoie.substring(0,27); 
                        else ZBAPI_CRM_PTL.ZNOM_VOIE = nomVoie;
                    }
                    
                    String lieuDit = qptl.Opportunity_PTL__r.PTL_Place_Called__c;
					if(lieuDit!=null)
                    {
                        if(lieuDit.length()>35) ZBAPI_CRM_PTL.ORT02 = lieuDit.substring(0,35); 
                        else ZBAPI_CRM_PTL.ORT02 = lieuDit;
                    }
                    
                    system.debug('MSG4');

                    if((qptl.Opportunity_PTL__r.PTL_Postal_Box__c!='')&&(qptl.Opportunity_PTL__r.PTL_Postal_Box__c!=null))
                    {
                        String boitePostal = qptl.Opportunity_PTL__r.PTL_Postal_Box__c;
                        if((boitePostal!='')&&(boitePostal!=null))
                            if(boitePostal.length() > 10) boitePostal = boitePostal.substring(0, 10);
                        ZBAPI_CRM_PTL.PFACH = boitePostal;
                    }

                    String codePostal = qptl.Opportunity_PTL__r.PTL_City_Postal_Code__r.Postal_Code__c;
                    system.debug('codePostal:'+codePostal);
                    
					if(codePostal!=null && codePostal!= '')
                    {    
                        if(codePostal.length()>5) ZBAPI_CRM_PTL.PSTLZ = codePostal.substring(0, 5);
                        else ZBAPI_CRM_PTL.PSTLZ = codePostal;
                    }
                    ZBAPI_CRM_PTL.REGIO = qptl.Opportunity_PTL__r.DepartmentFormula__c;
                    system.debug('qptl.Opportunity_PTL__r.DepartmentFormula__c:'+qptl.Opportunity_PTL__r.DepartmentFormula__c);
                    
                    if((qptl.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.INSEE_Code__c!='')&&(qptl.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.INSEE_Code__c!=null))
                    {
                        String codeINSEE = qptl.Opportunity_PTL__r.PTL_City_Postal_Code__r.City__r.INSEE_Code__c;
                        ZBAPI_CRM_PTL.CITYC = codeINSEE.substring(codeINSEE.length() - 3);
                    }
                    ZBAPI_CRM_PTL.LAND1 = 'FR';
                    ZBAPI_CRM_PTL.SPRAS = 'F';

                    if(qptl.Opportunity_PTL__r.PTL_Phone__c!='' && qptl.Opportunity_PTL__r.PTL_Phone__c!=null)
                        ZBAPI_CRM_PTL.TELF1 = qptl.Opportunity_PTL__r.PTL_Phone__c;
                    else
                        ZBAPI_CRM_PTL.TELF1 = q[0].Opportunity.DO_Phone__c;

                    if(qptl.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c!='' && qptl.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c!=null)
                        ZBAPI_CRM_PTL.TELF3 = qptl.Opportunity_PTL__r.PTL_Mobile_Phone_Number__c;
                    else
                        ZBAPI_CRM_PTL.TELF3 = q[0].Opportunity.DO_Mobile_Phone_Number__c;

                    if(qptl.Opportunity_PTL__r.PTL_Work_Phone_Number__c!='' && qptl.Opportunity_PTL__r.PTL_Work_Phone_Number__c!=null)
                        ZBAPI_CRM_PTL.TELF2 = qptl.Opportunity_PTL__r.PTL_Work_Phone_Number__c;
                    else
                        ZBAPI_CRM_PTL.TELF2 = q[0].Opportunity.DO_Work_Phone_Number__c;

                    if(qptl.Opportunity_PTL__r.PTL_Fax_Number__c!='' && qptl.Opportunity_PTL__r.PTL_Fax_Number__c!=null)
                        ZBAPI_CRM_PTL.TELFX = qptl.Opportunity_PTL__r.PTL_Fax_Number__c;
                    else
                        ZBAPI_CRM_PTL.TELFX = q[0].Opportunity.DO_Fax__c;

                    ZBAPI_CRM_PTL.ZREST_TEL = qptl.Opportunity_PTL__r.opportunity__r.account.Phone_Restriction__c;
                    ZBAPI_CRM_PTL.TAXKD = q[0].VAT_code__c;
                    ZBAPI_CRM_PTL.BRAN1 = qptl.Opportunity_PTL__r.PTL_Code_NACE__r.ExternalID__c;
                    system.debug('BRAN1:'+qptl.Opportunity_PTL__r.PTL_Code_NACE__r.ExternalID__c);                    
                    ZBAPI_CRM_PTL.STCD1 = qptl.Opportunity_PTL__r.opportunity__r.account.Code_SIRET__c;

                    ZBAPI_CRM_PTL.PROP_PL = qptl.Opportunity_PTL__r.opportunity__r.ReferenceClientSAP__c;
                    ZBAPI_CRM_PTL.BZIRK = qptl.Quote__r.Product_Scale_Code__c;

                    system.debug('MSG22');                    
                    
                    system.debug('VKGRP Code_AC_administrator_New__r.Code_Groupe_Vendeur__c:'+qptl.Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c);                    
                    ZBAPI_CRM_PTL.VKGRP = qptl.Opportunity_PTL__r.Code_AC_administrator_New__r.Code_Groupe_Vendeur__c;

                    //condition expedition ECOCFT
                    String condExpedition = qptl.Opportunity_PTL__r.PTL_Shipping_Condition__c;

                    if(qptl.Opportunity_PTL__r.opportunity__r.T_Pack__c == 'ECOCFT' || condExpedition == '05' &&
                        ((q[0].Project_Type__c == 'CREA')||(q[0].Project_Type__c == 'EXTE')))
                        condExpedition = '02';       
                    else if(q[0].Project_Type__c == 'SUCC' && condExpedition == '05')    
                    {
                        //recupere ptl existant sur l'optl
                        if(qptl.Opportunity_PTL__r.PTL__r.Shipping_Condition__c == '02')
                            condExpedition = '02';
                        if(qptl.Opportunity_PTL__r.PTL__r.Shipping_Condition__c == '04')
                            condExpedition = '04';
                    }                        

                    ZBAPI_CRM_PTL.VSBED = condExpedition;
                    
                    if(q[0].Opportunity.Activity_Domain__c == 'GEC - Gaz en citerne')
                        ZBAPI_CRM_PTL.LPRIO = Integer.valueOf('02');
                    else if((qptl.Opportunity_PTL__r.PTL_Shipping_Priority__c!='')&&(qptl.Opportunity_PTL__r.PTL_Shipping_Priority__c!=null))
                    {
                        String shiPrio = qptl.Opportunity_PTL__r.PTL_Shipping_Priority__c;
                        if((shiPrio!='')&&(shiPrio!=null))
                            ZBAPI_CRM_PTL.LPRIO = Integer.valueOf(qptl.Opportunity_PTL__r.PTL_Shipping_Priority__c);
                    }    
                    
                    ZBAPI_CRM_PTL.ZCOD_RECR =  mapTaRefSfSap.get(qptl.Opportunity_PTL__r.opportunity__r.Opportunity_Reason__c);               

                    if(qptl.Opportunity_PTL__r.Call_client_before_delivery__c == true)
                        ZBAPI_CRM_PTL.ZAPP_LIV = 'X';
                    system.debug('MSG23');
                    //pas utilisé dans SF et non required dans SAP
                    //ZBAPI_CRM_PTL.ZDEB_LIV = qptl.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_Start__c;
                    //ZBAPI_CRM_PTL.ZFIN_LIV = qptl.Opportunity_PTL__r.PTL_Seasonal_Date_of_Period_End__c;
                    
                    //ZBAPI_CRM_PTL.ZCONSO_AN = qptl.Opportunity_PTL__r.PTL_Etimated_or_Real_Consumption__c;
                    Decimal consoEstimated =  qptl.Estimated_Consumption__c;   
                    OrganizationSettings__c orgSetting = [SELECT Tons_To_KWH__c FROM OrganizationSettings__c];
                    Decimal kwToTone = orgSetting.Tons_To_KWH__c;
                    if(qptl.Opportunity_PTL__r.opportunity__r.T_Pack__c == 'ECOCFT')//conversion kw en t
                        consoEstimated = consoEstimated/kwToTone;
                    ZBAPI_CRM_PTL.ZCONSO_AN = consoEstimated.setScale(3);
                    
                    system.debug('consoEstimated.setScale(3):'+consoEstimated.setScale(3));

                    ZBAPI_CRM_PTL.ZREST_VEH = qptl.Opportunity_PTL__r.PTL_Limitation_of_Vehicle__c;
                    if(qptl.Opportunity_PTL__r.PTL_Limitation_of_Tonnage__c == true)
                    {
                        ZBAPI_CRM_PTL.ZLIMTON = 'X';
                        ZBAPI_CRM_PTL.ZVALLIM = qptl.Opportunity_PTL__r.Valeur_limitation_tonnage__c;
                    }
                    ZBAPI_CRM_PTL.ZLONGIT = String.valueOf(qptl.Opportunity_PTL__r.Opty_PTL_Geolocation__longitude__s);
                    ZBAPI_CRM_PTL.ZLATITD = String.valueOf(qptl.Opportunity_PTL__r.Opty_PTL_Geolocation__latitude__s);
                    system.debug('MSG24');                    
                    //DEBUT profil de consommation
                    LIST<PTL_Consumption_Profile__c> lconso = [select Id, Quote_PTL_del__c,
                    consumption_variable_jan__c, consumption_variable_feb__c, consumption_variable_mar__c, 
                    consumption_variable_apr__c, consumption_variable_may__c, consumption_variable_jun__c,
                    consumption_variable_jul__c, consumption_variable_aug__c, consumption_variable_sep__c,
                    consumption_variable_oct__c, consumption_variable_nov__c, consumption_variable_dec__c,
                    consumption_fixed_jan__c, consumption_fixed_feb__c, consumption_fixed_mar__c,
                    consumption_fixed_apr__c, consumption_fixed_may__c, consumption_fixed_jun__c,
                    consumption_fixed_jul__c, consumption_fixed_aug__c, consumption_fixed_sep__c,
                    consumption_fixed_oct__c, consumption_fixed_nov__c, consumption_fixed_dec__c
                    from PTL_Consumption_Profile__c where Quote_PTL_del__c = :qptl.Id];
                    system.debug('MSG25');
                    if(lconso.size()>0)
                    {
                    system.debug('lconso.size()>0');
                        ZBAPI_CRM_PTL.CONSO_H_01 = lconso[0].consumption_variable_jan__c;
                        ZBAPI_CRM_PTL.CONSO_H_02 = lconso[0].consumption_variable_feb__c;
                        ZBAPI_CRM_PTL.CONSO_H_03 = lconso[0].consumption_variable_mar__c;
                        ZBAPI_CRM_PTL.CONSO_H_04 = lconso[0].consumption_variable_apr__c;
                        ZBAPI_CRM_PTL.CONSO_H_05 = lconso[0].consumption_variable_may__c;
                        ZBAPI_CRM_PTL.CONSO_H_06 = lconso[0].consumption_variable_jun__c;
                        ZBAPI_CRM_PTL.CONSO_H_07 = lconso[0].consumption_variable_jul__c;
                        ZBAPI_CRM_PTL.CONSO_H_08 = lconso[0].consumption_variable_aug__c;
                        ZBAPI_CRM_PTL.CONSO_H_09 = lconso[0].consumption_variable_sep__c;
                        ZBAPI_CRM_PTL.CONSO_H_10 = lconso[0].consumption_variable_oct__c;
                        ZBAPI_CRM_PTL.CONSO_H_11 = lconso[0].consumption_variable_nov__c;
                        ZBAPI_CRM_PTL.CONSO_H_12 = lconso[0].consumption_variable_dec__c;

                        ZBAPI_CRM_PTL.CONSO_US_01 = lconso[0].consumption_fixed_jan__c;
                        ZBAPI_CRM_PTL.CONSO_US_02 = lconso[0].consumption_fixed_feb__c;
                        ZBAPI_CRM_PTL.CONSO_US_03 = lconso[0].consumption_fixed_mar__c;
                        ZBAPI_CRM_PTL.CONSO_US_04 = lconso[0].consumption_fixed_apr__c;
                        ZBAPI_CRM_PTL.CONSO_US_05 = lconso[0].consumption_fixed_may__c;
                        ZBAPI_CRM_PTL.CONSO_US_06 = lconso[0].consumption_fixed_jun__c;
                        ZBAPI_CRM_PTL.CONSO_US_07 = lconso[0].consumption_fixed_jul__c;
                        ZBAPI_CRM_PTL.CONSO_US_08 = lconso[0].consumption_fixed_aug__c;
                        ZBAPI_CRM_PTL.CONSO_US_09 = lconso[0].consumption_fixed_sep__c;
                        ZBAPI_CRM_PTL.CONSO_US_10 = lconso[0].consumption_fixed_oct__c;
                        ZBAPI_CRM_PTL.CONSO_US_11 = lconso[0].consumption_fixed_nov__c;
                        ZBAPI_CRM_PTL.CONSO_US_12 = lconso[0].consumption_fixed_dec__c;
                    }    
                    //FIN profil de consommation
                    system.debug('MSG26');                    
                    //add 
                    lZBAPI_CRM_PTL.add(ZBAPI_CRM_PTL);
                    IT_PTL.ZBAPI_CRM_PTL = lZBAPI_CRM_PTL;
                    system.debug('MSG27');
                    
                    //DEF ACTION
                    String action = currentMatriceSAP.PTL;
                    system.debug('>>>action PTL:'+action); 
                    //crea locataire
                    if(action == 'CREA' && typeProjet == 'CREARENTER')
                        action = 'MODI';

                    
                    system.debug('qptl.Opportunity_PTL__r.Name:'+qptl.Opportunity_PTL__r.Name); 
                    system.debug('q[0].account.Mandataire__r.ExternalID__c:'+q[0].account.Mandataire__r.ExternalID__c); 
                    /*
                    String oldEndPoint =  callBAPI.endpoint_x;
                    system.debug('Account oldEndPoint:'+oldEndPoint);
                    //appel endpoint trace
                    callBAPI.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';
                    
    
                    response = callBAPI.ZBAPI_CRM_PTL(action, '02', qptl.Opportunity_PTL__r.Name, String.valueOf(q[0].account.Mandataire__r.ExternalID__c),
                    typeProjet, qptl.Opportunity_PTL__r.PTL__r.ExternalID__c, String.valueOf(q[0].opportunity.Account.Activity_Domain__r.ExternalID__c),
                    ET_RETURN, IT_PTL); 
    
                    //appel SAP
                    callBAPI.endpoint_x = oldEndPoint;
                    */
                    response = callBAPI.ZBAPI_CRM_PTL(action, '02', qptl.Opportunity_PTL__r.Name, String.valueOf(q[0].account.Mandataire__r.ExternalID__c),
                    typeProjet, qptl.Opportunity_PTL__r.PTL__r.ExternalID__c, String.valueOf(q[0].opportunity.Account.Activity_Domain__r.ExternalID__c),
                    ET_RETURN, IT_PTL); 
                    
                    system.debug('response:'+response);   
                
                    microsoftLobservicesSapPTL200703Types.ArrayOfBAPIRET2 ET_RETURNSAP = response.ET_RETURN;
                    list<microsoftLobservicesSapPTL200703Types.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;

                    String errorMessage = '';
                    for(microsoftLobservicesSapPTL200703Types.BAPIRET2 b:BAPIRET2)
                        errorMessage = errorMessage +'#'+b.MESSAGE;
            
                    //oBapiTrackerPTL
                    oBapiTrackerPTL.Response1__c = JSON.serialize(response);
                    oBapiTrackerPTL.Endpoint__c = callBAPI.endpoint_x;   
                    oBapiTrackerPTL.Message__c = errorMessage;
                    oBapiTrackerPTL.Request__c = callBAPI.request;
                    oBapiTrackerPTL.User__c = UserInfo.getUserId();
                    this.loBapiTracker.add(oBapiTrackerPTL);

                    if((this.statusContinueProcess==true)&&(response.EX_CONTROL=='KO'))                        
                        this.statusContinueProcess = false;

                    system.debug('this.statusContinueProcess :'+this.statusContinueProcess);

                    lIdOPTL.put(qptl.Opportunity_PTL__c, new responseSAP(response.EX_CONTROL, response.EX_PTL, errorMessage));

                    for (Id key : lIdOPTL.keySet()) 
                        system.debug('PAS EXCEPTION key:'+key+'## value:'+lIdOPTL.get(key));    
                }//fin boucle for

                //INSERT TRACKER
                if (this.sStoreTracker.toLowercase() == 'true') upsert this.loBapiTracker;

                //DEBUT MAJ OPTL
                loptl = [select Id, PTL_Label__c, Name, PTLSynchroSAP__c, State_Synchro_To_SAP__c, Error_Synchro_To_SAP__c from Opportunity_PTL__c where Id IN :lIdOPTL.keyset()];
                system.debug('PAS EXCEPTION :'+loptl);
                
                for(Opportunity_PTL__c optl:loptl)
                {
                    optl.State_Synchro_To_SAP__c = lIdOPTL.get(optl.Id).EX_CONTROL;
                    optl.Error_Synchro_To_SAP__c = lIdOPTL.get(optl.Id).lERROR;
                    optl.PTLSynchroSAP__c = lIdOPTL.get(optl.Id).EX_PTL;
                }
                update loptl;
                //FIN MAJ OPTL

                mapOPTL.put('ListOPTL', loptl);

            }        
            return mapOPTL;

        }catch (Exception e) 
        {
            this.statusContinueProcess = false;
            system.debug('>>>class AP_WrapperForSOAPCallPTL:'+e.getMessage());
            system.debug('>>>response:'+response);

            //DEBUT MAJ OPTL
            loptl = [select Id, PTL_Label__c, Name, PTLSynchroSAP__c, State_Synchro_To_SAP__c, Error_Synchro_To_SAP__c from Opportunity_PTL__c where Id IN :lIdOPTL.keyset()];
            for(Opportunity_PTL__c optl:loptl)
            {
                optl.State_Synchro_To_SAP__c = 'KO';
                optl.Error_Synchro_To_SAP__c = e.getMessage();
            }    
			update loptl;
            system.debug('Exception loptl:'+loptl);


            //oBapiTracker
            this.oBapiTracker.Response1__c = JSON.serialize(response);
            this.oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
            this.oBapiTracker.Message__c = e.getMessage();
            this.oBapiTracker.Request__c = callBAPI.request;
            this.oBapiTracker.User__c = UserInfo.getUserId() ;
            if (this.sStoreTracker.toLowercase() == 'true') upsert this.oBapiTracker;

            Map<String, list<Opportunity_PTL__c>> mapOPTL = new Map<String, list<Opportunity_PTL__c>>(); 
            mapOPTL.put('ListOPTL', loptl);

            return mapOPTL;
        } 
    }

    public class responseSAP
    {
        public String EX_CONTROL;
        public String EX_PTL;
        public String lERROR;
        
        public responseSAP(String EX_CONTROL, String EX_PTL, String lERROR)
        {
                this.EX_CONTROL = EX_CONTROL;
                this.EX_PTL = EX_PTL;
                this.lERROR = lERROR;
        }
    }


}