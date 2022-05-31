public class AP_WrapperForSOAPCallAccount {

    public Boolean statusContinueProcess;
    public BAPITracker__c oBapiTracker {get;set;}
    public String sStoreTracker {get;set;}

    public AP_WrapperForSOAPCallAccount() {
    }

    public Map<String, list<Account>> Send_Account_TO_SAP(String IdQuote, matriceSAP currentMatriceSAP)
    {
        system.debug('Send_Account_TO_SAP');
        this.oBapiTracker = new BAPITracker__c();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');

        Map<String, responseSAP> lIdACC = new Map<String, responseSAP>();
        list<Account> lAccount = new list<Account>();
        list<Quote> q = new list<Quote>();
        //Boolean statusContinue = true;
        this.statusContinueProcess = true;
        Boolean originalBypassVRvalue;
        Boolean originalBypassWFvalue;
        Boolean originalBypassEmailNoEmailvalue;
        //Boolean IsException = false;
        String errorMessage = '';
        microsoftLobservicesSapACC200703.RfcEndpoint callBAPI = new microsoftLobservicesSapACC200703.RfcEndpoint();
        microsoftLobservicesSapACC200703Rfc.ZBAPI_CRM_COMPTEResponse_element response = new microsoftLobservicesSapACC200703Rfc.ZBAPI_CRM_COMPTEResponse_element();
        try {

            
            //DEVIS (bareme produit, type de marché)
            q = [select Id, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
                            Client_Type__c, Account.name, account.salutation, Market_type__c, opportunity.Account.Activity_Domain__r.ExternalID__c,
                            Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, Product_Scale_Code__c, 
                            Shipping_Condition__c, Facturation_calendar__c, DO_Payment_method__c, 
                            Opportunity.DO_Accounting_Manager__r.Code__c, Opportunity.Account_Payer__r.accountnumber, Opportunity.DO_Code_SIRET__c,
                            Opportunity.Contract_Start_Date__c, Opportunity.Account_Billed__r.accountnumber, Opportunity.PA_DO__c, Opportunity.FA_DO__c, Opportunity.DO_Name__c, 
                            Opportunity.DO_Recovery_procedures__c, Opportunity.Predecessor__c, Opportunity.Function_quality__c,
                 			Payment_spread__c, DO_Groupement__r.accountnumber, Scale__c, account.Salutation__c, account.PersonContactId, DO_Groupement__c, Scale_Code__c, Opportunity.Account.name       
                            , opportunity.DO_Street_name__c, opportunity.DO_Lieu_dit__c, opportunity.DEMAT1__c, opportunity.DEMAT2__c 
                             from Quote where Id= :IdQuote limit 1];

            system.debug('q:'+q);

            if(q.size()>0)
            {
                //debut chargement custom metadata Table_Ref_SF_SAP__mdt
                list<Table_Ref_SF_SAP__mdt> tabRefSFSap = [select Id, MasterLabel, DeveloperName, Code_SAP_Salutation__c from Table_Ref_SF_SAP__mdt];
                Map<String, String> mapTaRefSfSap = new Map<String, String>();
                for(Table_Ref_SF_SAP__mdt t:tabRefSFSap)
                {
                    mapTaRefSfSap.put(t.MasterLabel, t.Code_SAP_Salutation__c); 
                    //system.debug(t.MasterLabel+'##'+t.DeveloperName);
                }
                //fin chargement custom metadata Table_Ref_SF_SAP__mdt

                //DEBUT si PRO, calcul mention complémentaire
                String mention_comp='';
                if(q[0].Market_type__c == 'PRO')
                {       
                    String civilite = q[0].Contact.salutation;
                    system.debug('civilite:'+civilite);
                    system.debug('map civilite:'+mapTaRefSfSap.get(civilite));
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

                system.debug('mention_comp:'+mention_comp);

                //definition du type de projet
                String typeProjet = (q[0].Project_Type__c  + q[0].Client_Type__c).toUpperCase();
                system.debug('typeProjet:'+typeProjet);

                lAccount = [select Id, AccountNumber, name, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, 
                Mandataire__r.ExternalID__c, Activity_Domain__r.ExternalID__c,
                Street_N__c, Number_extention__c, Street_type__c, Street_name__c, Place_Called__c,
                Lieu_dit__c, Postal_Box__c, Postal_Code__c, Department__c, City_Postal_Code__r.City__r.INSEE_Code__c, 
                Price_information__c, Code_SIRET__c, Adherent_Central_Number__c, Invoicing_Frequency__c, 
                Compte_Superieur__c, Fonction_Qualite__c, Phone, Mobile_Phone_Number__c, Work_Phone_Number__c, 
                Fax, Phone_Restriction__c, Email__c, Email_2__c, No_E_mail__c, Optin_1__c, Optin_2__c, 
                Demat1_chorus__c, Demat2_chorus__c, Salutation__c,City_Postal_Code__r.Postal_Code__c, Status__c, Country__c, city__c   
                from Account where Id = :q[0].AccountId];
                
                //DEF ACTION
                String action = currentMatriceSAP.sDO;
                system.debug('>>>action PTL:'+action);                 
                
                //BAPI SAP
                microsoftLobservicesSapACC200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapACC200703Types.ArrayOfBAPIRET2();
                microsoftLobservicesSapACC200703Types.ArrayOfZBAPI_CRM_COMPTE IT_COMPTE = new microsoftLobservicesSapACC200703Types.ArrayOfZBAPI_CRM_COMPTE();
                list<microsoftLobservicesSapACC200703Types.ZBAPI_CRM_COMPTE> lZBAPI_CRM_COMPTE = new list<microsoftLobservicesSapACC200703Types.ZBAPI_CRM_COMPTE>(); 
                microsoftLobservicesSapACC200703Types.ZBAPI_CRM_COMPTE ZBAPI_CRM_COMPTE = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_COMPTE(); 
                system.debug('MSG1');
                if(q[0].Market_type__c == 'PRO')
                {
                    String name1 = q[0].Opportunity.DO_Name__c;
                    system.debug('name1 PRO:'+name1);                
                    if(name1.length() > 30)
                        ZBAPI_CRM_COMPTE.NAME1 = name1.substring(0, 30); 
                    else
                        ZBAPI_CRM_COMPTE.NAME1 = name1; 

                    String name2 = q[0].Opportunity.Function_quality__c;
                    if(name2 != null)
                    {
                        if(name2.length() > 35 ) name2 = name2.substring(0, 35);
                        ZBAPI_CRM_COMPTE.NAME2 = name2;
                    }    
                    ZBAPI_CRM_COMPTE.NAME3 = mention_comp;
                }
                
                
                if(q[0].Market_type__c == 'DOM')
                {
                    String personContactId = q[0].account.PersonContactId;
                    system.debug('personContactId:'+personContactId);
                    Contact con = [select Id, Salutation from Contact where Id= :personContactId];
                    system.debug('con.Salutation:'+con.Salutation);
                    system.debug('mapTaRefSfSap.get(con.Salutation):'+mapTaRefSfSap.get(con.Salutation));
                    if(con.Salutation == 'M. & Mrs')
	                    ZBAPI_CRM_COMPTE.ZCOD_TIT = 'M';
                    else
                        ZBAPI_CRM_COMPTE.ZCOD_TIT = mapTaRefSfSap.get(con.Salutation);

                    String name1 = q[0].Opportunity.DO_Name__c;
                    if(con.Salutation == 'M. & Mrs')
                        name1 = 'ET MME '+name1;                   
                    system.debug('name1 DOM:'+name1);                
                    if(name1.length() > 30)
                        ZBAPI_CRM_COMPTE.NAME1 = name1.substring(0, 30); 
                    else
                        ZBAPI_CRM_COMPTE.NAME1 = name1; 

                    String name2 = q[0].Opportunity.Function_quality__c;
                    if(name2 != null)
                    {
                        if(name2.length() > 35 ) name2 = name2.substring(0, 35);
                        ZBAPI_CRM_COMPTE.NAME2 = name2;
                    }    
                }    

                system.debug('ZBAPI_CRM_COMPTE.ZCOD_TIT:'+ZBAPI_CRM_COMPTE.ZCOD_TIT);
                system.debug('ZBAPI_CRM_COMPTE.NAME1:'+ZBAPI_CRM_COMPTE.NAME1);
                system.debug('ZBAPI_CRM_COMPTE.NAME2:'+ZBAPI_CRM_COMPTE.NAME2);

                if((lAccount[0].Street_N__c!='')&&(lAccount[0].Street_N__c!=null))
                    ZBAPI_CRM_COMPTE.ZNUM_VOIE = Integer.valueof(lAccount[0].Street_N__c);
                ZBAPI_CRM_COMPTE.ZCOD_COMP = lAccount[0].Number_extention__c;
                ZBAPI_CRM_COMPTE.ZCOD_VOIE = lAccount[0].Street_type__c;
                system.debug('lAccount[0].Street_type__c:'+lAccount[0].Street_type__c);                
                system.debug('MSG2');                
                
                ZBAPI_CRM_COMPTE.ZNOM_VOIE = q[0].opportunity.DO_Street_name__c;
                ZBAPI_CRM_COMPTE.ORT02 = q[0].opportunity.DO_Lieu_dit__c;
               

                system.debug('MSG4:');

                String boitePostal = lAccount[0].Postal_Box__c;
                if((boitePostal!=null)&&(boitePostal!=''))
                    if(boitePostal.length() > 10) boitePostal = boitePostal.substring(0, 10);
                ZBAPI_CRM_COMPTE.PFACH = boitePostal;
                
                String IdcodePostal = lAccount[0].City_Postal_Code__c;
                if((IdcodePostal!='')&&(IdcodePostal!=null))                
                {                
                    system.debug('ADRESSE FRANCAISE');
                    String codePostal = lAccount[0].City_Postal_Code__r.Postal_Code__c;
                    ZBAPI_CRM_COMPTE.PSTLZ = codePostal;
                    //ZBAPI_CRM_COMPTE.REGIO = codePostal.substring(0, 2);
                    String codeINSEE = lAccount[0].City_Postal_Code__r.City__r.INSEE_Code__c;  
                    String codeINSEECodePostal = '';
                    String codeINSEEcity = '';
                    if((codeINSEE!=null)&&(codeINSEE!=''))
                    {    
                        if(codeINSEE.length() > 3) codeINSEEcity = codeINSEE.substring(codeINSEE.length() - 3);
                        if(codeINSEE.length() > 2) codeINSEECodePostal = codeINSEE.substring(0, 2);

                    }
                    ZBAPI_CRM_COMPTE.REGIO = codeINSEECodePostal;
                    ZBAPI_CRM_COMPTE.CITYC = codeINSEEcity;
                    ZBAPI_CRM_COMPTE.LAND1 = 'FR';


                }
                else if(lAccount[0].Country__c == 'FR')
                {
                    system.debug('ADRESSE FRANCAISE NON TROUVE');

                    String codePostal = lAccount[0].Postal_Code__c;
                    if((codePostal!=null)&&(codePostal!=''))
                        if(codePostal.length() > 5) codePostal = codePostal.substring(0, 5);
                    ZBAPI_CRM_COMPTE.PSTLZ = codePostal;
                    ZBAPI_CRM_COMPTE.REGIO = codePostal.substring(0, 2);
                    ZBAPI_CRM_COMPTE.CITYC = lAccount[0].Country__c;                    
                    ZBAPI_CRM_COMPTE.LAND1 = 'FR';
                    //ZBAPI_CRM_COMPTE.CITY1 = lAccount[0].city__c;

                }
                else
                {
                    system.debug('ADRESSE ETRANGERE');
                    system.debug('ADRESSE ETRANGERE:'+lAccount[0].Country__c);

                    String codePostal = lAccount[0].Postal_Code__c;
                    if((codePostal!=null)&&(codePostal!=''))
                        if(codePostal.length() > 10) codePostal = codePostal.substring(0, 10);
                    ZBAPI_CRM_COMPTE.PSTLZ = codePostal;
                    ZBAPI_CRM_COMPTE.REGIO = lAccount[0].Country__c;
                    ZBAPI_CRM_COMPTE.CITYC = lAccount[0].Country__c;                    
                    ZBAPI_CRM_COMPTE.LAND1 = lAccount[0].Country__c;
                    String city = lAccount[0].city__c;
                    if((city!=null)&&(city!=''))
                        if(city.length() > 40) city = city.substring(0, 40);
                    ZBAPI_CRM_COMPTE.CITY1 = city;
                }
               
                ZBAPI_CRM_COMPTE.SPRAS = 'F';
                system.debug('MSG5:');

                String priceInfo = lAccount[0].Price_information__c;
                if((priceInfo!='')&&(priceInfo!=null))
                    ZBAPI_CRM_COMPTE.ZMODE_INF = Integer.valueof(lAccount[0].Price_information__c);
                ZBAPI_CRM_COMPTE.TELF1 = lAccount[0].Phone;
                ZBAPI_CRM_COMPTE.TELF3 = lAccount[0].Mobile_Phone_Number__c;
                ZBAPI_CRM_COMPTE.TELF2 = lAccount[0].Work_Phone_Number__c;
                ZBAPI_CRM_COMPTE.TELFX = lAccount[0].Fax;
                ZBAPI_CRM_COMPTE.ZREST_TEL = lAccount[0].Phone_Restriction__c;
                ZBAPI_CRM_COMPTE.EMAIL = lAccount[0].Email__c;
                ZBAPI_CRM_COMPTE.EMAIL2 = lAccount[0].Email_2__c;
                if(lAccount[0].No_E_mail__c == true)
                    ZBAPI_CRM_COMPTE.ZPAS_EMAIL = 'X';
                if(lAccount[0].Optin_1__c == true)
                    ZBAPI_CRM_COMPTE.ZOPT = 'X';
                if(lAccount[0].Optin_2__c == true)
                    ZBAPI_CRM_COMPTE.ZOP2 = 'X';
                if((q[0].opportunity.DEMAT1__c == false)||(q[0].opportunity.DEMAT1__c == null))
                    ZBAPI_CRM_COMPTE.ZOUT1 = 'X';
                if((q[0].opportunity.DEMAT2__c == false)||(q[0].opportunity.DEMAT2__c == null))
                    ZBAPI_CRM_COMPTE.ZOUT2 = 'X';
                
                ZBAPI_CRM_COMPTE.STCD1 = q[0].Opportunity.DO_Code_SIRET__c;
                
                String BarAbo = q[0].Scale_Code__c;
                if(BarAbo=='NA')  BarAbo = '2';
                ZBAPI_CRM_COMPTE.KONDA = BarAbo;
                String aCN = lAccount[0].Adherent_Central_Number__c;
                if((aCN!=null)&&(aCN!=''))
                    if(aCN.length() > 10) aCN = aCN.substring(0, 10);
                        ZBAPI_CRM_COMPTE.ALTKN = aCN;
                system.debug('MSG10:');

                
                String invFre = lAccount[0].Invoicing_Frequency__c;
                if((invFre!='')&&(invFre!=null))
                    ZBAPI_CRM_COMPTE.PERFK = invFre;
                system.debug('invFre:'+invFre);
                if(q[0].Facturation_calendar__c!='null' && q[0].Facturation_calendar__c!='' && q[0].Facturation_calendar__c!=null)
                    ZBAPI_CRM_COMPTE.PERRL = q[0].Facturation_calendar__c;
                ZBAPI_CRM_COMPTE.ZTERM = q[0].Payment_spread__c;
                ZBAPI_CRM_COMPTE.ZWELS = q[0].DO_Payment_method__c;
                ZBAPI_CRM_COMPTE.MAHNA = q[0].Opportunity.DO_Recovery_procedures__c;
                ZBAPI_CRM_COMPTE.BUSAB = q[0].Opportunity.DO_Accounting_Manager__r.Code__c;

                //String compSup = lAccount[0].Compte_Superieur__c;
                String compSup = q[0].DO_Groupement__r.AccountNumber;
                system.debug('compSup:'+compSup);
                Boolean optimo = false;
                if((compSup!=null)&&(compSup.contains('OPTI')))
                {
                    optimo = true;
                    ZBAPI_CRM_COMPTE.HKUNNR = q[0].DO_Groupement__r.AccountNumber;
                    
                    if(q[0].Opportunity.Contract_Start_Date__c != null)
                    {                        
                        Date DATAB = Date.newInstance(q[0].Opportunity.Contract_Start_Date__c.year(), q[0].Opportunity.Contract_Start_Date__c.month(), q[0].Opportunity.Contract_Start_Date__c.day());
                        ZBAPI_CRM_COMPTE.DATAB = DATAB;
                    }
                    else
                        ZBAPI_CRM_COMPTE.DATAB = Date.newInstance(1900, 01,01);
                }
                else
                    ZBAPI_CRM_COMPTE.DATAB = Date.newInstance(1900, 01,01);

                lZBAPI_CRM_COMPTE.add(ZBAPI_CRM_COMPTE);
                IT_COMPTE.ZBAPI_CRM_COMPTE = lZBAPI_CRM_COMPTE;

                microsoftLobservicesSapACC200703Types.ArrayOfZBAPI_CRM_PARTENAIRES IT_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ArrayOfZBAPI_CRM_PARTENAIRES(); 
                list<microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES> lZBAPI_CRM_PARTENAIRES = new list<microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES>(); 
                microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES ZBAPI_CRM_PARTENAIRES; 

                List<Opportunity_PTL__c> lOPTL = [select Id, PTLSynchroSAP__c from Opportunity_PTL__c where Opportunity__c= :q[0].OpportunityId];

                Integer i = 000;
                //projet type CREA on récupère tous les optl.PTLSynchroSAP__c  
                if(action == 'CREA' && typeProjet != 'CREARENTER')
                {
                    for(Opportunity_PTL__c optl:lOPTL)
                    {
                        ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                        ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                        ZBAPI_CRM_PARTENAIRES.PARZA = i;
                        ZBAPI_CRM_PARTENAIRES.KUNN2 = optl.PTLSynchroSAP__c;
                        lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        i++;
                    }
                }    

                //projet type EXTE on récupère tous les nouveaux PTL non dans PTL existants et PTL existants  
                if(action == 'MODIF FONCT PARTENAIRES')
                {
                    List<Opportunity_PTL__c> lOPTLSynchroNonNull = [select Id, PTLSynchroSAP__c from Opportunity_PTL__c where Opportunity__c= :q[0].OpportunityId and PTLSynchroSAP__c != null];
                    system.debug('lOPTLSynchroNonNull:'+lOPTLSynchroNonNull);

                    List<String> lOPTLNameSynchroNonNull = new List<String>();
                    for(Opportunity_PTL__c optl:lOPTLSynchroNonNull)
                        lOPTLNameSynchroNonNull.add(optl.PTLSynchroSAP__c);
                    system.debug('lOPTLNameSynchroNonNull:'+lOPTLNameSynchroNonNull);

                    List<PTL__c> lPTLAccountExistant = [select Id, Name from PTL__c where Account_DO__c = :q[0].AccountId];
                    system.debug('lPTLAccountExistant:'+lPTLAccountExistant);
                    
                    List<String> lOPTLNameExistant = new List<String>();
                    for(PTL__c ptl:lPTLAccountExistant)
                        lOPTLNameExistant.add(ptl.Name);
                    system.debug('lOPTLNameExistant:'+lOPTLNameExistant);

                    //on ajoute les ptl syncro non présent sur account
                    for(String ptl:lOPTLNameSynchroNonNull)
                    {
                        if(!lOPTLNameExistant.contains(ptl))
                            lOPTLNameExistant.add(ptl);
                    }
                    system.debug('lOPTLNameExistant 1:'+lOPTLNameExistant);


                    for(String ptl:lOPTLNameExistant)
                    {
                        ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                        ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                        ZBAPI_CRM_PARTENAIRES.PARZA = i;
                        ZBAPI_CRM_PARTENAIRES.KUNN2 = ptl;
                        lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        i++;
                    }
                    
                    action = 'MODI';
                }    

                //projet type SUCC on récupère tous les PTL  
                if(action == 'CREA DO RELIER PTL EXISTANT AU DO' || (action == 'CREA' && typeProjet == 'CREARENTER'))
                {
                    system.debug('projet type SUCC:');
                    //on récupère les ptl choisi associés au devis

                    List<Quote_PTL__c> lPTLAccountExistant = [select Id, Quote__c, PTL_Name__c from Quote_PTL__c where Quote__c= :q[0].Id]; 
                    system.debug('lPTLAccountExistant:'+lPTLAccountExistant);

                    for(Quote_PTL__c ptl:lPTLAccountExistant)
                    {
                        ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                        ZBAPI_CRM_PARTENAIRES.PARVW = 'WE';
                        ZBAPI_CRM_PARTENAIRES.PARZA = i;
                        ZBAPI_CRM_PARTENAIRES.KUNN2 = ptl.PTL_Name__c;
                        lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                        i++;
                    }

                    action = 'CREA';
                }

                //si payeur != DO
                if(q[0].Opportunity.PA_DO__c == false)
                {
                    ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                    ZBAPI_CRM_PARTENAIRES.PARVW = 'RG';
                    ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                    ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account_Payer__r.accountnumber;
                    lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                }                
                //si facturé != DO
                if(q[0].Opportunity.FA_DO__c == false)
                {
                    ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                    ZBAPI_CRM_PARTENAIRES.PARVW = 'RE';
                    ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                    ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].Opportunity.Account_Billed__r.accountnumber;
                    lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                }                
                //groupement produit
                if((q[0].DO_Groupement__r.accountnumber != null)&&(q[0].DO_Groupement__r.accountnumber!='')&&(optimo == false)&&(q[0].DO_Groupement__r.accountnumber!='AP000000'))
                {
                    ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                    ZBAPI_CRM_PARTENAIRES.PARVW = 'Z4';
                    ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                    ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                    lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                }                
                //groupement abonnementC
                if(q[0].Scale__c == 'V2GR')
                {
                    ZBAPI_CRM_PARTENAIRES = new microsoftLobservicesSapACC200703Types.ZBAPI_CRM_PARTENAIRES();
                    ZBAPI_CRM_PARTENAIRES.PARVW = 'Z5';
                    ZBAPI_CRM_PARTENAIRES.PARZA = 000;
                    ZBAPI_CRM_PARTENAIRES.KUNN2 = q[0].DO_Groupement__r.accountnumber;
                    lZBAPI_CRM_PARTENAIRES.add(ZBAPI_CRM_PARTENAIRES);
                }                

                IT_PARTENAIRES.ZBAPI_CRM_PARTENAIRES = lZBAPI_CRM_PARTENAIRES;

                system.debug('lAccount[0].AccountNumber:'+lAccount[0].AccountNumber);
                system.debug('String.valueOf(lAccount[0].Mandataire__r.ExternalID__c:'+String.valueOf(lAccount[0].Mandataire__r.ExternalID__c));
                system.debug('typeProjet:'+typeProjet);
                system.debug('String.valueOf(lAccount[0].Activity_Domain__r.ExternalID__c):'+String.valueOf(lAccount[0].Activity_Domain__r.ExternalID__c));
                system.debug('ET_RETURN:'+ET_RETURN);
                system.debug('IT_COMPTE:'+IT_COMPTE);
                system.debug('IT_PARTENAIRES:'+IT_PARTENAIRES);

                system.debug('lAccount[0].Mandataire__r.ExternalID__c:'+lAccount[0].Mandataire__r.ExternalID__c);
                
                /*String oldEndPoint =  callBAPI.endpoint_x;
                system.debug('Account oldEndPoint:'+oldEndPoint);
                //appel endepoint trace
                callBAPI.endpoint_x = 'http://test-soap-pricing-butagaz.herokuapp.com/put/';

                callBAPI.ZBAPI_CRM_COMPTE(action, '02', lAccount[0].AccountNumber, String.valueOf(lAccount[0].Mandataire__r.ExternalID__c), 
                                                     typeProjet, String.valueOf(lAccount[0].Activity_Domain__r.ExternalID__c), 
                                                     ET_RETURN, IT_COMPTE, IT_PARTENAIRES);

                //appel SAP
                callBAPI.endpoint_x = oldEndPoint;
                */
                response = callBAPI.ZBAPI_CRM_COMPTE(action, '02', lAccount[0].AccountNumber, String.valueOf(lAccount[0].Mandataire__r.ExternalID__c), 
                                                     typeProjet, String.valueOf(lAccount[0].Activity_Domain__r.ExternalID__c), 
                                                     ET_RETURN, IT_COMPTE, IT_PARTENAIRES);
                
                system.debug('>>>response ACC:'+response);
                
                microsoftLobservicesSapACC200703Types.ArrayOfBAPIRET2 ET_RETURNSAP = response.ET_RETURN;
                list<microsoftLobservicesSapACC200703Types.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;
                
                for(microsoftLobservicesSapACC200703Types.BAPIRET2 b:BAPIRET2)
                    system.debug('b.MESSAGE:'+b.MESSAGE);
                
                for(microsoftLobservicesSapACC200703Types.BAPIRET2 b:BAPIRET2)
                    errorMessage = errorMessage +'#'+b.MESSAGE;

                //oBapiTracker
                this.oBapiTracker.Response1__c = JSON.serialize((response));
                this.oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
                this.oBapiTracker.Message__c = errorMessage;
                this.oBapiTracker.Request__c = callBAPI.request;
                this.oBapiTracker.User__c = UserInfo.getUserId() ;
                if (this.sStoreTracker.toLowercase() == 'true') upsert this.oBapiTracker;

                if(response.EX_CONTROL=='KO')                        
                    this.statusContinueProcess = false;

                system.debug('this.statusContinueProcess Account:'+this.statusContinueProcess);

                lIdACC.put(lAccount[0].Id, new responseSAP(response.EX_CONTROL, errorMessage));
            }        

            System.debug('lIdACC:'+lIdACC);

            lAccount = [select Id, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                                                State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];
            
            System.debug('lAccount 1:'+lAccount);
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

            //DEBUT MAJ lAccount
            for(Account acc:lAccount)
            {
                acc.State_Synchro_To_SAP__c = lIdACC.get(acc.Id).EX_CONTROL;
                String errorMsg = lIdACC.get(acc.Id).lERROR;
                if(errorMsg.length()>255) errorMsg = errorMsg.substring(0, 255);
                acc.Error_Synchro_To_SAP__c = errorMsg;
            }
            update lAccount;
            // Reset Bypass fields to their original value
            //userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
            userCurrent.Bypass_Validation_Rules__c = originalBypassVRvalue;
            userCurrent.Bypass_Workflow__c = originalBypassWFvalue;
            userCurrent.Bypass_Email_No_Email_Check__c = originalBypassEmailNoEmailvalue;
            update userCurrent;

            lAccount = [select Id, Name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                                                State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];

            System.debug('lAccount 2:'+lAccount);

            //on ajoute statusContinue
            Map<String, list<Account>> mapACC = new Map<String, list<Account>>(); 
            /*Account acc = new Account(T_Apex_Context__c=statusContinue);
            List<Account> lAcc = new List<Account>();
            lAcc.add(acc);
            mapACC.put('statusContinue', lAcc);*/
            mapACC.put('ListACC', lAccount);

            
            return mapACC;

        }catch (Exception e) 
        {
            this.statusContinueProcess = false;
            system.debug('>>>class AP_WrapperForSOAPCallAccount:'+e.getMessage());
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

            //MAJ Account
            list<Account> lAccount1 = [select Id, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
            State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];

            if(lAccount1.size()!=0)
            {    
                for(Account acc:lAccount1)
                {
                    acc.State_Synchro_To_SAP__c = 'KO';
                    acc.Error_Synchro_To_SAP__c = e.getMessage();
                }    
                update lAccount1;
                //MAJ Account
                lAccount1 = [select Id, Name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];

            }
            else
            {
                lAccount1 = [select Id, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                                State_Synchro_Bank_To_SAP__c from Account where Id = :q[0].AccountId];
                for(Account acc:lAccount1)
                {
                    acc.State_Synchro_To_SAP__c = 'KO';
                    acc.Error_Synchro_To_SAP__c = e.getMessage();
                }    

                update lAccount1;

                lAccount1 = [select Id, Name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                                State_Synchro_Bank_To_SAP__c from Account where Id = :q[0].AccountId];
            }
            // Reset Bypass fields to their original value
            //userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
            userCurrent.Bypass_Validation_Rules__c = originalBypassVRvalue;
            userCurrent.Bypass_Workflow__c = originalBypassWFvalue;
            userCurrent.Bypass_Email_No_Email_Check__c = originalBypassEmailNoEmailvalue;
            update userCurrent;

            //oBapiTracker
            this.oBapiTracker.Response1__c = JSON.serialize((response));
            this.oBapiTracker.Endpoint__c = callBAPI.endpoint_x;   
            this.oBapiTracker.Message__c = e.getMessage();
            this.oBapiTracker.Request__c = callBAPI.request;
            this.oBapiTracker.User__c = UserInfo.getUserId() ;
            if (this.sStoreTracker.toLowercase() == 'true') upsert this.oBapiTracker;
            
            Map<String, list<Account>> mapACC = new Map<String, list<Account>>(); 
            mapACC.put('ListACC', lAccount1);
         
            return mapACC;

        }
    }

    public class responseSAP
    {
        public String EX_CONTROL;
        public String lERROR;
        
        public responseSAP(String EX_CONTROL, String lERROR)
        {
                this.EX_CONTROL = EX_CONTROL;
                this.lERROR = lERROR;
        }
    }


}