public class VFC_NewQuote_01 {

    ApexPages.StandardController stdController;

    public VFC_NewQuote_01(ApexPages.StandardController stdController) {
        this.stdController = stdController;
    }
    
    public String sOptyReason {get; set;}
    public String sProjectType {get; set;}
    public Decimal sActivityDomain {get; set;}
    public Boolean bError {get; set;}
    
    
    private boolean controlOPTL(){
        //query 
        Opportunity opty = [SELECT Id,
                                  Number_of_OPTL__c,
                                  Account.Activity_Domain__r.ExternalID__c,
                                  project_type__c,
                                  RecordTypeID,
                                  Opportunity_Reason__c
                             FROM Opportunity 
                             WHERE Id =:(this.stdController.getRecord()).ID limit 1];
    	
    	// ELC 20141121 Check Opty Reason
    	sOptyReason = (opty != null) ? opty.Opportunity_Reason__c : null;
    	sProjectType = (opty != null) ? opty.project_type__c : null;
    	sActivityDomain = (opty.Account.Activity_Domain__r.ExternalID__c != null) ? opty.Account.Activity_Domain__r.ExternalID__c : null;
    	
        String projectType = (opty != null) ? opty.project_type__c : null;
        Boolean isChallengeCom = (opty != null) ? opty.RecordTypeID == AP_PricingUtilities.getOpportunityRecordTypeValue('GEB Challenge Commercial') : false;
        if(projectType != null && !projectType.equals('FIDE') ){
            if(opty.Account.Activity_Domain__r.ExternalID__c == 41 && !isChallengeCom ){
                if(opty.Number_of_OPTL__c < 1 || opty.Number_of_OPTL__c > 1){
                    return false;
                }
            }
        }
        return true;
    }
    
    public PageReference newQuote(){
        
        bError = false;
        if(!controlOPTL()){
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.FATAL,System.Label.OPTL_mandatory));
            bError = true;
        }
        // ELC 20141121 Check Opty Reason
        if (sActivityDomain != null){
	        if(sProjectType != null){
		        if(sOptyReason == null && sActivityDomain == 42 && (sProjectType == 'CREA' || sProjectType == 'FIDE')){
		            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.FATAL,System.Label.Opty_Reason_Mandatory));
		            bError = true;
		        }
	        }
        }
        
        if(bError){
        	return null;
        }
        
             
        //fetch the customSettings related to the Quote/Opty Record type
        Map<String , RecordTypes_OpportunityToQuote__c> customSettings = RecordTypes_OpportunityToQuote__c.getAll();
        //build the map with the id
        map<Id,Id> mapRTQuoteIdRTOptyId = new map<Id,Id>();
       
        //feed the map
        for (String s : customSettings.keySet()) {
            RecordTypes_OpportunityToQuote__c rt = customSettings.get(s);
            if(rt != null){
                mapRTQuoteIdRTOptyId.put(rt.OpportunityRecordType__c, rt.QuoteRecordType__c);
            }
        }
        System.debug('map RT'+ mapRTQuoteIdRTOptyId);
        
        // Fetch Opty link to the Quote
        //Opportunity opty = (Opportunity) this.stdController.getRecord();
        //query 
        Opportunity opty = [SELECT Id,
                                   Project_Type__c,
                                   recordtypeid,
                                   DO_Price_Group__c,
                                   DO_Payment_Time_Code__c,
                                   DO_Payment_method__c,
                                   DO_Invoicing_Frequency__c,
                                   Existing_PTL__c,
                                   Existing_PTL__r.VAT_Code__c,
                                   Existing_PTL__r.Shipping_Condition__c,
                                   Existing_PTL__r.Scale__c,
                                   Existing_PTL__r.Account_Groupement__c,
                                   Existing_PTL__r.Account_Groupement__r.Name,
                                   Existing_PTL__r.Emballage_Pivot__c,
                                   Contrat__c,
                                   Contrat__r.Condition_for_Payment_Package_Code__c,
                                   Contrat__r.Contract_Term_year__c
                             FROM Opportunity 
                             WHERE Id =:(this.stdController.getRecord()).ID limit 1];
               
        //build url
        List<String> urlParameters = new List<String>{};
        //https://cs7.salesforce.com/0Q0/e?retURL=%2F006M0000004e9aX&oppid=006M0000004e9aX&RecordType=012M0000000Cr6H&ent=Quote
        
        //url Ret
        List<String> urlRet = new List<String> {'retURL', '/'+opty.Id };
        String sRet = String.join( urlRet , '=');
        urlParameters.add(sRet);
    
         //url OPTY
        List<String> urlOPTY = new List<String> {'oppid', opty.Id };
        String sOpty = String.join( urlOPTY , '=');
        urlParameters.add(sOpty);
        
        OrganizationSettings__c orgSettings = OrganizationSettings__c.getInstance();
                    
        //url prefil others fields (most we can) in case of FIDE
        String projectType = (opty != null) ? opty.project_type__c : null;
        if(projectType != null && projectType.equals('FIDE')){

            
            String FacturationCalendarFieldId = orgSettings.Quote_FieldId_Facturation_calendar__c ;
            urlParameters.add(FacturationCalendarFieldId + '=' + opty.DO_Invoicing_Frequency__c);
            
            String DOPaymentMethodFieldId = orgSettings.Quote_FieldId_DO_Payment_method__c ;
            urlParameters.add(DOPaymentMethodFieldId + '=' + opty.DO_Payment_method__c);
            
            String ScaleFieldId = orgSettings.Quote_FieldId_scale__c ;
            urlParameters.add(ScaleFieldId + '=' + opty.DO_Price_Group__c);
            
            String VATCodeFieldId = orgSettings.Quote_FieldId_VAT_Code__c ;
            urlParameters.add(VATCodeFieldId + '=' + opty.Existing_PTL__r.VAT_Code__c);
            
            String ShippingConditionFieldId = orgSettings.Quote_FieldId_Shipping_Condition__c ;
            urlParameters.add(ShippingConditionFieldId + '=' + opty.Existing_PTL__r.Shipping_Condition__c);
            
            String ProductScaleFieldId = orgSettings.Quote_FieldId_Product_Scale__c ;
            urlParameters.add(ProductScaleFieldId + '=' + opty.Existing_PTL__r.Scale__c);
            
            String DOGroupementFieldId = orgSettings.Quote_FieldId_DO_Groupement__c;
            if(opty.Existing_PTL__r.Account_Groupement__c != null){
                urlParameters.add('CF' + DOGroupementFieldId + '=' + opty.Existing_PTL__r.Account_Groupement__r.Name);
                urlParameters.add('CF' + DOGroupementFieldId + '_lkid=' + opty.Existing_PTL__r.Account_Groupement__c);
            }
            
            String PaymentSpreadFieldId = orgSettings.Quote_FieldId_Payment_spread__c  ;
            String paymentSpread;
            if(opty.Contrat__r.Condition_for_Payment_Package_Code__c != null){
                 paymentSpread = opty.Contrat__r.Condition_for_Payment_Package_Code__c;
            }else{
                paymentSpread = opty.DO_Payment_Time_Code__c;
            }
            urlParameters.add(PaymentSpreadFieldId + '=' + paymentSpread );
            
            
            String ContractDurationFieldId = orgSettings.Quote_FieldId_Contract_Duration__c;
            urlParameters.add(ContractDurationFieldId + '=' + opty.Contrat__r.Contract_Term_year__c );
        }
        
        String emballagePivotFieldId = orgSettings.Quote_FieldId_Emballage_Pivot__c ;
        urlParameters.add(emballagePivotFieldId + '=' + opty.Existing_PTL__r.Emballage_Pivot__c);
            
        //url RT
        Id rtOptyId = opty.RecordTypeId;
        String rtID = String.valueOf(mapRTQuoteIdRTOptyId.get(rtOptyId ));
        List<String> urlRT = new List<String> {'RecordType', rtID };
        String sRt = String.join( urlRT , '=');
        urlParameters.add(sRt);
       
        //url Quote
        List<String> urlQuote = new List<String> {'ent', 'Quote' };
        String sQuote = String.join( urlQuote , '=');
        urlParameters.add(sQuote );
        
        //https://cs7.salesforce.com/0Q0/e?retURL=%2F006M0000004e9aX&oppid=006M0000004e9aX&RecordType=012M0000000Cr6H&ent=Quote
        //final url
        String urlEnd = String.join(urlParameters ,'&');
        String quoteId = orgSettings.Quote_ObjectId__c;
        List<String> finalUrl = new List<String> {quoteId +'/e', urlEnd};
        
        String sFinalUrl = String.join(finalUrl, '?');
        
        return new PageReference('/' + sFinalUrl );
        
        /**    
        //if FIDE 
        String projectType = (opty != null) ? opty.project_type__c : null;
        if(projectType != null && projectType.equals('FIDE')){
            Quote oQuote = new Quote() ;
            oQuote.opportunityID = opty.ID;
            oQuote.recordTypeID = rtID;
            oQuote.name = 'Devis Fidélisation';
            oQuote.contract_duration__c = '7';
            try{
                insert oQuote;
            }
            catch(DMLException e){
                return new PageReference('/' + sFinalUrl );
            }
            //https://cs7.salesforce.com/0Q0M0000000HWfb/e?retURL=%2F0Q0M0000000HWfbKAG
            return new PageReference('/' + oQuote.ID + '/e?retURL=/' + oQuote.ID );
        
        }else{
            //iF NOT FIDE 
            return new PageReference('/' + sFinalUrl );
        }
        **/
    }
    
}