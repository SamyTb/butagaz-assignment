public class VoxpayMgr {
    
    public User currentUser;
    public Account oAccount {get;set;}
    public string selectedPaymentType {get;set;}
    //public string selectedIntervalType {get;set;}
    public List<SelectOption> optionsProjectTypes {get;set;}
    public string selectedProjectType {get;set;}
    public string embeddedURL {get;set;}
    public string vxpPaymentId {get;set;}
    public Voxpay_CalloutMgr.userReferenceResponseBody vxpUser {get;set;}
    public Voxpay_CalloutMgr.paymentInfo oPaymentInfo {get;set;}
    public Voxpay_CalloutMgr.ddiBookResponseBody vxpDdiBook {get;set;}
    public Voxpay_CalloutMgr.callsResponseBody vxpCalls {get;set;}
    
    //public OrangeFCC_CalloutMgr.fccClickToCallResponseBody fccClickToCall {get;set;}
    
    public Boolean showForm {get; set;}
    public Boolean isServiceAccount {get; set;}
    public Voxpay_Settings__mdt cVxp;
    public Voxpay_API_Settings__mdt cVxpAPI;
    //public String fccApiEndpoint {get; set;}
    public boolean showVoxpayiFrame {get;set;}
    
    public string vxpSDA {get;set;}
    
    
    public List<SelectOption> getPaymentTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','Sélectionner une méthode de paiement'));
        if(currentUser.CallCenterId != null) 
        	options.add(new SelectOption('1','Par téléphone'));
        options.add(new SelectOption('6','Par email'));
        options.add(new SelectOption('4','Par SMS'));
        return options;
    }
    
    public List<SelectOption> getIntervalTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','Sélectionner un intervalle'));
        options.add(new SelectOption('week','Toutes les semaines'));
        options.add(new SelectOption('month','Tous les mois'));
        return options;
    }
    
    public void getProjectTypes() {
        
        List<RecordType> projectRTList = new List<RecordType>([select Id, Name from RecordType where sObjectType = 'Project__c' order by Name]);
        
        if( projectRTList.size() > 0 ){
            optionsProjectTypes.add(new SelectOption('0','Sélectionner un type de projet'));
            for(RecordType rt : projectRTList)
                optionsProjectTypes.add(new SelectOption(rt.Name, rt.Name));
        }
    }
    
    
    public VoxpayMgr(ApexPages.standardcontroller stdController) {
        
        this.showForm = true;
        this.selectedPaymentType = '0';
        //this.selectedIntervalType = '0';
        
        // Retrieve current user FederationId
        //String fedId = getFederationId();
        getUserDetails();
        String fedId = currentUser.FederationIdentifier;
        
        cVxpAPI = getVoxpayAPISettings();
        
        if( fedId != null && fedId != '' ){
            
            // Retrieve user info from Voxpay API
            vxpUser = Voxpay_CalloutMgr.callVoxpayUser(cVxpAPI, fedId);
            
            // If vxpUser is empty or is inactive, we need to stop and display a message
            if( vxpUser != null && vxpUser.Active == true ){
                System.debug(logginglevel.WARN,'### vxpUser.api_token = '+ vxpUser.api_token);
                for(Voxpay_CalloutMgr.userReferenceResponseBodyCampaign oCampaign : vxpUser.campaigns){
                    System.debug(logginglevel.WARN,'### oCampaign.uuid : ' + oCampaign.uuid);
                    System.debug(logginglevel.WARN,'### oCampaign.name : ' + oCampaign.name);
                }
            }else{
                this.showForm = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Utilisateur Voxpay non défini.'));
            }
            
        }else{
            this.showForm = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Votre Id de fédération n\'est pas défini.'));
        }
        
        // Retrieve current account information
        this.oAccount = [
            SELECT Id, Name, isPersonAccount, PersonContactId, Activity_Domain__c, AccountNumber, Salutation, LastName, FirstName, Email__c,
                    Indicatif_Pays__c, Mobile_Phone_Number__c, FCC_Mobile_Phone_Number__c, Activity_Domain__r.ExternalID__c, Mandataire__r.ExternalID__c
            FROM Account
            WHERE Id=:stdController.getRecord().Id
        ];
        System.debug(logginglevel.WARN,'### this.oAccount = '+ this.oAccount);
        
        // Initialize object that will hold the values to pass to the payment API callout
        oPaymentInfo = new Voxpay_CalloutMgr.paymentInfo();
        oPaymentInfo.campaign_id = '';
        oPaymentInfo.cinematic_id = integer.valueOf(this.selectedPaymentType);
        oPaymentInfo.amount = 0;
        oPaymentInfo.currencyLabel = 'EUR';
        oPaymentInfo.customer_reference = this.oAccount.AccountNumber;
        oPaymentInfo.customer_title = '';
        oPaymentInfo.customer_firstname = this.oAccount.isPersonAccount ? this.oAccount.FirstName : '';
        oPaymentInfo.customer_lastname = this.oAccount.isPersonAccount ? this.oAccount.LastName : this.oAccount.Name;
        oPaymentInfo.customer_phone = this.oAccount.FCC_Mobile_Phone_Number__c;
        oPaymentInfo.customer_email = this.oAccount.Email__c;
        oPaymentInfo.returnContext = '';
        oPaymentInfo.orderId = '';
        oPaymentInfo.short_description = '';
        oPaymentInfo.subscription = false;
        oPaymentInfo.interval_amount = 0;
        oPaymentInfo.interval_type = '0';  //this.selectedIntervalType;
        oPaymentInfo.interval_count = 0;
        oPaymentInfo.gateway_operation = 'tokenization+authorization+capture';
        
        
        isServiceAccount = (this.oAccount.Activity_Domain__c != null && this.oAccount.Activity_Domain__r.ExternalID__c == 38);
        
        optionsProjectTypes = new List<SelectOption>();
        this.getProjectTypes();
    }
    
    public void validatePaymentType() {
        if(selectedPaymentType != '0'){
            oPaymentInfo.cinematic_id = integer.valueOf(selectedPaymentType);
        }
    }
    
    
    public void preparePayment() {
        
        String campaignId = getVoxpayCampaign();
        
        ApexPages.getMessages().clear();
        
        // if Service account, we need a project type selected
        if ( oAccount.Activity_Domain__r.ExternalID__c == 38 && selectedProjectType == '0' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un type de projet.'));
        }
        
        // Check a campaign exists for the criteria
        if( campaignId == null || campaignId == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Aucune campagne Voxpay ne correspond à votre demande.'));
        }else{
            oPaymentInfo.campaign_id = campaignId;
        }
        
        // Check current user is associated with the campaign
        boolean bFound = false;
        for(Voxpay_CalloutMgr.userReferenceResponseBodyCampaign oCampaign : vxpUser.campaigns){
            System.debug(logginglevel.WARN,'### oCampaign.uuid : ' + oCampaign.uuid);
            System.debug(logginglevel.WARN,'### oCampaign.name : ' + oCampaign.name);
            if( campaignId == oCampaign.uuid ){
                bFound = true;
                break;
            }
        }
        if( !bFound && !Test.isRunningTest() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous n\'êtes pas autorisé à lancer un paiement sur cette campagne.'));
        }
        
        // Check amount > 0
        if( oPaymentInfo.amount == null || oPaymentInfo.amount <= 0 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner un montant.'));
        }
        
        // If subscription, check all related fields
        if( oPaymentInfo.subscription ){
	        if( oPaymentInfo.interval_amount == null || oPaymentInfo.interval_amount <= 0 ){
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez renseigner un montant.'));
	        }
	        if( oPaymentInfo.interval_type == null || oPaymentInfo.interval_type == '' || oPaymentInfo.interval_type == '0' ){
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un intervalle de paiement.'));
	        }
	        if( oPaymentInfo.interval_count == null || oPaymentInfo.interval_count <= 0 ){
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Veuillez sélectionner un nombre de récurrences de paiement.'));
	        }
        }
        
        // if cinematic chosen = phone, we need to book a phone number
        if( !ApexPages.hasMessages() && oPaymentInfo.cinematic_id == 1){
            vxpDdiBook = Voxpay_CalloutMgr.callVoxpayDdiBook(cVxpAPI, vxpUser.api_token, vxpUser.reference);
            
            if(vxpDdiBook != null){
                System.debug(logginglevel.WARN,'### vxpDdiBook = '+ vxpDdiBook);
                System.debug(logginglevel.WARN,'### vxpDdiBook.sda = '+ vxpDdiBook.sda);
                System.debug(logginglevel.WARN,'### vxpDdiBook.date_end_booking = '+ vxpDdiBook.date_end_booking);
                if(vxpDdiBook.sda == null || vxpDdiBook.sda == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Pas de numéro de transfert disponible.'));
                }else{
                	vxpSDA = /*'%2B' +*/ vxpDdiBook.sda;
            		System.debug(logginglevel.WARN,'### vxpSDA = '+ vxpSDA);
                }
                
                /*
                // if we got an sda, we now need to call this sda provided by Voxpay
                fccClickToCall = OrangeFCC_CalloutMgr.callClickToCall(vxpDdiBook.sda, 'true');
                if(fccClickToCall != null){
                    if(fccClickToCall.code != '0'){
                        System.debug(logginglevel.WARN,'### Erreur lors du transfert d\'appel vers Voxpay : ' + fccClickToCall.code + ' ' + fccClickToCall.message + ' ' + fccClickToCall.messagePayload);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors du transfert d\'appel vers Voxpay : ' + fccClickToCall.code + ' ' + fccClickToCall.message + ' ' + fccClickToCall.messagePayload));
                    }
                }else{
                    System.debug(logginglevel.WARN,'### Erreur lors du transfert d\'appel vers Voxpay.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors du transfert d\'appel vers Voxpay.'));
                }
                
                // then we need to transfer the call to this sda
                fccClickToCall = OrangeFCC_CalloutMgr.callClickToCall(vxpDdiBook.sda, 'false');
                if(fccClickToCall != null){
                    if(fccClickToCall.code != '0'){
                        System.debug(logginglevel.WARN,'### Erreur lors du transfert d\'appel vers Voxpay : ' + fccClickToCall.code + ' ' + fccClickToCall.message + ' ' + fccClickToCall.messagePayload);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors du transfert d\'appel vers Voxpay : ' + fccClickToCall.code + ' ' + fccClickToCall.message + ' ' + fccClickToCall.messagePayload));
                    }
                }else{
                    System.debug(logginglevel.WARN,'### Erreur lors du transfert d\'appel vers Voxpay.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors du transfert d\'appel vers Voxpay.'));
                }
                */
            }else{
                System.debug(logginglevel.WARN,'### Erreur lors de la tentative d\'obtention d\'un numéro de transfert Voxpay.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors de la tentative d\'obtention d\'un numéro de transfert Voxpay.'));
            }
        }
        
        /*
        this.showVoxpayiFrame = false;
        if( !ApexPages.hasMessages() ){
            this.showVoxpayiFrame = true;
            
            HttpResponse response = Voxpay_CalloutMgr.doCalloutPayment(vxpUser.api_token, oPaymentInfo);
            System.debug(logginglevel.WARN,'### response = '+ response);
            
            if(response != null && response.getStatusCode() == 200) {
                
                // Deserialize the JSON string into collections of primitive data types
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                this.embeddedURL = (String)results.get('embedded_url');
                System.debug(logginglevel.WARN,'### embeddedURL = '+ embeddedURL);
                System.debug(logginglevel.WARN,'### Voxpay payment id = '+ (String)results.get('id'));
                
            }
        }
        */
        System.debug(logginglevel.WARN,'### End preparePayment : ApexPages.hasMessages() = ' + ApexPages.hasMessages());
    }
    
    public void checkCallTransfer() {
    	
    	String vxpCallId = '';
    	
    	// if cinematic chosen = phone, we need to check the phone transfer was successful
        if( oPaymentInfo.cinematic_id == 1 && !ApexPages.hasMessages()){
        	vxpCalls = Voxpay_CalloutMgr.callVoxpayCalls(cVxpAPI, vxpUser.api_token, vxpUser.reference);
            
            if(vxpCalls != null){
                System.debug(logginglevel.WARN,'### vxpCalls = ' + vxpCalls);
                System.debug(logginglevel.WARN,'### vxpCalls.id = ' + vxpCalls.id);
                if(vxpCalls.id == null || vxpCalls.id == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Transfert d\'appel non-effectué.'));
                }else{
                	vxpCallId = vxpCalls.id;
                	oPaymentInfo.call_uuid = vxpCallId;
            		System.debug(logginglevel.WARN,'### vxpCallId = ' + vxpCallId);
                }
            }else{
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors de la tentative de vérification du transfert d\'appel.'));
            }
        }
    	
    }
    
    public void postPayment() {
    	
    	this.showVoxpayiFrame = false;
    	
    	System.debug(logginglevel.WARN,'### Start postPayment');
    	//System.debug(logginglevel.WARN,'### oPaymentInfo.cinematic_id = ' + oPaymentInfo.cinematic_id);
    	System.debug(logginglevel.WARN,'### Start postPayment : ApexPages.hasMessages() = ' + ApexPages.hasMessages());
    	
    	
        if( !ApexPages.hasMessages() ){
            
            HttpResponse response = Voxpay_CalloutMgr.doCalloutPayment(cVxpAPI, vxpUser.api_token, oPaymentInfo);
            System.debug(logginglevel.WARN,'### response = ' + response);
            
            if( response != null && response.getStatusCode() >= 200 && response.getStatusCode() <= 299 ) {
                this.showVoxpayiFrame = true;
                
                // Deserialize the JSON string into collections of primitive data types
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if( !oPaymentInfo.subscription ){
	                this.embeddedURL = (String)results.get('embedded_url');
	                System.debug(logginglevel.WARN,'### embeddedURL = ' + this.embeddedURL);
	                this.vxpPaymentId = (String)results.get('id');
	                System.debug(logginglevel.WARN,'### Voxpay payment id = ' + this.vxpPaymentId);
                }else{
	            	// Get embedded url from subscription response : different location in JSon response	
	            	System.debug(logginglevel.WARN,'### results = ' + results);
	            	System.debug(logginglevel.WARN,'### results.get(parent_payment) = ' + results.get('parent_payment'));
	            	
	            	Map<String, Object> parentPayment = (Map<String, Object>) results.get('parent_payment');
	            	System.debug(logginglevel.WARN,'### parentPayment = ' + parentPayment);
	            	System.debug(logginglevel.WARN,'### parentPayment.get(embedded_url) = ' + parentPayment.get('embedded_url'));
	            	
	            	this.embeddedURL = (String)parentPayment.get('embedded_url');
	                System.debug(logginglevel.WARN,'### embeddedURL = ' + this.embeddedURL);
	                this.vxpPaymentId = (String)parentPayment.get('id');
	                System.debug(logginglevel.WARN,'###  Voxpay payment id = ' + this.vxpPaymentId);
	            }
                
            }else{
            	this.showVoxpayiFrame = false;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors de l\'envoi du paiement.'));
            }
        }
    	
    }
    
    public void savePayment() {
    	
    	//String vxpCallId = '';
    	
        if( !ApexPages.hasMessages() ){
        	Voxpay_Payment_History__c oVoxpayPaymentHistory = new Voxpay_Payment_History__c(
                ExternalID__c = this.vxpPaymentId,
                Account__c = oAccount.Id,
                Amount__c = oPaymentInfo.amount,
                Payment_URL__c = this.embeddedURL,
                Subscription__c = oPaymentInfo.subscription,
                Interval_Amount__c = oPaymentInfo.interval_amount,
                Interval_Type__c = oPaymentInfo.interval_type,
                Interval_Count__c = oPaymentInfo.interval_count

                /*,
                Request_Body__c = requestBody == null ? '' : requestBody.toString(),
                Request_URI__c = requestURI,
                Request_Resource_Path__c = resourcePath,
                Response__c = response == null ? '' : response.toString()*/
            );
            insert oVoxpayPaymentHistory;
        }
    	
    }
    
    /*
    public void callVxpSDAApi() {
        vxpDdiBook = Voxpay_CalloutMgr.callVoxpayDdiBook(cVxpAPI, vxpUser.api_token, vxpUser.reference);
            
        if(vxpDdiBook != null){
            System.debug(logginglevel.WARN,'### vxpDdiBook = '+ vxpDdiBook);
            System.debug(logginglevel.WARN,'### vxpDdiBook.sda = '+ vxpDdiBook.sda);
            System.debug(logginglevel.WARN,'### vxpDdiBook.date_end_booking = '+ vxpDdiBook.date_end_booking);
            if(vxpDdiBook.sda == null || vxpDdiBook.sda == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Pas de numéro de transfert disponible.'));
            }
            
            vxpSDA = vxpDdiBook.sda;  //'%2B' + 
            System.debug(logginglevel.WARN,'### vxpSDA = '+ vxpSDA);
        }else{
            System.debug(logginglevel.WARN,'### Erreur lors de la tentative d\'obtention d\'un numéro de transfert Voxpay.');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Erreur lors de la tentative d\'obtention d\'un numéro de transfert Voxpay.'));
        }
    }
    */
    
    /*// Get current user FederationId
    public String getFederationId() {
        
        String fedId = [ select Id, FederationIdentifier, CallCenterId from User where Id =:UserInfo.getUserId() ].FederationIdentifier;
        
        return fedId;
    }*/
    
    // Get current user details
    public void getUserDetails() {
        
        //String fedId = [ select Id, FederationIdentifier, CallCenterId from User where Id =:UserInfo.getUserId() ].FederationIdentifier;
        currentUser = [ select Id, FederationIdentifier, CallCenterId from User where Id =:UserInfo.getUserId() limit 1 ];
        
    }
    
    // Get Voxpay API settings
    public Voxpay_API_Settings__mdt getVoxpayAPISettings() {
        
        List<Voxpay_API_Settings__mdt> lVxpAPI = [ select API_Key__c, Ddi_Book_Endpoint__c, Get_Calls_Endpoint__c, Payment_Endpoint__c, Subscription_Endpoint__c, User_Reference_Endpoint__c, FCC_ClickToCall_Endpoint__c   
                                            from Voxpay_API_Settings__mdt
                                            limit 1
                                            ];
        
        if(lVxpAPI.size() == 0){
            System.debug('### No Voxpay API settings defined');
            return null;
        }
        
        System.debug('### lVxpAPI[0] = ' + lVxpAPI[0]);
        return lVxpAPI[0];
    }
    
    // Get Voxpay campaign related to current criteria
    public String getVoxpayCampaign() {
        boolean isSbx = VoxpayMgr.isSandbox();
        string campaignId;
        List<Voxpay_Settings__mdt> lVxp;
        
        
        String campaignQuery = 'select Activity_Domain__c, Mandataire__c, Voxpay_Campaigns__r.TestCampaignId__c, Voxpay_Campaigns__r.ProductionCampaignId__c ' +    
                                            'from Voxpay_Settings__mdt ' +
                                            'where Activity_Domain__c like \'%' + oAccount.Activity_Domain__r.ExternalID__c + '%\' ';
        
        // we only need to determine the mandataire if not a service account
        if ( oAccount.Activity_Domain__r.ExternalID__c != 38 ){
            campaignQuery += 'and Mandataire__c like \'%' + oAccount.Mandataire__r.ExternalID__c + '%\' ' ;
        }
        
        // if Service account, we need to determine what kind of service to get the matching campaign
        if ( oAccount.Activity_Domain__r.ExternalID__c == 38 ){
            campaignQuery += 'AND Project_Type__c like \'%' + selectedProjectType + '%\' ' ;
        }
        System.debug('### campaignQuery = ' + campaignQuery);
        lVxp = Database.query(campaignQuery); 
        
        
        if(lVxp.size() == 0){
            System.debug('### No campaign matching criteria');
        }else{
            cVxp = lVxp[0];
            System.debug('### cVxp = ' + cVxp);
            if(isSbx){
                System.debug('### cVxp Test = ' + cVxp.Voxpay_Campaigns__r.TestCampaignId__c);
                campaignId = cVxp.Voxpay_Campaigns__r.TestCampaignId__c;
            }else{
                System.debug('### cVxp Prod = ' + cVxp.Voxpay_Campaigns__r.ProductionCampaignId__c);
                campaignId = cVxp.Voxpay_Campaigns__r.ProductionCampaignId__c;
            }
        }
        
        return campaignId;
    }
    
    public static Boolean isSandbox() {
        Organization o = [ select Id, IsSandbox from Organization LIMIT 1 ];
        
        if(o != null) {
            return o.IsSandbox;
        }
        return true;
    }
    
	public Boolean hasError {
		get {
			return ApexPages.hasMessages();
		}
    }
    
    public String fccApiEndpoint {
		get {
			return cVxpAPI.FCC_ClickToCall_Endpoint__c;
		}
    }
    

}