public without sharing class AP01_Contact {
    
    
    public static void createContactRole(List<Contact> lContacts)
    {
        //Custom Settings of the environment
        String sRoleValue = Utils.getCustomSetting('Contact_Main_Role');
        
        // List of Contact in Account that we will Insert at the end of the method
        List<Contact_in_Account__c> lContactInAccountToInsert=new List<Contact_in_Account__c>();
       
        //Set of Accounts ID referenced in the list of Accounts
        set<Id> sAccountID = new set<Id>();
        for (Contact oContact : lContacts) {
            sAccountID.add(oContact.AccountId);
        }
        
        // we retrieve all the Account In Contacts that reference the list of accounts
        List<Contact_in_Account__c> lContactRole = [SELECT Id, Account__c, Contact__c, Role__c FROM Contact_in_Account__c WHERE Account__c IN :sAccountID];
       
        // we use this map to simplify the treathment. String will be : ContactID+ AccountID + Role
        map<String,Contact_in_Account__c> mapContactRole=new map<String,Contact_in_Account__c>();
        for(Contact_in_Account__c oca:lContactRole){
            mapContactRole.put((String)oca.Account__c+oca.Role__c,oca);
        }
       
        // We loop on Trigger.new elements
        for (Contact oContact : lContacts){
            // if the contact is linked to an account
            if (oContact.accountId !=null){
                if (mapContactRole.get((String)oContact.AccountId + sRoleValue) == null) {
                    if (!Utils.idsAreEqual(oContact.AccountId, Label.DummyAccountId)) {
                        //We create a new ContactInAccount between this contact and this Account 
                        lContactInAccountToInsert.add(new Contact_in_Account__c(COntact__c = oCOntact.Id, Account__c = oContact.AccountID, Role__c = sRoleValue));
                    }
                }      
            }
       }
       
       if(lContactInAccountToInsert.size() > 0) {
           insert lContactInAccountToInsert;
       }
    }
}