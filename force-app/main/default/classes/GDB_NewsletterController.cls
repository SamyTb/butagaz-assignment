public with sharing class GDB_NewsletterController {
    
    /**
     * saveMailNewsletter : save mail in newsletter object with a verification if they are doublon or invalid email
     *
     *@param {Map<String, String>} email to insert into database
     *@return {Map<String, String>} information to send to front user as succes, mail or already registered.
     */
    
    @AuraEnabled
    public static  Map<String, String> saveMailNewsletter(Map<String, String> detailsForm) {
    	String mail = detailsForm.get('email');

		List<Newsletter_Subscription__c> souscription = [SELECT OwnerId, Name, Email__c FROM Newsletter_Subscription__c WHERE Email__c = :mail];
		
    	
    	Map<String, String> returnObject = new Map<String, String>();
    	returnObject.put('mail', mail);
        returnObject.put('success', 'false');
    	
    	try {
    	    if(String.isEmpty(mail)) {
    	        return returnObject;
    	    }
    		if(souscription == NULL || souscription.size() == 0) {
    		
    		Newsletter_Subscription__c newMail = new Newsletter_Subscription__c(Email__c = mail);

            returnObject.put('message', System.Label.GDB_newsletter_successMessage);
            
            insert newMail;

    		} else {
    			
            returnObject.put('message',  System.Label.GDB_newsletter_duplicateMessage);
    		}
    		
            returnObject.put('success', 'true');
			return returnObject;

        } catch(Exception e) {

            System.debug(System.LoggingLevel.ERROR, e.getMessage());
			returnObject.put('message', System.Label.GDB_newsletter_errorMessage);

            return returnObject; 
        }
    	
    }
    
}