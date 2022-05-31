/*
 * Controller for the Opportunity Creation button from Account / Contract
 */
public class VFC_NewOpportunity {

    /** CONSTANTS **********/
    static final Decimal GEB_EXTERNAL_ID = 41;
    static final Decimal GEC_EXTERNAL_ID = 42;
    static final Decimal GPLC_EXTERNAL_ID = 43;
    static final Decimal GER_EXTERNAL_ID = 45;

    static final String PRO_MARKET_TYPE = 'PRO';
    static final String DOM_MARKET_TYPE = 'DOM';
    /***********************/


    /***INNER CLASS ********/
    class Url{
        private List<String> urlParameters;
        
        public Url(){
            urlParameters = new List<String>();
        }
        
        public void addParameter(String key, String value){
            if(value != null) 
                urlParameters.add(key+'='+value);
        } 
        
        public void addParameter(String key, Id value){
            addParameter(key, String.valueOf(value));
        }
        
        public String getAllParameters(){
            return String.join(urlParameters,'&');
        } 
    }
    /***********************/
     
     
    private ApexPages.Standardcontroller standardController;


    //Constructor
    public VFC_NewOpportunity(ApexPages.Standardcontroller standardController){
        this.standardController = standardController;
    }
    
   
    /*
     * Method called by the Button New Opty from Account
     */
     public PageReference redirectFromAccountToNewOpty(){        
        Account account = (Account) this.standardController.getRecord();

        account = [
            SELECT Id, Activity_Domain__c, Market_Type__c, AccountNumber, Prescriber__c, Channel__c, recordType.Name  
            FROM Account 
            WHERE Id = :account.Id
        ];
        
        return redirectToNewOpty(account, null, null, null);
     }
     
        
    /*
     * Method called by the Button New Opty from Contract
     */
     public PageReference redirectFromContractToNewOpty(){         
          Contract contract = (Contract) this.standardController.getRecord();
          
          contract = [
            SELECT Id, Name, AccountId, PTL__c, PTL__r.Name, PTL__r.Street_Name__c, PTL__r.Street_Number__c, PTL__r.Street_Type__c,
                PTL__r.Place_Called__c, PTL__r.Number_Extention__c, PTL__r.City_Postal_Code__c,
                PTL__r.City_Postal_Code__r.Name
            FROM Contract
            WHERE Id = :contract.Id
          ];
          
          Account account=null;
          list<Account> laccount = [
            SELECT Id, Activity_Domain__c, Market_Type__c, AccountNumber, Prescriber__c, Channel__c, recordType.Name  
            FROM Account 
            WHERE Id = :contract.AccountId
          ];
          if(laccount .size()>0){
              account=laccount .get(0);
          }
                    
        String conditionPayeur = contract.Name+'RG';
          Account_in_Contract__c payeur=null; 
          list<Account_in_Contract__c> lpayeur = [
            SELECT Id, Account__c, Contract__c, ExternalID__c, Role__c,account__r.Name, account__r.Id
            FROM Account_in_Contract__c 
            WHERE ExternalID__c = :conditionPayeur 
          ];
          if(lpayeur.size()>0){
              payeur =lpayeur.get(0);
          }
          
          String conditionFacture = contract.Name+'RE';
          
          Account_in_Contract__c facture=null;
          list<Account_in_Contract__c> lfacture= [
            SELECT Id, Account__c, Contract__c, ExternalID__c, Role__c,account__r.Name, account__r.Id
            FROM Account_in_Contract__c 
            WHERE ExternalID__c = :conditionFacture 
          ];
          if(lfacture.size()>0){
              facture=lfacture.get(0);
          }          
          return redirectToNewOpty(account, contract, payeur, facture);
     }
     
     
     
      /*
       * Generate de redirection to new Opty
       */
       public PageReference redirectToNewOpty(Account account, Contract contract,Account_in_Contract__c payeur, Account_in_Contract__c facture){
            
           try {
               
                if(account.Prescriber__c){
                    //Exit if the Account is a prescriber, we lauch a blocking exception.
                    throw new AP_CRMException(Label.Account_OpportunityCreation_ErrorMessage);
                }
    
                //Figure out the good Record Type based on Account datas
                Id recordTypeId  = getRecordTypeByAccountData(
                                                account.Activity_Domain__c, 
                                                account.Market_Type__c, 
                                                account.AccountNumber, 
                                                account.Id, 
                                                account.channel__c,
                                                account.recordType.Name);
    
                //And build the url
                Url url = buildUrlParametersToNewOpty(account, contract, recordTypeId, payeur, facture);
                
                //Opportunity Code Url
                String codeUrlOpty = '006/e';
                return new PageReference('/' + codeUrlOpty + '?' + url.getAllParameters());
    
            } catch (AP_CRMException e) {
                ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(error);
                return null;
            }
       }
       
       
       
      /*
       * Generate the Url to new Opty
       */
       public Url buildUrlParametersToNewOpty(Account account, Contract contract, Id recordTypeId, Account_in_Contract__c payeur, Account_in_Contract__c facture){
                
            Url url = new Url();
                                  
            url.addParameter('accid', account.Id);
            url.addParameter('RecordType', recordTypeId);
            url.addParameter('ent', 'Opportunity');
             
            OrganizationSettings__c orgSettings = OrganizationSettings__c.getInstance();
             
            //Client type
            if(account.channel__c != null)
                url.addParameter(orgSettings.Opty_FieldId_ClientType__c, account.channel__c);
            
            //Specific part for whether Contract or Account context               
            if (contract != null){
                //If there is a Contract, use additional information from there.
                
                String existingPTLFieldId            = orgSettings.Opty_FieldId_ExistingPTL__c;
                String existingContractFieldId       = orgSettings.Opty_FieldId_Contrat__c;
                String projectStreetNameFieldId      = orgSettings.Opty_FieldId_ProjectStreetName__c;
                String projectStreetNumberFieldId    = orgSettings.Opty_FieldId_ProjectStreetNumber__c;
                String projectStreetTypeFieldId      = orgSettings.Opty_FieldId_ProjectStreetType__c;
                String projectPlaceCalledFieldId     = orgSettings.Opty_FieldId_ProjectPlaceCalled__c;
                String projectNumberExtensionFieldId = orgSettings.Opty_FieldId_ProjectStreetNumberExt__c;
                String projectCityPostalCodeFieldId  = orgSettings.Opty_FieldId_ProjectCityPostalCode__c; 
                String projectTypeFieldId            = orgSettings.Opty_FieldId_ProjectType__c;
                String accountBilledId               = orgSettings.Opty_FieldId_Billed__c;
                String accountPayerId                = orgSettings.Opty_FieldId_Payer__c;
                 
                url.addParameter('CF' + existingPTLFieldId,             contract.PTL__r.Name);               
                url.addParameter('CF' + existingPTLFieldId + '_lkid',   contract.PTL__c);
                url.addParameter('CF' + existingContractFieldId,             contract.Name);               
                url.addParameter('CF' + existingContractFieldId + '_lkid',   contract.Id);
                
                //Account Payer and Billed prefilled
                if(facture != null){
                url.addParameter('CF' + accountBilledId,             facture.account__r.Name);               
                url.addParameter('CF' + accountBilledId+ '_lkid',   facture.account__r.Id);
                }
                if(payeur != null){
                url.addParameter('CF' + accountPayerId,             payeur.account__r.Name);               
                url.addParameter('CF' + accountPayerId+ '_lkid',   payeur.account__r.Id);
                }
                            
                url.addParameter(projectStreetNameFieldId, contract.PTL__r.Street_Name__c);
                
                url.addParameter(projectStreetNumberFieldId, contract.PTL__r.Street_Number__c);
                url.addParameter(projectStreetTypeFieldId, contract.PTL__r.Street_Type__c);
                url.addParameter(projectPlaceCalledFieldId, contract.PTL__r.Place_Called__c);
                url.addParameter(projectNumberExtensionFieldId, contract.PTL__r.Number_Extention__c);
                url.addParameter('CF' + projectCityPostalCodeFieldId, contract.PTL__r.City_Postal_Code__r.Name);
                url.addParameter('CF' + projectCityPostalCodeFieldId, contract.PTL__r.City_Postal_Code__c);
                url.addParameter(projectTypeFieldId, 'FIDE');
                
                url.addParameter('retURL', '/'+contract.Id);
            } else {
                
                String projectTypeFieldId = orgSettings.Opty_FieldId_ProjectType__c;
                url.addParameter(projectTypeFieldId, 'EXTE');
                url.addParameter('retURL', '/'+account.Id);
            }//TODO: PTL => SUCC.
            
            return url;
       }
       
       
    /*
     * Determine what's the best Opportunity Record type to choose based on the activity Domain, the market type and the account number
     */
    private Id getRecordTypeByAccountData(Id activityDomainId, String marketType, String matricule, Id accountId, String channel, String recordType){
        
        String debug = 'Find out the RecordTypeId : '+
                       'activityDomainId = '+activityDomainId+', '+
                       'marketType = '+marketType+', '+ 
                       'matricule = '+matricule+', '+ 
                       'accountId = '+accountId+', '+ 
                       'channel = '+channel+', ';                      
        System.debug(debug); 
        
        //fetch the customSettings related to the Opty Record types
        Map<String , RecordTypes_OpportunityToQuote__c> mappingRecordType = RecordTypes_OpportunityToQuote__c.getAll();

        if(mappingRecordType == null || mappingRecordType.size() == 0){ 
            //Exit if there is no Custom settings configured on the env.
            System.debug('Failed to retrieve RecordTypes_OpportunityToQuote__c Custom Setting.'); 
            throw new AP_CRMException(Label.Account_OpportunityCreation_ErrorMessage);
        }

        Id targetRecordTypeId = null;

        map<Id,Decimal> mapActivityDomain = retrieveAllActivityDomain();

        Decimal activitydomainExtId = mapActivityDomain.get(activityDomainId);
        if(activitydomainExtId != null){

            // /!\ Please, take care to the order of the following tests (GEB, GEC, etc)
            // As they all potentially impact the var targetRecordTypeId :
            // a result can override another previous one result !

            //TODO Gros Vrac
            if(false){
                targetRecordTypeId = getTargetRecordTypeId('GrosVrac', mappingRecordType);
            }

            //GEB
            if(activitydomainExtId == GEB_EXTERNAL_ID && channel == 'CS'){
                targetRecordTypeId = getTargetRecordTypeId('GEB CONS', mappingRecordType);
            }
            if(activitydomainExtId == GEB_EXTERNAL_ID && channel == 'RE'){
                targetRecordTypeId = getTargetRecordTypeId('GEB RE', mappingRecordType);
            }

            //GEC
            if(activitydomainExtId == GEC_EXTERNAL_ID){

                //GEC DOM
                if(DOM_MARKET_TYPE.equals(marketType)){
                    targetRecordTypeId = getTargetRecordTypeId('GEC DOM', mappingRecordType);
                }

                 //GEC PRO
                if(PRO_MARKET_TYPE.equals(marketType) || (recordType != null && PRO_MARKET_TYPE.equals(recordType.toUpperCase()))){
                    targetRecordTypeId = getTargetRecordTypeId('GEC PRO', mappingRecordType);
                }

                //GEC ENERGIGAZ
                if(matricule != null && matricule.startsWith('PR')){
                    targetRecordTypeId = getTargetRecordTypeId('GEC energigaz', mappingRecordType);
                }

            }

            //GER
            if(activitydomainExtId == GER_EXTERNAL_ID){

                //GER Propriétaire
                if(matricule != null && matricule.startsWith('PR')){
                    targetRecordTypeId = getTargetRecordTypeId('GER Proprietaire', mappingRecordType);
                }

                //GER Usager
                if(matricule != null && (matricule.startsWith('U') || matricule.startsWith('L'))){
                    targetRecordTypeId = getTargetRecordTypeId('GER Usager', mappingRecordType);
                }
            }

            //GPLc
            if(activitydomainExtId == GPLC_EXTERNAL_ID){    
                targetRecordTypeId = getTargetRecordTypeId('GPLc', mappingRecordType);
            }


        }else{ System.debug('No Activity Domain retrieved for the Id : '+activityDomainId); }

        if(targetRecordTypeId == null){
            System.debug('No Record Type figured out for a new Opportunity for the account : '+accountId);
            targetRecordTypeId = getDefaultRecordTypeId(mappingRecordType);
        }

        return targetRecordTypeId;
    }

    /*
     * Retrieve the configured mapping for the given Record Type code and set the targetRecordTypeId passed in parameter
     */
    private Id getTargetRecordTypeId(String codeRecordType, Map<String , RecordTypes_OpportunityToQuote__c> mappingRecordType){
        Id targetRecordTypeId = null;

        RecordTypes_OpportunityToQuote__c mapping = mappingRecordType.get(codeRecordType);
        if(mapping != null){ targetRecordTypeId = mapping.OpportunityRecordType__c; }
        else{ System.debug('No Record Type Mapping found for ['+codeRecordType+'] on RecordTypes_OpportunityToQuote__c Custom Settings'); }

        return targetRecordTypeId;
    }

    /*
     * Extract the default Record Type Id from the mapping passed in parameter
     */
    private Id getDefaultRecordTypeId(Map<String , RecordTypes_OpportunityToQuote__c> mappingRecordType){
        Id defaultRecordTypeId = null;

        if(mappingRecordType != null){
            RecordTypes_OpportunityToQuote__c defaultRecordType = mappingRecordType.get('GEC DOM');

            if(defaultRecordType != null){
                defaultRecordTypeId = defaultRecordType.OpportunityRecordType__c;
            } else { System.debug('No Default Record Type found for GEC DOM on RecordTypes_OpportunityToQuote Custom Settings'); }
        } 

        return defaultRecordTypeId;
    }


    /*
     * Fetch all the activity Domains and return a map
     */
    private map<Id,Decimal> retrieveAllActivityDomain(){
        List<Activity_Domain__c> listeActivityDomain = [SELECT Id, ExternalID__c FROM Activity_Domain__c];

        map<Id,Decimal> mapActivityDomain = new map<Id,Decimal>();

        for(Activity_Domain__c ad:listeActivityDomain){
            mapActivityDomain.put(ad.Id, ad.ExternalID__c);
        }

        return mapActivityDomain;
    }
   
}