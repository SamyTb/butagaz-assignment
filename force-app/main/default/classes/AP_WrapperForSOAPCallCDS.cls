public class AP_WrapperForSOAPCallCDS {

    public AP_WrapperForSOAPCallCDS() {

    }

    public static microsoftLobservicesSap200703Rfc.ZBAPI_CRM_CDSResponse_element Send_CDS_To_SAP(String IdCDS)
    {
        CDS__c  cds = [select Id, Status__c, CreatedDate, CDS_Date__c, Account__c, account__r.AccountNumber, name, 
                    Transaction_SAP_Date__c, Transaction_SAP_Bouteilles_Casiers__c, Transaction_SAP_Presentoirs__c from CDS__c where Id= :IdCDS];

        Date IM_DATE_CDS = Date.newInstance(cds.CreatedDate.year(), cds.CreatedDate.month(), cds.CreatedDate.day());
        //Date IM_DATE_REGUL = Date.newInstance(cds.CDS_Date__c.year(), cds.CDS_Date__c.month(), cds.CDS_Date__c.day());
        Date dateRegul = system.today();
        Date IM_DATE_REGUL = Date.newInstance(dateRegul.year(), dateRegul.month(), dateRegul.day());

        String IM_CLIENT_LIVRE = cds.account__r.AccountNumber;
        String IM_REF_CLIENT = cds.name;
        //division livraison
        list<PTL__c> lPTL = [select Id, Code_division__c from PTL__c where Account_DO__c= :cds.Account__c];
        String IM_VWERK = '';
        if(lPTL.size()>0) IM_VWERK = lPTL[0].Code_division__c;

        //ET_RETURN et ET_STEP_STATUS, retour SAP donc pas alimentés
        microsoftLobservicesSap200703Types.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSap200703Types.ArrayOfBAPIRET2();
        microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS ET_STEP_STATUS = new microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS();

        //liste des articles liés au CDS donc le résultat < ou > 0
        microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_ITEM IT_CDS = new microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_ITEM();
        list<CDS_Article__c> lArticles = [select Id, Article__r.ExternalID__c,Article__r.name, Resultat_CDS__c, Compensation_Excedents__c,Non_Facture_Excedents__c, 
                                          Compensation_Manquants__c, Consignation_Manquants__c from CDS_Article__c 
                                          where CDS__c= :cds.Id and Resultat_CDS__c != 0 and Resultat_CDS__c != null];

        list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_ITEM> lCallCdsA = new list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_ITEM>(); 
        for(CDS_Article__c cdsA:lArticles)
        {
            microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_ITEM CallCdsA = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_ITEM();
            CallCdsA.ARTICLE = cdsA.Article__r.ExternalID__c;
            CallCdsA.QTE_EX_COMP = (cdsA.Compensation_Excedents__c==null)? 0: cdsA.Compensation_Excedents__c;
            CallCdsA.QTE_EX = (cdsA.Non_Facture_Excedents__c==null)? 0: cdsA.Non_Facture_Excedents__c;
            CallCdsA.QTE_MQ_COMP = (cdsA.Compensation_Manquants__c==null)? 0: cdsA.Compensation_Manquants__c;
            CallCdsA.QTE_MQ = (cdsA.Consignation_Manquants__c==null)? 0: cdsA.Consignation_Manquants__c;
            lCallCdsA.add(CallCdsA);           
        }
        IT_CDS.ZBAPI_CRM_CDS_ITEM = lCallCdsA;

        //Liste des services à définir (STEP 1 = date CDS , STEP 2 = CDS bouteilles/Casiers, STEP 3 = CDS Présentoirs
        microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS IT_STEP_STATUS = new microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS();
        list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS> lCall_IT_STATUS = new list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS>(); 
        //IT 0
        microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS Call_IT_STATUS_0 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS(); 
        Call_IT_STATUS_0.STEP = 'STEP 1';
        if(cds.Transaction_SAP_Date__c == true) Call_IT_STATUS_0.STATUS = 'OK';
        else Call_IT_STATUS_0.STATUS = 'KO';        
        //IT 1
        microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS Call_IT_STATUS_1 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS(); 
        Call_IT_STATUS_1.STEP = 'STEP 2';
        if(cds.Transaction_SAP_Bouteilles_Casiers__c == true) Call_IT_STATUS_1.STATUS = 'OK';
        else Call_IT_STATUS_1.STATUS = 'KO';        
        //IT 2
        microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS Call_IT_STATUS_2 = new microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS(); 
        Call_IT_STATUS_2.STEP = 'STEP 3';
        if(cds.Transaction_SAP_Presentoirs__c == true) Call_IT_STATUS_2.STATUS = 'OK';
        else Call_IT_STATUS_2.STATUS = 'KO';        

        lCall_IT_STATUS.add(Call_IT_STATUS_0);
        lCall_IT_STATUS.add(Call_IT_STATUS_1);
        lCall_IT_STATUS.add(Call_IT_STATUS_2);
        IT_STEP_STATUS.ZBAPI_CRM_CDS_STATUS = lCall_IT_STATUS;

        //call BAPI
        microsoftLobservicesSap200703.BasicHttpBinding_Rfc callBAPI = new microsoftLobservicesSap200703.BasicHttpBinding_Rfc();
        microsoftLobservicesSap200703Rfc.ZBAPI_CRM_CDSResponse_element response = callBAPI.ZBAPI_CRM_CDS(
            IM_CLIENT_LIVRE, IM_DATE_CDS, IM_DATE_REGUL, IM_REF_CLIENT, IM_VWERK,
            ET_RETURN, ET_STEP_STATUS, IT_CDS, IT_STEP_STATUS);

        return response;
              
    }

}