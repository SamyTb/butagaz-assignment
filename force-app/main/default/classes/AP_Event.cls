public class AP_Event {
    
    private static boolean alreadyUpdatedEvent = false;
    
    public static void putAcCodeInEvent(list<Event> lEvent){

        List<Id> lEventId = new list<Id>();
        List<Id> lOwnerId = new list<Id>();
        map<id, User> mUserIdtoUser = new map<id, User>(); 
        
        List<Event> lEventToUpdate = new List<Event>();
        
        //System.debug('[AP_Event.putAcCodeInEvent] lEvent Counts: ' + lEvent.size());    
            
        //Recover the list PTL iD
        for(Event oEvent:lEvent){
                lEventId.add(oEvent.id); 
        }       
        
        List<Event> lAllEventChanged = [Select Id,ActivityDate,RecordType.Name, OwnerId from Event where id in: lEventId];
        List<Event> lGEBEventChanged = new List<Event>();
        for(Event oEvent:lAllEventChanged){
            if(oEvent.RecordType.Name=='Visite GEB' && oEvent.OwnerId!=null ){
                lGEBEventChanged.add(oEvent);
                lOwnerId.add(oEvent.OwnerId);
            }           
                        
        }
        
        list<User> lUser=[Select id, AC_Code__c from User Where id in :lOwnerId ];
        //System.debug('[AP_Event.putAcCodeInEvent] lUser Counts: ' + lUser.size());          
        for(User oUser:lUser){
            mUserIdtoUser.put(oUser.id,oUser);  
            //System.debug('[AP_Event.putAcCodeInEvent] Ac Code: '+ oUser.AC_Code__c);    
                    
        }
        
        for(Event oEvent:lGEBEventChanged){
            lEventToUpdate.add(new Event(
                          Id=oEvent.id,
                          Code_AC_administrator__c=mUserIdtoUser.get(oEvent.OwnerId).AC_Code__c,
                          Year_of_Event__c=string.valueof(oEvent.ActivityDate.year())
                        )
                      );            
        }
    
        // Update database      
        if(lEventToUpdate.size()>0){
            try{
                update lEventToUpdate;
            } 
            catch(DmlException e){
                //System.debug('Error: '+ e);
            }           
         }  
    }

    public static void putSegmentationScoringInEvent(list<Event> lEvent){
        List<Id> lEventId = new list<Id>();
        map<id, Event> mIdToEvent = new map<id, Event>();       
        map<id, Event> mAccountIdToEvent = new map<id, Event>(); 
        map<id, Event> mPTLIdIdToEvent = new map<id, Event>(); 
        List<Event> lEventToUpdate = new List<Event>();
        
        //System.debug('[AP_Event.putSegmentationScoringInEvent] lEvent Counts: ' + lEvent.size());   
            
        //Recover the list PTL iD
        for(Event oEvent:lEvent){
                lEventId.add(oEvent.id); 
        }       
        
        List<Event> lAllEventChanged = [Select Id,Segmentation_Scoring__c,RecordType.Name, whatid from Event where id in: lEventId ];
        List<Event> lGEBEventChanged = new List<Event>();
        for(Event oEvent:lAllEventChanged){
            if(oEvent.RecordType.Name=='Visite GEB' && oEvent.whatid!=null ){
                lGEBEventChanged.add(oEvent);
            }
        }
        String PTL_prefix = Schema.SObjectType.PTL__c.getKeyPrefix();
        String Account_prefix = Schema.SObjectType.Account.getKeyPrefix();      
        for(Event oEvent:lGEBEventChanged){
            String task_whatid = oEvent.WhatId;
            if(task_whatid.startsWith(account_prefix)){
                mAccountIdToEvent.put(oEvent.WhatId, oEvent);
            }
            if(task_whatid.startsWith(PTL_prefix)){
                mPTLIdIdToEvent.put(oEvent.WhatId, oEvent);
            }
            mIdToEvent.put(oEvent.id,oEvent);           
        }
        
        if(mAccountIdToEvent.size()>0){
            list<Account> lAccount =[Select id, Segmentation__c from Account Where id in : mAccountIdToEvent.keyset()];
            for(Account oAccount:lAccount){
                if( mAccountIdToEvent.get(oAccount.id).Segmentation_Scoring__c == null 
                    || mAccountIdToEvent.get(oAccount.id).Segmentation_Scoring__c == ''){ 
                    
                    lEventToUpdate.add(new Event(
                                  Id=mAccountIdToEvent.get(oAccount.id).Id,
                                  Segmentation_Scoring__c=oAccount.Segmentation__c
                                )
                              );    
                }               
            }       
        }

        if(mPTLIdIdToEvent.size()>0){
            list<PTL__c> lPTL =[Select id, Segmentation__c from PTL__c Where id in : mPTLIdIdToEvent.keyset()];
            for(PTL__c oPTL:lPTL){
                if( mPTLIdIdToEvent.get(oPTL.id).Segmentation_Scoring__c == null 
                    || mPTLIdIdToEvent.get(oPTL.id).Segmentation_Scoring__c == ''){ 
                    
                    lEventToUpdate.add(new Event(
                                  Id=mPTLIdIdToEvent.get(oPTL.id).Id,
                                  Segmentation_Scoring__c=oPTL.Segmentation__c
                                )
                              );    
                }               
            }       
        }
        
        // Update database      
        if(lEventToUpdate.size()>0){
            try{
                update lEventToUpdate;
            } 
            catch(DmlException e){
            }           
         }          
        
    }
    
    @future
    //public static void putSObjectInfoInEvent(list<Event> lEvent){
    public static void putSObjectInfoInEvent(list<Id> lEventId){
        //List<Id> lEventId = new list<Id>();
        map<id, Event> mIdToEvent = new map<id, Event>();
        map<id, Event> mAccountIdToEvent = new map<id, Event>();
        map<id, Event> mPTLIdToEvent = new map<id, Event>();
        map<id, Event> mEquipementIdToEvent = new map<id, Event>();
        map<id, Event> mCaseIdToEvent = new map<id, Event>();
        map<id, Event> mOptyIdToEvent = new map<id, Event>();
        map<id, Event> mLeadIdToEvent = new map<id, Event>();
        String RecordTypeEvenement =''; 
        String ObjetTypeEvenement =''; 
        String sSubject = '';
        
        
        List<Event> lEventToUpdate = new List<Event>();
        
        //System.debug('[AP_Event.putSObjectInfoInEvent] lEventId Counts: ' + lEventId.size());   
        
        /*// Store the list of event Ids
        for(Event oEvent:lEvent){
            lEventId.add(oEvent.id);
        }*/
        
        List<Event> lAllEventChanged = [Select Id, RecordType.Name, WhatId, WhoId, City_Postal_Code__c, Departement__c, Mandataire__c,
                Telephone__c, EMail__c, Subject, Type_d_evenement_GEC__c, What.Name, Who.Name, Objet_GEB__c
                from Event where id in: lEventId ];
                
       
        
        List<Event> lGECEventChanged = new List<Event>();
        for(Event oEvent:lAllEventChanged){
            if((oEvent.RecordType.Name== 'Visite GEC'|| oEvent.RecordType.Name=='Visite Prescripteur' || oEvent.RecordType.Name=='Visite GEB'  ) && (oEvent.whatid!=null || oEvent.whoid!=null) ){
            
                
        if (oEvent.RecordType.Name== 'Visite GEC')
        {
            RecordTypeEvenement = 'GEC';
        }
        
        if (oEvent.RecordType.Name== 'Visite Prescripteur')
        {
            RecordTypeEvenement = 'Prescripteur';
        }
        
        if (oEvent.RecordType.Name== 'Visite GEB')
        {
            RecordTypeEvenement = 'GEB';
        }
                
                oEvent.City_Postal_Code__c=null;
                oEvent.Departement__c='';
                oEvent.Mandataire__c=null;
                oEvent.Telephone__c='';
                oEvent.EMail__c='';
                //oEvent.Subject=oEvent.Type_d_evenement_GEC__c;
                
                if (RecordTypeEvenement== 'Prescripteur' || RecordTypeEvenement == 'GEC')
                {
                oEvent.Subject=oEvent.Type_d_evenement_GEC__c;
                ObjetTypeEvenement = oEvent.Type_d_evenement_GEC__c ; 
        
                }
                else
                {
                oEvent.Subject=oEvent.Objet_GEB__c;
                ObjetTypeEvenement = oEvent.Objet_GEB__c ; 
                }
                
                lGECEventChanged.add(oEvent);
            }
        }
        
        // To reset custom fields to blank
        update lGECEventChanged;
        
        String Account_prefix = Schema.SObjectType.Account.getKeyPrefix();
        String PTL_prefix = Schema.SObjectType.PTL__c.getKeyPrefix();
        String Equipement_prefix = Schema.SObjectType.Equipement__c.getKeyPrefix();
        String Case_prefix = Schema.SObjectType.Case.getKeyPrefix();
        String Opty_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
        String Lead_prefix = Schema.SObjectType.Lead.getKeyPrefix();
        for(Event oEvent:lGECEventChanged){
            String event_whatid = oEvent.WhatId;
            String event_whoid = oEvent.WhoId;
            
            if(event_whatid!=null){
                if(event_whatid.startsWith(account_prefix)){
                    mAccountIdToEvent.put(oEvent.WhatId, oEvent);
                }
                else if(event_whatid.startsWith(PTL_prefix)){
                    mPTLIdToEvent.put(oEvent.WhatId, oEvent);
                }
                else if(event_whatid.startsWith(Equipement_prefix)){
                    mEquipementIdToEvent.put(oEvent.WhatId, oEvent);
                }
                else if(event_whatid.startsWith(Case_prefix)){
                    mCaseIdToEvent.put(oEvent.WhatId, oEvent);
                }
                else if(event_whatid.startsWith(Opty_prefix)){
                    mOptyIdToEvent.put(oEvent.WhatId, oEvent);
                }
            }
            // Particular case for Leads that are selected from the Who lookup, not the What lookup
            else if(event_whoid!=null){
                if(event_whoid.startsWith(Lead_prefix)){
                    mLeadIdToEvent.put(oEvent.WhoId, oEvent);
                }
            }
            
            mIdToEvent.put(oEvent.id, oEvent);          
        }
        
        // WhatId = Account
        if(mAccountIdToEvent.size()>0){
            list<Account> lAccount =[Select Id, Mobile_Phone_Number__c, Phone, Work_Phone_Number__c, Email__c, Email_2__c,
                    City_Postal_Code__c, Mandataire__c, City_Postal_Code__r.City__r.Canton__r.Department_Code__c,City_Postal_Code__r.City__r.Name
                    from Account Where Id in : mAccountIdToEvent.keyset() ];
            for(Account oAccount:lAccount){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oAccount.Mobile_Phone_Number__c!=null){
                    myPhone=oAccount.Mobile_Phone_Number__c;
                }
                else if(oAccount.Phone!=null){
                    myPhone=oAccount.Phone;
                }
                else if(oAccount.Work_Phone_Number__c!=null){
                    myPhone=oAccount.Work_Phone_Number__c;
                }else{
                    myPhone=null;
                }
                
                // Take 1st non-NULL EMail
                String myEMail = '';
                if(oAccount.Email__c!=null){
                    myEMail=oAccount.Email__c;
                }
                else if(oAccount.Email_2__c!=null){
                    myEMail=oAccount.Email_2__c;
                }else{
                    myEMail=null;
                }
                
                string myDept = '';
                if(oAccount.City_Postal_Code__r.City__r!=null)
               
                    myDept = oAccount.City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                    
                    
                     if (RecordTypeEvenement=='GEC' || RecordTypeEvenement =='Prescripteur')
                      {
                          sSubject =ObjetTypeEvenement + ' - ' + myDept  + mAccountIdToEvent.get(oAccount.Id).What.Name;
                      }
                      else
                      {
                          sSubject =ObjetTypeEvenement + ' - '  + mAccountIdToEvent.get(oAccount.Id).What.Name + ' - '  + oAccount.City_Postal_Code__r.City__r.Name;
                      }
                             
                       
                    
                
                //System.debug(logginglevel.WARN,'### putSObjectInfoInEvent: oAccount.City_Postal_Code__c : ' + oAccount.City_Postal_Code__c);
                lEventToUpdate.add(new Event(
                              Id=mAccountIdToEvent.get(oAccount.Id).Id,
                              City_Postal_Code__c=oAccount.City_Postal_Code__c,
                              Departement__c=oAccount.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oAccount.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=myEMail,
                              Subject=sSubject)
                          );
                
            }
        }
        
        // WhatId = PTL
        if(mPTLIdToEvent.size()>0){
            list<PTL__c> lPTL =[Select Id, Mobile_Phone_Number__c, Phone__c, Work_Phone_Number__c, Account_DO__r.Email__c, Account_DO__r.Email_2__c,
                    City_Postal_Code__c, Mandataire__c, City_Postal_Code__r.City__r.Canton__r.Department_Code__c, Account_DO__r.Name,City_Postal_Code__r.City__r.Name,First_and_Last_Name__c
                from PTL__c Where Id in : mPTLIdToEvent.keyset() ];
            for(PTL__c oPTL:lPTL){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oPTL.Mobile_Phone_Number__c!=null){
                    myPhone=oPTL.Mobile_Phone_Number__c;
                }
                else if(oPTL.Phone__c!=null){
                    myPhone=oPTL.Phone__c;
                }
                else if(oPTL.Work_Phone_Number__c!=null){
                    myPhone=oPTL.Work_Phone_Number__c;
                }else{
                    myPhone=null;
                }
                
                // Take 1st non-NULL EMail
                String myEMail = '';
                if(oPTL.Account_DO__r.Email__c!=null){
                    myEMail=oPTL.Account_DO__r.Email__c;
                }
                else if(oPTL.Account_DO__r.Email_2__c!=null){
                    myEMail=oPTL.Account_DO__r.Email_2__c;
                }else{
                    myEMail=null;
                }
                
                string myDept = '';
                if(oPTL.City_Postal_Code__r.City__r!=null)
                    myDept = oPTL.City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                    
                    
                  
                     if (RecordTypeEvenement=='GEC' || RecordTypeEvenement =='Prescripteur')
                      {
                          sSubject =ObjetTypeEvenement + ' - ' + myDept  + oPTL.Account_DO__r.Name;
                      }
                      else
                      {
                          sSubject=ObjetTypeEvenement + ' - '  + oPTL.Account_DO__r.Name + ' - '  + oPTL.City_Postal_Code__r.City__r.Name;
                      }   
                              
                lEventToUpdate.add(new Event(
                              Id=mPTLIdToEvent.get(oPTL.Id).Id,
                              City_Postal_Code__c=oPTL.City_Postal_Code__c,
                              Departement__c=oPTL.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oPTL.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=myEMail,
                             // Subject=mPTLIdToEvent.get(oPTL.Id).Type_d_evenement_GEC__c + ' - ' + myDept + oPTL.Account_DO__r.Name
                              Subject= sSubject)
                             
                          );
                            
            }       
        }
        
        // WhatId = Equipement__c
        if(mEquipementIdToEvent.size()>0){
            list<Equipement__c> lEquipement =[SELECT Id, PTL__r.Account_DO__r.Mobile_Phone_Number__c, PTL__r.Account_DO__r.Phone, PTL__r.Account_DO__r.Work_Phone_Number__c, PTL__r.Account_DO__r.Email__c, PTL__r.Account_DO__r.Email_2__c,
                PTL__r.Account_DO__r.City_Postal_Code__c, PTL__r.Account_DO__r.Mandataire__c, PTL__r.Account_DO__r.City_Postal_Code__r.City__r.Canton__r.Department_Code__c, PTL__r.Account_DO__r.Name
                from Equipement__c Where Id in : mEquipementIdToEvent.keyset() ];
            for(Equipement__c oEquipement:lEquipement){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oEquipement.PTL__r.Account_DO__r.Mobile_Phone_Number__c!=null){
                    myPhone=oEquipement.PTL__r.Account_DO__r.Mobile_Phone_Number__c;
                }
                else if(oEquipement.PTL__r.Account_DO__r.Phone!=null){
                    myPhone=oEquipement.PTL__r.Account_DO__r.Phone;
                }
                else if(oEquipement.PTL__r.Account_DO__r.Work_Phone_Number__c!=null){
                    myPhone=oEquipement.PTL__r.Account_DO__r.Work_Phone_Number__c;
                }else{
                    myPhone=null;
                }
                
                // Take 1st non-NULL EMail
                String myEMail = '';
                if(oEquipement.PTL__r.Account_DO__r.Email__c!=null){
                    myEMail=oEquipement.PTL__r.Account_DO__r.Email__c;
                }
                else if(oEquipement.PTL__r.Account_DO__r.Email_2__c!=null){
                    myEMail=oEquipement.PTL__r.Account_DO__r.Email_2__c;
                }else{
                    myEMail=null;
                }
                
                string myDept = '';
                if(oEquipement.PTL__r.Account_DO__r.City_Postal_Code__r.City__r!=null)
                    myDept = oEquipement.PTL__r.Account_DO__r.City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                              
                lEventToUpdate.add(new Event(
                              Id=mEquipementIdToEvent.get(oEquipement.Id).Id,
                              City_Postal_Code__c=oEquipement.PTL__r.Account_DO__r.City_Postal_Code__c,
                              Departement__c=oEquipement.PTL__r.Account_DO__r.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oEquipement.PTL__r.Account_DO__r.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=myEMail,
                              Subject=mEquipementIdToEvent.get(oEquipement.Id).Type_d_evenement_GEC__c + ' - ' + myDept + oEquipement.PTL__r.Account_DO__r.Name
                            )
                          );
                
            }       
        }
        
        // WhatId = Case
        if(mCaseIdToEvent.size()>0){
            list<Case> lCase =[SELECT Id, Account.Mobile_Phone_Number__c, Account.Phone, Account.Work_Phone_Number__c, Account.Email__c, Account.Email_2__c, 
                Account.City_Postal_Code__c, Account.Mandataire__c, Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c, Account.Name
                FROM Case Where Id in : mCaseIdToEvent.keyset() ];
            for(Case oCase:lCase){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oCase.Account.Mobile_Phone_Number__c!=null){
                    myPhone=oCase.Account.Mobile_Phone_Number__c;
                }
                else if(oCase.Account.Phone!=null){
                    myPhone=oCase.Account.Phone;
                }
                else if(oCase.Account.Work_Phone_Number__c!=null){
                    myPhone=oCase.Account.Work_Phone_Number__c;
                }else{
                    myPhone=null;
                }
                
                // Take 1st non-NULL EMail
                String myEMail = '';
                if(oCase.Account.Email__c!=null){
                    myEMail=oCase.Account.Email__c;
                }
                else if(oCase.Account.Email_2__c!=null){
                    myEMail=oCase.Account.Email_2__c;
                }else{
                    myEMail=null;
                }
                
                string myDept = '';
                if(oCase.Account.City_Postal_Code__r.City__r!=null)
                    myDept = oCase.Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                
                lEventToUpdate.add(new Event(
                              Id=mCaseIdToEvent.get(oCase.Id).Id,
                              City_Postal_Code__c=oCase.Account.City_Postal_Code__c,
                              Departement__c=oCase.Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oCase.Account.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=myEMail,
                              Subject=mCaseIdToEvent.get(oCase.Id).Type_d_evenement_GEC__c + ' - ' + myDept + oCase.Account.Name
                            )
                          );
                
            }
        }
        
        // WhatId = Opportunity
        if(mOptyIdToEvent.size()>0){
            list<Opportunity> lOpty =[SELECT Id, Account.Mobile_Phone_Number__c, Account.Phone, Account.Work_Phone_Number__c, Account.Email__c, Account.Email_2__c, 
                Account.City_Postal_Code__c, Account.Mandataire__c, Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c, Account.Name
                FROM Opportunity Where Id in : mOptyIdToEvent.keyset() ];
            for(Opportunity oOpty:lOpty){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oOpty.Account.Mobile_Phone_Number__c!=null){
                    myPhone=oOpty.Account.Mobile_Phone_Number__c;
                }
                else if(oOpty.Account.Phone!=null){
                    myPhone=oOpty.Account.Phone;
                }
                else if(oOpty.Account.Work_Phone_Number__c!=null){
                    myPhone=oOpty.Account.Work_Phone_Number__c;
                }else{
                    myPhone=null;
                }
                
                // Take 1st non-NULL EMail
                String myEMail = '';
                if(oOpty.Account.Email__c!=null){
                    myEMail=oOpty.Account.Email__c;
                }
                else if(oOpty.Account.Email_2__c!=null){
                    myEMail=oOpty.Account.Email_2__c;
                }else{
                    myEMail=null;
                }
                
                string myDept = '';
                if(oOpty.Account.City_Postal_Code__r.City__r!=null)
                    myDept = oOpty.Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                
                lEventToUpdate.add(new Event(
                              Id=mOptyIdToEvent.get(oOpty.Id).Id,
                              City_Postal_Code__c=oOpty.Account.City_Postal_Code__c,
                              Departement__c=oOpty.Account.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oOpty.Account.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=myEMail,
                              Subject=mOptyIdToEvent.get(oOpty.Id).Type_d_evenement_GEC__c + ' - ' + myDept + oOpty.Account.Name
                            )
                          );
                
            }
        }
        
        // WhoId = Lead
        if(mLeadIdToEvent.size()>0){
            list<Lead> lLead =[Select Id, MobilePhone, Phone, Email, Account_City_Postal_Code__c, 
                Account_City_Postal_Code__r.City__r.Canton__r.Mandataire__c, Account_City_Postal_Code__r.City__r.Canton__r.Department_Code__c
                from Lead Where Id in : mLeadIdToEvent.keyset() ];
            for(Lead oLead:lLead){
                
                // Take 1st non-NULL Phone
                String myPhone = '';
                if(oLead.MobilePhone!=null){
                    myPhone=oLead.MobilePhone;
                }
                else if(oLead.Phone!=null){
                    myPhone=oLead.Phone;
                }
                else{
                    myPhone=null;
                }
                
                string myDept = '';
                if(oLead.Account_City_Postal_Code__r.City__r!=null)
                    myDept = oLead.Account_City_Postal_Code__r.City__r.Canton__r.Department_Code__c + ' - ';
                
                lEventToUpdate.add(new Event(
                              Id=mLeadIdToEvent.get(oLead.Id).Id,
                              City_Postal_Code__c=oLead.Account_City_Postal_Code__c,
                              Departement__c=oLead.Account_City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                              Mandataire__c=oLead.Account_City_Postal_Code__r.City__r.Canton__r.Mandataire__c,
                              Telephone__c=myPhone,
                              EMail__c=oLead.Email,
                              Subject=mLeadIdToEvent.get(oLead.Id).Type_d_evenement_GEC__c + ' - ' + myDept + mLeadIdToEvent.get(oLead.Id).Who.Name
                            )
                          );
                
            }
        }
        
        
        // Update database      
        if(lEventToUpdate.size()>0){
            try{
            	//System.debug(logginglevel.WARN,'### lEventToUpdate : ' + lEventToUpdate);
                update lEventToUpdate;
            } 
            catch(DmlException e){
            }           
         }          
        
    }
    
  /*  //MLC20180228
    
    public static void putSObjectInfoPTLGEBInEvent(list<Event> lEvent){
    List<Id> lEventId = new list<Id>();
    map<id, Event> mIdToEvent = new map<id, Event>();
    Map<id, Event> mAccountIdToEvent = new map<id, Event>();
    map<id, Event> mPTLIdToEvent = new map<id, Event>();
   
    
    
    List<Event> lEventToUpdate = new List<Event>();
    
    //System.debug('[AP_Event.putSObjectInfoInEvent] lEvent Counts: ' + lEvent.size());  
    
    // Store the list of event Ids
    for(Event oEvent:lEvent){
          lEventId.add(oEvent.id);
      }
    
    List<Event> lAllEventChanged = [Select Id, RecordType.Name, WhatId, WhoId, City_Postal_Code__c, Departement__c, Mandataire__c,
        Telephone__c, EMail__c, Subject, What.Name, Who.Name,Objet_GEB__c
         from Event where id in: lEventId ];
    List<Event> lGEBEventChanged = new List<Event>();
    for(Event oEvent:lAllEventChanged){
      if(oEvent.RecordType.Name=='Visite GEB' && (oEvent.whatid!=null || oEvent.whoid!=null) ){
        oEvent.City_Postal_Code__c=null;
        oEvent.Departement__c='';
        oEvent.Mandataire__c=null;
        oEvent.Telephone__c='';
        oEvent.EMail__c='';
        oEvent.Subject=oEvent.Objet_GEB__c;

        
        lGEBEventChanged.add(oEvent);
      }
    }
    
    // To reset custom fields to blank
    update lGEBEventChanged;
    
    String Account_prefix = Schema.SObjectType.Account.getKeyPrefix();
    String PTL_prefix = Schema.SObjectType.PTL__c.getKeyPrefix();
    
    for(Event oEvent:lGEBEventChanged){
      String event_whatid = oEvent.WhatId;
      String event_whoid = oEvent.WhoId;
      
      if(event_whatid!=null){
        if(event_whatid.startsWith(account_prefix)){
          mAccountIdToEvent.put(oEvent.WhatId, oEvent);
        }
        else if(event_whatid.startsWith(PTL_prefix)){
          mPTLIdToEvent.put(oEvent.WhatId, oEvent);
        }
        
      }
      
      
      mIdToEvent.put(oEvent.id, oEvent);      
    }
    
    // WhatId = Account
    if(mAccountIdToEvent.size()>0){
      list<Account> lAccount =[Select Id, Mobile_Phone_Number__c, Phone, Work_Phone_Number__c, Email__c, Email_2__c,
          City_Postal_Code__c, Mandataire__c, City_Postal_Code__r.City__r.Name,Name,City_Postal_Code__r.City__r.Canton__r.Department_Code__c
           from Account Where Id in : mAccountIdToEvent.keyset() ];
      for(Account oAccount:lAccount){
        
        // Take 1st non-NULL Phone
        String myPhone = '';
        if(oAccount.Mobile_Phone_Number__c!=null){
          myPhone=oAccount.Mobile_Phone_Number__c;
        }
        else if(oAccount.Phone!=null){
          myPhone=oAccount.Phone;
        }
        else if(oAccount.Work_Phone_Number__c!=null){
          myPhone=oAccount.Work_Phone_Number__c;
        }else{
          myPhone=null;
        }
        
        // Take 1st non-NULL EMail
        String myEMail = '';
        if(oAccount.Email__c!=null){
          myEMail=oAccount.Email__c;
        }
        else if(oAccount.Email_2__c!=null){
          myEMail=oAccount.Email_2__c;
        }else{
          myEMail=null;
        }
        
        string myDept = '';
        if(oAccount.City_Postal_Code__r.City__r!=null)
          myDept = mAccountIdToEvent.get(oAccount.Id).What.Name + ' - ';
        
        //System.debug(logginglevel.WARN,'### putSObjectInfoInEvent: oAccount.City_c : ' + oAccount.City_Postal_Code__r.City__r.Name);
        lEventToUpdate.add(new Event(
                Id=mAccountIdToEvent.get(oAccount.Id).Id,
                City_Postal_Code__c=oAccount.City_Postal_Code__c,
                Departement__c=oAccount.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                Mandataire__c=oAccount.Mandataire__c,
                Telephone__c=myPhone,
                EMail__c=myEMail,
                Subject=mAccountIdToEvent.get(oAccount.Id).Objet_GEB__c+ ' - ' + myDept + oAccount.City_Postal_Code__r.City__r.Name
              )
              );
        
      }
    }
    
    // WhatId = PTL
    if(mPTLIdToEvent.size()>0){
      list<PTL__c> lPTL =[Select Id, Mobile_Phone_Number__c, Phone__c, Work_Phone_Number__c, Account_DO__r.Email__c, Account_DO__r.Email_2__c,
          City_Postal_Code__c, Mandataire__c, City_Postal_Code__r.City__r.Canton__r.Department_Code__c, Account_DO__r.Name,City_Postal_Code__r.City__r.Name,First_and_Last_Name__c
        from PTL__c Where Id in : mPTLIdToEvent.keyset() ];
      for(PTL__c oPTL:lPTL){
        
        // Take 1st non-NULL Phone
        String myPhone = '';
        if(oPTL.Mobile_Phone_Number__c!=null){
          myPhone=oPTL.Mobile_Phone_Number__c;
        }
        else if(oPTL.Phone__c!=null){
          myPhone=oPTL.Phone__c;
        }
        else if(oPTL.Work_Phone_Number__c!=null){
          myPhone=oPTL.Work_Phone_Number__c;
        }else{
          myPhone=null;
        }
        
        // Take 1st non-NULL EMail
        String myEMail = '';
        if(oPTL.Account_DO__r.Email__c!=null){
          myEMail=oPTL.Account_DO__r.Email__c;
        }
        else if(oPTL.Account_DO__r.Email_2__c!=null){
          myEMail=oPTL.Account_DO__r.Email_2__c;
        }else{
          myEMail=null;
        }
        
        string myDept = '';
        if(oPTL.City_Postal_Code__r.City__r!=null)
          myDept = oPTL.First_and_Last_Name__c + ' - ';
                
        lEventToUpdate.add(new Event(
                Id=mPTLIdToEvent.get(oPTL.Id).Id,
                City_Postal_Code__c=oPTL.City_Postal_Code__c,
                Departement__c=oPTL.City_Postal_Code__r.City__r.Canton__r.Department_Code__c,
                Mandataire__c=oPTL.Mandataire__c,
                Telephone__c=myPhone,
                EMail__c=myEMail,
                Subject=mPTLIdToEvent.get(oPTL.Id).Objet_GEB__c+ ' - ' + myDept + oPTL.City_Postal_Code__r.City__r.Name
              )
              );
              
      }    
    }
    
  
   
    
    
    // Update database      
        if(lEventToUpdate.size()>0){
          try{
             update lEventToUpdate;
          } 
            catch(DmlException e){
            }           
         }       
    
  }
    */
    public static boolean hasAlreadyUpdatedEvent() {
        return alreadyUpdatedEvent;
    }
        
    public static void setAlreadyUpdatedEvent(boolean b) {
        alreadyUpdatedEvent = b;
    }  
   
}