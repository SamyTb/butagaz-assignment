/*public*/ global class VFC_ProcessDataForSigneaFromCampaign {

    private static CampaignMember oCampMember;
    public static String isSE{get; set;} // Is the contract being electronically signed ?
    public static String paymentSpreadChosen{get; set;} // Is the contract being electronically signed ?
    
    private static final integer FONT_SIZE = 10;  // Sets the font size of fields sent to Signea
    private static final string sFolderId = AP_PricingUtilities.getCustomSettingValue('FolderIdToStoreDocumentsForSignea');  // Used to store the id of the folder in which documents will be copied for Signea 
    private static final string sMaxNumberEvidenceFilesForSignea = AP_PricingUtilities.getCustomSettingValue('MaxNumberEvidenceFilesForSignea');  // Used to store the max number of files per evidence the cutomer is allowed to upload on Contralia
    
    //private Map<Integer, String> mSortDocs {get;set;}  // Map used to sort Scale Docs to render on VFP
    
    private static list<Document_A_Signer__c> documents {get;set;}
    private static list<Signataire_Document__c> signataires {get;set;}
    private static list<Parametre_Signature__c> parametres {get;set;}
    
    private static boolean hasDocumentsToBeFilled {get; set;}  // This variable (default false) will be set to true if the circuit requires documents to be filled (tag with Type_de_remplissage__c != 'SIGNATURE'). When sending metadata to Contralia, we will check this variable value and manage the requirements to force reading on the fill step or on the sign step

    //public ApexPages.StandardController myAccountController {get; set;}
    //public Account Account {get; set;}

    
    ApexPages.StandardController stdController;

    public VFC_ProcessDataForSigneaFromCampaign(ApexPages.StandardController controller) {
        this.stdController = controller;
        oCampMember = (CampaignMember)stdController.getRecord();

        /*isSE = ApexPages.CurrentPage().getParameters().get('isSE');
        if(isSE == null){isSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button*/

        /*if(oCampMember.Contact!=null){
            Account = [select Id, Name, Postal_Code__c from Account where id = :oCampMember.Contact.AccountId][0];
            myAccountController = new ApexPages.StandardController(Account);
        }*/
    }


    WebService static string ProcessDataForSigneaFromCampaign(string campMemberId, string pPaymentSpreadChosen) {
        
        string outcomeMessage;
        
        isSE = 'true';  // electronic signature
        hasDocumentsToBeFilled = false;
        paymentSpreadChosen = pPaymentSpreadChosen; // To display in contract VFP
        
        
        // Check if user has the required permissions to run the Signea process
        if(!Test.isRunningTest()){
            if(VFC_User.isUserAuthorizedToRunSignea(UserInfo.getUserId()) == false){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] : 001-Utilisateur non autorisé à lancer la signature électronique.');
                return '<span style="color: red">- Utilisateur non autorisé à lancer la signature électronique.</span>';
            }
        }
        
        // Get CampaignMember
        List<CampaignMember> lCampaignMembers = [select Id, Signea_Circuit__c, Signea_Date_Signature__c,
                                    /* Fields for Parametre_Signature__c */
                                    Contact.Account.AccountNumber, Contact.Account.FirstName, Contact.Account.LastName, Contact.Account.Activity_Domain_Simple__c, 
                                    /*Opportunity.Payer_AccountNumber__c, Opportunity.Billed_AccountNumber__c,*/ Contact.Account.Mandataire__r.ExternalID__c, Contact.Account.Mandataire__r.Headquarters_Phone__c,
                                    Contact.AccountId, 
                                    /* Fields for Signataire_Document__c */
                                    Contact.Id,
                                    Contact.Account.Salutation__c, 
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__c, Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Id,
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Salutation, Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.FirstName,
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.LastName, Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Email__c,
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Country__c,
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Indicatif_Pays__c,
                                    Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Mobile_Phone_Number__c,
                                    /* Fields for Piece_Justificative__c */
                                    /*DO_Payment_method__c, Opportunity.Client_Type__c,*/
                                    /* Fields for Document_A_Signer__c */
                                    /*Project_Type__c, Client_Reenlistment__c,*/
                                    /* Fields for Zone_De_Remplissage__c */
                                    Contact.Salutation, Contact.FirstName, Contact.LastName,
                                    Contact.Account.Street_Number__c, Contact.Account.Number_extention__c, Contact.Account.Street_type__c,
                                    Contact.Account.Street_name__c, Contact.Account.Lieu_dit__c,
                                    Contact.Account.City_Postal_Code__c, Contact.Account.City__c, Contact.Account.Postal_Code__c, Contact.Account.City_Postal_Code__r.Name, Contact.Account.Street_N__c,
                                    /* Other */
                                    Contact.Account.IsPersonAccount, 
                                    Contact.Account.Country__c, Contact.Account.Indicatif_Pays__c, Contact.Account.Mobile_Phone_Number__c, Contact.Country__c, Contact.Indicatif_Pays_c__c, Contact.MobilePhone,
                                    Contact.Account.Email__c, Contact.Email,
                                    
                                    Contact.Account.Activity_Domain__r.Id
                                from CampaignMember where Id =:campMemberId limit 1];
        if(!lCampaignMembers.isEmpty()){
            oCampMember = lCampaignMembers[0];
        }else{
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] : 001-Membre de campagne non trouvé.');
            return '001-Membre de campagne non trouvé.';
        }
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] oCampaignMember.Id = ' + oCampMember.Id);
        
        
        // Don't go further if an issue is found
        string pbMessageBefore = getIssuesBeforePreparingData();
        if(pbMessageBefore != ''){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] message = ' + pbMessageBefore);
            return pbMessageBefore;
        }
        
        // Check if documents are all there in libraries ???
        
        
        
        // Prepare data and optionally call WS depending on pMode parameter
        if(prepareDataForSignea()){
            //if(pMode == 1){
                // Ok to call WS
                
            string pbMessageAfter = getIssuesAfterPreparingData();
            if(pbMessageAfter != ''){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] message = ' + pbMessageAfter);
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
        System.Debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] Début Création des parametres du circuit');
        Parametre_Signature__c myCircuitParam = new Parametre_Signature__c();
        myCircuitParam.Account__c = oCampMember.Contact.Account.Id;
        myCircuitParam.CampaignMemberId__c = oCampMember.Id;
        //myCircuitParam.Index_AES__c = 'MatriculeDO=' + oQuote.Account.AccountNumber + ', Activite=' + oQuote.Account.Activity_Domain_Simple__c.toUpperCase() + ', MatriculePA=' + (String.isBlank(oQuote.Opportunity.Payer_AccountNumber__c)? oQuote.Account.AccountNumber : oQuote.Opportunity.Payer_AccountNumber__c) + ', MatriculeFA=' + (String.isBlank(oQuote.Opportunity.Billed_AccountNumber__c)? oQuote.Account.AccountNumber : oQuote.Opportunity.Billed_AccountNumber__c) + ',OrganisationCom=' + oQuote.Account.Mandataire__r.ExternalID__c;
        myCircuitParam.Index_AES__c = 'matricule_do=' + oCampMember.Contact.Account.AccountNumber + ', matricule_pa=' + oCampMember.Contact.Account.AccountNumber + ', matricule_fa=' + oCampMember.Contact.Account.AccountNumber + ', orga_comm=' + oCampMember.Contact.Account.Mandataire__r.ExternalID__c + ', activite=' + oCampMember.Contact.Account.Activity_Domain_Simple__c.toUpperCase();
        myCircuitParam.Condition_d_acceptation__c = 'J\'ai lu le document et j\'accepte sans réserve les conditions.';
        myCircuitParam.Notification_Createur__c = true;
        //myCircuitParam.Module__c = 'default';
        myCircuitParam.Module__c = 'Etal0317';
        //myCircuitParam.Notification_additionnelle_generale__c = '';
        myCircuitParam.Notification_additionnelle_generale__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oCampMember.Contact.Account.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h';
        Datetime curDT = Datetime.now();
        //myCircuitParam.Nom_du_circuit__c = 'Contrat_' + oQuote.QuoteNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        myCircuitParam.Nom_du_circuit__c = ( (oCampMember.Contact.Account.FirstName == null || oCampMember.Contact.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oCampMember.Contact.Account.LastName == null || oCampMember.Contact.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' - ' + oCampMember.Contact.Account.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        insert myCircuitParam;
        
        
        // ============================================
        // Création du conteneur d’étapes et des étapes
        // ============================================
        List<Signataire_Document__c> lSigDoc = new List<Signataire_Document__c>();
        
        //Etape 1 : 1 Signataire client
        Signataire_Document__c mySigner1 = new Signataire_Document__c();
        mySigner1.Numero_du_participant__c = 1;
        mySigner1.Type_de_destinataire__c = 'Distance';
        mySigner1.Type_de_signature__c = 'OTP';
        mySigner1.Type_de_signataire__c = 'C';
        //mySigner1.Type_de_signataire__c = '';
        mySigner1.Id_SF_Signataire__c = oCampMember.Contact.Id;
        //mySigner1.Id_SF_Signataire__c = null;
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        mySigner1.Civilite__c = oCampMember.Contact.Account.Salutation__c;
        mySigner1.Prenom__c = ( (oCampMember.Contact.Account.FirstName == null || oCampMember.Contact.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner1.Name = ( (oCampMember.Contact.Account.LastName == null || oCampMember.Contact.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner1.Email__c = oCampMember.Contact.Account.Email__c;
        mySigner1.Telephone__c = oCampMember.Contact.Account.Country__c == 'FR' ? oCampMember.Contact.Account.Mobile_Phone_Number__c : oCampMember.Contact.Account.Indicatif_Pays__c + oCampMember.Contact.Account.Mobile_Phone_Number__c;
        // ***
        mySigner1.Etape_de_signature__c = '1-Signature Client';
        mySigner1.Account__c = oCampMember.Contact.Account.Id;
        mySigner1.CampaignMemberId__c = oCampMember.Id;
        mySigner1.Notification_additionnelle_personnalisee__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oCampMember.Contact.Account.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h';
        mySigner1.Duree_avant_expiration__c = 20;
        mySigner1.Delai_avant_relance__c = 7;
        mySigner1.Position__c = 1;
        
        lSigDoc.add(mySigner1);
        
        //Etape 2 : 2 Visa conseiller
        /*Signataire_Document__c mySigner2 = new Signataire_Document__c();
        mySigner2.Numero_du_participant__c = 2;
        mySigner2.Type_de_destinataire__c = 'Visa';
        mySigner2.Type_de_signature__c = '';
        mySigner2.Type_de_signataire__c = 'U';
        mySigner2.Id_SF_Signataire__c = UserInfo.getUserId();*/
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        //mySigner2.Civilite__c = 'Mr';
        //mySigner2.Prenom__c = UserInfo.getFirstName();
        //mySigner2.Name = UserInfo.getLastName();
        //mySigner2.Email__c = '';
        //mySigner2.Telephone__c ='';
        // ***
        /*mySigner2.Etape_de_signature__c = '2-Visa Conseiller';
        mySigner2.Account__c = oCampMember.Contact.Account.Id;
        mySigner2.CampaignMemberId__c = oCampMember.Id;
        mySigner2.Notification_additionnelle_personnalisee__c = '';
        mySigner2.Duree_avant_expiration__c = 20;
        mySigner2.Delai_avant_relance__c = 7;
        mySigner1.Position__c = 2;*/
        
        //Etape 2 : 2 Visa conseiller
        // For this process we are using person accounts that we link on the mandataires through a lookup on the Mandataire__c object to manage one visor per mandataire
        Signataire_Document__c mySigner2 = new Signataire_Document__c();
        mySigner2.Numero_du_participant__c = 2;
        mySigner2.Type_de_destinataire__c = 'Visa';
        mySigner2.Type_de_signature__c = '';
        mySigner2.Type_de_signataire__c = 'C';
        mySigner2.Id_SF_Signataire__c = oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Id;
        //mySigner1.Id_SF_Signataire__c = null;
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        mySigner2.Civilite__c = oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Salutation;
        mySigner2.Prenom__c = ( (oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.FirstName == null || oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner2.Name = ( (oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.LastName == null || oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner2.Email__c = oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Email__c;
        mySigner2.Telephone__c = oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Country__c == 'FR' ? oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Mobile_Phone_Number__c : oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Indicatif_Pays__c + oCampMember.Contact.Account.Mandataire__r.Contact_Signature_Electronique__r.Account.Mobile_Phone_Number__c;
        // ***
        mySigner2.Etape_de_signature__c = '2-Visa Conseiller';
        mySigner2.Account__c = oCampMember.Contact.Account.Id;
        mySigner2.CampaignMemberId__c = oCampMember.Id;
        mySigner2.Notification_additionnelle_personnalisee__c = '';
        mySigner2.Duree_avant_expiration__c = 20;
        mySigner2.Delai_avant_relance__c = 7;
        mySigner2.Position__c = 2;

        lSigDoc.add(mySigner2);
        
        
        insert lSigDoc;
        
        
        // ============================================
        // Création des pièces justificatives à joindre
        // ============================================     
        List<Piece_Justificative__c> lPJ = new List<Piece_Justificative__c>();
        
        // RIB
        //if(oQuote.DO_Payment_method__c == 'P'){
            Piece_Justificative__c pj = new Piece_Justificative__c();
            pj.Signataire_Document__c = mySigner1.Id;
            pj.Description__c = 'RIB du client';
            pj.Obligatoire__c = true;
            pj.Type__c = 'Other';
            pj.Account__c = oCampMember.Contact.Account.Id;
            pj.CampaignMemberId__c = oCampMember.Id;
            lPJ.add(pj);
        //}

        if(lPJ.size()>0){
            insert lPJ;
        }
        
        
        // ============================================
        // Création des documents
        // ============================================        
        
        // Contract PDF
        generateContractPDF();
        
        // Mandat SEPA PDF
        //if(oQuote.DO_Payment_method__c == 'P'){
            generateMandatSEPAPDF();
            hasDocumentsToBeFilled = true;
        //}
        
        
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
        
        //resetFields();
        
        // ======================================
        // Création du circuit
        // ======================================
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] Création du circuit');
        Signea.Signea_Entities_v2.SigneaCircuit myCircuit = new Signea.Signea_Entities_v2.SigneaCircuit();
        
        
        myCircuit.description = 'Circuit de signature automatisé associé au compte ' + oCampMember.Contact.Account.AccountNumber;    
        myCircuit.name = parametres[0].Nom_du_circuit__c;
        myCircuit.notifyCreator = String.valueOf(parametres[0].Notification_Createur__c);
        myCircuit.keywords = parametres[0].Index_AES__c;
        myCircuit.Module = parametres[0].Module__c;
        //Parametrage prévue dans une futur version de SigneA
        //myCircuit.Condition_d_acceptation__c = parametres[0].Condition_d_acceptation__c;
    
        if(parametres[0].Notification_additionnelle_generale__c != null && !''.equals(parametres[0].Notification_additionnelle_generale__c)) {
            Signea.Signea_Entities_v2.SigneaNotification notif = new Signea.Signea_Entities_v2.SigneaNotification();
            notif.additionalNotification = emptyIfNull(parametres[0].Notification_additionnelle_generale__c);
            myCircuit.additionalNotification = notif ;
        }
        //myCircuit.insertAllDocumentInFillView = True;
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
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] signataire.Type_de_signataire__c = ' + signataire.Type_de_signataire__c);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] signataire.Id_SF_Signataire__c = ' + signataire.Id_SF_Signataire__c);
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
                List<Contact> con = [select id, Email, Country__c, Indicatif_Pays_c__c, MobilePhone from Contact where id = :oCampMember.Contact.Id ];   
                if( con.size() > 0 ) {
                    con[0].Email = oCampMember.Contact.Account.Email__c;
                    con[0].Country__c = oCampMember.Contact.Account.Country__c;
                    con[0].Indicatif_Pays_c__c = oCampMember.Contact.Account.Indicatif_Pays__c;
                    con[0].MobilePhone = oCampMember.Contact.Account.Mobile_Phone_Number__c;
                    update con;
                }
            }
            Signea.Signea_Entities_v2.SigneaSigner mySigner = new Signea.Signea_Entities_v2.SigneaSigner();
            mySigner.signerType = emptyIfNull(signataire.Type_de_signataire__c); 
            mySigner.signerId = emptyIfNull(signataire.Id_SF_Signataire__c);
            mySigner.signatureType = emptyIfNull(signataire.Type_de_signature__c);
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
            if (signataire.Telephone__c!=null && signataire.Telephone__c!='') mySigner.DealWithPhoneNumber = true; else mySigner.DealWithPhoneNumber = false;
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
                                      ' name="name_'+i+'"'+
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
                values = values+'\n'+'<value fieldName="name_'+i+'"' +  ' value="'+emptyIfNull(tag.Valeur_preremplie__c).replace('&', 'et')+'" />';
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
            oCampMember.Signea_Circuit__c = result.result;
            oCampMember.Signea_Date_Signature__c = null;
            oCampMember.Statut_circuit_de_signature__c = '';
            update oCampMember;
            
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
        
        PageReference pdfPage = Page.VFP_AvenantPDF_PaiementXFois_FromAccount;
        //pdfPage.getParameters().put('id', oCampMember.Contact.Account.Id);
        pdfPage.getParameters().put('id', oCampMember.Id);
        pdfPage.getParameters().put('isSE', isSE);
        pdfPage.getParameters().put('paymentSpreadChosen', paymentSpreadChosen);
        //Blob pdfBlob = pdfPage.getContent();
        
        // getContent not supported in Test Methods, so we need to handle it
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
        
        // Document
        Document oDoc = New Document();
        oDoc.Name = 'Contrat-' + oCampMember.Contact.Account.AccountNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oCampMember.Contact.Account.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Contrat-' + oCampMember.Contact.Account.AccountNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.Account__c = oCampMember.Contact.Account.Id;
        oDocASigner.CampaignMemberId__c = oCampMember.Id;
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
        tag1.Name = 'Name_1';
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
        tag2.Name = 'Name_2';
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
        tag3.Name = 'Name_3';
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
        
        PageReference pdfPage = Page.VFP_Mandat_SEPA_FromAccount;
        pdfPage.getParameters().put('id', oCampMember.Contact.Account.Id);
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
        oDoc.Name = 'Mandat SEPA-' + oCampMember.Contact.Account.AccountNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oCampMember.Contact.Account.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Mandat SEPA-' + oCampMember.Contact.Account.AccountNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.Account__c = oCampMember.Contact.Account.Id;
        oDocASigner.CampaignMemberId__c = oCampMember.Id;
        insert oDocASigner;
        
        // Zone_De_Remplissage__c
        List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
        
        // BIC
        Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
        tag1.Identifiant_document__c = oDocASigner.Id;
        tag1.Numero_Participant__c = 1;
        tag1.Description__c = 'Saisissez votre BIC';
        tag1.Type_de_remplissage__c = 'TEXT';
        tag1.Name = 'Name_1';
        tag1.Page__c = 1;
        tag1.Position_X__c = 75;
        tag1.Position_Y__c = 537;
        tag1.Largeur__c = 183;
        tag1.Hauteur__c = 16;
        tag1.Taille_de_la_police__c = FONT_SIZE;
        tag1.Obligatoire__c = true;
        tag1.Valeur_preremplie__c = '';
        tag1.format_champ__c = '([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)';
        tag1.Message_erreur__c = 'Saisissez vos données BIC sans espace';
        lTag.add(tag1);
        
        // IBAN
        Zone_De_Remplissage__c tag2 = new Zone_De_Remplissage__c();
        tag2.Identifiant_document__c = oDocASigner.Id;
        tag2.Numero_Participant__c = 1;
        tag2.Description__c = 'Saisissez votre IBAN';
        tag2.Type_de_remplissage__c = 'TEXT';
        tag2.Name = 'Name_2';
        tag2.Page__c = 1;
        tag2.Position_X__c = 75;
        tag2.Position_Y__c = 510;
        tag2.Largeur__c = 246;
        tag2.Hauteur__c = 16;
        tag2.Taille_de_la_police__c = FONT_SIZE;
        tag2.Obligatoire__c = true;
        tag2.Valeur_preremplie__c = '';
        tag2.format_champ__c = '[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}';
        tag2.Message_erreur__c = 'Saisissez vos données IBAN sans espace';
        lTag.add(tag2);
        
        // Client Salutation FirstName LastName
        Zone_De_Remplissage__c tag3 = new Zone_De_Remplissage__c();
        tag3.Identifiant_document__c = oDocASigner.Id;
        tag3.Numero_Participant__c = 1;
        tag3.Description__c = 'Nom du client';
        tag3.Type_de_remplissage__c = 'TEXT';
        tag3.Name = 'Name_3';
        tag3.Page__c = 1;
        tag3.Position_X__c = 40;
        tag3.Position_Y__c = 433;
        tag3.Largeur__c = 280;
        tag3.Hauteur__c = 16;
        tag3.Taille_de_la_police__c = FONT_SIZE;
        tag3.Obligatoire__c = true;
        tag3.Valeur_preremplie__c = (oCampMember.Contact.Salutation == null ? '' : oCampMember.Contact.Salutation + ' ') + (oCampMember.Contact.FirstName == null ? '' : oCampMember.Contact.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') + ' ') + (oCampMember.Contact.LastName == null ? '' : oCampMember.Contact.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        tag3.format_champ__c = '^[!#$\'(),.:;_\\- a-zA-Z0-9]{2,40}$';
        tag3.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag3);
        
        // Address line 1
        Zone_De_Remplissage__c tag4 = new Zone_De_Remplissage__c();
        tag4.Identifiant_document__c = oDocASigner.Id;
        tag4.Numero_Participant__c = 1;
        tag4.Description__c = 'Adresse du client 1';
        tag4.Type_de_remplissage__c = 'TEXT';
        tag4.Name = 'Name_4';
        tag4.Page__c = 1;
        tag4.Position_X__c = 40;
        tag4.Position_Y__c = 415;
        tag4.Largeur__c = 280;
        tag4.Hauteur__c = 16;
        tag4.Taille_de_la_police__c = FONT_SIZE;
        tag4.Obligatoire__c = true;
        tag4.Valeur_preremplie__c = (oCampMember.Contact.Account.Street_N__c == null ? '' : oCampMember.Contact.Account.Street_N__c + ' ') + (String.isBlank(oCampMember.Contact.Account.Number_extention__c) ? '' : oCampMember.Contact.Account.Number_extention__c + ' ') + (oCampMember.Contact.Account.Street_type__c == null ? '' : oCampMember.Contact.Account.Street_type__c + ' ') + (oCampMember.Contact.Account.Street_name__c == null ? '' : oCampMember.Contact.Account.Street_name__c + ' ') + (oCampMember.Contact.Account.Lieu_dit__c == null ? '' : oCampMember.Contact.Account.Lieu_dit__c);
        tag4.format_champ__c = '^[!#$\'(),.:;_\\- a-zA-Z0-9]{2,40}$';
        tag4.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag4);
        
        // Address line 2
        Zone_De_Remplissage__c tag5 = new Zone_De_Remplissage__c();
        tag5.Identifiant_document__c = oDocASigner.Id;
        tag5.Numero_Participant__c = 1;
        tag5.Description__c = 'Adresse du client 2';
        tag5.Type_de_remplissage__c = 'TEXT';
        tag5.Name = 'Name_5';
        tag5.Page__c = 1;
        tag5.Position_X__c = 40;
        tag5.Position_Y__c = 397;
        tag5.Largeur__c = 280;
        tag5.Hauteur__c = 16;
        tag5.Taille_de_la_police__c = FONT_SIZE;
        tag5.Obligatoire__c = true;
        if(oCampMember.Contact.Account.City_Postal_Code__c != null){
            tag5.Valeur_preremplie__c = oCampMember.Contact.Account.City_Postal_Code__r.Name;
        }else{
            tag5.Valeur_preremplie__c = (oCampMember.Contact.Account.Postal_Code__c == null ? '' : oCampMember.Contact.Account.Postal_Code__c) + ' - ' + (oCampMember.Contact.Account.City__c == null ? '' : oCampMember.Contact.Account.City__c);
        }
        tag5.format_champ__c = '^[\'(),.\\- a-zA-Z0-9]{2,30}$';
        tag5.Message_erreur__c = 'Vérifiez les informations renseignées';
        lTag.add(tag5);
        
        // Signature
        Zone_De_Remplissage__c tag6 = new Zone_De_Remplissage__c();
        tag6.Identifiant_document__c = oDocASigner.Id;
        tag6.Numero_Participant__c = 1;
        tag6.Description__c = '';
        tag6.Type_de_remplissage__c = 'SIGNATURE';
        tag6.Name = 'Name_6';
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
    
    
    /** Checking issues for first step **/
    public static String getIssuesBeforePreparingData(){
        
        string pbCode = '';
        boolean missingTel = false;
        boolean missingEmail = false;
        
        
        //// Check mobile phone isn't blank (/!\ PA/BA)
        //if(oCampMember.Contact.Account.IsPersonAccount){
        //    if(oCampMember.Contact.Account.Mobile_Phone_Number__c == null || oCampMember.Contact.Account.Mobile_Phone_Number__c == ''){
        //        missingTel = true;
        //    }
        //}/*else{
        //    if(oQuote.Contact.MobilePhone == null || oQuote.Contact.MobilePhone == ''){
        //        missingTel = true;
        //    }
        //}*/
        //if(missingTel) pbCode += '- Téléphone mobile du client non-renseigné.' + '<br>';
        
        //// Check email isn't blank
        //if(oCampMember.Contact.Account.IsPersonAccount){
        //  // /!\ if we want to manage 2 email addresses, the insert in Signea table must be modified
        //    //if((oQuote.Account.Email__c == null || oQuote.Account.Email__c == '') && (oQuote.Account.Email_2__c == null || oQuote.Account.Email_2__c == '')){
        //    if(oCampMember.Contact.Account.Email__c == null || oCampMember.Contact.Account.Email__c == ''){
        //        missingEmail = true;
        //    }
        //}/*else{
        //    //if((oQuote.Contact.Email == null || oQuote.Contact.Email == '') && (oQuote.Contact.Email_2__c == null || oQuote.Contact.Email_2__c == '')){
        //    if(oQuote.Contact.Email == null || oQuote.Contact.Email == ''){
        //        missingEmail = true;
        //    }
        //}*/
        //if(missingEmail) pbCode += '- Adresse e-mail du client non-renseignée.' + '<br>';
        

        if(oCampMember.Contact.Account.AccountNumber == null || oCampMember.Contact.Account.AccountNumber == ''){
            pbCode += 'Pas de référence client au niveau du compte.';
        }
        if(oCampMember.Contact.Account.Mandataire__c == null || oCampMember.Contact.Account.Mandataire__r.ExternalID__c == null || oCampMember.Contact.Account.Mandataire__r.ExternalID__c == ''){
            pbCode += 'Pas de mandataire au niveau du compte.';
        }
        if(oCampMember.Contact.Account.Activity_Domain_Simple__c == null || oCampMember.Contact.Account.Activity_Domain_Simple__c == ''){
            pbCode += 'Pas de secteur d\'activité au niveau du compte.';
        }
        
        //if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez corriger ces anomalies afin de pouvoir lancer le circuit de signature.';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    /** Checking issues for second step **/
    public static String getIssuesAfterPreparingData(){
        
        string pbCode = '';
        
        
        if( oCampMember.Signea_Circuit__c != null ) {
            List<Signea__Circuit__c> myCircuits = [select id, name, signea__status__c from Signea__Circuit__c where id = :oCampMember.Signea_Circuit__c ];   
            if( myCircuits != null && myCircuits.size() > 0 ) {
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] myCircuits.size() = ' + myCircuits.size());
                if( myCircuits[0].signea__status__c != 'Refused' && myCircuits[0].signea__status__c != 'Expired' && myCircuits[0].signea__status__c != 'Cancelled' && myCircuits[0].signea__status__c != 'Launch Failed' ) {
                    pbCode += 'ENC - Un circuit est déjà en cours de signature.'; // + '<br>';
                }
            }
        }
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] oCampMember.Id = ' + oCampMember.Id);

        // Controle des documents à signer
        documents = [select id, Id_SF_Document__c, Name, Type_de_document__c from Document_A_Signer__c where CampaignMemberId__c = :oCampMember.Id ];
        if( documents == null || documents.size() == 0 ) {
            pbCode += '- Aucun document dans le membre de campagne.'; // + '<br>';
        }
        
        // Controle des signataires
        signataires = [select id, Delai_avant_relance__c, Type_de_signataire__c, Id_SF_Signataire__c, Duree_avant_expiration__c, Email__c, Telephone__c, Civilite__c, Name, Prenom__c, Numero_du_participant__c, Etape_de_signature__c, Type_de_destinataire__c, Type_de_signature__c, Notification_additionnelle_personnalisee__c from Signataire_Document__c where CampaignMemberId__c = :oCampMember.Id order by Etape_de_signature__c asc ];
        system.Debug('\n\n===> signataires : ' +  signataires  + '\n\n');
        if( signataires == null || signataires.size() == 0 ) {
            pbCode += '- Aucun signataire dans le membre de campagne.'; // + '<br>';
        }
        
        // Controle des paramètres de signature
        parametres = [select id, Nom_du_circuit__c, Index_AES__c, Condition_d_acceptation__c, Notification_Createur__c, Notification_additionnelle_generale__c, Module__c from Parametre_Signature__c where CampaignMemberId__c = :oCampMember.Id ];
        if( parametres == null || parametres.size() == 0 ) {
            pbCode += '- Aucun paramètre de signature dans le membre de campagne.'; // + '<br>';
        }
        
        //if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez contacter l\'administrateur de l\'application.';
        //if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromCampaign.ProcessDataForSigneaFromCampaign] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    /** Delete records linked to current quote from Signea objects and Documents **/
    public static void deleteRecords(){
        
        List<Parametre_Signature__c> lParametreSignature = [select Id from Parametre_Signature__c where CampaignMemberId__c =:oCampMember.Id];
        delete lParametreSignature;
        
        List<Signataire_Document__c> lSignataireDocument = [select Id from Signataire_Document__c where CampaignMemberId__c =:oCampMember.Id];
        delete lSignataireDocument;
        
        List<Piece_Justificative__c> lPieceJustificative = [select Id from Piece_Justificative__c where CampaignMemberId__c =:oCampMember.Id];
        delete lPieceJustificative;
        
        // Delete Docs et DocsSignea
        List<Document_A_Signer__c> lDocumentASigner = [select Id, Id_SF_Document__c from Document_A_Signer__c where CampaignMemberId__c =:oCampMember.Id];
        
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

    public string getPrettyDate() {
        Date today = Date.today();
        return today.format();
    }


}