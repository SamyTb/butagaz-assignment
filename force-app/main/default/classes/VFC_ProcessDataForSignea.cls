global class VFC_ProcessDataForSignea {
    
    private static Quote oQuote;
    public static String isSE{get; set;} // Is the quote being electronically signed ?
    public static Boolean withPEC{get; set;} // For GEB quotes, do we want to print the PEC ?
    private static list<PEC__c> lPECToSign;
    private static PEC__c oPECToSign;
    private static CDS__c oCDSToSign;
    private static list<CDS__c> lCDSToSign;

    
    private static final integer FONT_SIZE = 10;  // Sets the font size of fields sent to Signea
    private static final string sFolderId = AP_PricingUtilities.getCustomSettingValue('FolderIdToStoreDocumentsForSignea');  // Used to store the id of the folder in which documents will be copied for Signea 
    private static final string sMaxNumberEvidenceFilesForSignea = AP_PricingUtilities.getCustomSettingValue('MaxNumberEvidenceFilesForSignea');  // Used to store the max number of files per evidence the cutomer is allowed to upload on Contralia
    
    private Map<Integer, String> mSortDocs {get;set;}  // Map used to sort Scale Docs to render on VFP
    
    private static list<Opportunity_PTL__c> lOPTLs {get;set;}
    
    private static list<Opportunity_PTL__c> lOPTLsWithoutPlanImplantation {get;set;}
    private static list<Opportunity_PTL__c> lOPTLsWithPlanImplantation {get;set;}
    
    //private static Set<Id> pcpAttachmentsSet {get;set;}
    private static list<Attachment> lPCPAttachments {get;set;}
    private static list<PTL_Consumption_Profile__c> lPCPsWithoutProfilConsoFile {get;set;}
    private static list<PTL_Consumption_Profile__c> lPCPsWithProfilConsoFile {get;set;}
    
    private static list<Document_A_Signer__c> documents {get;set;}
    private static list<Signataire_Document__c> signataires {get;set;}
    private static list<Parametre_Signature__c> parametres {get;set;}

    private static boolean hasDocumentsToBeFilled {get; set;}  // This variable (default false) will be set to true if the circuit requires documents to be filled (tag with Type_de_remplissage__c != 'SIGNATURE'). When sending metadata to Contralia, we will check this variable value and manage the requirements to force reading on the fill step or on the sign step
    
    Static Custom_Settings__c GEC_GrosVrac = Custom_Settings__c.getValues('Opportunity_RecordTypeId_GEC_GrosVrac'); 
    ApexPages.StandardController stdController;
    
    public VFC_ProcessDataForSignea(ApexPages.StandardController controller) {
        this.stdController = controller;
        oQuote = (Quote)stdController.getRecord() ;
    }
    
    
    
    // actDom values : gecdom, geb
    // withPEC : true/false to determine if the PEC document is needed or not
    // pMode : 0 = Prepare data only | 1 = Prepare data and call WS 
    WebService static string ProcessDataForSignea(string quoteId, boolean pWithPEC, integer pMode) {
        
        string outcomeMessage;
        
        
        isSE = 'true';  // electronic signature
        hasDocumentsToBeFilled = false;
        if (pWithPEC != null) withPEC = pWithPEC;
        
        // Check if user has the required permissions to run the Signea process
        if(!Test.isRunningTest()){
            if(VFC_User.isUserAuthorizedToRunSignea(UserInfo.getUserId()) == false){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] : 001-Utilisateur non autorisé à lancer la signature électronique.');
                return '<span style="color: red">- Utilisateur non autorisé à lancer la signature électronique.</span>';
            }
        }
        
        // Get Quote  
        List<Quote> lQuotes = [select Id, Name, QuoteNumber, Signea_Circuit__c, Signea_Date_Signature__c,
                                    /* Fields for Parametre_Signature__c */
                                    AccountId, Account.AccountNumber, Account.FirstName, Account.LastName, Account.Activity_Domain_Simple__c, Account.Payment_method__c,
                                    Opportunity.Payer_AccountNumber__c, Opportunity.Billed_AccountNumber__c, Account.Mandataire__r.ExternalID__c, Account.Mandataire__r.Headquarters_Phone__c,
                                    Account.Mandataire__r.Email_Service_Client__c, Account.Mandataire__r.Electronic_Signature_Email__c,
                                    /* Fields for Signataire_Document__c */
                                    Contact.Id,
                                    Account.Salutation__c, 
                                    /* Fields for Piece_Justificative__c */
                                    DO_Payment_method__c, Opportunity.Client_Type__c,
                                    /* Fields for Document_A_Signer__c */
                                    Project_Type__c, Client_Reenlistment__c,
                                    /* Fields for Zone_De_Remplissage__c */
                                    Contact.Salutation, Contact.FirstName, Contact.LastName,
                                    Opportunity.DO_Salutation__c, Opportunity.DO_Name__c,
                                    Opportunity.DO_Street_N__c, Opportunity.DO_Number_extention__c, Opportunity.DO_Street_type__c,
                                    Opportunity.DO_Street_name__c, Opportunity.DO_Lieu_dit__c,
                                    Opportunity.DO_Postal_Code__c, Opportunity.DO_City__c, Opportunity.DO_City_Postal_Code__r.Name,
                                    /* Fields for Scales */
                                    Product_Scale__c, Scale__c, VAT_code__c,
                                    Product_Scale_Code__c, Scale_Code__c,
                                    /* Other */
                                    Account.IsPersonAccount, IsSyncing, T_LAT_Approved__c, 
                                    Account.Country__c, Account.Indicatif_Pays__c, Account.Mobile_Phone_Number__c, Contact.Country__c, Contact.Indicatif_Pays_c__c, Contact.MobilePhone,
                                    Account.Email__c, Contact.Email,
                                    Opportunity.Opportunity_Reason__c, Market_type__c, /*T_RollUpIsMEP__c,*/ Account.Sub_Channel__c, Consommation_estimee_Prop_Carb__c, 
                                    Opportunity.Attestation_vente_deja_presente__c, Opportunity.Avez_vous_votre_Kbis__c, Opportunity.Changement_de_banque__c, 
                                    Activity_Domain_ID__c, Opportunity.T_Pack__c, Opportunity.Livraison_pendant_delai_retractation__c, Derogation_calcul_consommation__c,
                                    Opportunity.Project_market_type__c, Opportunity.Channel__c,Opportunity.RecordType.Id, Opportunity.Project_market_subtype__c,
                                    Opportunity.DO_En_cours_d_immatriculation__c,DO_Groupement__c,Opportunity.Contrat_anticipation__c
                                from Quote where Id =:quoteId limit 1];
        if(!lQuotes.isEmpty()){
            oQuote = lQuotes[0];
        }else{
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] : 001-Devis non trouvé.');
            return '001-Devis non trouvé.';
        }
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Id = ' + oQuote.Id);
        

        // Load OPTLs list
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
            lOPTLs = new List<Opportunity_PTL__c>();
            lOPTLs = getlOPTLs();
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] lOPTLs : ' + lOPTLs);
        
            // Manage OPTLs with or without PlanImplantation
            lOPTLsWithoutPlanImplantation = new List<Opportunity_PTL__c>();
            lOPTLsWithPlanImplantation = new List<Opportunity_PTL__c>();
            manageOPTLsWithOrWithoutPlanImplantation();
        }
        
        // Load ProfilConso attachments list 
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.T_Pack__c == 'ECOCFT' && oQuote.Project_Type__c == 'CREA' && (oQuote.Opportunity.Opportunity_Reason__c == 'Piquage client' || oQuote.Opportunity.Opportunity_Reason__c == 'Renovation')){
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            lPCPAttachments = new List<Attachment>();
            
            // Manage QPTLs with or without ProfilConsoFile
            lPCPsWithoutProfilConsoFile = new List<PTL_Consumption_Profile__c>();
            lPCPsWithProfilConsoFile = new List<PTL_Consumption_Profile__c>();
            manageQPTLsWithOrWithoutProfilConsoFile();
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] lPCPsWithoutProfilConsoFile : ' + lPCPsWithoutProfilConsoFile);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] pcpAttachmentsSet : ' + lPCPAttachments);
        }

        // Load PEC
        if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            lPECToSign = getPECToSign();
            if(lPECToSign.size()>0) oPECToSign = lPECToSign[0];
        }

        // Load CDS (to delete after tests with Docapost)
        /*if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            lCDSToSign = getCDSToSign();
            if(lCDSToSign.size()>0) oCDSToSign = lCDSToSign[0];
        }*/
        
        
        // Don't go further if an issue is found
        string pbMessageBefore = getIssuesBeforePreparingData();
        if(pbMessageBefore != ''){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] message = ' + pbMessageBefore);
            return pbMessageBefore;
        }
        
        // Check if documents are all there in libraries ???
        
        
         
        // Prepare data and optionally call WS depending on pMode parameter
        if(prepareDataForSignea()){
            if(pMode == 1){
                // Ok to call WS
                
                string pbMessageAfter = getIssuesAfterPreparingData();
                if(pbMessageAfter != ''){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] message = ' + pbMessageAfter);
                return pbMessageAfter;
            }
            
            string responseSignea = sendDataToSignea();
                if(responseSignea.substring(0, 3) == '000'){
                  outcomeMessage = '000-Circuit de signature créé avec succès';
              }else{
                outcomeMessage = responseSignea;
              }
              //outcomeMessage = sendDataToSignea();
            }else{
                outcomeMessage = '000-Préparation des tables et des documents terminée';
            }
        }
        
        
        return outcomeMessage;
        
    }
    
    
    
    /** Prepare data for Signea **/
    public static Boolean prepareDataForSignea(){
        
        boolean res = false;
        
        // ==================================================================
        // Purge des enregistrements des objets Signea liés au devis en cours
        // ==================================================================
        deleteRecords();
        
        
        // ============================================
        // Création des parametres du circuit
        // ============================================
        system.Debug('# debut Création des parametres du circuit');
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] Début Création des parametres du circuit');
        Parametre_Signature__c myCircuitParam = new Parametre_Signature__c();
        myCircuitParam.Account__c = oQuote.Account.Id;
        myCircuitParam.Devis__c = oQuote.Id;
        //myCircuitParam.Index_AES__c = 'MatriculeDO=' + oQuote.Account.AccountNumber + ', Activite=' + oQuote.Account.Activity_Domain_Simple__c.toUpperCase() + ', MatriculePA=' + (String.isBlank(oQuote.Opportunity.Payer_AccountNumber__c)? oQuote.Account.AccountNumber : oQuote.Opportunity.Payer_AccountNumber__c) + ', MatriculeFA=' + (String.isBlank(oQuote.Opportunity.Billed_AccountNumber__c)? oQuote.Account.AccountNumber : oQuote.Opportunity.Billed_AccountNumber__c) + ',OrganisationCom=' + oQuote.Account.Mandataire__r.ExternalID__c;
        myCircuitParam.Index_AES__c = 'matricule_do=' + oQuote.Account.AccountNumber + ', matricule_pa=' + (String.isBlank(oQuote.Opportunity.Payer_AccountNumber__c) ? oQuote.Account.AccountNumber : oQuote.Opportunity.Payer_AccountNumber__c) + ', matricule_fa=' + (String.isBlank(oQuote.Opportunity.Billed_AccountNumber__c) ? oQuote.Account.AccountNumber : oQuote.Opportunity.Billed_AccountNumber__c) + ', orga_comm=' + oQuote.Account.Mandataire__r.ExternalID__c + ', activite=' + oQuote.Account.Activity_Domain_Simple__c.toUpperCase();
        myCircuitParam.Condition_d_acceptation__c = 'J\'ai lu le document et j\'accepte sans réserve les conditions.';
        myCircuitParam.Notification_Createur__c = true;
        if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO' && oQuote.Opportunity.Client_Type__c == 'RE'){
            myCircuitParam.Module__c = 'GEB_RE';
        }else{
            myCircuitParam.Module__c = 'default';
        }
        //myCircuitParam.Notification_additionnelle_generale__c = '';
        myCircuitParam.Notification_additionnelle_generale__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oQuote.Account.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oQuote.Account.Mandataire__r.Email_Service_Client__c;
        Datetime curDT = Datetime.now();
        //myCircuitParam.Nom_du_circuit__c = 'Contrat_' + oQuote.QuoteNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        //myCircuitParam.Nom_du_circuit__c = ( (oQuote.Account.FirstName == null || oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oQuote.Account.LastName == null || oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' - ' + oQuote.Account.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Market_type__c = ' + oQuote.Market_type__c);
        if(oQuote.Market_type__c == 'DOM'){
            string FirstAndLastName = ( (oQuote.Account.FirstName == null || oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oQuote.Account.LastName == null || oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            myCircuitParam.Nom_du_circuit__c = FirstAndLastName.left(49) + ' - ' + oQuote.Account.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        }else if(oQuote.Market_type__c == 'PRO'){
            string FirstAndLastName = ( (oQuote.Contact.FirstName == null || oQuote.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oQuote.Contact.LastName == null || oQuote.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            myCircuitParam.Nom_du_circuit__c = FirstAndLastName.left(49) + ' - ' + oQuote.Account.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        }
        
        insert myCircuitParam;
        
        
        // ============================================
        // Création du conteneur d’étapes et des étapes
        // ============================================
        List<Signataire_Document__c> lSigDoc = new List<Signataire_Document__c>();
        
        //Etape 1 : 1 Signataire client
        Signataire_Document__c mySigner1 = new Signataire_Document__c();
        mySigner1.Numero_du_participant__c = 1;
        mySigner1.Type_de_destinataire__c = 'Distance';
        mySigner1.Type_de_signature__c = 'OTP';		//NOTE POUR EVOL : mySigner1.Type_de_signature__c = 'OTP'
        mySigner1.Type_de_signataire__c = 'C';
        //mySigner1.Type_de_signataire__c = '';
        mySigner1.Id_SF_Signataire__c = oQuote.Contact.Id;
        //mySigner1.Id_SF_Signataire__c = null;
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        if(oQuote.Market_type__c == 'DOM'){
            mySigner1.Civilite__c = oQuote.Account.Salutation__c;
            mySigner1.Prenom__c = ( (oQuote.Account.FirstName == null || oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Name = ( (oQuote.Account.LastName == null || oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Email__c = oQuote.Account.Email__c;
            mySigner1.Telephone__c = oQuote.Account.Country__c == 'FR' ? oQuote.Account.Mobile_Phone_Number__c : ( oQuote.Account.Indicatif_Pays__c == null ? '' : oQuote.Account.Indicatif_Pays__c ) + oQuote.Account.Mobile_Phone_Number__c;
        }else if(oQuote.Market_type__c == 'PRO'){
            mySigner1.Civilite__c = oQuote.Contact.Salutation;
            mySigner1.Prenom__c = ( (oQuote.Contact.FirstName == null || oQuote.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Name = ( (oQuote.Contact.LastName == null || oQuote.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oQuote.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Email__c = oQuote.Contact.Email;
            mySigner1.Telephone__c = oQuote.Contact.Country__c == 'FR' ? oQuote.Contact.MobilePhone : ( oQuote.Contact.Indicatif_Pays_c__c == null ? '' : oQuote.Contact.Indicatif_Pays_c__c ) + oQuote.Contact.MobilePhone;
        }
        // ***
        mySigner1.Etape_de_signature__c = '1-Signature Client';
        mySigner1.Devis__c = oQuote.Id;
        mySigner1.Notification_additionnelle_personnalisee__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oQuote.Account.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oQuote.Account.Mandataire__r.Email_Service_Client__c;
        mySigner1.Duree_avant_expiration__c = 20;
        mySigner1.Delai_avant_relance__c = 7;
        mySigner1.position__c = 1;
        
        lSigDoc.add(mySigner1);
        
        //Etape 2 : 2 Visa conseiller
        Signataire_Document__c mySigner2 = new Signataire_Document__c();
        mySigner2.Numero_du_participant__c = 2;
        mySigner2.Type_de_destinataire__c = 'Visa';
        mySigner2.Type_de_signature__c = '';
        mySigner2.Type_de_signataire__c = 'U';
        mySigner2.Id_SF_Signataire__c = UserInfo.getUserId();
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        //mySigner2.Civilite__c = 'Mr';
        //mySigner2.Prenom__c = UserInfo.getFirstName();
        //mySigner2.Name = UserInfo.getLastName();
        //mySigner2.Email__c = '';
        //mySigner2.Telephone__c ='';
        // ***
        mySigner2.Etape_de_signature__c = '2-Visa Conseiller';
        mySigner2.Devis__c = oQuote.Id;
        mySigner2.Notification_additionnelle_personnalisee__c = '';
        mySigner2.Duree_avant_expiration__c = 20;
        mySigner2.Delai_avant_relance__c = 7;
        mySigner2.position__c = 2;
        
        lSigDoc.add(mySigner2);
        
        /* Qui doit être défini en tant que BO ?
        //Etape 3 : 3 Information BO
        Signataire_Document__c mySigner3 = new Signataire_Document__c();
        mySigner3.Numero_du_participant__c = 3;
        mySigner3.Type_de_destinataire__c = 'Information';
        mySigner3.Type_de_signature__c = 'Pas de signature';
        mySigner3.Type_de_signataire__c = 'C';
        mySigner3.Id_SF_Signataire__c = '0034E00000AL7yT';  // ToDo
        // The following fields are optional if SFDC Id is provided
        //mySigner3.Civilite__c = 'Mr';
        //mySigner3.Prenom__c = '';
        //mySigner3.Name = 'Back Office Contrat';
        //mySigner3.Email__c = '';
        //mySigner3.Telephone__c ='';
        mySigner3.Etape_de_signature__c = '3-Information BO';
        mySigner3.Devis__c = oQuote.Id;
        mySigner3.Notification_additionnelle_personnalisee__c = '';
        //mySigner3.Duree_avant_expiration__c = 20;
        //mySigner3.Delai_avant_relance__c = 7;
        
        lSigDoc.add(mySigner3);*/
        
        insert lSigDoc;
        
        
        // ============================================
        // Création des pièces justificatives à joindre
        // ============================================     
        List<Piece_Justificative__c> lPJ = new List<Piece_Justificative__c>();
        
        // RIB
        // For FIDE project type, we only need the RIB if the customer wasn't on PO before
        //if(oQuote.Opportunity.Changement_de_banque__c.toUpperCase() == 'OUI' || oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC' || (oQuote.Project_Type__c == 'FIDE' && oQuote.Account.Payment_method__c != 'P')){
        if( (oQuote.Opportunity.Changement_de_banque__c != null && oQuote.Opportunity.Changement_de_banque__c.toUpperCase() == 'OUI') || oQuote.Project_Type__c == 'CREA'|| (oQuote.Project_Type__c == 'SUCC' && oQuote.Account.Activity_Domain_Simple__c == 'gec') 
            || ( oQuote.Project_Type__c == 'FIDE' && (oQuote.Account.Payment_method__c != 'P' && oQuote.Account.Payment_method__c != '2' && oQuote.Account.Payment_method__c != '3'  && oQuote.Account.Payment_method__c != 'G' ) ) ){
            if(oQuote.DO_Payment_method__c == 'P' || oQuote.DO_Payment_method__c == '2' || oQuote.DO_Payment_method__c == '3'){   // P = Prélèvement d'office, 2 = LCR, 3 = LCR Acceptée
                Piece_Justificative__c pj = new Piece_Justificative__c();
                pj.Signataire_Document__c = mySigner1.Id;
                pj.Description__c = 'RIB du client';
                pj.Obligatoire__c = true;
                pj.Type__c = 'Other';
                pj.Devis__c = oQuote.Id;
                lPJ.add(pj);
            }
        }
        
        // DPE
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
            if(oQuote.Project_Type__c == 'SUCC' && oQuote.Opportunity.Client_Type__c == 'Owner'){
                Piece_Justificative__c pj = new Piece_Justificative__c();
                pj.Signataire_Document__c = mySigner1.Id;
                pj.Description__c = 'DPE avec volet gaz ou Diagnostic Gaz';
                pj.Obligatoire__c = false;
                pj.Type__c = 'Other';
                pj.Devis__c = oQuote.Id;
                lPJ.add(pj);
            }
        }
        
        // Acte
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
       if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
           System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Opportunity.RecordType.Id = ' + oQuote.Opportunity.RecordType.Id);
           System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Opportunity.Attestation_vente_deja_presente__c = ' + oQuote.Opportunity.Attestation_vente_deja_presente__c);
           System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Project_Type__c  = ' + oQuote.Project_Type__c);
           System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.Client_Type__c ] oQuote.Opportunity.Attestation_vente_deja_presente__c = ' + oQuote.Opportunity.Client_Type__c);
           System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.Client_Type__c ] oQuote.Opportunity.Contrat_anticipation__c = ' + oQuote.Opportunity.Contrat_anticipation__c );
        //    if(oQuote.Project_Type__c == 'SUCC' && oQuote.Opportunity.Client_Type__c == 'Owner' && !oQuote.Opportunity.Attestation_vente_deja_presente__c || !oQuote.Opportunity.Contrat_anticipation__c ){
                if(oQuote.Project_Type__c == 'SUCC' && oQuote.Opportunity.Client_Type__c == 'Owner' && !oQuote.Opportunity.Attestation_vente_deja_presente__c && !oQuote.Opportunity.Contrat_anticipation__c  ){
                Piece_Justificative__c pj = new Piece_Justificative__c();
                pj.Signataire_Document__c = mySigner1.Id;
                pj.Description__c = 'Attestation de vente, acte de décès ou divorce';
                pj.Obligatoire__c = true;
                pj.Type__c = 'Other';
                pj.Devis__c = oQuote.Id;
                lPJ.add(pj);
            }
        }
        
        // Bail
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
            if((oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC') && oQuote.Opportunity.Client_Type__c == 'Renter'){
                Piece_Justificative__c pj = new Piece_Justificative__c();
                pj.Signataire_Document__c = mySigner1.Id;
                pj.Description__c = 'Bail';
                pj.Obligatoire__c = true;
                pj.Type__c = 'Other';
                pj.Devis__c = oQuote.Id;
                lPJ.add(pj);
            }
        }
        
        // CNI
        boolean requireCNI = false;
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
            if((oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC') && oQuote.Opportunity.Client_Type__c == 'Renter'){
                requireCNI = true;
            }
        }
        /*if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO' && oQuote.Account.Sub_Channel__c == 'NC'){
            requireCNI = true;
        }*/
        if(requireCNI){
            Piece_Justificative__c pj = new Piece_Justificative__c();
            pj.Signataire_Document__c = mySigner1.Id;
            pj.Description__c = 'Carte Nationale d\'Identité Recto/Verso';
            pj.Obligatoire__c = true;
            pj.Type__c = 'Other';
            pj.Devis__c = oQuote.Id;
            lPJ.add(pj);
        }

        // KBIS
        // Uniquement si "Non commerçant". Attention, le commercial doit saisir cette information sur le compte (voir si droits ok) s'il n'est pas descendu de SAP (CREA)
        // /!\ ou prendre sur Opty ?
        // Clients non-commerçants exclus du scope du projet
       // if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO' && (oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC')){
         if((oQuote.Account.Activity_Domain_Simple__c == 'geb' || oQuote.Account.Activity_Domain_Simple__c == 'gec' )   && oQuote.Market_type__c == 'PRO' && (oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC')){
            if(oQuote.Account.Sub_Channel__c != 'NC'){
                if(oQuote.Opportunity.Avez_vous_votre_Kbis__c != null && oQuote.Opportunity.Avez_vous_votre_Kbis__c.toUpperCase() == 'OUI'){
                    Piece_Justificative__c pj = new Piece_Justificative__c();
                    pj.Signataire_Document__c = mySigner1.Id;
                    pj.Description__c = 'KBIS';
                    pj.Obligatoire__c = true;
                    pj.Type__c = 'Other';
                    pj.Devis__c = oQuote.Id;
                    lPJ.add(pj);
                }
            }
        }


        // SIRET en cours d'immat
        // Uniquement si le code SIRET est en cours d'immatriculation
        // /!\ ou prendre sur Opty ?
        // Clients GEC PRO
     
         if(oQuote.Account.Activity_Domain_Simple__c == 'gec'  && oQuote.Market_type__c == 'PRO' )
         {
            if(oQuote.Opportunity.DO_En_cours_d_immatriculation__c == true ){
                    Piece_Justificative__c pj = new Piece_Justificative__c();
                    pj.Signataire_Document__c = mySigner1.Id;
                    pj.Description__c = 'Récépissé chambre de commerce';
                    pj.Obligatoire__c = true;
                    pj.Type__c = 'Other';
                    pj.Devis__c = oQuote.Id;
                    lPJ.add(pj);
            }
            
        }
        
        if(lPJ.size()>0){
            insert lPJ;
        }
        
        
        // ============================================
        // Création des documents
        // ============================================        
        
        // CGV SE
        /*if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
            if(oQuote.Project_Type__c != 'EXTE' && oQuote.Client_Reenlistment__c == 'Contract' && oQuote.Opportunity.Client_Type__c == 'Owner'){  //  || oQuote.Client_Reenlistment__c == 'Avenant'  ?
                getCGV();
            }
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            if(oQuote.Project_Type__c != 'EXTE' && oQuote.Client_Reenlistment__c == 'Contract'){
                getStaticFilesFromLibraries();
            }
        }*/
        //if(oQuote.Project_Type__c != 'EXTE' && oQuote.Client_Reenlistment__c == 'Contract'){
        if(oQuote.Client_Reenlistment__c == 'Contract'){
            getStaticFilesFromLibraries();
        }
        
        // Bareme(s)
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
       if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c  ){
            if(oQuote.Client_Reenlistment__c == 'Contract'){
                
                
                  generateScalePDF();
            }
        }
        
        // Contract PDF
        generateContractPDF();
        
        // Mandat SEPA PDF
        // For FIDE project type, we only need the Mandat SEPA if the customer wasn't on PO before
        //if(oQuote.Opportunity.Changement_de_banque__c.toUpperCase() == 'OUI' || oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC' || (oQuote.Project_Type__c == 'FIDE' && oQuote.Account.Payment_method__c != 'P')){
        if( (oQuote.Opportunity.Changement_de_banque__c != null && oQuote.Opportunity.Changement_de_banque__c.toUpperCase() == 'OUI') || oQuote.Project_Type__c == 'CREA'|| (oQuote.Project_Type__c == 'SUCC' && oQuote.Account.Activity_Domain_Simple__c == 'gec') || (oQuote.Project_Type__c == 'FIDE' && ( oQuote.Account.Payment_method__c != 'P' && oQuote.Account.Payment_method__c != 'G') ) ){
            if(oQuote.DO_Payment_method__c == 'P'){
                generateMandatSEPAPDF();
                hasDocumentsToBeFilled = true;
            }
        }
        
        // Dossier de MEP + Plan d'implantation
        //if(oQuote.T_RollUpIsMEP__c > 0){
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
            generateMEPPDF();
        }
        //}

        if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            if(withPEC){
                generatePECPDF();
                //generateCDSPDF();
            }
        }
        
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.T_Pack__c == 'ECOCFT'){
            getConsumptionProfileFiles();
        }
        
        
        res = true;
        return res;
    }
    
    /** Send data to Signea **/
    //public static Boolean sendDataToSignea(){
    public static String sendDataToSignea(){
        
        //boolean res = false;
        
        /*private static Attachment contratDoc;
        private static Attachment mandatDoc;
        private static list<Attachment> ListattachementDoc;*/
        
        resetFields();
        
        // ======================================
        // Création du circuit
        // ======================================
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] Création du circuit');
        Signea.Signea_Entities_v2.SigneaCircuit myCircuit = new Signea.Signea_Entities_v2.SigneaCircuit();
        
        
        myCircuit.description = 'Circuit de signature automatisé associé au devis ' + quote.Name;    
        myCircuit.name = parametres[0].Nom_du_circuit__c;
        myCircuit.notifyCreator = String.valueOf(parametres[0].Notification_Createur__c);
        myCircuit.keywords = parametres[0].Index_AES__c;
        //Parametrage prévue dans une futur version de SigneA
        //myCircuit.Condition_d_acceptation__c = parametres[0].Condition_d_acceptation__c;
        
        if(oQuote.Account.Mandataire__c != null){
            myCircuit.emailSender = oQuote.Account.Mandataire__r.Electronic_Signature_Email__c;
        }
        
        if(parametres[0].Notification_additionnelle_generale__c != null && !''.equals(parametres[0].Notification_additionnelle_generale__c)) {
            Signea.Signea_Entities_v2.SigneaNotification notif = new Signea.Signea_Entities_v2.SigneaNotification();
            notif.additionalNotification = emptyIfNull(parametres[0].Notification_additionnelle_generale__c);
            myCircuit.additionalNotification = notif ;
        }
        myCircuit.module = parametres[0].module__c;
        system.Debug(logginglevel.WARN,'\n\n===> keywords are : ' + myCircuit.keywords + '\n\n');
    
    
        // ===================================================
        // Gestion des signataires
        // ===================================================
        myCircuit.stepList = new List<Signea.Signea_Entities_v2.SigneaStep>();
        Map<String, Signea.Signea_Entities_v2.SigneaStep> stepByName = new Map<String, Signea.Signea_Entities_v2.SigneaStep>();
        for(Signataire_Document__c signataire : signataires ) {
            
            // ===================================================
            // Création des étapes
            // ===================================================
            Signea.Signea_Entities_v2.SigneaStep myStep = stepByName.get(signataire.Etape_de_signature__c);
            if(myStep == null){
                myStep = new Signea.Signea_Entities_v2.SigneaStep();
                myStep.name = signataire.Etape_de_signature__c.split('-')[1];
                myStep.stepNumber = Integer.valueof(signataire.Etape_de_signature__c.split('-')[0]);
                myStep.maxDuration = Integer.valueof(signataire.Duree_avant_expiration__c);
                myStep.reminderType = 'After';
                myStep.reminderDays = Integer.valueof(signataire.Delai_avant_relance__c);
                myStep.signerList = new List<Signea.Signea_Entities_v2.SigneaSigner>();
                stepByName.put(signataire.Etape_de_signature__c, myStep);
                myCircuit.stepList.add( myStep );   // Rattachement de l'étape au circuit
            }else {
                //On verifie la durée max
                if(null != signataire.Duree_avant_expiration__c && myStep.maxDuration < signataire.Duree_avant_expiration__c) {
                    myStep.maxDuration = integer.valueOf(signataire.Duree_avant_expiration__c);
                }
                //On vérifie le rappel
                if(null != signataire.Delai_avant_relance__c && myStep.reminderDays < signataire.Delai_avant_relance__c) {
                    myStep.reminderDays = integer.valueOf(signataire.Delai_avant_relance__c);
                }
                
            }
        
            // ===================================================
            // Création des signataires
            // ===================================================  
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] signataire.Type_de_signataire__c = ' + signataire.Type_de_signataire__c);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] signataire.Id_SF_Signataire__c = ' + signataire.Id_SF_Signataire__c);
            if(signataire.Type_de_signataire__c == null || signataire.Id_SF_Signataire__c == null ) {
                Contact newContact = new Contact ();
                newContact.FirstName = emptyIfNull(signataire.civilite__c)+ ' ' + signataire.Prenom__c;
                newContact.LastName = signataire.Name;
                newContact.Email = signataire.Email__c;
                newContact.Phone = signataire.Telephone__c;
                insert newContact;
                signataire.Type_de_signataire__c = 'C';
                signataire.Id_SF_Signataire__c = newContact.Id;
            }else{
                // 20160919 ELC
                if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){                
                    List<Contact> con = [select id, Email, Country__c, Indicatif_Pays_c__c, MobilePhone from Contact where id = :oQuote.Contact.Id ];   
                    if( con.size() > 0 ) {
                        con[0].Email = oQuote.Account.Email__c;
                        con[0].Country__c = oQuote.Account.Country__c;
                        con[0].Indicatif_Pays_c__c = oQuote.Account.Indicatif_Pays__c;
                        con[0].MobilePhone = oQuote.Account.Mobile_Phone_Number__c;
                        update con;
                    }
                }
            }
            Signea.Signea_Entities_v2.SigneaSigner mySigner = new Signea.Signea_Entities_v2.SigneaSigner();
            mySigner.signerType = emptyIfNull(signataire.Type_de_signataire__c); 
            mySigner.signerId = emptyIfNull(signataire.Id_SF_Signataire__c);
            mySigner.signatureType = emptyIfNull(signataire.Type_de_signature__c);		//Ici mySigner.signatureType = 'PAD';
            mySigner.recipientType = emptyIfNull(signataire.Type_de_destinataire__c);
            mySigner.signerPhone = signataire.Telephone__c;
            mySigner.signerEmail = signataire.Email__c;
            mySigner.otpConfig = 
                '<config>'+
                    '<otpDeliveryMode>'+
                          //'<deliveryMode type="EMAIL" count="2" />'+
                          '<deliveryMode type="SMS" count="3" />'+
                    '</otpDeliveryMode>'+
                    '<genOtpConfig>'+
                        '<smsCustomSender>' + System.Label.Signea_SMS_Sender + '</smsCustomSender>'+
                        '<smsCustomMessage>' + System.Label.Signea_SMS_Message_Contract + '</smsCustomMessage>'+
                        //'<emailCustomSubject>Signature de votre Contrat Butagaz - Code OTP</emailCustomSubject>'+
                        //'<emailCustomMessage><![CDATA[<html>Cher Signataire,<br/><br/>Le code OTP nécessaire à la signature de votre contrat Butagaz est : {OTP}</html>]]></emailCustomMessage>'+
                    '</genOtpConfig>'+
                '</config>';
            
            if(null != signataire.Type_de_signature__c) {
                mySigner.participantNumber = integer.valueOf(signataire.Numero_du_participant__c);
            }
            mySigner.position = Integer.ValueOf(signataire.position__c);
            // If no documents to be filled, we set the forceReading on the sign step instead of the fill step
            if(!hasDocumentsToBeFilled){
                mySigner.forceReading = 'FULL_READING';
                mySigner.fillForceReading = 'NO';
            }
            
            // Test présence notification personnalisée
            if(signataire.Notification_additionnelle_personnalisee__c != null && !''.equals(signataire.Notification_additionnelle_personnalisee__c)) {
                Signea.Signea_Entities_v2.SigneaNotification notif = new Signea.Signea_Entities_v2.SigneaNotification();
                notif.additionalNotification = emptyIfNull(signataire.Notification_additionnelle_personnalisee__c);
                mySigner.specificNotification = notif ;
            }
            mySigner.documentaryEvidenceList = new List<Signea.Signea_Entities_v2.SigneaDocumentaryEvidence>();
            myStep.signerList.add( mySigner );  // Rattachement du signataire à l'étape
            
            system.Debug(logginglevel.WARN,'\n\n===> mysigner : ' +  mySigner  + '\n\n');
            // ============================================
            // Création des pièces justificatives à joindre
            // ============================================
            List<Piece_Justificative__c> pjs = [select id, Obligatoire__c, Type__c, Description__c , Signataire_Document__c from Piece_Justificative__c where Signataire_Document__c = :signataire.Id ];
            system.Debug(logginglevel.WARN,'\n\n===> pièces justificatives : ' +  pjs  + '\n\n');
            
            
            for(Piece_Justificative__c pieceJointe : pjs ) {
                Signea.Signea_Entities_v2.SigneaDocumentaryEvidence pj = new Signea.Signea_Entities_v2.SigneaDocumentaryEvidence();
                pj.contactId = emptyIfNull(signataire.Id_SF_Signataire__c) ;
                pj.description = emptyIfNull(pieceJointe.Description__c);
                pj.mandatory = pieceJointe.Obligatoire__c;
                pj.type = emptyIfNull(pieceJointe.Type__c);
                if( sMaxNumberEvidenceFilesForSignea != null )
                    pj.nbDocument = Integer.valueof(sMaxNumberEvidenceFilesForSignea);
                mySigner.documentaryEvidenceList.add(pj);
               
                system.Debug(logginglevel.WARN,'\n\n===> PJ : ' +  pj + '\n\n');
            }   
        }
        
        // ======================================
        // Création des documents Contrat
        // ======================================
        myCircuit.documentList = new List<Signea.Signea_Entities_v2.SigneaDocument>();
        String metadonneEntete = '<?xml version="1.0" encoding="UTF-8"?>'+
                                    '<metadata xmlns="http://www.contralia.fr/metadata">';
        String metadonnePied = '</metadata>';
        String participantsEntete = '<participants>';
        String participantsPied = '</participants>';
        String fieldsEntete = '<fields>';
        String fieldsPied = '</fields>';
        String valuesEntete = '<values>';
        String valuesPied = '</values>';
        
        for(Document_A_Signer__c doc : documents) {
            Signea.Signea_Entities_v2.SigneaDocument myDocument = new Signea.Signea_Entities_v2.SigneaDocument();
            myCircuit.documentList.add( myDocument );    // Rattachement du document au circuit
            myDocument.id = doc.Id_SF_Document__c;
            myDocument.name = emptyIfNull(doc.Name);
            myDocument.type = emptyIfNull(doc.Type_de_document__c);
            // To define how documents are sorted on Contralia website (if field is left blank, those docs will be put at the end by alphabetical order)
            if(myDocument.name.startsWithIgnoreCase('Mandat SEPA-')){
                myDocument.rank = null;
            }else if(myDocument.name.startsWithIgnoreCase('Contrat-')){
                myDocument.rank = 1;
            }else if(myDocument.name.startsWithIgnoreCase('CGV-') || myDocument.name.startsWithIgnoreCase('CG-')){
                myDocument.rank = 2;
            }else if(myDocument.name.startsWithIgnoreCase('Prise en charge-')){
                myDocument.rank = 3;
            }else{
                myDocument.rank = 4;
            }
            // ============================================
            // Création des Tags de remplissage
            // ============================================
            
            Set<String> participants = new Set<String>();
            integer i=1;
            List<Zone_De_Remplissage__c > tags = [select id, Name, Numero_Participant__c, Type_de_remplissage__c, Description__c, Position_X__c, Position_Y__c, Page__c, Largeur__c, Hauteur__c, Taille_de_la_Police__c, Obligatoire__c, Format_champ__c, Message_erreur__c, Police__c, Valeur_preremplie__c from Zone_De_Remplissage__c where Identifiant_document__c= :doc.Id ];    
            system.Debug(logginglevel.WARN,'\n\n===> zone remplissage : ' +  tags  + '\n\n');
            String fields = '';
            String parts = '';
            String values = '';
            for(Zone_De_Remplissage__c tag : tags ) {
                String numPart = String.valueOf(tag.Numero_Participant__c);
                if(!participants.contains(numPart) && tag.Numero_Participant__c>0) {
                    participants.add(numPart );
                    parts = parts+'\n'+'<participant number="'+tag.Numero_Participant__c+'" name="Participant'+tag.Numero_Participant__c+'" />';
                }
                
                String field = '<field participantNumber="'+tag.Numero_Participant__c +'"'+
                                      ' type="'+emptyIfNull(tag.Type_de_remplissage__c)+'"'+
                                      ' name="'+tag.Name+'"'+     /* ' name="name_'+i+'"'+ */
                                      ' description="'+emptyIfNull(tag.description__c)+'"'+
                                      ' x="'+tag.Position_X__c+'"'+
                                      ' y="'+tag.Position_Y__c+'"'+
                                      ' page="'+tag.Page__c+'"'+
                                      ' width="'+tag.Largeur__c+'"'+
                                      ' height="'+tag.Hauteur__c+'"'+
                                      ' fontSize="'+tag.Taille_de_la_police__c+'"'+
                                      ' required="'+tag.Obligatoire__c+'"'+
                                      ' regEx="'+emptyIfNull(tag.format_champ__c)+'"'+
                                      ' regExTip="'+emptyIfNull(tag.Message_erreur__c)+'"'+
                                      ' font="'+emptyIfNull(tag.police__c)+'"'+
                                      ' values="" />';
                 fields = fields+'\n'+field;
                 
            
                /*values = values+'\n'+'<value fieldName="name_'+i+'"' +  ' value="'+emptyIfNull(tag.Valeur_preremplie__c)+'" />';*/
                /*values = values+'\n'+'<value fieldName="name_'+i+'"' +  ' value="'+emptyIfNull(tag.Valeur_preremplie__c).replace('&', 'et')+'" />';*/
                values = values+'\n'+'<value fieldName="'+tag.Name+'"' +  ' value="'+emptyIfNull(tag.Valeur_preremplie__c).replace('&', 'et')+'" />';
                i++;
            }
            myDocument.metadata =   metadonneEntete
                                      + '\n'+participantsEntete
                                      +   parts
                                      + '\n'+participantsPied
                                      + '\n'+fieldsEntete
                                      +   fields
                                      + '\n'+fieldsPied
                                      + '\n'+valuesEntete
                                      +   values
                                      + '\n'+valuesPied 
                                      +'\n'+metadonnePied;
                                      
            system.Debug(logginglevel.WARN,'\n\n===> mandate metadata are : ' +  myDocument.metadata + '\n\n');
        } 
        
        
        // ============================================
        // Lancement du circuit
        // ============================================
        system.Debug(logginglevel.WARN,'myCircuit : ' + myCircuit);
        Signea.Signea_Entities_V2.SigneaServicesResult result = Signea.Signea_API_V2.createNlaunchCircuit(myCircuit);
        
        system.Debug(logginglevel.WARN,'result : ' + result);
        if( result.errorCode == '000' ) {
            // Associate circuit with the quote
            oQuote.Signea_Circuit__c = result.result;
            oQuote.Signea_Date_Signature__c = null;
            oQuote.Statut_circuit_de_signature__c = '';
            update oQuote;

            // Associate circuit with the PEC if applicable
            if(withPEC==true){
                oPECToSign.Signea_Circuit__c = result.result;
                //oQuote.Signea_Date_Signature__c = null;
                //oPECToSign.Status__c = '';
                update oPECToSign;
            }

            // Associate circuit with the account
            Signea__Circuit__c oCircuit = [ select Id, Name, AccountBTZ__c from Signea__Circuit__c where Id = :oQuote.Signea_Circuit__c LIMIT 1 ];
            if(oCircuit != null && oQuote.Account != null){
                oCircuit.AccountBTZ__c = oQuote.Account.Id;
                
                update oCircuit;
            }
            
            return result.errorCode + '-' + result.result;
        } else {
            return result.errorCode + '-' + result.errorMessage;
        }
        
    }
    
    
    static String emptyIfNull(String s) {
        if (s == null) {
            return '';
        } else {
            return s;
        }
    }
    
    
    /** Generate and save Contract PDF file **/ 
    public static void generateContractPDF() {
        /*PageReference pdfPage = Page.VFP_ContractPDF;
        pdfPage.getParameters().put('id', oQuote.Id);
        Blob pdfBlob = pdfPage.getContent();
        Attachment attach = new Attachment(parentId = oQuote.Id, Name = 'Contrat-' + oQuote.QuoteNumber + '.pdf', body = pdfBlob);
        insert attach;*/
        
        PageReference pdfPage = Page.VFP_ContractPDF;
        pdfPage.getParameters().put('id', oQuote.Id);
        pdfPage.getParameters().put('isSE', isSE);
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
          if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
          System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] withdrawalText GEC DOM= ' );
            pdfPage.getParameters().put('withdrawalText', 'true');
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] withdrawalText GEB PRO= ' );
            if(oQuote.Project_Type__c == 'FIDE'){
                pdfPage.getParameters().put('displayCGUSE', 'true');
            }
            pdfPage.getParameters().put('withdrawalText', 'false');
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'PRO'){
            if(oQuote.Opportunity.Project_market_subtype__c == 'Collectivité/Administration' || oQuote.Opportunity.Project_market_subtype__c == 'Commerce/Service'){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] withdrawalText GEC PRO COLL= ' + oQuote.Opportunity.Project_market_subtype__c );
                pdfPage.getParameters().put('withdrawalText', 'true');
                }else{
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] withdrawalText GEC PRO CHR= ' + oQuote.Opportunity.Project_market_subtype__c );
                pdfPage.getParameters().put('withdrawalText', 'false');
                }
        }
        pdfPage.getParameters().put('nbSig', '3');
        //Blob pdfBlob = pdfPage.getContent();
        
        // getContent not supported in Test Methods, so we need to handle it
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
        
        /*Blob pdfBlob;
        try {
          pdfBlob = pdfPage.getContent();
          
        // getContent not supported in Test Methods, so we need to handle it
        } catch (VisualforceException e) {
            pdfBlob = Blob.valueOf('Some Text');
        }*/
        
        // Document
        Document oDoc = New Document();
        oDoc.Name = 'Contrat-' + oQuote.QuoteNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oQuote.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Contrat-' + oQuote.QuoteNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.devis__c = oQuote.Id;
        insert oDocASigner;
        
        // /!\ Paramétrer tous les tags dans une table ?
        // Zone_De_Remplissage__c
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        
        // Signature
        Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
        tag1.Identifiant_document__c = oDocASigner.Id;
        tag1.Numero_Participant__c = 1;
        tag1.Description__c = '';
        tag1.Type_de_remplissage__c = 'SIGNATURE';
        tag1.Name = 'CONTRACTSIG_1';
        tag1.Page__c = -1;
        tag1.Position_X__c = 37;
        tag1.Position_Y__c = 408;
        tag1.Largeur__c = 148;
        tag1.Hauteur__c = 110;
        tag1.Taille_de_la_police__c = FONT_SIZE;
        tag1.Obligatoire__c = false;
        tag1.Valeur_preremplie__c = '';
        tag1.format_champ__c = '';
        tag1.Message_erreur__c = '';
        lTag.add(tag1);
        
        // Signature
        Zone_De_Remplissage__c tag2 = new Zone_De_Remplissage__c();
        tag2.Identifiant_document__c = oDocASigner.Id;
        tag2.Numero_Participant__c = -2;
        tag2.Description__c = '';
        tag2.Type_de_remplissage__c = 'SIGNATURE';
        tag2.Name = 'CONTRACTSIG_2';
        tag2.Page__c = -1;
        tag2.Position_X__c = 399;
        tag2.Position_Y__c = 408;
        tag2.Largeur__c = 148;
        tag2.Hauteur__c = 110;
        tag2.Taille_de_la_police__c = FONT_SIZE;
        tag2.Obligatoire__c = false;
        tag2.Valeur_preremplie__c = '';
        tag2.format_champ__c = '';
        tag2.Message_erreur__c = '';
        lTag.add(tag2);
        
        // Signature
        Zone_De_Remplissage__c tag3 = new Zone_De_Remplissage__c();
        tag3.Identifiant_document__c = oDocASigner.Id;
        tag3.Numero_Participant__c = -1;
        tag3.Description__c = '';
        tag3.Type_de_remplissage__c = 'SIGNATURE';
        tag3.Name = 'CONTRACTSIG_3';
        tag3.Page__c = -1;
        tag3.Position_X__c = 218;
        tag3.Position_Y__c = 408;
        tag3.Largeur__c = 148;
        tag3.Hauteur__c = 110;
        tag3.Taille_de_la_police__c = FONT_SIZE;
        tag3.Obligatoire__c = false;
        tag3.Valeur_preremplie__c = '';
        tag3.format_champ__c = '';
        tag3.Message_erreur__c = '';
        lTag.add(tag3);
        
        if(lTag.size()>0){
            insert lTag;
        }
        
    }
    
    
    /** Generate and save MandatSEPA PDF file **/ 
    public static void generateMandatSEPAPDF() {
        
        PageReference pdfPage = Page.VFP_Mandat_SEPA;
        pdfPage.getParameters().put('id', oQuote.Id);
        //Blob pdfBlob = pdfPage.getContent();
        
        // getContent not supported in Test Methods, so we need to handle it
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
        
        /*Blob pdfBlob;
        try {
          pdfBlob = pdfPage.getContent();
          
        // getContent not supported in Test Methods, so we need to handle it
        } catch (VisualforceException e) {
          pdfBlob = Blob.valueOf('Some Text');
        }*/
        
        // Document
        Document oDoc = New Document();
        oDoc.Name = 'Mandat SEPA-' + oQuote.QuoteNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oQuote.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Mandat SEPA-' + oQuote.QuoteNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.devis__c = oQuote.Id;
        insert oDocASigner;
        
        // Zone_De_Remplissage__c
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        
        // BIC
        Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
        tag1.Identifiant_document__c = oDocASigner.Id;
        tag1.Numero_Participant__c = 1;
        tag1.Description__c = 'Saisissez votre BIC';
        tag1.Type_de_remplissage__c = 'TEXT';
        tag1.Name = 'SEPA_BIC';
        tag1.Page__c = 1;
        tag1.Position_X__c = 75;
        tag1.Position_Y__c = 537;
        tag1.Largeur__c = 183;
        tag1.Hauteur__c = 16;
        tag1.Taille_de_la_police__c = FONT_SIZE;
        tag1.Obligatoire__c = true;
        tag1.Valeur_preremplie__c = '';
        //tag1.format_champ__c = '([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)';
        tag1.format_champ__c = '^[a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?$';
        tag1.Message_erreur__c = 'Saisissez vos données BIC sans espace';
        lTag.add(tag1);
        
        // IBAN
        Zone_De_Remplissage__c tag2 = new Zone_De_Remplissage__c();
        tag2.Identifiant_document__c = oDocASigner.Id;
        tag2.Numero_Participant__c = 1;
        tag2.Description__c = 'Saisissez votre IBAN';
        tag2.Type_de_remplissage__c = 'TEXT';
        tag2.Name = 'SEPA_IBAN';
        tag2.Page__c = 1;
        tag2.Position_X__c = 75;
        tag2.Position_Y__c = 510;
        tag2.Largeur__c = 246;
        tag2.Hauteur__c = 16;
        tag2.Taille_de_la_police__c = FONT_SIZE;
        tag2.Obligatoire__c = true;
        tag2.Valeur_preremplie__c = '';
        //tag2.format_champ__c = '[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}';
        tag2.format_champ__c = '^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{11,30}$';
        tag2.Message_erreur__c = 'Saisissez vos données IBAN sans espace';
        lTag.add(tag2);
        
        // Client Salutation FirstName LastName
        Zone_De_Remplissage__c tag3 = new Zone_De_Remplissage__c();
        tag3.Identifiant_document__c = oDocASigner.Id;
        tag3.Numero_Participant__c = 1;
        tag3.Description__c = 'Nom du client';
        tag3.Type_de_remplissage__c = 'TEXT';
        tag3.Name = 'SEPA_NAME';
        tag3.Page__c = 1;
        tag3.Position_X__c = 40;
        tag3.Position_Y__c = 433;
        tag3.Largeur__c = 280;
        tag3.Hauteur__c = 16;
        tag3.Taille_de_la_police__c = FONT_SIZE;
        tag3.Obligatoire__c = true;
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
            tag3.Valeur_preremplie__c = (oQuote.Contact.Salutation == null ? '' : oQuote.Contact.Salutation + ' ') + (oQuote.Contact.FirstName == null ? '' : oQuote.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') + ' ') + (oQuote.Contact.LastName == null ? '' : oQuote.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        }else{
            tag3.Valeur_preremplie__c = (oQuote.Opportunity.DO_Salutation__c == null ? '' : oQuote.Opportunity.DO_Salutation__c + ' ') + (oQuote.Opportunity.DO_Name__c == null ? '' : oQuote.Opportunity.DO_Name__c.replaceAll('[^- \'\\p{L}\\p{M}*]', '') + ' ');
        }
        //tag3.format_champ__c = '';
        //tag3.format_champ__c = '^[!#$%&amp;&apos;(),.:;_\\- a-zA-Z0-9] {2,40}$';
        tag3.format_champ__c = '^[!#$\'(),.:;_\\- a-zA-Z0-9]{2,40}$';
        tag3.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag3);
        
        // Address line 1
        Zone_De_Remplissage__c tag4 = new Zone_De_Remplissage__c();
        tag4.Identifiant_document__c = oDocASigner.Id;
        tag4.Numero_Participant__c = 1;
        tag4.Description__c = 'Adresse du client 1';
        tag4.Type_de_remplissage__c = 'TEXT';
        tag4.Name = 'SEPA_ADDR';
        tag4.Page__c = 1;
        tag4.Position_X__c = 40;
        tag4.Position_Y__c = 415;
        tag4.Largeur__c = 280;
        tag4.Hauteur__c = 16;
        tag4.Taille_de_la_police__c = FONT_SIZE;
        tag4.Obligatoire__c = true;
        tag4.Valeur_preremplie__c = (oQuote.Opportunity.DO_Street_N__c == null ? '' : oQuote.Opportunity.DO_Street_N__c + ' ') + (String.isBlank(oQuote.Opportunity.DO_Number_extention__c) ? '' : oQuote.Opportunity.DO_Number_extention__c + ' ') + (oQuote.Opportunity.DO_Street_type__c == null ? '' : oQuote.Opportunity.DO_Street_type__c + ' ') + (oQuote.Opportunity.DO_Street_name__c == null ? '' : oQuote.Opportunity.DO_Street_name__c + ' ') + (oQuote.Opportunity.DO_Lieu_dit__c == null ? '' : oQuote.Opportunity.DO_Lieu_dit__c);
        //tag4.format_champ__c = '';
        //tag4.format_champ__c = '^[!#$%&amp;&apos;(),.:;_\\- a-zA-Z0-9] {2,40}$';
        tag4.format_champ__c = '^[!#$\'(),.:;_\\- a-zA-Z0-9]{2,40}$';
        tag4.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag4);
        
        // Address line 2
        Zone_De_Remplissage__c tag5 = new Zone_De_Remplissage__c();
        tag5.Identifiant_document__c = oDocASigner.Id;
        tag5.Numero_Participant__c = 1;
        tag5.Description__c = 'Adresse du client 2';
        tag5.Type_de_remplissage__c = 'TEXT';
        tag5.Name = 'SEPA_CITY';
        tag5.Page__c = 1;
        tag5.Position_X__c = 40;
        tag5.Position_Y__c = 397;
        tag5.Largeur__c = 280;
        tag5.Hauteur__c = 16;
        tag5.Taille_de_la_police__c = FONT_SIZE;
        tag5.Obligatoire__c = true;
        if(oQuote.Opportunity.DO_City_Postal_Code__c != null){
            tag5.Valeur_preremplie__c = oQuote.Opportunity.DO_City_Postal_Code__r.Name;
        }else{
            tag5.Valeur_preremplie__c = (oQuote.Opportunity.DO_Postal_Code__c == null ? '' : oQuote.Opportunity.DO_Postal_Code__c) + ' - ' + (oQuote.Opportunity.DO_City__c == null ? '' : oQuote.Opportunity.DO_City__c);
        }
        //tag5.format_champ__c = '';
        //tag5.format_champ__c = '^[&apos;(),.\\- a-zA-Z0-9] {2,30}$';
        tag5.format_champ__c = '^[\'(),.\\- a-zA-Z0-9]{2,30}$';
        tag5.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag5);
        
        // Signature
        Zone_De_Remplissage__c tag6 = new Zone_De_Remplissage__c();
        tag6.Identifiant_document__c = oDocASigner.Id;
        tag6.Numero_Participant__c = 1;
        tag6.Description__c = '';
        tag6.Type_de_remplissage__c = 'SIGNATURE';
        tag6.Name = 'SEPA_SIG';
        tag6.Page__c = 1;
        tag6.Position_X__c = 432;
        tag6.Position_Y__c = 241;
        tag6.Largeur__c = 153;
        tag6.Hauteur__c = 80;
        tag6.Taille_de_la_police__c = FONT_SIZE;
        tag6.Obligatoire__c = false;
        tag6.Valeur_preremplie__c = '';
        tag6.format_champ__c = '';
        tag6.Message_erreur__c = '';
        lTag.add(tag6);
        
        
        if(lTag.size()>0){
            insert lTag;
        }
        
    }
    
    
    /** Generate and save Scale PDF file **/ 
    public static void generateScalePDF() {
        
        PageReference pdfPage = Page.VFP_ScalePDF;
        pdfPage.getParameters().put('id', oQuote.Id);
        pdfPage.getParameters().put('isSE', isSE);
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
       if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
            pdfPage.getParameters().put('withdrawalText', 'true');
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            pdfPage.getParameters().put('withdrawalText', 'false');
        }
        pdfPage.getParameters().put('nbSig', '3');
        //Blob pdfBlob = pdfPage.getContent();
        
        // getContent not supported in Test Methods, so we need to handle it
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
        
        /*Blob pdfBlob;
        try {
          pdfBlob = pdfPage.getContent();
          
        // getContent not supported in Test Methods, so we need to handle it
        } catch (VisualforceException e) {
            pdfBlob = Blob.valueOf('Some Text');
        }*/
        
        // Document
        Document oDoc = New Document();
        oDoc.Name = 'Bareme-' + oQuote.QuoteNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oQuote.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Bareme-' + oQuote.QuoteNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.devis__c = oQuote.Id;
        insert oDocASigner;
        
        // Zone_De_Remplissage__c
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        
        // Signature
        Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
        tag1.Identifiant_document__c = oDocASigner.Id;
        tag1.Numero_Participant__c = 1;
        tag1.Description__c = '';
        tag1.Type_de_remplissage__c = 'SIGNATURE';
        tag1.Name = 'SCALE_SIG';
        tag1.Page__c = -1;
        tag1.Position_X__c = 220;
        tag1.Position_Y__c = 408;
        tag1.Largeur__c = 146;
        tag1.Hauteur__c = 109;
        tag1.Taille_de_la_police__c = FONT_SIZE;
        tag1.Obligatoire__c = false;
        tag1.Valeur_preremplie__c = '';
        tag1.format_champ__c = '';
        tag1.Message_erreur__c = '';
        lTag.add(tag1);
        
        if(lTag.size()>0){
            insert lTag;
        }
        
    }
    
    
    public List<Document> getScales() {
        
        List<Document> scaleList = new List<Document>();
        List<Document> sortedScaleList = new List<Document>();
        
        List<String> tmpProductScaleList = new List<String>();
        List<String> tmpScaleList = new List<String>();
        List<String> tmpTankPriceList = new List<String>();
        
        Integer i = 1;
        mSortDocs = new Map<Integer, String>();
        
        //if (mSortDocs != null) mSortDocs.clear();
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Id = ' + oQuote.Id);
       // Get product scales
      
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Product_Scale__c = ' + oQuote.Product_Scale__c);
        if(oQuote.Opportunity.T_Pack__c !='OPTIMO'){
            if(oQuote.Product_Scale__c != null && oQuote.VAT_code__c != null ){
                tmpProductScaleList = getDocumentsIdsValue(oQuote.Product_Scale__c + '_' + oQuote.VAT_code__c).split(';');
                for(String str : tmpProductScaleList){
                    mSortDocs.put(i, str);
                    i++;
                }
            }
         }
        
        // Get scales (redevance)
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Scale__c = ' + oQuote.Scale__c);
        if(oQuote.Scale__c != null && oQuote.Scale__c != 'NA'){
            tmpScaleList = getDocumentsIdsValue(oQuote.Scale__c).split(';');
            for(String str : tmpScaleList){
                mSortDocs.put(i, str);
                i++;
            }
        }

        // Get V2F scale in case of service type products in the qlis
        // 20210118 : Update : Add V2F even if no service type products
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.Client_Type__c == 'Owner' && oQuote.Market_type__c== 'PRO'){
            //if(hasServiceProduct()){
                tmpScaleList = getDocumentsIdsValue('V2F').split(';');
                for(String str : tmpScaleList){
                    mSortDocs.put(i, str);
                    i++;
                }
            //}
        }
        
        // Get tank price
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Account.Activity_Domain_Simple__c = ' + oQuote.Account.Activity_Domain_Simple__c);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Opportunity.Client_Type__c = ' + oQuote.Opportunity.Client_Type__c);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Market_type__c= ' + oQuote.Market_type__c);
     //   System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.Project_Type__c= ' + oQuote.Project_Type__c );
     //   System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oQuote.DO_Groupement__c = ' + oQuote.DO_Groupement__c );
     
     // MLC 20210607  |  Sharepoint 422  Dans le cas d’une signature électronique, supprimer l’envoi automatique du barème Citernes à compter du 10 juin-->
     /*   if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.Client_Type__c == 'Owner' && oQuote.Market_type__c== 'DOM'  ){
            tmpTankPriceList = getDocumentsIdsValue('BaremeCiternes').split(';');
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] tmpTankPriceList = ' + tmpTankPriceList);
            for(String str : tmpTankPriceList){
                mSortDocs.put(i, str);
                i++;
            }
        }*/
        
        /* Erwan 20201117 : Commented out
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.Client_Type__c == 'Owner' && oQuote.Market_type__c== 'PRO' && (oQuote.Project_Type__c == 'CREA' || oQuote.Project_Type__c == 'SUCC')   ){
           if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.Client_Type__c == 'Owner' && oQuote.Market_type__c== 'PRO' && (oQuote.Project_Type__c !='FIDE')   ){ 
           if (oQuote.Scale__c=='2G')
           {
            tmpTankPriceList = getDocumentsIdsValue('V2GR').split(';');
           }
           else
           {
            tmpTankPriceList = getDocumentsIdsValue('MADV').split(';');
           }
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] tmpTankPriceList = ' + tmpTankPriceList);
            for(String str : tmpTankPriceList){
                mSortDocs.put(i, str);
                i++;
            }
        }
        */
        
        // Retrieve documents from db
        if(mSortDocs != null && !mSortDocs.isEmpty()){
            scaleList = [select Id from Document where Id=:mSortDocs.values()];
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] scaleList = ' + scaleList);
            // Manual sorting of the list to maintain docs order (Product, Redevance, Tank)
            for(String sortDoc : mSortDocs.values()){
                for (Document doc : scaleList){
                    if(sortDoc == doc.Id) sortedScaleList.add(doc); 
                }
            }
        }
        
        return sortedScaleList;
        
    }
    
    
    /** Generate and save MEP PDF file(s) **/ 
    public static void generateMEPPDF() {
        
        /*Set<Id> OTPLsWithoutPlanImplantationSet = new Set<Id>();
        
        // Feed a Set to generate PDF only for OPTLs with PlanImplantation
        for(Opportunity_PTL__c oOTPLsWithoutPlanImplantation : OTPLsWithoutPlanImplantation()){
          if(!OTPLsWithoutPlanImplantationSet.contains(oOTPLsWithoutPlanImplantation.id)){
          OTPLsWithoutPlanImplantationSet.add(oOTPLsWithoutPlanImplantation.id);
          }
        }*/
        
        
        if (lOPTLsWithPlanImplantation.size() > 0){
          
            for (Opportunity_PTL__c oOPTL : lOPTLsWithPlanImplantation){
              
                // Skip to next iteration if PlanImplantation is missing
                /*if(OTPLsWithoutPlanImplantationSet.contains(oOPTL.Id)){
                    continue;
                }*/
                  
                PageReference pdfPage = Page.VFP_AvenantPDF_Dossiers;
                pdfPage.getParameters().put('id', oOPTL.Id);
                pdfPage.getParameters().put('isSE', isSE);
                //Blob pdfBlob = pdfPage.getContent();
                
                // getContent not supported in Test Methods, so we need to handle it
                Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
                
                /*Blob pdfBlob;
                try {
                  pdfBlob = pdfPage.getContent();
                  
                // getContent not supported in Test Methods, so we need to handle it
                } catch (VisualforceException e) {
                  pdfBlob = Blob.valueOf('Some Text');
                }*/
                
                // Document
                Document oDoc = New Document();
                // oDoc.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
                oDoc.Name = 'Plan et dossier MEP-' + oOPTL.Name;
                oDoc.Body = pdfBlob;
                oDoc.Type = 'pdf';
                oDoc.FolderId = sFolderId;
                oDoc.Description = oQuote.Id;
                insert oDoc;
                
                // Document_A_Signer__c
                Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
                oDocASigner.Id_SF_Document__c = oDoc.Id;
                //oDocASigner.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
                oDocASigner.Name = 'Plan et dossier MEP-' + oOPTL.Name;
                oDocASigner.Type_de_document__c = 'Document';
                oDocASigner.devis__c = oQuote.Id;
                oDocASigner.Identifiant_OPTL__c = oOPTL.Id;
                insert oDocASigner;
                
                // Zone_De_Remplissage__c
                List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
                
                // Signature
                Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
                tag1.Identifiant_document__c = oDocASigner.Id;
                tag1.Numero_Participant__c = 1;
                tag1.Description__c = '';
                tag1.Type_de_remplissage__c = 'SIGNATURE';
                tag1.Name = 'MEP_SIG';
                tag1.Page__c = -1;
                tag1.Position_X__c = 215.54933; //432;
                tag1.Position_Y__c = 406.67783; //241;
                tag1.Largeur__c = 153.2287; //153;
                tag1.Hauteur__c = 112.97758; //80;
                tag1.Taille_de_la_police__c = FONT_SIZE;
                tag1.Obligatoire__c = false;
                tag1.Valeur_preremplie__c = '';
                tag1.format_champ__c = '';
                tag1.Message_erreur__c = '';
                lTag.add(tag1);
                
                if(lTag.size()>0){
                    insert lTag;
                }
              
            }
        }
        
    }
    
    /** Method to check if there is a PEC available to add to the documents **/
    //Get PEC linked to the account with status "Attente de signature"
    /*public List<PEC__c> getListPEC(){
        
        List<PEC__c> lPEC = [SELECT Id FROM PEC__c WHERE Account__c =: oQuote.AccountId AND Status__c = 'Attente de signature' LIMIT 1];

        return lPEC;
    }*/

    public static List<PEC__c> getPECToSign(){
        
        List<PEC__c> lPEC = [SELECT Id, Name, Signea_Circuit__c FROM PEC__c WHERE Account__c =: oQuote.AccountId AND Status__c = 'Attente de signature'];

        return lPEC;
    }


    /** Generate PEC PDF file **/ 
    //public static void generatePECPDF(PEC__c pPEC) {
    public static void generatePECPDF() {
        
        //oPECToSign = getPECToSign();
        if(oPECToSign!=null){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oPECToSign.Id = ' + oPECToSign.Id);
            PageReference pdfPage = Page.VFP_PriseEnChargePDF;
            pdfPage.getParameters().put('id', oPECToSign.Id);
            pdfPage.getParameters().put('isSE', isSE);
            pdfPage.getParameters().put('displayCGUSE', 'true');
            pdfPage.getParameters().put('withdrawalText', 'false');
            pdfPage.getParameters().put('nbSig', '3');
            
            // getContent not supported in Test Methods, so we need to handle it
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
            
            
            // Document
            Document oDoc = New Document();
            // oDoc.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
            oDoc.Name = 'Prise en charge-' + oPECToSign.Name;
            oDoc.Body = pdfBlob;
            oDoc.Type = 'pdf';
            oDoc.FolderId = sFolderId;
            oDoc.Description = oQuote.Id;
            insert oDoc;
            
            // Document_A_Signer__c
            Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
            oDocASigner.Id_SF_Document__c = oDoc.Id;
            //oDocASigner.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
            oDocASigner.Name = 'Prise en charge-' + oPECToSign.Name;
            oDocASigner.Type_de_document__c = 'Document';
            oDocASigner.devis__c = oQuote.Id;
            //oDocASigner.Identifiant_OPTL__c = oOPTL.Id;
            insert oDocASigner;
            
            // Zone_De_Remplissage__c
            List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
            
            /*// Signature
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 1;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'SIGNATURE';
            tag1.Name = 'Name_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 215.54933; //432;
            tag1.Position_Y__c = 406.67783; //241;
            tag1.Largeur__c = 153.2287; //153;
            tag1.Hauteur__c = 112.97758; //80;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = '';
            tag1.format_champ__c = '';
            tag1.Message_erreur__c = '';
            lTag.add(tag1);*/

            // Signature
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 1;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'SIGNATURE';
            tag1.Name = 'PEC_SIG_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 37;
            tag1.Position_Y__c = 408;
            tag1.Largeur__c = 148;
            tag1.Hauteur__c = 110;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = '';
            tag1.format_champ__c = '';
            tag1.Message_erreur__c = '';
            lTag.add(tag1);
            
            // Signature
            Zone_De_Remplissage__c tag2 = new Zone_De_Remplissage__c();
            tag2.Identifiant_document__c = oDocASigner.Id;
            tag2.Numero_Participant__c = -2;
            tag2.Description__c = '';
            tag2.Type_de_remplissage__c = 'SIGNATURE';
            tag2.Name = 'PEC_SIG_2';
            tag2.Page__c = -1;
            tag2.Position_X__c = 399;
            tag2.Position_Y__c = 408;
            tag2.Largeur__c = 148;
            tag2.Hauteur__c = 110;
            tag2.Taille_de_la_police__c = FONT_SIZE;
            tag2.Obligatoire__c = false;
            tag2.Valeur_preremplie__c = '';
            tag2.format_champ__c = '';
            tag2.Message_erreur__c = '';
            lTag.add(tag2);
            
            // Signature
            Zone_De_Remplissage__c tag3 = new Zone_De_Remplissage__c();
            tag3.Identifiant_document__c = oDocASigner.Id;
            tag3.Numero_Participant__c = -1;
            tag3.Description__c = '';
            tag3.Type_de_remplissage__c = 'SIGNATURE';
            tag3.Name = 'PEC_SIG_3';
            tag3.Page__c = -1;
            tag3.Position_X__c = 218;
            tag3.Position_Y__c = 408;
            tag3.Largeur__c = 148;
            tag3.Hauteur__c = 110;
            tag3.Taille_de_la_police__c = FONT_SIZE;
            tag3.Obligatoire__c = false;
            tag3.Valeur_preremplie__c = '';
            tag3.format_champ__c = '';
            tag3.Message_erreur__c = '';
            lTag.add(tag3);
            
            if(lTag.size()>0){
                insert lTag;
            }
        }

    }

    /** Method to check if there is a CDS available to add to the documents **/
    /*public static List<CDS__c> getCDSToSign(){
        
        List<CDS__c> lCDS = [SELECT Id, Name, Signea_Circuit__c FROM CDS__c WHERE Account__c =: oQuote.AccountId AND Status__c = 'Attente de signature' LIMIT 1];

        return lCDS;
    }*/


    /** Generate PEC PDF file **/ 
    /*public static void generateCDSPDF() {
        
        //oCDSToSign = getCDSToSign();
        if(oCDSToSign!=null){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] oCDSToSign.Id = ' + oCDSToSign.Id);
            PageReference pdfPage = Page.VFP_ControleDesStocksPDF;
            pdfPage.getParameters().put('id', oCDSToSign.Id);
            pdfPage.getParameters().put('isSE', isSE);
            pdfPage.getParameters().put('displayCGUSE', 'true');
            pdfPage.getParameters().put('withdrawalText', 'false');
            pdfPage.getParameters().put('nbSig', '3');
            
            // getContent not supported in Test Methods, so we need to handle it
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
            
            
            // Document
            Document oDoc = New Document();
            // oDoc.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
            oDoc.Name = 'Contrôle de stock-' + oCDSToSign.Name;
            oDoc.Body = pdfBlob;
            oDoc.Type = 'pdf';
            oDoc.FolderId = sFolderId;
            oDoc.Description = oQuote.Id;
            insert oDoc;
            
            // Document_A_Signer__c
            Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
            oDocASigner.Id_SF_Document__c = oDoc.Id;
            //oDocASigner.Name = 'Plan et dossier MEP-' + oQuote.QuoteNumber + '-' + oOPTL.Name;
            oDocASigner.Name = 'Contrôle de stock-' + oCDSToSign.Name;
            oDocASigner.Type_de_document__c = 'Document';
            oDocASigner.devis__c = oQuote.Id;
            //oDocASigner.Identifiant_OPTL__c = oOPTL.Id;
            insert oDocASigner;
            
            // Zone_De_Remplissage__c
            List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
            
            // Signature
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 1;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'SIGNATURE';
            tag1.Name = 'Name_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 215.54933; //432;
            tag1.Position_Y__c = 406.67783; //241;
            tag1.Largeur__c = 153.2287; //153;
            tag1.Hauteur__c = 112.97758; //80;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = '';
            tag1.format_champ__c = '';
            tag1.Message_erreur__c = '';
            lTag.add(tag1);
            
            if(lTag.size()>0){
                insert lTag;
            }
        }

    }*/
    
    /** Get CGV PDF file from Libraries and make a copy in Documents and a reference to Document in Document_A_Signer__c **/ 
    //public static boolean getCGV() {
    /*public static void getCGV() {   // Not used anymore
        List<Document_A_Signer__c> lDocASigner = new List<Document_A_Signer__c>();
        string sDocId;
        
        //boolean res = false;
        
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
            sDocId = getDocumentsIdsValue('CGV_GEC_DOM_SE');
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            // A modifier pour le GEB PRO une fois le document fourni
            sDocId = getDocumentsIdsValue('CGV_GEC_DOM_SE');
        }
        //string sCGVLabel = System.Label.CGV_Label_For_Signea == null ? '' : System.Label.CGV_Label_For_Signea;
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] sDocId = ' + sDocId);
        
        //List<ContentVersion> lContentVersion = [SELECT Id, Title, PublishStatus, VersionNumber, VersionData, IsLatest, PathOnClient, FileType, ContentUrl, TagCsv, ContentDocument.LatestPublishedVersionId
        //        FROM ContentVersion 
        //        WHERE ContentDocumentId in ( 
        //            SELECT ContentDocumentId FROM ContentWorkspaceDoc 
        //            //WHERE ContentWorkspaceId = '058D000000093Bd' 
        //            //AND ContentWorkspace.Name = 'Barèmes' 
        //            WHERE ContentDocumentId =:sDocId
        //        )
        //        AND IsLatest = True];
        
        //, Title, PublishStatus, VersionNumber, IsLatest, PathOnClient, ContentUrl, TagCsv, ContentDocument.LatestPublishedVersionId
        List<ContentVersion> lContentVersion = [SELECT Id, VersionData, FileType 
                FROM ContentVersion 
                WHERE IsLatest = True
                AND ContentDocumentId =:sDocId];
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] lContentVersion.size() = ' + lContentVersion.size());
        
        // Copy Document from Libraries to Documents
        if (!lContentVersion.IsEmpty()){
            List<Document> lDocs = new List<Document>();
            
            for (ContentVersion oContentVersion : lContentVersion){
                Document oDoc = New Document();
                // oDoc.Name = sCGVLabel + '-' + oQuote.QuoteNumber;
                oDoc.Name = 'CGV-' + oQuote.QuoteNumber;
                oDoc.Body = oContentVersion.VersionData;
                oDoc.Type = oContentVersion.FileType;
                oDoc.FolderId = sFolderId;
                oDoc.Description = oQuote.Id;
                lDocs.add(oDoc);
            }
            
            if(lDocs.size() > 0){
                Insert lDocs;
            }
            
            // Document_A_Signer__c
            Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
            oDocASigner.Id_SF_Document__c = lDocs[0].Id;
            //oDocASigner.Name = sCGVLabel + '-' + oQuote.QuoteNumber;
            oDocASigner.Name = 'CGV-' + oQuote.QuoteNumber;
            oDocASigner.Type_de_document__c = 'Document';
            oDocASigner.devis__c = oQuote.Id;
            lDocASigner.add(oDocASigner);
            
            if(lDocASigner.size()>0){
                insert lDocASigner;
            }
            
            // Zone_De_Remplissage__c
            List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
            
            // Signature
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 1;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'SIGNATURE';
            tag1.Name = 'Name_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 61;
            tag1.Position_Y__c = 61;
            tag1.Largeur__c = 166;
            tag1.Hauteur__c = 94;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = '';
            tag1.format_champ__c = '';
            tag1.Message_erreur__c = '';
            lTag.add(tag1);
            
            if(lTag.size()>0){
                insert lTag;
            }
            
        }else{
            // File not found in Libraries
            //res = false;
        }
        
        //res = true;
        //return res;
    }*/

    /** Get static PDF files from Libraries and make a copy in Documents and a reference to Document in Document_A_Signer__c **/ 
    public static void getStaticFilesFromLibraries() {
        List<Document_A_Signer__c> lDocASigner = new List<Document_A_Signer__c>();
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        //string sDocId;
        //List<String> lDocIds = new List<String>();
        Map<Id, String>mDocIds = new Map<Id, String>();
        string sPrefix;

        //boolean res = false;
        
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.Client_Type__c == 'Owner'){
            mDocIds.put(getDocumentsIdsValue('CGV_GEC_DOM_SE'), 'CGV_GEC_DOM_SE');
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            if(oQuote.Opportunity.Client_Type__c == 'CS'){
                mDocIds.put(getDocumentsIdsValue('CGV_GEB_PRO_CS'), 'CGV_GEB_PRO_CS');
                mDocIds.put(getDocumentsIdsValue('FichesDeDonneesSecurite'), 'FichesDeDonneesSecurite');
                if(hasGC()){
                    mDocIds.put(getDocumentsIdsValue('BouteillesCarburation'), 'BouteillesCarburation');
                }
            }else if(oQuote.Opportunity.Client_Type__c == 'RE'){
                mDocIds.put(getDocumentsIdsValue('CGV_GEB_PRO_RE'), 'CGV_GEB_PRO_RE');
                mDocIds.put(getDocumentsIdsValue('TechniqueEtSecurite'), 'TechniqueEtSecurite');
            }

            // For Docapost test, to delete afterwards
            //mDocIds.put(getDocumentsIdsValue('BAREME'), 'BAREME');
            //mDocIds.put(getDocumentsIdsValue('TEST'), 'TEST');
        }
        
        //MLC
        else if (oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'PRO' )
        {
        if ( oQuote.Opportunity.Project_market_subtype__c == 'Hôtel/Restauration' || oQuote.Opportunity.Project_market_subtype__c == 'Agriculture' || oQuote.Opportunity.Project_market_subtype__c == 'Industrie' || oQuote.Opportunity.Project_market_subtype__c  == 'Camping')
        
        {
         mDocIds.put(getDocumentsIdsValue('CGV_GEC_PRO_CHR'), 'CGV_GEC_PRO_CHR');
        }
        else
        {
        mDocIds.put(getDocumentsIdsValue('CGV_GEC_PRO'), 'CGV_GEC_PRO');
        }
       }   
        
        
        //string sCGVLabel = System.Label.CGV_Label_For_Signea == null ? '' : System.Label.CGV_Label_For_Signea;
        
        
        //List<ContentVersion> lContentVersion = [SELECT Id, Title, PublishStatus, VersionNumber, VersionData, IsLatest, PathOnClient, FileType, ContentUrl, TagCsv, ContentDocument.LatestPublishedVersionId
        //        FROM ContentVersion 
        //        WHERE ContentDocumentId in ( 
        //            SELECT ContentDocumentId FROM ContentWorkspaceDoc 
        //            /*WHERE ContentWorkspaceId = '058D000000093Bd' 
        //            AND ContentWorkspace.Name = 'Barèmes' */
        //            WHERE ContentDocumentId =:sDocId
        //        )
        //        AND IsLatest = True];
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] mDocIds = ' + mDocIds);

        List<ContentVersion> lContentVersion = [SELECT Id, VersionData, FileType, ContentDocumentId /*, Title, PublishStatus, VersionNumber, IsLatest, PathOnClient, ContentUrl, TagCsv, ContentDocument.LatestPublishedVersionId*/
                FROM ContentVersion 
                WHERE IsLatest = True
                AND ContentDocumentId =:mDocIds.keySet()];
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] lContentVersion.size() = ' + lContentVersion.size());
        
        // Copy Document from Libraries to Documents
        if (!lContentVersion.IsEmpty()){
            List<Document> lDocs = new List<Document>();
            
            for (ContentVersion oContentVersion : lContentVersion){
                Document oDoc = New Document();
                // oDoc.Name = sCGVLabel + '-' + oQuote.QuoteNumber;
                if(mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEC_DOM_SE' || mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEC_PRO' || mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEC_PRO_CHR'){
                    sPrefix = 'CGV-';
               /*  }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEC_PRO_SE'{ 
                    sPrefix = 'CGV-';*/
                }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEB_PRO_RE' || mDocIds.get(oContentVersion.ContentDocumentId)=='CGV_GEB_PRO_CS'){
                    sPrefix = 'CG-';
                }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='TechniqueEtSecurite'){
                    sPrefix = 'Technique et securite-';
                }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='FichesDeDonneesSecurite'){
                    sPrefix = 'Fiches de donnees securite-';
                }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='BouteillesCarburation'){
                    sPrefix = 'Bouteilles carburation-';
                /*}else if(mDocIds.get(oContentVersion.ContentDocumentId)=='BAREME'){   // Test, to delete from there
                    sPrefix = 'Bareme-';
                }else if(mDocIds.get(oContentVersion.ContentDocumentId)=='TEST'){
                    sPrefix = 'Test-';*/
                }
                oDoc.Name = sPrefix + oQuote.QuoteNumber;
                oDoc.Body = oContentVersion.VersionData;
                oDoc.Type = oContentVersion.FileType;
                oDoc.FolderId = sFolderId;
                oDoc.Description = oQuote.Id;
                lDocs.add(oDoc);
            }
            
            if(lDocs.size() > 0){
                Insert lDocs;
            }
            
            for(Document oDoc : lDocs){
                // Document_A_Signer__c
                Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
                oDocASigner.Id_SF_Document__c = oDoc.Id;
                //oDocASigner.Name = sCGVLabel + '-' + oQuote.QuoteNumber;
                //oDocASigner.Name = 'CGV-' + oQuote.QuoteNumber;
                oDocASigner.Name = oDoc.Name;
                oDocASigner.Type_de_document__c = 'Document';
                oDocASigner.devis__c = oQuote.Id;
                lDocASigner.add(oDocASigner);
            }    
            if(lDocASigner.size()>0){
                insert lDocASigner;
            }
            
            for(Document_A_Signer__c oDocASigner : lDocASigner){
                // Zone_De_Remplissage__c
                
                decimal posX;
                decimal posX1;
                decimal posX2;
                decimal posX3;
                decimal posY;
                decimal width;
                decimal height;
                integer page;
                
                // Signature
               // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
               if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
                    
                    page = -1;
                    if(oQuote.Market_type__c == 'DOM' ){
                        posX = 30.71875;
                        posY = 108.03125;
                        width = 229.594;
                        height = 119;
                    }else{
                        posX = 61;
                        posY = 150;
                        width = 166;
                        height = 94;
                    }
                       
                    Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
                    tag1.Identifiant_document__c = oDocASigner.Id;
                    tag1.Numero_Participant__c = 1;
                    tag1.Description__c = '';
                    tag1.Type_de_remplissage__c = 'SIGNATURE';
                    tag1.Name = 'PDF_SIG_1';
                    tag1.Page__c = -1;
                    tag1.Position_X__c = posX;
                    tag1.Position_Y__c = posY;
                    tag1.Largeur__c = width;
                    tag1.Hauteur__c = height;
                    tag1.Taille_de_la_police__c = FONT_SIZE;
                    tag1.Obligatoire__c = false;
                    tag1.Valeur_preremplie__c = '';
                    tag1.format_champ__c = '';
                    tag1.Message_erreur__c = '';
                    lTag.add(tag1);
                }else{
                    
                    System.debug(logginglevel.WARN,'### oDocASigner.Name = ' + oDocASigner.Name);
                    
                    page = -1;
                    if( oDocASigner.Name.startsWithIgnoreCase('Technique et securite-') ){
                        posX1 = 87.98208;
                        posX2 = 236.54051;
                        posX3 = 385.05106;
                        posY = 169.45163;
                        width = 124.10405;
                        height = 83.82757;
                    }else if( oDocASigner.Name.startsWithIgnoreCase('CG-') && oQuote.Opportunity.Client_Type__c == 'RE' ){
                        posX1 = 49.66914;
                        posX2 = 225.04663;
                        posX3 = 399.22684;
                        posY = 316.8008;
                        width = 144.79305;
                        height = 97.62023;
                    }else if( oDocASigner.Name.startsWithIgnoreCase('CG-') && oQuote.Opportunity.Client_Type__c == 'CS' ){
                        page = -2;
                        posX1 = 642.7954;
                        posX2 = 818.93915;
                        posX3 = 993.74194;
                        posY = 515.5236;
                        width = 145.78075;
                        height = 98.65583;
                    }else if( oDocASigner.Name.startsWithIgnoreCase('Fiches de donnees securite-') ){
                        posX1 = 48.729275;
                        posX2 = 224.58568;
                        posX3 = 400.05896;
                        posY = 159.2807;
                        width = 146.84048;
                        height = 98.97919;
                    }else if( oDocASigner.Name.startsWithIgnoreCase('Bouteilles carburation-') ){
                        posX1 = 642.5799;
                        posX2 = 818.0412;
                        posX3 = 994.2807;
                        posY = 363.0979;
                        width = 146.0681;
                        height = 99.36232;
                    }else{
                        posX1 = 61;
                        posX2 = 61;
                        posX3 = 61;
                        posY = 150;
                        width = 166;
                        height = 94;
                    }
                    
                    // Signature
                    Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
                    tag1.Identifiant_document__c = oDocASigner.Id;
                    tag1.Numero_Participant__c = 1;
                    tag1.Description__c = '';
                    tag1.Type_de_remplissage__c = 'SIGNATURE';
                    tag1.Name = 'PDF_SIG_1';
                    tag1.Page__c = page;
                    tag1.Position_X__c = posX1;
                    tag1.Position_Y__c = posY;
                    tag1.Largeur__c = width;
                    tag1.Hauteur__c = height;
                    tag1.Taille_de_la_police__c = FONT_SIZE;
                    tag1.Obligatoire__c = false;
                    tag1.Valeur_preremplie__c = '';
                    tag1.format_champ__c = '';
                    tag1.Message_erreur__c = '';
                    lTag.add(tag1);
                    
                    // Signature
                    Zone_De_Remplissage__c tag2 = new Zone_De_Remplissage__c();
                    tag2.Identifiant_document__c = oDocASigner.Id;
                    tag2.Numero_Participant__c = -2;
                    tag2.Description__c = '';
                    tag2.Type_de_remplissage__c = 'SIGNATURE';
                    tag2.Name = 'PDF_SIG_2';
                    tag2.Page__c = page;
                    tag2.Position_X__c = posX2;
                    tag2.Position_Y__c = posY;
                    tag2.Largeur__c = width;
                    tag2.Hauteur__c = height;
                    tag2.Taille_de_la_police__c = FONT_SIZE;
                    tag2.Obligatoire__c = false;
                    tag2.Valeur_preremplie__c = '';
                    tag2.format_champ__c = '';
                    tag2.Message_erreur__c = '';
                    lTag.add(tag2);
                    
                    // Signature
                    Zone_De_Remplissage__c tag3 = new Zone_De_Remplissage__c();
                    tag3.Identifiant_document__c = oDocASigner.Id;
                    tag3.Numero_Participant__c = -1;
                    tag3.Description__c = '';
                    tag3.Type_de_remplissage__c = 'SIGNATURE';
                    tag3.Name = 'PDF_SIG_3';
                    tag3.Page__c = page;
                    tag3.Position_X__c = posX3;
                    tag3.Position_Y__c = posY;
                    tag3.Largeur__c = width;
                    tag3.Hauteur__c = height;
                    tag3.Taille_de_la_police__c = FONT_SIZE;
                    tag3.Obligatoire__c = false;
                    tag3.Valeur_preremplie__c = '';
                    tag3.format_champ__c = '';
                    tag3.Message_erreur__c = '';
                    lTag.add(tag3);
                }
            }
            
            if(lTag.size()>0){
                insert lTag;
            }
            
        }else{
            // File not found in Libraries
            //res = false;
        }
        
        //res = true;
        //return res;
    }
    
    /** Get PTL_Consumption_Profile__c attachments and make a copy in Documents and a reference to Document in Document_A_Signer__c **/ 
    public static void getConsumptionProfileFiles() {
        List<Document_A_Signer__c> lDocASigner = new List<Document_A_Signer__c>();
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        
        
        List<Attachment> lAtt = [select Id, ParentId, Body, ContentType, Parent.Name from Attachment where ParentId =: lPCPsWithProfilConsoFile];
        
        // Copy Document from Attachments to Documents
        if (!lAtt.IsEmpty()){
            List<Document> lDocs = new List<Document>();
            
            for(Attachment oAtt : lAtt){
                Document oDoc = New Document();
                oDoc.Name = 'Contrat' + '-' + oAtt.Parent.Name;
                oDoc.Body = oAtt.Body;
                oDoc.Type = oAtt.ContentType;
                oDoc.FolderId = sFolderId;
                oDoc.Description = oQuote.Id;
                lDocs.add(oDoc);
            }
            if(lDocs.size() > 0){
                Insert lDocs;
            }
            
            for(Document oDoc : lDocs){
                // Document_A_Signer__c
                Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
                oDocASigner.Id_SF_Document__c = oDoc.Id;
                oDocASigner.Name = oDoc.Name;
                oDocASigner.Type_de_document__c = 'Document';
                oDocASigner.devis__c = oQuote.Id;
                lDocASigner.add(oDocASigner);
            }    
            if(lDocASigner.size()>0){
                insert lDocASigner;
            }
            
            for(Document_A_Signer__c oDocASigner : lDocASigner){
                // Zone_De_Remplissage__c

                // Signature
                Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
                tag1.Identifiant_document__c = oDocASigner.Id;
                tag1.Numero_Participant__c = 1;
                tag1.Description__c = '';
                tag1.Type_de_remplissage__c = 'SIGNATURE';
                tag1.Name = 'CONSPROFILE_SIG';
                tag1.Page__c = -1;
                tag1.Position_X__c = 449;
                tag1.Position_Y__c = 96;
                tag1.Largeur__c = 102;
                tag1.Hauteur__c = 42;
                tag1.Taille_de_la_police__c = FONT_SIZE;
                tag1.Obligatoire__c = false;
                tag1.Valeur_preremplie__c = '';
                tag1.format_champ__c = '';
                tag1.Message_erreur__c = '';
                lTag.add(tag1);

            }
            
            if(lTag.size()>0){
                insert lTag;
            }
            
        }else{
            // File not found
            //res = false;
        }
        
        //res = true;
        //return res;
    }
    
    
    /** Checking issues for first step **/
    public static String getIssuesBeforePreparingData(){
        string pbCode = '';
        boolean missingTel = false;
        boolean missingEmail = false;
        
        
        // Check Quote is on GEC DOM
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
       if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c){
            
        // or GEB PRO
        }else if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){

        // (no other combination available yet)
        }else{
            pbCode += '- La signature électronique n\'est pour l\'instant disponible que pour le GEC DOM - PRO (Hors Gros Vrac) et le GEB PRO.' + '<br>';
        }
        
        // Check quote is synchronized and approved
        if(!oQuote.IsSyncing){
            pbCode += '- Devis non synchronisé.' + '<br>';
        }
        if(!oQuote.T_LAT_Approved__c){
            pbCode += '- Devis non approuvé.' + '<br>';
        }
        
        // Check quote has not already been signed
        if(oQuote.Signea_Date_Signature__c != null) {
            pbCode += '- Devis déjà signé.' + '<br>';
        }

        if(oQuote.Account.AccountNumber == null || oQuote.Account.AccountNumber == ''){
            pbCode += '- Pas de référence client au niveau du compte.' + '<br>';
        }
        if(oQuote.Account.Mandataire__c == null || oQuote.Account.Mandataire__r.ExternalID__c == null || oQuote.Account.Mandataire__r.ExternalID__c == ''){
            pbCode += '- Pas de mandataire au niveau du compte.' + '<br>';
        }
        if(oQuote.Account.Activity_Domain_Simple__c == null || oQuote.Account.Activity_Domain_Simple__c == ''){
            pbCode += '- Pas de secteur d\'activité au niveau du compte.' + '<br>';
        }
        
        // Check a value has been selected in Livraison_pendant_delai_retractation__c picklist
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.T_Pack__c == 'ECOCFT'){  // To remove if we apply this test to all opties
       // if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM'){
         if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c &&  ( oQuote.Opportunity.Project_market_subtype__c != 'Hôtel/Restauration' || oQuote.Opportunity.Project_market_subtype__c != 'Agriculture' || oQuote.Opportunity.Project_market_subtype__c != 'Industrie' || oQuote.Opportunity.Project_market_subtype__c != 'Camping' )){
     
            if(String.isEmpty(oQuote.Opportunity.Livraison_pendant_delai_retractation__c)){
                pbCode += '- Aucune valeur sélectionnée dans la liste "Livraison pendant délai de rétractation" sur l\'opportunité.' + '<br>';
            }
        }
        
        // Check a value has been selected in Opportunity.Changement_de_banque__c picklist
        if( oQuote.Opportunity.Changement_de_banque__c == null && ( oQuote.DO_Payment_method__c == 'P' || oQuote.DO_Payment_method__c == '2' || oQuote.DO_Payment_method__c == '3' ) ){
            if( oQuote.Project_Type__c == 'CREA' || (oQuote.Project_Type__c == 'SUCC' && oQuote.Account.Activity_Domain_Simple__c == 'gec') || (oQuote.Project_Type__c == 'FIDE' && (oQuote.Account.Payment_method__c != 'P' && oQuote.Account.Payment_method__c != '2' && oQuote.Account.Payment_method__c != '3' ) ) ){
                // No issue, we'll ask for the SEPA and RIB anyway
            }else{
                pbCode += '- Aucune valeur sélectionnée dans la liste "Changement de banque" sur l\'opportunité.' + '<br>';
            }
        }
        
        // Check mobile phone isn't blank (/!\ PA/BA)
        if(oQuote.Account.IsPersonAccount){
            if(oQuote.Account.Mobile_Phone_Number__c == null || oQuote.Account.Mobile_Phone_Number__c == ''){
                missingTel = true;
            }
        }else{
            if(oQuote.Contact.MobilePhone == null || oQuote.Contact.MobilePhone == ''){
                missingTel = true;
            }
        }
        if(missingTel) pbCode += '- Téléphone mobile du client non-renseigné.' + '<br>';

        // Check email isn't blank
        if(oQuote.Account.IsPersonAccount){
            // /!\ if we want to manage 2 email addresses, the insert in Signea table must be modified
            //if((oQuote.Account.Email__c == null || oQuote.Account.Email__c == '') && (oQuote.Account.Email_2__c == null || oQuote.Account.Email_2__c == '')){
            if(oQuote.Account.Email__c == null || oQuote.Account.Email__c == ''){
                missingEmail = true;
            }
        }else{
            //if((oQuote.Contact.Email == null || oQuote.Contact.Email == '') && (oQuote.Contact.Email_2__c == null || oQuote.Contact.Email_2__c == '')){
            if(oQuote.Contact.Email == null || oQuote.Contact.Email == ''){
                missingEmail = true;
            }
        }
        if(missingEmail) pbCode += '- Adresse e-mail du client non-renseignée.' + '<br>';
        
        // Check all OPTLs related to the Quote have an attachment (Plan d'implantation), except if 'Construction neuve'
        //if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.Channel__c != 'Extranet comparateur'){
        if(oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c && oQuote.Opportunity.Channel__c != 'Extranet comparateur'){
        
            if(lOPTLsWithoutPlanImplantation.size() > 0 && oQuote.Opportunity.Opportunity_Reason__c != 'Construction neuve'){
                pbCode += '- Les OPTLs suivants n\'ont pas de plan d\'implantation :<br>';
            
                for (Opportunity_PTL__c oOTPLsWithoutPlanImplantation : lOPTLsWithoutPlanImplantation){
                    pbCode += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;<a style="color: red" target="_blank" href="/' + oOTPLsWithoutPlanImplantation.id + '">' + oOTPLsWithoutPlanImplantation.Name + '</a><br>';
                }
            }
        }

        // Check PEC is ok with option chosen and only one is in the correct status
        if(oQuote.Account.Activity_Domain_Simple__c == 'geb' && oQuote.Market_type__c == 'PRO'){
            if(withPEC && oPECToSign == null){
                pbCode += '- Pas de Prise en Charge en attente de signature pour ce compte.' + '<br>';
            }
            if(withPEC && lPECToSign.size() > 1){
                pbCode += '- Plusieurs Prises en Charge en attente de signature pour ce compte.' + '<br>';
            }
        }
        
        // Check all Consumption Profiles related to the Quote have an attachment (BobEstim)
       // if( oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Market_type__c == 'DOM' && oQuote.Opportunity.T_Pack__c == 'ECOCFT' && oQuote.Opportunity.Channel__c != 'Extranet comparateur' ){
         if( oQuote.Account.Activity_Domain_Simple__c == 'gec' && oQuote.Opportunity.RecordType.Id != GEC_GrosVrac.value__c && oQuote.Opportunity.T_Pack__c == 'ECOCFT' && oQuote.Opportunity.Channel__c != 'Extranet comparateur' ){ 
            if( !oQuote.Derogation_calcul_consommation__c || (oQuote.Project_Type__c == 'CREA' && (oQuote.Opportunity.Opportunity_Reason__c == 'Piquage client' || oQuote.Opportunity.Opportunity_Reason__c == 'Renovation')) ){
                if(lPCPsWithoutProfilConsoFile.size() > 0){
                    pbCode += '- Les profils de consommation suivants n\'ont pas de pièce jointe :<br>';
                    
                    for (PTL_Consumption_Profile__c oPCPsWithoutProfilConsoFile : lPCPsWithoutProfilConsoFile){
                        pbCode += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;<a style="color: red" target="_blank" href="/' + oPCPsWithoutProfilConsoFile.id + '">' + oPCPsWithoutProfilConsoFile.Name + '</a><br>';
                    }
                }
            }
        }

        
        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez corriger ces anomalies afin de pouvoir lancer le circuit de signature.';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    /** Checking issues for second step **/
    public static String getIssuesAfterPreparingData(){
        
        string pbCode = '';
        
        
        if( oQuote.Signea_Circuit__c != null ) {
            List<Signea__Circuit__c> myCircuits = [select id, name, signea__status__c from Signea__Circuit__c where id = :oQuote.Signea_Circuit__c ];   
            if( myCircuits != null && myCircuits.size() > 0 ) {
                if( myCircuits[0].signea__status__c != 'Refused' && myCircuits[0].signea__status__c != 'Expired' && myCircuits[0].signea__status__c != 'Cancelled' && myCircuits[0].signea__status__c != 'Launch Failed' ) {
                    pbCode += '- Un circuit est déjà en cours de signature.' + '<br>';
                }
            }
        }
        
        // Controle des documents à signer
        documents = [select id, Id_SF_Document__c, Name, Type_de_document__c from Document_A_Signer__c where devis__c = :oQuote.Id ];
        if( documents == null || documents.size() == 0 ) {
            pbCode += '- Aucun document dans le devis.' + '<br>';
        }
        
        // Controle des signataires
        signataires = [select id, position__c, Delai_avant_relance__c, Type_de_signataire__c, Id_SF_Signataire__c, Duree_avant_expiration__c, Email__c, Telephone__c, Civilite__c, Name, Prenom__c, Numero_du_participant__c, Etape_de_signature__c, Type_de_destinataire__c, Type_de_signature__c, Notification_additionnelle_personnalisee__c from Signataire_Document__c where devis__c = :oQuote.Id order by Etape_de_signature__c asc ];
        system.Debug('\n\n===> signataires : ' +  signataires  + '\n\n');
        if( signataires == null || signataires.size() == 0 ) {
            pbCode += '- Aucun signataire dans le devis.' + '<br>';
        }
        
        // Controle des paramètres de signature
        parametres = [select id, Module__c, Nom_du_circuit__c, Index_AES__c, Condition_d_acceptation__c, Notification_Createur__c, Notification_additionnelle_generale__c from Parametre_Signature__c where devis__c = :oQuote.Id ];
        if( parametres == null || parametres.size() == 0 ) {
            pbCode += '- Aucun paramètre de signature dans le devis.' + '<br>';
        }
        
        //if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez contacter l\'administrateur de l\'application.';
        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    // Get all OPTLs related to the Quote
    private static List<Opportunity_PTL__c> getlOPTLs() {

        List<Opportunity_PTL__c> lOPTL = [select Id, Name from Opportunity_PTL__c where Opportunity__r.SyncedQuoteId=:oQuote.Id];
        
        return lOPTL;
    }
    
    
    // Manage OPTLs with or without PlanImplantation
    private static void manageOPTLsWithOrWithoutPlanImplantation() {
        
        //List<Opportunity_PTL__c> lOPTLsWithoutPlanImplantation = new List<Opportunity_PTL__c>();
        Set<Id> optlWithMEPSet = new Set<Id>();
        Set<Id> attSet = new Set<Id>();
        
        
        // Query all QLIs with a MEP linked to the quote 
        List<QuoteLineItem> qliWithMEPList = new List<QuoteLineItem>([
            select Id, Quote_PTL__r.Opportunity_PTL__c
            from QuoteLineItem
            where Sub_type__c = 'Citerne'
            and Tank_Placing_Options__c  in ('MEP', 'DDS')
            and QuoteId =:oQuote.Id
        ]);
            
        if(qliWithMEPList != null && qliWithMEPList.size() > 0){
            
            // Feed a set containing the OPTLs with a MEP
            for(QuoteLineItem oqliWithMEPList : qliWithMEPList){
              System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageOPTLsWithOrWithoutPlanImplantation] oqliWithMEPList.Quote_PTL__r.Opportunity_PTL__c = ' + oqliWithMEPList.Quote_PTL__r.Opportunity_PTL__c);
              if(!optlWithMEPSet.contains(oqliWithMEPList.Quote_PTL__r.Opportunity_PTL__c)){
                  optlWithMEPSet.add(oqliWithMEPList.Quote_PTL__r.Opportunity_PTL__c);
              }
            }
        
            // Query all attachments linked to the OPTLs with a MEP linked to the current Opty/SyncedQuote
            List<Attachment> attList = new List<Attachment>([
                select ParentId  from Attachment  where ParentId =:optlWithMEPSet
            ]);
          
            // Feed a set containing the OPTLs with a MEP with an attachment
            for(Attachment oAttList : attList){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageOPTLsWithOrWithoutPlanImplantation] oAttList.ParentId = ' + oAttList.ParentId);
                if(!attSet.contains(oAttList.ParentId)){
                    attSet.add(oAttList.ParentId);
                }
            }
        
            // Feed lists containing the OPTLs with a MEP with or without an attachment
            for(Opportunity_PTL__c oOptl : lOPTLs){
                // if MEP and has attachment : OK
                if(optlWithMEPSet.contains(oOptl.Id) && attset.contains(oOptl.Id)){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageOPTLsWithOrWithoutPlanImplantation] lOPTLsWithPlanImplantation.add = ' + oOptl.Id);
                    lOPTLsWithPlanImplantation.add(oOptl);
                // if MEP and has no attachment : NOK
                }else if(optlWithMEPSet.contains(oOptl.Id) && !attset.contains(oOptl.Id)){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageOPTLsWithOrWithoutPlanImplantation] lOPTLsWithoutPlanImplantation.add = ' + oOptl.Id);
                    lOPTLsWithoutPlanImplantation.add(oOptl);
                }
            }
        
        }else{
            // No QLI with a MEP
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageOPTLsWithOrWithoutPlanImplantation] else');
        }
        
    }
    
    // Manage QPTLs with or without ProfilConsoFile
    private static void manageQPTLsWithOrWithoutProfilConsoFile() {
        
        // Query all Consumption Profiles (with or without attachment) linked to the quote 
        List<PTL_Consumption_Profile__c> pcpList = new List<PTL_Consumption_Profile__c>([
            select Id, Name, Quote_PTL_del__c, Quote_PTL_del__r.Quote__c, (select Id FROM Attachments)
            from PTL_Consumption_Profile__c
            where Quote_PTL_del__r.Quote__c =:oQuote.Id
        ]);
        
        if(pcpList != null && pcpList.size() > 0){
            
            // Feed lists containing the ConsumptionProfiles with or without an attachment
            for(PTL_Consumption_Profile__c oPCP : pcpList){
                // if has attachment : OK
                if(oPCP.Attachments.size()>0){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageQPTLsWithOrWithoutProfilConsoFile] lPCPsWithProfilConsoFile.add = ' + oPCP.Id);
                    lPCPsWithProfilConsoFile.add(oPCP);
                    
                    // Feed a set of ProfilConso files to be sent to Contralia
                    for (Attachment att : oPCP.Attachments) {
                        lPCPAttachments.add(att);
                    }
                // if has no attachment : NOK
                }else if(oPCP.Attachments.size()==0){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageQPTLsWithOrWithoutProfilConsoFile] lPCPsWithoutProfilConsoFile.add = ' + oPCP.Id);
                    lPCPsWithoutProfilConsoFile.add(oPCP);
                }
            }
            
        }else{
            // No QLI with a MEP
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSignea.manageQPTLsWithOrWithoutProfilConsoFile] else');
        }
        
    }
    
    // Check if there are GC (Propane Carburation) products on the quote
    private static boolean hasGC(){
        boolean returnValue = false;

        List<QuoteLineItem> lQLI = [select Id, Product2.ProductCode
                                            from QuoteLineItem
                                            where Product2.ProductCode = '000000000000000440'
                                            and QuoteId =:oQuote.Id];
        
        if(!lQLI.isEmpty()){ returnValue = true; }
        return returnValue;
    }

    // Check if there are Service products on the quote
    // 20210118 : Update : Add V2F even if no service type products : We don't need this method anymore
    /*private static boolean hasServiceProduct(){
        boolean returnValue = false;

        List<QuoteLineItem> lQLI = [select Id, Product2.ProductCode
                                            from QuoteLineItem
                                            where Product2.Family = 'Service'
                                            and QuoteId =:oQuote.Id];
        
        if(!lQLI.isEmpty()){ returnValue = true; }
        return returnValue;
    }*/
    
    /** Delete records linked to current quote from Signea objects and Documents **/
    public static void deleteRecords(){
        
        /*List<Signea__Circuit__c> lSigneaCircuit = [select Id from Signea__Circuit__c where Id =:oQuote.Signea_Circuit__c];
        delete lSigneaCircuit;*/
        Signea.Signea_Entities_V2.SigneaServicesResult result = Signea.Signea_API_V2.deleteCircuit(oQuote.Signea_Circuit__c);
        
        List<Parametre_Signature__c> lParametreSignature = [select Id from Parametre_Signature__c where Devis__c =:oQuote.Id];
        delete lParametreSignature;
        
        List<Signataire_Document__c> lSignataireDocument = [select Id from Signataire_Document__c where Devis__c =:oQuote.Id];
        delete lSignataireDocument;
        
        List<Piece_Justificative__c> lPieceJustificative = [select Id from Piece_Justificative__c where Devis__c =:oQuote.Id];
        delete lPieceJustificative;
        
        // Delete Docs et DocsSignea
        List<Document_A_Signer__c> lDocumentASigner = [select Id, Id_SF_Document__c from Document_A_Signer__c where Devis__c =:oQuote.Id];
        
        List<String> lDocsId = new List<String>();
        for (Document_A_Signer__c oDocumentASigner : lDocumentASigner){
            lDocsId.add(oDocumentASigner.Id_SF_Document__c);
        }
        List<Document> lDocument = [select Id from Document where Id =:lDocsId];
        
        // Handled by the master/detail relationship between Document_A_Signer__c and Zone_De_Remplissage__c
        //List<Zone_De_Remplissage__c> lZoneDeRemplissage = [select Id from Zone_De_Remplissage__c where Identifiant_document__c =:lDocsId];
        //delete lZoneDeRemplissage;
        
        delete lDocument;
        delete lDocumentASigner;

        
        system.Debug(logginglevel.WARN,'deleteCircuit result : ' + result);
        if( result.errorCode == '000' ) {
            // Delete was successfull
        } else {
            system.Debug(logginglevel.WARN,'deleteCircuit result error : ' + result.errorCode + '-' + result.errorMessage);
            //return result.errorCode + '-' + result.errorMessage;
        }
        
    }
    
    /** Reset fields of the current quote and opportunity **/
    public static void resetFields(){
        
        // Update Quote fields
        oQuote.Statut_circuit_de_signature__c = '';
        oQuote.Signea_Date_Signature__c = null;
        oQuote.Signea_Raison_Refus_Signature__c = '';
        oQuote.Signea_Circuit__c = null;
        update oQuote;
        
        // Update Opportunity fields
        List<Opportunity> opty = [select id, StageName, Reason_for_Closed_Lost__c, Signea_Raison_Refus_Signature__c, Statut_circuit_de_signature__c from Opportunity where id = :oQuote.OpportunityId ];   
        if( opty.size() > 0 ) {
            opty[0].StageName = 'Negotiation/Review';
            opty[0].Reason_for_Closed_Lost__c = null;
            opty[0].Signea_Raison_Refus_Signature__c = '';
            opty[0].Statut_circuit_de_signature__c = '';
            
            update opty;
        }
        
    }
    
    
    /** Getting Custom Settings methods **/
    public static String getDocumentsIdsValue(String name){
        try{
            String res = DocumentsIds__c.getInstance(name).DocumentId__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
              // BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
                //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'No value specified for Custom Setting DocumentsIds__c : (' + name +').'});
                return '';
            }            
        }catch(System.NullPointerException e){
          // BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
            //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the DocumentsIds__c named (' + name +'). [ '+ e.getMessage() + ' ]'});
            return '';
        }
    }
    
}