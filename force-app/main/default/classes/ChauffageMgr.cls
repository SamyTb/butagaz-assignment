public class ChauffageMgr {
    
    public Account oAccountSource {get; set;}
    public Account oAccountTarget {get; set;}
    public Project__c oProject {get; set;}
    public Boolean showForm {get; set;}

    public string selectedPostalCode {get; set;}
    private Project_Subcontractor__c oSubcontractor {get; set;}
    public String subcontractorName {get; set;}

    public Chauffage_API_Settings__mdt cChauffageAPI {get; set;}
    public Chauffage_CalloutMgr.apiResponse apiResponseToProcess {get;set;}
    public String APIToken {get; set;}
    public Boolean isCustomerEligible {get; set;}
    public Map<String, Object> mapTimeSlots {get; set;}
    public Boolean dataSentToPartner {get; set;}

    public Chauffage_CalloutMgr.projectData oProjectData {get; set;}

    public List<SelectOption> lstTimeSlots {get; set;}
    public String selectedTimeSlot {get; set;}

    public Boolean hasError {get; set;}

    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','Sélectionner un article'));
        options.add(new SelectOption('11','Chaudière gaz'));
        options.add(new SelectOption('142','Pompe à chaleur'));
        return options;
    }
    
    public String getPriceCode() {
        String priceCode = '';
        
        System.debug(logginglevel.WARN,'### oProject.Type_of_Technology__c = ' + oProject.Type_of_Technology__c);
        System.debug(logginglevel.WARN,'### oProject.Housing_Type__c = ' + oProject.Housing_Type__c);
        System.debug(logginglevel.WARN,'### oProject.Housing_Over_2_Years__c = ' + oProject.Housing_Over_2_Years__c);
        if( String.isBlank(oProject.Type_of_Technology__c) || String.isBlank(oProject.Housing_Type__c) ) return '';

        if(oProject.Product__c == '11'){
            if( oProject.Type_of_Technology__c == '14' && (!oAccountSource.IsPersonAccount || oProject.Housing_Type__c == 'local pro' || !oProject.Housing_Over_2_Years__c) ){
                priceCode = 'P1';
            }else if ( oProject.Type_of_Technology__c != '14' && (!oAccountSource.IsPersonAccount || oProject.Housing_Type__c == 'local pro' || !oProject.Housing_Over_2_Years__c) ){
                priceCode = 'P2';
            }else{
                priceCode = 'P3';
            }
        }else if(oProject.Product__c == '142'){
            if( (oProject.Type_of_Technology__c == '16' || oProject.Type_of_Technology__c == '17') && (!oAccountSource.IsPersonAccount || oProject.Housing_Type__c == 'local pro' || !oProject.Housing_Over_2_Years__c) ){
                priceCode = 'P1';
            }else{
                priceCode = 'P2';
            }
        }
        // Update price code on project
        oProject.Price_Code__c = priceCode;
        System.debug(logginglevel.WARN,'### priceCode = ' + priceCode);
        
        return priceCode;
    }
    

    public ChauffageMgr(ApexPages.standardcontroller stdController) {

        this.showForm = true;
        this.hasError = false;

        // Retrieve current account information
        this.oAccountSource = [
            SELECT Id, Name, isPersonAccount, Street_N__c, Street_type__c, Street_name__c, Postal_Code__c, City_Postal_Code__r.Postal_Code__c, City_Postal_Code__r.City__r.Name,
                    PersonContactId, Activity_Domain__c, AccountNumber, Salutation, LastName, FirstName, Email__c, Salutation__c, Phone, Type_de_relation__c, 
                    Indicatif_Pays__c, Mobile_Phone_Number__c, FCC_Mobile_Phone_Number__c, Activity_Domain__r.ExternalID__c, Mandataire__r.ExternalID__c
            FROM Account
            WHERE Id=:stdController.getRecord().Id
        ];
        System.debug(logginglevel.WARN,'### this.oAccountSource = ' + this.oAccountSource);

        this.oAccountTarget = new Account();
        //this.oAccountTarget.Name = this.oAccountSource.Name;
        this.oAccountTarget.Salutation = this.oAccountSource.Salutation;
        this.oAccountTarget.LastName = this.oAccountSource.LastName;
        this.oAccountTarget.FirstName = this.oAccountSource.FirstName;
        this.oAccountTarget.Email__c = this.oAccountSource.Email__c;
        this.oAccountTarget.Indicatif_Pays__c = this.oAccountSource.Indicatif_Pays__c;
        this.oAccountTarget.Phone = this.oAccountSource.Phone;
        this.oAccountTarget.Mobile_Phone_Number__c = this.oAccountSource.Mobile_Phone_Number__c;
        this.oAccountTarget.Mandataire__c = this.oAccountSource.Mandataire__c;
        this.oAccountTarget.Street_N__c = this.oAccountSource.Street_N__c;
        this.oAccountTarget.Street_type__c = this.oAccountSource.Street_type__c;
        this.oAccountTarget.Street_name__c = this.oAccountSource.Street_name__c;
        this.oAccountTarget.City_Postal_Code__c = this.oAccountSource.City_Postal_Code__c;

        this.oProject = new Project__c();
        oProject.Project_Status__c = '7';
        oProject.GARANKA_Contract_Type__c = '82';
        oProject.Project_Street_Number__c = this.oAccountSource.Street_N__c;
        oProject.Project_Street_Type__c = this.oAccountSource.Street_type__c;
        oProject.Project_Street_name__c = this.oAccountSource.Street_name__c;
        oProject.Project_City_Postal_Code__c = this.oAccountSource.City_Postal_Code__c;

        // Initialize object that will hold the values to pass to the partner
        oProjectData = new Chauffage_CalloutMgr.projectData();

        selectedPostalCode = (this.oAccountSource.City_Postal_Code__c == null ? '' : this.oAccountSource.City_Postal_Code__r.Postal_Code__c);
        //selectedProduct = '';

    }
    
    public void validatePostalCode() {
        ApexPages.getMessages().clear();
        
        if( !String.isBlank(selectedPostalCode) && selectedPostalCode.length() == 5 && !String.isBlank(oProject.Product__c) && oProject.Product__c != null ){
            oSubcontractor = new Project_Subcontractor__c();
            oSubcontractor = ProjectMgr.getSubcontractor('Chauffage', selectedPostalCode.substring(0,2));
            
            if( oSubcontractor == null || String.isBlank(oSubcontractor.Name) ){
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Aucun partenaire trouvé pour le code postal demandé.'));
            }else{
                this.hasError = false;
                subcontractorName = oSubcontractor.Name;
                cChauffageAPI = getChauffageAPISettings(oSubcontractor.Name);
            }
        }else{
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez saisir un code postal correct et sélectionner un article.'));
        }
    }

    public void validateData() {
        ApexPages.getMessages().clear();
        this.hasError = false;
        
        if(! oProject.Resident__c){
            if( String.isBlank(oProject.Renter_Salutation__c) || String.isBlank(oProject.Renter_Last_Name__c) || String.isBlank(oProject.Renter_First_Name__c) || String.isBlank(oProject.Renter_Email__c) || String.isBlank(oProject.Renter_Phone__c) ){
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner les informations du locataire.'));
            }
        }

        if( String.isBlank(oProject.Project_Street_Number__c) || String.isBlank(oProject.Project_Street_Type__c) || String.isBlank(oProject.Project_Street_name__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner l\'adresse du projet.'));
        }

        if( String.isBlank(oAccountTarget.Salutation) || String.isBlank(oAccountTarget.Email__c) || ( String.isBlank(oAccountTarget.Phone) && String.isBlank(oAccountTarget.Mobile_Phone_Number__c) )
            || String.isBlank(oAccountTarget.Street_N__c) || String.isBlank(oAccountTarget.Street_type__c) || String.isBlank(oAccountTarget.Street_name__c) || String.isBlank(oAccountTarget.City_Postal_Code__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner les informations de facturation.'));
        }
        
        /*if( String.isBlank(oProject.Client_Type__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un type de client.'));
        }*/
        if( String.isBlank(oProject.Housing_Type__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un type de logement.'));
        }
        if( String.isBlank(oProject.Device_Type__c) && oProject.Product__c != '142' ){ // Device type not mandatory for product 142 (PAC)
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un type d\'appareil.'));
        }
        if( String.isBlank(oProject.Type_of_Technology__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un type de technologie.'));
        }
        if( String.isBlank(oProject.GARANKA_Device_Brand__c) && cChauffageAPI.DeveloperName == 'GARANKA' ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner une marque d\'appareil.'));
        }
        if( String.isBlank(oProject.Estimated_Age_Of_Device__c) ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner l\'âge de l\'appareil.'));
        }
        // TimeSlot isn't mandatory anymore
        /*if( (String.isBlank(selectedTimeSlot) || selectedTimeSlot == '0') && cChauffageAPI.DeveloperName == 'GARANKA' ){
            this.hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un créneau de rendez-vous.'));
        }*/
    }

    public void getAPIToken() {
        System.debug(logginglevel.WARN,'### cChauffageAPI = ' + cChauffageAPI);
        
        if( !this.hasError ) {
            apiResponseToProcess = Chauffage_CalloutMgr.callGetToken(cChauffageAPI);
            if(!apiResponseToProcess.hasError){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Token : ' + apiResponseToProcess.successMessage));
                this.hasError = false;
                APIToken = apiResponseToProcess.successMessage;
            }else{
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, apiResponseToProcess.errorMessage));
            }
        }
        System.debug(logginglevel.WARN,'### APIToken = ' + APIToken);
    }

    public void getEligibility() {
        System.debug(logginglevel.WARN,'### getEligibility ApexPages.hasMessages() = ' + ApexPages.hasMessages(ApexPages.Severity.ERROR));
        
        if( !this.hasError ) {
            apiResponseToProcess = Chauffage_CalloutMgr.callGetEligibility(cChauffageAPI, APIToken, selectedPostalCode, oProject.Product__c);
            if(!apiResponseToProcess.hasError){
                isCustomerEligible = (apiResponseToProcess.successMessage == 'true');
                if(isCustomerEligible){
                    this.hasError = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Eligible à l\'offre entretien chauffage du partenaire ' + cChauffageAPI.DeveloperName));
                }else{
                    this.hasError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Non éligible à l\'offre entretien chauffage'));
                }
            }
        }
        System.debug(logginglevel.WARN,'### isCustomerEligible = ' + isCustomerEligible);
    }

    public void getBookingTimeSlots() {
        
        if( !this.hasError && isCustomerEligible ) {
            if( cChauffageAPI.DeveloperName == 'GARANKA' ) {
                mapTimeSlots = Chauffage_CalloutMgr.callGetBookingTimeSlots(cChauffageAPI, APIToken, selectedPostalCode);

                lstTimeSlots = new List<SelectOption>();
                lstTimeSlots.add(new SelectOption('0','Sélectionner un créneau'));
                if( mapTimeSlots != null ){
                    for(String key : mapTimeSlots.keyset()) {
                        // Dates are stored in map keys
                        System.debug('Key : ' + key);

                        // Hours are stored in map list of values under hour node
                        List<Object> hours = (List<Object>) mapTimeSlots.get(key);
                        for( Object oHour : hours ) {
                            lstTimeSlots.add(new SelectOption(key + ' ' + oHour, key + ' ' + oHour));
                        }
                    }
                }
                System.debug('>>> lstTimeSlots = ' + lstTimeSlots); 
            }
            // Messages added here otherwise it gets overwritten by the Ajax refresh
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Eligible à l\'offre entretien chauffage du partenaire ' + cChauffageAPI.DeveloperName));
        }
        
    }

    public void postData() {

        String responseFromPartner;
        
        if( !this.hasError && isCustomerEligible && !oProject.Sent_To_External_Partner__c ) {
            /*
            oProjectData.id_lead_source = 'TESTELC1';
            oProjectData.affilieur = 'BUTAGAZ';
            oProjectData.id_prod = 11;
            oProjectData.id_contrat = 82;
            oProjectData.code_postal = '78000';
            oProjectData.statut = 'part';
            oProjectData.batiment = 'appartement';
            oProjectData.age = 'p2'; // Convert values to GARANKA expected values (m2 / p2)
            oProjectData.app = 84;
            oProjectData.techno = 'NSP';
            oProjectData.marque = 28;
            oProjectData.age_appareil = 1;
            oProjectData.code_prix = 'P2';
            oProjectData.promo = '';
            oProjectData.date_visite = '01-12-2020';
            oProjectData.creneau_visite = '8h - 12h';
            oProjectData.clt_situation = 'resident';
            oProjectData.clt_position = 'proprio';
            oProjectData.clt_civ = 'M.';
            oProjectData.clt_nom = 'LE CAER';
            oProjectData.clt_prenom = 'Erwan';
            oProjectData.clt_email = 'erwan.lecaer@butagaz.com';
            oProjectData.clt_telephone = '0611959221';
            oProjectData.clt_adresse = '47 rue Raspail';
            oProjectData.clt_adresse_cpl = '';
            oProjectData.clt_adresse_cpl2 = '';
            oProjectData.clt_cp = '78000';
            oProjectData.clt_ville = 'Levallois Perret';
            oProjectData.fct_civ = 'Mme';
            oProjectData.fct_nom = 'Muche';
            oProjectData.fct_prenom = 'Truc';
            oProjectData.fct_email = 'truc.muche@butagaz.fr';
            oProjectData.fct_telephone = '0101010101';
            oProjectData.fct_adresse = 'Addresse2';
            oProjectData.fct_adresse_cpl = '';
            oProjectData.fct_adresse_cpl2 = '';
            oProjectData.fct_cp = '92600';
            oProjectData.fct_ville = 'Asnières sur Seine';
            */
            
            oProjectData.id_lead_source = oProject.Name;
            oProjectData.affilieur = 'BUTAGAZ';
            oProjectData.id_prod = (String.isBlank(oProject.Product__c) ? null : integer.valueOf(oProject.Product__c));
            if( cChauffageAPI.DeveloperName == 'GARANKA' ){
                oProjectData.id_contrat = (String.isBlank(oProject.GARANKA_Contract_Type__c) ? null : integer.valueOf(oProject.GARANKA_Contract_Type__c));
            }else if( cChauffageAPI.DeveloperName == 'MENERGIES' ){
                oProjectData.id_contrat = 0;  // No values given for MEnergies
            }
            oProjectData.code_postal = (String.isBlank(selectedPostalCode) ? '' : selectedPostalCode);
            oProjectData.statut = (oAccountTarget.IsPersonAccount ? 'part' : 'pro'); // Convert values to GARANKA expected values (part / pro)
            oProjectData.batiment = (oProject.Housing_Type__c == 'House' ? 'maison' : 'appartement');
            oProjectData.age = (oProject.Housing_Over_2_Years__c ? 'p2' : 'm2'); // Convert values to GARANKA expected values (m2 / p2)
            oProjectData.app = (String.isBlank(oProject.Device_Type__c) ? null : integer.valueOf(oProject.Device_Type__c));
            oProjectData.techno = oProject.Type_of_Technology__c;
            if( cChauffageAPI.DeveloperName == 'GARANKA' ){
                oProjectData.marque = (String.isBlank(oProject.GARANKA_Device_Brand__c) ? null : oProject.GARANKA_Device_Brand__c);  // integer.valueOf(oProject.GARANKA_Device_Brand__c)
            }else if( cChauffageAPI.DeveloperName == 'MENERGIES' ){
                if(oProject.GARANKA_Device_Brand__c.toUpperCase() == 'AUTRE'){
                    oProjectData.marque = '0';
                }else{
                    oProjectData.marque = (String.isBlank(oProject.GARANKA_Device_Brand__c) ? null : oProject.GARANKA_Device_Brand__c);  // integer.valueOf(oProject.GARANKA_Device_Brand__c)
                }
            }
            oProjectData.age_appareil = (String.isBlank(oProject.Estimated_Age_Of_Device__c) ? null : integer.valueOf(oProject.Estimated_Age_Of_Device__c));
            oProjectData.code_prix = oProject.Price_Code__c; //sPriceCode;
            oProjectData.promo = '';
            if( cChauffageAPI.DeveloperName == 'GARANKA' ){
                oProjectData.date_visite = oProject.GARANKA_Date_Of_Visit__c;
            }else if( cChauffageAPI.DeveloperName == 'MENERGIES' ){
                oProjectData.date_visite = '2020-11-19T08:20:05.483Z';  // MEnergies doesn't manage this field and just expects a date to be sent to match the datatype
            }
            oProjectData.creneau_visite = oProject.GARANKA_Time_Of_Visit__c;
            oProjectData.clt_situation = (oProject.Resident__c ? 'resident' : 'non-resident');
            oProjectData.clt_position = (oProject.Client_Type__c == 'Owner' ? 'proprio' : 'locataire');
            
            if(oProject.Resident__c){
                // Project customer
                oProjectData.clt_civ = (String.isBlank(oAccountTarget.Salutation) ? null : oAccountTarget.Salutation);
                oProjectData.clt_nom = (String.isBlank(oAccountTarget.LastName) ? null : oAccountTarget.LastName);
                oProjectData.clt_prenom = (String.isBlank(oAccountTarget.FirstName) ? null : oAccountTarget.FirstName);
                oProjectData.clt_email = (String.isBlank(oAccountTarget.Email__c) ? null : oAccountTarget.Email__c);
                if(!String.isBlank(oAccountTarget.Phone)){
                    oProjectData.clt_telephone = oAccountTarget.Phone;
                } else if(!String.isBlank(oAccountTarget.Mobile_Phone_Number__c)){
                    oProjectData.clt_telephone = oAccountTarget.Mobile_Phone_Number__c;
                } else {
                    oProjectData.clt_telephone = '';
                }
                oProjectData.clt_adresse = oProject.Project_Street_Number__c + ' ' + oProject.Project_Street_Type__c + ' ' + oProject.Project_Street_name__c;
                oProjectData.clt_adresse_cpl = '';
                oProjectData.clt_adresse_cpl2 = '';
                oProjectData.clt_cp = (oProject.Project_City_Postal_Code__r.Postal_Code__c == null) ? '' : oProject.Project_City_Postal_Code__r.Postal_Code__c; //oAccountTarget.City_Postal_Code__r.Postal_Code__c
                oProjectData.clt_ville = (oProject.Project_City_Postal_Code__r.City__r.Name == null) ? '' : oProject.Project_City_Postal_Code__r.City__r.Name; //oAccountTarget.City_Postal_Code__r.City__r.Name
            }else{
                // Project customer
                oProjectData.clt_civ = (String.isBlank(oProject.Renter_Salutation__c) ? null : oProject.Renter_Salutation__c);
                oProjectData.clt_nom = (String.isBlank(oProject.Renter_Last_Name__c) ? null : oProject.Renter_Last_Name__c);
                oProjectData.clt_prenom = (String.isBlank(oProject.Renter_First_Name__c) ? null : oProject.Renter_First_Name__c);
                oProjectData.clt_email = (String.isBlank(oProject.Renter_Email__c) ? null : oProject.Renter_Email__c);
                if(!String.isBlank(oProject.Renter_Phone__c)){
                    oProjectData.clt_telephone = oProject.Renter_Phone__c;
                } else {
                    oProjectData.clt_telephone = '';
                }
                oProjectData.clt_adresse = oProject.Project_Street_Number__c + ' ' + oProject.Project_Street_Type__c + ' ' + oProject.Project_Street_name__c;
                oProjectData.clt_adresse_cpl = '';
                oProjectData.clt_adresse_cpl2 = '';
                oProjectData.clt_cp = (oProject.Project_City_Postal_Code__r.Postal_Code__c == null) ? '' : oProject.Project_City_Postal_Code__r.Postal_Code__c;
                oProjectData.clt_ville = (oProject.Project_City_Postal_Code__r.City__r.Name == null) ? '' : oProject.Project_City_Postal_Code__r.City__r.Name;

                // Invoiced customer
                oProjectData.fct_civ = (String.isBlank(oAccountTarget.Salutation) ? null : oAccountTarget.Salutation);
                oProjectData.fct_nom = (String.isBlank(oAccountTarget.LastName) ? null : oAccountTarget.LastName);
                oProjectData.fct_prenom = (String.isBlank(oAccountTarget.FirstName) ? null : oAccountTarget.FirstName);
                oProjectData.fct_email = (String.isBlank(oAccountTarget.Email__c) ? null : oAccountTarget.Email__c);
                if(!String.isBlank(oAccountTarget.Phone)){
                    oProjectData.fct_telephone = oAccountTarget.Phone;
                } else if(!String.isBlank(oAccountTarget.Mobile_Phone_Number__c)){
                    oProjectData.fct_telephone = oAccountTarget.Mobile_Phone_Number__c;
                } else {
                    oProjectData.fct_telephone = '';
                }
                oProjectData.fct_adresse = oAccountTarget.Street_N__c + ' ' + oAccountTarget.Street_type__c + ' ' + oAccountTarget.Street_name__c;
                oProjectData.fct_adresse_cpl = '';
                oProjectData.fct_adresse_cpl2 = '';
                oProjectData.fct_cp = (oAccountTarget.City_Postal_Code__r.Postal_Code__c == null) ? '' : oAccountTarget.City_Postal_Code__r.Postal_Code__c;
                oProjectData.fct_ville = (oAccountTarget.City_Postal_Code__r.City__r.Name == null) ? '' : oAccountTarget.City_Postal_Code__r.City__r.Name;
            }
            
            apiResponseToProcess = Chauffage_CalloutMgr.callPostData(cChauffageAPI, APIToken, oProjectData);
            if(!apiResponseToProcess.hasError){
                // Update dataSentToPartner flag on Project
                oProject.Sent_To_External_Partner__c = true;
                update oProject;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Projet envoyé au partenaire ' + cChauffageAPI.DeveloperName + ' avec succès.'));
            }else{
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, apiResponseToProcess.errorMessage));
            }
            
        }
        
    }

    public void saveData() {
        
        if( !this.hasError && isCustomerEligible /*&& cChauffageAPI.DeveloperName == 'GARANKA'*/ ) {
            
            try {
                
                Id AccountServiceRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service_PersonAccount').getRecordTypeId();
                Id projectChauffageRT = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Chauffage').getRecordTypeId();
                
                // Retrieve Id matching selectedPostalCode from City_Postal_Code__c object
                String projectPostalCodeId = '';
                List<City_Postal_Code__c> lPostalCode = [ SELECT Id FROM City_Postal_Code__c WHERE Postal_Code__c = :selectedPostalCode LIMIT 1 ];
                
                if(lPostalCode.size() > 0){
                    for (City_Postal_Code__c oCPC: lPostalCode) {
                        projectPostalCodeId = oCPC.Id;
                    }
                }else{
                    this.hasError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Ce code postal n\'existe pas dans le système.'));
                    return;
                }
                
                // Account
                oAccountTarget.RecordTypeId = AccountServiceRT;
                oAccountTarget.putSObject('Activity_Domain__r', new Activity_Domain__c(ExternalID__c = 38));
                if(oProject.Resident__c){
                    oAccountTarget.City_Postal_Code__c = (String.isBlank(projectPostalCodeId) ? null : projectPostalCodeId);
                }
                insert oAccountTarget;

                // Project
                oProject.Project_Type__c = 'Chauffage';
                oProject.RecordTypeId = projectChauffageRT;
                oProject.Customer_Account__c = oAccountTarget.Id;
                
                if(oProject.Resident__c){
                    oProject.Client_Type__c = (oAccountSource.Type_de_relation__c == 'Propriétaire' ? 'Owner' : 'Renter');
                }else{
                    oProject.Client_Type__c = 'Owner';
                }

                if( cChauffageAPI.DeveloperName == 'MENERGIES' ){
                    oProject.GARANKA_Contract_Type__c = null;
                }

                oProject.Same_Address__c = oProject.Resident__c;
                oProject.Intervention_Group__c = null;
                oProject.Subcontractor__c = oSubcontractor.Id;
                oProject.GARANKA_Date_Of_Visit__c = ( (String.isBlank(selectedTimeSlot) || (selectedTimeSlot == '0')) ? '' : selectedTimeSlot.left(10) );
                oProject.GARANKA_Time_Of_Visit__c = ( (String.isBlank(selectedTimeSlot) || (selectedTimeSlot == '0')) ? '' : selectedTimeSlot.substringAfter(' ') );
                oProject.Project_City_Postal_Code__c = (String.isBlank(projectPostalCodeId) ? null : projectPostalCodeId);
                insert oProject;
                
                // Requery records to get updated values
                this.oAccountTarget = [
                    SELECT Id, Name, isPersonAccount, Street_N__c, Street_type__c, Street_name__c, Postal_Code__c, City_Postal_Code__c, City_Postal_Code__r.City__c, City_Postal_Code__r.Postal_Code__c, City_Postal_Code__r.City__r.Name,
                            PersonContactId, Activity_Domain__c, AccountNumber, Salutation, LastName, FirstName, Email__c, Salutation__c, Phone, Type_de_relation__c, 
                            Indicatif_Pays__c, Mobile_Phone_Number__c, FCC_Mobile_Phone_Number__c, Activity_Domain__r.ExternalID__c, Mandataire__r.ExternalID__c
                    FROM Account
                    WHERE Id=:oAccountTarget.Id
                ];

                this.oProject = [
                    SELECT Id, Name, Sent_To_External_Partner__c, Project_Type__c, RecordTypeId, Customer_Account__c, Same_Address__c, Intervention_Group__c, Subcontractor__c, 
                        GARANKA_Date_Of_Visit__c, GARANKA_Time_Of_Visit__c, Project_City_Postal_Code__c, Product__c, GARANKA_Contract_Type__c, Housing_Type__c, Housing_Over_2_Years__c, 
                        Device_Type__c, Type_of_Technology__c, GARANKA_Device_Brand__c, Estimated_Age_Of_Device__c, Resident__c, Client_Type__c, Renter_Salutation__c, Renter_Last_Name__c,
                        Renter_First_Name__c, Renter_Email__c, Renter_Phone__c, Project_Street_Number__c, Project_Street_Type__c, Project_Street_name__c, 
                        Project_City_Postal_Code__r.Postal_Code__c, Project_City_Postal_Code__r.Name, Project_City_Postal_Code__r.City__c, Project_City_Postal_Code__r.City__r.Name, 
                        Price_Code__c
                    FROM Project__c
                    WHERE Id=:oProject.Id
                ];
                
            } catch(DmlException e) {
                this.hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Une erreur est survenue : ' + e.getMessage()));
            }
           
        }
        
    }

    // Get Chauffage API settings
    public Chauffage_API_Settings__mdt getChauffageAPISettings(String pPartner) {
        
        List<Chauffage_API_Settings__mdt> lChauffageAPI = [ select Id, DeveloperName, ClientId__c, ClientSecret__c, UserName__c, Password__c, Get_Token_Endpoint__c, Get_Eligibility_Endpoint__c, Get_Booking_Time_Slots_Endpoint__c, Post_Data_Endpoint__c
                                            from Chauffage_API_Settings__mdt
                                            where DeveloperName =: pPartner
                                            limit 1
                                            ];
        
        if(lChauffageAPI.size() == 0){
            System.debug('### No Chauffage API settings defined');
            return null;
        }
        
        return lChauffageAPI[0];
    }

    public PageReference navigateToAccount(){
        PageReference pageRef = new PageReference('/' + oAccountTarget.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference navigateToProject(){
        PageReference pageRef = new PageReference('/' + oProject.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

}