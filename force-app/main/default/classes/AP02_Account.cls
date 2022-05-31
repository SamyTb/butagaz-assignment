public without sharing class AP02_Account {

    private final static String sMainContact='Contact Principal';
    private final static String sSecContact='Contact Vantive';
    private final static String sConvertionStatus='todelete';    
/* Erwan 20170922 : To uncomment once Salesforce resolves the conversion bug 
    public static void convertToPA(set<Id> sAccountToManage){
        
        RecordType rtPA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        RecordType rtBA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];

        // List of Contact that are not Main contacts (They will be attached to a new Account )
        List<Contact> lContactToConvert=new List<Contact>();
        
        // List of Contact to be created (Account without any contacts)
        List<Contact> lContactToInsert=new List<Contact>();
        
        // List of Contact to update (too short name or with a different owner than the account)
        List<Contact> lContactToUpdate=new List<Contact>();
        
        // List of relationships between sames contacts 
        map<ID,ID> mRelationshipContactSame=new map<ID,ID>();
        
        // List of unknown relationships  contacts 
        map<ID,ID> mRelationshipContactTBD=new map<ID,ID>();
     
        // List of Account to handle
        List<Account> lAccountToManage=new List<Account>();
        List<Contact> lContactsToHandle=new List<Contact>();
        
        // if a Main contact has been found
        Boolean bPrincipalFound;
         
        // if a Vantive Contact has been found
        Boolean bVantiveFound;
        set<ID> sContactID=new set<Id>();
        map<Id,List<Case>> mapAccountIDCase=new map<Id,List<Case>>();
        List<Case> lCaseToUpdate=new List<Case>();
        
        System.Debug('##>>> AP02_Account.convertToPA : Number of Account To Manage->'+sAccountToManage.size()+' <<< run by ' + UserInfo.getName());
        if(sAccountToManage.size()>0){
            
            // We retrieve the List of Account to Handle
            lAccountToManage=[select Id, Name, ispersonAccount,Street_Number__c,Postal_Box__c,Salutation__c,Postal_Code__c,City__c,Email__c,Email_2__c,Fax,Place_Called__c,Mandataire__c,Optin_2__c,Optin_1__c,No_E_mail__c,Country__c,Activity_Domain__c,Phone,Mobile_Phone_Number__c,Work_Phone_Number__c,ownerId ,(select LastModifiedDate,Id,Street_Number__c,Postal_Box__c,Salutation,Postal_Code__c,City__c,Email,Email_2__c,Fax,Place_Called__c,Mandataire__c,Email_2_Opt_Out__c,HasOptedOutOfEmail,Has_No_Email__c,Country__c,Activity_Domain__c,HomePhone,MobilePhone,Phone,AccountId,ownerID,CT_ContactRole__c,FirstName,LastName from Contacts) FROM Account where Id in : sAccountToManage];
            System.Debug('##>>> AP02_Account.convertToPA : retrieve lAccountToManage->'+lAccountToManage+' <<< run by ' + UserInfo.getName());
            for(Account oAccount: lAccountToManage){
                System.assert(!oAccount.ispersonAccount);
                for(Contact oContact:oAccount.Contacts){
                        sContactID.add(oContact.Id);
                }
            }
            for(Case oCase:[Select Id,Contact.AccountID,AccountID from Case where  ContactId in:sContactID]){
                if(mapAccountIDCase.get(oCase.ContactID)==null){
                    mapAccountIDCase.put(oCase.ContactID,new List<Case>());
                }
                mapAccountIDCase.get(oCase.ContactID).add(oCase);
            }

            // contain the Main COntact
            Contact tempContactPrincipal;
                   
            for(Account oAccount: lAccountToManage){
                
                //init
                tempContactPrincipal=null;
                bPrincipalFound=false;
                bVantiveFound=false;
                lContactsToHandle=oAccount.Contacts;
                oAccount.CT_PreviousAccountName__c=oAccount.Name;
                oAccount.A_convertir__c=false;
                
                System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage oAccount.Name->'+oAccount.Name+' <<< run by ' + UserInfo.getName());
                System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle->'+lContactsToHandle+' <<< run by ' + UserInfo.getName());
                if(lContactsToHandle!=null){
                    if(lContactsToHandle.size()>1){
                        // THe account has more than 1 Contact
                        for(Contact oContact:lContactsToHandle){
                            // Loop on the list of contacts
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle oContact.Id->'+oContact.Id+' <<< run by ' + UserInfo.getName());
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle oContact.Role->'+oContact.CT_ContactRole__c+' <<< run by ' + UserInfo.getName());
                            if(oContact.CT_ContactRole__c==sMainContact){
                                //If the role of the contact is "Contact Principal", we define him as the Main contact
                                if(bPrincipalFound ){
                                    
                                    lContactToConvert.add(oContact);
                                }
                                else{
                                    // If this is the first, we define it as the Main contact.
                                   bPrincipalFound=true;
                                   if(tempContactPrincipal!=null)
                                       lContactToConvert.add(tempContactPrincipal);
                                   tempContactPrincipal=oContact;
                                }
                            }
                            
                            else if(oContact.CT_ContactRole__c==sSecContact){
                                
                                if(bPrincipalFound || bVantiveFound){
                                    // If there is already one "Contact Principal" found or another "Contact Vantive" found, we define others as Contact to be Converted to another Person Account
                                    
                                    lContactToConvert.add(oContact);
                                }
                                else {
                                    //If there is no "Contact Principal" found nor another "COntact Vantive" found , we define it as the Main Contact
                                    bVantiveFound=true;
                                    if(tempContactPrincipal!=null)
                                       lContactToConvert.add(tempContactPrincipal);
                                    tempContactPrincipal=oContact;
                                    
                                }
                            }   
                            else { 
                                //If the role is different from  "COntact Vantive" and  "Contact Principal"
                                if(bPrincipalFound || bVantiveFound || tempContactPrincipal!=null ){
                                    // If there is already one "Contact Principal" found or another "Contact Vantive" found or any other Main contact found, we define others as Contact to be Converted to another Person Account
                                    lContactToConvert.add(oContact);
                                }
                                else {
                                    //If there is no "Contact Principal" found nor "COntact Vantive" found nor any other main contact found , we define it as the Main Contact
                                    if(tempContactPrincipal!=null)
                                       lContactToConvert.add(tempContactPrincipal);
                                    tempContactPrincipal=oContact;
                                }
                            }
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle tempContactPrincipal->'+tempContactPrincipal+' <<< run by ' + UserInfo.getName());
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle lContactToConvert->'+lContactToConvert+' <<< run by ' + UserInfo.getName());
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle bVantiveFound->'+bVantiveFound+' <<< run by ' + UserInfo.getName());
                            System.Debug('##>>> AP02_Account.convertToPA : Loop lAccountToManage lContactsToHandle bPrincipalFound->'+bPrincipalFound+' <<< run by ' + UserInfo.getName());
                             
                        }

                        for(Contact oContact2:lContactsToHandle){
                            // We loop on COntacts to create relationships between main contacts and other Contacts
                                 if(oContact2.Id!=tempContactPrincipal.Id){
                                    if(mapAccountIDCase.get(oContact2.ID)!=null){
                                         for(Case oCase:mapAccountIDCase.get(oContact2.ID)){
       
                                            oCase.Salutation__c=oContact2.Salutation;
                                            oCase.LastName__c=oContact2.LastName;
                                            oCase.FirstName__c=oContact2.FirstName;
                                            oCase.ContactId=tempContactPrincipal.Id;
                                            oCase.CT_OriginalAccountId__c=(String)oCase.AccountID;
                                            oCase.AccountID=oAccount.Id;
                                            oCase.CT_OriginalContactId__c=oContact2.Id;
                                            
      
                                            String st='';
                                            if(oContact2.Street_Number__c!='')
                                                st=oContact2.Street_Number__c+'\r\n';
                                            if(oContact2.Place_Called__c!='')
                                                st+=oContact2.Place_Called__c+'\r\n';
                                            if(oContact2.Postal_Code__c!='')
                                                st+=oContact2.Postal_Code__c+'\r\n';
                                            if(oContact2.City__c!='')
                                                st+=oContact2.City__c+'\r\n';
                                            if(oContact2.Country__c!='')
                                                st+=oContact2.Country__c+'\r\n';
                                            oCase.Address__c=st;
    
                                             
                                            if(oContact2.MobilePhone!='')
                                                oCase.Phone__c=oContact2.MobilePhone;
                                            else if(oContact2.Phone!='')
                                                oCase.Phone__c=oContact2.Phone;
                                            else if(oContact2.HomePhone!='')
                                                oCase.Phone__c=oContact2.HomePhone;
                                            else if(oContact2.OtherPhone!='')
                                                oCase.Phone__c=oContact2.OtherPhone;
                                                
                                            lCaseToUpdate.add(oCase);
    
                                         } 
                                    }
                                 }
                            }

                            MapFieldToAccount(tempContactPrincipal,oAccount);
                            tempContactPrincipal.ownerID=oAccount.ownerId;
                            lContactToUpdate.add(tempContactPrincipal);
                        
                    }
                    else if (lContactsToHandle.size()==0){
                        // If the Account has no Contacts, we create a basic one and add it to the Account
                        System.Debug('##>>> AP02_Account.convertToPA : lContactsToHandle.size()==0 <<< run by ' + UserInfo.getName());
      
                        lContactToInsert.add(new Contact(CT_statutConversion__c=sConvertionStatus,ownerId=oAccount.ownerId,AccountId=oAccount.Id,lastName=oAccount.Name));
                    }
                    else { 
                        // START - Added due to error during conversion
                        
                        // If the Account has a unique Contact, we check the contact first name and last name (to be replaced by the Account name if it is too short)
                        // We also set the same Account ownerId on the Contact.
                        
                          System.Debug('##>>> AP02_Account.convertToPA : lContactsToHandle.size()==1 <<< run by ' + UserInfo.getName());

                         lContactsToHandle[0].CT_PreviousOwnerId__c=lContactsToHandle[0].ownerId;  
                         lContactsToHandle[0].ownerId=oAccount.ownerId;

                          MapFieldToAccount(lContactsToHandle[0],oAccount);
                          lContactToUpdate.add(lContactsToHandle[0]);
                           
                         // END - Added due to error during conversion
                         
                    }
                }
                
            }

            System.Debug('##>>> AP02_Account.convertToPA : insert lContactToInsert->'+lContactToInsert+' <<< run by ' + UserInfo.getName());
            insert lContactToInsert;
            System.Debug('##>>> AP02_Account.convertToPA : update lContactToUpdate->'+lContactToUpdate+' <<< run by ' + UserInfo.getName());
            update lContactToUpdate;
            System.Debug('##>>> AP02_Account.convertToPA : update lCaseToUpdate->'+lCaseToUpdate+' <<< run by ' + UserInfo.getName());
            update lCaseToUpdate;
            
            lAccountToManage = removeAlreadyConvertedAccount(lAccountToManage);   
            System.Debug('##>>> AP02_Account.convertToPA : update lAccountToManage->'+lAccountToManage+' <<< run by ' + UserInfo.getName());    
            update lAccountToManage;
           
            for(Contact oContact: lContactToConvert){
                // We Link the contact to convert to the new Accounts we just created
                oContact.CT_OriginalAccountId__c=oContact.AccountId;
                oContact.CT_PreviousOwnerId__c=oContact.ownerID;
                oContact.AccountId= null;
                oContact.ownerID=userInfo.getUserID();

                System.Debug('##>>> AP02_Account.convertToPA : insert lContactToConvert->'+oContact+' <<< run by ' + UserInfo.getName());   
            }

            System.Debug('##>>> AP02_Account.convertToPA : update lContactToConvert->'+lContactToConvert+' <<< run by ' + UserInfo.getName());
            update lContactToConvert;
 
           // START - Added due to an error during conversion 
           // If I don't do a SOQL to retrieve the Account I handle, I have an error during conversion
           

           update  lAccountToManage;
             
           List<Account> lAccountToManage2=new List<Account>();    

           for(Account oAccount: [select Id from Account where Id in:lAccountToManage]){
                 oAccount.RecordTypeId=rtPA.Id;
                 lAccountToManage2.add(oAccount);
                 
            }
            update lAccountToManage2;
            
            System.Debug('##>>> AP02_Account.convertToPA : update lAccountToManage2->'+lAccountToManage2+' <<< run by ' + UserInfo.getName());
                    
            // END - Added due to an error during conversion   

        }
    }
    
    private static List<Account> removeAlreadyConvertedAccount(List<Account> accountsToFilter){
            
            //Fetch the Id of already converted accounts from the list
            Set<Id> personAccountIdsToRemove  = new Set<Id>();
            
            List<Account> personAccountsToRemove = [select Id FROM Account where Id in :accountsToFilter and ispersonAccount=true];
            for(Account accountToRemove:personAccountsToRemove){
               personAccountIdsToRemove.add(accountToRemove.id);
            }

            //Create a new list without the person account to remove
            List<Account> remainingAccountsToConvert= new List<Account>();
            for(Account account:accountsToFilter){
                if(!personAccountIdsToRemove.contains(account.Id)){
                    remainingAccountsToConvert.add(account);
                }
            }
            
            return remainingAccountsToConvert;  
    }
    
    public static void MapFieldToAccount(Contact c,Account a){
        
        if(c.Street_Number__c!='' ){
            a.Street_Number__c=c.Street_Number__c;
        }
        if(c.Postal_Box__c!='' ){
            a.Postal_Box__c=c.Postal_Box__c;
        }
         
        if(c.Postal_Code__c!=''){
            a.Postal_Code__c=c.Postal_Code__c;
        }
        if(c.City__c!='' ){
            a.City__c=c.City__c;
        }
        if(c.Email!=''){
            a.Email__c=c.Email;
        }
        if(c.Email_2__c!='' ){
            a.Email_2__c=c.Email_2__c;
        }

        if(c.Fax!='' ){
            a.Fax=c.Fax;
        }
        if(c.Place_Called__c!=''){
            a.Place_Called__c=c.Place_Called__c;
        }
     
        if(c.Country__c!='' ){
            a.Country__c=c.Country__c;
        }
        if(c.Phone!=''){
            a.Phone=c.Phone;
        }
        if(c.MobilePhone!='' ){
            a.Mobile_Phone_Number__c=c.MobilePhone;
        }
        if(c.HomePhone!='' ){
            a.Work_Phone_Number__c=c.HomePhone;
        }
        
        a.No_E_mail__c = c.Has_No_Email__c;
        a.Optin_1__c  = c.HasOptedOutOfEmail;
        a.Optin_2__c = c.Email_2_Opt_Out__c;
        
    }
    
     public static void convertToBA(set<Id> sAccountToManage){
        
        RecordType rtPA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Dom' LIMIT 1];
        RecordType rtBA = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        
        
        List<Account> lAccountToConvert=[select Id from Account where id in:sAccountToManage];
        for(Account oAccount:lAccountToConvert){
            oAccount.recordtypeId=rtBA.Id;
        }

        update lAccountToConvert;
        
        lAccountToConvert=[select Id,CT_PreviousAccountName__c from Account where id in:sAccountToManage];
        for(Account oAccount:lAccountToConvert){
            oAccount.Name=oAccount.CT_PreviousAccountName__c;
            oAccount.A_Convertir__c=false;
        }
        update lAccountToConvert;
        delete [select id from Contact where AccountId in:sAccountToManage And CT_statutConversion__c=:sConvertionStatus];

        List<Contact> lcontactToUpdate=new List<Contact>();

        set<Id> sAccountToDelete=new set<Id>();

        lcontactToUpdate=[select id,CT_OriginalAccountId__c,CT_PreviousOwnerId__c from Contact where CT_OriginalAccountId__c in:sAccountToManage];
        for(Contact oContact:lcontactToUpdate){
            oCOntact.AccountId=oContact.CT_OriginalAccountId__c;
            oCOntact.ownerId=oContact.CT_PreviousOwnerId__c;
        }
        update lcontactToUpdate;
        
        List<Case> lCaseToUpdate=new List<Case>();
        for(Case oCase:[select id,CT_OriginalAccountId__c,CT_OriginalContactId__c from Case where AccountID in:lAccountToConvert]){
            if(oCase.CT_OriginalAccountId__c!=null && oCase.CT_OriginalAccountId__c!='')
                oCase.AccountId=oCase.CT_OriginalAccountId__c;
            if(oCase.CT_OriginalContactId__c!=null && oCase.CT_OriginalContactId__c!='')
                oCase.contactId=oCase.CT_OriginalContactId__c; 
            oCase.Salutation__c='';
            oCase.LastName__c='';
            oCase.FirstName__c='';
            oCase.CT_OriginalAccountId__c='';
            oCase.CT_OriginalContactId__c='';
            oCase.Address__c='';
            oCase.Phone__c='';
            lCaseToUpdate.add(oCase);
        }
        update lCaseToUpdate;
     }
*/
}