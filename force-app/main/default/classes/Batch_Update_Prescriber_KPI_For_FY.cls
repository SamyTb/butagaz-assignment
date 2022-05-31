global class Batch_Update_Prescriber_KPI_For_FY implements Database.Batchable<sObject> {
    // Implement the interface to update the couting Opportunities for Account
    global String query; 
    global String emailMessage;
    global Batch_Update_Prescriber_KPI_For_FY (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    global void execute(Database.BatchableContext BC, List<Account> listAccount) {
        List<Opportunity> listOpptyScoring = new  List<Opportunity>([SELECT Id, Name, StageName,project_market_type__c, Prescriber_Account__c, CloseDate,opportunity_won_Substage__c
                                                                     FROM Opportunity 
                                                                     where Prescriber_Account__c=:listAccount and CloseDate = LAST_N_MONTHS:12 and Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                    ]);
        List<Opportunity> listOpptyPrescriptionCurrentFY = new  List<Opportunity>([  SELECT Id, Name, StageName,project_market_type__c, Prescriber_Account__c, CloseDate,opportunity_won_Substage__c 
                                                                                   FROM Opportunity
                                                                                   where Prescriber_Account__c=:listAccount and CloseDate=THIS_FISCAL_YEAR and Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                  ]);
        List<Opportunity> listOpptyPrescriptionLastFY = new  List<Opportunity>([  SELECT Id, Name, StageName,project_market_type__c, Prescriber_Account__c, CloseDate,opportunity_won_Substage__c 
                                                                                FROM Opportunity
                                                                                where Prescriber_Account__c=:listAccount and CloseDate=LAST_FISCAL_YEAR and Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                               ]);
        
        
        List<Event> listEvent = new List<Event> ([Select id,Type_d_evenement_GEC__c,AccountId,EndDateTime 
                                                  From Event 
                                                  where AccountId in:listAccount and Type_d_evenement_GEC__c='PRESCRIPTION' and EndDate=THIS_FISCAL_YEAR ]);
        Map<Id,Account> mapIdAccount = New Map<Id,Account>();
        For(Account accOld:listAccount ){
            Account accNew = new Account( id=accOld.id, 
                                         Nb_de_visites_realisees__c=0, 
                                         Scoring__c='',
                                         Affaires_GEC_prescrites_A_BtoC__c=0,
                                         Affaires_GEC_prescrites_A_BtoB__c=0,
                                         Affaires_GEC_prescritesgagnees_A_BtoC__c=0,
                                         Affaires_GEC_prescrites_gagnees_A_BtoB__c=0
                                        );
            mapIdAccount.put(accOld.id, accNew);
            system.debug('CompteMaj : '+accNew);
            
        }
        system.debug('listOpptyScoring : '+listOpptyScoring.size());
        system.debug('listOpptyPrescription : '+listOpptyPrescriptionCurrentFY.size());
        system.debug('debut comptabilite affaire : ');
        countingOppty(mapIdAccount, listOpptyPrescriptionCurrentFY,false,false);
        system.debug('Fin comptabilite affaire : ');
        system.debug('debut comptabilite scoring : ');
        countingOppty(mapIdAccount, listOpptyScoring,true,false);
        system.debug('fin comptabilite scoring : ');
        system.debug('debut comptabilite event : ');
        countingOppty(mapIdAccount, listOpptyPrescriptionLastFY,false,true);
        countingEvent( mapIdAccount,  listEvent);
        system.debug('fin comptabilite event : ');
        system.debug(mapIdAccount.values());
        List<Database.SaveResult> lsr=   Database.update(mapIdAccount.values());
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    emailMessage =emailMessage+'\r\n The following error has occurred. ';                    
                    emailMessage =emailMessage+'\r\n '+err.getStatusCode() + '  :  ' + err.getMessage()+' ';
                    emailMessage =emailMessage+'\r\n  Account fields that affected this error: ' + err.getFields()+' ';
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('AsyncApexJob : '+job );
        
        // Send an email to the Apex job's submitter notifying of job completion.  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'supportbfi@Butagaz.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch de calcul du scoring pour les comptes Prescritpeurs ');
        mail.setPlainTextBody('exécution du batch de calcul du scoring pour les comptes Prescritpeurs  ( Statut : ' + job.Status+' ) \n\r'+
                              'The batch Apex job processed : ' + job.TotalJobItems +'  batches with : '+ job.NumberOfErrors + '  failures.  \r\n '+ emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    
    private void countingOppty(Map<Id,Account> mapidAccount, List<Opportunity> listOpptyIn, boolean isScoring, boolean isLastfiscal) {
        Map<Id,List<Opportunity>> mapPrescripteurBTBListOppty = new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> mapPrescripteurBTBListOpptyGagnees = new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> mapPrescripteurBTCListOppty = new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> mapPrescripteurBTCListOpptyGagnees = new Map<Id,List<Opportunity>>();
        
        Set<Id> idPrescrAccount = new set<Id>();
        
        for (Opportunity oppty : listOpptyIn) {
            idPrescrAccount.add(oppty.Prescriber_Account__c);  
            if(oppty.project_market_type__c=='DOM'){
                system.debug('isScoring : '+isScoring+' DOM Oppty Prescrite : '+oppty);
                if(oppty.opportunity_won_Substage__c=='Data validated by BO'){
                    system.debug('isScoring : '+isScoring+' DOM Oppty Gagnée : '+oppty);
                    if(mapPrescripteurBTCListOpptyGagnees.containsKey(oppty.Prescriber_Account__c)){
                        ((List<Opportunity>)mapPrescripteurBTCListOpptyGagnees.get(oppty.Prescriber_Account__c)).add(oppty);
                    }else{
                        List<Opportunity> listOppty=new List<Opportunity>();
                        listOppty.add(oppty);
                        mapPrescripteurBTCListOpptyGagnees.put(oppty.Prescriber_Account__c,listOppty);
                    }
                }
                if(mapPrescripteurBTCListOppty.containsKey(oppty.Prescriber_Account__c)){
                    ((List<Opportunity>)mapPrescripteurBTCListOppty.get(oppty.Prescriber_Account__c)).add(oppty);
                }else{
                    List<Opportunity> listOppty=new List<Opportunity>();
                    listOppty.add(oppty);
                    mapPrescripteurBTCListOppty.put(oppty.Prescriber_Account__c,listOppty);
                }    
            }
            else{
                system.debug('isScoring : '+isScoring+' PRO Oppty Prescrite : '+oppty);
                if(oppty.opportunity_won_Substage__c=='Data validated by BO'){
                    system.debug('isScoring : '+isScoring+' PRO Oppty Gagnée : '+oppty);
                    if(mapPrescripteurBTBListOpptyGagnees.containsKey(oppty.Prescriber_Account__c)){
                        ((List<Opportunity>)mapPrescripteurBTBListOpptyGagnees.get(oppty.Prescriber_Account__c)).add(oppty);
                    }else{
                        List<Opportunity> listOppty=new List<Opportunity>();
                        listOppty.add(oppty);
                        mapPrescripteurBTBListOpptyGagnees.put(oppty.Prescriber_Account__c,listOppty);
                    }
                }
                if(mapPrescripteurBTBListOppty.containsKey(oppty.Prescriber_Account__c)){
                    ((List<Opportunity>)mapPrescripteurBTBListOppty.get(oppty.Prescriber_Account__c)).add(oppty);
                }else{
                    List<Opportunity> listOppty=new List<Opportunity>();
                    listOppty.add(oppty);
                    mapPrescripteurBTBListOppty.put(oppty.Prescriber_Account__c,listOppty);
                }                   
            } 
        }            
        List<Account> listAccount = new List<Account>();
        for (Id idpresAccount : idPrescrAccount){
            integer nbAffaireBTC =mapPrescripteurBTCListOppty.containsKey(idpresAccount)?((List<Opportunity>)mapPrescripteurBTCListOppty.get(idpresAccount)).size():0;
            integer nbAffaireBTCGagnees =mapPrescripteurBTCListOpptyGagnees.containsKey(idpresAccount)?((List<Opportunity>)mapPrescripteurBTCListOpptyGagnees.get(idpresAccount)).size():0;
            integer nbAffaireBTB =mapPrescripteurBTBListOppty.containsKey(idpresAccount)?((List<Opportunity>)mapPrescripteurBTBListOppty.get(idpresAccount)).size():0;
            integer nbAffaireBTBGagnees =mapPrescripteurBTBListOpptyGagnees.containsKey(idpresAccount)?((List<Opportunity>)mapPrescripteurBTBListOpptyGagnees.get(idpresAccount)).size():0;
            integer AffaireGagnees =nbAffaireBTBGagnees+nbAffaireBTCGagnees;
            integer affairePrescrite = nbAffaireBTC+nbAffaireBTB;
            String Scoring ='';
            if( isScoring ){
                if( affairePrescrite>0){
                    if( AffaireGagnees>0){
                        switch on AffaireGagnees {
                            when 1,2 {		
                                Scoring='Bronze';
                            }	
                            when 3,4 {		// when block 2
                                Scoring='Argent';
                            }
                            when else {		// when block 3
                                Scoring='Or';
                            }
                            
                        }
                    }else {
                        Scoring='Cuivre';
                    }
                }
                
                ((Account) mapIdAccount.get(idpresAccount)).Scoring__c=Scoring; 
                system.debug('Set scoring  : '+Scoring + '  on account id : '+idpresAccount+'  '); 
            }
            else{
                if( isLastfiscal){
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_A_moins1_BtoC__c=nbAffaireBTC; 
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_A_1_BtoB__c=nbAffaireBTB;
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_gagnees_A_1_BtoC__c=nbAffaireBTCGagnees;
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_gagnees_A_1_BtoB__c=nbAffaireBTBGagnees;
                    system.debug('nbAffaireBTC  : '+nbAffaireBTC + ' nbAffaireBTB  : '+nbAffaireBTB +'  nbAffaireBTCGagnees  : '+nbAffaireBTCGagnees +' nbAffaireBTBGagnees  : '+nbAffaireBTBGagnees); 
                  
                }else{
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_A_BtoC__c=nbAffaireBTC; 
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_A_BtoB__c=nbAffaireBTB;
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescritesgagnees_A_BtoC__c=nbAffaireBTCGagnees;
                    ((Account) mapIdAccount.get(idpresAccount)).Affaires_GEC_prescrites_gagnees_A_BtoB__c=nbAffaireBTBGagnees;
                    system.debug('nbAffaireBTC  : '+nbAffaireBTC + ' nbAffaireBTB  : '+nbAffaireBTB +'  nbAffaireBTCGagnees  : '+nbAffaireBTCGagnees +' nbAffaireBTBGagnees  : '+nbAffaireBTBGagnees); 
                    
                }
                
            }
        }  
    }
    
    private void countingEvent(Map<Id,Account> mapidAccount, List<Event> listEvent) {
        map<id, list<Event>> mapAccToUpdate = new  map<id, list<Event>>();
        for( Event evt :listEvent){
            if (mapAccToUpdate.containsKey(evt.AccountId)){
                list<Event> listevt= mapAccToUpdate.get(evt.AccountId);
                listevt.add(evt);
            }else{
                list<Event> listevt= new list<Event>() ;
                listevt.add(evt);
                mapAccToUpdate.put(evt.AccountId,listevt);
            }
        }
        List<Account> listAccountToUpdate =new List<Account>();
        for(Id idacc : mapAccToUpdate.keySet()){
            list<Event> listevt= mapAccToUpdate.get(idacc);
            if(!mapidAccount.isEmpty() && mapidAccount.containsKey(idacc)){
                Account acc = mapidAccount.get(idacc);
                acc.Nb_de_visites_realisees__c=listevt.size();
            }
        }
    }
    
    
}