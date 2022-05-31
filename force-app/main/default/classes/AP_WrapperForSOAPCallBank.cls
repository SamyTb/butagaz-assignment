public class AP_WrapperForSOAPCallBank {

    public Boolean statusContinueProcess;
    public BAPITracker__c oBapiTracker {get;set;}
    public String sStoreTracker {get;set;}

    public Map<String, list<Account>> Send_Bank_TO_SAP(String IdQuote)
    {
        system.debug('Send_Bank_TO_SAP');
        this.oBapiTracker = new BAPITracker__c();
        this.sStoreTracker = AP_PricingUtilities.getCustomSettingValue('TrackBAPICalls');


        list<Account> lAccount = new list<Account>();
        Map<String, responseSAP> lIdACC = new Map<String, responseSAP>();
        list<Quote> q = new list<Quote>();
        this.statusContinueProcess = true;
        Boolean originalBypassVRvalue;
        Boolean originalBypassWFvalue;
        Boolean originalBypassEmailNoEmailvalue;
        String errorMessage = '';
        microsoftLobservicesSapBANQUE.RfcEndpoint callBAPI = new microsoftLobservicesSapBANQUE.RfcEndpoint();
        microsoftLobservicesSapBANQUERfc.ZBAPI_CRM_BANQUEResponse_element response = new microsoftLobservicesSapBANQUERfc.ZBAPI_CRM_BANQUEResponse_element();
        microsoftLobservicesSapBANQUETypes.ArrayOfBAPIRET2 ET_RETURN = new microsoftLobservicesSapBANQUETypes.ArrayOfBAPIRET2();

        try {
            
            //DEVIS (bareme produit, type de marché)
            q = [select Id, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
                            Client_Type__c, Account.name, account.salutation, Market_type__c, opportunity.Account.Activity_Domain__r.ExternalID__c,
                            Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, Product_Scale_Code__c, 
                            Shipping_Condition__c, Facturation_calendar__c, DO_Payment_method__c, 
                            Opportunity.DO_Accounting_Manager__r.Code__c, Opportunity.Account_Payer__r.accountnumber, 
                            Opportunity.Contract_Start_Date__c, Opportunity.Account_Billed__r.accountnumber, Opportunity.PA_DO__c, Opportunity.FA_DO__c, Opportunity.DO_Name__c, 
                            Opportunity.DO_Recovery_procedures__c, Payment_spread__c, DO_Groupement__r.accountnumber, Scale__c, account.Salutation__c, Scale_Code__c, Opportunity.Account.name, 
                            Opportunity.Account_Payer__r.SEPA_IBAN__c, Opportunity.Account_Payer__r.SEPA_CITY__c, Signea_Date_Signature__c,  
                            Opportunity.Account.accountnumber, Opportunity.Account.SEPA_IBAN__c, Opportunity.Account.SEPA_CITY__c, Opportunity.Account_Payer__c  
                            from Quote where Id= :IdQuote limit 1];
            
            system.debug('q:'+q);

            if(q.size()>0)
            {
                //definition du type de projet
                String typeProjet = (q[0].Project_Type__c  + q[0].Client_Type__c).toUpperCase();
                system.debug('typeProjet:'+typeProjet);

                lAccount = [select Id, name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                            State_Synchro_Bank_To_SAP__c, Mandataire__r.ExternalID__c from Account where Id = :q[0].AccountId];

                String action = q[0].Project_Type__c;
                action = 'CREA';
                
                system.debug('########q[0].Opportunity.Account_Payer__r.accountnumber:'+q[0].Opportunity.Account_Payer__r.accountnumber);
                system.debug('########q[0].Opportunity.Account_Payer__r.SEPA_IBAN__c:'+q[0].Opportunity.Account_Payer__r.SEPA_IBAN__c);
                system.debug('########q[0].Opportunity.Account_Payer__r.SEPA_CITY__c:'+q[0].Opportunity.Account_Payer__r.SEPA_CITY__c);
                system.debug('########q[0].Opportunity.Account.accountnumber:'+q[0].Opportunity.Account.accountnumber);
                system.debug('########q[0].Opportunity.Account.SEPA_IBAN__c:'+q[0].Opportunity.Account.SEPA_IBAN__c);
                system.debug('########q[0].Opportunity.Account.SEPA_CITY__c:'+q[0].Opportunity.Account.SEPA_CITY__c);
                
                //si payeur != DO
                if(q[0].Opportunity.PA_DO__c == false)
                {
                    response = callBAPI.ZBAPI_CRM_BANQUE(action, q[0].Opportunity.Account_Payer__r.accountnumber,  
                                    q[0].Signea_Date_Signature__c, q[0].Opportunity.Account_Payer__r.SEPA_IBAN__c,
                                    String.valueOf(lAccount[0].Mandataire__r.ExternalID__c), typeProjet, 
                                    q[0].Opportunity.Account_Payer__r.SEPA_CITY__c, ET_RETURN);
                
                }
                else
                {    
                    response = callBAPI.ZBAPI_CRM_BANQUE(action, q[0].Opportunity.Account.accountnumber,  
                                    q[0].Signea_Date_Signature__c, q[0].Opportunity.Account.SEPA_IBAN__c,
                                    String.valueOf(lAccount[0].Mandataire__r.ExternalID__c), typeProjet, 
                                    q[0].Opportunity.Account.SEPA_CITY__c, ET_RETURN);
                }
                system.debug('>>>response BANK:'+response);

                //TRAITEMENT RETOUR
                microsoftLobservicesSapBANQUETypes.ArrayOfBAPIRET2 ET_RETURNSAP = response.ET_RETURN;
                list<microsoftLobservicesSapBANQUETypes.BAPIRET2> BAPIRET2 = ET_RETURNSAP.BAPIRET2;
                
                for(microsoftLobservicesSapBANQUETypes.BAPIRET2 b:BAPIRET2)
                    system.debug('b.MESSAGE:'+b.MESSAGE);
                
                for(microsoftLobservicesSapBANQUETypes.BAPIRET2 b:BAPIRET2)
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

                system.debug('this.statusContinueProcess BANK:'+this.statusContinueProcess);


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


            //si payeur != DO et OK, on sup coord bancaire
            if(q[0].Opportunity.PA_DO__c == false && response.EX_CONTROL=='OK')
            {
                Account acc = [select Id, SEPA_IBAN__c, SEPA_CITY__c from Account where Id = :q[0].Opportunity.Account_Payer__c limit 1];
                acc.SEPA_IBAN__c = null;
                acc.SEPA_CITY__c = null;
                update acc;

            }
            //DEBUT MAJ lAccount
            for(Account acc:lAccount)
            {
                acc.State_Synchro_Bank_To_SAP__c = lIdACC.get(acc.Id).EX_CONTROL;
                acc.Error_Synchro_Bank_To_SAP__c = lIdACC.get(acc.Id).lERROR;
                if(q[0].Opportunity.PA_DO__c == true && response.EX_CONTROL=='OK')
                {
                    acc.SEPA_IBAN__c = null;
                    acc.SEPA_CITY__c = null;
                }
    
            }
            update lAccount;

            // Reset Bypass fields to their original value
            //userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
            userCurrent.Bypass_Validation_Rules__c = originalBypassVRvalue;
            userCurrent.Bypass_Workflow__c = originalBypassWFvalue;
            userCurrent.Bypass_Email_No_Email_Check__c = originalBypassEmailNoEmailvalue;
            update userCurrent;
            
            lAccount = [select Id, name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                        State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];

            System.debug('lAccount 2:'+lAccount);

            Map<String, list<Account>> mapACC = new Map<String, list<Account>>(); 
            mapACC.put('ListACC', lAccount);
            
            return mapACC;
        }
        catch (Exception e) {
            this.statusContinueProcess = false;
            system.debug('>>>class AP_WrapperForSOAPCallBank:'+e.getMessage());
            system.debug('>>>AP_WrapperForSOAPCallBank response:'+response);
            //DEBUT MAJ COMPTE
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

            list<Account> lAccount1 = [select Id, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];
    
            if(lAccount1.size()!=0)
            {    
                for(Account acc:lAccount1)
                {
                    acc.State_Synchro_Bank_To_SAP__c = 'KO';
                    acc.Error_Synchro_Bank_To_SAP__c = e.getMessage();
                }    
                update lAccount1;
                lAccount1 = [select Id, Name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                State_Synchro_Bank_To_SAP__c from Account where Id IN :lIdACC.keyset()];

            }
            else
            {
                lAccount1 = [select Id, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                                State_Synchro_Bank_To_SAP__c from Account where Id = :q[0].AccountId];
                for(Account acc:lAccount1)
                {
                    acc.State_Synchro_Bank_To_SAP__c = 'KO';
                    acc.Error_Synchro_Bank_To_SAP__c = e.getMessage();
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