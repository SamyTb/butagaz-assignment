public without sharing class AP03Contact {

    private final static String sTemporaryAccount='enveloppe';
    private final static String sConvertionStatus='todelete';
    
    public static void convertToPA(set<Id> sContactToManage){

        System.Debug('##>>> AP03Contact.convertToPA : Number of Contact To Manage->'+sContactToManage.size()+' <<< run by ' + UserInfo.getName());
        
        RecordType rtPA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='External_Contact' LIMIT 1];
        RecordType rtBA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];

        List<Contact> lContactToConvert=[select Id,AccountId,ownerId from Contact where id in:sContactToManage];

        Integer i=0;
        List<Account> lEnveloppeAccountToInsert=new List<Account>();
   
        for(Contact oContact: lContactToConvert){
           
            // create a new account and set the record type to business account
            Account newAccount = new Account();
            newAccount.Name=sTemporaryAccount+' '+i;
            newAccount.RecordTypeId = rtBA.Id;
            newAccount.ownerId=oContact.ownerId;
            newAccount.CT_statutConversion__c=sConvertionStatus;
            MapFieldToAccount(oContact,newAccount);
            lEnveloppeAccountToInsert.add(newAccount);
            
            System.Debug('##>>> AP03Contact.convertToPA : New enveloppe Account->'+newAccount+' <<< run by ' + UserInfo.getName());
            System.Debug('##>>> AP03Contact.convertToPA : New enveloppe Account Contact->'+oContact+' <<< run by ' + UserInfo.getName());
            i++;
        }


        System.Debug('##>>> AP03Contact.convertToPA : insert lEnveloppeAccountToInsert->'+lEnveloppeAccountToInsert+' <<< run by ' + UserInfo.getName());
        insert lEnveloppeAccountToInsert;

        i=0;
                        
        for(Contact oContact: lContactToConvert){
            // We Link the contact to convert to the new Accounts we just created
            oContact.CT_OriginalAccountId__c=oContact.AccountId;
            oContact.AccountId= lEnveloppeAccountToInsert[i].Id;
            oContact.A_Convertir__c=false;
            System.Debug('##>>> AP03Contact.convertToPA : update lContactToConvert->'+oContact+' <<< run by ' + UserInfo.getName());   
           i++;
        }

        List<Account> lEnveloppeAccountToUpdate=new List<Account>();
        System.Debug('##>>> AP03Contact.convertToPA : update lContactToConvert->'+lContactToConvert+' <<< run by ' + UserInfo.getName());
        update lContactToConvert;

        for(Account oAccount:[select Id,REcordTypeId,IsPersonAccount from Account where Id in:lEnveloppeAccountToInsert]){
            
            oAccount.RecordTypeId=rtPA.Id;
            lEnveloppeAccountToUpdate.add(oAccount);
        }

        System.Debug('##>>> AP03Contact.convertToPA : update lEnveloppeAccountToUpdate->'+lEnveloppeAccountToUpdate+' <<< run by ' + UserInfo.getName());
        update lEnveloppeAccountToUpdate;

    }
    
    
     public static void MapFieldToAccount(Contact c,Account a){

        if(a.Street_Number__c=='' ){
            a.Street_Number__c=c.Street_Number__c;
        }
        if(a.Postal_Box__c=='' ){
            a.Postal_Box__c=c.Postal_Box__c;
        }
         
        if(a.Postal_Code__c==''){
            a.Postal_Code__c=c.Postal_Code__c;
        }
        if(a.City__c=='' ){
            a.City__c=c.City__c;
        }
        if(a.Email__c==''){
            a.Email__c=c.Email;
        }
        if(a.Email_2__c=='' ){
            a.Email_2__c=c.Email_2__c;
        }

        if(a.Fax=='' ){
            a.Fax=c.Fax;
        }
        if(a.Place_Called__c==''){
            a.Place_Called__c=c.Place_Called__c;
        }
     
        if(a.Country__c=='' ){
            a.Country__c=c.Country__c;
        }
        if(a.Phone==''){
            a.Phone=c.Phone;
        }
        if(a.Mobile_Phone_Number__c=='' ){
            a.Mobile_Phone_Number__c=c.MobilePhone;
        }
        if(a.Work_Phone_Number__c=='' ){
            a.Work_Phone_Number__c=c.HomePhone;
        }
    }


    // This method is used to nullify email address fields containing an email address that has been hard bounced from Marketing Cloud
    @future 
    public static void nullifyEmailAddress(set<String> setEmailAddressesToNullify){

        System.Debug('##>>> AP03Contact.nullifyEmailAddress : Number of Email Addresses To Manage->'+setEmailAddressesToNullify.size()+' <<< run by ' + UserInfo.getName());

        // Update Contacts
        List<Contact> lContactToUpdate=[select Id,Email,Email_2__c from Contact where Email in:setEmailAddressesToNullify or Email_2__c in:setEmailAddressesToNullify];
        System.debug(logginglevel.WARN, 'nullifyEmailAddress.lContactToUpdate.size() : ' + lContactToUpdate.size());

        for(Contact oContact: lContactToUpdate){
            if (setEmailAddressesToNullify.contains(oContact.Email)) oContact.Email='';
            if (setEmailAddressesToNullify.contains(oContact.Email_2__c)) oContact.Email_2__c='';
        }
        if(lContactToUpdate.size()>0){
            try {
                update lContactToUpdate;
            }
            catch (Exception Ex){
                System.debug(logginglevel.WARN, 'nullifyEmailAddress update lContactToUpdate Err : ' + Ex);
            }
        }
        
        // Update Accounts
        List<Account> lAccountToUpdate=[select Id,PersonEmail,Email__c,Email_2__c 
                                            from Account 
                                            where PersonEmail in:setEmailAddressesToNullify 
                                            or Email__c in:setEmailAddressesToNullify 
                                            or Email_2__c in:setEmailAddressesToNullify];
        System.debug(logginglevel.WARN, 'nullifyEmailAddress.lAccountToUpdate.size() : ' + lAccountToUpdate.size());

        for(Account oAccount: lAccountToUpdate){
            if (setEmailAddressesToNullify.contains(oAccount.PersonEmail)) oAccount.PersonEmail='';
            if (setEmailAddressesToNullify.contains(oAccount.Email__c)) oAccount.Email__c='';
            if (setEmailAddressesToNullify.contains(oAccount.Email_2__c)) oAccount.Email_2__c='';
        }
        if(lAccountToUpdate.size()>0){
            try {
                update lAccountToUpdate;
            }
            catch (Exception Ex){
                System.debug(logginglevel.WARN, 'nullifyEmailAddress update lAccountToUpdate Err : ' + Ex);
            }
        }

        // Update Leads
        List<Lead> lLeadToUpdate=[select Id,Email from Lead where Email in:setEmailAddressesToNullify];
        System.debug(logginglevel.WARN, 'nullifyEmailAddress.lLeadToUpdate.size() : ' + lLeadToUpdate.size());

        for(Lead oLead: lLeadToUpdate){
            if (setEmailAddressesToNullify.contains(oLead.Email)) oLead.Email='';
        }
        if(lLeadToUpdate.size()>0){
            try {
                update lLeadToUpdate;
            }
            catch (Exception Ex){
                System.debug(logginglevel.WARN, 'nullifyEmailAddress update lLeadToUpdate Err : ' + Ex);
            }
        }

    }
    
    
    // MLC : mise a jour des emails et tel du compte  A SUPPRIMER
  /*  public static void updateTelEmailContactMKT(List<Contact> contactToValidate ) { 

           System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] START');
           System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] account' + contactToValidate );
           Set<string> sAccountId = new Set<string>();
           
                   
           for(Contact AccountContact:ContactToValidate)
           {
                 if(!sAccountId.contains(AccountContact.AccountId))sAccountId.add(AccountContact.AccountId);
             
           }
                      
           System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] Avant la liste');
           List<Account> lAccountContactMkt=([ SELECT id,Mobile_Phone_Number__c,Email__c,T_Apex_Context__c
                                            FROM account 
                                            WHERE  id
                                            in ( select AccountId from contact where AccountId =:  sAccountId   )
                                            and IsPersonAccount = false
                                            ]);
       
           List<UpdateMail__c> lUpdateMail =([SELECT IdAccount__c,StatutUpdate__c FROM UpdateMail__c    ]);
           
           
                                    
           System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] Apres la liste ');
           

            
           for(Contact con:contactToValidate) 
           {                    
             
                  for(Account laccountcontact:lAccountContactMkt)
                  {
                      


                       
                        if(laccountcontact.id==con.AccountId)
                        {

                            for(UpdateMail__c updMailPro:lUpdateMail) 
                            {
                                if(updMailPro.IdAccount__c==con.AccountId )
                                {
                                  
                                   
                                    System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] MAJ COMPTE lUpdateMail ' + updMailPro.IdAccount__c + ' ' + updMailPro.StatutUpdate__c );
                                    if(updMailPro.StatutUpdate__c == 'Standard' )                       
                                    {
                                          System.debug('[AP_ACCOUNT.updateTelEmailContactMKT] MAJ COMPTE' + updMailPro.IdAccount__c + ' ' + updMailPro.StatutUpdate__c );
                                        
                                          laccountcontact.Mobile_Phone_Number__c = con.MobilePhone ;
                                          laccountcontact.Email__c =  con.Email ;
                                          laccountcontact.T_Apex_Context__c=true;
                                    }
                                    
                                }
                            }
                        }

                    
                }
            
        
         if (lAccountContactMkt.size()>0   ) update lAccountContactMkt;
         
         
    }    
  }*/
  
  
  }