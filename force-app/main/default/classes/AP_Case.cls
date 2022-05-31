public class AP_Case
{   
    /*public static void updateCalculatedFields(List<Case> cases)
    {    
    
        System.Debug('Start method AP_Case.updateCalculatedFields');

        Date tempDate;
        Integer tempnDays;
        Date weekStart;
        
        for (Case oCase : cases) {
            if (oCase.CreatedDate != null) {
                tempDate = oCase.CreatedDate.date();
            } else {
                tempDate = Date.today();
            }
            
            tempnDays = Integer.valueof(oCase.CategorySLA__c);
            
            while (tempnDays > 0) {
                tempDate = tempDate.addDays(1);
                weekStart = tempDate.toStartofWeek();
                if (weekStart.daysBetween(tempDate) != 5 && weekStart.daysBetween(tempDate) != 6) {
                    tempnDays--;
                }
            }
            oCase.SLA_Due_Date__c = tempDate;
            
            if (oCase.Communicated_Due_Date__c != null) {
                oCase.Real_Due_Date__c = oCase.Communicated_Due_Date__c;
            } else {
                oCase.Real_Due_Date__c = oCase.SLA_Due_Date__c;
            }
            
            oCase.Related_Cases_Count__c = 0;
            oCase.Related_Open_Cases_Count__c = 0;
            //oCase.AccountId = null; removed to fix the PA Account prbm
        }
        
        System.Debug('End method AP_Case.updateCalculatedFields');
    }*/
    
    /** Method modified to manage holidays **/
    public static void updateCalculatedFields(List<Case> cases){    
    
        System.Debug('Start method AP_Case.updateCalculatedFields');
        
        DateUtilities.calculateWorkingDaysOnListOfCases(cases);
        
        System.Debug('End method AP_Case.updateCalculatedFields');
    }
    
    public static void setFrontOffice(List<Case> lCases)
    {
        System.Debug('Start method AP_Case.setFrontOffice');

        //Plaques Management
        User oUser = [select User_Mandataires__c from User where Id = :userInfo.getUserId()];
        system.debug('User_Mandataires__c: '+oUser.User_Mandataires__c);
                
        list<Mandataire__c> lMandataire = new list<Mandataire__c>();
        if (!Utils.valueIsNull(oUser.User_Mandataires__c)) {
            String[] userMandataires = oUser.User_Mandataires__c.split(';',0);
            system.debug('userMandataires: '+userMandataires);
            try {
                lMandataire = [select Id from Mandataire__c where ExternalID__c IN :userMandataires];
            } catch (System.QueryException e) {
                System.Debug('Mandataire(s): ' + oUser.User_Mandataires__c + ' not found');
            }
        }
        
        system.debug('lMandataire size: '+lMandataire.size());
    
        for (Case oCase : lCases) {        
            if(lMandataire.size()==1){
                oCase.Front_Office__c = lMandataire.get(0).Id;
            }           
            else {
                oCase.Front_Office__c=oCase.Mandataire__c;
            }
        }
        
        System.Debug('End method AP_Case.setFrontOffice');
    }
    
    public static void setActivityDomainAndMandataire(List<Case> lNewCases, Map<Id, Case> mOldCases)
    {
        System.Debug('Start method AP_Case.setActivityDomainAndMandataire');
        
        Set<Id> sOrderIds = new Set<Id>();
        for (Case oCase : lNewCases) {
            sOrderIds.add(oCase.Order__c);
        }
        
        Set<Id> sContractIds = new Set<Id>();
        for (Case oCase : lNewCases) {
            sContractIds.add(oCase.Contract__c);
        }
        
        Set<Id> sEquipementIds = new Set<Id>();
        for (Case oCase : lNewCases) {
            sEquipementIds.add(oCase.Equipement__c);
        }
        
        Set<Id> sPtlIds = new Set<Id>();
        for (Case oCase : lNewCases) {
            sPtlIds.add(oCase.PTL__c);
        }
        
        Set<Id> sAccountIds = new Set<Id>();
        for (Case oCase : lNewCases) {
            sAccountIds.add(oCase.AccountId);
        }
        
        Map<Id, Order__c> mOrders = new Map<Id, Order__c>([select Id, Activity_Domain__c, Mandataire__c from Order__c where Id in :sOrderIds]);
        Map<Id, Contract> mContracts = new Map<Id, Contract>([select Id, Activity_Domain__c, Mandataire__c from Contract where Id in :sContractIds]);
        Map<Id, Equipement__c> mEquipements = new Map<Id, Equipement__c>([select Id, Activity_Domain__c, Mandataire__c from Equipement__c where Id in :sEquipementIds]);
        Map<Id, PTL__c> mPtls = new Map<Id, PTL__c>([select Id, Activity_Domain__c, Mandataire__c from PTL__c where Id in :sPtlIds]);
        Map<Id, Account> mAccounts = new Map<Id, Account>([select Id, Activity_Domain__c, Mandataire__c from Account where Id in :sAccountIds]);
        
        for (Case oCase : lNewCases) {
            
            if (oCase.Order__c != null && mOrders.get(oCase.Order__c).Activity_Domain__c != null) {
                oCase.Activity_Domain__c = mOrders.get(oCase.Order__c).Activity_Domain__c;
            } else if (oCase.Contract__c != null && mContracts.get(oCase.Contract__c).Activity_Domain__c != null) {
                oCase.Activity_Domain__c = mContracts.get(oCase.Contract__c).Activity_Domain__c;
            } else if (oCase.Equipement__c != null && mEquipements.get(oCase.Equipement__c).Activity_Domain__c != null) {
                oCase.Activity_Domain__c = mEquipements.get(oCase.Equipement__c).Activity_Domain__c;
            } else if (oCase.PTL__c != null && mPtls.get(oCase.PTL__c).Activity_Domain__c != null) {
                oCase.Activity_Domain__c = mPtls.get(oCase.PTL__c).Activity_Domain__c;
            } else if (oCase.AccountId != null && mAccounts.get(oCase.AccountId).Activity_Domain__c != null) {
                oCase.Activity_Domain__c = mAccounts.get(oCase.AccountId).Activity_Domain__c;
            } else if(oCase.Activity_Domain_Contact__c!=null)
                oCase.Activity_Domain__c = oCase.Activity_Domain_Contact__c;{
            }
        }
        
        for (Case oNewCase : lNewCases) {
            Case oOldCase = mOldCases.get(oNewCase.Id);
            if (oOldCase == null) {
                oOldCase = new Case();
            }
            
            System.Debug('@@@ CVER : oOldCase.Id:' + oOldCase.Id);
            
            if (oNewCase.Order__c != null && mOrders.get(oNewCase.Order__c).Mandataire__c != null) {
                System.Debug('@@@ CVER : Order__c');
                // Only set the Mandataire when the linked object changed, to allow editing of the Mandataire.
                if (oNewCase.Order__c != oOldCase.Order__c) {
                    oNewCase.Mandataire__c = mOrders.get(oNewCase.Order__c).Mandataire__c;
                }
            } else if (oNewCase.Contract__c != null && mContracts.get(oNewCase.Contract__c).Mandataire__c != null) {
                System.Debug('@@@ CVER : Contract__c');
                // Only set the Mandataire when the linked object changed, to allow editing of the Mandataire.
                if (oNewCase.Contract__c != oOldCase.Contract__c) {
                    oNewCase.Mandataire__c = mContracts.get(oNewCase.Contract__c).Mandataire__c;
                }
            } else if (oNewCase.Equipement__c != null && mEquipements.get(oNewCase.Equipement__c).Mandataire__c != null) {
                System.Debug('@@@ CVER : Equipement__c');
                // Only set the Mandataire when the linked object changed, to allow editing of the Mandataire.
                if (oNewCase.Equipement__c != oOldCase.Equipement__c) {
                    oNewCase.Mandataire__c = mEquipements.get(oNewCase.Equipement__c).Mandataire__c;
                }
            } else if (oNewCase.PTL__c != null && mPtls.get(oNewCase.PTL__c).Mandataire__c != null) {
                System.Debug('@@@ CVER : PTL__c');
                // Only set the Mandataire when the linked object changed, to allow editing of the Mandataire.
                if (oNewCase.PTL__c != oOldCase.PTL__c) {
                    oNewCase.Mandataire__c = mPtls.get(oNewCase.PTL__c).Mandataire__c;
                }
            } else if (oNewCase.AccountId != null && mAccounts.get(oNewCase.AccountId).Mandataire__c != null) {
                System.Debug('@@@ CVER : Account');
                // Only set the Mandataire when the linked object changed, to allow editing of the Mandataire.
                if (oNewCase.AccountId != oOldCase.AccountId) {
                    oNewCase.Mandataire__c = mAccounts.get(oNewCase.AccountId).Mandataire__c;
                }
            } else if (oOldCase.Id == null) {
                System.Debug('@@@ CVER : oNewCase.Front_Office__c:' + oNewCase.Front_Office__c);
                // Only try to set the Front Office as Mandataire when the case is created
                // and the person did not fill in a mandataire manually.
                if (oNewCase.Mandataire__c == null && oNewCase.Front_Office__c != null) {
                    Mandataire__c oMandataire = [SELECT Id, Active__c FROM Mandataire__c WHERE Id = :oNewCase.Front_Office__c];
                    if (oMandataire.Active__c == true) {
                        oNewCase.Mandataire__c = oMandataire.Id;
                    }
                }
            }
        }
        
        System.Debug('End method AP_Case.setActivityDomainAndMandataire');
    }
    
        public static void setMandataireWhenEmpty(List<Case> lNewCases, Map<Id, Case> mOldCases)
    {
        System.Debug('Start method AP_Case.setActivityDomainAndMandataire');
        
        for (Case oNewCase : lNewCases) {
            Case oOldCase = mOldCases.get(oNewCase.Id);
            if (oOldCase == null) {
                oOldCase = new Case();
            }
            
            System.Debug('@@@ CVER : oOldCase.Id:' + oOldCase.Id);
            
            if (oOldCase.Id == null) {
                System.Debug('@@@ CVER : oNewCase.Front_Office__c:' + oNewCase.Front_Office__c);
                // Only try to set the Front Office as Mandataire when the case is created
                // and the person did not fill in a mandataire manually.
                if (oNewCase.Mandataire__c == null && oNewCase.Front_Office__c != null) {
                    Mandataire__c oMandataire = [SELECT Id, Active__c FROM Mandataire__c WHERE Id = :oNewCase.Front_Office__c];
                    if (oMandataire.Active__c == true) {
                        oNewCase.Mandataire__c = oMandataire.Id;
                    }
                }
            }
        }
        
        System.Debug('End method AP_Case.setMandataireWhenEmpty');
    }
    
    
    public static void updateRelatedLinks(List<Case> cases)
    {
        System.Debug('Start method AP_Case.updateUpdateRelatedLinks');
        
        set<Id> sEquipements = new set<Id>();
        set<Id> sContracts = new set<Id>();
        set<Id> sOrders = new set<Id>();
        set<Id> sPTLs = new set<Id>();
        
        for (Case oCase : cases) {
            sEquipements.add(oCase.Equipement__c);
            sContracts.add(oCase.Contract__c);
            sOrders.add(oCase.Order__c);
            sPTLs.add(oCase.PTL__c);
        }
        map<Id, Equipement__c> mEquipments = new map<Id, Equipement__c>([SELECT Id, PTL__c,PTL__r.Account_DO__c FROM Equipement__c WHERE Id IN :sEquipements ]);
        map<Id, Contract> mContracts = new map<Id, Contract>([SELECT Id, PTL__c, Equipement__c, AccountId FROM Contract WHERE Id IN :sContracts ]);
        map<Id, Order__c> mOrders = new map<Id, Order__c>([SELECT Id, Contract__c, Contract__r.Equipement__c, Contract__r.AccountId, Contract__r.PTL__c FROM Order__c WHERE Id IN :sOrders ]);
        map<Id, PTL__c> mPTLs = new map<Id, PTL__c>([SELECT Id, Account_DO__c FROM PTL__c WHERE Id IN :sPTLs ]);    
        
        for (Case oCase : cases) {
            if (mOrders != null && mOrders.get(oCase.Order__c) != null) {
                oCase.Contract__c = mOrders.get(oCase.Order__c).Contract__c;
                oCase.Equipement__c = mOrders.get(oCase.Order__c).Contract__r.Equipement__c;
                oCase.PTL__c = mOrders.get(oCase.Order__c).Contract__r.PTL__c;
                oCase.AccountId = mOrders.get(oCase.Order__c).Contract__r.AccountId;
            } else if (mContracts != null && mContracts.get(oCase.Contract__c) != null) {
                oCase.Equipement__c = mContracts.get(oCase.Contract__c).Equipement__c;
                oCase.PTL__c = mContracts.get(oCase.Contract__c).PTL__c;
                oCase.AccountId = mContracts.get(oCase.Contract__c).AccountId;
            } else if (mEquipments != null && mEquipments.get(oCase.Equipement__c) != null) {
                oCase.PTL__c = mEquipments.get(oCase.Equipement__c).PTL__c;
                oCase.AccountId = mEquipments.get(oCase.Equipement__c).PTL__r.Account_DO__c;
            } else if (mPTLs != null && mPTLs.get(oCase.PTL__c) != null) {
                if(oCase.AccountId==null)
                    oCase.AccountId = mPTLs.get(oCase.PTL__c).Account_DO__c;
            }
             
        }
        
        System.Debug('End method AP_Case.updateUpdateRelatedLinks');
    }
    
    public static void checkActivitiesWhenClosing(List<Case> cases)
    {
        System.Debug('Start method AP_Case.checkActivitiesWhenClosing');
        
        List<Case> lClosedCases = new List<Case>();
        for (Case oCase : cases) {
            if (oCase.Status == 'Closed'){
                lClosedCases.add(oCase);
            } 
        }
        
        List<Task> lTask = [select id, whatId from Task where whatId in :lClosedCases and isClosed = false ];
        map<Id, List<Task>> mTasks = new map<Id, List<Task>>();
        
        for (Task oTask:lTask) {
            if (mTasks.get(oTask.whatID) == null) {
                mTasks.put(oTask.whatID,new List<Task>());
            }
            mTasks.get(oTask.whatID).add(oTask);
        }
        
        for (Case oCase : lClosedCases) {
            if (mTasks.get(oCase.Id) != null) {
                oCase.addError(Label.check_no_Activities_when_closing_Case);
            }
        }
        
        System.Debug('End method AP_Case.checkActivitiesWhenClosing');
        
    }
    
    public static void fillAccountId(List<Case> lCases)
    {
      System.Debug('Start method AP_Case.fillAccountId');
        
        
        // Get the external ID
        Set<String> sW2CAccExternalIDs = new Set<String>();
        Set<String> sW2CPTLExternalIDs = new Set<String>();
        for (Case oCase : lCases){
            sW2CAccExternalIDs.add(String.valueOf(oCase.W2C_AccountNumber__c));
            if(!String.isEmpty(oCase.W2C_PTLNumber__c)) sW2CPTLExternalIDs.add(String.valueOf(oCase.W2C_PTLNumber__c));
        }
        System.debug('AP_Case.fillAccountId - liste des external ID' + sW2CAccExternalIDs);

        // Map ExternalID to Account
        Map<String, Account> mExternalIDAccount = new Map<String, Account>();
        for (Account oAccount : [SELECT Name, ExternalID__c FROM Account WHERE ExternalID__c IN :sW2CAccExternalIDs]){
            
            mExternalIDAccount.put(oAccount.ExternalID__c, oAccount);
        }
        System.debug('AP_Case.fillAccountId - Nom du compte ' + mExternalIDAccount);
        
        // ELC | 20160916 | Fill PTL as well in case of GEB
        // ELC | 20190319 | Manage PTL in case of GEC as well if field W2C_PTLNumber__c is not empty
        // Map ExternalID to PTL__c
        Map<String, PTL__c> mExternalIDPTL = new Map<String, PTL__c>();
        for (PTL__c oPTL : [SELECT Name, ExternalID__c, Activity_Domain__r.ExternalID__c FROM PTL__c 
                                WHERE ( Activity_Domain__r.ExternalID__c = 41 AND ExternalID__c IN :sW2CAccExternalIDs )
                                OR ( Activity_Domain__r.ExternalID__c = 42 AND ExternalID__c IN :sW2CPTLExternalIDs )
                                ]){
            
            mExternalIDPTL.put(oPTL.ExternalID__c, oPTL);
        }
        System.debug('AP_Case.fillPTLId - Nom du PTL ' + mExternalIDPTL);
        
        // fill Account Id
        for (Case oCase : lCases){
            if( mExternalIDAccount.get(oCase.W2C_AccountNumber__c) != null) {
                oCase.AccountId = mExternalIDAccount.get(oCase.W2C_AccountNumber__c).Id;
            }
            // ELC | 20160916 | Fill PTL as well in case of GEB
            if(mExternalIDPTL.get(oCase.W2C_AccountNumber__c) != null && mExternalIDPTL.get(oCase.W2C_AccountNumber__c).Activity_Domain__r.ExternalID__c == 41){
                oCase.PTL__c = mExternalIDPTL.get(oCase.W2C_AccountNumber__c).Id;
            }
            // ELC | 20190319 | Manage PTL in case of GEC as well if field W2C_PTLNumber__c is not empty
            if(mExternalIDPTL.get(oCase.W2C_PTLNumber__c) != null && mExternalIDPTL.get(oCase.W2C_PTLNumber__c).Activity_Domain__r.ExternalID__c == 42){
                oCase.PTL__c = mExternalIDPTL.get(oCase.W2C_PTLNumber__c).Id;
            }
        }
        System.Debug('End method AP_Case.fillAccountId');
    }
    
    public static void fillCategoryId(List<Case> lCases)
    {
      System.Debug('Start method AP_Case.fillCategoryId');
      
           
        // Get the the category from Web form
        Set<String> sW2CCategories = new Set<String>();
        for (Case oCase : lCases){
            sW2CCategories.add(oCase.W2C_CaseCategory__c);
        }
        System.debug('AP_Case.fillCategoryId - liste des external ID' + sW2CCategories);

        // Map web form category to Case
        Map<String, Request_Category__c> mW2CCategoryCase = new Map<String, Request_Category__c>();
        for (Request_Category__c oRequest_Category : [SELECT Id, W2C_RequestCategory__c FROM Request_Category__c WHERE W2C_RequestCategory__c IN :sW2CCategories]){
            
           mW2CCategoryCase.put(oRequest_Category.W2C_RequestCategory__c, oRequest_Category);
        }
        System.debug('AP_Case.fillCategoryId - Nom du compte ' + mW2CCategoryCase);
       
        // fill Category Id
        for (Case oCase : lCases){
            if( mW2CCategoryCase.get(oCase.W2C_CaseCategory__c) != null) {
             oCase.Category__c = mW2CCategoryCase.get(oCase.W2C_CaseCategory__c).Id;
             }
        }
        System.Debug('End method AP_Case.fillCategoryId');
    }
    
    public static void fillActivityDomainId(List<Case> lCases)
    {
      System.Debug('Start method AP_Case.fillActivityDomainId');
      
           
        // Get the the activity domain from Web form
        Set<Decimal> sW2CActivityDomains = new Set<Decimal>();
        for (Case oCase : lCases){
            sW2CActivityDomains.add(oCase.W2C_ActivityDomain__c);
        }
        System.debug('AP_Case.fillActivityDomainId - liste des external ID' + sW2CActivityDomains);

        // Map web form Activity Domain to Case
        Map<Decimal, Activity_Domain__c> mW2CActivityDomainsCase = new Map<Decimal, Activity_Domain__c>();
        for (Activity_Domain__c oActivity_Domain : [SELECT Id, ExternalID__c FROM Activity_Domain__c WHERE ExternalID__c IN :sW2CActivityDomains]){
            
           mW2CActivityDomainsCase.put(oActivity_Domain.ExternalID__c, oActivity_Domain);
        }
        System.debug('AP_Case.fillActivityDomainId - Nom du compte ' + mW2CActivityDomainsCase);
       
        // fill Activity Domain Id
        for (Case oCase : lCases){
            if( mW2CActivityDomainsCase.get(oCase.W2C_ActivityDomain__c) != null) {
             oCase.Activity_Domain__c = mW2CActivityDomainsCase.get(oCase.W2C_ActivityDomain__c).Id;
             }
        }
        System.Debug('End method AP_Case.fillActivityDomainId');
    }
    
    
    public static void enableCaseAutoResponse(Set<Id> ids) {
        Database.DMLOptions autoResponseOptions = new Database.DMLOptions();
        autoResponseOptions.EmailHeader.triggerAutoResponseEmail = true;
        List<Case> newCases = [SELECT Id From Case WHERE Id IN :ids];
        Database.update(newCases, autoResponseOptions);
    }

    /*
    @future(callout = true)
    public static void enableCaseAutoResponse(Set<Id> ids) {
        List<Case> newCases = [SELECT Id From Case WHERE Id IN :ids];
        for (Case newCase:newCases) {
            Database.DMLOptions autoResponseOptions = new Database.DMLOptions();
            autoResponseOptions.emailHeader.triggerUserEmail = true;
            newCase.setOptions(autoResponseOptions);
        }
        Database.update(newCases);
    }
    */
}