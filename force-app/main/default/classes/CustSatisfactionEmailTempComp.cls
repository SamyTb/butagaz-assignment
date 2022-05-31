public class CustSatisfactionEmailTempComp {
    
    public map<integer,string> mapCryptageStatisfactionUrl{ 
        get { return prepareCustSatisfactionUrl (); } 
                                                          }
    /*
    public map<integer,string> mapNoteText{ 
        get { return  prepareMapNoteText (); } 
                                                          }

    
   public Boolean vOrderIdIsNotNull {
        get { 
            return (vOrderId != '' || vOrderId != NULL) ;
                } 
    }  
*/

    public String CryptageURL { get; set; }
    public String vOrderId {get; set;}
    public Account oAccount {get; set;} // set by component assignTo
    
    public        String recordFound = '';
    public        List<Account> lAccountsToUpdate = new List<Account>();

    public        string sEspaceClientEncryptKey = AP_PricingUtilities.getCustomSettingValue('Espace_Client_AES_Key');
    public        string sEspaceClientEncryptIv = AP_PricingUtilities.getCustomSettingValue('Espace_Client_AES_Iv');
    public        string sEspaceClientUrlGeb = AP_PricingUtilities.getCustomSettingValue('Espace_Client_Satisfaction_URL_GEB');
    public        string sEspaceClientUrlGec = AP_PricingUtilities.getCustomSettingValue('Espace_Client_Satisfaction_URL_GEC');
    public        string sUrl = '';
    public        string sParameters = '';
    public        string b64EncryptedData = '';
    public        string sFinalUrl = '';
    public        List<Order__c> orderitemList {get;set;}
    
    
    //Blob PrivateKey = Crypto.generateAesKey(256);
    blob key = EncodingUtil.base64Decode(sEspaceClientEncryptKey);
    blob iv = EncodingUtil.base64Decode(sEspaceClientEncryptIv);
    
    
    
    public  CustSatisfactionEmailTempComp(){
        
         

    }
    

    
        public map<integer,string> prepareCustSatisfactionUrl (){
           Map<integer,String> noteMapUrl = new Map<integer,String> ();
           
             if( vOrderId ==null ){
            //prepareCustSatisfactionUrl ();
                   noteMapUrl.put(4,'www.salesforce');
            		noteMapUrl.put(5,'www.salesforce');
            		noteMapUrl.put(6,'www.salesforce');
          }else{
              
               Order__c vOrder=    [SELECT Id, Order_Origin__c,Created_By_value__c,Name,Activity_Domain__r.ExternalID__c,Account__r.ExternalID__c  from Order__c where Id = :vOrderId];
               if(vOrder.Activity_Domain__c != null && (vOrder.Activity_Domain__r.ExternalID__c == 41 || vOrder.Activity_Domain__r.ExternalID__c == 42))
            {         
              
                   
            
                
            
                if(vOrder.Account__r.ExternalID__c!= null){
                    
                   
                    
                        
                    sUrl = vOrder.Activity_Domain__r.ExternalID__c == 41 ? sEspaceClientUrlGeb : sEspaceClientUrlGec;
                    
                     noteMapUrl.put(1,'www.salesforce');
            		noteMapUrl.put(2,'www.salesforce');
            		noteMapUrl.put(3,'www.salesforce');
                    
                    
                    for (integer note=1;note<=10;note++){
                        sParameters = 'AccountNumber='+vOrder.Account__r.ExternalID__c+'&SatisfactionCdeOrigine='+vOrder.Order_Origin__c+'&SatisfactionCdeValeurAC='+vOrder.Created_By_value__c+'&SatisfactionCdeNote='+note; 
                        blob textBlob = blob.valueOf(sParameters);
                        blob encryptedData = Crypto.encrypt('AES256', key, iv, textBlob);
                        // To remove after debug
                        blob decryptedData = Crypto.decrypt('AES256', key, iv, encryptedData);
                        b64EncryptedData = EncodingUtil.base64Encode(encryptedData);
                        String sUrlPourNote = sUrl + EncodingUtil.urlEncode(b64EncryptedData, 'UTF-8');
                        noteMapUrl.put(note, sUrlPourNote);
                        System.debug(logginglevel.WARN,'### sUrlPourNote = ' + sUrlPourNote);
                        
                    }


                }else{                
                    System.debug(logginglevel.WARN,'Account with external id null: contruction url note statisfaction impossible');                   
                }

            }    
              
              
/*              
              if (vOrder !=null){
                   noteMapUrl.put(1,'www.salesforce');
            		noteMapUrl.put(2,'www.salesforce');
            		noteMapUrl.put(3,'www.salesforce');
              }else{
                   noteMapUrl.put(11,'www.salesforce');
            		noteMapUrl.put(21,'www.salesforce');
            		noteMapUrl.put(31,'www.salesforce');
              }
                   
          */  
          }

            return noteMapUrl;  
    }
  
}