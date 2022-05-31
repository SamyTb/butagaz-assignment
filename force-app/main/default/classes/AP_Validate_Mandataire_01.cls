public class AP_Validate_Mandataire_01 {

    public static void validateOpportunities(List<Opportunity> lOpportunities){
        System.debug('[AP_valMandataire_01.validateOppportunities] START METHOD');

        System.debug('[AP_valMandataire_01.validateOppportunities] Retrieving users');
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity oOpportunity : lOpportunities){
            ownerIds.add(oOpportunity.OwnerId);
        }

        //Map<Id, User> mUsers = new Map<Id, User>([SELECT Id, Mandataire__c FROM User WHERE Id IN :ownerIds]);
		// Gestion multi-plaques
		Map<Id, User> mUsers = new Map<Id, User>([SELECT Id, User_Mandataires__c FROM User WHERE Id IN :ownerIds]);
		String[] userMandataires = null;
		boolean bMatchMandataire = false;
		 
        System.debug('[AP_valMandataire_01.validateOppportunities] Retrieving users.');
        User loopUser; // loop variable for the user
        for (Opportunity oOpportunity : lOpportunities){
            System.debug('[AP_valMandataire_01.validateOppportunities] Validating Opportunity ' + oOpportunity);
            loopUser = mUsers.get(oOpportunity.OwnerId);
            
            // Gestion multi-plaques
            bMatchMandataire = false;
            
            if (loopUser == null){
                // We have a Queue here.
            } else {
                /*if (oOpportunity.T_MandataireId__c != (String) loopUser.Mandataire__c){ 
                    // Mandataire__c is an ID.
                    // T_MandataireId__c is a TEXT formula.
                    oOpportunity.addError('WRONG MANDATAIRE');
                    System.debug('[AP_valMandataire_01.validateOppportunities] Mandataire mismatch.');
                    System.debug('[AP_valMandataire_01.validateOppportunities] Opportunity Mandataire:[' + oOpportunity.T_MandataireId__c + ']');
                    System.debug('[AP_valMandataire_01.validateOppportunities] User Mandataire:[' + loopUser.Mandataire__c + ']');
                } else {
                    System.debug('[AP_valMandataire_01.validateOppportunities] Mandataire match.');
                }*/            	
            	
            	// Gestion multi-plaques
                if(loopUser.User_Mandataires__c != null){
                	userMandataires = loopUser.User_Mandataires__c.split(';',0);	
                }
                
                if(oOpportunity.T_MandataireId__c == null && userMandataires == null){
                	bMatchMandataire = true;
                }

				if(oOpportunity.T_MandataireId__c != null){
					for(integer i=0;i<userMandataires.size();i++){
						if(oOpportunity.T_MandataireId__c == userMandataires[i]){
							bMatchMandataire = true;
							break;
						}
					}
				}

				if(bMatchMandataire){
					System.debug('[AP_valMandataire_01.validateOppportunities] Mandataire match.');	
				}
				else{
                    // Mandataire__c is an ID.
                    // T_MandataireId__c is a TEXT formula.
                    oOpportunity.addError('WRONG MANDATAIRE');
                    System.debug('[AP_valMandataire_01.validateOppportunities] Mandataire mismatch.');
                    System.debug('[AP_valMandataire_01.validateOppportunities] Opportunity Mandataire:[' + oOpportunity.T_MandataireId__c + ']');
                    System.debug('[AP_valMandataire_01.validateOppportunities] User Mandataire:[' + loopUser.User_Mandataires__c + ']');					
				}

            }
        }

        System.debug('[AP_valMandataire_01.validateOppportunities] END METHOD');
    }
}