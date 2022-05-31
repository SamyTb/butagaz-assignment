public class AP04Lead {

    public static void MatchAdress(List<Lead> leads){
            
            set<String> sPostalCode=new set<String>();
            map<String,List<City_Postal_Code__c>> mCityPostalCode=new map<String,List<City_Postal_Code__c>>();
            List<Lead> lLeadToManage=new List<Lead>();
            Boolean bSelect;
        
            for(Lead oLead:leads){
                bSelect=false;
                if(oLead.Account_City_Postal_Code__c==null){
                     sPostalCode.add(oLead.W2L_Postal_Code__c);
                     bSelect=true;
                }
                if(oLead.Project_City_Postal_Code__c==null){
                     sPostalCode.add(oLead.W2L_Project_Postal_Code__c);
                     bSelect=true;
                }
                if(bSelect)
                    lLeadToManage.add(oLead);
            }
            
            List<City_Postal_Code__c> lPC=[select Id,Postal_Code__c,City__r.Name from City_Postal_Code__c where Postal_Code__c in: sPostalCode ];
            
            for(City_Postal_Code__c oCPC:lPC){
                if(mCityPostalCode.get(oCPC.Postal_Code__c)==null){
                    mCityPostalCode.put(oCPC.Postal_Code__c,new List<City_Postal_Code__c>());
                }
                mCityPostalCode.get(oCPC.Postal_Code__c).add(oCPC);
            }
            String tempCity;
            String tempPostalCode;
            Integer currentMatchDistance;
            Integer bestMatchDistance=1000;
            
            for(Lead oLead:lLeadToManage){
                
                tempCity='';
                tempPostalCode='';
                
                tempPostalCode=oLead.W2L_Postal_Code__c;
                tempCity=oLead.W2L_City__c;
                if(tempPostalCode!=null)
                    tempPostalCode=tempPostalCode.toUpperCase();
                if(tempCity!=null){
                    
                    tempCity=tempCity.toUpperCase();
                    if(mCityPostalCode.get(tempPostalCode)!=null){
                        for(City_Postal_Code__c oCPC:mCityPostalCode.get(tempPostalCode)){
                            currentMatchDistance = tempCity.getLevenshteinDistance(oCPC.City__r.Name);
                            if (currentMatchDistance < bestMatchDistance){
                                oLead.Account_City_Postal_Code__c=oCPC.Id;
                                bestMatchDistance = currentMatchDistance;
                                
                            }
                        }
                    }           
                }
                
                tempCity='';
                tempPostalCode='';
                bestMatchDistance=1000;
                
                tempPostalCode=oLead.W2L_Project_Postal_Code__c;
                tempCity=oLead.W2L_Project_City__c;
                if(tempPostalCode!=null )
                    tempPostalCode=tempPostalCode.toUpperCase();
                if(tempCity!=null){
                    tempCity=tempCity.toUpperCase();
                    if(mCityPostalCode.get(tempPostalCode)!=null){
                        for(City_Postal_Code__c oCPC:mCityPostalCode.get(tempPostalCode)){
                            currentMatchDistance = tempCity.getLevenshteinDistance(oCPC.City__r.Name);
                            if (currentMatchDistance < bestMatchDistance){
                                oLead.Project_City_Postal_Code__c=oCPC.Id;
                                bestMatchDistance = currentMatchDistance;
                                
                            }
                        }
                    }
                }       
            }
      }


    
    public static void fillActivityDomainId(List<Lead> lLeads)
    {
      System.Debug('Start method AP04Lead.fillActivityDomainId');
      
           
        // Get the the activity domain from Web form
        Set<Decimal> sW2LActivityDomains = new Set<Decimal>();
        for (Lead oLead : lLeads){
            sW2LActivityDomains.add(oLead.W2L_Activity_Domain__c);
        }
        System.debug('AP04Lead.fillActivityDomainId - liste des external ID : ' + sW2LActivityDomains);

        // Map web form Activity Domain to Lead
        Map<Decimal, Activity_Domain__c> mW2LActivityDomainsLead = new Map<Decimal, Activity_Domain__c>();
        for (Activity_Domain__c oActivity_Domain : [SELECT Id, ExternalID__c FROM Activity_Domain__c WHERE ExternalID__c IN :sW2LActivityDomains]){
            
           mW2LActivityDomainsLead.put(oActivity_Domain.ExternalID__c, oActivity_Domain);
        }
        System.debug('AP04Lead.fillActivityDomainId - Domaine activité ' + mW2LActivityDomainsLead);
       
        // fill Activity Domain Id
        for (Lead oLead : lLeads){
            if( mW2LActivityDomainsLead.get(oLead.W2L_Activity_Domain__c) != null) {
             oLead.Activity_Domain__c = mW2LActivityDomainsLead.get(oLead.W2L_Activity_Domain__c).Id;
             }
        }
        System.Debug('End method AP04Lead.fillActivityDomainId');
    } 
    
    public static void fillNACEId(List<Lead> lLeads){
        System.Debug('Start method AP04Lead.fillNACEId');
      
        // Get the the activity domain from Web form
        Set<String> sW2LNACECodes = new Set<String>();
        for(Lead oLead : lLeads){
            sW2LNACECodes.add(oLead.W2L_NACE_Code__c);
        }
        System.debug('AP04Lead.fillNACEId - Liste des External IDs : ' + sW2LNACECodes);

        // Map received NACE Code to Lead
        Map<String, Code_NAF__c> mW2LCodeNACELead = new Map<String, Code_NAF__c>();
        for (Code_NAF__c oCode_NACE : [SELECT Id, ExternalID__c FROM Code_NAF__c WHERE ExternalID__c IN :sW2LNACECodes]){
            mW2LCodeNACELead.put(oCode_NACE.ExternalID__c, oCode_NACE);
        }
        System.debug('AP04Lead.fillNACEId - Codes NACE : ' + mW2LCodeNACELead);
       
        // Fill NACE Code Id
        for (Lead oLead : lLeads){
            if(mW2LCodeNACELead.get(oLead.W2L_NACE_Code__c) != null) {
                oLead.Code_NAF__c = mW2LCodeNACELead.get(oLead.W2L_NACE_Code__c).Id;
            }
        }
        System.Debug('End method AP04Lead.fillNACEId');
    }
    
    // Fill the field "T_Predecessor" for successions
    public static void fillTPredecessor(List<Lead> lLeads){
        
        System.Debug('Start method AP04Lead.fillTPredecessor');
          
        for (Lead oLead : lLeads){
            oLead.T_Predecessor__c = oLead.Predecessor__c;
        }

        System.Debug('End method AP04Lead.fillTPredecessor');
    }
    
    @future(callout = true)
    public static void enableLeadAutoResponse(Set<Id> ids) {
        Database.DMLOptions autoResponseOptions = new Database.DMLOptions();
        autoResponseOptions.EmailHeader.triggerAutoResponseEmail = true;
        List<Lead> newLeads = [SELECT Id From Lead WHERE Id IN :ids];
        Database.update(newLeads, autoResponseOptions);
    }
}