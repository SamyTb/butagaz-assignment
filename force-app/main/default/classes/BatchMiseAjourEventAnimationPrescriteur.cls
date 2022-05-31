global  class BatchMiseAjourEventAnimationPrescriteur implements Database.Batchable<Event> {
    
    // This batch is intended for updating event with the new design of categorie field
    // It query all event with the type_GEC = 'Prescription' and update the categorie
    
    // Implement the interface to update the couting Opportunities for Account
    
    global String emailMessage;
    global BatchMiseAjourEventAnimationPrescriteur (){
       
    }
    global Iterable<Event> start(Database.BatchableContext info){
       return new CustomIterable();
   }
    global void execute(Database.BatchableContext BC, List<Event> listEvent) {
        List<String> ListVisiteTerrain = new List<String>();
        List<String> ListVisiteTerrain1 = new List<String>();
        List<String> ListVisiteTerrain2 = new List<String>();
        List<String> ListVisiteTerrain3 = new List<String>();
        List<String> ListVisiteTerrain4 = new List<String>();
        List<String> ListVisiteTerrain5 = new List<String>();
        List<String> ListVisiteTerrain6 = new List<String>();
        
        List<String> ListContactTelephonique = new List<String>();
        
        List<String> ListJourneeAnimation = new List<String>();
        
        ListVisiteTerrain.add('Découverte et Qualification Fiche prescripteur'); 
        ListVisiteTerrain.add('Nouveau Projet/affaire en cours');   
        ListVisiteTerrain.add('Négociation pour opération commerciale');  
        ListVisiteTerrain.add('Présentation Offres / Services');  
        ListVisiteTerrain.add('RDV technique / réunion de chantier');  
        ListVisiteTerrain.add('Réclamation Prescripteur');  
        ListVisiteTerrain.add('Recrutement Prescripteur');  
        ListVisiteTerrain.add('Réunion avec commerciaux/techniciens du prescripteur');  
        //ListVisiteTerrain.add('Réunion avec prescripteurs');  
        ListVisiteTerrain.add('Signature de convention de partenariat (ou avenant)');  
        ListVisiteTerrain.add('Tournée commune commerciale (Fabriquant/grossiste.)');  
        ListVisiteTerrain.add('Visite de courtoisie');  
        ListVisiteTerrain.add('Visite inopinée pour prise de rdv'); 
       
        
        ListVisiteTerrain1.add('Connaissance concurrent');
		ListVisiteTerrain1.add('Connaissance partenaires');
		ListVisiteTerrain1.add('Découverte potentiel du prescripteur');
		ListVisiteTerrain1.add('Découverte potentiel réalisable par Butagaz');
        
        ListVisiteTerrain2.add('Opération d\'animation réseau');
                               
		ListVisiteTerrain3.add('Présentation nouvelle offre');
		ListVisiteTerrain3.add('Présentation offre Facilipass');
        
		ListVisiteTerrain4.add('RDV fidélisation relation client/prescripteur');
        
        ListVisiteTerrain5.add('Signature de contrat/ convention de partenariat');
        ListVisiteTerrain6.add('Réunion avec prescripteurs');
        
        
        ListContactTelephonique.add('Découverte et Qualification Fiche prescripteur'); 
        ListContactTelephonique.add('Nouveau Projet/affaire en cours');  
        ListContactTelephonique.add('Négociation pour opération commerciale'); 
        ListContactTelephonique.add('Présentation Offres / Services'); 
        ListContactTelephonique.add('Réclamation Prescripteur'); 
        ListContactTelephonique.add('Réunion Visio avec commerciaux/techniciens du prescripteur'); 
        ListContactTelephonique.add('Réunion Visio avec prescripteurs'); 
        ListContactTelephonique.add('Appel pour prise de rdv'); 
        ListContactTelephonique.add('Autre motif'); 
        
        ListJourneeAnimation.add('Matinée Comptoir'); 
        ListJourneeAnimation.add('Opération portes ouvertes'); 
        ListJourneeAnimation.add('Opération d’animation réseau');
        ListJourneeAnimation.add('Présence foire & salon');  
        ListJourneeAnimation.add('Autres'); 
        
        
        List<Event> listEvtToUpdate = new List<Event>();
        for (Event evt : listEvent) {
            for (String elt : ListVisiteTerrain) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c=evt.Objectif_de_visite_1__c;
                }
            }
            
            for (String elt : ListVisiteTerrain1) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Découverte et Qualification Fiche prescripteur';
                }
            }
            
            for (String elt : ListVisiteTerrain2) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Négociation pour opération commerciale';
                }
            }
            
            for (String elt : ListVisiteTerrain3) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Présentation Offres / Services';
                }
            }
            
            for (String elt : ListVisiteTerrain4) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Visite de courtoisie';
                }
            }
            
            for (String elt : ListVisiteTerrain5) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Signature de convention de partenariat (ou avenant)';
                }
            }
            for (String elt : ListVisiteTerrain6) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_1';
                    evt.SousCategories__c='Réunion avec plusieurs prescripteurs';
                }
            }
            
            for (String elt : ListContactTelephonique) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_2';
                    evt.SousCategories__c=evt.Objectif_de_visite_1__c;
                }
            }
            for (String elt : ListJourneeAnimation) {
                if(elt.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                    evt.Categories__c='Categorie_Event_3';
                    evt.SousCategories__c=evt.Objectif_de_visite_1__c;
                }else if('Opération d’animation réseau'.equalsIgnoreCase(evt.Objectif_de_visite_1__c)){
                     evt.Categories__c='Categorie_Event_3';
                    evt.SousCategories__c='Opération portes ouvertes';
                }
            }
            listEvtToUpdate.add(evt);
        }
        update listEvtToUpdate;
    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()
                           ];
        System.debug('AsyncApexJob : '+job );
        // Send an email to the Apex job's submitter notifying of job completion.  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'supportbfi@Butagaz.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch de mise à jour des évènements créé par les animateurs  de réseau prescritpeurs sur l\'année fiscale ');
        mail.setPlainTextBody('exécution du batch de mise à jours des évènements crée par les animateurs réseau pour les comptes Prescritpeurs  ( Statut : ' + job.Status+' ) \n\r'+
                              'The batch Apex job processed : ' + job.TotalJobItems +'  batches with : '+ job.NumberOfErrors + '  failures.  \r\n '+ emailMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    global class CustomIterator implements Iterator<Event>{ 
        
        private List<Event> evts;
        private Integer currentIndex;
        
        global CustomIterator(List<Event> evts){
            this.evts = evts;
            this.currentIndex = 0;
        }
        
        global boolean hasNext(){ 
            return currentIndex < evts.size() - 1;
        }    
        
        global Event next(){
            if(hasNext()) {
                currentIndex++;
                return evts[currentIndex];
            } else {
                throw new NoSuchElementException();
            }
        } 
    }
    
    global class CustomIterable implements Iterable<Event> {
        global Iterator<Event> iterator(){
            List<Event> evts =new List<Event>(
                [Select id,AccountId,Categories__c,Objectif_de_visite_1__c 
                 From Event 
                 where AccountId in ( SELECT Id FROM Account WHERE Prescriber__c = true)
                 and   Type_d_evenement_GEC__c='PRESCRIPTION' 
                ]);
              /*List<Event> evts =new List<Event>(
                [Select id,AccountId,Categories__c,Objectif_de_visite_1__c 
                 From Event 
                 where Id='00U2o00000yTpQkEAK'
                ]);*/
            return new CustomIterator(evts);
        }
    }
    
    
}