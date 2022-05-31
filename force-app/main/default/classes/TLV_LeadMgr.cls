global class TLV_LeadMgr {
    
    private static Account oAccount;
    private final static String CLOSED_WON_STATUS = 'Closed Won';
    private final static String BO_VALIDATED_SUBSTATUS = 'Data validated by BO';
    
    
    //WebService static string createLeadElectricity(string accountId, Date appointmentDate){
    WebService static string createLeadFromAccount(string accountId, string actDom, string appointmentDate, string codeElec, string sDesc){
        
        System.Debug('Start method TLV_LeadMgr.createLeadFromAccount');
        
        String outcomeMessage;
        DateTime finalDate;
        Decimal decActDom = decimal.valueOf(actDom);
        String sLeadSource;
        
        // Get Account
        List<Account> lacc = [select Id, Name, AccountNumber, ExternalID__c, Salutation, LastName, FirstName, Email__c, No_E_mail__c, Phone, Mobile_Phone_Number__c, Indicatif_Pays__c, Street_N__c, Number_extention__c, 
                                Street_type__c, Street_name__c, City_Postal_Code__c, Postal_Code__c, City__c, Country__c, IsPersonAccount, Code_promo_contrat_electricite__c
                                from Account where Id =:accountId limit 1];
        if(!lacc.isEmpty()){
            oAccount = lacc[0];
        }else{
            //System.debug(logginglevel.WARN,'### [TLV_LeadMgr.createLeadFromAccount] : 001-Compte non trouvé.');
            return 'KO-Compte non trouvé.';
        }
        
        
        /*// if lead found
        Map<String, String> leadsFoundMap = new Map<String, String>();
        for(Lead oLead : [ select Id, TLV_AccountNumber__c from Lead where TLV_AccountNumber__c =:oAccount.ExternalID__c and Activity_Domain__r.ExternalID__c =:decActDom ])
            leadsFoundMap.put(oLead.TLV_AccountNumber__c, oLead.Id);
        System.debug(logginglevel.WARN,'### leadsFoundMap : ' + leadsFoundMap);
        
        String sFoundLead = leadsFoundMap.get(oAccount.ExternalID__c);
        System.debug(logginglevel.WARN,'### sFoundLead : ' + sFoundLead);
        if(sFoundLead != null && sFoundLead != ''){
            outcomeMessage = 'FD-' + sFoundLead;
            return outcomeMessage;
        }*/
        
        // if lead found
        Map<String, String> leadsFoundMap = new Map<String, String>();
        Map<String, String> leadsWithElecDiscountCodeFoundMap = new Map<String, String>();
        for(Lead oLead : [ select Id, TLV_AccountNumber__c, TLV_Elec_Discount_Code__c from Lead where ( TLV_AccountNumber__c =:oAccount.AccountNumber and Activity_Domain__r.ExternalID__c =:decActDom ) OR ( TLV_Elec_Discount_Code__c != null and TLV_Elec_Discount_Code__c =:oAccount.Code_promo_contrat_electricite__c ) ]){
            if(oLead.TLV_AccountNumber__c == oAccount.AccountNumber){
                leadsFoundMap.put(oLead.TLV_AccountNumber__c, oLead.Id);
            }else if(oLead.TLV_Elec_Discount_Code__c == oAccount.Code_promo_contrat_electricite__c){
                leadsWithElecDiscountCodeFoundMap.put(oLead.TLV_AccountNumber__c, oLead.Id);
            }
        }
        System.debug(logginglevel.WARN,'### leadsFoundMap : ' + leadsFoundMap);
        
        String sFoundLead = leadsFoundMap.get(oAccount.ExternalID__c);
        System.debug(logginglevel.WARN,'### sFoundLead : ' + sFoundLead);
        if(sFoundLead != null && sFoundLead != ''){
            outcomeMessage = 'FD-' + sFoundLead;
            return outcomeMessage;
        }
        String sFoundLeadWithElecDiscountCode = leadsWithElecDiscountCodeFoundMap.get(oAccount.ExternalID__c);
        System.debug(logginglevel.WARN,'### sFoundLeadWithElecDiscountCode : ' + sFoundLeadWithElecDiscountCode);
        if(sFoundLeadWithElecDiscountCode != null && sFoundLeadWithElecDiscountCode != ''){
            outcomeMessage = 'FE-' + sFoundLeadWithElecDiscountCode;
            return outcomeMessage;
        }
        
        
        if(appointmentDate != ''){
            finalDate = DateTime.parse(appointmentDate);
        }else{
            finalDate = null;
        }
        
        
        // Get Activity Domain
        Activity_Domain__c actDomain = [SELECT Id FROM Activity_Domain__c WHERE ExternalID__c =:decActDom LIMIT 1];
        
        // Get Record Type
        String rtDevName = '';
        sLeadSource = '';
        switch on actDom {
            when '39' {
                rtDevName = 'Televente_EcoCarburant';
                sLeadSource = 'Leads sans offre commerciale';
            }
            when '40' {
                rtDevName = 'Televente_Electricite';
                sLeadSource = 'Leads sans offre commerciale';
            }
            when '50' {
                rtDevName = 'Televente_Granules';
                sLeadSource = 'Leads sans offre commerciale';
            }
            when '38' {
                // Improve this when we want to manage several services
                rtDevName = 'Service_Chauffage_Installation_Materiel';
                sLeadSource = 'Chauffage Installation Materiel';
            }
            when else {
                return 'KO-Secteur d\'activité non trouvé.';
            }
        }
        Id rtId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId();
        System.debug(logginglevel.WARN,'### rtId : ' + rtId);
        
        //Fetching the assignment rules on lead
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Lead' /*and Name = 'Suspects_Televente'*/ and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        
        try {
            Lead leadToCreate = new Lead(
                Salutation = oAccount.Salutation,
                Company = oAccount.IsPersonAccount == true ? '' : oAccount.Name,
                LastName = oAccount.IsPersonAccount == true ? oAccount.LastName : oAccount.Name,
                FirstName = oAccount.IsPersonAccount == true ? oAccount.FirstName : '-',
                Activity_Domain__c = actDomain.Id,
                LeadSource = sLeadSource,
                Status = 'New',
                TLV_Stage__c = 'Initiale',
                RecordTypeId = rtId,
                TLV_AccountNumber__c = oAccount.ExternalID__c,
                TLV_User_Who_Brought_The_Lead__c = UserInfo.getUserId(),
                Email = oAccount.Email__c,
                No_E_mail__c = oAccount.No_E_mail__c,
                Phone = oAccount.Phone,
                MobilePhone = oAccount.Mobile_Phone_Number__c,
                Indicatif_Pays__c = oAccount.Indicatif_Pays__c,
                Account_Street_Number__c = oAccount.Street_N__c,
                Account_Number_Extension__c = oAccount.Number_extention__c,
                Account_Street_Type__c = oAccount.Street_type__c,
                Account_Street_Name__c = oAccount.Street_name__c,
                Account_City_Postal_Code__c = oAccount.City_Postal_Code__c,
                Postal_Code__c = (oAccount.Country__c == 'FR') ? null : oAccount.Postal_Code__c,
                Account_Other_City__c = (oAccount.Country__c == 'FR') ? null : oAccount.City__c,
                Account_Country__c = oAccount.Country__c,
                //Project_Street_Number__c = null,
                //Project_Number_Extension__c = null,
                //Project_Street_Type__c = null,
                //Project_Street_name__c = null,
                //Project_City_Postal_Code__c = null,
                //Project_Country__c = null,
                //Owner = null  managed by the assignment rules
                //Existing_PTL__c = null,
                Same_Address__c = (oAccount.Country__c == 'FR') ? true : false,
                Assign__c = false,
                TLV_Elec_Discount_Code__c = string.isBlank(codeElec) ? oAccount.Code_promo_contrat_electricite__c : codeElec,
                Description = sDesc,
                TLV_Contact_Wished_DateTime__c = finalDate
            );
            leadToCreate.setOptions(dmlOpts);
            insert leadToCreate;
            
            // Used to set the Record Type that is changed by the lead settings (Replace existing Record Type by default Record Type when lead assignment rules are processed)
            leadToCreate.RecordTypeId = rtId;
            update leadToCreate;
            
            //outcomeMessage = 'Un suspect électricité a été créé : <br/>' + '<span style="color: red"><a style="color: red" target="_blank" href="/' + leadToCreate.id + '">' + leadToCreate.Name + '</a></span><br/>';
            outcomeMessage = 'OK-' + leadToCreate.Id;
        } catch(DmlException e) {
            System.debug('Une erreur est survenue : ' + e.getMessage());
            outcomeMessage = 'KO-' + e.getMessage();
        }
        
        
        /*for (List<Id> sobj : listIds){
            if(sobj instanceOf Account){
                Account acc = (Account)sobj;
            }else if(sobj instanceOf Opportunity){
                Opportunity opp = (Opportunity)sobj;      
            }
        }
        
        Id idToProcess = '00611000002ZXX';                  
        Schema.sObjectType entityType = idToProcess.getSObjectType();
        System.assert(entityType == Opportunity.sObjectType);
        
        for (List<sObject> sobj : sobjList){
            if(sobj instanceOf Account){
                Account acc = (Account)sobj;
            }else if(sobj instanceOf Opportunity){
                Opportunity opp = (Opportunity)sobj;      
            }
        }*/
        
        System.Debug('End method TLV_LeadMgr.createLeadFromAccount');
        
        return outcomeMessage;
    }
    
    
    @future
    public static void createLeadElectricityFromOpty(Set<Id> lOptyIds){
        
        System.Debug('Start method TLV_LeadMgr.createLeadElectricityFromOpty');
        
        List<Lead> lLeadToInsert = new List<Lead>();
        
        // Get Opportunity and Quote info
        List<Quote> lQuotes = [select Id, Name, Code_promo_contrat_electricite__c, Opportunity.Account.Salutation, Opportunity.Account.LastName, Opportunity.Account.FirstName, Opportunity.OwnerId, 
                                     Opportunity.DO_Email__c, Opportunity.DO_No_E_mail__c, Opportunity.DO_Phone__c, Opportunity.DO_Mobile_Phone_Number__c, Opportunity.DO_Street_N__c,
                                     Opportunity.DO_Number_extention__c, Opportunity.DO_Street_type__c, Opportunity.DO_Street_name__c, Opportunity.DO_City_Postal_Code__c, Opportunity.DO_Country__c, 
                                     Opportunity.Street_number_project__c, Opportunity.Number_extention_project__c, Opportunity.Street_type_project__c, Opportunity.Street_name_project__c, 
                                     Opportunity.Project_City_Postal_Code__c, Opportunity.Country__c, Opportunity.ReferenceClientSAP__c
                                     from Quote 
                                     where OpportunityId =:lOptyIds
                                     and Opportunity.StageName =:CLOSED_WON_STATUS
                                     and Opportunity.Opportunity_Won_Substage__c =:BO_VALIDATED_SUBSTATUS
                                     and Code_promo_contrat_electricite__c != '' ];
        
        if(lQuotes != null && lQuotes.size() > 0){
            
            // Check if RefClient already exists on a lead
            List<String> lRefClient = New List<String>();
            for(Quote oQuote : lQuotes){
                lRefClient.add(oQuote.Opportunity.ReferenceClientSAP__c);
            }
            Map<String, String> refClientFoundMap = new Map<String, String>();
            for(Lead oLead : [select Id, TLV_AccountNumber__c from Lead where TLV_AccountNumber__c =:lRefClient]) {
                refClientFoundMap.put(oLead.TLV_AccountNumber__c, oLead.Id);
            }
            System.debug(logginglevel.WARN,'### refClientFoundMap : ' + refClientFoundMap);
            
            
            // Check if Elec Discount Code already exists on a lead
            List<String> lElecDiscountCode = New List<String>();
            for(Quote oQuote : lQuotes){
                lElecDiscountCode.add(oQuote.Code_promo_contrat_electricite__c);
            }
            Map<String, String> elecDiscountCodeFoundMap = new Map<String, String>();
            for(Lead oLead : [select Id, TLV_Elec_Discount_Code__c from Lead where TLV_Elec_Discount_Code__c =:lElecDiscountCode]) {
                elecDiscountCodeFoundMap.put(oLead.TLV_Elec_Discount_Code__c, oLead.Id);
            }
            System.debug(logginglevel.WARN,'### elecDiscountCodeFoundMap : ' + elecDiscountCodeFoundMap);
            
            
            // Get Activity Domain
            Activity_Domain__c actDomain = [SELECT Id FROM Activity_Domain__c WHERE ExternalID__c = 40 LIMIT 1];
            
            // Get TLV Electricity Record Type
            Id rtId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Televente - Electricité').getRecordTypeId();
            System.debug(logginglevel.WARN,'### rtId : ' + rtId);
            
            //Fetching the assignment rules on lead
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Lead' /*and Name = 'Suspects_Televente'*/ and Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            
            
            try {
                for(Quote oQuote : lQuotes){
                    
                    /*String sFoundLeadWithSameRefClient = refClientFoundMap.get(oQuote.Opportunity.ReferenceClientSAP__c);
                    if(sFoundLeadWithSameRefClient != null && sFoundLeadWithSameRefClient != ''){
                        System.debug(logginglevel.WARN,'### Found Existing Lead with same RefClient : ' + sFoundLeadWithSameRefClient);
                        continue;  // Skip to next iteration. We don't want to create a Lead if one already exists
                    }
                    
                    String sFoundLeadWithSameElecDiscountCode = elecDiscountCodeFoundMap.get(oQuote.Code_promo_contrat_electricite__c);
                    if(sFoundLeadWithSameElecDiscountCode != null && sFoundLeadWithSameElecDiscountCode != ''){
                        System.debug(logginglevel.WARN,'### Found Existing Lead with same Elec Discount Code : ' + sFoundLeadWithSameElecDiscountCode);
                        continue;  // Skip to next iteration. We don't want to create a Lead if one already exists
                    }*/
                    
                    Lead leadToCreate = new Lead(
                        Salutation = oQuote.Opportunity.Account.Salutation,
                        LastName = oQuote.Opportunity.Account.LastName,
                        FirstName = oQuote.Opportunity.Account.FirstName,
                        Activity_Domain__c = actDomain.Id,
                        LeadSource = 'Leads avec offre commerciale',
                        Status = 'New',
                        TLV_Stage__c = 'Initiale',
                        RecordTypeId = rtId,
                        TLV_AccountNumber__c = oQuote.Opportunity.ReferenceClientSAP__c,
                        TLV_User_Who_Brought_The_Lead__c = oQuote.Opportunity.OwnerId,
                        Email = oQuote.Opportunity.DO_Email__c,
                        No_E_mail__c = oQuote.Opportunity.DO_No_E_mail__c,
                        Phone = oQuote.Opportunity.DO_Phone__c,
                        MobilePhone = oQuote.Opportunity.DO_Mobile_Phone_Number__c,
                        Account_Street_Number__c = oQuote.Opportunity.DO_Street_N__c,
                        Account_Number_Extension__c = oQuote.Opportunity.DO_Number_extention__c,
                        Account_Street_Type__c = oQuote.Opportunity.DO_Street_type__c,
                        Account_Street_Name__c = oQuote.Opportunity.DO_Street_name__c,
                        Account_City_Postal_Code__c = oQuote.Opportunity.DO_City_Postal_Code__c,
                        Account_Country__c = oQuote.Opportunity.DO_Country__c,
                        Project_Street_Number__c = oQuote.Opportunity.Street_number_project__c,
                        Project_Number_Extension__c = oQuote.Opportunity.Number_extention_project__c,
                        Project_Street_Type__c = oQuote.Opportunity.Street_type_project__c,
                        Project_Street_name__c = oQuote.Opportunity.Street_name_project__c,
                        Project_City_Postal_Code__c = oQuote.Opportunity.Project_City_Postal_Code__c,
                        Project_Country__c = oQuote.Opportunity.Country__c,
                        Same_Address__c = true,
                        Assign__c = false,
                        TLV_Elec_Discount_Code__c = oQuote.Code_promo_contrat_electricite__c,
                        //Existing_PTL__c = null
                        //Owner = null  managed by the assignment rules
                        TLV_Contact_Wished_DateTime__c = null
                    );
                    leadToCreate.setOptions(dmlOpts);
                    
                    lLeadToInsert.add(leadToCreate);
                }
                
                if(lLeadToInsert != null && lLeadToInsert.size() > 0){
                    insert lLeadToInsert;
                }
                
                // Used to set the Record Type that is changed by the lead settings (Replace existing Record Type by default Record Type when lead assignment rules are processed)
                for(Lead oLead : lLeadToInsert){
                    oLead.RecordTypeId = rtId;
                    update lLeadToInsert;
                }
                
            } catch(DmlException e) {
                System.debug('Une erreur est survenue : ' + e.getMessage());
            }
        }
        
        System.Debug('End method TLV_LeadMgr.createLeadElectricityFromOpty');
    }
    
    
    // Fill a Set containing all leads already previously created for these Account Ids
    /*private static Set<String> alreadyExistingLeads(List<String> laccountExtID){
        //Set<String> foundLeadIdsSet = new Set<String>([select Id from Lead where TLV_AccountNumber__c =:laccountExtID]);
        Map<String, Id> m = new Map<String, Id>([select TLV_AccountNumber__c, Id from Lead where TLV_AccountNumber__c =:laccountExtID]);
        return foundLeadIdsSet;
    }*/
    
    /*// Check if a lead has already been created for this account number
    private static String leadAlreadyExists(String accountExtID){
        
        String foundLeadId = '';
        
        List<Lead> lFoundLead = [select Id from Lead where TLV_AccountNumber__c =:oAccount.ExternalID__c limit 1];
        
        // if lead found
        if(!lFoundLead.isEmpty()){
            foundLeadId = lFoundLead[0].Id;
        }
        return foundLeadId;
        
    }*/
    
}