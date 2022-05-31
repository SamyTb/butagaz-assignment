public class VFC_Send_To_SAP_Wrapper {
    
    public String IdCDSCurrent{get; set;}
    public static Boolean bStatut{get; set;}
    public static Boolean bEnvoiSAP{get; set;}
    public static Boolean bErrorSAP{get; set;}
    public static Boolean bDejaEnvoyeSAP{get; set;}   
    public Integer windowSize{get; set;}
    public String labelListError{get; set;}
    public Boolean bdisplayError{get; set;}
    public List<String> lMessageError {get; set;}
    public Boolean bdisplaySpinner{get; set;}
    public Boolean bBackOffice{get; set;}

    public VFC_Send_To_SAP_Wrapper(ApexPages.StandardController controller) 
    {
        this.bdisplaySpinner = true;
        this.IdCDSCurrent = ApexPages.CurrentPage().getParameters().get('id');
    }
    
    public PageReference init() 
    {
		//this.bdisplaySpinner = true;
        this.windowSize = 170;
        this.bBackOffice = true;

        if(!isBackOfficeUser())
        {
            this.bdisplaySpinner = false;
            this.bBackOffice = false;
            //bStatut = true;
        }
        else
        {
            CDS__c currentCDS = [select Id, Prise_en_Charge__c, Status__c,Transaction_SAP_Date__c, Transaction_SAP_Bouteilles_Casiers__c, Transaction_SAP_Presentoirs__c from CDS__c where Id= :this.IdCDSCurrent];
            
            if((currentCDS.Status__c != 'Signé')&&(currentCDS.Status__c != 'Validé par BO'))
            {
                this.bdisplaySpinner = false;
                bStatut = false;
            }    
            else
            {   //DEBUT ELSE 
                bStatut = true;
                //on verifie si toutes les transactions on deja été envoyées
                if(((currentCDS.Transaction_SAP_Date__c == true) && (currentCDS.Transaction_SAP_Bouteilles_Casiers__c == true) && (currentCDS.Transaction_SAP_Presentoirs__c == true))|| (currentCDS.Status__c == 'Validé par BO'))
                {
                    this.bdisplaySpinner = false;
                    bDejaEnvoyeSAP = true;
                }    
                else //envoie a SAP 
                {
                    microsoftLobservicesSap200703Rfc.ZBAPI_CRM_CDSResponse_element response = AP_WrapperForSOAPCallCDS.Send_CDS_To_SAP(currentCDS.Id);
                    //response.EX_CONTROL = 'OK';
                    //retour OK de SAP
                    if(response.EX_CONTROL == 'OK')
                    {
                        bErrorSAP = false;
                        this.bdisplaySpinner = false;
                        //MAJ CDS
                        currentCDS.Transaction_SAP_Date__c = true;
                        currentCDS.Transaction_SAP_Bouteilles_Casiers__c = true;
                        currentCDS.Transaction_SAP_Presentoirs__c = true;
                        currentCDS.Status__c = 'Validé par BO';
                        currentCDS.User_CDS_SF_SAP__c = UserInfo.getUserId();
                        currentCDS.Synchro_To_SAP__c = true;
                        update currentCDS;
                        //update PEC
                        if(currentCDS.Prise_en_Charge__c != null)
                        {
                            PEC__c pec = [select Id, Status__c from PEC__c where Id= :currentCDS.Prise_en_Charge__c];
                            pec.Status__c = 'Validée par BO';
                            update pec;
                        }
                    }    
                    //retour KO de SAP
                    else
                    {
                        bErrorSAP = true;
                        this.bdisplaySpinner = false;
                        this.windowSize =  this.windowSize+40;
                        //DEBUT GESTION DES MESSAGES ERREURS
                        microsoftLobservicesSap200703Types.ArrayOfBAPIRET2 ET_RETURN = response.ET_RETURN;
                        list<microsoftLobservicesSap200703Types.BAPIRET2> BAPIRET2 = ET_RETURN.BAPIRET2;

                        this.labelListError = 'Veuillez corriger les erreurs suivantes:';
                        if(BAPIRET2.size() == 1) this.labelListError = 'Veuillez corriger l\'erreur suivante:';
                        if(BAPIRET2.size() > 0) this.bdisplayError = true;
                        lMessageError = new List<String>();
                        
                        for(microsoftLobservicesSap200703Types.BAPIRET2 CDS_ET_RETURN:BAPIRET2)
                        {
                            lMessageError.add(CDS_ET_RETURN.MESSAGE);
                            this.windowSize =  this.windowSize+51;        
                        }
                        //FIN GESTION DES MESSAGES ERREURS

                        //DEBUT GESTION DES STATUT
                        microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS ET_STEP_STATUS = response.ET_STEP_STATUS;
                        list<microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS> ZBAPI_CRM_CDS_STATUS = ET_STEP_STATUS.ZBAPI_CRM_CDS_STATUS;

                        for(microsoftLobservicesSap200703Types.ZBAPI_CRM_CDS_STATUS CDS_STEP_STATUS:ZBAPI_CRM_CDS_STATUS)
                        {
                            if(CDS_STEP_STATUS.STEP == 'STEP 1')
                                currentCDS.Transaction_SAP_Date__c = (CDS_STEP_STATUS.STATUS == 'KO') ? false : true;
                            if(CDS_STEP_STATUS.STEP == 'STEP 2')
                                currentCDS.Transaction_SAP_Bouteilles_Casiers__c = (CDS_STEP_STATUS.STATUS == 'KO') ? false : true;
                            if(CDS_STEP_STATUS.STEP == 'STEP 3')
                                currentCDS.Transaction_SAP_Presentoirs__c = (CDS_STEP_STATUS.STATUS == 'KO') ? false : true;
                        }
                        currentCDS.User_CDS_SF_SAP__c = UserInfo.getUserId();
                        currentCDS.Synchro_To_SAP__c = true;
                        update currentCDS;
                        //FIN GESTION DES STATUT

                        //microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_ITEM IT_CDS = response.IT_CDS;
                        //microsoftLobservicesSap200703Types.ArrayOfZBAPI_CRM_CDS_STATUS IT_STEP_STATUS = response.IT_STEP_STATUS;

                    }                
                }
            }//FIN ELSE
        }    
        return null;
    }

    public static Boolean isBackOfficeUser()
    {
		if(Test.isRunningTest())
        {
            return true;
        }
        else
        {
            Id userId = UserInfo.getUserId();
            List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];
    
            if( members != null && !members.isEmpty() ){
                return true;
            }
    
            return false;
    	}
    }


}