global class Batch_Updating_Account_ContactMKT_Step2 implements Database.Batchable<sObject> {
    
    String value;
        
    global Batch_Updating_Account_ContactMKT_Step2(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Predecessor__c, IsPersonAccount, CT_statutConversion__c, A_convertir__c, Name, Street_Number__c, Postal_Box__c, Postal_Code__c, City__c, Email__c, Email_2__c, Fax, Place_Called__c, Country__c, Phone 
									FROM Account 
									WHERE Predecessor__c != '' 
									AND Activity_Domain__r.ExternalID__c=41
									AND General_Deletion_Flag__c = false
									AND Id NOT IN 
										(SELECT AccountId FROM Contact 
										WHERE Contact_Marketing__c = true)]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> account){
        AP_Account_01.manageMKTContactELC(account);
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}