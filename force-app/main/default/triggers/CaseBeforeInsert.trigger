trigger CaseBeforeInsert on Case (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> Case.beforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        
        List<Case> lCases = Trigger.new;
           
        
        if (PAD.canTrigger('Case.fillAcountId')) {
            List<Case> lCases_W2CAccount = new List<Case>();
      		            
            for (Case oCase : Trigger.new){
                if(oCase.W2C_AccountNumber__c != null) {
                    lCases_W2CAccount.add(oCase);
                }
            }
              			         
            if (lCases_W2CAccount.size() > 0) 
                AP_Case.fillAccountId(lCases_W2CAccount);
        }
          
        if (PAD.canTrigger('Case.fillCategoryId')) {
            List<Case> lCases_W2CCategory = new List<Case>();
            
            for (Case oCase : Trigger.new){
                if(oCase.W2C_CaseCategory__c != null) {
                    lCases_W2CCategory.add(oCase);
                }
            }
                 
            if (lCases_W2CCategory.size() > 0) 
                AP_Case.fillCategoryId(lCases_W2CCategory);   
            
        } 
        
        if (PAD.canTrigger('Case.fillActivityDomainId')) {
            List<Case> lCases_W2CActivityDomain = new List<Case>();
            
            for (Case oCase : Trigger.new){
                if(oCase.W2C_ActivityDomain__c != null) {
                    lCases_W2CActivityDomain.add(oCase);
                }
            }
                 
            if (lCases_W2CActivityDomain.size() > 0) 
                AP_Case.fillActivityDomainId(lCases_W2CActivityDomain);   
            
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS updateCalculatedFields <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.updateCalculatedFields')) {
            AP_Case.updateCalculatedFields(lCases);
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS updateCalculatedFields <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.updateRelatedLinks')) {
            AP_Case.updateRelatedLinks(lCases);
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS updateRelatedLinks <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.setActivityDomainAndMandataire')) {
            AP_Case.setActivityDomainAndMandataire(lCases, new Map<Id, Case>());
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS setActivityDomainAndMandataire <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.setFrontOffice')) {
            AP_Case.setFrontOffice(lCases);
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS setFrontOffice <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Case.setMandataireWhenEmpty')) {
            AP_Case.setMandataireWhenEmpty(lCases, new Map<Id, Case>());
        } else {
            System.Debug('##>>> Case.beforeInsert : BYPASS setMandataireWhenEmpty <<< run by ' + UserInfo.getName());
        }
                
        System.Debug('##>>> Case.beforeInsert : END <<<');
    } else {
        System.Debug('##>>> Case.beforeInsert : FALSE TRIGGER <<<');
    }
}