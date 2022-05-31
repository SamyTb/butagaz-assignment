global class VFC_ProcessDataForSigneaFromPECandCDS {

    public static String isSE{get; set;} // Is the quote being electronically signed ?

    private static Account oAccount;
    //private static Quote oQuote;  // plus nécessaire

    private static list<PEC__c> lPECToSign;
    private static list<CDS__c> lCDSToSign;
    private static PEC__c oPECToSign;  // = new PEC__c();
    private static CDS__c oCDSToSign;  // = new CDS__c();

    private static final integer FONT_SIZE = 10;  // Sets the font size of fields sent to Signea
    private static final string sFolderId = AP_PricingUtilities.getCustomSettingValue('FolderIdToStoreDocumentsForSignea');  // Used to store the id of the folder in which documents will be copied for Signea 
    private static final string sMaxNumberEvidenceFilesForSignea = AP_PricingUtilities.getCustomSettingValue('MaxNumberEvidenceFilesForSignea');  // Used to store the max number of files per evidence the cutomer is allowed to upload on Contralia

    private static list<Document_A_Signer__c> documents {get;set;}
    private static list<Signataire_Document__c> signataires {get;set;}
    private static list<Parametre_Signature__c> parametres {get;set;}

    private static string source;    // ACCOUNT, PEC, CDS


    // actDom values : gecdom, geb
    // pMode : 0 = Prepare data only | 1 = Prepare data and call WS 
    WebService static string ProcessDataForSignea(string accountId, string pecId, string cdsId, integer pMode) {
        
        string outcomeMessage;
        
        
        isSE = 'true';  // electronic signature
        
        // Check if user has the required permissions to run the Signea process
        if(!Test.isRunningTest()){
            if(VFC_User.isUserAuthorizedToRunSignea(UserInfo.getUserId()) == false){
                System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] : 001-Utilisateur non autorisé à lancer la signature électronique.');
                return '<span style="color: red">- Utilisateur non autorisé à lancer la signature électronique.</span>';
            }
        }

        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] accountId = ' + accountId);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] pecId = ' + pecId);
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] cdsId = ' + cdsId);


        // Get Account
        List<Account> lAccounts = new List<Account>();
        List<PEC__c> lPECs = new List<PEC__c>();
        List<CDS__c> lCDSs = new List<CDS__c>();
        String accId;
        // if circuit launched from the account (for both PEC and CDS)
        if(accountId != null && accountId != ''){
            accId = accountId;
            source = 'ACCOUNT';
        // if circuit launched from the PEC
        }else if(pecId != null && pecId != ''){
            source = 'PEC';
            lPECs = [select Id, Account__c from PEC__c where Id =:pecId limit 1];
            if(!lPECs.isEmpty()){
                accId = lPECs[0].Account__c;
            }
        // if circuit launched from the CDS
        }else if(cdsId != null && cdsId != ''){
            source = 'CDS';
            lCDSs = [select Id, Account__c from CDS__c where Id =:cdsId limit 1];
            if(!lCDSs.isEmpty()){
                accId = lCDSs[0].Account__c;
            }
        }
        lAccounts = [select Id, AccountNumber, Mandataire__c, Mandataire__r.ExternalID__c, Activity_Domain_Simple__c, Mandataire__r.Headquarters_Phone__c, Mandataire__r.Email_Service_Client__c, Mandataire__r.Electronic_Signature_Email__c, Email__c, Country__c, Indicatif_Pays__c, Mobile_Phone_Number__c 
                        from Account where Id =:accId limit 1];

        if(!lAccounts.isEmpty()){
            oAccount = lAccounts[0];
        }else{
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] : 001-Compte non trouvé.');
            return '001-Compte non trouvé.';
        }
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oAccount.Id = ' + oAccount.Id);


        // Load PEC
        //if(pecId != null && pecId != ''){
        if(source=='ACCOUNT' || source=='PEC'){
            lPECToSign = getPECToSign();
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] lPECToSign = ' + lPECToSign);
            if(lPECToSign.size()>0) oPECToSign = lPECToSign[0];
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oPECToSign = ' + oPECToSign);
        }
        
        // Load CDS
        //if(cdsId != null && cdsId != ''){
        if(source=='ACCOUNT' || source=='CDS'){
            lCDSToSign = getCDSToSign();
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] lCDSToSign = ' + lCDSToSign);
            if(lCDSToSign.size()>0) oCDSToSign = lCDSToSign[0];
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oCDSToSign = ' + oCDSToSign);
        }


        
        // Don't go further if an issue is found
        string pbMessageBefore = getIssuesBeforePreparingData();
        if(pbMessageBefore != ''){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] message = ' + pbMessageBefore);
            return pbMessageBefore;
        }
        
        
         
        // Prepare data and optionally call WS depending on pMode parameter
        if(prepareDataForSignea()){
            if(pMode == 1){
                // Ok to call WS
                
                string pbMessageAfter = getIssuesAfterPreparingData();
                if(pbMessageAfter != ''){
                    System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] message = ' + pbMessageAfter);
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
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] Début Création des parametres du circuit');
        Parametre_Signature__c myCircuitParam = new Parametre_Signature__c();
        if(oPECToSign!=null){
            myCircuitParam.Prise_en_Charge__c = oPECToSign.Id;
        }
        if(oCDSToSign!=null){
            myCircuitParam.Controle_des_Stocks__c = oCDSToSign.Id;
        }
        myCircuitParam.Index_AES__c = 'matricule_do=' + oAccount.AccountNumber + ', matricule_pa=' + oAccount.AccountNumber + ', matricule_fa=' + oAccount.AccountNumber + ', orga_comm=' + oAccount.Mandataire__r.ExternalID__c + ', activite=' + oAccount.Activity_Domain_Simple__c.toUpperCase();
        myCircuitParam.Condition_d_acceptation__c = 'J\'ai lu le document et j\'accepte sans réserve les conditions.';
        myCircuitParam.Notification_Createur__c = true;
        if(oPECToSign!=null){
            myCircuitParam.Module__c = 'GEB_CDS_PEC';
        }else if(oCDSToSign!=null){
            myCircuitParam.Module__c = 'GEB_CDS_PEC';
        }
        //myCircuitParam.Notification_additionnelle_generale__c = '';
        myCircuitParam.Notification_additionnelle_generale__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oAccount.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oAccount.Mandataire__r.Email_Service_Client__c;
        Datetime curDT = Datetime.now();
        
        if(oPECToSign!=null){
            string FirstAndLastName = ( (oPECToSign.Contact__r.FirstName == null || oPECToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oPECToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oPECToSign.Contact__r.LastName == null || oPECToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oPECToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            myCircuitParam.Nom_du_circuit__c = FirstAndLastName.left(49) + ' - ' + oAccount.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        }else if(oCDSToSign!=null){
            string FirstAndLastName = ( (oCDSToSign.Contact__r.FirstName == null || oCDSToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCDSToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '')) + ' ' + ( (oCDSToSign.Contact__r.LastName == null || oCDSToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCDSToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            myCircuitParam.Nom_du_circuit__c = FirstAndLastName.left(49) + ' - ' + oAccount.AccountNumber + '(' + curDT.format('dd/MM/yyyy HH:mm') + ')';
        }
        
        insert myCircuitParam;
        
        
        // ============================================
        // Création du conteneur d’étapes et des étapes
        // ============================================
        List<Signataire_Document__c> lSigDoc = new List<Signataire_Document__c>();
        
        //Etape 1 : 1 Signataire client
        Signataire_Document__c mySigner1 = new Signataire_Document__c();
        mySigner1.Numero_du_participant__c = 1;
        mySigner1.Type_de_destinataire__c = 'Visa';   //'Visa'; //'Distance';   //'Face2Face'
        mySigner1.Type_de_signature__c = '';  // 'OTP';   //'PAD'
        mySigner1.Type_de_signataire__c = 'C';
        if(oPECToSign!=null){
            mySigner1.Id_SF_Signataire__c = oPECToSign.Contact__r.Id;
        }else if(oCDSToSign!=null){
            mySigner1.Id_SF_Signataire__c = oCDSToSign.Contact__r.Id;
        }
        //mySigner1.Id_SF_Signataire__c = null;
        // *** The following fields are optional if SFDC Id is provided (not exactly the case anymore, change made by Docapost
        //     If fields are provided, Signea will use their values)
        if(oPECToSign!=null){
            mySigner1.Civilite__c = oPECToSign.Contact__r.Salutation;
            mySigner1.Prenom__c = ( (oPECToSign.Contact__r.FirstName == null || oPECToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oPECToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Name = ( (oPECToSign.Contact__r.LastName == null || oPECToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oPECToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Email__c = oPECToSign.Contact__r.Email;
            mySigner1.Telephone__c = oPECToSign.Contact__r.Country__c == 'FR' ? oPECToSign.Contact__r.MobilePhone : oPECToSign.Contact__r.Indicatif_Pays_c__c + oPECToSign.Contact__r.MobilePhone;
        }else if(oCDSToSign!=null){
            mySigner1.Civilite__c = oCDSToSign.Contact__r.Salutation;
            mySigner1.Prenom__c = ( (oCDSToSign.Contact__r.FirstName == null || oCDSToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCDSToSign.Contact__r.FirstName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Name = ( (oCDSToSign.Contact__r.LastName == null || oCDSToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', '') == '') ? '-' : oCDSToSign.Contact__r.LastName.replaceAll('[^- \'\\p{L}\\p{M}*]', ''));
            mySigner1.Email__c = oCDSToSign.Contact__r.Email;
            mySigner1.Telephone__c = oCDSToSign.Contact__r.Country__c == 'FR' ? oCDSToSign.Contact__r.MobilePhone : oCDSToSign.Contact__r.Indicatif_Pays_c__c + oCDSToSign.Contact__r.MobilePhone;
        }
        // ***
        mySigner1.Etape_de_signature__c = '1-Signature Client';
        mySigner1.Account__c = oAccount.Id;
        if(oPECToSign!=null){
            mySigner1.Prise_en_Charge__c = oPECToSign.Id;
        }
        if(oCDSToSign!=null){
            mySigner1.Controle_des_Stocks__c = oCDSToSign.Id;
        }
        mySigner1.Notification_additionnelle_personnalisee__c = 'Pour toute question, votre Service Clients est à votre disposition au ' +  oAccount.Mandataire__r.Headquarters_Phone__c + ' du lundi au vendredi de 9h à 17h ou par mail : ' + oAccount.Mandataire__r.Email_Service_Client__c;
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
        mySigner2.Account__c = oAccount.Id;
        if(oPECToSign!=null){
            mySigner2.Prise_en_Charge__c = oPECToSign.Id;
        }
        if(oCDSToSign!=null){
            mySigner2.Controle_des_Stocks__c = oCDSToSign.Id;
        }
        mySigner2.Notification_additionnelle_personnalisee__c = '';
        mySigner2.Duree_avant_expiration__c = 20;
        mySigner2.Delai_avant_relance__c = 7;
        mySigner2.position__c = 2;
        
        lSigDoc.add(mySigner2);
        
        
        insert lSigDoc;
        
        
        
        // ============================================
        // Création des documents
        // ============================================        

        if(oPECToSign!=null){
            generatePECPDF();
        }
        if(oCDSToSign!=null){
            generateCDSPDF();
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
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] Création du circuit');
        Signea.Signea_Entities_v2.SigneaCircuit myCircuit = new Signea.Signea_Entities_v2.SigneaCircuit();
        
        
        if(oPECToSign!=null && oCDSToSign!=null){
            myCircuit.description = 'Circuit de signature automatisé associé à la ' + oPECToSign.Name + ' et au ' + oCDSToSign.Name;
        }else if(oPECToSign!=null){
            myCircuit.description = 'Circuit de signature automatisé associé à la ' + oPECToSign.Name;
        }else if(oCDSToSign!=null){
            myCircuit.description = 'Circuit de signature automatisé associé au ' + oCDSToSign.Name;
        }
        myCircuit.name = parametres[0].Nom_du_circuit__c;
        myCircuit.notifyCreator = String.valueOf(parametres[0].Notification_Createur__c);
        myCircuit.keywords = parametres[0].Index_AES__c;
        //Parametrage prévue dans une futur version de SigneA
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
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] signataire.Type_de_signataire__c = ' + signataire.Type_de_signataire__c);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] signataire.Id_SF_Signataire__c = ' + signataire.Id_SF_Signataire__c);
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
                        '<smsCustomMessage>' + System.Label.Signea_SMS_Message_Contract + '</smsCustomMessage>'+
                        //'<emailCustomSubject>Signature de votre Contrat Butagaz - Code OTP</emailCustomSubject>'+
                        //'<emailCustomMessage><![CDATA[<html>Cher Signataire,<br/><br/>Le code OTP nécessaire à la signature de votre contrat Butagaz est : {OTP}</html>]]></emailCustomMessage>'+
                    '</genOtpConfig>'+
                '</config>';
            
            if(null != signataire.Type_de_signature__c) {
                mySigner.participantNumber = integer.valueOf(signataire.Numero_du_participant__c);
            }
            mySigner.position = Integer.ValueOf(signataire.position__c);
            
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
            // Associate circuit with the PEC and/or the CDS
            if(oPECToSign!=null){
                oPECToSign.Signea_Circuit__c = result.result;
                oPECToSign.Signea_Date_Signature__c = null;
                oPECToSign.Statut_circuit_de_signature__c = '';
                update oPECToSign;
            }
            if(oCDSToSign!=null){
                oCDSToSign.Signea_Circuit__c = result.result;
                oCDSToSign.Signea_Date_Signature__c = null;
                oCDSToSign.Statut_circuit_de_signature__c = '';
                update oCDSToSign;
            }


            // Associate circuit with the account
            String where_clause = '';
            
            if(oPECToSign!=null){
                where_clause = 'where Id = \'' + oPECToSign.Signea_Circuit__c + '\'';
            }else if(oCDSToSign!=null){
                where_clause = 'where Id = \'' + oCDSToSign.Signea_Circuit__c + '\'';
            }
            Signea__Circuit__c oCircuit = (Signea__Circuit__c)Database.query('select Id, Name, AccountBTZ__c from Signea__Circuit__c ' + where_clause + ' LIMIT 1');
            //Signea__Circuit__c oCircuit = [ select Id, Name, AccountBTZ__c from Signea__Circuit__c where Id = :oPECToSign.Signea_Circuit__c or Id = :oCDSToSign.Signea_Circuit__c LIMIT 1 ];
            if(oCircuit!=null){
                oCircuit.AccountBTZ__c = oAccount.Id;
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
    

    public static List<PEC__c> getPECToSign(){
        List<PEC__c> lPEC = new List<PEC__c>();
        
        lPEC = [SELECT Id, Name, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c, Signea_Raison_Refus_Signature__c, Contact__r.Id, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Country__c, Contact__r.MobilePhone, Contact__r.Indicatif_Pays_c__c 
                                FROM PEC__c WHERE Account__c =: oAccount.Id AND Status__c = 'Attente de signature'];

        return lPEC;
    }


    /** Generate PEC PDF file **/ 
    //public static void generatePECPDF(PEC__c pPEC) {
    public static void generatePECPDF() {
        
        //oPECToSign = getPECToSign();
        if(oPECToSign!=null){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oPECToSign.Id = ' + oPECToSign.Id);
            PageReference pdfPage = Page.VFP_PriseEnChargePDF;
            pdfPage.getParameters().put('id', oPECToSign.Id);
            //pdfPage.getParameters().put('isSE', isSE);
            pdfPage.getParameters().put('isSE', 'true');
            pdfPage.getParameters().put('displayCGUSE', 'true');
            pdfPage.getParameters().put('withdrawalText', 'false');
            pdfPage.getParameters().put('nbSig', '3');
            
            // getContent not supported in Test Methods, so we need to handle it
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
            
            
            // Document
            Document oDoc = New Document();
            oDoc.Name = 'Prise en charge-' + oPECToSign.Name;
            oDoc.Body = pdfBlob;
            oDoc.Type = 'pdf';
            oDoc.FolderId = sFolderId;
            oDoc.Description = oPECToSign.Id;
            insert oDoc;
            
            // Document_A_Signer__c
            Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
            oDocASigner.Id_SF_Document__c = oDoc.Id;
            oDocASigner.Name = 'Prise en charge-' + oPECToSign.Name;
            oDocASigner.Type_de_document__c = 'Document';
            oDocASigner.Prise_en_Charge__c = oPECToSign.Id;
            //oDocASigner.Identifiant_OPTL__c = oOPTL.Id;
            insert oDocASigner;
            
            // Zone_De_Remplissage__c
            List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
            
            // Signature
            // Signature
            //BDJ - Debut - Si visa pas de signature
            /*
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
            */
            //BDJ - Debut - Si visa pas de signature
            
            // Visa client
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 0;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'TEXT';
            tag1.Name = 'Name_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 37;
            tag1.Position_Y__c = 408;
            tag1.Largeur__c = 148;
            tag1.Hauteur__c = 110;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = oPECToSign.Contact__r.FirstName + ' ' + oPECToSign.Contact__r.LastName;
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

    }

    /** Method to check if there is a CDS available to add to the documents **/
    public static List<CDS__c> getCDSToSign(){
        List<CDS__c> lCDS = new List<CDS__c>();

        lCDS = [SELECT Id, Name, Signea_Circuit__c, Signea_Date_Signature__c, Statut_circuit_de_signature__c, Signea_Raison_Refus_Signature__c, Contact__r.Id, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Country__c, Contact__r.MobilePhone, Contact__r.Indicatif_Pays_c__c 
                    FROM CDS__c WHERE Account__c =: oAccount.Id AND Status__c = 'Attente de signature' ]; // LIMIT 1 MLC 20171017 suppression LIMIT

        return lCDS;
    }
    


    /** Generate PEC PDF file **/ 
    //public static void generatePECPDF(PEC__c pPEC) {
    public static void generateCDSPDF() {
        
        //oCDSToSign = getCDSToSign();
        if(oCDSToSign!=null){
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oCDSToSign = ' + oCDSToSign);
            System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] oCDSToSign.Id = ' + oCDSToSign.Id);
            PageReference pdfPage = Page.VFP_ControleDesStocksPDF;
            pdfPage.getParameters().put('id', oCDSToSign.Id);
            pdfPage.getParameters().put('isSE', isSE);
            //String displayCGUSE = oPECToSign!=null ? 'false' : 'true';
            //pdfPage.getParameters().put('displayCGUSE', displayCGUSE);
            pdfPage.getParameters().put('displayCGUSE', 'true');
            pdfPage.getParameters().put('withdrawalText', 'false');
            //if(oPECToSign!=null){   // if both documents, the 3 signature blocks will go on the PEC, otherwise on the CDS
            //  pdfPage.getParameters().put('nbSig', '1');
            //}else{
                pdfPage.getParameters().put('nbSig', '3');
            //}

            
            // getContent not supported in Test Methods, so we need to handle it
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
            
            
            // Document
            Document oDoc = New Document();
            oDoc.Name = 'Controle de stock-' + oCDSToSign.Name;
            oDoc.Body = pdfBlob;
            oDoc.Type = 'pdf';
            oDoc.FolderId = sFolderId;
            oDoc.Description = oCDSToSign.Id;
            insert oDoc;
            
            // Document_A_Signer__c
            Document_A_Signer__c oDocASigner = new Document_A_Signer__c();
            oDocASigner.Id_SF_Document__c = oDoc.Id;
            oDocASigner.Name = 'Controle de stock-' + oCDSToSign.Name;
            oDocASigner.Type_de_document__c = 'Document';
            oDocASigner.Controle_des_Stocks__c = oCDSToSign.Id;
            //oDocASigner.Identifiant_OPTL__c = oOPTL.Id;
            insert oDocASigner;
            
            // Zone_De_Remplissage__c
            List<Zone_De_Remplissage__c> lTag = new List<Zone_De_Remplissage__c>();
            
            // Signature
            // Signature
            Zone_De_Remplissage__c tag1 = new Zone_De_Remplissage__c();
            tag1.Identifiant_document__c = oDocASigner.Id;
            tag1.Numero_Participant__c = 0;
            tag1.Description__c = '';
            tag1.Type_de_remplissage__c = 'TEXT';
            tag1.Name = 'Name_1';
            tag1.Page__c = -1;
            tag1.Position_X__c = 37;
            tag1.Position_Y__c = 408;
            tag1.Largeur__c = 148;
            tag1.Hauteur__c = 110;
            tag1.Taille_de_la_police__c = FONT_SIZE;
            tag1.Obligatoire__c = false;
            tag1.Valeur_preremplie__c = oCDSToSign.Contact__r.FirstName + ' ' + oCDSToSign.Contact__r.LastName;
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

    }
    
    
    /** Checking issues for first step **/
    public static String getIssuesBeforePreparingData(){
        string pbCode = '';
        boolean missingTel = false;
        boolean missingEmail = false;
        
        
        // Check PEC and/or CDS has not already been signed
        // /!\ To modify : we never enter this condition because the list is empty if no PEC in the correct status
        /*if(source == 'PEC'){
            if(lPECToSign.size() > 0 && oPECToSign.Signea_Date_Signature__c != null) {
                pbCode += '- Prise en Charge déjà signée.' + '<br>';
            }
        }
        if(source == 'CDS'){
            if(lCDSToSign.size() > 0 && oCDSToSign.Signea_Date_Signature__c != null) {
                pbCode += '- Contrôle de Stock déjà signé.' + '<br>';
            }
        }*/

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

        // Check mobile phone isn't blank
        // 20190307 : Removing this control because we're not doing OTP anymore for PEC and CDS SE so we don't need a mobile phone to send the text message to. 
        /*if(source == 'ACCOUNT' || source == 'PEC'){
            if(lPECToSign.size() > 0 && (oPECToSign.Contact__r.MobilePhone == null || oPECToSign.Contact__r.MobilePhone == '')){
                missingTel = true;
            }
        }
        if(source == 'ACCOUNT' || source == 'CDS'){
            if(lCDSToSign.size() > 0 && (oCDSToSign.Contact__r.MobilePhone == null || oCDSToSign.Contact__r.MobilePhone == '')){
                missingTel = true;
            }
        }
        if(missingTel) pbCode += '- Téléphone mobile du contact non-renseigné.' + '<br>';*/

        // Check email isn't blank
        if(source == 'ACCOUNT' || source == 'PEC'){
            if(lPECToSign.size() > 0 && (oPECToSign.Contact__r.Email == null || oPECToSign.Contact__r.Email == '')){
                missingEmail = true;
            }
        }
        if(source == 'ACCOUNT' || source == 'CDS'){
            if(lCDSToSign.size() > 0 && (oCDSToSign.Contact__r.Email == null || oCDSToSign.Contact__r.Email == '')){
                missingEmail = true;
            }
        }
        if(missingEmail) pbCode += '- Adresse e-mail du contact non-renseignée.' + '<br>';

        // Check PEC and/or CDS are there
        if(source == 'ACCOUNT' || source == 'PEC'){
            if(lPECToSign != null && lPECToSign.isEmpty()){
                pbCode += '- Pas de Prise en Charge en attente de signature pour ce compte.' + '<br>';
            }else if(lPECToSign != null && lPECToSign.size() > 1){
                pbCode += '- Plusieurs Prises en Charge en attente de signature pour ce compte.' + '<br>';
            }
        }
        if(source == 'ACCOUNT' || source == 'CDS'){
            if(lCDSToSign != null && lCDSToSign.isEmpty()){
                pbCode += '- Pas de Contrôle de Stock en attente de signature pour ce compte.' + '<br>';
            }else if(lCDSToSign != null && lCDSToSign.size() > 1){
                pbCode += '- Plusieurs Contrôles de Stock en attente de signature pour ce compte.' + '<br>';
            }
        }

        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez corriger ces anomalies afin de pouvoir lancer le circuit de signature.';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    /** Checking issues for second step **/
    public static String getIssuesAfterPreparingData(){
        
        string pbCode = '';
        String where_clause = '';
        String where_clausePEC = '';
        String where_clauseCDS = '';
        
        if(oPECToSign!=null){
            where_clausePEC = 'where Prise_en_Charge__c = \'' + oPECToSign.Id + '\'';
        }
        if(oCDSToSign!=null){
            if(where_clausePEC==''){
                where_clauseCDS = ' where Controle_des_Stocks__c = \'' + oCDSToSign.Id + '\'';
            }else{
                where_clauseCDS = ' or Controle_des_Stocks__c = \'' + oCDSToSign.Id + '\'';
            }
        }
        where_clause = where_clausePEC + where_clauseCDS;
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] where_clause = ' + where_clause);
        
        //if( oQuote.Signea_Circuit__c != null ) {
            //List<Signea__Circuit__c> myCircuits = [select id, name, signea__status__c from Signea__Circuit__c where id = :oQuote.Signea_Circuit__c ];   
            //if( myCircuits != null && myCircuits.size() > 0 ) {
                //if( myCircuits[0].signea__status__c != 'Refused' && myCircuits[0].signea__status__c != 'Expired' && myCircuits[0].signea__status__c != 'Cancelled' && myCircuits[0].signea__status__c != 'Launch Failed' ) {
                    //pbCode += '- Un circuit est déjà en cours de signature.' + '<br>';
                //}
            //}
        //}
        
        // Controle des documents à signer
        documents = (List<Document_A_Signer__c>)Database.query('select id, Id_SF_Document__c, Name, Type_de_document__c from Document_A_Signer__c ' + where_clause);
        //documents = [select id, Id_SF_Document__c, Name, Type_de_document__c from Document_A_Signer__c where devis__c = :oQuote.Id ];
        if( documents == null || documents.size() == 0 ) {
            pbCode += '- Aucun document dans le devis.' + '<br>';
        }
        
        // Controle des signataires
        signataires = (List<Signataire_Document__c>)Database.query('select id, position__c, Delai_avant_relance__c, Type_de_signataire__c, Id_SF_Signataire__c, Duree_avant_expiration__c, Email__c, Telephone__c, Civilite__c, Name, Prenom__c, Numero_du_participant__c, Etape_de_signature__c, Type_de_destinataire__c, Type_de_signature__c, Notification_additionnelle_personnalisee__c from Signataire_Document__c ' + where_clause + ' order by Etape_de_signature__c asc');
        //signataires = [select id, position__c, Delai_avant_relance__c, Type_de_signataire__c, Id_SF_Signataire__c, Duree_avant_expiration__c, Email__c, Telephone__c, Civilite__c, Name, Prenom__c, Numero_du_participant__c, Etape_de_signature__c, Type_de_destinataire__c, Type_de_signature__c, Notification_additionnelle_personnalisee__c from Signataire_Document__c where devis__c = :oQuote.Id order by Etape_de_signature__c asc ];
        system.Debug('\n\n===> signataires : ' +  signataires  + '\n\n');
        if( signataires == null || signataires.size() == 0 ) {
            pbCode += '- Aucun signataire dans le devis.' + '<br>';
        }
        
        // Controle des paramètres de signature
        parametres = (List<Parametre_Signature__c>)Database.query('select id, Module__c, Nom_du_circuit__c, Index_AES__c, Condition_d_acceptation__c, Notification_Createur__c, Notification_additionnelle_generale__c from Parametre_Signature__c ' + where_clause);
        //parametres = [select id, Module__c, Nom_du_circuit__c, Index_AES__c, Condition_d_acceptation__c, Notification_Createur__c, Notification_additionnelle_generale__c from Parametre_Signature__c where devis__c = :oQuote.Id ];
        if( parametres == null || parametres.size() == 0 ) {
            pbCode += '- Aucun paramètre de signature.' + '<br>';
        }
        
        //if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>Veuillez contacter l\'administrateur de l\'application.';
        if(pbCode!='') pbCode = '<span style="color: red">' + pbCode + '</span><br>';
        
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] pbCode = ' + pbCode);
        return pbCode;
        
    }
    
    
    
    /** Delete records linked to current quote from Signea objects and Documents **/
    public static void deleteRecords(){
        String where_clause = '';
        String where_clausePEC = '';
        String where_clauseCDS = '';
        
        if(oPECToSign!=null){
            where_clausePEC = 'where Prise_en_Charge__c = \'' + oPECToSign.Id + '\'';
        }
        if(oCDSToSign!=null){
            if(where_clausePEC==''){
                where_clauseCDS = ' where Controle_des_Stocks__c = \'' + oCDSToSign.Id + '\'';
            }else{
                where_clauseCDS = ' or Controle_des_Stocks__c = \'' + oCDSToSign.Id + '\'';
            }
        }
        where_clause = where_clausePEC + where_clauseCDS;
        System.debug(logginglevel.WARN,'### [VFC_ProcessDataForSigneaFromPECandCDS.ProcessDataForSignea] where_clause = ' + where_clause);
        
        
        /*List<Signea__Circuit__c> lSigneaCircuit = [select Id from Signea__Circuit__c where Id =:oQuote.Signea_Circuit__c];
        delete lSigneaCircuit;*/
        Signea.Signea_Entities_V2.SigneaServicesResult result;
        if(oPECToSign!=null){
            result = Signea.Signea_API_V2.deleteCircuit(oPECToSign.Signea_Circuit__c);
        }else if(oCDSToSign!=null){
            result = Signea.Signea_API_V2.deleteCircuit(oCDSToSign.Signea_Circuit__c);
        }
        
        List<Parametre_Signature__c> lParametreSignature = (List<Parametre_Signature__c>)Database.query('select Id from Parametre_Signature__c ' + where_clause);
        //List<Parametre_Signature__c> lParametreSignature = [select Id from Parametre_Signature__c where Prise_en_Charge__c =:oPECToSign.Id or Controle_des_Stocks__c =:oCDSToSign.Id];
        delete lParametreSignature;
        
        List<Signataire_Document__c> lSignataireDocument = (List<Signataire_Document__c>)Database.query('select Id from Signataire_Document__c ' + where_clause);
        //List<Signataire_Document__c> lSignataireDocument = [select Id from Signataire_Document__c where Prise_en_Charge__c =:oPECToSign.Id or Controle_des_Stocks__c =:oCDSToSign.Id];
        delete lSignataireDocument;
        
        List<Piece_Justificative__c> lPieceJustificative = (List<Piece_Justificative__c>)Database.query('select Id from Piece_Justificative__c ' + where_clause);
        //List<Piece_Justificative__c> lPieceJustificative = [select Id from Piece_Justificative__c where Prise_en_Charge__c =:oPECToSign.Id or Controle_des_Stocks__c =:oCDSToSign.Id];
        delete lPieceJustificative;
        
        // Delete Docs et DocsSignea
        List<Document_A_Signer__c> lDocumentASigner = (List<Document_A_Signer__c>)Database.query('select Id, Id_SF_Document__c from Document_A_Signer__c ' + where_clause);
        //List<Document_A_Signer__c> lDocumentASigner = [select Id, Id_SF_Document__c from Document_A_Signer__c where Prise_en_Charge__c =:oPECToSign.Id or Controle_des_Stocks__c =:oCDSToSign.Id];
        
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
        
        // Update PEC and/or CDS fields
        if(oPECToSign!=null){
            oPECToSign.Statut_circuit_de_signature__c = '';
            oPECToSign.Signea_Date_Signature__c = null;
            oPECToSign.Signea_Raison_Refus_Signature__c = '';
            oPECToSign.Signea_Circuit__c = null;
            update oPECToSign;
        }
        if(oCDSToSign!=null){
            oCDSToSign.Statut_circuit_de_signature__c = '';
            oCDSToSign.Signea_Date_Signature__c = null;
            oCDSToSign.Signea_Raison_Refus_Signature__c = '';
            oCDSToSign.Signea_Circuit__c = null;
            update oCDSToSign;
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