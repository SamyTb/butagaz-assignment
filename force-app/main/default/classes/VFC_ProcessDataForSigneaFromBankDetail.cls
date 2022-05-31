global class VFC_ProcessDataForSigneaFromBankDetail {
    
    public static String isSE{get; set;} // Is the quote being electronically signed ?
    
    //private static Quote oQuote;
    private static Account oAccount;
    private static Id oContactId;
    private static Bank_Detail__c oBankDetailToSign;
    
    private static list<Bank_Detail__c> lBankDetailToSign;
    
    /*private static list<PEC__c> lPECToSign;
    private static list<CDS__c> lCDSToSign;
    private static PEC__c oPECToSign;  // = new PEC__c();
    private static CDS__c oCDSToSign;  // = new CDS__c();*/

    private static final integer FONT_SIZE = 10;  // Sets the font size of fields sent to Signea
    private static final string sFolderId = AP_PricingUtilities.getCustomSettingValue('FolderIdToStoreDocumentsForSignea');  // Used to store the id of the folder in which documents will be copied for Signea 
    private static final string sMaxNumberEvidenceFilesForSignea = AP_PricingUtilities.getCustomSettingValue('MaxNumberEvidenceFilesForSignea');  // Used to store the max number of files per evidence the cutomer is allowed to upload on Contralia

    private static list<Document_A_Signer__c> documents {get;set;}
    private static list<Signataire_Document__c> signataires {get;set;}
    private static list<Parametre_Signature__c> parametres {get;set;}
    
    private static integer gMode;  // From 90 to 93, used for Covid
    
    
    
    // pMode : 0 = Prepare data only | 1 = Prepare data and call WS 
    WebService static string ProcessDataForSignea(string accountId, string contactId, integer pMode) {
        
        string outcomeMessage;
        
        
        isSE = 'true';  // electronic signature
        gMode = pMode;
        
        // Check if user has the required permissions to run the Signea process
        if(!Test.isRunningTest()){
            if(VFC_User.isUserAuthorizedToRunSignea(UserInfo.getUserId()) == false){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] : 001-Utilisateur non autorisé à lancer la signature électronique.');
                return '<span style="color: red">- Utilisateur non autorisé à lancer la signature électronique.</span>';
            }
        }

        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] accountId = ' + accountId);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] contactId = ' + contactId);
        
        
        if(contactId != null && contactId != ''){
            oContactId = contactId;
        }
        // Get Account
        List<Account> lAccounts = new List<Account>();
        
        if(accountId != null && accountId != ''){
            lAccounts = [select Id, AccountNumber, PersonContactId, Mandataire__c, Mandataire__r.ExternalID__c, Activity_Domain_Simple__c, Mandataire__r.Headquarters_Phone__c, Mandataire__r.Email_Service_Client__c, Mandataire__r.Electronic_Signature_Email__c, Email__c, 
                            Country__c, Indicatif_Pays__c, Mobile_Phone_Number__c, Payment_method__c, Market_type__c, Salutation__c,
                            Name, Street_N__c, Number_extention__c, Street_type__c, Street_name__c, Lieu_dit__c, City_Postal_Code__c, City_Postal_Code__r.Postal_Code__c, 
                            City_Postal_Code__r.Name, City_Postal_Code__r.City__r.Name
                         from Account where Id =:accountId limit 1];
        }
        
        if(!lAccounts.isEmpty()){
            oAccount = lAccounts[0];
            if(contactId==null && oAccount.PersonContactId==null){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] : 001-Contact non trouvé.');
                return '001-Contact non trouvé.';
            }else if( (contactId == null || contactId == '') && (oAccount.PersonContactId != null || oAccount.PersonContactId == '') ){
                oContactId = oAccount.PersonContactId;
            }
        }else{
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] : 001-Compte non trouvé.');
            return '001-Compte non trouvé.';
        }
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] oAccount.Id = ' + oAccount.Id);


        // Load BankDetail
        lBankDetailToSign = getBankDetailToSign();
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] lBankDetailToSign = ' + lBankDetailToSign);
        if(lBankDetailToSign.size()>0) {
            oBankDetailToSign = lBankDetailToSign[0];
        }else{
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] : 001-Un circuit est déjà en cours de signature.');
            return '001-Un circuit est déjà en cours de signature.';
        }
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] oBankDetailToSign = ' + oBankDetailToSign);
        
        
        // Don't go further if an issue is found
        string pbMessageBefore = getIssuesBeforePreparingData();
        if(pbMessageBefore != ''){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] message = ' + pbMessageBefore);
            return pbMessageBefore;
        }
        
        
         
        // Prepare data and optionally call WS depending on pMode parameter
        if(prepareDataForSignea()){
            if(pMode == 1 || pMode == 90 || pMode == 91 || pMode == 92 || pMode == 93){
                // Ok to call WS
                
                string pbMessageAfter = getIssuesAfterPreparingData();
                if(pbMessageAfter != ''){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] message = ' + pbMessageAfter);
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
        if(oBankDetailToSign!=null){
            deleteRecords();
        }
        
        
        // ============================================
        // Création des parametres du circuit
        // ============================================
        system.Debug('# debut Création des parametres du circuit');
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] Début Création des parametres du circuit');
        Parametre_Signature__c myCircuitParam = new Parametre_Signature__c();
        myCircuitParam.Bank_Detail__c = oBankDetailToSign.Id;
        myCircuitParam.Index_AES__c = 'matricule_do=' + oAccount.AccountNumber + ', matricule_pa=' + oAccount.AccountNumber + ', matricule_fa=' + oAccount.AccountNumber + ', orga_comm=' + oAccount.Mandataire__r.ExternalID__c + ', activite=' + oAccount.Activity_Domain_Simple__c.toUpperCase();
        myCircuitParam.Condition_d_acceptation__c = 'J\'ai lu le document et j\'accepte sans réserve les conditions.';
        myCircuitParam.Notification_Createur__c = true;
        
        if( gMode == 1 ){
            myCircuitParam.Module__c = 'SEPA';
        }else if ( gMode == 90 ){
            myCircuitParam.Module__c = 'SEPA90';
        }else if ( gMode == 91 ){
            myCircuitParam.Module__c = 'SEPA91';
        }else if ( gMode == 92 ){
            myCircuitParam.Module__c = 'SEPA92';
        }else if ( gMode == 93 ){
            myCircuitParam.Module__c = 'SEPA93';
        }
        
        //myCircuitParam.Notification_additionnelle_generale__c = '';
        myCircuitParam.Notification_additionnelle_generale__c = 'Pour toute question, votre Service Clients est à votre disposition au ' + oAccount.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oAccount.Mandataire__r.Email_Service_Client__c;
        Datetime curDT = Datetime.now();
        
        string FirstAndLastName = ( (oBankDetailToSign.Contact__r.FirstName == null || oBankDetailToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oBankDetailToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oBankDetailToSign.Contact__r.LastName == null || oBankDetailToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oBankDetailToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        myCircuitParam.Nom_du_circuit__c = FirstAndLastName.left(49) + ' - ' + oAccount.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        
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
        mySigner1.Id_SF_Signataire__c = oBankDetailToSign.Contact__r.Id;
        //mySigner1.Id_SF_Signataire__c = null;
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        mySigner1.Civilite__c = oBankDetailToSign.Contact__r.Salutation;
        mySigner1.Prenom__c = ( (oBankDetailToSign.Contact__r.FirstName == null || oBankDetailToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oBankDetailToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner1.Name = ( (oBankDetailToSign.Contact__r.LastName == null || oBankDetailToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oBankDetailToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        mySigner1.Email__c = oBankDetailToSign.Contact__r.Email;
        mySigner1.Telephone__c = oBankDetailToSign.Contact__r.Country__c == 'FR' ? oBankDetailToSign.Contact__r.MobilePhone : oBankDetailToSign.Contact__r.Indicatif_Pays_c__c + oBankDetailToSign.Contact__r.MobilePhone;
        // ***
        mySigner1.Etape_de_signature__c = '1-Signature Client';
        mySigner1.Account__c = oAccount.Id;
        mySigner1.Bank_Detail__c = oBankDetailToSign.Id;
        mySigner1.Notification_additionnelle_personnalisee__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oAccount.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oAccount.Mandataire__r.Email_Service_Client__c;
        mySigner1.Duree_avant_expiration__c = 30;
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
        mySigner2.Account__c = oAccount.Id;
        mySigner2.Bank_Detail__c = oBankDetailToSign.Id;
        mySigner2.Notification_additionnelle_personnalisee__c = '';
        mySigner2.Duree_avant_expiration__c = 30;
        mySigner2.Delai_avant_relance__c = 7;
        mySigner2.position__c = 2;
        
        lSigDoc.add(mySigner2);
        
        
        insert lSigDoc;
        
        
        // ============================================
        // Création des pièces justificatives à joindre
        // ============================================     
        List<Piece_Justificative__c> lPJ = new List<Piece_Justificative__c>();
        
        // RIB
        //if(oAccount.Payment_method__c == 'P' || oAccount.Payment_method__c == '2' || oAccount.Payment_method__c == '3'){   // P = Prélèvement d'office, 2 = LCR, 3 = LCR Acceptée
            Piece_Justificative__c pj = new Piece_Justificative__c();
            pj.Signataire_Document__c = mySigner1.Id;
            pj.Description__c = 'RIB du client';
            pj.Obligatoire__c = true;
            pj.Type__c = 'Other';
            pj.Bank_Detail__c = oBankDetailToSign.Id;
            lPJ.add(pj);
        //}
        
        // Manage documents required for Covid specificities
        if( gMode == 90 || gMode == 91 || gMode == 92 || gMode == 93 ){
            
            Piece_Justificative__c pj1 = new Piece_Justificative__c();
            pj1.Signataire_Document__c = mySigner1.Id;
            pj1.Description__c = 'Demande au fonds de solidarité';
            pj1.Obligatoire__c = true;
            pj1.Type__c = 'Other';
            pj1.Bank_Detail__c = oBankDetailToSign.Id;
            lPJ.add(pj1);
            
            Piece_Justificative__c pj2 = new Piece_Justificative__c();
            pj2.Signataire_Document__c = mySigner1.Id;
            pj2.Description__c = 'Attestation sur l\'honneur';
            pj2.Obligatoire__c = true;
            pj2.Type__c = 'Other';
            pj2.Bank_Detail__c = oBankDetailToSign.Id;
            lPJ.add(pj2);
            
            Piece_Justificative__c pj3 = new Piece_Justificative__c();
            pj3.Signataire_Document__c = mySigner1.Id;
            pj3.Description__c = 'Estimation perte CA';
            pj3.Obligatoire__c = true;
            pj3.Type__c = 'Other';
            pj3.Bank_Detail__c = oBankDetailToSign.Id;
            lPJ.add(pj3);
        }
        
        if(lPJ.size()>0){
            insert lPJ;
        }
        
        
        // ============================================
        // Création des documents
        // ============================================        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] oAccount : ' + oAccount);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] oAccount.Payment_method__c : ' + oAccount.Payment_method__c);
        // Mandat SEPA PDF
        // For FIDE project type, we only need the Mandat SEPA if the customer wasn't on PO before
        //if( (oQuote.Opportunity.Changement_de_banque__c != null && oQuote.Opportunity.Changement_de_banque__c.toUpperCase() == 'OUI') || oQuote.Project_Type__c == 'CREA'|| (oQuote.Project_Type__c == 'SUCC' && oQuote.Account.Activity_Domain_Simple__c == 'gec') || (oQuote.Project_Type__c == 'FIDE' && oQuote.Account.Payment_method__c != 'P') ){
            //if(oAccount.Payment_method__c == 'P'){
                generateMandatSEPAPDF();
            //}
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
        
        resetFields();
        
        // ======================================
        // Création du circuit
        // ======================================
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] Création du circuit');
        Signea.Signea_Entities_v2.SigneaCircuit myCircuit = new Signea.Signea_Entities_v2.SigneaCircuit();
        
        
        myCircuit.description = 'Circuit de signature automatisé associé au SEPA ' + oBankDetailToSign.Name;
        myCircuit.name = parametres[0].Nom_du_circuit__c;
        myCircuit.notifyCreator = String.valueOf(parametres[0].Notification_Createur__c);
        // For this particular circuit, we only want to send minimal notifications
        
        myCircuit.keywords = parametres[0].Index_AES__c;
        //Parametrage prévu dans une futur version de SigneA
        //myCircuit.Condition_d_acceptation__c = parametres[0].Condition_d_acceptation__c;
        
        if(oAccount.Mandataire__c != null){
            myCircuit.emailSender = oAccount.Mandataire__r.Electronic_Signature_Email__c;
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
        for(Signataire_Document__c signataire : signataires){
            
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
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] signataire.Type_de_signataire__c = ' + signataire.Type_de_signataire__c);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] signataire.Id_SF_Signataire__c = ' + signataire.Id_SF_Signataire__c);
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
                //List<Contact> con = [select id, Email, Country__c, Indicatif_Pays_c__c, MobilePhone from Contact where id = :oQuote.Contact.Id ];
                /* 20170831 Erwan | Suppression de cette étape pour éviter modification d'email
                List<Contact> con = new List<Contact>();
                String conId;
                if(oPECToSign!=null){
                    conId = oPECToSign.Contact__r.Id;
                }else if(oCDSToSign!=null){
                    conId = oCDSToSign.Contact__r.Id;
                }
                con = [select id, Email, Country__c, Indicatif_Pays_c__c, MobilePhone from Contact where id = :conId ];
                if( con.size() > 0 ) {
                    con[0].Email = oAccount.Email__c;
                    con[0].Country__c = oAccount.Country__c;
                    con[0].Indicatif_Pays_c__c = oAccount.Indicatif_Pays__c;
                    con[0].MobilePhone = oAccount.Mobile_Phone_Number__c;
                    update con;
                }*/
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
                        //'<smsCustomMessage>' + System.Label.Signea_SMS_Message_PaymentMethod + '</smsCustomMessage>'+
                        '<smsCustomMessage>' + (oAccount.Payment_method__c == 'C' ? System.Label.Signea_SMS_Message_PaymentMethod : System.Label.Signea_SMS_Message_BankDetails) + '</smsCustomMessage>'+
                        //'<emailCustomSubject>Signature de votre Contrat Butagaz - Code OTP</emailCustomSubject>'+
                        //'<emailCustomMessage><![CDATA[<html>Cher Signataire,<br/><br/>Le code OTP nécessaire à la signature de votre contrat Butagaz est : {OTP}</html>]]></emailCustomMessage>'+
                    '</genOtpConfig>'+
                '</config>';
            
            if(null != signataire.Type_de_signature__c) {
                mySigner.participantNumber = integer.valueOf(signataire.Numero_du_participant__c);
            }
            mySigner.position = Integer.ValueOf(signataire.position__c);
            // For the Mandat SEPA circuit, we don't want to send all notifications :
            mySigner.NotificationSignerSignerHasSigned = false;
            mySigner.NotificationSignerSignerHasStamped = false;
            
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
                //values = values+'\n'+'<value fieldName="name_'+i+'"' +  ' value="'+emptyIfNull(tag.Valeur_preremplie__c).replace('&', 'et')+'" />';
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
            // Associate circuit with the Bank_Detail__c object
            if(oBankDetailToSign != null){
                system.Debug(logginglevel.WARN,'\n\n===> oBankDetailToSign : ' + oBankDetailToSign + '\n\n');
                oBankDetailToSign.Signea_Circuit__c = result.result;
                oBankDetailToSign.Signea_Date_Signature__c = null;
                oBankDetailToSign.Statut_circuit_de_signature__c = '';
                update oBankDetailToSign;
            }


            // Associate circuit with the account
            Signea__Circuit__c oCircuit = [ select Id, Name, AccountBTZ__c from Signea__Circuit__c where Id = :oBankDetailToSign.Signea_Circuit__c LIMIT 1 ];
            
            if(oCircuit != null){
                oCircuit.AccountBTZ__c = oBankDetailToSign.Account__c;
                
                // For the purpose of adapting the notification message whether the customer changes his payment method or not, we need to set the information on a field that is reachable from the email template 
                oCircuit.Change_Of_Payment_Method__c = (oAccount.Payment_method__c == 'C');
                
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
    
    
    public static List<Bank_Detail__c> getBankDetailToSign(){
        
        List<Bank_Detail__c> lBD = new List<Bank_Detail__c>();
        Boolean bNeedToCreateBankDetailRecord = false;
        
        lBD = [SELECT Id, Name, Status__c, Account__c, Signea_Circuit__c, Signea_Circuit__r.signea__status__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c, Signea_Raison_Refus_Signature__c, Contact__r.Id, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Country__c, Contact__r.MobilePhone, Contact__r.Indicatif_Pays_c__c 
                                FROM Bank_Detail__c WHERE Account__c =: oAccount.Id /*AND Status__c = 'Attente de signature'*/ ORDER BY CreatedDate DESC LIMIT 1];
        
        
        Set<String> ongoingSet = new Set<String>{'Ongoing', 'Launch Success', 'Launching', 'Draft', 'Cancelling', 'Filling', 'Filled'};
        Set<String> cancelledSet = new Set<String>{'Expired', 'Refused', 'Launch Failed', 'Cancelled', 'Cancelled Contralia', 'Cancelled Signea', 'Refused Contralia', 'Refused Signea', 'Expired Contralia', 'Expired Signea'};
        Set<String> completedSet = new Set<String>{'Completed', 'Completed Contralia', 'Completed Signea'};
        
        
        if( lBD.size() > 0 ){
            
            if( ongoingSet.contains( lBD[0].Signea_Circuit__r.signea__status__c ) ){
                
                // Circuit ongoing, stop there
                lBD.clear();
                return lBD;
                
            }else if( cancelledSet.contains( lBD[0].Signea_Circuit__r.signea__status__c ) ){
                
                // We can erase the current circuit and launch a new one on the same Bank Detail record
                // No need to do anything, we'll use the Bank Detail record we just queried to store the electronic signature circuit
                
            }else if( completedSet.contains( lBD[0].Signea_Circuit__r.signea__status__c ) ){
                
                // We need to create a new Bank Detail record to store the electronic signature circuit
                bNeedToCreateBankDetailRecord = true;
                
            }
            
        }else{
            // We need to create a new Bank Detail record to store the electronic signature circuit
            bNeedToCreateBankDetailRecord = true;
        }
        
        if(bNeedToCreateBankDetailRecord){
            
            Bank_Detail__c oBD = new Bank_Detail__c(
                    Account__c = oAccount.Id, 
                    Contact__c = oContactId,
                    Status__c = '', //'Attente de signature',
                    Signea_Circuit__c = null,
                    Signea_Date_Signature__c = null,
                    Signea_Raison_Refus_Signature__c = '',
                    Statut_circuit_de_signature__c = ''
                );
                insert new List<Bank_Detail__c> { oBD };
                
                // Re-query the BankDetail record that we just created so we have access to its fields' values 
                lBD = [SELECT Id, Name, Status__c, Account__c, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c, Signea_Raison_Refus_Signature__c, Contact__r.Id, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Country__c, Contact__r.MobilePhone, Contact__r.Indicatif_Pays_c__c 
                       FROM Bank_Detail__c WHERE Id =: oBD.Id];
                
        }
        
        return lBD;
    }
    
    
    /** Generate and save MandatSEPA PDF file **/ 
    public static void generateMandatSEPAPDF() {
        
        PageReference pdfPage = Page.VFP_Mandat_SEPA_FromAccount;
        pdfPage.getParameters().put('id', oAccount.Id);
        
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
        oDoc.Name = 'Mandat SEPA-' + oAccount.AccountNumber;
        oDoc.Body = pdfBlob;
        oDoc.Type = 'pdf';
        oDoc.FolderId = sFolderId;
        oDoc.Description = oAccount.Id;
        insert oDoc;
        
        // Document_A_Signer__c
        Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
        oDocASigner.Id_SF_Document__c = oDoc.Id;
        oDocASigner.Name = 'Mandat SEPA-' + oAccount.AccountNumber;
        oDocASigner.Type_de_document__c = 'Document';
        oDocASigner.Account__c = oAccount.Id;
        oDocASigner.Bank_Detail__c = oBankDetailToSign.Id;
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
        if(oAccount.Activity_Domain_Simple__c == 'gec' && oAccount.Market_type__c == 'DOM'){
            tag3.Valeur_preremplie__c = (oBankDetailToSign.Contact__r.Salutation == null ? '' : oBankDetailToSign.Contact__r.Salutation + ' ') + (oBankDetailToSign.Contact__r.FirstName == null ? '' : oBankDetailToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') + ' ') + (oBankDetailToSign.Contact__r.LastName == null ? '' : oBankDetailToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
        }else{
            tag3.Valeur_preremplie__c = (oAccount.Salutation__c == null ? '' : oAccount.Salutation__c + ' ') + (oAccount.Name == null ? '' : oAccount.Name.replaceAll('[^- \'\\p{L}\\p{M}*]', '') + ' ');
        }
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
        tag4.Valeur_preremplie__c = (oAccount.Street_N__c == null ? '' : oAccount.Street_N__c + ' ') + (String.isBlank(oAccount.Number_extention__c) ? '' : oAccount.Number_extention__c + ' ') + (oAccount.Street_type__c == null ? '' : oAccount.Street_type__c + ' ') + (oAccount.Street_name__c == null ? '' : oAccount.Street_name__c + ' ') + (oAccount.Lieu_dit__c == null ? '' : oAccount.Lieu_dit__c);
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
        if(oAccount.City_Postal_Code__c != null){
            tag5.Valeur_preremplie__c = oAccount.City_Postal_Code__r.Name;
        }else{
            tag5.Valeur_preremplie__c = (oAccount.City_Postal_Code__c == null || oAccount.City_Postal_Code__r.Postal_Code__c == null ? '' : oAccount.City_Postal_Code__r.Postal_Code__c) + ' - ' + (oAccount.City_Postal_Code__r == null || oAccount.City_Postal_Code__r.City__r.Name == null ? '' : oAccount.City_Postal_Code__r.City__r.Name);
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
    
    
    /** Checking issues for first step **/
    public static String getIssuesBeforePreparingData(){
        string pbCode = '';
        boolean missingTel = false;
        boolean missingEmail = false;
        

        // Check Account info
        if(oAccount.AccountNumber == null || oAccount.AccountNumber == ''){
            pbCode += '- Pas de référence client au niveau du compte.' + '<br>';
        }
        if(oAccount.Mandataire__c == null || oAccount.Mandataire__r.ExternalID__c == null || oAccount.Mandataire__r.ExternalID__c == ''){
            pbCode += '- Pas de mandataire au niveau du compte.' + '<br>';
        }
        if(oAccount.Activity_Domain_Simple__c == null || oAccount.Activity_Domain_Simple__c == ''){
            pbCode += '- Pas de secteur d\'activité au niveau du compte.' + '<br>';
        }
        
        // Rule for Covid specificities
        if( gMode == 90 || gMode == 91 || gMode == 92 || gMode == 93 ){
            if(oAccount.Payment_method__c == 'P'){
                pbCode += '- Le client est déjà en prélévement d\'office.' + '<br>';
            }
        }else{
            // Check the client is already in PO or LCR payment method or Gazaumois
            if(oAccount.Payment_method__c != 'P' && oAccount.Payment_method__c != '2' && oAccount.Payment_method__c != '3' && oAccount.Payment_method__c != 'G' && oAccount.Payment_method__c != 'C'){
                pbCode += '- Le client n\'est ni en prélévement d\'office, ni en LCR, ni en chèque.' + '<br>';
            }
        }
        
        // Check mobile phone isn't blank
        if(lBankDetailToSign.size() > 0 && (oBankDetailToSign.Contact__r.MobilePhone == null || oBankDetailToSign.Contact__r.MobilePhone == '')){
            missingTel = true;
        }
        if(missingTel) pbCode += '- Téléphone mobile du contact non-renseigné.' + '<br>';

        // Check email isn't blank
        if(lBankDetailToSign.size() > 0 && (oBankDetailToSign.Contact__r.Email == null || oBankDetailToSign.Contact__r.Email == '')){
            missingEmail = true;
        }
        if(missingEmail) pbCode += '- Adresse e-mail du contact non-renseignée.' + '<br>';

        /*// Check PEC and/or CDS are there
        if(source == 'ACCOUNT' || source == 'PEC'){
            if(lPECToSign != null && lPECToSign.isEmpty()){
                pbCode += '- Pas de Prise en Charge en attente de signature pour ce compte.' + '<br>';
            }else if(lPECToSign != null && lPECToSign.size() > 1){
                pbCode += '- Plusieurs Prises en Charge en attente de signature pour ce compte.' + '<br>';
            }
        }*/

        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez corriger ces anomalies afin de pouvoir lancer le circuit de signature.';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    /** Checking issues for second step **/
    public static String getIssuesAfterPreparingData(){
        
        string pbCode = '';
        
        
        //if( oQuote.Signea_Circuit__c != null ) {
            //List<Signea__Circuit__c> myCircuits = [select id, name, signea__status__c from Signea__Circuit__c where id = :oQuote.Signea_Circuit__c ];   
            //if( myCircuits != null && myCircuits.size() > 0 ) {
                //if( myCircuits[0].signea__status__c != 'Refused' && myCircuits[0].signea__status__c != 'Expired' && myCircuits[0].signea__status__c != 'Cancelled' && myCircuits[0].signea__status__c != 'Launch Failed' ) {
                    //pbCode += '- Un circuit est déjà en cours de signature.' + '<br>';
                //}
            //}
        //}
        
        // Controle des documents à signer
        documents = [select id, Id_SF_Document__c, Name, Type_de_document__c from Document_A_Signer__c where Bank_Detail__c = :oBankDetailToSign.Id ];
        if( documents == null || documents.size() == 0 ) {
            pbCode += '- Aucun document dans le circuit.' + '<br>';
        }
        
        // Controle des signataires
        signataires = [select id, position__c, Delai_avant_relance__c, Type_de_signataire__c, Id_SF_Signataire__c, Duree_avant_expiration__c, Email__c, Telephone__c, Civilite__c, Name, Prenom__c, Numero_du_participant__c, Etape_de_signature__c, Type_de_destinataire__c, Type_de_signature__c, Notification_additionnelle_personnalisee__c from Signataire_Document__c where Bank_Detail__c = :oBankDetailToSign.Id order by Etape_de_signature__c asc ];
        system.Debug('\n\n===> signataires : ' +  signataires  + '\n\n');
        if( signataires == null || signataires.size() == 0 ) {
            pbCode += '- Aucun signataire dans le circuit.' + '<br>';
        }
        
        // Controle des paramètres de signature
        parametres = [select id, Module__c, Nom_du_circuit__c, Index_AES__c, Condition_d_acceptation__c, Notification_Createur__c, Notification_additionnelle_generale__c from Parametre_Signature__c where Bank_Detail__c = :oBankDetailToSign.Id ];
        if( parametres == null || parametres.size() == 0 ) {
            pbCode += '- Aucun paramètre de signature.' + '<br>';
        }
        
        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromBankDetail.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    
    /** Delete records linked to current quote from Signea objects and Documents **/
    public static void deleteRecords(){
        
        /*List<Signea__Circuit__c> lSigneaCircuit = [select Id from Signea__Circuit__c where Id =:oQuote.Signea_Circuit__c];
        delete lSigneaCircuit;*/
        Signea.Signea_Entities_V2.SigneaServicesResult result;
        result = Signea.Signea_API_V2.deleteCircuit(oBankDetailToSign.Signea_Circuit__c);
        system.Debug(logginglevel.WARN,'deleteCircuit result : ' + result);
        
        
        List<Parametre_Signature__c> lParametreSignature = [select Id from Parametre_Signature__c where Bank_Detail__c =:oBankDetailToSign.Id];
        delete lParametreSignature;
        
        List<Signataire_Document__c> lSignataireDocument = [select Id from Signataire_Document__c where Bank_Detail__c =:oBankDetailToSign.Id];
        delete lSignataireDocument;
        
        List<Piece_Justificative__c> lPieceJustificative = [select Id from Piece_Justificative__c where Bank_Detail__c =:oBankDetailToSign.Id];
        delete lPieceJustificative;
        
        // Delete Docs et DocsSignea
        List<Document_A_Signer__c> lDocumentASigner = [select Id, Id_SF_Document__c from Document_A_Signer__c where Bank_Detail__c =:oBankDetailToSign.Id];
        
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

        
        if(oBankDetailToSign != null && oBankDetailToSign.Signea_Circuit__c != null){
            
            if( result.errorCode == '000' ) {
                // Delete was successfull
            } else {
                system.Debug(logginglevel.WARN,'deleteCircuit result error : ' + result.errorCode + '-' + result.errorMessage);
                //return result.errorCode + '-' + result.errorMessage;
            }
        }
        
    }
    
    /** Reset fields of the current Bank_Detail__c **/
    public static void resetFields(){
        
        // Update BankDetail fields
        if(oBankDetailToSign!=null){
            oBankDetailToSign.Status__c = '';
            oBankDetailToSign.Statut_circuit_de_signature__c = '';
            oBankDetailToSign.Signea_Date_Signature__c = null;
            oBankDetailToSign.Signea_Raison_Refus_Signature__c = '';
            oBankDetailToSign.Signea_Circuit__c = null;
            update oBankDetailToSign;
        }
        
    }
    
    
    /** Getting Custom Settings methods **/
    /*public static String getDocumentsIdsValue(String name){
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
    }*/
    
}