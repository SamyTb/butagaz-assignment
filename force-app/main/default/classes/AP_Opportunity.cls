public class AP_Opportunity{   
    
    private final static String CLOSED_WON_STATUS = 'Closed Won';
    private final static String BO_VALIDATED_SUBSTATUS = 'Data validated by BO';
    private final static User oUser = [select id, Bypass_Validation_Rules__c from User where id = :UserInfo.getUserId()];
    private final static Map<Id, String> recordTypeIdToName = new Map<Id, String>();
    private static Boolean IsInsert = false;
    public static map<Id,decimal> mOpportunityToActivityDomain = new map<Id,decimal>();
    
    /*
     * Control the OptyPTL linked to the opportunities list in parameter.
     * Put the generated errors directly on the opportunities.
     */
    public static void controlRelatedOpportunityPTLs(List<Opportunity> opportunitiesToControl){    
         
         Map<Id, List<Opportunity_PTL__c>> mapOPTLsByOptyId = fetchAllOptyPTLsByOpportunities(opportunitiesToControl);
         getOptyActivityDomain(opportunitiesToControl);
         for(Opportunity opportunity:opportunitiesToControl){
             
             List<Opportunity_PTL__c> opportunityPTLs = mapOPTLsByOptyId.get(opportunity.Id);
             
             controlACAdministratorValue(opportunity, opportunityPTLs);
             
             controlAnniversaryDateValue(opportunity, opportunityPTLs);
         }
    }
    
    
    /*
     * Control if AC Administrator is filled on each OptyPTL linked to the Opty.
     * If not, it put an error to display on the opty.
     */
    private static void controlACAdministratorValue(Opportunity opportunityToControl, List<Opportunity_PTL__c> opportunityPTLsToControl){
        
        if(isOptyValidatedByBO(opportunityToControl)){
            
            for(Opportunity_PTL__c optyPTL:opportunityPTLsToControl){
                
                /*if(optyPTL.PTL_Code_AC_administrator_value__c == null){*/
                if(optyPTL.Code_AC_administrator_New__c == null){
                    opportunityToControl.addError('Merci de renseigner le champ AC Gestionnaire sur chacun des Opportunité-PTL associés');
                }
            }
        }
        
    }
    
    
     /*
     * Control if Anniversary Date is filled on each OptyPTL linked to the Opty.
     * If not, it put an error to display on the opty.
     */
    private static void controlAnniversaryDateValue(Opportunity opportunityToControl, List<Opportunity_PTL__c> opportunityPTLsToControl){
        
        if(isGPLc(opportunityToControl) && isOptyValidatedByBO(opportunityToControl)){
            
            for(Opportunity_PTL__c optyPTL:opportunityPTLsToControl){
                
                if(optyPTL.Anniversary_date__c == null){
                    opportunityToControl.addError('Merci de renseigner le champ Date d\'anniversaire sur chacun des Opportunité-PTL associés');
                }
            }
        }
        
    }
    
    /*
     * Is the Opty with a 'Closed Won' status and 'Data validated by BO' Sub status
     */
    private static Boolean isOptyValidatedByBO(Opportunity opportunity){
        return CLOSED_WON_STATUS.equals(opportunity.StageName) && BO_VALIDATED_SUBSTATUS.equals(opportunity.Opportunity_Won_Substage__c);
    }
     
      /*
     * Is a GPLc opty
     */
    private static Boolean isGPLc(Opportunity opportunity){
        
        if(mOpportunityToActivityDomain.containsKey(opportunity.id)){
            return (mOpportunityToActivityDomain.get(opportunity.id) == 43);
        }else{
            return false;
        }        
        
    }

    /*
    * Get Activity domain for Opportunities to control  
    */
    public static void getOptyActivityDomain(list<Opportunity> lopportunity){       
        List<Opportunity> fetchedOpportunity = [SELECT Account.Activity_Domain__r.ExternalID__c FROM Opportunity WHERE Id = :lopportunity];
        for(Opportunity oOpty:fetchedOpportunity){
            mOpportunityToActivityDomain.put(oOpty.id,oOpty.Account.Activity_Domain__r.ExternalID__c);
        }   
    
    }
         
    /*
     * Fetch all the Opportunity_PTL__c linked to the opportunities list in parameter.
     * Return a Map with all the Opportunity_PTL__c group by Opportunity Ids
     */
    private static Map<Id, List<Opportunity_PTL__c>> fetchAllOptyPTLsByOpportunities(List<Opportunity> opportunities){
        
        //Fetch Opportunity_PTL__c List
        List<Opportunity_PTL__c> allOptyPTLs = [SELECT /*PTL_Code_AC_administrator_value__c,*/ Code_AC_administrator_New__c, 
                                                       Opportunity__c,
                                                       Anniversary_date__c 
                                                FROM Opportunity_PTL__c 
                                                WHERE Opportunity__c IN :opportunities];
        
        //Generate the Map to return
        Map<Id, List<Opportunity_PTL__c>> mapOPTLsByOptyId = new Map<Id, List<Opportunity_PTL__c>>();
        
        for(Opportunity_PTL__c optyPTL:allOptyPTLs){
            
            if(mapOPTLsByOptyId.get(optyPTL.Opportunity__c) == null){
                mapOPTLsByOptyId.put(optyPTL.Opportunity__c, new List<Opportunity_PTL__c>());
            }
            mapOPTLsByOptyId.get(optyPTL.Opportunity__c).add(optyPTL);
        }
        
        return mapOPTLsByOptyId;
    }
    
    /*
     * Check the validity of the opties passed in parameters
     */
    public static Boolean validateOpportunity(List<Opportunity> optiesToValidate){
        Boolean allOptiesOk = true;
        
        /* Retrieve all RecordType Id and Name to put in a map */
        for(RecordType rt: [Select Id, Name from RecordType where sObjectType='Opportunity']){
            recordTypeIdToName.put(rt.id, rt.Name);
        }
        
        for(Opportunity opty:optiesToValidate){
            if(opty.Opportunity_Won_Substage__c == 'Data validated by BO' ){  // MLC : story 472 anticipation || opty.Opportunity_Won_Substage__c =='Contractualised'
                if(!isBackOfficeUser()){
                    
                    // ajouté pour autoriser la modification uniquement dans le cadre d'un processus de courtage
                    
                    if(!isCommissionToBePaid(opty) ){
                        System.debug(' Opportunité validé BO !!!!!!');
                      opty.addError('Vous devez faire partie du groupe Back Office. Veuillez vous rapprocher de votre service contrat.');  
                    }                    
                }
                opty.Commission__c =false;
            }
        }    
                
        return true;
    }  
    
    public static Boolean isBackOfficeUser(){
        Id userId = UserInfo.getUserId();
        List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];
        
        if(members != null && !members.isEmpty()){
            return true;
        }
        
        return false;
    }
    
     public static Boolean isCommissionToBePaid(Opportunity opty){ 
        return  opty.Commission__c!=null?opty.Commission__c:false ;
    }
    
    
    
    /*
     * Algorithme permettent de vérifier la validation du code SIRET en entrée
     */
    public static boolean SiretValidation(String CodeSiret){
        /*Integer sum = 0;
        Integer len = CodeSiret.length();
        for(Integer i = len - 1;i >= 0;i--){
            Integer num = Integer.ValueOf(CodeSiret.substring(i, i + 1));
            if( math.mod(i, 2) == math.mod(len, 2)) {
                Integer n = num * 2;
                sum += (n / 10) + (math.mod(n, 10));
            } else {
                sum += num;
            }
        }
        return (math.mod(sum, 10) != 0);*/
        
        Integer sum = 0;
        Integer len = CodeSiret.length();
                
        if (CodeSiret.substring(0, 9)==('356000000'))
        {
            for(Integer i = 0; i<len; i ++)
            {
                 /** somme simple des chiffres du SIRET */
                        
                Integer num = Integer.ValueOf(CodeSiret.substring(i, i + 1));
                sum += num;
            }
            // boolean ret=true;
             //if(Long.parseLong(CodeSiret)==0)ret=false;
             
             /** Si la somme est un multiple de 5 alors le SIRET de la Poste est valide */
             return (math.mod(sum, 5) != 0) ; 
        }
        else
        {
            for(Integer i = len - 1;i >= 0;i--)
            {
                Integer num = Integer.ValueOf(CodeSiret.substring(i, i + 1));
                if( math.mod(i, 2) == math.mod(len, 2)) 
                {
                    Integer n = num * 2;
                    sum += (n / 10) + (math.mod(n, 10));
                } else {
                    sum += num;
                }
            }
            return (math.mod(sum, 10) != 0);
            
        }
        
    }
    
    /*
     * Récupération des comptes associés aux optys passées en entrée
     */
    public static Map<Id, Account> getAccounts(List<Opportunity> lOpportunitys){
        Set<Id> sAccountIds = new Set<Id>();
        for (Opportunity oOpportunity : lOpportunitys){
            sAccountIds.add(oOpportunity.AccountId);
            sAccountIds.add(oOpportunity.Account_Payer__c);
            sAccountIds.add(oOpportunity.Account_Billed__c);
            
        }

        return new Map<Id, Account>([
            SELECT
                Id,
                Code_SIRET__c,
                En_cours_d_immatriculation__c,
                Email__c,
                Email_2__c,
                No_E_mail__c
            FROM  Account
            WHERE Id IN :sAccountIds
        ]);
    }
    
    /*
     * Synchronisation des codes SIRET du compte vers l'opty à la création de celle-ci
     */
    public static void syncSiretFromAccount(List<Opportunity> lOpportunitys){
        //if(!Test.isRunningTest()) {
            Map<Id, Account> mAccounts = AP_Opportunity.getAccounts(lOpportunitys);
            for (Opportunity oOpportunity : lOpportunitys){
                AP_Opportunity.syncDO_Fields_Siret(oOpportunity, mAccounts);
                AP_Opportunity.syncPayer_Fields_Siret(oOpportunity, mAccounts);
                AP_Opportunity.syncBilled_Fields_Siret(oOpportunity, mAccounts);
                
            }
        //}
    }
    
    /*
     * Synchronisation du code SIRET du compte vers le code SIRET DO de l'opty à la création de celle-ci
     */
    public static void syncDO_Fields_Siret(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.AccountId != null){
            Account oAccount = mAccounts.get(oOpportunity.AccountId);
            oOpportunity.DO_En_cours_d_immatriculation__c = oAccount.En_cours_d_immatriculation__c;
            oOpportunity.DO_Code_SIRET__c = oAccount.Code_SIRET__c;
        }
    }
    
    /*
     * Synchronisation du code SIRET du compte vers le code SIRET Payer de l'opty à la création de celle-ci
     */
    public static void syncPayer_Fields_Siret(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Payer__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Payer__c);
            oOpportunity.Payer_Siret__c = oAccount.Code_SIRET__c;
        }
    }
    
    /*
     * Synchronisation du code SIRET du compte vers le code SIRET Billed de l'opty à la création de celle-ci
     */
    public static void syncBilled_Fields_Siret(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Billed__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Billed__c);
            oOpportunity.Billed_SIRET__c = oAccount.Code_SIRET__c;
        }
    }
    
    /*
     * Synchronisation des mails du compte vers l'opty à la création de celle-ci
     */
    public static void syncEmailFromAccount(List<Opportunity> lOpportunitys){
        //if(!Test.isRunningTest()) {
            Map<Id, Account> mAccounts = AP_Opportunity.getAccounts(lOpportunitys);
            for (Opportunity oOpportunity : lOpportunitys){
                AP_Opportunity.syncDO_Fields_Email(oOpportunity, mAccounts);
                AP_Opportunity.syncPayer_Fields_Email(oOpportunity, mAccounts);
                AP_Opportunity.syncBilled_Fields_Email(oOpportunity, mAccounts);
                
            }
        //}
    }
    
    /*
     * Synchronisation des mails du compte vers les mails DO de l'opty à la création de celle-ci
     */
    public static void syncDO_Fields_Email(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.AccountId != null){
            Account oAccount = mAccounts.get(oOpportunity.AccountId);
            oOpportunity.DO_Email_2__c = oAccount.Email_2__c;
            oOpportunity.DO_Email__c = oAccount.Email__c;
            oOpportunity.DO_No_E_mail__c = oAccount.No_E_mail__c;
        }
    }
    
    /*
     * Synchronisation des mails du compte vers les mails Payer de l'opty à la création de celle-ci
     */
    public static void syncPayer_Fields_Email(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Payer__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Payer__c);
            oOpportunity.Payer_Email_2__c = oAccount.Email_2__c;
            oOpportunity.Payer_Email__c = oAccount.Email__c;
            oOpportunity.Payer_No_E_mail__c = oAccount.No_E_mail__c;
        }
    }
    
    /*
     * Synchronisation des mails du compte vers les mails Billed de l'opty à la création de celle-ci
     */
    public static void syncBilled_Fields_Email(Opportunity oOpportunity, Map<Id, Account> mAccounts){
        if (oOpportunity.Account_Billed__c != null){
            Account oAccount = mAccounts.get(oOpportunity.Account_Billed__c);
            oOpportunity.Billed_Email_2__c = oAccount.Email_2__c;
            oOpportunity.Billed_Email__c = oAccount.Email__c;
            oOpportunity.Billed_No_E_mail__c = oAccount.No_E_mail__c;
        }
    }
    
    /* 
     * Remplacement de la VR de l'histoire 301
     *
     * Déclenche une erreur quand le code SIRET ou la coche en cours d'immatriculation ne sont pas renseignés au niveau d'une opportunité 
     * lorsque celle-ci est modifiée ou quand le code siret n'est pas bien construit.
     */
    public static Boolean siretOuEnCoursDImmatUpdate(List<Opportunity> optiesToValidate, Boolean isTest){
        for(Opportunity opty:optiesToValidate){
            if((oUser.Bypass_Validation_Rules__c == false || isTest) && !IsInsert){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                if(isSiretOuEnCoursDImmatOptyInsert(opty)){
                    opty.DO_Code_SIRET__c.addError('Un et un seul des deux champs "Code SIRET" et "En cours d immatriculation" doit être renseigné.');
                }
            
                if((isSiretCodeOptyCorrect(opty))&&(opty.Project_Sub_Type__c != 'Credit')){
                    opty.DO_Code_SIRET__c.addError('Le code SIRET que vous avez entré est incorrect.');
                }
            }
        }
        
        return true;
    }
    
    /*
     * Déclenche une erreur quand le code SIRET ou la coche en cours d'immatriculation ne sont pas renseignés au niveau du compte 
     * lorsqu'une opportunité est créée ou quand le code siret n'est pas bien construit(hors conversion de suspect).
     */
    public static Boolean siretOuEnCoursDImmatInsert(List<Opportunity> optiesToValidate, Boolean isTest){
        map<Id, Opportunity> accountIDToOpportunity = new map<Id, Opportunity>();
        for(Opportunity op: optiesToValidate){
            accountIDToOpportunity.put(op.accountID, op);
        }
        
        for(Account acc: [SELECT Code_SIRET__c,
                                 En_cours_d_immatriculation__c,
                                 T_ByPassEmailPasDEmailEtSIRET__c,
                                 T_Is_Converted__c
                          FROM Account where id IN : accountIDToOpportunity.keySet()]){
            Opportunity opty = accountIDToOpportunity.get(acc.id);
            String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
            if(isSiretCodeAccountCorrectInsert(acc) && String.isBlank(opty.DO_Code_SIRET__c) && opty.DO_En_cours_d_immatriculation__c == false){
                if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                    opty.DO_Code_SIRET__c.addError('Veuillez renseigner le code SIRET car il est incorrect au niveau du compte associé.');
                }
            } else if(isSiretCodeAccountCorrectInsert(acc) && isSiretCodeOptyCorrect(opty)) {
                if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                    opty.DO_Code_SIRET__c.addError('Le code SIRET est incorrect.');
                }
            } else if(isSiretOuEnCoursDImmatAccountInsert(acc, opty) && String.isBlank(opty.DO_Code_SIRET__c) && opty.DO_En_cours_d_immatriculation__c == false){
                if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                    opty.DO_Code_SIRET__c.addError('Veuillez renseigner un et un seul des deux champs "Code SIRET" et "En cours d immatriculation" car cela est incorrect au niveau du compte associé.');
                }
            } else if(isSiretOuEnCoursDImmatAccountInsert(acc, opty) && isSiretOuEnCoursDImmatOptyUpdate(opty)){
                if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                    opty.DO_Code_SIRET__c.addError('Veuillez renseigner un et un seul des deux champs "Code SIRET" et "En cours d immatriculation".');
                }
            } else if(!isSiretOuEnCoursDImmatAccountInsert(acc, opty) && optyRecordTypeName != 'GEB Challenge Commercial' && String.isNotBlank(opty.AccountId)){
                syncSiretFromAccount(optiesToValidate);
            }
        }
        
        IsInsert = true;
        
        return true;
    }
    
    /*
     * Vérifie si le code SIRET est correct au niveau du compte
     */
    private static Boolean isSiretCodeAccountCorrectInsert(Account acc){
        Boolean error;
        
        if(String.isNotBlank(acc.Code_SIRET__c))  {  
            if(acc.Code_SIRET__c.length() == 14) {
                if(SiretValidation(acc.Code_SIRET__c)) {
                    error = true;
                } else {
                    error = false;
                }
            } else {
                error = true;
            }
        } else {
            error = false;
        }
        
        return error;
    }
    
    /*
     * Vérifie si le code SIRET est correct au niveau de l'opportunité
     */
    public static Boolean isSiretCodeOptyCorrect(Opportunity opty){
        Boolean error;
        
        if(String.isNotBlank(opty.DO_Code_SIRET__c))  {  
            if(opty.DO_Code_SIRET__c.length() == 14) {
                if(SiretValidation(opty.DO_Code_SIRET__c)) {
                    error = true;
                } else {
                    error = false;
                }
            } else {
                error = true;
            }
        } else {
            error = false;
        }
        
        return error;
    }
    
    /*
     * Vérifie si les champs SIRET ou En cours d'immatriculation sont renseignés au niveau du compte
     */
    private static Boolean isSiretOuEnCoursDImmatAccountInsert(Account acc, Opportunity opty){
        Boolean error;
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
            
        if(
                ((String.isBlank(acc.Code_SIRET__c) && acc.En_cours_d_immatriculation__c == false)
                || ((String.isNotBlank(acc.Code_SIRET__c)) && acc.En_cours_d_immatriculation__c))
            &&
                opty.T_AccountRecordTypeName__c == 'Pro'
            &&
                optyRecordTypeName != 'GEB Challenge Commercial'
            &&
                // Partie qui empêche l'erreur de se déclencher lors de la conversion d'un suspect
                (!acc.T_ByPassEmailPasDEmailEtSIRET__c && !acc.T_Is_Converted__c
                || acc.T_ByPassEmailPasDEmailEtSIRET__c && acc.T_Is_Converted__c)
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /*
     * Vérifie si les champs SIRET ou En cours d'immatriculation sont renseignés au niveau de l'opportunité
     * lors de la création de celle-ci
     */
    public static Boolean isSiretOuEnCoursDImmatOptyInsert(Opportunity opty){
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
        
        Boolean error;
        if(
                ((String.isBlank(opty.DO_Code_SIRET__c) && opty.DO_En_cours_d_immatriculation__c == false)
                || ((String.isNotBlank(opty.DO_Code_SIRET__c)) && opty.DO_En_cours_d_immatriculation__c))
            &&
                opty.T_AccountRecordTypeName__c == 'Pro'
            &&
                optyRecordTypeName != 'GEB Challenge Commercial'
            &&
                opty.Project_Sub_Type__c != 'Credit'
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /*
     * Vérifie si les champs SIRET ou En cours d'immatriculation sont renseignés au niveau de l'opportunité 
     * lors de la mise à jour de celle-ci
     */
    public static Boolean isSiretOuEnCoursDImmatOptyUpdate(Opportunity opty){
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
        
        Boolean error;
        if(
                ((String.isBlank(opty.DO_Code_SIRET__c) && opty.DO_En_cours_d_immatriculation__c == false)
                || ((String.isNotBlank(opty.DO_Code_SIRET__c)) && opty.DO_En_cours_d_immatriculation__c))
            &&
                opty.T_AccountRecordTypeName__c == 'Pro'
            &&
                optyRecordTypeName != 'GEB Challenge Commercial'
            &&
                opty.StageName == 'Closed Won'
            

        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /* 
     * Remplacement de la VR au niveau de l'opty pour l'histoire 305
     *
     * Déclenche une erreur quand l'email ou la coche pas d'email ne sont pas renseignés au niveau d'une opportunité lorsque
     * celle-ci est modifiée.
     */
    public static Boolean emailPasDEmailUpdate(List<Opportunity> optiesToValidate, Boolean isTest){
        if((oUser.Bypass_Validation_Rules__c == false || isTest) && !IsInsert){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
            for(Opportunity opty:optiesToValidate){
                if(isEmailPasDEmailDOOpty(opty)){
                    opty.DO_No_E_mail__c.addError('Le champ "Pas d’Email", au niveau de l’opportunité, doit être coché si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
                }
                if(isEmailPasDEmailBilledOpty(opty)){
                    opty.Billed_No_E_mail__c.addError('Le champ "Pas d’Email", au niveau de l’opportunité, doit être coché si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
                }
                if(isEmailPasDEmailPayerOpty(opty)){
                    opty.Payer_No_E_mail__c.addError('Le champ "Pas d’Email", au niveau de l’opportunité, doit être coché si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
                }
            }
        }
        
        return true;
    }
    
    /*
     * Déclenche une erreur quand l'email ou la coche pas d'email ne sont pas renseignés au niveau du compte lorsqu'une opportunité
     * est créée (hors conversion de suspect).
     */
    public static Boolean emailPasDEmailInsert(List<Opportunity> optiesToValidate, Boolean isTest){
        map<Id, Opportunity> accountIDToOpportunity = new map<Id, Opportunity>();
        for(Opportunity op: optiesToValidate){
            accountIDToOpportunity.put(op.accountID, op);
        }
        
        for(Account acc: [SELECT Email__c,
                                 Email_2__c,
                                 No_E_mail__c,
                                 T_ByPassEmailPasDEmailEtSIRET__c,
                                 T_Is_Converted__c
                          FROM Account where id IN : accountIDToOpportunity.keySet()]){
            Opportunity opty = accountIDToOpportunity.get(acc.id);
            if(oUser.Bypass_Validation_Rules__c == false || isTest){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
                if(isEmailPasDEmailAccount(acc, opty)){
                    opty.addError('Le champ "Pas d’Email", au niveau du compte, doit être coché si aucun e-mail n’est renseigné, et décoché si au moins un des champs e-mail est renseigné.');
                }
            }
            
            if(String.isNotBlank(opty.AccountId)) {
                syncEmailFromAccount(optiesToValidate);
            }
            
            IsInsert = true;
            
        }
        
        return true;
    }
    
    /*
     * Vérifie si les champs email ou pas d'email sont renseignés au niveau du compte
     */
    private static Boolean isEmailPasDEmailAccount(Account acc, Opportunity opty){
        Boolean error;
        
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
            
        if(
            (((acc.No_E_mail__c && String.isNotBlank(acc.Email__c))
            || (acc.No_E_mail__c && String.isNotBlank(acc.Email_2__c))
            || (acc.No_E_mail__c == false 
                && String.isBlank(acc.Email__c) 
                && String.isBlank(acc.Email_2__c)
                )
            )
            &&  
                optyRecordTypeName != 'GEB Challenge Commercial')
                
            // Partie qui empêche l'erreur de se déclencher lors de la conversion d'un suspect
            &&
                (!acc.T_ByPassEmailPasDEmailEtSIRET__c && !acc.T_Is_Converted__c
                || acc.T_ByPassEmailPasDEmailEtSIRET__c && acc.T_Is_Converted__c)
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /*
     * Vérifie si les champs email ou pas d'email DO sont renseignés au niveau de l'opportunité
     */
    public static Boolean isEmailPasDEmailDOOpty(Opportunity opty){
        Boolean error;
        
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
        
        if(
            (((opty.DO_No_E_mail__c && String.isNotBlank(opty.DO_Email__c))
            || (opty.DO_No_E_mail__c && String.isNotBlank(opty.DO_Email_2__c))
            || (opty.DO_No_E_mail__c == false 
                && String.isBlank(opty.DO_Email__c) 
                && String.isBlank(opty.DO_Email_2__c)
                )
            )
            &&  
                optyRecordTypeName != 'GEB Challenge Commercial')
            &&
                opty.StageName == 'Closed Won'
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /*
     * Vérifie si les champs email ou pas d'email Billed sont renseignés au niveau de l'opportunité
     */
    public static Boolean isEmailPasDEmailBilledOpty(Opportunity opty){
        Boolean error;
        
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
        
        if(
            (((opty.Billed_No_E_mail__c && String.isNotBlank(opty.Billed_Email__c))
            || (opty.Billed_No_E_mail__c && String.isNotBlank(opty.Billed_Email_2__c))
            || (opty.Billed_No_E_mail__c == false 
                && String.isBlank(opty.Billed_Email__c) 
                && String.isBlank(opty.Billed_Email_2__c)
                )
            )
            && 
                opty.FA_DO__c == false
            && 
                optyRecordTypeName != 'GEB Challenge Commercial')
            &&
                opty.StageName == 'Closed Won'
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }
    
    /*
     * Vérifie si les champs email ou pas d'email Payer sont renseignés au niveau de l'opportunité
     */
    public static Boolean isEmailPasDEmailPayerOpty(Opportunity opty){
        Boolean error;
        
        String optyRecordTypeName = recordTypeIdToName.get(opty.RecordTypeId);
        
        if(
            (((opty.Payer_No_E_mail__c && String.isNotBlank(opty.Payer_Email__c))
            || (opty.Payer_No_E_mail__c && String.isNotBlank(opty.Payer_Email_2__c))
            || (opty.Payer_No_E_mail__c == false 
                && String.isBlank(opty.Payer_Email__c) 
                && String.isBlank(opty.Payer_Email_2__c)
                )
            )
            && 
                opty.PA_DO__c == false
            && 
                optyRecordTypeName != 'GEB Challenge Commercial')
            &&
                opty.StageName == 'Closed Won'
        ) {
            error = true;
        } else {
            error = false;
        }

        return error;
    }   
    
    
    /* FRECA0 29/10/2014
     * Raises an error when the user tries to create an opty FIDE in V1DOM, V1LIB or V1PK from an IDEO, SOLO or ECOCFT contract 
     */
    public static Boolean checkExistingContractScale(List<Opportunity> optiesToValidate, map<Id, string>mOpportunityToContractScale){
        Boolean error;
        
        System.debug('[AP_Opportunity.checkExistingContractScale] START');
        
        set<string> setContractScalesToForbid = new set<string>(); 
        setContractScalesToForbid.add('CART1');
        setContractScalesToForbid.add('CART2');
        setContractScalesToForbid.add('ECOCFT');
        
        set<string> setPacksToAllow = new set<string>();
        setPacksToAllow.add('IDEO');
        setPacksToAllow.add('SOLO');
        setPacksToAllow.add('ECOCFT');
        setPacksToAllow.add('OPTIMO');
        
        
        /*map<Id,string> mOpportunityToContractScale = new map<Id,string>();
        List<Opportunity> fetchedOpportunity = [SELECT Contrat__r.Scale_c__c FROM Opportunity WHERE Id = :optiesToValidate];
        for(Opportunity oOpty:fetchedOpportunity){
            mOpportunityToContractScale.put(oOpty.Id, oOpty.Contrat__r.Scale_c__c);
        }*/
        
        
        if((oUser.Bypass_Validation_Rules__c == false)){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
            for(Opportunity opty:optiesToValidate){
                //System.debug('[AP_Opportunity.checkExistingContractScale] opty.T_Pack__c: [' + opty.T_Pack__c + ']');
                
                //System.debug('[AP_Opportunity.checkExistingContractScale] mOpportunityToContractScale.containsKey(opty.Id): [' + mOpportunityToContractScale.containsKey(opty.Id) + ']');
                if(mOpportunityToContractScale.containsKey(opty.Id)){
                    //System.debug('[AP_Opportunity.checkExistingContractScale] opty.Project_Type__c: [' + opty.Project_Type__c + ']');
                    if(opty.Project_Type__c == 'FIDE'){
                        //System.debug('[AP_Opportunity.checkExistingContractScale] mOpportunityToContractScale.get(opty.Id): [' + mOpportunityToContractScale.get(opty.Id) + ']');
                        //System.debug('[AP_Opportunity.checkExistingContractScale] setContractScalesToForbid.contains(mOpportunityToContractScale.get(opty.Id)): [' + setContractScalesToForbid.contains(mOpportunityToContractScale.get(opty.Id)) + ']');
                        //System.debug('[AP_Opportunity.checkExistingContractScale] setPacksToAllow.contains(opty.T_Pack__c): [' + setPacksToAllow.contains(opty.T_Pack__c) + ']');
                        if(setContractScalesToForbid.contains(mOpportunityToContractScale.get(opty.Id)) && !setPacksToAllow.contains(opty.T_Pack__c) ){
                            //System.debug('[AP_Opportunity.checkExistingContractScale] addError: [ TRUE ]');
                            opty.T_Pack__c.addError('Vous ne pouvez pas créer d\'opportunité FIDE autre que IDEO, SOLO, ECOCFT, OPTIMO.');
                        }
                    }
                } else {
                    //opty.T_Pack__c.addError('Pas de contrat trouvé.');
                }
            }
        }
        
        return true;
        
    }
    
    /* FRECA0 29/10/2014
     * Raises an error when the user tries to create a FIDE GesteCo on an IDEO, SOLO or ECOCFT opty from a V1DOM, V1LIB or V1PK contract 
     */
    public static Boolean preventFIDEGesteCoFromV1DOMtoIDEO(List<Opportunity> optiesToValidate, map<Id, string>mOpportunityToContractScale){
        Boolean error;
        
        System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] START');
        
        string sProjectSubType = 'GC';
        
        set<string> setContractScales = new set<string>(); 
        setContractScales.add('V1DOM');
        setContractScales.add('V1LIB');
        setContractScales.add('V1PK');
        
        set<string> setPacks = new set<string>();
        setPacks.add('IDEO');
        setPacks.add('SOLO');
        setPacks.add('ECOCFT');
        setPacks.add('OPTIMO');
        
        
        /*map<Id,string> mOpportunityToContractScale = new map<Id,string>();
        List<Opportunity> fetchedOpportunity = [SELECT Contrat__r.Scale_c__c FROM Opportunity WHERE Id = :optiesToValidate];
        for(Opportunity oOpty:fetchedOpportunity){
            mOpportunityToContractScale.put(oOpty.Id, oOpty.Contrat__r.Scale_c__c);
        }*/
        
        
        if((oUser.Bypass_Validation_Rules__c == false)){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
            for(Opportunity opty:optiesToValidate){
                System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] opty.T_Pack__c: [' + opty.T_Pack__c + ']');
                
                System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] mOpportunityToContractScale.containsKey(opty.Id): [' + mOpportunityToContractScale.containsKey(opty.Id) + ']');
                if(mOpportunityToContractScale.containsKey(opty.Id)){
                    System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] opty.Project_Type__c: [' + opty.Project_Type__c + ']');
                    if(opty.Project_Type__c == 'FIDE'){
                        System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] mOpportunityToContractScale.get(opty.Id): [' + mOpportunityToContractScale.get(opty.Id) + ']');
                        System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] setContractScales.contains(mOpportunityToContractScale.get(opty.Id)): [' + setContractScales.contains(mOpportunityToContractScale.get(opty.Id)) + ']');
                        System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] setPacks.contains(opty.T_Pack__c): [' + setPacks.contains(opty.T_Pack__c) + ']');
                        if(opty.Project_Sub_Type__c == sProjectSubType && setContractScales.contains(mOpportunityToContractScale.get(opty.Id)) && setPacks.contains(opty.T_Pack__c) ){
                            System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoIDEO] addError: [ TRUE ]');
                            opty.T_Pack__c.addError('Vous ne pouvez pas créer d\'opportunité FIDE Geste Co ' + opty.T_Pack__c + ' en partant d\'un contrat ' + mOpportunityToContractScale.get(opty.Id) + '.');
                        }
                    }
                } else {
                    //opty.T_Pack__c.addError('Pas de contrat trouvé.');
                }
            }
        }
        
        return true;
        
    }
    

    /*** FLA 10/11/201 récupère street name et lieu dit project du compte pour maj project street name et lieu dit sur opty */
    public static void updateProjectAddressFromAccountProjectAddress(List<Opportunity> lOpty)
    { 
        System.debug('[AP_Opportunity.updateProjectAddressFromAccountProjectAddress] START');
        System.debug('[AP_Opportunity.updateProjectAddressFromAccountProjectAddress] lOpty' + lOpty);

        for(Opportunity opty:lOpty)
        {
            if(opty.Activity_Domain__c == 'GEC - Gaz en citerne' || opty.Activity_Domain__c == 'GEB - Gaz en bouteille')
            {
                String streetName = opty.Street_name_project__c;
                String lieuDit = opty.Project_Place_Called__c;
                String streetLieuDit;
                System.debug('streetName:'+streetName);
                System.debug('lieuDit:'+lieuDit);

                if(streetName !=''&& streetName != null)
                {
                    if(streetName.length()<=27)
                    {
                        if(lieuDit !=''&& lieuDit != null)
                        {    
                            if(lieuDit.length()>35) opty.Lieu_dit_Project__c = lieuDit.substring(0, 35);
                            else opty.Lieu_dit_Project__c = lieuDit;
                        }
                    }
                    else
                    {
                        opty.Street_name_project__c = streetName.substring(0, 27);//limit 27c dans SAP
                        if(lieuDit !=''&& lieuDit != null)
                            streetLieuDit = streetName.substring(27, streetName.length())+' '+lieuDit;
                        else
                            streetLieuDit = streetName.substring(27, streetName.length());

                        if(streetLieuDit.length() > 35)
                            opty.Lieu_dit_Project__c = streetLieuDit.substring(0, 35);
                        else
                            opty.Lieu_dit_Project__c = streetLieuDit;
                    }
                }
                else if(lieuDit !=''&& lieuDit != null)
                {
                    if(lieuDit.length() > 35)
                        opty.Lieu_dit_Project__c = lieuDit.substring(0, 35);
                    else
                        opty.Lieu_dit_Project__c = lieuDit;
                }
            }
        }    
        System.debug('[AP_Opportunity.updateProjectAddressFromAccountProjectAddress] END');

    }
  
    
     /**** MLC 082016***/
    //MAJ du compteur de matricule sur le mandataire à chaque  création ou succession
 
   
    public static void updateReferenceClientSAP(List<Opportunity> optiesToValidate)
    { 
           System.debug('[AP_Opportunity.updateReferenceClientSAP] START');
           System.debug('[AP_Opportunity.updateReferenceClientSAP] opty' + optiesToValidate );
           String MandataireProjet ;
           Set<string> sMdt = new Set<string>();
          // Map<Id,Mandataire__c> mdt = new Map<Id,Mandataire__c>(); 
           
           for(Opportunity optyMdt:optiesToValidate) 
           {           
               if(!sMdt.contains(optyMdt.T_MandataireId__c)) sMdt.add(optyMdt.T_MandataireId__c);
             
           }
           
           try
           {
               Map<Id,Mandataire__c> mdt=new Map<Id,Mandataire__c>([SELECT id, MatriculeEnCours__c,ExternalID__c,Matricule_en_cours_GEB__c FROM Mandataire__c where id =: sMdt FOR UPDATE]);
     
                 
               for(Opportunity opty:optiesToValidate) 
               {                    
                
                     System.debug('[AP_Opportunity.updateReferenceClientSAP] opty avant ReferenceClientSAP__c   ' +  opty.ReferenceClientSAP__c  );  
                      System.debug('[AP_Opportunity.updateReferenceClientSAP] opty avant DO_AccountNumber__c  ' +  opty.DO_AccountNumber__c  ); 
                        System.debug('[AP_Opportunity.updateReferenceClientSAP] opty avant DO_ExternalID__c' +  opty.DO_ExternalID__c); 
                 /*   integer IdMandataire  = Integer.valueOf(mdt.get(opty.T_MandataireId__c).ExternalID__c);
                    integer MatriculeEnCours = Integer.valueOf(mdt.get(opty.T_MandataireId__c).MatriculeEnCours__c);
                    integer MAtriculeEnCoursGEB = Integer.valueOf(mdt.get(opty.T_MandataireId__c).Matricule_en_cours_GEB__c);*/
                    
                     if(opty.Activity_Domain__c == 'GEC - Gaz en citerne' || opty.Activity_Domain__c == 'GEB - Gaz en bouteille')
                     {
                        if (opty.ReferenceClientSAP__c ==null && opty.DO_AccountNumber__c ==null && opty.DO_ExternalID__c==null )
                        {
                    
                            if (opty.Project_Type__c=='CREA' ||  opty.Project_Type__c == 'SUCC') 
                            {
                            
                              integer IdMandataire  = Integer.valueOf(mdt.get(opty.T_MandataireId__c).ExternalID__c);
                              integer MatriculeEnCours = Integer.valueOf(mdt.get(opty.T_MandataireId__c).MatriculeEnCours__c);
                              integer MAtriculeEnCoursGEB = Integer.valueOf(mdt.get(opty.T_MandataireId__c).Matricule_en_cours_GEB__c);
                            
                               System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 CAS 1 ' ); 
                                if (opty.Activity_Domain__c == 'GEC - Gaz en citerne' )
                                {
                                    opty.ReferenceClientSAP__c = 'W' + ('0000000' + String.valueOf(MatriculeEnCours)).right(6) + IdMandataire;
                                    mdt.get(opty.T_MandataireId__c).MatriculeEnCours__c = MatriculeEnCours + 1;
                                    opty.DO_AccountNumber__c =  opty.ReferenceClientSAP__c;
                                }
                                
                                if (opty.Activity_Domain__c == 'GEB - Gaz en bouteille' )
                                {
                                    opty.ReferenceClientSAP__c = 'ZB' + ('0000000' + String.valueOf(MAtriculeEnCoursGEB)).right(5) + IdMandataire;
                                    mdt.get(opty.T_MandataireId__c).Matricule_en_cours_GEB__c = MAtriculeEnCoursGEB + 1;
                                    opty.DO_AccountNumber__c =  opty.ReferenceClientSAP__c;
                                }
                                
                                
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty avant ' +  opty.DO_AccountNumber__c  );  
                                  
                                
                              //  opty.DO_AccountNumber__c =  opty.ReferenceClientSAP__c;
                               
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m1 opty.DO_AccountNumber__c' +  opty.DO_AccountNumber__c  );
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m1 opty.ReferenceClientSAP__c' +  opty.ReferenceClientSAP__c  );
                         
                            }
                        }
                        else  if (opty.ReferenceClientSAP__c ==null && opty.DO_ExternalID__c!=null )
                         
                        {
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 CAS 2 ' );
                                opty.ReferenceClientSAP__c =opty.DO_ExternalID__c;
                                opty.DO_AccountNumber__c=opty.DO_ExternalID__c;
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 opty.DO_AccountNumber__c' +  opty.DO_AccountNumber__c  );
                                System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 opty.ReferenceClientSAP__c' +  opty.ReferenceClientSAP__c  );
                      
                        }
                        
                        else
                        
                        {
                        
                        System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 CAS 3 ' );
                        opty.DO_AccountNumber__c =  opty.ReferenceClientSAP__c;
                        System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 opty.DO_AccountNumber__c' +  opty.DO_AccountNumber__c  );
                        System.debug('[AP_Opportunity.updateReferenceClientSAP] opty m2 opty.ReferenceClientSAP__c' +  opty.ReferenceClientSAP__c  );
                        
                        }
                    
                        update mdt.values();
                
                    }       
                }
            }
            catch(Exception e)
            {
               
               System.debug('Pouvez vous retenter la convertion du suspect,svp ?');
               // object.addError(e.getMessage() + 'Texte Perso');
               

           }
          
       
        
    }
    
    
    /***/
    
    // Erwan 20190606 Moved to VR Prevent_GesteCo_and_MDS_DOM_OldContracts. Reason : Bug in this method and Apex code not needed for this check
    /*MLC*/
    public static Boolean preventFIDE_MSD_V37_FromV1DOMtoV1DOM(List<Opportunity> optiesToValidate, map<Id, string>mOpportunityToContractScale){
        Boolean error;
        
        System.debug('[AP_Opportunity.preventFIDEGesteCoFromV1DOMtoV1DOM] START');
        
    
        set<string> setProjectSubTypes = new set<string>(); 
        setProjectSubTypes.add('MDS');
        setProjectSubTypes.add('V37');
        
        
        set<string> setContractScales = new set<string>(); 
        setContractScales.add('V1DOM');
        setContractScales.add('V1LIB');
        setContractScales.add('V1PK');
        
        set<string> setPacksToForbid = new set<string>();
        setPacksToForbid.add('IDEO');
        setPacksToForbid.add('SOLO');
        setPacksToForbid.add('ECOCFT');
        setPacksToForbid.add('OPTIMO');
        
        
        //map<Id,string> mOpportunityToContractScale = new map<Id,string>();
        //
        //List<Opportunity> fetchedOpportunity = [SELECT Contrat__r.Scale_c__c FROM Opportunity WHERE Id = :optiesToValidate];
        //for(Opportunity oOpty:fetchedOpportunity){
        //    mOpportunityToContractScale.put(oOpty.Id, oOpty.Contrat__r.Scale_c__c);
        //}
        
        
        if((oUser.Bypass_Validation_Rules__c == false)){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
            for(Opportunity opty:optiesToValidate){
                System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] opty.T_Pack__c: [' + opty.T_Pack__c + ']');
                
                System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] mOpportunityToContractScale.containsKey(opty.Id): [' + mOpportunityToContractScale.containsKey(opty.Id) + ']');
                if(mOpportunityToContractScale.containsKey(opty.Id)){
                    System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] opty.Project_Type__c: [' + opty.Project_Type__c + ']');
                    if(opty.Project_Type__c == 'FIDE'){
                        System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] mOpportunityToContractScale.get(opty.Id): [' + mOpportunityToContractScale.get(opty.Id) + ']');
                        System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] setContractScales.contains(mOpportunityToContractScale.get(opty.Id)): [' + setContractScales.contains(mOpportunityToContractScale.get(opty.Id)) + ']');
                        System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] setPacksToAllow.contains(opty.T_Pack__c): [' + setPacksToForbid.contains(opty.T_Pack__c) + ']');
                        //if(setProjectSubTypes.contains(opty.Project_Sub_Type__c) && setContractScales.contains(mOpportunityToContractScale.get(opty.Id)) && (opty.T_Pack__c==null) ){
                        if(setProjectSubTypes.contains(opty.Project_Sub_Type__c) && setContractScales.contains(mOpportunityToContractScale.get(opty.Id)) && !setPacksToForbid.contains(opty.T_Pack__c) ){
                            System.debug('[AP_Opportunity.preventFIDE_MSD_V37_FromV1DOMtoV1DOM] addError: [ TRUE ]');
                            opty.T_Pack__c.addError('Seul le geste commercial est disponible pour cette offre.');
                            
                        }
                    }
                } else {
                    //opty.T_Pack__c.addError('Pas de contrat trouvé.');
                }
            }
        }
        
        return true;
        
    }
    
    
    /* FRECA0 04/12/2014
     * Displays a message if the Opty Account is a "Bailleur"
     */
    /*public static void checkOptyAccountBailleur(List<Opportunity> optiesToValidate){
        
        map<Id, boolean> mOpportunityToAccountBailleur = new map<Id, boolean>();
        
        List<Opportunity> fetchedOpportunity = [SELECT Account.Bailleur__c FROM Opportunity WHERE Id = :optiesToValidate];
        for(Opportunity oOpty:fetchedOpportunity){
            mOpportunityToAccountBailleur.put(oOpty.id, oOpty.Account.Bailleur__c);
        }
        
        if((oUser.Bypass_Validation_Rules__c == false)){//Bypass this error if Bypass_Validation_Rules__c is checked for the active user
            for(Opportunity opty:optiesToValidate){
                if(opty.Activity_Domain__c == 'GEC - Gaz en citerne' && opty.Project_market_type__c == 'DOM' && opty.Project_market_subtype__c == 'Domestique' ){
                    if(mOpportunityToAccountBailleur.containsKey(opty.Id)){
                        if(mOpportunityToAccountBailleur.get(opty.Id) == True){
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.crm_message + ' : '+  System.Label.Bailleur_Account));
                            
                        }
                    }
                }
            }
        }
        
    }*/
    
    
     public static map<Id,list<Opportunity>> getMapAccountidOpportunity(List<Opportunity> optiesToValidate){
         map<Id, list<Opportunity>> accountIDToOpportunity = new map<Id, list<Opportunity>>();
        for(Opportunity op: optiesToValidate){
            if( accountIDToOpportunity.containskey(op.accountID)){
                ((list<Opportunity>)accountIDToOpportunity.get(op.accountID)).add(op);
            }else{
                list<Opportunity> listeOpty= new list<Opportunity>();
                 accountIDToOpportunity.put(op.accountID, listeOpty);
            }
           if(null!=op.Prescriber_Account__c ){
               if( accountIDToOpportunity.containskey(op.Prescriber_Account__c)){
                ((list<Opportunity>)accountIDToOpportunity.get(op.Prescriber_Account__c)).add(op);
            }else{
                list<Opportunity> listeOpty= new list<Opportunity>();
                 accountIDToOpportunity.put(op.Prescriber_Account__c, listeOpty);
            }
           
           }
        }
        return accountIDToOpportunity;
    }
    
    
    Public static Map<id,Account> getRelatedAccountsDetail(map<Id,list<Opportunity>> accountIDToOpportunity){
        return new Map<id,Account> ([SELECT Email__c,
                                 Email_2__c,
                                 No_E_mail__c,MontantCourtageGEC__c,
                                 T_ByPassEmailPasDEmailEtSIRET__c,
                                 T_Is_Converted__c,
                                     Prescriber__c
                          FROM Account where id IN : accountIDToOpportunity.keySet()]);
    }
    
    
/**
*Redescente du montant du courtage GEC du compte prescripteur sur une opportunité prescrite. 
* compte tenu de l'existant et dans le but de ne pas faire une nouvelle requête je fais cet appel depuis la méthode emailPasDEmailInsert
*/
    public static void setMontantCourtageGEC(map<Id,list<Opportunity>> accountIDToOpportunity,Map<id,Account> mapRelatedAccountsDetail ){
        For ( Account acc:mapRelatedAccountsDetail.values()){
            if( acc.Prescriber__c && mapRelatedAccountsDetail.containsKey(acc.id) ){
                list<Opportunity> optyPrescrites= accountIDToOpportunity.get(acc.id);
                for(Opportunity opty: optyPrescrites){
                    if( acc.id==opty.Prescriber_Account__c){
                        if(null!=acc.MontantCourtageGEC__c ){
                            opty.Comimission_Amount__c=acc.MontantCourtageGEC__c;
                        }
                         opty.addError('Le montant de courtage doit être renseigné sur la fiche prescripteur !!');
                    }                 
                }
                
            }
        }
    }
    
}