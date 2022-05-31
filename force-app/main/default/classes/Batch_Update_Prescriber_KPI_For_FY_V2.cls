global class Batch_Update_Prescriber_KPI_For_FY_V2 implements Database.Batchable<sObject> {
    // Implement the interface to update the couting Opportunities for Account
    global String query; 
    global String emailMessage;
    global Batch_Update_Prescriber_KPI_For_FY_V2 (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    global void execute(Database.BatchableContext BC, List<Account> listAccount) {
        
        
        // Affaire sur 12 mois roulant
        Map<id,AggregateResult> mapAffaireBTC = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                 FROM Opportunity 
                                                                                 where Prescriber_Account__c=:listAccount 
                                                                                 and   CloseDate = LAST_N_MONTHS:12 
                                                                                 and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                 and  project_market_type__c='DOM'
                                                                                 Group By Prescriber_Account__c
                                                                                ]);
        Map<id,AggregateResult> mapAffairegagneesBTC = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                        FROM Opportunity 
                                                                                        where Prescriber_Account__c=:listAccount 
                                                                                        and   CloseDate = LAST_N_MONTHS:12 
                                                                                        and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                        and  project_market_type__c='DOM'
                                                                                        and  opportunity_won_Substage__c='Data validated by BO'
                                                                                        Group By Prescriber_Account__c
                                                                                       ]);
        Map<id,AggregateResult> mapAffaireBTB = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                 FROM Opportunity 
                                                                                 where Prescriber_Account__c=:listAccount 
                                                                                 and   CloseDate = LAST_N_MONTHS:12 
                                                                                 and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                 and  project_market_type__c!='DOM'
                                                                                 Group By Prescriber_Account__c
                                                                                ]);
        Map<id,AggregateResult> mapAffairegagneesBTB = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                        FROM Opportunity 
                                                                                        where Prescriber_Account__c=:listAccount 
                                                                                        and   CloseDate = LAST_N_MONTHS:12 
                                                                                        and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                        and  project_market_type__c!='DOM'
                                                                                        and  opportunity_won_Substage__c='Data validated by BO'
                                                                                        Group By Prescriber_Account__c
                                                                                       ]);
        
        // Affaire année fiscal en cours 
        Map<id,AggregateResult> mapAffaireBTCFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                   FROM Opportunity 
                                                                                   where Prescriber_Account__c=:listAccount 
                                                                                   and   CloseDate = THIS_FISCAL_YEAR 
                                                                                   and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                   and  project_market_type__c='DOM'
                                                                                   Group By Prescriber_Account__c
                                                                                  ]);
        Map<id,AggregateResult> mapAffairegagneesBTCFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                          FROM Opportunity 
                                                                                          where Prescriber_Account__c=:listAccount 
                                                                                          and   CloseDate = THIS_FISCAL_YEAR 
                                                                                          and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                          and  project_market_type__c='DOM'
                                                                                          and  opportunity_won_Substage__c='Data validated by BO'
                                                                                          Group By Prescriber_Account__c
                                                                                         ]);
        Map<id,AggregateResult> mapAffaireBTBFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                   FROM Opportunity 
                                                                                   where Prescriber_Account__c=:listAccount 
                                                                                   and   CloseDate = THIS_FISCAL_YEAR 
                                                                                   and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                   and  project_market_type__c!='DOM'
                                                                                   Group By Prescriber_Account__c
                                                                                  ]);
        Map<id,AggregateResult> mapAffairegagneesBTBFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                          FROM Opportunity 
                                                                                          where Prescriber_Account__c=:listAccount 
                                                                                          and   CloseDate = THIS_FISCAL_YEAR 
                                                                                          and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                          and  project_market_type__c!='DOM'
                                                                                          and  opportunity_won_Substage__c='Data validated by BO'
                                                                                          Group By Prescriber_Account__c
                                                                                         ]);
        
        // Affaire année fiscal précédente                                                             
        Map<id,AggregateResult> mapAffaireBTCLFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                    FROM Opportunity 
                                                                                    where Prescriber_Account__c=:listAccount 
                                                                                    and   CloseDate = LAST_FISCAL_YEAR 
                                                                                    and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                    and  project_market_type__c='DOM'
                                                                                    Group By Prescriber_Account__c
                                                                                   ]);
        Map<id,AggregateResult> mapAffairegagneesBTCLFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                           FROM Opportunity 
                                                                                           where Prescriber_Account__c=:listAccount 
                                                                                           and   CloseDate = LAST_FISCAL_YEAR 
                                                                                           and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                           and  project_market_type__c='DOM'
                                                                                           and  opportunity_won_Substage__c='Data validated by BO'
                                                                                           Group By Prescriber_Account__c
                                                                                          ]);
        Map<id,AggregateResult> mapAffaireBTBLFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                    FROM Opportunity 
                                                                                    where Prescriber_Account__c=:listAccount 
                                                                                    and   CloseDate = LAST_FISCAL_YEAR 
                                                                                    and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                    and  project_market_type__c!='DOM'
                                                                                    Group By Prescriber_Account__c
                                                                                   ]);
        Map<id,AggregateResult> mapAffairegagneesBTBLFY = new    Map<id,AggregateResult> ([SELECT count (Id) cnt,Prescriber_Account__c Id
                                                                                           FROM Opportunity 
                                                                                           where Prescriber_Account__c=:listAccount 
                                                                                           and   CloseDate = LAST_FISCAL_YEAR 
                                                                                           and   Prescriber_Account__r.Activity_Domain__r.ExternalID__c in (42,45)
                                                                                           and  project_market_type__c!='DOM'
                                                                                           and  opportunity_won_Substage__c='Data validated by BO'
                                                                                           Group By Prescriber_Account__c
                                                                                          ]);
        
        List<AggregateResult> ListEventFY = new List<AggregateResult>([Select AccountId id,count(id)nb,Categories__c 
                                                                       From Event 
                                                                       where AccountId in :listAccount 
                                                                       and   Type_d_evenement_GEC__c='PRESCRIPTION' 
                                                                       and   EndDate=THIS_FISCAL_YEAR
                                                                       Group By AccountId,Categories__c
                                                                      ]);
        
        
       Map<id,AggregateResult> mapSuspectPrescritFY = new   Map<id,AggregateResult> ([SELECT count(name) cnt, Prescriber_Account__c Id
                                                                                      FROM Lead 
                                                                          			  Where Prescriber_Account__c in :listAccount
                                                                                      and CreatedDate = THIS_FISCAL_YEAR
                                                                                      Group By Prescriber_Account__c
                                                                                            ]);
        
        
        
        Map<Id,Map<String,integer>> mapEvent = New Map<Id,Map<String,integer>>();
        for(AggregateResult agg : ListEventFY){
            if(mapEvent.containsKey((Id)agg.get('id')) ){
                ((Map<String,integer>)mapEvent.get((Id)agg.get('id'))).put((String)agg.get('Categories__c'),(Integer)agg.get('nb'));
            }else{
                
                Map<String,integer> mapinner = new Map<String,integer>{(String)agg.get('Categories__c')=>(Integer)agg.get('nb')};
                    mapEvent.put((Id)agg.get('id'),mapinner);
            }  
        }
        system.debug('mapEvent : '+mapEvent);
        
        Map<Id,Account> mapIdAccount = New Map<Id,Account>();
        For(Account accOld:listAccount ){
            integer AffairesPrescritesBTCMoisRoulant = mapAffaireBTC.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTC.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesgagneesBTCMoisRoulant = mapAffairegagneesBTC.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTC.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesBTBMoisRoulant = mapAffaireBTB.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTB.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesgagneesBTBMoisRoulant = mapAffairegagneesBTB.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTB.get(accOld.id)).get('cnt'):0;
            
            integer AffairesPrescritesBTCFY = mapAffaireBTCFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTCFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesgagneesBTCFY = mapAffairegagneesBTCFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTCFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesBTBFY = mapAffaireBTBFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTBFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesgagneesBTBFY = mapAffairegagneesBTBFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTBFY.get(accOld.id)).get('cnt'):0;
            
            integer AffairesPrescritesBTCLFY = mapAffaireBTCLFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTCLFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesGagneesBTCLFY = mapAffairegagneesBTCLFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTCLFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesBTBLFY = mapAffaireBTBLFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffaireBTBLFY.get(accOld.id)).get('cnt'):0;
            integer AffairesPrescritesGagneesBTBLFY = mapAffairegagneesBTBLFY.containsKey(accOld.id)?(integer)((AggregateResult)mapAffairegagneesBTBLFY.get(accOld.id)).get('cnt'):0;
            
            integer affairePrescrite =affairesPrescritesBTCMoisRoulant+affairesPrescritesBTBMoisRoulant;
            integer affaireGagnees = affairesPrescritesgagneesBTCMoisRoulant+affairesPrescritesgagneesBTBMoisRoulant;
            String Scoring ='';            
            
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
            
            
            Account accNew = new Account( id=accOld.id, 
                                         Nb_de_contacts_telephoniques_FYTD__c=mapEvent.containsKey(accOld.id)?((Map<String,integer>)mapEvent.get(accOld.id)).get('Categorie_Event_2'):0,
                                         Nb_de_journees_d_animation_FYTD__c=mapEvent.containsKey(accOld.id)?((Map<String,integer>)mapEvent.get(accOld.id)).get('Categorie_Event_3'):0,
                                         Nb_de_visites_realisees__c=mapEvent.containsKey(accOld.id)?((Map<String,integer>)mapEvent.get(accOld.id)).get('Categorie_Event_1'):0, 
                                         Scoring__c=Scoring,
                                         Affaires_GEC_prescrites_A_BtoC__c=AffairesPrescritesBTCFY,
                                         Affaires_GEC_prescrites_A_BtoB__c=AffairesPrescritesBTBFY,
                                         Affaires_GEC_prescritesgagnees_A_BtoC__c=AffairesPrescritesgagneesBTCFY,
                                         Affaires_GEC_prescrites_gagnees_A_BtoB__c=AffairesPrescritesgagneesBTBFY,
                                         Affaires_GEC_prescrites_A_moins1_BtoC__c=AffairesPrescritesBTCLFY,
                                         Affaires_GEC_prescrites_A_1_BtoB__c=AffairesPrescritesBTBLFY,
                                         Affaires_GEC_prescrites_gagnees_A_1_BtoC__c=AffairesPrescritesGagneesBTCLFY,
                                         Affaires_GEC_prescrites_gagnees_A_1_BtoB__c=AffairesPrescritesGagneesBTBLFY,
                                         Nb_de_suspect_prescrit_FYTD__c=mapSuspectPrescritFY.containsKey(accOld.id)?(integer)((AggregateResult)mapSuspectPrescritFY.get(accOld.id)).get('cnt'):0
                                        );
            mapIdAccount.put(accOld.id, accNew);
            system.debug('CompteMaj : '+accNew);
            
        } 
        
        system.debug(mapIdAccount.values());
        List<Database.SaveResult> lsr=   Database.update(mapIdAccount.values());
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated account. Account ID: ' + sr.getId());
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
    
    
    
}