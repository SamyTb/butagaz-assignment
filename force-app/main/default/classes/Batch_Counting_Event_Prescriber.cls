global class Batch_Counting_Event_Prescriber implements Database.Batchable<sObject> {
    
    
    // Implement the interface to update the counting of YTD activities on PTLs 
    global String query;
    //global Integer iAccountToUpdateSize = 0;
    
    global  Batch_Counting_Event_Prescriber (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Account> lAcc){
        Map<id,Account> mapAccId =new Map<id,Account>();
        for (account acc:lAcc){
            mapAccId.put(acc.id,acc);
        }
        Datetime myDT = Datetime.now();
        
        map<id, list<Event>> mapAccToUpdate = new  map<id, list<Event>>();
        for( Event evt : [Select id,Type_d_evenement_GEC__c,AccountId,EndDateTime From Event where AccountId in:mapAccId.values()]){
            if( 
                evt.Type_d_evenement_GEC__c=='PRESCRIPTION' &&
                myDT.year()== ((Datetime)evt.EndDateTime).year()
            ){
                if (mapAccToUpdate.containsKey(evt.AccountId)){
                    list<Event> listevt= mapAccToUpdate.get(evt.AccountId);
                    listevt.add(evt);
                }else{
                    list<Event> listevt= new list<Event>() ;
                    listevt.add(evt);
                    mapAccToUpdate.put(evt.AccountId,listevt);
                }
            }
        }
        List<Account> listAccountToUpdate =new List<Account>();
        List<Account> listAccountToUpdateWith =new List<Account>();
        for(Id idacc : mapAccId.keySet()){
            Account acc = new Account();
            acc.id=idacc;
            
            if(mapAccToUpdate.containsKey(idacc)){
                list<Event> listevt= mapAccToUpdate.get(idacc);
                acc.Nb_de_visites_realisees__c=listevt.size();
                listAccountToUpdateWith.add(acc);
            }else{
                acc.Nb_de_visites_realisees__c=0;
            }
            
            listAccountToUpdate.add(acc);
        }
        update listAccountToUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}